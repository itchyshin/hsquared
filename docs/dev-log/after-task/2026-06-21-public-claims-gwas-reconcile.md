# After-task report: public GWAS/marker-scan claims reconciliation

Date: 2026-06-21

Branch: `codex/public-claims-gwas-reconcile`

Active lenses: Ada, Shannon, Jason, Fisher, Pat, Rose, Grace

Spawned subagents: none

Current lane: R public claims/docs

## Scope

Correct a stale public-claims row that still implied no post-fit marker-scan or
GWAS fitting exists, after the experimental `gwas(fit, markers)` mixed,
single-marker, and LOCO bridge paths had already landed.

## Files touched

- `docs/design/06-public-claims-register.md`
- `docs/dev-log/check-log.md`
- `docs/dev-log/coordination-board.md`
- `docs/dev-log/after-task/2026-06-21-public-claims-gwas-reconcile.md`

## Boundary

This is documentation/status reconciliation only. No R behavior changed. No
genome-wide significance threshold was activated. No formula-level
`marker_scan()`, QTL, or eQTL workflow was implemented. No map-annotated
`gwas_table()`, `qtl_table()`, `eqtl_table()`, or `lod_scores()` extractor was
implemented. No external comparator/calibration evidence was added, and no
status was promoted.

## Checks

- `Rscript --vanilla -e 'pkgdown::check_pkgdown()'` clean.
- `Rscript --vanilla /Users/z3437171/shinichi-brain/tools/check-after-task.R docs/dev-log/after-task/2026-06-21-public-claims-gwas-reconcile.md`
  clean.
- `git diff --check` clean.
- Boundary grep confirms the stale no-GWAS wording is gone from the touched
  public claim row and that `gwas()` remains experimental/uncalibrated with
  map-annotated table extractors reserved.
