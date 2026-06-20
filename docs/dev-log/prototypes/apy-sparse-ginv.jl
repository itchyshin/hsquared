# APY (Algorithm for Proven and Young) sparse inverse of the genomic relationship
# matrix G — the missing open Julia implementation (twin #51: "no open Julia
# implementation exists"; scout-confirmed for the local depot + a General-registry
# name/keyword sweep — re-confirm before any public first-implementation claim).
#
# SCOPE: this demonstrates the sparse G^-1 RECURSION + its core-sizing only. It is
# GBLUP-only; the single-step H^-1 = A^-1 + scatter(G_APY^-1 - A22^-1) assembly and
# the (1-w)G + w*A22 SPD blend live in the twin (genomic.jl) and are NOT exercised
# here. The SPD guard here is a bare ridge G+lambda*I, which differs from the twin's
# A22 blend on purpose (no pedigree in this fixture).
#
# Recursion (Pocrnic et al. 2016): partition genotyped animals into core c / non-core n.
#   G_APY^-1 = [[Gcc^-1 + B Mnn^-1 B' ,  -B Mnn^-1 ],
#              [   -Mnn^-1 B'         ,    Mnn^-1  ]]   with B = Gcc^-1 Gcn,
#   Mnn = diag( g_ii - g_ic Gcc^-1 g_ci )   (the conditional variances; DIAGONAL).
# Sparsity: the (n,n) block is diagonal -> nnz ~ c^2 + 2 c n + n  vs  (c+n)^2 dense.
# Blocks are built straight from the markers, so the n x n G is NEVER formed.
# Build cost: O(c*m*n + c^2*n + c^3)  (the c*m*n marker product Gcn=Wc*Wn'/m dominates).
#
# Validates: (i) a SHARP c<n element-wise correctness test (scattered core) vs the
# explicitly-inverted APY-implied covariance + symmetry + G_APY^-1*Sigma~=I + an nn=1
# analytic check + a floor-triggering case; (ii) recovery on BOTH a clean-rank synthetic
# GRM (APY's optimistic limit) AND a realistic VanRaden biallelic GRM (smooth spectrum),
# reporting fidelity-to-full AND accuracy-vs-true-g; (iii) the under-rank failure mode;
# (iv) randomized-SVD core sizing that never forms G; (v) large-n marker-based build.
# Deps: LinearAlgebra, SparseArrays.
using LinearAlgebra, SparseArrays, Random, Printf, Statistics

# --- generators ---------------------------------------------------------------
# Clean rank-d synthetic GRM: the OPTIMISTIC limit of the Pocrnic Ne-driven
# dimensionality assumption (sharp spectral cliff at d). NOT realistic LD.
function make_lowrank(n, m, d; seed = 1)
    Random.seed!(seed)
    U = randn(n, d); V = randn(m, d)
    W = U * transpose(V) ./ sqrt(d); W .-= mean(W; dims = 1)
    a = W * (randn(m) .* (1 / sqrt(m)))
    return (; W, g = a .* (sqrt(0.5) / std(a)), m, n, kind = "lowrank(d=$d)")
end
# Realistic VanRaden biallelic GRM (independent markers -> smooth, MP-like spectrum
# with NO induced low rank -> high effective dimension; the honest hard case).
function make_vanraden(n, m; seed = 1)
    Random.seed!(seed)
    p = 0.05 .+ 0.45 .* rand(m)
    M = Matrix{Float64}(undef, n, m)
    @inbounds for j in 1:m, i in 1:n
        M[i, j] = (rand() < p[j]) + (rand() < p[j])
    end
    W = (M .- 2 .* transpose(p)) ./ sqrt(2 * sum(p .* (1 .- p)))
    a = W * (randn(m) .* (1 / sqrt(m)))
    return (; W, g = a .* (sqrt(0.5) / std(a)), m, n, kind = "vanraden")
end
grm(W, m) = (W * transpose(W)) ./ m

# --- core sizing --------------------------------------------------------------
function eig_core_size(G, thr)                       # dense; validation scale only
    ev = sort(max.(eigvals(Symmetric(G)), 0.0); rev = true)
    return findfirst(>=(thr), cumsum(ev) ./ sum(ev))
