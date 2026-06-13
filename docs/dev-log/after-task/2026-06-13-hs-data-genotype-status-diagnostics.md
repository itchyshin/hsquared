# hs_data Genotype-Status Diagnostics

Date: 2026-06-13

Active lenses: Emmy, Jason, Pat, Rose, Grace.

Spawned subagents: none.

## Scope

Add genotype component diagnostics to `hs_data()` without adding genomic
fitting, marker scans, QTL/GWAS models, automatic genotype-model construction,
or bridge payload changes.

This slice supports future genomic and QTL workflows by making the current
genotype component shape visible to users and developers.

## Skills

Used:

- `hsquared-rehydrate`;
- `hsquared-team-dispatch`;
- `r-package-development`;
- `testing-r-packages`;
- `rose-pre-public-audit`;
- `after-task-audit`.

## Implementation

Added:

- `summary(hs_data(...))$genotype_status`;
- `data_status(...)$genotype_status`;
- print support for genotype-status diagnostics.

The genotype-status table reports:

- genotype rows;
- genotype IDs;
- genotype marker-column count;
- named genotype marker-column count;
- unnamed genotype marker-column count;
- duplicate named genotype marker-column count;
- missing genotype value count;
- genotype component type.

This slice also fixed duplicate-name handling in genotype and expression
feature helper paths by replacing `setdiff()` with order-preserving name
filtering.

## Validation

Local checks:

- `Rscript -e "devtools::document()" && air format . && Rscript -e "devtools::test(filter = 'hs-data')"`:
  documentation updated, formatting completed, `108 pass`, `0 fail`,
  `0 warnings`, `0 skips`.
- `Rscript -e "devtools::test()"`: `402 pass`, `0 fail`, `0 warnings`,
  `0 skips`; live Julia bridge activated sibling `HSquared.jl`.
- `Rscript -e "pkgdown::build_articles(lazy = FALSE); pkgdown::check_pkgdown()"`:
  articles rebuilt and `No problems found.`
- `Rscript -e "devtools::check()"`: first run had `0 errors`, `0 warnings`,
  `1 note`; the note was `unable to verify current time`.
- `Rscript -e "devtools::check()"`: rerun had `0 errors`, `0 warnings`,
  `0 notes`.
- `git diff --check`: clean.
- Overclaim scan:
  `rg -n "genotype.*model|genotype.*fit|genotype_status.*fit|genotype_status.*model|genomic.*implemented|marker.*implemented|QTL.*implemented|eQTL.*implemented|omics.*implemented|automatic.*genotype|automatic.*marker|GLLVM.*implemented|GPU.*implemented|supports genomic|supports QTL|supports eQTL|ASReml parity|speedup|fast|faster" README.md NEWS.md R man tests vignettes docs/design docs/dev-log _pkgdown.yml`.
  Hits were planned, blocked, negated, prior scan/report records, or the
  intended new `without fitting genomic, marker-scan, or QTL models` wording.

Remote checks:

- Pending until this slice is pushed.

## Rose Audit

Initial verdict: clean with limitations.

Allowed wording:

- `summary()` and `data_status()` report genotype rows, genotype IDs, marker
  columns, unnamed marker columns, duplicate marker columns, missing genotype
  value counts, and genotype component type.

Blocked wording:

- genomic models are fitted;
- marker scans, QTL, GWAS, or eQTL models are fitted;
- genotypes are parsed from PLINK/VCF or imputed;
- genotype data are automatically converted to relationship matrices or model
  terms;
- GLLVM or GPU workflows are implemented.

## Tests Of The Tests

The focused tests cover:

- matrix genotype inputs with marker column names;
- data-frame genotype inputs with an explicit ID column;
- unnamed genotype matrix columns;
- duplicate genotype marker columns;
- missing genotype values;
- duplicate-name preservation in status helper paths.

## Coordination Notes

R-only slice. No Julia payload or engine API change is required.

## Known Limitations

- `genotype_status` reports in-memory matrix or data-frame shape only.
- It does not parse PLINK/VCF, dosage, sparse, HDF5, Zarr, or file-backed
  genotype data.
- It does not impute genotypes, construct genomic relationships, or run marker
  scans.
- Genomic prediction, QTL/GWAS/eQTL scans, and single-step models remain
  planned.

## Next Work

1. Consider file-backed genotype source descriptors after the in-memory data
   contract stabilizes.
2. Mirror the diagnostics in `HSquared.jl` only when the Julia data lane is
   ready and not colliding with current HSData parity work.
