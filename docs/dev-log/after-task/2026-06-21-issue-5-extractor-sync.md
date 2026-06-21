# After-task report: issue 5 extractor sync

## Task goal

Refresh the R fitted-object/extractor parent issue after the scan-result
`gwas_table(scan)` / `lod_scores(scan)` methods were banked.

## Active lenses and spawned agents

- Active lenses: Ada, Shannon, Emmy, Hopper, Boole, Pat, Rose, Grace.
- Spawned agents: none.
- Current lane: R coordinator / extractor status.

## Files changed

- `docs/dev-log/issue-map.md`
- `docs/dev-log/check-log.md`
- `docs/dev-log/coordination-board.md`
- `docs/dev-log/after-task/2026-06-21-issue-5-extractor-sync.md`

## Checks run and outcomes

- `gh issue edit 5 --repo itchyshin/hsquared --body-file -`
  updated the live fitted-object/extractor parent issue body.
- `air format .` clean.
- `/Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e 'pkgdown::check_pkgdown()'`
  clean.
- `/Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla /Users/z3437171/shinichi-brain/tools/check-after-task.R docs/dev-log/after-task/2026-06-21-issue-5-extractor-sync.md`
  clean.
- `git diff --check` clean.

## Public claim audit

Clean so far. The update only distinguishes the banked scan-object methods
`gwas_table(scan)` and `lod_scores(scan)` from still-planned fit-level /
map-annotated QTL/GWAS/eQTL table workflows.

No code behavior, calibrated uncertainty, calibrated marker significance,
production validation, map-annotated QTL/GWAS/eQTL workflow, or covered-status
promotion is claimed.

## Tests of the tests

This is an issue/docs sync. The method tests were banked in the earlier
scan-table slice; pkgdown, after-task validation, and whitespace checks guarded
this branch before banking.

## Coordination notes

R #5 remains open and `status:partial` because #22/#23 and future
extractor/result-shape children remain active. The scan-result table methods do
not close the map-annotated table workflow.

## What did not go smoothly

No unexpected issue yet. The drift was small but user-facing: without this sync,
the parent issue could be read as saying all `gwas_table()` / `lod_scores()`
surfaces were still planned.

## Known limitations

The parent issue is a coordination ledger. Actual extractor behavior is governed
by `R/extractors.R`, tests, and the capability/public-claims ledgers.

## Next actions

- Bank the issue-sync PR if remote CI is green.
- Keep R #5 open until remaining extractor/result-shape gates are split or
  closed with evidence.
