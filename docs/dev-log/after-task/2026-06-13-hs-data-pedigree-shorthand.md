# After-Task Report: hs_data Pedigree Shorthand

Date: 2026-06-13
Lane: R
Active lenses: Ada, Shannon, Boole, Noether, Emmy, Hopper, Grace, Rose, Pat
Spawned subagents: none

## Slice

Added a small formula-ergonomics improvement: `animal(1 | id)` now uses the
pedigree stored in `data = hs_data(..., pedigree = ped)`. The canonical
portable spelling `animal(1 | id, pedigree = ped)` remains supported and
documented.

## Files Changed

- `R/model-spec.R`
- `R/model-spec-inspect.R`
- `R/hsquared.R`
- `R/animal.R`
- `R/formula-status.R`
- `tests/testthat/test-formula-animal.R`
- `tests/testthat/test-model-spec-inspect.R`
- `tests/testthat/test-phase0-api.R`
- `man/animal.Rd`
- `man/hsquared.Rd`
- `man/model_spec.Rd`
- `README.md`
- `NEWS.md`
- `vignettes/hsquared.Rmd`
- `vignettes/articles/formula-grammar.Rmd`
- `vignettes/articles/model-status.Rmd`
- `docs/design/01-v0.1-contract.md`
- `docs/design/02-formula-grammar.md`
- `docs/design/capability-status.md`
- `docs/design/06-public-claims-register.md`
- `docs/design/validation-debt-register.md`
- `docs/dev-log/check-log.md`
- `docs/dev-log/coordination-board.md`
- `docs/dev-log/scout/2026-06-13-hs-data-pedigree-shorthand-scout.md`

## Verification

- `Rscript -e "devtools::test(filter = 'formula-animal|model-spec-inspect|phase0-api')"`:
  122 pass, 0 fail, 0 warnings, 0 skips.
- `Rscript -e "devtools::document()"`: completed; wrote `animal.Rd`,
  `hsquared.Rd`, and `model_spec.Rd`.
- `air format .`: completed.
- `Rscript -e "devtools::test()"`: 276 pass, 0 fail, 0 warnings, 0 skips.
- `git diff --check`: passed with no output.
- `Rscript -e "pkgdown::build_articles(lazy = FALSE); pkgdown::check_pkgdown()"`:
  articles rebuilt and no pkgdown problems found.
- `Rscript -e "devtools::check()"`: 0 errors, 0 warnings, 0 notes.
- Remote GitHub checks for commit `74eef82`:
  - R-CMD-check `27461541666`: passed in 1m36s.
  - pkgdown `27461541639`: passed in 1m41s.
  - Pages `27461576199`: passed in 22s.

## Claim Boundary

This is parser/data-container ergonomics only. It does not add new fitted
animal-model support, R-side Ainv construction, production sparse reliability,
genomic fitting, QTL/eQTL fitting, or GPU execution.

## Tests Of Tests

The focused tests cover three paths: explicit `pedigree = ped`, bundle-default
`animal(1 | id)`, and clear errors for missing pedigree sources in plain data
frames or pedigree-free `hs_data()` bundles. Full package tests also exercised
the live Julia bridge against the sibling `HSquared.jl` checkout.

## Coordination Notes

The Julia twin was notified before this slice started. The change is R-only and
does not require a Julia engine API change. Julia parity docs should treat
`animal(1 | id, pedigree = ped)` as the canonical contract and the `hs_data()`
omission as an R-side convenience.

## What Did Not Go Smoothly

Two guessed test filenames from memory were stale. Live `rg --files` corrected
the test map before edits.

## Known Limitations

The shorthand works only when an `hs_data()` bundle contains a pedigree
component. It does not infer pedigrees from global variables, genotype data,
marker maps, or future relationship-matrix components.

## Next Actions

Update issues #4 and #8, send the Julia twin a closeout note, and continue the
next Phase 1 slice without changing the Julia engine API from the R lane.
