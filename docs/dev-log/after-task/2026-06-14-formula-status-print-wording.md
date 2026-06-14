# After-Task Report: Formula Status Print Wording

Date: 2026-06-14

## Task Goal

Make the printed `formula_status()` header match the current package state:
default v0.1 fitting, opt-in experimental fitting, and planned/reserved grammar
are separate categories.

## Active Lenses And Spawned Agents

- Active lenses: Ada, Shannon, Boole, Pat, Rose, Grace.
- Spawned subagents: none.
- Current lane: R.

## Files Changed

- `R/formula-status.R`
- `tests/testthat/test-phase0-api.R`
- `docs/dev-log/check-log.md`
- `docs/dev-log/coordination-board.md`
- `docs/dev-log/after-task/2026-06-14-formula-status-print-wording.md`

## Implementation

- Replaced the printed phrase "others parse-only" with:
  - a default-fit line;
  - an opt-in experimental-fit line;
  - a planned/reserved grammar line.
- Added a test that pins the new planned/reserved wording.

## Checks Run

- `/Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e "devtools::test(filter = 'phase0-api')"` - passed, 0 failures / 0 warnings / 0 skips / 76 passes.
- `/Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e "devtools::test()"` - passed, 0 failures / 0 warnings / 32 skips / 623 passes.
- `git diff --check` - passed.
- `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64 /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e "pkgdown::check_pkgdown()"` - passed, "No problems found."
- `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64 /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e "devtools::check(document = FALSE, args = '--no-manual')"` - passed, 0 errors / 0 warnings / 0 notes.

## Public Claim Audit

Clean. This is user-facing status wording only. It does not promote any planned
or partial model capability.

## Tests Of The Tests

The new `phase0-api` expectation fails if the printed status header stops
separating planned/reserved grammar from opt-in fitted targets.

## Coordination Notes

No Julia files were edited. This keeps R's status table aligned with the
coordination-board claim boundaries after the structured covariance vocabulary
slice.

## What Did Not Go Smoothly

Nothing material; this was a direct wording fix found while testing the previous
slice.

## Known Limitations

The printed status is intentionally compact. Users still need the full
`formula_status()` table and `validation_status()` table for row-level detail.

## Next Actions

- Commit and push.
- Watch R-CMD-check, pkgdown, and Pages.