end
# Randomized-SVD core sizing that NEVER forms the n x n G: top singular values of W
# (via a range finder) give the top eigenvalues of G=WW'/m; tr(G)=sum|W|^2/m is exact.
function rsvd_core_size(W, m, thr; maxrank = 1500, oversample = 20, seed = 1)
    n, M = size(W); k = min(maxrank, n, M) + oversample
    Random.seed!(seed)
    Y = W * randn(M, k)                              # n x k
    Q = Matrix(qr(Y).Q)
    ev = sort((svdvals(transpose(Q) * W) .^ 2) ./ m; rev = true)
    total = sum(abs2, W) / m                         # exact tr(G)
    cum = cumsum(ev) ./ total
    c = findfirst(>=(thr), cum)
    return isnothing(c) ? length(ev) : c
end

# --- APY assembly -------------------------------------------------------------
function apy_assemble(core, noncore, Gcc, Gcn, gdiag_nc, lambda)
    nc = length(core); nn = length(noncore); n = nc + nn
    Fcc = cholesky(Symmetric(Gcc + lambda * I))
    B = Fcc \ Gcn                                    # Gcc^-1 Gcn, c x nn
    quad = vec(sum(Gcn .* B; dims = 1))
    Mnn = gdiag_nc .+ lambda .- quad
    nfloor = count(<=(1e-10), Mnn)
    Mnn = max.(Mnn, 1e-10); Minv = 1.0 ./ Mnn
    Gcc_inv = Fcc \ Matrix{Float64}(I, nc, nc)
    cc = Gcc_inv .+ B * (Minv .* transpose(B))
    cn = -(B .* transpose(Minv))
    I0 = Int[]; J0 = Int[]; V0 = Float64[]
    sizehint!(I0, nc*nc + 2*nc*nn + nn)
    for b in 1:nc, a in 1:nc
        push!(I0, core[a]); push!(J0, core[b]); push!(V0, cc[a, b])
    end
    for j in 1:nn, a in 1:nc
        v = cn[a, j]
        push!(I0, core[a]); push!(J0, noncore[j]); push!(V0, v)
        push!(I0, noncore[j]); push!(J0, core[a]); push!(V0, v)
    end
    for j in 1:nn
        push!(I0, noncore[j]); push!(J0, noncore[j]); push!(V0, Minv[j])
    end
    return sparse(I0, J0, V0, n, n), nfloor
end
# The explicit APY-IMPLIED covariance whose inverse G_APY^-1 must equal (original order):
#   Sigma[core,core]=Gcc+λI ; Sigma[core,non]=Gcn ; Sigma[non,non]=B'(Gcc+λI)B + diag(Mnn).
function apy_sigma(core, noncore, Gcc, Gcn, gdiag_nc, lambda)
    nc = length(core); nn = length(noncore); n = nc + nn
    Tcc = Gcc + lambda * I
    Fcc = cholesky(Symmetric(Tcc)); B = Fcc \ Gcn
    quad = vec(sum(Gcn .* B; dims = 1))
    Mnn = max.(gdiag_nc .+ lambda .- quad, 1e-10)
    Tnn = transpose(B) * (Tcc * B) + Diagonal(Mnn)   # low-rank + diagonal
    S = zeros(n, n)
    S[core, core] = Tcc; S[core, noncore] = Gcn
    S[noncore, core] = transpose(Gcn); S[noncore, noncore] = Tnn
    return S
end
function apy_ginv(G, core::Vector{Int}, lambda)
    noncore = setdiff(1:size(G, 1), core)
    apy_assemble(core, noncore, Matrix(G[core, core]), Matrix(G[core, noncore]),
                 diag(G)[noncore], lambda)
end
function apy_ginv_markers(W, m, core::Vector{Int}, lambda)
    n = size(W, 1); noncore = setdiff(1:n, core)
    Wc = W[core, :]; Wn = W[noncore, :]
    apy_assemble(core, noncore, (Wc*transpose(Wc))./m, (Wc*transpose(Wn))./m,
                 vec(sum(abs2, Wn; dims = 2)) ./ m, lambda)
end
random_core(n, c; seed = 1) = (Random.seed!(seed); sort(randperm(n)[1:c]))

