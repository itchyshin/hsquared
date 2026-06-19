# After-task — #47 diagonal multivariate bridge + covariance_structure_lrt (2026-06-19)

## Task goal

Cross-lane build against the twin's committed payload contract (HSquared.jl#61, comment
4753371426): surface the `:diagonal` structured genetic covariance in the opt-in multivariate
bridge (the honesty-clean structure — no loadings, no rotation ambiguity), and add the
diagonal-vs-unstructured covariance-structure LRT, computed R-side from the contract's `loglik`
+ `n_genetic_params`.

## Active lenses / agents

- Lenses: Hopper (bridge/contract), Kirkpatrick/Fisher (estimand + LRT honesty), Boole (control
  grammar), Rose (honesty). Cross-lane pairing with the Julia engine lane (live on #61). No
  spawned subagents.
- Lane: R.

## Files changed

- `R/julia-bridge.R` — `hs_validate_genetic_structure_control()` now allows `"diagonal"`
  (lowrank/fa stay gated on the rotation convention); `hs_fit_julia_multivariate_payload()` gains
  a `genetic_structure` arg, assigns + passes `genetic_structure = Symbol(...)` to
  `fit_multivariate_reml`, and marshals `n_genetic_params` (guarded by `hasproperty`); the
  normalizer stores `genetic_structure` + `n_genetic_params` (read from the payload, else derived:
  diagonal = t, unstructured = t(t+1)/2).
- `R/hsquared.R` — captures the validated `genetic_structure` and threads it to the multivariate
  fit.
- `R/extractors.R` — new `covariance_structure_lrt(constrained, full)` (pure-R over the two fits'
  stored `loglik` + `n_genetic_params`: `stat = 2*Δloglik`, `df = Δn_genetic_params`,
  `boundary = !(diagonal-in-unstructured)`, χ² p-value).
- `tests/testthat/test-covariance-structure-lrt.R` — new (LRT value, df, boundary, p; order +
  class + missing-field guards). `test-multivariate.R` — fence test updated: `"diagonal"` accepted,
  `"lowrank"`/`"factor_analytic"` gated.
- `_pkgdown.yml`, `NEWS.md`, `man/covariance_structure_lrt.Rd` — registered.

## Built to the contract (HSquared.jl#61)

The twin posted + committed to the diagonal payload (`genetic_structure`, diagonal `G0`,
`genetic_variances`, `loglik`, `n_genetic_params = t`, EBVs, h²). The R LRT reads `loglik` +
`n_genetic_params` exactly as specified; `df = t(t+1)/2 − t = t(t−1)/2`, `boundary = false`,
χ² (no mixture correction — that's the gated lowrank/fa case). `n_genetic_params` is read from the
payload when present and otherwise derived R-side from `genetic_structure` + `n_traits`, so the
LRT is robust to when the engine field lands.

## Checks

- `air format` clean; `devtools::document()`; `devtools::test()` PASS (the LRT + the updated fence
  run on CI; the live diagonal *fit* is skip-guarded — engine inactive); `pkgdown::check_pkgdown()`
  clean; `devtools::check(--no-manual)` 0/0/0 (see CI-evidence note).

## Public claim audit (Rose lens, applied)

- `:diagonal` is honesty-clean to surface ahead of lowrank/fa: it has no loadings and no rotation
  non-identifiability (the exact reason the twin cleared it). `covariance_structure_lrt` is
  documented experimental, mirrors `V4-MV-REML` (`partial`) — asymptotic, REML-only, dense
  validation-scale, recovery calibration not passed — "a reported test, not a validated one".
  lowrank/fa remain gated; the guardrail error names the rotation convention.

## Tests of the tests

- The LRT value is checked against a hand value (`2*(−108−−110)=4`, df 1, `pchisq(4,1)`); the
  order guard (df ≤ 0), class guard, and missing-`loglik` guard confirm clear failures.

## Known limitations / next actions

- The live diagonal *fit* needs the engine + the twin's payload to land (the twin is implementing
  it to the same contract); the R unpack + LRT are fixture-verified, fit leg skip-guarded — the
  established pattern. Will activate/verify the live leg on the twin's fixture landing (they'll
  post the path on #61).
- lowrank/fa stay gated on #42 + the rotation convention (do-not-start, by agreement).
