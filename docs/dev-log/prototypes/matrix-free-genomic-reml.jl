# Matrix-free GENOMIC REML — exact variance-component estimation without forming
# the n x n genomic relationship matrix G = Wt Wt'  (Wt = centered/scaled markers
# / sqrt(m), so diag(G) ~ 1 and the additive variance va is on the trait scale).
#
# Model:  y = X beta + g + e,   g ~ N(0, va*G),  e ~ N(0, ve*I),   V = ve*I + va*Wt*Wt'
#
# The whole REML objective + analytic AI-REML gradient + average information are
# computed EXACTLY in O(n*m^2 + m^3) via two classical identities, never touching
# the n x n V or G:
#   matrix determinant lemma:  logdet(V) = n*log(ve) + logdet(K),  K = I_m + (va/ve)*S,  S = Wt'Wt
#   Woodbury:                  V^-1 B    = (1/ve)*( B - (va/ve)*Wt*(K^-1*(Wt'B)) )
# Every trace term in AI-REML reduces to an m x m trace (exact), so no stochastic
# trace is needed while m is moderate. SLQ logdet is demonstrated separately as the
# path to the regime where even the m x m Cholesky is too big.
#
# Validates: (a) loglik + analytic score vs a dense reference and finite differences;
# (b) VC recovery vs the dense REML optimum; (c) known-truth recovery at n where dense
# is infeasible; (d) SLQ logdet(K) vs exact. Standalone; deps: LinearAlgebra/Random/Printf.
using LinearAlgebra, Random, Printf, Statistics
BLAS.set_num_threads(Sys.CPU_THREADS)

# ---- problem -----------------------------------------------------------------
function make_genomic(n, m; va = 0.6, ve = 1.0, seed = 1)
    Random.seed!(seed)
    p = 0.05 .+ 0.9 .* rand(m)
    W = Matrix{Float64}(undef, n, m)
    @inbounds for j in 1:m
        pj = p[j]; c = 2pj; s = sqrt(2pj * (1 - pj) + 1e-9)
        for i in 1:n
            g = (rand() < pj) + (rand() < pj)
            W[i, j] = (g - c) / s
        end
    end
    Wt = W ./ sqrt(m)                       # G = Wt*Wt' has diag ~ 1
    alpha = sqrt(va) .* randn(m)            # g = Wt*alpha  => Var(g) = va*G
    g = Wt * alpha
    X = ones(n, 1)
    y = 3.0 .+ g .+ sqrt(ve) .* randn(n)
    return (; y, X, Wt, m, va_true = va, ve_true = ve)
end

# ---- one-time setup: the only O(n m^2) work; reused across all REML iterations -
function prepare(prob)
    Wt, X, y = prob.Wt, prob.X, prob.y
    n, m = size(Wt); p = size(X, 2)
    S   = transpose(Wt) * Wt          # m x m  -- the single O(n m^2) cost
    WtX = transpose(Wt) * X           # m x p
    Wty = transpose(Wt) * y           # m
    return (; Wt, X, y, n, m, p, S, WtX, Wty)
end

# ---- exact low-rank REML kernel: O(m^3 + n m) per call, given prep ------------
function reml_kernel(pp, va, ve)
    Wt, X, y = pp.Wt, pp.X, pp.y
    n, m, p = pp.n, pp.m, pp.p
    c = va / ve
    K = Matrix{Float64}(I, m, m) .+ c .* pp.S
    Kf = cholesky(Symmetric(K))
    Vinv(B) = (B .- c .* (Wt * (Kf \ (transpose(Wt) * B)))) ./ ve   # O(n m * cols(B))
    ViX = Vinv(X); Viy = Vinv(y)                                    # n x p, n  (p tiny)
    XtViX = Symmetric(transpose(X) * ViX); Rc = cholesky(XtViX)
    XtViy = transpose(X) * Viy
    beta = Rc \ XtViy
    Py = Viy .- ViX * (Rc \ XtViy)                                  # P y = V^-1 (y - X beta)
    logdetV = n * log(ve) + 2 * sum(log, diag(Kf.U))
    logdetXtViX = 2 * sum(log, diag(Rc.U))
    neg2ll = logdetV + logdetXtViX + dot(y, Py)
    return (; c, Kf, Vinv, ViX, Viy, XtViX, Rc, beta, Py, neg2ll)
end

