# Meuwissen & Luo (1992) O(n * n_ancestors) sparse inbreeding coefficients — the
# >10k-pedigree unlock for HSquared.jl. The engine's pedigree_inverse routes F
# through _numerator_relationship, a DENSE n x n recursion hard-capped at 10,000
# animals (pedigree.jl:106-109), so no pedigree > 10k can build A^-1 today. This
# computes the full inbreeding vector F without ever forming the dense A, via the
# A = L D L' decomposition: a_ii = sum_k L_ik^2 d_k, d_k = 0.5 - 0.25(F_sire + F_dam),
# the i-th row of L built by propagating contributions up the ancestors of i.
#
# Validates F against an INDEPENDENT dense tabular A (textbook recursion, engine-free)
# to ~1e-12, then demonstrates the build at n = 1e5..1e6 where the dense path throws.
# Deps: stdlib only (no external packages) — matches the engine's Project.toml.
using Printf, Random

# Realistic DISCRETE-GENERATION pedigree (parents drawn from the immediately
# preceding generation), animals chronological (parents < child), 0 = unknown.
# Discrete generations bound the ancestor depth (= #generations), which is how real
# pedigrees behave; a flat sliding "window" over millions of animals would imply
# hundreds of unrealistically interconnected generations.
function make_pedigree(n; gen_size = 2000, seed = 1, inbreed = false, p_half = 0.0)
    Random.seed!(seed)
    sire = zeros(Int, n); dam = zeros(Int, n)
    for i in (gen_size + 1):n
        g0 = ((i - 1) ÷ gen_size) * gen_size      # start index of i's generation
        lo = max(1, g0 - gen_size + 1); hi = g0    # the preceding generation
        s = rand(lo:hi); d = rand(lo:hi)
        if !inbreed
            while d == s; d = rand(lo:hi); end
        end
        sire[i] = s
        dam[i] = (p_half > 0 && rand() < p_half) ? 0 : d   # some animals: one parent unknown
    end
    return sire, dam
end

# --- Meuwissen-Luo, O(n * ancestors) -- tiny stdlib max-heap orders ancestors -----
@inline function _siftup!(h, i)
    while i > 1
        p = i >> 1
        h[p] >= h[i] && break
        h[p], h[i] = h[i], h[p]; i = p
    end
end
@inline function _siftdown!(h, n)
    i = 1
    while true
        l = 2i; r = l + 1; big = i
        l <= n && h[l] > h[big] && (big = l)
        r <= n && h[r] > h[big] && (big = r)
        big == i && break
        h[i], h[big] = h[big], h[i]; i = big
    end
end

function ml_inbreeding(sire::Vector{Int}, dam::Vector{Int})
    n = length(sire)
    F = zeros(Float64, n)
    B = zeros(Float64, n)                       # d_i: within-family (Mendelian) variance
    L = zeros(Float64, n)
    inh = falses(n)
    heap = Int[]; sizehint!(heap, 256)
    Fp(j) = j == 0 ? -1.0 : F[j]
    @inbounds for i in 1:n
        s = sire[i]; d = dam[i]
        B[i] = 0.5 - 0.25 * (Fp(s) + Fp(d))
        if s == 0 || d == 0
            F[i] = 0.0
            continue
        end
        aii = 0.0
        L[i] = 1.0; push!(heap, i); _siftup!(heap, length(heap)); inh[i] = true
        while !isempty(heap)
            j = heap[1]                          # max index
            heap[1] = heap[end]; pop!(heap)
            !isempty(heap) && _siftdown!(heap, length(heap))
            inh[j] = false
            lj = L[j]; L[j] = 0.0
            aii += lj * lj * B[j]
            sj = sire[j]; dj = dam[j]
            if sj != 0
                L[sj] += 0.5 * lj
                if !inh[sj]; push!(heap, sj); _siftup!(heap, length(heap)); inh[sj] = true; end
            end
            if dj != 0
                L[dj] += 0.5 * lj
                if !inh[dj]; push!(heap, dj); _siftup!(heap, length(heap)); inh[dj] = true; end
            end
        end
        F[i] = aii - 1.0
    end
    return F
end

# --- independent dense tabular A (textbook, engine-free) -- O(n^2), small n only --
function dense_inbreeding(sire::Vector{Int}, dam::Vector{Int})
    n = length(sire); A = zeros(n, n)
    @inbounds for i in 1:n
        s = sire[i]; d = dam[i]
        for j in 1:i-1
            asj = s == 0 ? 0.0 : A[s, j]
            adj = d == 0 ? 0.0 : A[d, j]
            A[i, j] = A[j, i] = 0.5 * (asj + adj)
        end
        asd = (s == 0 || d == 0) ? 0.0 : A[s, d]
        A[i, i] = 1.0 + 0.5 * asd
    end
    return [A[i, i] - 1.0 for i in 1:n]
end

function validate()
    println("=== Meuwissen-Luo F vs independent dense tabular A ===")
    for (n, inb, ph, lab) in ((500, false, 0.0, "both-parents"), (2000, false, 0.0, "both-parents"),
                              (1500, true, 0.0, "inbred(sib-mating)"), (2000, false, 0.35, "35%-one-parent-known"))
        sire, dam = make_pedigree(n; gen_size = n ÷ 6, seed = 7, inbreed = inb, p_half = ph)
        Fml = ml_inbreeding(sire, dam); Fd = dense_inbreeding(sire, dam)
        @printf("  n=%-5d %-21s  max|F_ML - F_dense| = %.2e   mean F = %.4f  max F = %.4f\n",
                n, lab, maximum(abs.(Fml .- Fd)), sum(Fml)/n, maximum(Fml)); flush(stdout)
    end
end

function scaling()
    println("\n=== Meuwissen-Luo at scale (dense path throws > 10,000 animals; ~12-gen pedigree) ===")
    for n in (20_000, 50_000, 100_000, 250_000)
        sire, dam = make_pedigree(n; gen_size = max(500, n ÷ 12), seed = 3)
        F = ml_inbreeding(sire, dam)             # warm
        t = @elapsed (F = ml_inbreeding(sire, dam))
        @printf("  n=%-8d  build=%.2fs  mean F=%.5f  max F=%.4f  [dense numerator-relationship: capped at 10,000]\n",
                n, t, sum(F)/n, maximum(F)); flush(stdout)
    end
end

println("############ Meuwissen-Luo O(n) sparse inbreeding (>10k-pedigree unlock) ############")
validate()
scaling()
println("\nDONE.")
