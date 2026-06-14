# After-Task Report: Structured Covariance Formula Vocabulary

Date: 2026-06-14

## Task Goal

Reserve the full planned long-format structured covariance vocabulary in the R
status/error surface without making it executable or promoting any validation
claim.

## Active Lenses And Spawned Agents

- Active lenses: Ada, Shannon, Jason, Boole, Noether, Kirkpatrick, Hopper,
  Rose, Pat, Grace.
- Spawned subagents: none.
- Current lane: R/coordinator.

## Files Changed

- `NEWS.md`
- `R/formula-status.R`
- `R/model-spec.R`
- `docs/design/01-v0.1-contract.md`
- `docs/design/02-formula-grammar.md`
- `docs/design/06-public-claims-register.md`
- `docs/design/11-next-50-slices.md`
- `docs/design/capability-status.md`
- `docs/design/validation-debt-register.md`
- `docs/dev-log/check-log.md`
- `docs/dev-log/coordination-board.md`
- `docs/dev-log/scout/2026-06-14-structured-covariance-formula-vocabulary-scout.md`
- `tests/testthat/test-formula-animal.R`
- `tests/testthat/test-phase0-api.R`
- `vignettes/articles/formula-grammar.Rmd`

## Implementation

- Added separate planned `formula_status()` rows for:
  - `animal(trait | id, pedigree = ped, cov = us())`;
  - `animal(trait | id, pedigree = ped, cov = diag())`;
  - `animal(trait | id, pedigree = ped, cov = lowrank(K = 2))`;
  - `animal(trait | id, pedigree = ped, cov = fa(K = 2))`.
- Updated the planned `animal(..., cov = ...)` parser error so it names all four
  reserved covariance forms and points users to the current opt-in `cbind()`
  multivariate path.
- Corrected stale formula-contract prose that still described the project as
  pre-fit and still grouped genomic/multivariate surfaces as merely planned.
- Updated claims/status/debt rows to keep the structured covariance vocabulary
  partial/planned and diagnostic-only.
- Recorded a Jason scout note from local `HSquared.jl` and `gllvmTMB` patterns.

## Checks Run

- `command -v air || true` - no `air` binary on PATH.
- `/Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e "devtools::test(filter = 'phase0-api|formula-animal')"` - passed, 0 failures / 0 warnings / 0 skips / 119 passes.
- `/Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e "devtools::test()"` - passed, 0 failures / 0 warnings / 32 skips / 622 passes.
- `/Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e 'devtools::load_all(quiet = TRUE); s <- formula_status(); stopifnot(nrow(s) == 24L); ss <- s[s$category == "multivariate and factor analytic", c("term", "syntax_status", "fitting_status")]; print(ss)'` - passed and printed the parsed `cbind()` row plus planned `us`, `diag`, `lowrank`, and `fa` rows.
- `git diff --check` - passed.
- `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64 /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e "pkgdown::check_pkgdown()"` - passed, "No problems found."
- `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64 /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e "devtools::check(document = FALSE, args = '--no-manual')"` - passed, 0 errors / 0 warnings / 0 notes.

## Public Claim Audit

Clean. This slice does not implement `cov = us()`, `cov = diag()`,
`cov = lowrank(K)`, or `cov = fa(K)` formula grammar. It only makes the planned
vocabulary visible and honest in `formula_status()`, errors, and design memory.

## Tests Of The Tests

- The `phase0-api` test now fails if the four structured covariance status rows
  are missing or stop being marked `planned`.
- The `phase0-api` test now also checks that a column subset of
  `formula_status()` prints cleanly; this caught and fixed a real status-table
  print bug during closeout.
- The `formula-animal` test now checks that a planned `cov = lowrank(K = 2)`
  request reaches the explicit planned-error text instead of being silently
  swallowed.

## Coordination Notes

No Julia files were edited. The Julia twin still owns structured covariance
recovery and engine hardening; this R slice only prepares the vocabulary and
claim boundary.

## What Did Not Go Smoothly

The first pass exposed stale design text in `02-formula-grammar.md` and
`01-v0.1-contract.md` from before the default-fit and opt-in target flips. A
final sanity command also found that printing a column subset of
`formula_status()` could fail because the class-specific print method assumed
all display columns were present. Both issues were corrected while the formula
contract was already under review.

## Known Limitations

- No covariance helper functions are exported yet.
- Long-format `animal(trait | id, cov = ...)` grammar remains rejected.
- The current live multivariate R bridge remains the opt-in `cbind()` path with
  unstructured `G0`/`R0`.

## Next Actions

- Push and watch R-CMD-check, pkgdown, and Pages.
- Keep R-side structured covariance formula grammar blocked until Julia
  structured covariance is on `main`, recovery evidence is recorded, and R bridge
  tests cover result metadata.
