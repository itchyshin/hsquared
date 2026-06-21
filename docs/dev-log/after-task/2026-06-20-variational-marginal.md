# After-task — variational (VA) non-Gaussian marginal bridge (2026-06-20 s6)

## Goal

Surface the engine's **variational (VA)** marginal for the opt-in non-Gaussian
(GLMM) animal model. The twin's V6 rows flagged the `"laplace"`/`"va"`
method-string and family-acceptance as "pending R-lane coordination"; a scout
found the engine's `fit_laplace_reml` **already** supports `marginal =
:variational` (and DRM-style `:LA`/`:VA`), validated engine-side (V6-LAPLACE/VA:
the VA ELBO is a verified lower bound via Gauss–Hermite quadrature). So this is a
ready, engine-backed "Julia unlocks → bridge" slice — and it answers the twin's
pending item by implementing it.

## Shipped

- **`R/julia-bridge.R`** — `hs_validate_marginal_method()` accepts `"laplace"` and
  `"variational"` (+ the DRM-style aliases `"la"`/`"va"`, case-insensitive) and
  canonicalizes to the engine symbol; the bridge already passes
  `marginal = Symbol(...)` to `fit_laplace_reml`. The user-facing spec method is
  `"Variational-REML"` vs `"Laplace-REML"`, derived from the **engine-echoed**
  result method (single source of truth). `hs_normalize_nongaussian_result()`
  tags `loglik_kind`: the VA objective is the **ELBO** (a lower bound), so a VA
  fit's `logLik`/`AIC` are not comparable with a Laplace fit's.
- **`R/hsquared.R` + `R/hs_control.R`** — roxygen documents the `marginal` key, the
  `target = "nongaussian"` paragraph, and the ELBO-not-comparable caveat
  (`?hs_control` is the canonical engine_control catalog).
- **Tests** (`test-nongaussian.R`) — pure-R: the resolver accepts laplace/
  variational + aliases, case-insensitive, rejects junk; the laplace `loglik_kind`
  tag. Live: the VA fit's spec method / `marginal_method` / `loglik_kind`, `print`
  shows `Variational-REML`, **parity** against a direct engine
  `fit_laplace_reml(..., marginal = :variational)` (1e-6), **VA ≠ Laplace** (the
  knob is not a no-op), and the `"va"` alias routes identically.
- **Docs** — capability-status non-Gaussian clause, NEWS bullet.

## Honesty

- Experimental, REML-only, latent-scale, **no heritability**, not
  coverage-calibrated (twin gate V6-LAPLACE/VA, partial). The VA value is an ELBO
  (lower bound) — surfaced via `loglik_kind` and the `?hs_control` caveat so it is
  not mistaken for a marginal log-likelihood comparable to a Laplace fit.
- **No engine edit** (lane discipline): the engine pre-built the `MarginalMethod`
  dispatch as the "canonical engine↔R method-name mapping" — this slice is pure R.
- Adversarial verify (5-lens Workflow): Hopper + Curie **clean**; SHIP-after-FIX.
  Fixed 1 **blocker** (a `validation-debt-register` row still claiming "variational
  planned" — the opposite of reality) + majors (the `marginal` key was
  undiscoverable in `?hs_control`; the ELBO/Laplace scale difference was
  un-flagged). The **Rose principle** then caught the same stale
  "Laplace-only/Laplace-REML" claim in `model-spec.R`'s error, `README.md`,
  `model-status.Rmd`, the package roxygen, `validation-status.R`, and a second
  validation-debt row — all reconciled.

## Verification

- `air`; `devtools::document()`; pure-R `test-nongaussian` **18/0/0/2**; **LIVE**
  `test-nongaussian.R` **39/0/0/0** on the bridge; `pkgdown::check_pkgdown()`
  clean; `rcmdcheck(args="--no-manual")` **0/0/0**.

## Next

1. **Binomial(n-trials) family** — the engine's `fit_laplace_reml` already accepts
   `family = :binomial` with an `n_trials` keyword (validated, hard-gated `m=20`
   recovery); the next bridge slice is R's family-acceptance contract for
   `binomial` with a trial count (`cbind(successes, failures)` / weights → the
   engine `n_trials`). The other half of the twin's "pending R-lane coordination".
2. Validation depth; await twin (#93 naming map, #61 metafounder/FA;
   `breeding_values_plot_data`).
