# Multivariate partial-comparator claim sweep

Date: 2026-06-14

## Task goal

Refresh public claim surfaces after adding the optional `sommer`
diagonal-residual comparator, without promoting the multivariate row beyond
`partial`.

## Active lenses and spawned agents

Active lenses: Rose, Pat, Fisher, Curie, Grace.

Spawned agents: none.

Current lane: coordinator/docs.

## Files created or changed

- `docs/design/06-public-claims-register.md`: multivariate row now records the
  partial `sommer` diagonal-residual comparator and explicitly blocks full
  comparator validation wording.
- `vignettes/articles/model-status.Rmd`: multivariate status now says full
  same-estimand comparator evidence remains planned while the partial `sommer`
  check exists.
- `docs/design/11-next-50-slices.md`: current status updated.
- `docs/dev-log/check-log.md`: command evidence recorded.
- `docs/dev-log/coordination-board.md`: added this slice row.
- `docs/dev-log/after-task/2026-06-14-multivariate-claim-sweep.md`: this report.

## Checks run and exact outcomes

- `git diff --check`: passed.
- `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "pkgdown::check_pkgdown()"`: passed, "No problems found."
- `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "devtools::check(document = FALSE, args = '--no-manual')"`: passed, 0 errors
  / 0 warnings / 0 notes.

## Public claim audit

Rose verdict: clean.

The updated wording says:

- partial `sommer` diagonal-residual comparator evidence exists;
- full same-estimand external-comparator validation is still missing;
- no t >= 2 recovery claim exists;
- no ASReml-style production multivariate fitting claim exists.

## Tests of the tests

No R package code changed. The relevant checks are pkgdown rendering and package
check/vignette rebuilds.

## Coordination notes

This keeps public wording synchronized with issue #10, the comparator plan, and
the validation-status/capability-status rows.

## What did not go smoothly

No execution issue.

## Known limitations

This is wording hygiene only; it does not add validation evidence.

## Next actions

- Commit and push.
- Watch CI.
