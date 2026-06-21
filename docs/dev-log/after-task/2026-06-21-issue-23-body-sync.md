# After-task report: R issue #23 body retarget

Date: 2026-06-21

Branch: `codex/issue-23-body-sync`

Active lenses: Ada, Shannon, Jason, Fisher, Pat, Rose, Grace

Spawned subagents: none

Current lane: R coordination / bridge-status

## Scope

Update the live GitHub body of R issue #23 so it reflects the current
marker-scan state: the post-fit `gwas(fit, markers)` wrapper is already banked
for mixed, single-marker, and LOCO scans, while calibrated genome-wide
thresholds and map-annotated table extractors remain open gates.

## Live GitHub Action

Edited <https://github.com/itchyshin/hsquared/issues/23> with the current
partial/open scope and boundary.

## Files touched

- `docs/dev-log/check-log.md`
- `docs/dev-log/coordination-board.md`
- `docs/dev-log/after-task/2026-06-21-issue-23-body-sync.md`

## Boundary

This is GitHub issue-body/status synchronization only. No R behavior changed.
No significance threshold was activated. No permutation-backed cutoff,
realistic-LD calibration, PLINK/GenABEL-style comparator evidence, QTL/eQTL
table workflow, or covered-status promotion was added.

## Checks

- `Rscript --vanilla -e 'pkgdown::check_pkgdown()'` clean.
- `Rscript --vanilla /Users/z3437171/shinichi-brain/tools/check-after-task.R docs/dev-log/after-task/2026-06-21-issue-23-body-sync.md`
  clean.
- `git diff --check` clean.
- Live issue audit confirms #23 remains open with `status:partial`.
- Boundary grep confirms the current repo/status wording says `gwas()` is
  experimental/uncalibrated, map-annotated table extractors remain reserved,
  and no R threshold, comparator, QTL/eQTL table workflow, or promotion claim
  was added.
