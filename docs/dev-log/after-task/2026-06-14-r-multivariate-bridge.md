# R multivariate bridge slice

Date: 2026-06-14

## Task goal

Surface the Julia twin's landed multivariate REML engine from the R lane without
widening public claims beyond `partial`: `cbind(trait1, trait2) ~ animal(1 | id,
pedigree = ped)` -> `Y`, `X`, sparse `Z`, pedigree `Ainv`, opt-in
`target = "multivariate"`, and fitted-object extractors for G/R matrices,
correlations, per-trait h2, and cross-trait EBVs.

## Active lenses and spawned agents

Active lenses: Ada, Shannon, Boole, Hopper, Noether, Kirkpatrick, Falconer,
Curie, Rose, Grace, Pat.

Spawned agents: none. Claude explicitly stood down from the R lane; Codex owned
this working tree for the slice.

Current lane: R.

## Files created or changed

- `R/model-spec.R`: `cbind()` response parsing, missing-trait handling, and
  fixed-effect rank guard.
- `R/bridge-payload.R`: multivariate `Y` payload and trait metadata.
- `R/hsquared.R`: opt-in `target = "multivariate"` routing and default-path
  fence.
- `R/julia-bridge.R`: multivariate Julia bridge, named `G0`/`R0` initial
  validator, result normalizer, and target validation.
- `R/extractors.R`: `genetic_covariance()`, `residual_covariance()`,
  `genetic_correlation()`, `residual_correlation()`, and non-converged
  `logLik()`/`AIC()` fence.
- `R/formula-status.R`, `R/validation-status.R`, `R/hs_control.R`: status and
  control docs for the opt-in partial target.
- `tests/testthat/test-multivariate.R`, `tests/testthat/test-phase0-api.R`,
  `tests/testthat/test-fit-object.R`: parser/payload/extractor/status tests.
- `README.md`, `DESCRIPTION`, `NEWS.md`, `_pkgdown.yml`, `ROADMAP.md`,
  `docs/design/*`, and selected vignettes: honest public wording.
- `docs/design/11-next-50-slices.md`: durable 50-slice runway.
- `man/`, `NAMESPACE`: roxygen-generated updates.
- `docs/dev-log/check-log.md`, `docs/dev-log/coordination-board.md`: evidence
  and lane state.

## Checks run and exact outcomes

- `air`: not available on PATH.
- `devtools::document()`: passed.
- `devtools::test(filter = 'multivariate')`: 0 failures / 0 warnings / 2 skips
  / 29 passes.
- `devtools::test(filter = 'multivariate|phase0-api|fit-object|julia-bridge')`:
  0 failures / 0 warnings / 10 skips / 196 passes.
- `devtools::test()`: 0 failures / 0 warnings / 27 skips / 560 passes.
- Forced JuliaCall live bridge attempt with Julia on PATH: segfaulted in
  JuliaCall/Rcpp, exit 139. Recorded as a local bridge-runtime issue; ordinary
  package tests skip live Julia paths safely because Julia is not on this shell's
  default PATH.
- Direct Julia smoke outside JuliaCall: succeeded for shape checks against
  `fit_multivariate_reml()`; short 100-iteration run returned `converged =
  false`, expected for the deliberately small optimizer budget.
- `pkgdown::check_pkgdown()`: failed first because Pandoc was not on PATH; passed
  after setting `RSTUDIO_PANDOC` to RStudio's bundled Pandoc path.
- `rg -n "pkg::" ...`: clean.
- Stale multivariate-claim scan: clean for branch-only/not-on-main residue and
  production overclaim; remaining matches are intentional caveats.
- `git diff --check`: passed.
- `devtools::check(document = FALSE, args = '--no-manual')` with
  `RSTUDIO_PANDOC` set: 0 errors / 0 warnings / 0 notes.

## Public claim audit

The new claim is deliberately narrow:

- `partial`: opt-in, experimental multivariate Gaussian animal model via
  `engine = "julia", target = "multivariate"`.
- Not default.
- REML-only.
- Animal-model-only.
- Dense validation-scale.
- Missing trait cells allowed as `NA`.
- No ASReml-style production multi-trait parity.
- No external-comparator validation.
- No t>=2 known-truth recovery claim.
- Factor-analytic / structured covariance grammar remains planned.

Rose verdict: clean with explicit blockers.

## Tests of the tests

The tests exercise:

- `cbind()` response parsing and trait labels.
- NA response cells preserved in `Y`.
- fixed-effect missingness rejected separately from response missingness.
- rank-deficient `X` rejected before engine calls.
- default `engine = "fit"` rejects multivariate and points to the opt-in target.
- `target = "multivariate"` rejects univariate responses.
- `initial` must be a named list with positive-definite `G0` and `R0`.
- non-converged results do not expose `logLik()` / `AIC()`.
- result normalizer exposes G/R covariance, G/R correlation, h2, nobs, and
  id-by-trait EBVs.
- skip-guarded live tests cover R NA -> Julia NaN marshalling and the full bridge
  when JuliaCall is usable.

## Coordination notes

Claude's final note said the earlier board handoff row had been discarded with a
checkout. Codex rechecked the board and added a fresh row for this completed R
slice rather than reviving stale local state.

The Julia lane still owns the twin-side SHOULD-FIX backlog: close orphaned PRs,
delete merged branches, committed t>=2 recovery fixture, Cholesky roundtrip
test, engine-side rank guard, conditioning caveat, PSD guard, and Julia docs
status sync.

## What did not go smoothly

Forcing Julia onto PATH made JuliaCall segfault in this local R process before
live R-to-Julia bridge tests could run. Direct Julia itself works. This should
be treated as local bridge-runtime debt, not as evidence that the R parser or
payload are correct beyond the skip-guarded and direct-Julia checks.

Pandoc was not on the shell PATH; `pkgdown::check_pkgdown()` needed
`RSTUDIO_PANDOC` set to RStudio's bundled Pandoc.

## Known limitations

- No t>=2 known-truth recovery claim for multivariate REML.
- No external comparator parity.
- No long-format `animal(trait | id, cov = ...)` R grammar.
- No structured/factor-analytic covariance R surface.
- No production sparse/deep-pedigree conditioning claim; the twin engine still
  inverts `Ainv` internally on this dense validation path.

## Next actions

Start from `docs/design/11-next-50-slices.md`. The highest-value immediate next
slice is Julia-lane cleanup and hardening: close orphaned Phase 4 PRs, delete
merged branches, sync Julia validation docs, and add the committed t>=2
multivariate recovery fixture.
