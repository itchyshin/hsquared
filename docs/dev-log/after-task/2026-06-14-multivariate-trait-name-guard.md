# After-Task Report: Multivariate Trait-Name Guard

Date: 2026-06-14

## Task Goal

Harden the current opt-in multivariate `cbind()` parser so trait names are
unique and non-empty before fitting or marshalling to Julia.

## Active Lenses And Spawned Agents

- Active lenses: Ada, Shannon, Boole, Hopper, Curie, Rose, Grace.
- Spawned subagents: none.
- Current lane: R.

## Files Changed

- `R/model-spec.R`
- `tests/testthat/test-multivariate.R`
- `NEWS.md`
- `docs/design/17-trait-ordering-contract.md`
- `docs/dev-log/check-log.md`
- `docs/dev-log/coordination-board.md`
- `docs/dev-log/after-task/2026-06-14-multivariate-trait-name-guard.md`

## Implementation

- Added `hs_validate_multivariate_trait_names()`.
- Called it after `cbind()` trait names are resolved and before `Y` column names
  are assigned.
- Added tests for duplicate `cbind(y1, y1)` names and unrecoverable blank trait
  names.

## Checks Run

- `git diff --check` — passed.
- `command -v air` — no `air` binary on PATH.
- `/Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e "devtools::test(filter = 'multivariate')"` — passed, 0 failures / 0 warnings / 3 skips / 52 passes.
- `/Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e "devtools::test()"` — passed, 0 failures / 0 warnings / 32 skips / 610 passes.
- `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64 /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e "pkgdown::check_pkgdown()"` — passed, "No problems found."
- `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64 /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e "devtools::check(document = FALSE, args = '--no-manual')"` — passed, 0 errors / 0 warnings / 0 notes.
- Previous commit `bd53ebd` remote checks were green:
  - R-CMD-check `27505906421`
  - pkgdown `27505906424`
  - Pages `27505963691`

## Public Claim Audit

Clean with limitations. This is parser hardening for the current `cbind()`
multivariate path. It does not add long-data support, `traits(...)`, a
`trait_order` argument, wide-to-long equivalence, or comparator-validated trait
order.

## Tests Of The Tests

The focused test first caught an over-strict blank-name expectation. The final
tests now match intended behaviour: recoverable blank names from ordinary
`cbind()` evaluation can be repaired from formula symbols, while duplicate names
and unrecoverable blanks fail.

## Coordination Notes

No Julia files were edited. This strengthens the R-side trait-order contract
before future wide/long syntax work.

## What Did Not Go Smoothly

The first focused blank-name test expected `hs_build_response_spec()` to fail
even when formula symbols could repair missing evaluated names. The test was
adjusted to call the validator directly for the unrecoverable blank-name case.

## Known Limitations

- No live long-data multivariate parser.
- No `traits(...)` parser.
- No `trait_order` argument.
- No external comparator trait-order gate yet.

## Next Actions

- Commit and push this guard, then watch R-CMD-check and pkgdown.
- Apply the requested pkgdown sky-blue theme as a separate visual/docs slice.
