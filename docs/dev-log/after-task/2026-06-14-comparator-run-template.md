# Manual comparator-run report template

Date: 2026-06-14

## Task goal

Create a standard report surface for future manual external-comparator runs so
ASReml-R, BLUPF90/AIREMLF90, DMU, WOMBAT, sommer, JWAS, or related results can
be reviewed without muddling raw output and public claims.

## Active lenses and spawned agents

Active lenses: Ada, Shannon, Curie, Fisher, Rose, Grace, Pat.

Spawned agents: none.

Current lane: coordinator/docs.

## Files created or changed

- `docs/dev-log/comparator-runs/TEMPLATE.md`: new manual comparator-run report
  template.
- `docs/dev-log/comparator-runs/README.md`: points contributors to the template.
- `docs/design/11-next-50-slices.md`: current status updated.
- `docs/dev-log/check-log.md`: command evidence recorded.
- `docs/dev-log/coordination-board.md`: added this slice row.
- `docs/dev-log/after-task/2026-06-14-comparator-run-template.md`: this report.

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

Rose verdict: clean-with-limitations.

This template is not comparator evidence. It only defines the provenance and
review fields required before any external run can move a validation row.

## Tests of the tests

No executable package code changed. The relevant checks are markdown/package
build checks.

## Coordination notes

This supports issue #10 and the manual comparator scripts by creating a place
to record exact run evidence later.

## What did not go smoothly

No execution issue.

## Known limitations

No external comparator was run.

## Next actions

- Run markdown/package checks.
- Commit and push.
- Watch R-CMD-check/pkgdown/Pages.
- Comment on issue #10 with the comparator-script smoke and report-template
  status.
