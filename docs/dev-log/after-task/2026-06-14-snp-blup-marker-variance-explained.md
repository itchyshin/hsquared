# After-Task Report: SNP-BLUP Marker Variance Explained

Date: 2026-06-14

## Task Goal

Make `marker_variance_explained()` return useful output for real opt-in
SNP-BLUP/RR-BLUP fits, while keeping marker scanning, QTL, GWAS, and eQTL
claims blocked.

## Active Lenses And Spawned Agents

- Active lenses: Ada, Shannon, Jason, Hopper, Falconer, Pat, Rose, Grace.
- Spawned subagents: none.
- Current lane: R.

## Files Changed

- `R/julia-bridge.R`
- `R/extractors.R`
- `tests/testthat/test-snp-blup.R`
- `tests/testthat/test-fit-object.R`
- `man/marker_extractors.Rd`
- `NEWS.md`
- `vignettes/articles/fitting-models.Rmd`
- `vignettes/articles/genomic-prediction.Rmd`
- `vignettes/articles/model-status.Rmd`
- `vignettes/articles/qtl-gwas-eqtl-status.Rmd`
- `docs/design/06-public-claims-register.md`
- `docs/design/11-next-50-slices.md`
- `docs/design/capability-status.md`
- `docs/design/validation-debt-register.md`
- `docs/dev-log/scout/2026-06-14-snp-blup-marker-variance-explained-scout.md`
- `docs/dev-log/check-log.md`
- `docs/dev-log/coordination-board.md`
- `docs/dev-log/after-task/2026-06-14-snp-blup-marker-variance-explained.md`

## Implementation

- Requested the marker allele-frequency vector `p` from the Julia SNP-BLUP
  result.
- Added `hs_marker_variance_explained_from_snp_blup()`, which computes a
  descriptive fitted-marker contribution table:
  `effect^2 * centered_marker_variance`, normalized across fitted markers.
- Populated `marker_variance_explained` during SNP-BLUP result normalization.
- Added a fallback in `marker_variance_explained.hsquared_fit()` for older
  SNP-BLUP-shaped fit objects containing marker effects and stored marker
  payloads.
- Updated docs and status registers to say this extractor is live only for the
  opt-in supplied-variance SNP-BLUP path.

## Checks Run

- `command -v air || true` - no `air` binary on PATH.
- `/Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e "devtools::document()"` - passed.
- `/Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e "devtools::test(filter = 'snp-blup|fit-object')"` - passed, 0 failures / 0 warnings / 1 skip / 100 passes.
- `/Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e "devtools::test()"` - passed, 0 failures / 0 warnings / 32 skips / 632 passes.
- `git diff --check` - passed before closeout.
- `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64 /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e "pkgdown::check_pkgdown()"` - passed, "No problems found."
- `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64 /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e "devtools::check(document = FALSE, args = '--no-manual')"` - passed, 0 errors / 0 warnings / 0 notes.

## Public Claim Audit

Clean with boundaries. The allowed claim is that
`marker_variance_explained()` reports descriptive fitted-marker shares for
opt-in supplied-variance SNP-BLUP. It does not identify QTL, compute GWAS
p-values, compute LOD scores, fine-map variants, or provide a causal
variance-decomposition under linkage disequilibrium.

## Tests Of The Tests

- The normalizer test checks marker labels, returned effects, allele
  frequencies, contribution algebra, proportions summing to one, and a constant
  marker receiving zero contribution.
- The live SNP-BLUP test is skip-guarded and checks that fitted SNP-BLUP
  objects expose finite nonnegative marker contributions with proportions
  summing to one.
- Fit-object tests still verify that the extractor errors when no result field
  or SNP-BLUP payload is present.

## Coordination Notes

No Julia files were edited. The R lane only consumes the Julia-owned
`fit_snp_blup()` result shape and stores a descriptive R-side summary.

The maintainer's sky-blue theme note was verified during rehydration: the live
site already serves `extra.css` with `.navbar` pinned to `#0ea5e9`, so this
feature commit does not touch the visual theme.

## What Did Not Go Smoothly

`devtools::document()` attempted unrelated roxygen metadata churn; that was
trimmed before closeout so the generated documentation change stays focused on
`marker_extractors`.

## Known Limitations

- The extractor is descriptive for fitted SNP-BLUP marker effects only.
- The current SNP-BLUP path uses supplied variance components and does not
  estimate marker variance by REML.
- Correlated markers mean per-marker shares are not independent causal shares.
- Marker-scan, QTL, GWAS, eQTL, LOCO, p-values, LOD scores, and scan plots
  remain future work.

## Next Actions

- Commit and push.
- Watch R-CMD-check, pkgdown, and Pages.
- Continue with the next R-safe genomic/QTL slice after remote checks are
  green.
