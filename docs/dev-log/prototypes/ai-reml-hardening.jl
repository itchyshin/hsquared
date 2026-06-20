# Prototype: AI-REML convergence/robustness hardening for HSquared.jl `fit_ai_reml`
# (likelihood.jl:356-420). R-lane engine help for #58.
#
# TWO GAPS (read likelihood.jl:356-420):
#  (1) `factor = cholesky(Symmetric(lhs); check = true)` (likelihood.jl:381) has NO
#      try/catch. If the mixed-model `lhs` is not positive-definite -- the common
#      real cause is a RANK-DEFICIENT / collinear fixed-effect design X (the (1,1)
#      X'X/se2 block is then singular) -- it throws a bare `PosDefException` with a
#      LAPACK stacktrace, mid-iteration, instead of a diagnosis the user can act on.
#  (2) `score_a = -0.5/sa2^2 * (q*sa2 - trace_AC - uAu)` (likelihood.jl:389) and the
#      AI information scale with 1/sa2 / 1/sa2^2, so the Newton step is numerically
#      delicate as sa2 -> 0 (near-boundary h^2; the DGP study saw 94% conv + 5%
#      pinning at h^2=0.1). The step-halving loop (likelihood.jl:407-413) only keeps
#      a_new/e_new > 0; it does not guard the factorization.
#
# THIS PROTOTYPE is a faithful DENSE mirror of the AI-REML loop (same lhs, score,
# AI information, step-halving as the sparse engine), used to (a) reproduce the
# cryptic failure on a collinear X, (b) show a guarded factorization that turns it
# into a clear, actionable error, and (c) confirm the guard is non-regressive
# (raw == guarded to machine precision on a well-posed fit). Standalone; the fix
# maps line-for-line onto the engine's sparse loop. Twin's lane to apply (#58).
#
# Run:  ~/.juliaup/bin/julia docs/dev-log/prototypes/ai-reml-hardening.jl
#
# RECORDED RESULT (Julia 1.10, macOS arm64, 2026-06-20):
#   well-posed: raw == guarded to 0.00e+00 (sa2, se2) -- the guard is NON-REGRESSIVE.
#   collinear X: raw -> PosDefException ("matrix is not positive definite", cryptic);
#                guarded -> clear "fit_ai_reml: the fixed-effect design X is
#                rank-deficient (rank 2 < 3 columns) -- drop collinear/aliased terms".
#   faithfulness: over 20 seeds the dense loop recovers the truth on average
#                (mean sa2=0.652 vs 0.6, mean se2=0.930 vs 1.0, 20/20 converged),
#                confirming it mirrors the engine's AI-REML logic.

using LinearAlgebra, Random, Printf, Statistics

# Dense MME at (sa2, se2): mirrors _sparse_mme_system.
function mme(X, Z, Ainv, y, sa2, se2)
    XtX = transpose(X) * X / se2
    XtZ = transpose(X) * Z / se2
    ZtZ = transpose(Z) * Z / se2 + Ainv / sa2
    lhs = [XtX XtZ; transpose(XtZ) ZtZ]
    rhs = vcat(transpose(X) * y / se2, transpose(Z) * y / se2)
    return Symmetric(lhs), rhs
end

# One faithful AI-REML fit. `guard=true` wraps the factorization (the proposed fix).
function ai_reml(X, Z, Ainv, y; sa2 = 1.0, se2 = 1.0, iters = 100, tol = 1e-8, guard = false)
    n = length(y); p = size(X, 2); q = size(Z, 2)
    A = inv(Symmetric(Ainv))
    converged = false
    for it in 1:iters
        lhs, rhs = mme(X, Z, Ainv, y, sa2, se2)
        local F
        if guard
            F = cholesky(lhs; check = false)              # FIX: no throw...
            if !issuccess(F)                              # ...diagnose instead.
                if rank(Matrix(X)) < p
                    error("fit_ai_reml: the fixed-effect design X is rank-deficient " *
                          "(rank $(rank(Matrix(X))) < $p columns) -- drop collinear/aliased " *
                          "terms; the mixed-model coefficient matrix is then singular.")
                else
                    error("fit_ai_reml: mixed-model coefficient matrix not positive-definite " *
                          "at sigma_a2=$(round(sa2,sigdigits=4)), sigma_e2=$(round(se2,sigdigits=4)); " *
                          "try a different start or check for near-collinear effects.")
                end
            end
        else
            F = cholesky(lhs; check = true)               # engine line 381 (cryptic throw)
        end
        sol = F \ rhs
        beta = sol[1:p]; u = sol[p+1:end]
        e = y .- X * beta .- Z * u
        Cuu = inv(Matrix(lhs))[p+1:end, p+1:end]
        trace_AC = tr(Ainv * Cuu)
        uAu = dot(u, Ainv * u)
        score_a = -0.5 / sa2^2 * (q * sa2 - trace_AC - uAu)
        score_e = -0.5 / se2^2 * (se2 * (n - p - q + trace_AC / sa2) - dot(e, e))
        hypot(score_a, score_e) < tol && (converged = true; break)
        # AI information via the projection P = Vinv - Vinv X (X'Vinv X)^-1 X' Vinv
        V = sa2 * Z * A * transpose(Z) + se2 * I
        Vi = inv(Symmetric(Matrix(V)))
        P = Vi - Vi * X * inv(Symmetric(transpose(X) * Vi * X)) * transpose(X) * Vi
        wa = (Z * u) ./ sa2; we = e ./ se2
        Pwa = P * wa; Pwe = P * we
        info = 0.5 .* [dot(wa, Pwa) dot(wa, Pwe); dot(we, Pwa) dot(we, Pwe)]
        step = info \ [score_a, score_e]
        a_new = sa2 + step[1]; e_new = se2 + step[2]; h = 0
        while (a_new <= 0 || e_new <= 0) && h < 60
            step ./= 2; a_new = sa2 + step[1]; e_new = se2 + step[2]; h += 1
        end
        sa2, se2 = a_new, e_new
    end
    return (sigma_a2 = sa2, sigma_e2 = se2, converged = converged)
