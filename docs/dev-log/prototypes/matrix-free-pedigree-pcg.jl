# Matrix-free PCG MME solve — prototype + validation vs direct CHOLMOD, and a
# scaling benchmark. Foundational kernel for the Stage-B matrix-free REML and the
# GPU target. Standalone; does not touch the HSquared.jl working tree.
using HSquared, SparseArrays, LinearAlgebra, Random, Printf

# Build a random multi-generation pedigree, its sparse Ainv, and a y with real
# additive signal so the problem is well-conditioned.
function make_problem(n::Int; nfound::Int = max(50, n ÷ 10), sa2 = 1.0, se2 = 1.0, seed = 1)
    Random.seed!(seed)
    ids = ["a$i" for i in 1:n]
    sire = fill("0", n); dam = fill("0", n)
    window = 800                      # parents from a recent window -> realistic, modest fill-in
    for i in (nfound + 1):n
        lo = max(1, i - window)
        s = rand(lo:i-1)
        d = rand(lo:i-1)
        while d == s
            d = rand(lo:i-1)
        end
        sire[i] = ids[s]
        dam[i]  = ids[d]
    end
    ped = HSquared.normalize_pedigree(ids, sire, dam)
    Ainv = sparse(Float64.(HSquared.pedigree_inverse(ped)))
    q = size(Ainv, 1)
    Z = sparse(1.0I, q, q)            # one record per animal, in ped order
    X = ones(q, 1)
    y = 5.0 .+ randn(q)               # PCG == direct holds for any rhs; no dense A needed
    return (; y, X, Z, Ainv, ped, q)
end

# Matrix-free C·v: never forms C. C = [[X'X/se2, X'Z/se2]; [Z'X/se2, Z'Z/se2 + Ainv/sa2]].
function applyC(v, X, Z, Ainv, sa2, se2, nf)
    vb = @view v[1:nf]; vu = @view v[nf+1:end]
    t  = X * vb .+ Z * vu                      # length n  (the only n-vectors)
    top = (transpose(X) * t) ./ se2
    bot = (transpose(Z) * t) ./ se2 .+ (Ainv * vu) ./ sa2
    return vcat(top, bot)
end

# Jacobi (diagonal) preconditioner: M⁻¹ = 1 ./ diag(C).
function jacobi_Minv(X, Z, Ainv, sa2, se2)
    dX = vec(sum(abs2, X; dims = 1)) ./ se2
    dZ = vec(sum(abs2, Z; dims = 1)) ./ se2 .+ diag(Ainv) ./ sa2
    return 1.0 ./ vcat(dX, dZ)
end

# Preconditioned conjugate gradients, matrix-free.
function pcg(applyA, b, Minv; tol = 1e-10, maxit = 2000)
    x = zeros(length(b))
    r = b .- applyA(x)
    z = Minv .* r
    p = copy(z)
    rz = dot(r, z)
    bnrm = norm(b)
    its = 0
    for it in 1:maxit
        its = it
        Ap = applyA(p)
        alpha = rz / dot(p, Ap)
        x .+= alpha .* p
        r .-= alpha .* Ap
        norm(r) / bnrm < tol && break
        z .= Minv .* r
        rz_new = dot(r, z)
        p .= z .+ (rz_new / rz) .* p
        rz = rz_new
    end
    return x, its
end

function direct_C(X, Z, Ainv, sa2, se2)
    Xs = sparse(X)
    top = hcat(transpose(Xs) * Xs ./ se2, transpose(Xs) * Z ./ se2)
    bot = hcat(transpose(Z) * Xs ./ se2, transpose(Z) * Z ./ se2 .+ Ainv ./ sa2)
    return vcat(top, bot)
end

function run_case(n; sa2 = 0.8, se2 = 1.2, do_direct = true)
    p = make_problem(n; sa2, se2)
    nf = size(p.X, 2)
    b = vcat(transpose(p.X) * p.y ./ se2, transpose(p.Z) * p.y ./ se2)
    Minv = jacobi_Minv(p.X, p.Z, p.Ainv, sa2, se2)
    Aop(v) = applyC(v, p.X, p.Z, p.Ainv, sa2, se2, nf)

    x_pcg, its = pcg(Aop, b, Minv)        # warm
    t_pcg = @elapsed pcg(Aop, b, Minv)

    if do_direct
        F = cholesky(Symmetric(direct_C(p.X, p.Z, p.Ainv, sa2, se2)); check = true)
        x_dir = F \ b
        rel = norm(x_pcg .- x_dir) / norm(x_dir)
        t_dir = @elapsed (cholesky(Symmetric(direct_C(p.X, p.Z, p.Ainv, sa2, se2))) \ b)
        @printf("n=%-7d q=%-7d nnz(Ainv)=%-8d PCG its=%-4d rel_err=%.2e  t_pcg=%.3fs  t_chol=%.3fs  speedup=%.2fx\n",
                n, p.q, nnz(p.Ainv), its, rel, t_pcg, t_dir, t_dir / t_pcg)
        flush(stdout); return rel
    else
        @printf("n=%-7d q=%-7d nnz(Ainv)=%-8d PCG its=%-4d  t_pcg=%.3fs  (direct skipped: prohibitive)\n",
                n, p.q, nnz(p.Ainv), its, t_pcg)
        flush(stdout); return 0.0
    end
end

function main()
    println("=== matrix-free PCG MME solve: validation vs direct CHOLMOD + scaling ===")
    flush(stdout)
    maxerr = 0.0
    maxerr = max(maxerr, run_case(1000))
    maxerr = max(maxerr, run_case(5000))
    maxerr = max(maxerr, run_case(20000))
    run_case(60000; do_direct = false)
    run_case(150000; do_direct = false)
    @printf("\nMAX rel_err (validated sizes): %.2e  (PASS if < 1e-6)\n", maxerr)
    flush(stdout)
end
main()
