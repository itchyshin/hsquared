# After-task report: GWAS article calibration sync

Date: 2026-06-21

## Goal

Sync the user-facing articles with the post-PR #134 calibration story: Julia has
a fixed-panel smoke harness, while R `gwas()` remains uncalibrated.

## Active Lenses And Agents

Active lenses: Ada, Shannon, Jason, Fisher, Pat, Rose, Grace.

Spawned agents: none.

## Files Changed

- `vignettes/articles/qtl-gwas-eqtl-status.Rmd`
- `vignettes/articles/genomic-prediction.Rmd`
- `vignettes/articles/visualizing-models.Rmd`
- `docs/dev-log/check-log.md`
- `docs/dev-log/coordination-board.md`
- `docs/dev-log/after-task/2026-06-21-gwas-article-calibration-sync.md`

The unrelated Codex handover files remain untracked and untouched.

## What Changed

The articles now distinguish Julia's fixed-marker-panel type-I calibration smoke
from an activated R significance threshold. They continue to tell users not to
report genome-wide significance from the current `gwas()` p-values.

## Checks Run

- `Rscript --vanilla -e 'pkgdown::check_pkgdown()'`: clean.
- `git diff --check`: clean.
- Boundary grep over the edited articles and this report: confirms the
  fixed-panel-smoke/no-R-threshold wording.

## Public Claim Audit

No capability claim changed. This slice does not add calibrated thresholds,
permutation-backed cutoffs, realistic-LD production calibration, external scan
comparators, QTL/eQTL table activation, or covered-status language.

## Tests Of The Tests

Not applicable; prose/status article sync.

## Coordination Notes

This follows the narrower roxygen/ledger sync in R PR #56 and the programme
board sync in R PR #57.

## What Did Not Go Smoothly

No blocker.

## Known Limitations

The articles still describe planned QTL/eQTL and map-annotated scan APIs; those
paths remain future work.

## Next Actions

Keep calibrated-threshold activation as a separate validation slice.