end

# Tabular numerator relationship A for a pedigree (parents before offspring; 0 = unknown).
function tabular_A(sire, dam)
    n = length(sire)
    A = zeros(n, n)
    for i in 1:n
        s, d = sire[i], dam[i]
        for j in 1:(i - 1)
            asj = s == 0 ? 0.0 : A[s, j]
            adj = d == 0 ? 0.0 : A[d, j]
            A[i, j] = A[j, i] = 0.5 * (asj + adj)
        end
        A[i, i] = 1.0 + (s == 0 || d == 0 ? 0.0 : 0.5 * A[s, d])
    end
    return A
end

function build(; n_extra_dups = 0, seed = 1)
    Random.seed!(seed)
    # Half-sib pedigree: 8 unrelated sires + 8 unrelated dams, then 8 offspring per
    # sire (each from a distinct dam). Paternal half-sibs share a sire (A=0.25), which
    # identifies sigma_a2 from one record per animal -- a real animal-model design.
    n_sire = 8; n_dam = 8; off_per_sire = 8
    nf = n_sire + n_dam
    sire = vcat(fill(0, nf)); dam = vcat(fill(0, nf))
    for s in 1:n_sire, k in 1:off_per_sire
        push!(sire, s)
        push!(dam, n_sire + ((k - 1) % n_dam) + 1)
    end
    A = Symmetric(tabular_A(sire, dam))
    n = size(A, 1)
    Ainv = inv(A)
    Z = Matrix{Float64}(I, n, n)
    X = hcat(ones(n), randn(n))
    for _ in 1:n_extra_dups
        X = hcat(X, X[:, 2])   # exact duplicate column -> rank-deficient X
    end
    btrue = cholesky(A).L * randn(n) .* sqrt(0.6)
    y = 2.0 .+ X[:, 2] .* 0.5 .+ btrue .+ randn(n) .* sqrt(1.0)
    return Matrix(X), Z, Matrix(Ainv), y
end

# (a) well-posed: raw vs guarded must agree (non-regression)
X, Z, Ainv, y = build()
raw = ai_reml(X, Z, Ainv, y; guard = false)
grd = ai_reml(X, Z, Ainv, y; guard = true)
@printf("well-posed: raw  sa2=%.6f se2=%.6f conv=%s\n", raw.sigma_a2, raw.sigma_e2, raw.converged)
@printf("well-posed: grd  sa2=%.6f se2=%.6f conv=%s\n", grd.sigma_a2, grd.sigma_e2, grd.converged)
@printf("non-regression: |d sa2|=%.2e  |d se2|=%.2e\n",
        abs(raw.sigma_a2 - grd.sigma_a2), abs(raw.sigma_e2 - grd.sigma_e2))

# (b) collinear X: raw throws cryptically; guarded gives a clear, actionable error
Xc, Zc, Ainvc, yc = build(n_extra_dups = 1)
print("\ncollinear X, RAW (engine behaviour): ")
try
    ai_reml(Xc, Zc, Ainvc, yc; guard = false)
    println("(no error -- unexpected)")
catch err
    println(typeof(err), " -> ", sprint(showerror, err)[1:min(end, 90)], " ...")
end
print("collinear X, GUARDED (proposed fix): ")
try
    ai_reml(Xc, Zc, Ainvc, yc; guard = true)
    println("(no error -- unexpected)")
catch err
    println(typeof(err), " -> ", sprint(showerror, err))
end

# (c) faithfulness: single fits have sampling variance (the well-posed seed above),
# but the loop recovers the truth on average -- confirming it mirrors the engine.
function recovery_check(nseed = 20)
    sas = Float64[]; ses = Float64[]; nc = 0
    for s in 1:nseed
        Xs, Zs, As, ys = build(seed = s)
        r = ai_reml(Xs, Zs, As, ys; guard = true)
        r.converged && (nc += 1)
        push!(sas, r.sigma_a2); push!(ses, r.sigma_e2)
    end
    @printf("\nrecovery over %d seeds: mean sa2=%.3f (truth 0.6)  mean se2=%.3f (truth 1.0)  conv=%d/%d\n",
            nseed, mean(sas), mean(ses), nc, nseed)
end
recovery_check()
