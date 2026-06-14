# Manual comparator-script smoke coverage

Date: 2026-06-14

## Task goal

Keep the manual ASReml-R and BLUPF90-family multivariate comparator gates from
rotting by adding CI-safe smoke tests for dry-run and file-generation paths.

## Active lenses and spawned agents

Active lenses: Ada, Shannon, Curie, Fisher, Rose, Grace.

Spawned agents: none.

Current lane: R.

## Files created or changed

- `tests/testthat/test-comparator-scripts.R`: new smoke tests for ASReml dry-run
  and BLUPF90 dry-run/temp-write paths.
- `inst/comparator-scripts/blupf90/prepare-multivariate-animal.R`: template
  lookup now works in source-tree, installed-package, and `.Rcheck` layouts.
- `docs/design/11-next-50-slices.md`: current status updated.
- `docs/dev-log/check-log.md`: command evidence recorded.
- `docs/dev-log/coordination-board.md`: added this slice row.
- `docs/dev-log/after-task/2026-06-14-comparator-script-smoke.md`: this report.

## Checks run and exact outcomes

- `/Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "devtools::test(filter = 'comparator-scripts')"`: initially failed on path
  quoting, then passed after fixes, 0 failures / 0 warnings / 0 skips / 27
  passes.
- `command -v air`: no `air` binary on PATH.
- `git diff --check`: passed.
- `/Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "devtools::test()"`: passed, 0 failures / 0 warnings / 27 live-Julia skips /
  612 passes.
- `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "pkgdown::check_pkgdown()"`: passed, "No problems found."
- `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "devtools::check(document = FALSE, args = '--no-manual')"`: first failed in
  the `.Rcheck` layout, then passed after template discovery was hardened, 0
  errors / 0 warnings / 0 notes.

## Public claim audit

Rose verdict: clean-with-limitations.

This slice hardens manual comparator infrastructure only. It does not record an
ASReml-R, RENUMF90, AIREMLF90, or BLUPF90+ run, and it does not promote any
multivariate validation row.

## Tests of the tests

The first package check failed in the built-package layout because the
BLUPF90 templates were not found under `inst/`. The fix now searches the source
layout, the installed-package layout, and the `.Rcheck` layout, and the package
check passes.

## Coordination notes

This supports the comparator plan and issue #10 by making the manual gates
reproducible, but the actual external comparator evidence remains a separate
manual run.

## What did not go smoothly

Path quoting around `Github Local` and `.Rcheck` template paths both needed
hardening. The failures were useful and are now covered.

## Known limitations

No licensed ASReml-R run and no BLUPF90-family executable run was performed.

## Next actions

- Commit and push.
- Watch R-CMD-check/pkgdown/Pages.
- Continue with R-safe documentation/comparator runway or wait for Julia twin
  structured covariance recovery evidence.
