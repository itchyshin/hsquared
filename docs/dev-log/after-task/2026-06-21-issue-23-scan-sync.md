# After-task report: issue 23 marker-scan sync

## Task goal

Refresh the R marker-scan bridge issue after hsquared PR #83 and HSquared.jl PR
#146 so the live issue and repo map reflect the current blocker/status split.

## Active lenses and spawned agents

- Active lenses: Ada, Shannon, Hopper, Jason, Fisher, Pat, Rose, Grace.
- Spawned agents: none.
- Current lane: R coordinator / marker-scan bridge status.

## Files changed

- `docs/dev-log/issue-map.md`
- `docs/dev-log/check-log.md`
- `docs/dev-log/coordination-board.md`
- `docs/dev-log/after-task/2026-06-21-issue-23-scan-sync.md`

## Checks run and outcomes

- `gh issue edit 23 --repo itchyshin/hsquared --body-file -`
  updated the live marker-scan issue body.
- `air format .` clean.
- `/Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e 'pkgdown::check_pkgdown()'`
  clean.
- `/Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla /Users/z3437171/shinichi-brain/tools/check-after-task.R docs/dev-log/after-task/2026-06-21-issue-23-scan-sync.md`
  clean.
- `git diff --check` clean.

## Public claim audit

Clean so far. This is an issue/docs sync only. It records that `gwas_table(scan)`
and `lod_scores(scan)` are banked thin views of existing `hs_gwas` objects, and
that local marker-scan comparator / threshold tooling is unavailable on this
host.

No R threshold activation, formula-level `marker_scan()` grammar,
map-annotated table workflow, PLINK/GenABEL/GEMMA/GCTA/SAIGE comparator
evidence, production calibration, or validation/public-claim promotion is
claimed.

## Tests of the tests

This slice changes no R behavior. The relevant test evidence was banked in the
earlier marker-scan fixture/table slices; pkgdown, after-task validation, and
whitespace checks guarded this issue-sync branch.

## Coordination notes

HSquared.jl PR #146 (`a350225`) is recorded as a Julia docs/status/issue-body
mirror of R PR #82 only. It does not add behavior or evidence. R #23 remains
open and `status:partial`; Julia #48/#61 remain the active threshold and
coordination gates.

## What did not go smoothly

No unexpected issue yet. The main risk was overreading Julia #146 as engine work;
the body and issue map keep it as status-only.

## Known limitations

The local tool-availability blocker is host-specific. Another host with accepted
scan/comparator tooling could still run the threshold or comparator protocol.

## Next actions

- Bank the issue-sync PR if remote CI is green.
- Keep #23 open until calibrated thresholds, map-annotated table workflow, and
  accepted comparator/calibration evidence are reviewed.
