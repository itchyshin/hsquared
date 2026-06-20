# PR seed: symbolic-once Cholesky in `fit_ai_reml` (HSquared.jl #58)

Hand-off from the R lane. The MME sparsity **pattern is invariant across AI-REML
iterations** (only the `1/σ²ₑ`, `1/σ²ₐ` scalings change the block *values*), so the
per-iteration full `cholesky` can become a symbolic-once factorization + numeric-only
`cholesky!` refactor. Standalone prototype (`symbolic-once-cholesky.jl`) measured
**bit-identical solves (rel-err 0.0)** and a **1.43–2.55× constant-factor** speedup on
a real pedigree-structured MME. The win is constant-factor (flat in q — symbolic
analysis is a ~constant fraction of each CHOLMOD factorize), not asymptotic, but it
is free and exact. Do **not** apply from the R lane — this is a proposed diff for the
twin to apply in `src/likelihood.jl`.

## Diff (against `fit_ai_reml`, `likelihood.jl` ~376–382)

```diff
     converged = false
     iters = 0
+    # The MME pattern (union of X'X, X'Z, Z'Z, Ainv) is invariant across AI
+    # iterations; only the 1/σ²ₑ, 1/σ²ₐ scalings change values. Factor symbolically
+    # once, then numeric-only `cholesky!` thereafter.
+    local factor
+    local pat_colptr, pat_rowval
     for it in 1:iterations
         iters = it
         lhs, rhs, _ = _sparse_mme_system(spec, sigma_a2, sigma_e2)
-        factor = cholesky(Symmetric(lhs); check = true)
+        if it == 1
+            factor = cholesky(Symmetric(lhs); check = true)
+            pat_colptr = copy(lhs.colptr); pat_rowval = copy(lhs.rowval)
+        else
+            # `cholesky!` silently re-runs symbolic analysis on a pattern change,
+            # which would void the FLOP saving with no error — so assert invariance.
+            @assert lhs.colptr == pat_colptr && lhs.rowval == pat_rowval \
+                "fit_ai_reml: MME pattern changed across AI iterations; symbolic reuse invalid"
+            cholesky!(factor, Symmetric(lhs); check = true)
+        end
         solution = factor \ rhs
```

Everything downstream (`selinv_trace_against(factor, …)`, `_reml_project(factor, …)`,
the `factor \ rhs` solve) is unchanged — `factor` is still a `Factor{Float64}`.

## Companion hardening (separate, recommended)

The same loop's factorization is a bare `cholesky(Symmetric(lhs); check = true)` with
**no `try/catch`** — a near-boundary non-PD overshoot throws an uncaught
`PosDefException` mid-loop (the dense path guards this and returns `Inf`). With the
symbolic-once change, wrap the `cholesky!`/`cholesky` in `try/catch PosDefException`
and fall back to an EM half-step (the existing 60-halving guard only catches negative
VCs, not a failed factorization).

## Parity test (add to `test/runtests.jl`)

Asserts the symbolic-once path reproduces the current estimator bit-for-bit on the
existing fixtures (run BEFORE and AFTER the patch; the AFTER run must match the
recorded BEFORE values):

```julia
@testset "fit_ai_reml symbolic-once parity" begin
    spec = <existing small REML fixture spec, e.g. the Mrode Ch.3/4 animal model>
    fit  = fit_ai_reml(spec; tol = 1e-10)
    # Pin the converged estimates; with the symbolic-once patch these must be identical
    # to the pre-patch run to rtol ≤ 1e-10 (the refactor changes only the linear algebra
    # path, not the arithmetic):
    @test fit.variance_components.sigma_a2 ≈ <recorded> rtol = 1e-10
    @test fit.variance_components.sigma_e2 ≈ <recorded> rtol = 1e-10
    @test fit.loglik                       ≈ <recorded> rtol = 1e-10
    # And the pattern-invariance assert must not fire across iterations.
end
```

Standalone evidence the numeric refactor is exact on the genuine MME structure:
`docs/dev-log/prototypes/symbolic-once-cholesky.jl` (R repo) — solve rel-err vs a
fresh `cholesky` is **0.0** at q ∈ {5k, 20k, 50k, 100k}.