function gblup_ebv(Ginv, y, sg2, se2)
    n = length(y); one = ones(n)
    A = Matrix(Ginv) ./ sg2 + Matrix{Float64}(I, n, n) ./ se2
    sol = [ n/se2 transpose(one)./se2 ; one./se2 A ] \ vcat(sum(y)/se2, y ./ se2)
    return sol[2:end]
end

# --- (i) SHARP correctness: c<n, scattered core, element-wise vs explicit inverse --
function correctness()
    println("=== (i) SHARP correctness (c<n, scattered core) ===")
    Random.seed!(3); pr = make_lowrank(60, 80, 25); G = grm(pr.W, pr.m); lambda = 0.05
    core = sort(collect(2:3:60))                      # scattered, unsorted-source core
    noncore = setdiff(1:60, core)
    Gi, nfl = apy_ginv(G, core, lambda)
    S = apy_sigma(core, noncore, Matrix(G[core, core]), Matrix(G[core, noncore]),
                  diag(G)[noncore], lambda)
    Sinv = inv(Symmetric(S))
    e_elt = norm(Matrix(Gi) - Sinv) / norm(Sinv)
    e_sym = norm(Matrix(Gi) - transpose(Matrix(Gi)))
    e_ide = norm(Matrix(Gi) * S - I) / sqrt(size(S, 1))
    @printf("  element-wise ||G_APY^-1 - inv(Sigma)||/||.|| = %.2e   (core=%d, non=%d)\n",
            e_elt, length(core), length(noncore))
    @printf("  symmetry ||G_APY^-1 - (G_APY^-1)'|| = %.2e ;  ||G_APY^-1 * Sigma - I|| = %.2e\n", e_sym, e_ide)
    # nn=1 analytic: with a single non-core animal, APY is EXACT for (G+λI)^-1
    c1 = collect(1:59); Gi1, _ = apy_ginv(G, c1, lambda)
    e_nn1 = norm(Matrix(Gi1) - inv(Symmetric(G + lambda*I))) / norm(inv(Symmetric(G + lambda*I)))
    @printf("  nn=1 exactness vs (G+lambda I)^-1 = %.2e  (certifies the non-core ridge path)\n", e_nn1)
    # floor-triggering case: tiny core + near-zero ridge -> some Mnn hit the floor
    Random.seed!(5); pr2 = make_lowrank(80, 30, 12)   # rank 12 << non-core
    G2 = grm(pr2.W, pr2.m)
    _, nfl2 = apy_ginv(G2, random_core(80, 14; seed = 1), 1e-12)
    @printf("  floor guard: with tiny ridge 1e-12 and rank-deficient blocks, Mnn floored=%d (guard active)\n", nfl2)
    # marker-built vs dense-built at c<n (not c=n)
    Gim, _ = apy_ginv_markers(pr.W, pr.m, core, lambda)
    @printf("  marker-built vs dense-built APY at c<n = %.2e\n", norm(Matrix(Gim)-Matrix(Gi))/norm(Matrix(Gi)))
    flush(stdout)
end

# --- (ii) recovery on BOTH generators, fidelity-to-full AND accuracy-vs-truth -----
function recovery_on(pr; lambda = 0.01, sg2 = 0.5, se2 = 0.5)
    n, m = pr.n, pr.m; G = grm(pr.W, m)
    Random.seed!(42); y = 2.0 .+ pr.g .+ sqrt(se2) .* randn(n)
    Gfi = inv(Symmetric(G + lambda*I)); ebv_full = gblup_ebv(Gfi, y, sg2, se2)
    cft = cor(ebv_full, pr.g)
    sizes = Dict(t => eig_core_size(G, t) for t in (0.90, 0.95, 0.98, 0.99))
    @printf("  [%s] n=%d m=%d   EIG core: 90%%=%d 95%%=%d 98%%=%d 99%%=%d (=%d%%..%d%% of n)   cor(EBV_full, true g)=%.3f\n",
            pr.kind, n, m, sizes[0.90], sizes[0.95], sizes[0.98], sizes[0.99],
            round(Int, 100*sizes[0.90]/n), round(Int, 100*sizes[0.99]/n), cft); flush(stdout)
    for t in (0.90, 0.95, 0.98, 0.99)
        c = sizes[t]
        # across-seed spread of fidelity-to-full
        fids = Float64[]; acc = 0.0
        for s in 1:6
            Gi, _ = apy_ginv(G, random_core(n, c; seed = s), lambda)
            e = gblup_ebv(Gi, y, sg2, se2)
            push!(fids, cor(e, ebv_full)); s == 1 && (acc = cor(e, pr.g))
        end
        @printf("      EIG%2d%% core=%-5d  fidelity-to-full cor=%.4f [seed-spread %.4f-%.4f]  accuracy-vs-true=%.3f  nnz/dense=%.3f\n",
                Int(100t), c, fids[1], minimum(fids), maximum(fids), acc,
                (apy_ginv(G, random_core(n, c; seed=1), lambda)[1] |> nnz) / n^2); flush(stdout)
    end
    return G, y, ebv_full, sizes
