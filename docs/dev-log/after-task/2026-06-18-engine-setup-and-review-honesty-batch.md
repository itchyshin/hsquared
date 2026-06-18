# After-Task Report: Engine-Setup Onboarding + Review Honesty Fixes

Date: 2026-06-18

## Task Goal

Close the first-run onboarding gap (a freshly-installed user could not learn how
`hsquared` locates the `HSquared.jl` engine) and clear the top R-safe honesty
findings from the finish-readiness review, implemented in parallel by the team.

## Active Lenses And Spawned Agents

- Spawned subagents: yes — a 5-lens parallel workflow (`wf_7359069c-660`):
  Pat (docs), Hopper (error + fit-target), Boole (planned-marker), Fisher
  (boundary flag), Curie (regression tests). Each owned a disjoint file-set.
- Operator (Ada/Opus) ran the toolchain once and integrated.
- Current lane: R; HSquared.jl cross-referenced read-only.

## Files Changed

- R: `R/hsquared.R`, `R/bridge-payload.R`, `R/extractors.R`, `R/model-spec.R`
- Docs: `README.md`, `vignettes/hsquared.Rmd`, `vignettes/articles/fitting-models.Rmd`
- Tests: new `tests/testthat/test-engine-setup-and-honesty.R`,
  `tests/testthat/test-boundary-genomic.R`; updated `test-bridge-payload.R`,
  `test-model-spec-inspect.R`; `air format .` reformatted a few pre-existing
  test/comparator files.
- `man/hsquared-package.Rd` (document); dev-log evidence files.

## Implementation

- #6/#24 engine setup: README and Getting-started vignette now show install Julia
  + JuliaCall, `git clone` the engine, and register it via
  `Sys.setenv(HSQUARED_JULIA_PROJECT=...)` or
  `engine_control = list(julia_project = ...)`; the install-failure `stop()` now
  names those mechanisms and the `engine = "validate"` fallback. Honest: it is a
  from-source Julia checkout, not a package-managed dependency.
- #1 fit-target honesty: validate branch, payload `julia_fit_target`, and
  `model_spec()` summary all read `spec$bridge$target` (one source of truth).
- #2 planned-marker message: rewritten to point to `formula_status()` and stop
  contradicting the live opt-in fit paths.
- #4 boundary flag: `hs_fit_boundary_flag()` detects the primary
  genetic/effect component by name so genomic/single-step fits surface
  `at_boundary`.

## Checks Run

- `air format .` — clean.
- `devtools::document()` — RoxygenNote 7.3.2; `man/hsquared-package.Rd` rewritten.
- `devtools::test()` — 652 pass / 0 fail / 0 warn / 32 skip (18 files).
- `pkgdown::check_pkgdown()` — "No problems found."
- `devtools::check(document = FALSE, args = "--no-manual")` — 0 / 0 / 0.

## Public Claim Audit

Clean (Rose lens). Correctness/honesty/onboarding only; no capability promotion.
The engine is still required to fit; all opt-in/planned boundaries unchanged.

## Tests Of The Tests

- Curie's new tests were verified to go red against the pre-fix implementation
  (per the agent's report). The two updated tests pinned the old divergent
  fit-target strings; they now assert the corrected source-of-truth value.

## Coordination Notes

No Julia files were edited. The fixes were derived from the multi-lens review of
the R package (HSquared.jl cross-referenced read-only).

## Known Limitations / Follow-ups

- The univariate default validate/preview reports `fit_animal_model(...)` (the
  `spec$bridge$target` descriptor) rather than the `fit_ai_reml` estimator name —
  candidate follow-up (whether the descriptor should name the estimator).
- Remaining R-safe punch-list items (claim-attribution honesty, undocumented
  engine targets, CI policy, dead-code path, version alignment) are tracked in
  `docs/dev-log/2026-06-18-finish-readiness-punchlist.md`.

## Next Actions

- Continue the R-safe punch-list in further parallel waves; push to record CI
  evidence at a checkpoint.