# Analytic REML score (d logL / d theta) and average-information matrix.
# dV/dva = Wt Wt' ,  dV/dve = I.  All trace terms reduce to m x m / p x p (exact).
function reml_score_AI(pp, va, ve, K = reml_kernel(pp, va, ve))
    Wt, X, S = pp.Wt, pp.X, pp.S
    n, m, p = pp.n, pp.m, pp.p
    c = K.c; Rc = K.Rc; ViX = K.ViX; Py = K.Py
    KiS = K.Kf \ S
    trVinv = (n - c * tr(KiS)) / ve
    trP = trVinv - tr(Rc \ (transpose(ViX) * ViX))
    trWtVinvW = (tr(S) - c * tr(S * KiS)) / ve
    A = (pp.WtX .- c .* (S * (K.Kf \ pp.WtX))) ./ ve     # Wt'V^-1 X (m x p), small-matrix form
    trWPW = trWtVinvW - tr(A * (Rc \ transpose(A)))
    WtPy = transpose(Wt) * Py
    qg = dot(WtPy, WtPy); qe = dot(Py, Py)
    score = [0.5 * (qg - trWPW), 0.5 * (qe - trP)]       # [d/dva, d/dve] of logL
    # average information: AI_kl = 0.5 s_k' P s_l,  s_g = Wt(Wt'Py), s_e = Py
    Pz(z) = (zi = K.Vinv(z); zi .- ViX * (Rc \ (transpose(X) * zi)))
    sg = Wt * WtPy; se = Py
    Psg = Pz(sg); Pse = Pz(se)
    AI = [0.5*dot(sg, Psg)  0.5*dot(sg, Pse);
          0.5*dot(se, Psg)  0.5*dot(se, Pse)]
    return score, Symmetric(AI), K.neg2ll
end

# AI-REML optimizer with non-negativity + step halving.
function fit_reml_mf(pp; va0 = nothing, ve0 = nothing, maxit = 50, tol = 1e-7, verbose = false)
    vy = var(pp.y)
    va = isnothing(va0) ? vy / 2 : va0
    ve = isnothing(ve0) ? vy / 2 : ve0
    nll_prev = Inf; iters = 0
    for it in 1:maxit
        iters = it
        score, AI, nll = reml_score_AI(pp, va, ve)
        step = AI \ score
        t = 1.0; ok = false
        local va_n, ve_n, nll_n
        for _ in 1:25
            va_n = va + t * step[1]; ve_n = ve + t * step[2]
            if va_n > 1e-10 && ve_n > 1e-10
                nll_n = reml_kernel(pp, va_n, ve_n).neg2ll
                if nll_n <= nll + 1e-8
                    ok = true; break
                end
            end
            t *= 0.5
        end
        ok || (va_n = max(va + 1e-3*step[1], 1e-8); ve_n = max(ve + 1e-3*step[2], 1e-8);
               nll_n = reml_kernel(pp, va_n, ve_n).neg2ll)
        verbose && @printf("  it=%2d  va=%.5f ve=%.5f  -2logL=%.6f  |step|=%.2e\n",
                           it, va_n, ve_n, nll_n, norm(t .* step))
        conv = abs(nll_prev - nll_n) < tol && norm(score) < 1e-5
        va, ve, nll_prev = va_n, ve_n, nll_n
        conv && break
    end
    return (; va, ve, h2 = va / (va + ve), neg2ll = nll_prev, iters)
end

# ---- dense reference (small n only) ------------------------------------------
function neg2ll_dense(prob, va, ve)
    Wt, X, y = prob.Wt, prob.X, prob.y
    n = size(Wt, 1)
    V = ve .* Matrix{Float64}(I, n, n) .+ va .* (Wt * transpose(Wt))
    F = cholesky(Symmetric(V))
    ViX = F \ X; Viy = F \ y
    XtViX = Symmetric(transpose(X) * ViX); Rc = cholesky(XtViX)
    Py = Viy .- ViX * (Rc \ (transpose(X) * Viy))
    return 2*sum(log, diag(F.U)) + 2*sum(log, diag(Rc.U)) + dot(y, Py)
end

function fit_reml_dense(prob; maxit = 60)
    # coordinate-free Nelder-Mead-ish: simple grid refine on (log va, log ve)
    vy = var(prob.y)
    best = (1e18, vy/2, vy/2)
    for _ in 1:maxit
        va, ve, f = best[2], best[3], best[1]
        improved = false
        for dv in (-1,0,1), de in (-1,0,1)
            (dv==0 && de==0) && continue
            van = va * exp(0.15*dv); ven = ve * exp(0.15*de)
            fn = neg2ll_dense(prob, van, ven)
            if fn < f; best = (fn, van, ven); f = fn; improved = true; end
        end
        improved || (best = (best[1], best[2]*1.0, best[3]))  # shrink handled by loop count
    end
    return (; va = best[2], ve = best[3], neg2ll = best[1])
end

