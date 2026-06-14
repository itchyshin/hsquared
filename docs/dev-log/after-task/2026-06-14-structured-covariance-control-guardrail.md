# After-Task Report: Structured Covariance Control Guardrail

Date: 2026-06-14

## Task Goal

Prevent the reserved `engine_control$genetic_structure` field from being
silently ignored by the current opt-in multivariate R bridge.

## Active Lenses And Spawned Agents

- Active lenses: Ada, Shannon, Boole, Hopper, Kirkpatrick, Rose, Grace, Pat.
- Spawned subagents: none.
- Current lane: R.

## Files Changed

- `R/hsquared.R`
- `R/julia-bridge.R`
- `R/hs_control.R`
- `man/hs_control.Rd`
- `tests/testthat/test-multivariate.R`
- `NEWS.md`
- `docs/design/18-structured-covariance-r-control.md`
- `docs/design/11-next-50-slices.md`
- `docs/dev-log/check-log.md`
- `docs/dev-log/coordination-board.md`
- `docs/dev-log/after-task/2026-06-14-structured-covariance-control-guardrail.md`

## Implementation

- Added `hs_validate_genetic_structure_control()`.
- `genetic_structure = "unstructured"` is accepted only with
  `target = "multivariate"`.
- `genetic_structure = "diagonal"`, `"lowrank"`, or `"factor_analytic"` now
  errors as planned before Julia marshalling.
- `genetic_structure` on non-multivariate targets now errors instead of being
  ignored.
- Updated `hs_control()` documentation and `NEWS.md` wording to keep the public
  boundary clear.

## Checks Run

- `command -v air` - no `air` binary on PATH.
- `git diff --check` - passed.
- `/Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e "devtools::test(filter = 'multivariate')"` - passed, 0 failures / 0 warnings / 3 skips / 57 passes.
- `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64 /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e "devtools::document()"` - passed.
- `/Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e "devtools::test()"` - passed, 0 failures / 0 warnings / 32 skips / 615 passes.
- Rose claim grep for structured-covariance overclaims - matched only the
  intended planned/not-implemented R error text and the prior check-log grep
  record.
- `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64 /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e "pkgdown::check_pkgdown()"` - passed, "No problems found."
- `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64 /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e "devtools::check(document = FALSE, args = '--no-manual')"` - passed, 0 errors / 0 warnings / 0 notes.

## Public Claim Audit

Clean. The change does not advertise structured covariance fitting. It only
guards a reserved control field and keeps `diagonal`, `lowrank`, and
`factor_analytic` as planned until the Julia engine branch and R bridge tests
exist on main.

## Tests Of The Tests

The focused multivariate test now checks four failure/acceptance cases:
accepted `unstructured`, non-scalar values, unknown values, use on a
non-multivariate target, and planned structured values on the live multivariate
path.

## Coordination Notes

No Julia files were edited. This patch prepares the R lane for the future
structured covariance bridge without assuming `HSquared.jl#17` has landed or
promoting any Phase 4B claim.

## What Did Not Go Smoothly

`devtools::document()` introduced unrelated package-level roxygen churn
(`DESCRIPTION` / `man/hsquared-package.Rd`). That incidental churn was reverted,
keeping only the intended `hs_control.Rd` update.

## Known Limitations

- No live R bridge for `genetic_structure = "diagonal"`, `"lowrank"`, or
  `"factor_analytic"`.
- No `cov = diag()`, `cov = lowrank(K)`, or `cov = fa(K)` formula grammar.
- No loading/uniqueness extraction or rotation/sign convention.
- No validation promotion.

## Next Actions

- Commit and push the guardrail.
- Watch R-CMD-check, pkgdown, and Pages.
- When the Julia structured covariance surface lands on main, build the
  `genetic_structure = "diagonal"` bridge test first.
