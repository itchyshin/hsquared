# After-task - metafounder H^Gamma live bridge probe (2026-06-21)

## Goal

Activate the narrow R bridge for supplied-`Gamma` single-step `H^Gamma` after
the parser/payload gate, without claiming animal-only metafounder fitting,
`Gamma` estimation, extractor support, external comparator evidence, or covered
status.

## Scope

- Wired `engine_control = list(target = "metafounder_single_step")` to call the
  Julia-owned `fit_metafounder_single_step_reml()` path.
- Reused the existing single-step construction payload: normalized pedigree,
  markers, `genotyped_rows`, `group_of`, supplied `Gamma`, and construction
  knobs.
- Added skip-guarded live probes for:
  - `Gamma = 0` reduction to ordinary single-step construction;
  - nonzero-`Gamma` prediction sensitivity with stable labels and dimensions.
- Updated formula/status/docs ledgers and the genomic article to move from
  payload-only wording to experimental live-bridge wording.

## Files Changed

- `R/hsquared.R`
- `R/julia-bridge.R`
- `R/genomic-markers.R`
- `R/hs_control.R`
- `R/formula-status.R`
- `R/validation-status.R`
- `tests/testthat/test-single-step-construct.R`
- `tests/testthat/test-phase0-api.R`
- `NEWS.md`
- `vignettes/articles/genomic-prediction.Rmd`
- `docs/design/02-formula-grammar.md`
- `docs/design/06-public-claims-register.md`
- `docs/design/11-next-50-slices.md`
- `docs/design/19-on-main-bridge-gap.md`
- `docs/design/27-metafounder-single-step-contract.md`
- `docs/design/capability-status.md`
- `docs/design/validation-debt-register.md`
- `docs/dev-log/check-log.md`
- `docs/dev-log/coordination-board.md`
- `docs/dev-log/issue-map.md`
- `man/genomic_markers.Rd`
- `man/hs_control.Rd`

## Checks

- `air format .`
  - Passed.
- `Rscript --vanilla -e 'devtools::document()'`
  - Regenerated `man/genomic_markers.Rd` and `man/hs_control.Rd`.
- `HSQUARED_JULIA_PROJECT="/Users/z3437171/Dropbox/Github Local/HSquared.jl" NOT_CRAN=true Rscript --vanilla -e 'devtools::test(filter = "single-step-construct")'`
  - 92 passed, 0 failed, 0 warnings, 0 skipped.
- `Rscript --vanilla -e 'devtools::test(filter = "phase0-api|single-step-construct")'`
  - 159 passed, 0 failed, 0 warnings, 7 skipped.
- `Rscript --vanilla -e 'devtools::test()'`
  - 1247 passed, 0 failed, 0 warnings, 57 skipped.
- `Rscript --vanilla -e 'pkgdown::check_pkgdown()'`
  - Clean.
- `git diff --check`
  - Clean.
- `_R_CHECK_FORCE_SUGGESTS_=false Rscript --vanilla -e 'rcmdcheck::rcmdcheck(args = "--no-manual", error_on = "never")'`
  - Status OK, 0 errors, 0 warnings, 0 notes. Missing optional suggested
    packages `enhancer`, `nadiv`, and `pedigreemm` were INFO only.

## Findings

- JuliaCall collapses a 1x1 R matrix to a scalar. The bridge now sends `Gamma`
  as a numeric vector plus dimension and reconstructs the Julia matrix
  explicitly before calling the engine.
- The R `logLik()` extractor correctly refuses non-converged fits. The
  `Gamma = 0` bridge test therefore compares the raw engine payload
  `result$loglik` and convergence flags rather than forcing a user-facing
  extractor call.

## Rose Boundary

Allowed:

- R fits an opt-in, experimental, supplied-`Gamma` single-step `H^Gamma` bridge
  at dense validation scale.
- `Gamma` is supplied by the user and not estimated.
- The live R bridge has `Gamma = 0` reduction and nonzero-`Gamma` sensitivity
  probes.

Blocked:

- R fits animal-only metafounder models.
- `Gamma` is estimated.
- Metafounder-specific extractors exist.
- BLUPF90 or other external comparator evidence exists.
- `H^Gamma` support is covered, production-scale, or comparator-validated.

## Next

1. Finish full local gates and remote PR checks for this narrow bridge slice.
2. Pursue external comparator evidence if BLUPF90-family tooling becomes
   available.
3. Otherwise, consider the animal-only metafounder supplied-variance bridge as a
   separate contract-first slice.
