# After-Task Report: Structured Covariance Rank Guardrail

Date: 2026-06-14

## Task Goal

Prevent the future `engine_control$rank` control for low-rank and
factor-analytic multivariate covariance from being silently ignored by the
current unstructured multivariate bridge.

## Active Lenses And Spawned Agents

- Active lenses: Ada, Shannon, Boole, Hopper, Kirkpatrick, Rose, Grace, Pat.
- Spawned subagents: none.
- Current lane: R.

## Files Changed

- `R/julia-bridge.R`
- `R/hs_control.R`
- `man/hs_control.Rd`
- `tests/testthat/test-multivariate.R`
- `NEWS.md`
- `docs/design/18-structured-covariance-r-control.md`
- `docs/design/11-next-50-slices.md`
- `docs/dev-log/check-log.md`
- `docs/dev-log/coordination-board.md`
- `docs/dev-log/after-task/2026-06-14-structured-covariance-rank-guardrail.md`

## Implementation

- Extended `hs_validate_genetic_structure_control()` to inspect
  `engine_control$rank`.
- Invalid `rank` values now error as non-positive/non-integer controls.
- Valid `rank` values also error because the current bridge estimates
  unstructured G0/R0 only.
- Updated docs and NEWS so users see that `rank` is reserved, not active.

## Checks Run

- `command -v air` - no `air` binary on PATH.
- `git diff --check` - passed.
- `/Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e "devtools::test(filter = 'multivariate')"` - passed, 0 failures / 0 warnings / 3 skips / 59 passes.
- `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64 /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e "devtools::document()"` - passed.
- `/Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e "devtools::test()"` - passed, 0 failures / 0 warnings / 32 skips / 617 passes.
- Rose claim grep for rank/structured-covariance overclaims - matched only the
  intended NEWS wording, planned/not-implemented R error text, and prior grep
  records.
- `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64 /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e "pkgdown::check_pkgdown()"` - passed, "No problems found."
- `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64 /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e "devtools::check(document = FALSE, args = '--no-manual')"` - passed, 0 errors / 0 warnings / 0 notes.

## Public Claim Audit

Clean. The slice only blocks a future control from being ignored. It does not
claim low-rank, factor-analytic, structured covariance, or `cov = ...` grammar
support.

## Tests Of The Tests

The focused test checks both invalid `rank = 0` and valid-but-reserved
`rank = 1L` on the opt-in multivariate path.

## Coordination Notes

No Julia files were edited. This is R-side preparation for a future bridge once
the Julia structured covariance surface lands and validates.

## What Did Not Go Smoothly

`devtools::document()` again introduced unrelated package-level roxygen churn.
That churn was reverted, keeping only the intended `hs_control.Rd` change.

## Known Limitations

- No live low-rank or factor-analytic bridge.
- No `cov = lowrank(K)` or `cov = fa(K)` formula grammar.
- No loading, uniqueness, rotation, or sign-convention extraction.
- No validation promotion.

## Next Actions

- Commit and push the rank guardrail.
- Watch R-CMD-check, pkgdown, and Pages.
- When the Julia structured covariance surface is on main, replace the reserved
  `rank` error with real validation for `lowrank` and `factor_analytic`.
