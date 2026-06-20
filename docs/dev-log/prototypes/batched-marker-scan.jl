# Prototype: BATCHED CPU mixed-model marker scan — an exact, drop-in speedup for
# HSquared.jl `_mixed_marker_scan_stats` (src/genomic.jl). R-lane engine help for
# the post-fit scan tower (twin #45/#48; gates the GPU marker-scan work #51).
#
# THE OPPORTUNITY. The engine builds the GLS cache ONCE
# (`_mixed_marker_scan_cache`: V = sa2*Z*A*Z' + se2*I, cholV, Vinv_X,
# cholXtVinvX, Py), then loops marker-by-marker
# (`_mixed_marker_scan_stats`, src/genomic.jl:627):
#     for j: Vinv_w = cholV \ w_j           # O(n^2) BLAS-2 triangular solve, PER MARKER
#            Pw     = Vinv_w - Vinv_X*(cholXtVinvX \ (Vinv_X' w_j))
#            denom  = w_j' Pw ; alpha = w_j' Py / denom ; ...
# So m markers cost m separate BLAS-2 solves (O(m*n^2), latency-bound).
#
# THE FIX (exact, not an approximation). Replace the per-marker solve with ONE
# BLAS-3 solve over the whole centered marker matrix W (n x m):
#     Vinv_W = cholV \ W                     # one BLAS-3 solve
#     PW     = Vinv_W - Vinv_X*(cholXtVinvX \ (Vinv_X' W))
#     denom  = vec(sum(W .* PW; dims=1))     # w_j' Pw_j per column
#     alpha  = (W' Py) ./ denom ; se = sqrt.(1 ./ denom) ; z = alpha./se ; ...
# Same arithmetic, column for column -> bit-for-bit-equivalent stats (up to BLAS
# reassociation), but BLAS-3 is cache-efficient and loop-overhead-free.
#
# This script (1) builds a synthetic GLS problem, (2) computes the per-marker
# stats exactly as the engine does, (3) computes the batched stats, (4) checks
# element-wise equality, (5) benchmarks. Standalone: no HSquared dependency; the
# math mirrors genomic.jl:592-652 so the twin can drop the batched kernel in.
#
# Run:  ~/.juliaup/bin/julia docs/dev-log/prototypes/batched-marker-scan.jl
#
# RECORDED RESULT (Julia 1.10, macOS arm64, n=2000 p=3 m=20000, 2026-06-20):
#   max|d effects| = 2.9e-16   max|d se| = 5.6e-17   max|d chisq| = 3.6e-14
#   max|d denom|   = 1.8e-12   (machine precision -- BLAS reassociation only)
#   per-marker loop = 38.19s   batched = 0.82s   => 46.8x, EXACT (not an approx).
# The batched kernel is a drop-in for `_mixed_marker_scan_stats` and composes
# with LOCO (`cache_for_marker(j)`): batch per group cache, then concatenate.

using LinearAlgebra, Random, Printf

# ---- engine cache (mirrors _mixed_marker_scan_cache) ----------------------
function build_cache(y, X, Z, Ainv, sa2, se2)
    n = length(y)
    A = inv(Symmetric(Matrix(Ainv)))
    V = Symmetric(sa2 * Z * A * transpose(Z) + se2 * Matrix{Float64}(I, n, n))
    cholV = cholesky(V)
    Vinv_X = cholV \ X
    Vinv_y = cholV \ y
    cholXtVinvX = cholesky(Symmetric(transpose(X) * Vinv_X))
    Py = Vinv_y - Vinv_X * (cholXtVinvX \ (transpose(X) * Vinv_y))
    return (cholV = cholV, Vinv_X = Vinv_X, cholXtVinvX = cholXtVinvX, Py = Py)
end

# ---- per-marker loop (mirrors _mixed_marker_scan_stats exactly) -----------
function stats_loop(W, c)
    m = size(W, 2)
    effects = zeros(m); ses = zeros(m); z = zeros(m); chisq = zeros(m); denom = zeros(m)
    for j in axes(W, 2)
        w = Vector(@view W[:, j])
        Vinv_w = c.cholV \ w
        Pw = Vinv_w - c.Vinv_X * (c.cholXtVinvX \ (transpose(c.Vinv_X) * w))
        d = dot(w, Pw)
        a = dot(w, c.Py) / d
        s = sqrt(inv(d))
        denom[j] = d; effects[j] = a; ses[j] = s; z[j] = a / s; chisq[j] = (a / s)^2
    end
    return (effects = effects, ses = ses, z = z, chisq = chisq, denom = denom)
end

# ---- batched (one BLAS-3 solve) -------------------------------------------
function stats_batched(W, c)
    Vinv_W = c.cholV \ W
    PW = Vinv_W - c.Vinv_X * (c.cholXtVinvX \ (transpose(c.Vinv_X) * W))
    denom = vec(sum(W .* PW; dims = 1))
    effects = vec(transpose(W) * c.Py) ./ denom
    ses = sqrt.(inv.(denom))
    z = effects ./ ses
    chisq = z .^ 2
    return (effects = effects, ses = ses, z = z, chisq = chisq, denom = denom)
end

function run(; n = 2000, p = 3, m = 20000, seed = 1)
    Random.seed!(seed)
    # synthetic PD relationship: A = LL' + I (well-conditioned), Ainv = inv(A)
    L = randn(n, n) / sqrt(n)
    A = Symmetric(L * transpose(L) + I)
    Ainv = inv(A)
    Z = Matrix{Float64}(I, n, n)
    X = hcat(ones(n), randn(n, p - 1))
    y = randn(n)
    sa2, se2 = 0.6, 1.0
    # centered markers (column-mean centered, like VanRaden centering)
    M = Float64.(rand(0:2, n, m))
    W = M .- (sum(M; dims = 1) ./ n)

    c = build_cache(y, X, Z, Ainv, sa2, se2)

    # correctness: loop vs batched, element-wise
    sl = stats_loop(W, c)
    sb = stats_batched(W, c)
    maxabs(a, b) = maximum(abs.(a .- b))
    @printf("n=%d p=%d m=%d\n", n, p, m)
    @printf("max|d effects| = %.3e   max|d se| = %.3e   max|d chisq| = %.3e   max|d denom| = %.3e\n",
            maxabs(sl.effects, sb.effects), maxabs(sl.ses, sb.ses),
            maxabs(sl.chisq, sb.chisq), maxabs(sl.denom, sb.denom))

    # benchmark (median of a few runs, after a warmup)
    stats_loop(W[:, 1:100], c); stats_batched(W[:, 1:100], c)  # warmup
    bench(f) = begin
        ts = Float64[]
        for _ in 1:3
            t = @elapsed f(W, c)
            push!(ts, t)
        end
        sort(ts)[2]
    end
    tl = bench(stats_loop)
    tb = bench(stats_batched)
    @printf("per-marker loop: %.3fs   batched: %.3fs   speedup: %.1fx\n", tl, tb, tl / tb)
    return (tl = tl, tb = tb, speedup = tl / tb)
end

run()
