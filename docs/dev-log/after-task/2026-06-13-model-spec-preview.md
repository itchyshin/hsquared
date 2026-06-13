# After-Task Report: Model Specification Preview Helper

Date: 2026-06-13
Lane: R
Active lenses: Emmy, Hopper, Pat, Rose, Grace
Spawned subagents: none

## Slice

Added `model_spec()` as a user-facing preview helper for the v0.1 animal-model
contract. It validates the same formula path as `hsquared()`, builds the same
internal bridge payload, and reports the parsed response, family, method, fixed
columns, sparse animal-effect design dimensions, normalized pedigree ordering,
pedigree founder count, and Julia targets.

## Files Changed

- `R/model-spec-inspect.R`
- `tests/testthat/test-model-spec-inspect.R`
- `man/model_spec.Rd`
- `NAMESPACE`
- `README.md`
- `NEWS.md`
- `_pkgdown.yml`
- `vignettes/articles/model-status.Rmd`
- `docs/design/capability-status.md`
- `docs/design/06-public-claims-register.md`
- `docs/dev-log/check-log.md`
- `docs/dev-log/coordination-board.md`

## Verification

- `air format .`: completed.
- `Rscript -e "devtools::document()"`: completed.
- `Rscript -e "devtools::test(filter = 'model-spec-inspect')"`: 24 pass, 0 fail,
  0 warnings, 0 skips.
- `Rscript -e "devtools::test()"`: 219 pass, 0 fail, 0 warnings, 0 skips.
- `Rscript -e "pkgdown::check_pkgdown()"`: first run caught missing
  `_pkgdown.yml` reference entry for `model_spec`; second run passed after
  adding the topic.
- `Rscript -e "devtools::check()"`: 0 errors, 0 warnings, 0 notes.
- `git diff --check`: clean.

## Claim Boundary

`model_spec()` is a preview and diagnostics helper. It does not fit models,
does not execute Julia, and does not expand the supported formula grammar
beyond `animal(1 | id, pedigree = ped)`.

## Next Action

If this slice stays green in GitHub Actions, the next R-lane step should be a
small usability follow-up: either a printed bridge-payload diagnostic for
developers or a user-facing vignette example showing `model_spec()` beside
`hsquared(..., control = hs_control(engine = "julia"))` with the experimental
boundary explicit.
