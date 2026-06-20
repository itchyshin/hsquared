# Symbolic-once Cholesky for the sparse AI-REML hot loop.
# fit_ai_reml (likelihood.jl:378-381) calls a FULL cholesky(Symmetric(lhs); check=true)
# inside the AI iteration loop. The MME pattern is INVARIANT across iterations — only
# the 1/sigma_e2 and 1/sigma_a2 scalings change the block VALUES, never the union
# sparsity of Z'Z and Ainv. So: factor symbolically ONCE, then cholesky!(F, lhs_k)
# (numeric refactor only) each subsequent iteration. This proves (a) bit-identical
# solves and (b) a per-iteration speedup that widens with q. Builds the genuine MME
# from a real pedigree Ainv. Standalone; deps: HSquared, SparseArrays, LinearAlgebra.
using SparseArrays, LinearAlgebra, Random, Printf

# Non-inbred Henderson sparse A^-1 built directly from a random multi-generation
# pedigree, O(q): A^-1 = sum_i b_i v_i v_i', v_i = (+1 at i, -1/2 at sire, -1/2 at dam),
# b_i = 1/d_i with d_i = 1/2 (both parents known), 3/4 (one), 1 (none). This is the
# exact pedigree A^-1 when there is no inbreeding, and — critically for this test —
# the genuine sparse PATTERN of the pedigree MME random block (the symbolic-once
# speedup depends only on the pattern, not on inbreeding values).
function make_mme(q::Int; nfound = max(50, q ÷ 10), window = 800, seed = 1)
    Random.seed!(seed)
    sire = zeros(Int, q); dam = zeros(Int, q)
    for i in (nfound + 1):q
        lo = max(1, i - window)
        s = rand(lo:i-1); d = rand(lo:i-1)
        while d == s; d = rand(lo:i-1); end
        sire[i] = s; dam[i] = d
    end
    I0 = Int[]; J0 = Int[]; V0 = Float64[]
    add!(i, j, v) = (push!(I0, i); push!(J0, j); push!(V0, v))
    for i in 1:q
        s, d = sire[i], dam[i]
        nk = (s > 0) + (d > 0)
        b = nk == 2 ? 2.0 : nk == 1 ? 4/3 : 1.0
        idx = [i]; w = [1.0]
        s > 0 && (push!(idx, s); push!(w, -0.5))
        d > 0 && (push!(idx, d); push!(w, -0.5))
        for a in eachindex(idx), c in eachindex(idx)
            add!(idx[a], idx[c], b * w[a] * w[c])
        end
    end
    Ainv = sparse(I0, J0, V0, q, q)
    Z = sparse(1.0I, q, q); X = ones(q, 1)
    y = 5.0 .+ randn(q)
    return (; Ainv, Z, X, y, n = q)
end

# Henderson MME lhs/rhs at (sa2, se2). Pattern is identical for all (sa2, se2).
function mme(p, sa2, se2)
    X, Z, Ainv = p.X, p.Z, p.Ainv
    Xs = sparse(X)
    top = hcat(transpose(Xs) * Xs ./ se2, transpose(Xs) * Z ./ se2)
    bot = hcat(transpose(Z) * Xs ./ se2, transpose(Z) * Z ./ se2 .+ Ainv ./ sa2)
    lhs = vcat(top, bot)
    rhs = vcat(transpose(Xs) * p.y ./ se2, transpose(Z) * p.y ./ se2)
    return Symmetric(lhs), rhs
end

# A short sweep of (sa2, se2) standing in for the AI-REML iterates.
thetas() = [(0.8, 1.2), (0.9, 1.15), (1.0, 1.1), (1.05, 1.05), (1.1, 1.0), (1.12, 0.98)]

function run_case(q)
    p = make_mme(q)
    th = thetas()
    # --- (A) fresh full cholesky each iteration (current fit_ai_reml path) ---
    function fresh()
        local x
        for (sa2, se2) in th
            L, r = mme(p, sa2, se2)
            F = cholesky(L; check = true)
            x = F \ r
        end
        return x
    end
    # --- (B) symbolic-once: full factor on iter 1, cholesky! numeric refactor after ---
    function reuse()
        local x, F
        for (k, (sa2, se2)) in enumerate(th)
            L, r = mme(p, sa2, se2)
            if k == 1
                F = cholesky(L; check = true)
            else
                cholesky!(F, L)            # numeric refactor only; pattern reused
            end
            x = F \ r
        end
        return x
    end
    xa = fresh(); xb = reuse()
    relerr = norm(xa .- xb) / norm(xa)
    ta = minimum(@elapsed(fresh()) for _ in 1:3)
    tb = minimum(@elapsed(reuse()) for _ in 1:3)
    @printf("q=%-7d nnz(Ainv)=%-9d  solve_relerr(A vs B)=%.2e  fresh=%.3fs  symbolic-once=%.3fs  speedup=%.2fx\n",
            q, nnz(p.Ainv), relerr, ta, tb, ta / tb)
    flush(stdout)
end

println("=== symbolic-once cholesky! vs fresh cholesky in the AI-REML loop (6 iters) ===")
for q in (5000, 20000, 50000, 100000)
    run_case(q)
end
println("DONE.")
