# After-Task Report: hs_data Genotype-Marker Alignment

Date: 2026-06-13
Lane: R
Active lenses: Emmy, Jason, Pat, Rose
Spawned subagents: none

## Slice

Added exact marker-ID alignment checks when `hs_data()` receives both
`genotypes` and `markers`. Genotype marker column names must match marker-map
IDs exactly, though the order can differ. The internal object now records a
private `hs_genotype_marker_spec` with marker IDs and marker-map indices.

## Files Changed

- `R/hs_data.R`
- `tests/testthat/test-hs-data.R`
- `man/hs_data.Rd`
- `README.md`
- `NEWS.md`
- `vignettes/articles/model-status.Rmd`
- `docs/design/capability-status.md`
- `docs/design/06-public-claims-register.md`
- `docs/design/validation-debt-register.md`
- `docs/dev-log/check-log.md`
- `docs/dev-log/coordination-board.md`
- `docs/dev-log/scout/2026-06-13-marker-map-validation-scout.md`

## Verification

- `air format .`: completed.
- `Rscript -e "devtools::document()"`: completed.
- `Rscript -e "devtools::test(filter = 'hs-data')"`: 34 pass, 0 fail,
  0 warnings, 0 skips.
- `Rscript -e "devtools::test()"`: 242 pass, 0 fail, 0 warnings, 0 skips.
- `Rscript -e "pkgdown::check_pkgdown()"`: no problems found.
- `Rscript -e "devtools::check()"`: 0 errors, 0 warnings, 0 notes.

## Claim Boundary

This is genotype-marker metadata alignment only. It does not parse genotype
file formats, impute genotypes, construct genomic relationship matrices, scan
markers, or fit genomic/QTL/eQTL models.

## Next Action

A useful next data slice is to expose a tiny user-facing `data_status()` or
`summary_hs_data` print refinement that makes genotype-marker alignment visible
without exposing internal specs.
