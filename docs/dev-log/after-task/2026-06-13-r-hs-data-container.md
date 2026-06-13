# R hs_data Container

## Task Goal

Advance issue #8 by adding a minimal R-side data container for phenotype,
pedigree, genotype, marker, expression, annotation, and environment inputs.

## Active Lenses And Spawned Agents

- Active lenses: Emmy, Jason, Darwin, Pat, Rose, Grace, Ada, Shannon.
- Spawned subagents: none.
- Current lane: R.

## Files Created Or Changed

- Added `R/hs_data.R`.
- Added `tests/testthat/test-hs-data.R`.
- Regenerated `NAMESPACE` and `man/hs_data.Rd`.
- Updated `_pkgdown.yml`, README, NEWS, vignettes, claim/status registers,
  coordination board, and check log.

## Checks Run And Exact Outcomes

- `Rscript -e "devtools::document()"`: completed; `hs_data()` Rd generated.
- `git diff --check`: clean.
- `Rscript -e "devtools::test()"`: passed with `81 pass`, `0 fail`.
- `Rscript -e "pkgdown::check_pkgdown()"`: `No problems found.`
- `Rscript -e "devtools::check()"`: passed with `0 errors`, `0 warnings`,
  `0 notes`.

## Public Claim Audit

Public wording says `hs_data()` is a lightweight container and ID-map helper.
It does not claim file-backed storage, marker parsing, QTL/eQTL scans, genomic
relationship construction, or model fitting.

## Tests Of The Tests

Tests verify phenotype ID validation, pedigree coverage for phenotyped
individuals, genotype row-name ID mapping, expression ID-column mapping,
phenotype/genotype mismatch bookkeeping, default-row-name rejection, and
unsupported component-shape errors.

## Coordination Notes

This gives future R and Julia lanes a shared data vocabulary before large-file
and genomics work begins. It is intentionally not wired into `hsquared()` yet.

## What Did Not Go Smoothly

Data frames have automatic row names, so `hs_data()` now treats row names as
IDs only when they are explicit. A test locks that down.

## Known Limitations

- No PLINK, VCF, Arrow, Parquet, HDF5, Zarr, or file-backed storage support.
- No marker-map validation beyond data-frame shape.
- No genotype imputation or relationship-matrix construction.
- No integration with model fitting yet.

## Next Actions

1. Push the `hs_data()` commit and watch CI.
2. Update issue #8 with evidence and move it to partial.
3. Later: add file-backed readers and ID reconciliation for genomic/QTL lanes.
