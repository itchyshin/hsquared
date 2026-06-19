# After-task — Next-big-4 slice 4 (#26): multivariate covariance SEs + (#33) comparator policy (2026-06-19)

## Task goal

- **#26** (multivariate → covered support): surface the engine's
  `multivariate_covariance_standard_errors` (unstructured-only) as an experimental R extractor,
  via the multivariate bridge enrichment + normalizer + `covariance_standard_errors()`.
- **#33** (validation depth): write the external-comparator policy doc consolidating which
  comparators gate which capability, the same-estimand rules, the tolerance bands, and what
  `covered` requires.

## Active lenses / agents

- Lenses: Hopper (bridge/marshalling), Kirkpatrick/Fisher (covariance estimand + honesty), Emmy
  (extractor), Rose (honesty). Autonomous run (3h goal). No spawned subagents this slice.
- Lane: R / docs.

## Files changed

- `R/julia-bridge.R` — guarded enrichment in the multivariate fit block calling
  `multivariate_covariance_standard_errors(hsq_fit, hsq_Y, hsq_X, hsq_Z, hsq_Ainv)` (only when
  `genetic_structure == :unstructured`; `try`-guarded since the observed information can be non-PD
  at a flat/boundary optimum), adding `se_*` matrices to the result Dict; normalizer passthrough
  building `result$covariance_standard_errors` (trait-labelled SE matrices + per-trait h² SE).
- `R/extractors.R` — new `covariance_standard_errors()` generic + `.default` + `.hsquared_fit`.
- `tests/testthat/test-covariance-se.R` — fixture extractor test + error tests.
- `_pkgdown.yml` — reference-index entry.
- `NEWS.md` — dev-section bullet (#26).
- `docs/design/23-comparator-policy.md` — new comparator-policy doc (#33).
- `man/covariance_standard_errors.Rd` — generated.

## Engine fact verified (read-only, origin/main 2a3eed5)

`multivariate_covariance_standard_errors(fit, Y, X, Z, Ainv)` returns a NamedTuple of SE matrices
(`genetic_covariance`, `residual_covariance`, `genetic_correlation`, `residual_correlation`),
per-trait `heritability` SE vector, and the observed `information`; it throws for non-`:unstructured`
fits and when the information is not finite PD. The R path is `:unstructured`-only, so it is
applicable; the SE matrices marshal like the existing G/R covariance matrices (proven path).

## Checks

- `air format` clean; `devtools::document()` (registered the new exports); `devtools::test()`
  840 pass / 0 fail / 0 warn / 27 skip; `pkgdown::check_pkgdown()` clean;
  `devtools::check(--no-manual)` 0/0/0 (+benign timestamp note). pkgdown deploys on push.

## Public claim audit (Rose lens, applied)

- No capability promoted. The extractor doc states heavy caveats: engine row `V4-MV-REML`
  (`partial`), recovery calibration did **not** pass (6/10), asymptotic, REML-only,
  **unstructured-only** (the engine refuses structured / factor-analytic fits, whose loadings are
  rotation-nonidentified), omitted at a flat/boundary optimum, not a validated capability. The #33
  policy doc is explicit that a one-sided floor never suffices for `covered` and that the
  multivariate rows remain `partial`.

## Tests of the tests

- The missing-field + `.default` error tests confirm clear errors (not silent `NULL`). The live
  enrichment leg is skip-guarded (engine inactive this run); the R-side normalization + extractor
  are fixture-verified, matching the established skip-guarded bridge practice.

## Known limitations / next actions

- This adds the **R-side surface** for multivariate covariance SEs; promoting `V4-MV-REML` from
  `partial` → `covered` still needs the twin's t≥2 known-truth recovery + a passing calibration
  (HSquared.jl#41; R harness #34).
- Next program-2 R-ownable slice: #29 (gryphon end-to-end vignette); #32 (Mrode beyond 3.1).
