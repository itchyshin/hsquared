# Coef And Nobs Fit Methods

Date: 2026-06-13

Active lenses: Emmy, Pat, Rose, Grace

Spawned subagents: none

Current lane: R

## Goal

Add small standard R fit-object ergonomics for `hsquared_fit` objects without
changing the fitting boundary.

## Changed

- Added `coef.hsquared_fit()` as a fixed-effect alias.
- Added `nobs.hsquared_fit()` using `result$nobs`, with response-payload
  fallback when the explicit result field is absent.
- Imported the `stats::nobs` generic for clean namespace S3 registration.
- Added tests for ordinary extraction, fallback behavior, and missing metadata.
- Updated README, NEWS, model-status article, public claims register,
  capability status, check-log, and coordination board.

## Verification

- `Rscript -e "devtools::document()" && air format . && Rscript -e "devtools::test(filter = 'fit-object')"`:
  `58 pass`, `0 fail`, `0 warnings`, `0 skips`.
- `Rscript -e "devtools::test()"`: `412 pass`, `0 fail`, `0 warnings`,
  `0 skips`; live sibling `HSquared.jl` bridge activated.
- `Rscript -e "pkgdown::build_articles(lazy = FALSE); pkgdown::check_pkgdown()"`:
  articles rebuilt; `No problems found.`
- `Rscript -e "devtools::check()"`: initially failed because `nobs` was not
  imported for namespace S3 registration; fixed with `@importFrom stats nobs`.
- `Rscript -e "devtools::check()"` after the import fix: `0 errors`,
  `0 warnings`, `0 notes`.
- `git diff --check`: clean.
- GitHub Actions R-CMD-check `27465482460`: passed in 1m31s.
- GitHub Actions pkgdown `27465482452`: passed.
- GitHub Pages build/deploy `27465520405`: passed, with the existing upstream
  Node 20 deprecation annotation for Pages actions.

## Claim Boundary

This slice is S3 extractor ergonomics only. It does not add fitting,
variance-component estimation, production sparse reliability/PEV, Mrode fitted
validation, ASReml parity, or backend execution.

## Next Actions

1. Notify issue #5 with the namespace lesson and final CI evidence.