# ---- stochastic Lanczos quadrature: logdet(K) for the huge-m fallback --------
function slq_logdet(applyK, m; nv = 24, L = 30, seed = 7)
    Random.seed!(seed)
    acc = 0.0
    for _ in 1:nv
        v = rand((-1.0, 1.0), m); v ./= norm(v)
        # Lanczos
        alphas = zeros(L); betas = zeros(L-1)
        vprev = zeros(m); w = copy(v); b = 0.0
        for k in 1:L
            Aw = applyK(w)
            a = dot(w, Aw); alphas[k] = a
            r = Aw .- a .* w .- b .* vprev
            b = norm(r)
            k < L && (betas[k] = b)
            (b < 1e-12) && (alphas = alphas[1:k]; betas = betas[1:max(k-1,0)]; break)
            vprev = w; w = r ./ b
        end
        T = SymTridiagonal(alphas, betas)
        vals, vecs = eigen(T)
        acc += sum(@. (vecs[1, :]^2) * log(vals))
    end
    return (m / nv) * acc
end

# ---- drivers -----------------------------------------------------------------
function validate_small()
    println("=== (a) exact low-rank REML vs DENSE reference + finite-difference score ===")
    prob = make_genomic(400, 250; va = 0.7, ve = 1.3, seed = 3)
    pp = prepare(prob)
    va, ve = 0.55, 1.1
    K = reml_kernel(pp, va, ve)
    nll_d = neg2ll_dense(prob, va, ve)
    @printf("  -2logL  matfree=%.8f  dense=%.8f  abs_err=%.2e\n", K.neg2ll, nll_d, abs(K.neg2ll - nll_d))
    score, AI, _ = reml_score_AI(pp, va, ve)
    h = 1e-5
    fd_va = (reml_kernel(pp, va+h, ve).neg2ll - reml_kernel(pp, va-h, ve).neg2ll)/(2h)
    fd_ve = (reml_kernel(pp, va, ve+h).neg2ll - reml_kernel(pp, va, ve-h).neg2ll)/(2h)
    # score is d logL/dtheta = -0.5 d(-2logL)/dtheta
    @printf("  score_va analytic=%.6f  fd=%.6f   score_ve analytic=%.6f  fd=%.6f\n",
            score[1], -0.5*fd_va, score[2], -0.5*fd_ve)
    fit_mf = fit_reml_mf(pp)
    fit_d  = fit_reml_dense(prob)
    @printf("  REML optimum  matfree (va=%.4f ve=%.4f)  dense (va=%.4f ve=%.4f)  truth (va=%.2f ve=%.2f)\n",
            fit_mf.va, fit_mf.ve, fit_d.va, fit_d.ve, prob.va_true, prob.ve_true)
    flush(stdout)
end

function recovery_and_scaling()
    println("\n=== (b) known-truth VC recovery + timing (dense infeasible at large n) ===")
    for (n, m, dod) in ((2000, 1000, true), (8000, 1500, false), (30000, 2000, false), (80000, 3000, false))
        prob = make_genomic(n, m; va = 0.6, ve = 1.0, seed = 11)
        t_prep = @elapsed (pp = prepare(prob))
        fit = fit_reml_mf(pp)
        t_solve = @elapsed fit_reml_mf(pp)
        if dod
            fd = fit_reml_dense(prob)
            @printf("  n=%-6d m=%-5d  va_hat=%.4f ve_hat=%.4f h2=%.3f  (dense grid va=%.4f ve=%.4f)  setup=%.2fs solve=%.2fs (%d it)\n",
                    n, m, fit.va, fit.ve, fit.h2, fd.va, fd.ve, t_prep, t_solve, fit.iters)
        else
            @printf("  n=%-6d m=%-5d  va_hat=%.4f ve_hat=%.4f h2=%.3f  (truth va=0.60 ve=1.00 h2=%.3f)  setup=%.2fs solve=%.2fs (%d it)  [dense G=%.1fGB skipped]\n",
                    n, m, fit.va, fit.ve, fit.h2, 0.6/1.6, t_prep, t_solve, fit.iters, n^2*8/1e9)
        end
        flush(stdout)
    end
end

function slq_demo()
    println("\n=== (d) SLQ logdet(K) vs exact (path to the huge-m regime) ===")
    prob = make_genomic(6000, 1200; va = 0.6, ve = 1.0, seed = 5)
    S = transpose(prob.Wt) * prob.Wt
    va, ve = 0.6, 1.0; m = size(S, 1)
    K = Matrix{Float64}(I, m, m) .+ (va/ve) .* S
    exact = 2*sum(log, diag(cholesky(Symmetric(K)).U))
    applyK(v) = v .+ (va/ve) .* (S * v)
    est = slq_logdet(applyK, m; nv = 24, L = 30)
    @printf("  logdet(K)  exact=%.4f  SLQ(nv=24,L=30)=%.4f  rel_err=%.2e\n",
            exact, est, abs(est-exact)/abs(exact))
    flush(stdout)
end

println("############ matrix-free GENOMIC REML (exact low-rank AI-REML) ############")
validate_small()
recovery_and_scaling()
slq_demo()
println("\nDONE.")
