# After-task report: structured diagonal R-control design-note reconciliation

Date: 2026-06-21

Branch: `codex/structured-diagonal-doc-reconcile`

Active lenses: Ada, Shannon, Boole, Hopper, Kirkpatrick, Rose, Grace

Spawned subagents: none

Current lane: R design/docs

## Scope

Correct stale text in the structured covariance R-control design note so it
matches the current shipped diagonal subset: `engine_control =
list(genetic_structure = "diagonal")` is an experimental R-surfaced opt-in
multivariate control, while `lowrank`/`factor_analytic`, `rank`, and
formula-level `cov = ...` grammar remain planned/gated.

## Files touched

- `docs/design/18-structured-covariance-r-control.md`
- `docs/dev-log/check-log.md`
- `docs/dev-log/coordination-board.md`
- `docs/dev-log/after-task/2026-06-21-structured-diagonal-doc-reconcile.md`

## Boundary

This is documentation/status reconciliation only. No R behavior changed. No
low-rank or factor-analytic bridge was added. No loading extractor or
formula-level covariance grammar was implemented. No recovery/comparator
evidence was added, and no status was promoted.

## Checks

- `Rscript --vanilla -e 'pkgdown::check_pkgdown()'` clean.
- `Rscript --vanilla /Users/z3437171/shinichi-brain/tools/check-after-task.R docs/dev-log/after-task/2026-06-21-structured-diagonal-doc-reconcile.md`
  clean.
- `git diff --check` clean.
- Boundary grep confirms the stale planned-only diagonal wording is gone and the
  lowrank/factor-analytic/no-promotion boundary remains explicit.
