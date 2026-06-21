# After-task — binomial cbind(successes, failures) counts (2026-06-20 s6)

## Goal

Fix a silently-wrong bug surfaced by the cross-lane opportunity scout (ranked A1,
correctness-first) and deliver the canonical R binomial-counts syntax.

## The bug (correctness)

On the opt-in non-Gaussian path (`target = "nongaussian"`, which widens the
accepted families to include binomial), `hsquared(cbind(succ, fail) ~ ...,
family = binomial())` was mis-detected as a **two-trait multivariate Gaussian**
model — the cbind/multivariate detection (`multivariate <- is.matrix(response)`)
was family-blind, so successes and failures were silently fitted as two Gaussian
traits. `cbind(successes, failures) ~ x` is the canonical R `glm` binomial-counts
syntax, so an applied user hits this. Verified user-reachable via
`hs_build_model_spec()` with widened families (built a multivariate spec).

## Shipped

- **`R/model-spec.R`** — `hs_build_response_spec(lhs, response, family)` is now
  family-aware: a 2-column `cbind` under `family = binomial(logit)` routes to the
  new `hs_build_binomial_counts_response()` **before** the multivariate branch, so
  it is never silently a 2-trait Gaussian. That helper extracts successes (col 1),
  computes `n_trials = successes + failures`, validates non-negative integers and
  ≥1 trial, and requires **all row totals equal** (the engine `BinomialResponse`
  holds one scalar `n_trials`); varying totals error with a directing message
  (per-record varying trials deferred to a twin issue). The family-rejection
  message now names the `cbind(successes, failures)` counts option.
- **`R/bridge-payload.R`** — the payload carries `n_trials` (NULL for every
  non-binomial-counts response).
- **`R/julia-bridge.R`** — `hs_nongaussian_family_symbol(family, n_trials)` →
  "binomial" when binomial + n_trials > 1, else "bernoulli"; the non-Gaussian
  payload fn passes `n_trials = Int(...)` to `fit_laplace_reml` only for the
  binomial-counts case.
- **`R/formula-status.R`** — the `cbind()` grammar row now states the
  binomial-counts interpretation (`family = binomial()` → counts via
  `target = "nongaussian"`), resolving the family-blind ambiguity in the
  user-facing grammar table.
- **Tests** (`test-binomial-counts.R`) — pure-R: cbind+binomial builds a
  binomial-counts (not multivariate) spec; varying totals error; gaussian cbind
  still multivariate; binary stays bernoulli; the family-symbol mapper. Live:
  balanced counts fit matches a direct engine
  `fit_laplace_reml(family=:binomial, n_trials=)` to 1e-6; a one-trial cbind
  reduces to the bernoulli fit.
- **Docs** — capability-status, NEWS (the bug-fix + the new syntax), doc 21,
  validation-debt-register.

## Honesty

- Experimental, REML-only, latent-scale, **no heritability**, not
  coverage-calibrated (V6-LAPLACE/VA, partial). The equal-row-totals constraint is
  a correct consequence of the engine's scalar `n_trials` (not arbitrary).
- Adversarial verify (6-lens Workflow): code/bridge/tests **clean**
  (Boole/Hopper/Fisher/Curie). FIX-FIRST on 2 stale-doc blockers
  (validation-debt-register + doc 21 still said "binomial trial count planned")
  and 2 Pat majors (the rejection message + `formula_status()` said "binary 0/1"
  only) — all reconciled; a Rose-principle sweep confirmed no remaining stale
  "binomial binary-only / trial-count-planned" text.

## Verification

- `air`; `devtools::document()`; pure-R `test-binomial-counts` **12/0/0/2**;
  **LIVE** **20/0/0/0** on the bridge; `pkgdown::check_pkgdown()` clean;
  `rcmdcheck(args="--no-manual")` **0/0/0**.

## Next

1. **SNP-BLUP REML** (#13) — `fit_snp_blup_reml` is on twin main (estimates
   σ²g/σ²e from markers; today `target = "snp_blup"` is supplied-variance only).
   Clean ready-now bridge slice, no grammar change.
2. Validation depth; await twin (#93 naming map / #61 / `breeding_values_plot_data`).
3. **Twin issue to file:** binomial per-record `n_trials` (the engine
   `BinomialResponse` holds one common count; varying trials would let unbalanced
   binomial-counts data fit).
