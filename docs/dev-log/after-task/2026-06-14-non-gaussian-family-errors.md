# Non-Gaussian family planned errors

Date: 2026-06-14

## Task goal

Make unsupported non-Gaussian family errors easier for users to understand by
naming the requested family/link and pointing back to the live Gaussian v0.1
path.

## Active lenses and spawned agents

Active lenses: Ada, Shannon, Boole, Pat, Rose, Grace.

Spawned agents: none.

Current lane: R.

## Files created or changed

- `R/model-spec.R`: family validation now reports the requested family/link and
  the closest implemented path.
- `tests/testthat/test-formula-animal.R`: focused tests for `poisson(log)` and
  `binomial(logit)` planned errors.
- `docs/design/11-next-50-slices.md`: current status updated.
- `docs/dev-log/check-log.md`: command evidence recorded.
- `docs/dev-log/coordination-board.md`: added this slice row.
- `docs/dev-log/after-task/2026-06-14-non-gaussian-family-errors.md`: this
  report.

## Checks run and exact outcomes

- `/Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "devtools::test(filter = 'formula-animal')"`: passed, 0 failures /
  0 warnings / 0 skips / 43 passes.
- `command -v air`: no `air` binary on PATH.
- `git diff --check`: passed.
- `/Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "devtools::test()"`: passed, 0 failures / 0 warnings / 27 live-Julia skips /
  614 passes.
- `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "pkgdown::check_pkgdown()"`: passed, "No problems found."
- `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "devtools::check(document = FALSE, args = '--no-manual')"`: passed, 0 errors
  / 0 warnings / 0 notes.

## Public claim audit

Rose verdict: clean.

This is error ergonomics only. It does not add Poisson, binomial, negative
binomial, GLLVM, or other non-Gaussian fitting.

## Tests of the tests

The new tests hit both the internal parser path and exported `model_spec()` path
without requiring Julia.

## Coordination notes

Non-Gaussian fitting remains Phase 6 / Julia-engine-gated.

## What did not go smoothly

`devtools::check()` was unusually slow in the vignette/test phases but passed.

## Known limitations

No non-Gaussian family is implemented.

## Next actions

- Commit and push.
- Watch R-CMD-check/pkgdown/Pages.
