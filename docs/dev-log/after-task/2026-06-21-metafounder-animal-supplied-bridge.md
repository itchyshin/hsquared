# After-task report: animal-only supplied-Gamma metafounder bridge

Date: 2026-06-21

## Task goal

Activate the next narrow Candidate A R-lane bridge slice: animal-only
supplied-`Gamma` metafounder `A^Gamma` fitting through the Julia-owned
supplied-variance `metafounder_animal_model()` path, without changing validation
or coverage claims.

## Active lenses and spawned agents

- Active lenses: Ada, Shannon, Boole, Noether, Gauss, Hopper, Emmy, Henderson,
  Fisher, Curie, Rose, Grace.
- Spawned agents: none.
- Current lane: R. Julia lane was read/consumed only through the already merged
  engine contract and a coordination update about HSquared.jl PR #129.

## Files changed

- R parser/bridge/control/status:
  - `R/model-spec.R`
  - `R/bridge-payload.R`
  - `R/hsquared.R`
  - `R/julia-bridge.R`
  - `R/formula-status.R`
  - `R/qg-effects.R`
  - `R/hs_control.R`
  - `R/validation-status.R`
- Tests:
  - `tests/testthat/test-formula-animal.R`
  - `tests/testthat/test-bridge-payload.R`
  - `tests/testthat/test-julia-bridge.R`
  - `tests/testthat/test-phase0-api.R`
- Public/status docs:
  - `NEWS.md`
  - `docs/design/02-formula-grammar.md`
  - `docs/design/03-engine-contract.md`
  - `docs/design/06-public-claims-register.md`
  - `docs/design/11-next-50-slices.md`
  - `docs/design/19-on-main-bridge-gap.md`
  - `docs/design/27-metafounder-single-step-contract.md`
  - `docs/design/capability-status.md`
  - `docs/design/validation-debt-register.md`
  - `docs/dev-log/check-log.md`
  - `docs/dev-log/coordination-board.md`
  - `docs/dev-log/issue-map.md`
  - `vignettes/articles/genomic-prediction.Rmd`
  - `man/hs_control.Rd`
  - `man/qg_effect_markers.Rd`

The pre-existing untracked handover files were left untouched.

## Checks run and outcomes

- `air format .` - passed.
- `Rscript --vanilla -e 'devtools::document()'` - passed; regenerated
  `man/hs_control.Rd` and `man/qg_effect_markers.Rd`.
- `Rscript --vanilla -e 'devtools::test(filter = "formula-animal|phase0-api|bridge-payload|julia-bridge")'`
  - 229 passed, 0 failed, 0 warnings, 9 skipped.
- `HSQUARED_JULIA_PROJECT="/Users/z3437171/Dropbox/Github Local/HSquared.jl" NOT_CRAN=true Rscript --vanilla -e 'devtools::test(filter = "julia-bridge")'`
  - 109 passed, 0 failed, 0 warnings, 0 skipped.
- `Rscript --vanilla -e 'devtools::test()'`
  - 1265 passed, 0 failed, 0 warnings, 58 skipped.
- `Rscript --vanilla -e 'pkgdown::check_pkgdown()'` - clean.
- `git diff --check` - clean.
- `_R_CHECK_FORCE_SUGGESTS_=false Rscript --vanilla -e 'rcmdcheck::rcmdcheck(args = "--no-manual", error_on = "never")'`
  - Status OK, 0 errors, 0 warnings, 0 notes.
  - Optional suggested packages `enhancer`, `nadiv`, and `pedigreemm` were not
    available and were reported as INFO only.

## Public claim audit

Allowed claim: R now fits an experimental, opt-in, dense validation-scale,
animal-only supplied-variance metafounder `A^Gamma` bridge through
`target = "metafounder"`.

Blocked claims:

- `Gamma` estimation.
- Animal-only metafounder variance-component estimation.
- Metafounder-specific extractor support.
- BLUPF90-family or same-estimand external comparator evidence.
- Production-scale metafounder support.
- Covered-status promotion.

## Tests of the tests

- Pure parser tests check required `group`/`Gamma`, normalized pedigree
  alignment, supplied PSD `Gamma`, and explicit formula/status rows.
- Payload tests check `group_of`, `Gamma`, `gamma_labels`, relationship source,
  and Julia target metadata.
- Live Julia bridge tests compare `Gamma = 0` animal-only metafounder output
  against ordinary Henderson MME supplied-variance output and verify nonzero
  `Gamma` changes predictions while labels and dimensions remain stable.
- Missing supplied variance components are checked before Julia availability so
  local validation errors remain testable without a live bridge.

## Coordination notes

Julia PR #129 records a JWAS Bayesian/MCMC agreement probe, not same-estimand
REML parity and not a covered-status promotion. BLUPF90-family executables remain
absent on the Julia host, so the true second-comparator lane is still blocked
unless another host/toolchain supplies it.

## What did not go smoothly

- The first implementation surfaced a stale test expectation for missing
  variance components and the validator still said `target = "henderson_mme"`.
  The validator now accepts a target label and the metafounder bridge validates
  supplied variances before probing Julia availability.
- Several public ledgers still described animal-only metafounder as future-only.
  These were updated while keeping the partial/experimental boundary.

## Known limitations

- Animal-only `metafounder()` requires supplied `sigma_a2` and `sigma_e2`; it is
  not an REML estimation path.
- `Gamma` is supplied and validated, not estimated.
- No metafounder-specific extractor exists yet.
- No BLUPF90-family comparator run or same-estimand external comparator evidence
  exists for this R slice.
- Dense validation-scale only.

## Next actions

1. Bank this R slice as a narrow PR and watch remote R-CMD-check.
2. Keep comparator evidence separate: Julia #129 is useful agreement evidence,
   but not same-estimand REML parity.
3. From clean main, choose between an external validation/comparator leg,
   metafounder result-shape/extractor contract, or structured covariance bridge
   activation.