end
function recovery()
    println("\n=== (ii) recovery: optimistic clean-rank vs realistic VanRaden ===")
    println("  (cor(EBV_APY,EBV_full) = FIDELITY to the full-G solution, not accuracy;")
    println("   accuracy-vs-true = cor(EBV_APY, simulated true breeding values))")
    recovery_on(make_lowrank(2000, 1500, 250))
    G, y, ebv_full, sizes = recovery_on(make_vanraden(2000, 1500))
    println("\n=== (iii) under-rank failure mode (read via the vs-full drop) ===")
    pr = make_lowrank(2000, 1500, 250); G2 = grm(pr.W, pr.m)
    Random.seed!(42); y2 = 2.0 .+ pr.g .+ sqrt(0.5) .* randn(2000)
    ef = gblup_ebv(inv(Symmetric(G2 + 0.01I)), y2, 0.5, 0.5)
    c98 = eig_core_size(G2, 0.98)
    for (lab, c) in (("EIG98 (adequate)", c98), ("tiny core (c<<eff.dim)", max(20, c98 ÷ 6)))
        a = gblup_ebv(apy_ginv(G2, random_core(2000, c; seed=11), 0.01)[1], y2, 0.5, 0.5)
        b = gblup_ebv(apy_ginv(G2, random_core(2000, c; seed=22), 0.01)[1], y2, 0.5, 0.5)
        @printf("      %-22s core=%-4d  fidelity-vs-full: A=%.3f B=%.3f  (cross-seed cor=%.3f; under-ranking signature)\n",
                lab, c, cor(a, ef), cor(b, ef), cor(a, b)); flush(stdout)
    end
end

# --- (iv) randomized-SVD core sizing (never forms G) + (v) scale build -----------
function scaling()
    println("\n=== (iv) randomized-SVD core sizing vs dense eig (never forms G) ===")
    pr = make_lowrank(2000, 1500, 250); G = grm(pr.W, pr.m)
    @printf("  lowrank n=2000: eig EIG98=%d   rSVD EIG98=%d  (agreement check)\n",
            eig_core_size(G, 0.98), rsvd_core_size(pr.W, pr.m, 0.98)); flush(stdout)
    prv = make_vanraden(2000, 1500); Gv = grm(prv.W, prv.m)
    @printf("  vanraden n=2000: eig EIG98=%d   rSVD EIG98=%d\n",
            eig_core_size(Gv, 0.98), rsvd_core_size(prv.W, prv.m, 0.98)); flush(stdout)
    println("\n=== (v) APY marker-based build at scale (G never formed; core from rSVD) ===")
    for (n, m, d) in ((10000, 3000, 400), (40000, 4000, 600), (100000, 5000, 800))
        pr = make_lowrank(n, m, d; seed = 7)
        c = rsvd_core_size(pr.W, pr.m, 0.98)
        core = random_core(n, c; seed = 1)
        Gi, nfl = apy_ginv_markers(pr.W, pr.m, core, lambda)
        t = @elapsed apy_ginv_markers(pr.W, pr.m, core, lambda)
        @printf("  n=%-7d rSVD-core=%-5d  nnz=%-11d  nnz/dense=%.4f  build=%.2fs  floored=%d  [dense G^-1=%.1fGB skipped]\n",
                n, c, nnz(Gi), nnz(Gi)/n^2, t, nfl, n^2*8/1e9); flush(stdout)
    end
end
const lambda = 0.01

println("############ APY sparse genomic inverse (open Julia first) ############")
correctness()
recovery()
scaling()
println("\nDONE.")
