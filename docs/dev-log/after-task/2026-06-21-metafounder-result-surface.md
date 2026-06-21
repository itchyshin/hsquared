# After-task report: metafounder result-surface provenance extractors

Date: 2026-06-21

## Task goal

Finish the next R-lane bridge cleanup after the supplied-`Gamma` metafounder
bridges were banked: expose the fitted-object provenance users need to inspect
which `Gamma` matrix and ID-keyed metafounder groups were supplied, while
keeping metafounder effects, `Gamma` estimation, comparator evidence, and
coverage claims out of scope.

## Active lenses and spawned agents

- Active lenses: Ada, Shannon, Hopper, Emmy, Henderson, Pat, Rose, Grace.
- Spawned agents: none.
- Current lane: R result surface. Julia was used through the existing live
  bridge tests only; no `HSquared.jl` files were edited.

## Files changed

- `R/extractors.R`
- `NAMESPACE`
- `man/gamma_matrix.Rd`
- `man/metafounder_groups.Rd`
- `tests/testthat/test-fit-object.R`
- `tests/testthat/test-julia-bridge.R`
- `tests/testthat/test-single-step-construct.R`
- `_pkgdown.yml`
- `NEWS.md`
- `docs/design/06-public-claims-register.md`
- `docs/design/27-metafounder-single-step-contract.md`
- `docs/design/capability-status.md`
- `docs/design/validation-debt-register.md`
- `docs/dev-log/check-log.md`
- `docs/dev-log/coordination-board.md`

The two pre-existing untracked Codex handover files were left untouched.

## Checks run and outcomes

- `air format .` - passed.
- `Rscript --vanilla -e 'devtools::document()'` - passed; regenerated
  `NAMESPACE`, `man/gamma_matrix.Rd`, and `man/metafounder_groups.Rd`.
- `Rscript --vanilla -e 'devtools::test(filter = "fit-object|julia-bridge|single-step-construct|phase0-api")'`
  - 283 passed, 0 failed, 0 warnings, 16 skipped.
- `HSQUARED_JULIA_PROJECT="/Users/z3437171/Dropbox/Github Local/HSquared.jl" NOT_CRAN=true Rscript --vanilla -e 'devtools::test(filter = "julia-bridge|single-step-construct")'`
  - 208 passed, 0 failed, 0 warnings, 0 skipped.
- `Rscript --vanilla -e 'devtools::test()'`
  - 1272 passed, 0 failed, 0 warnings, 58 skipped.
- `Rscript --vanilla -e 'pkgdown::check_pkgdown()'` - clean after adding the
  two new exported topics to `_pkgdown.yml`.
- `git diff --check` - clean.
- `_R_CHECK_FORCE_SUGGESTS_=false Rscript --vanilla -e 'rcmdcheck::rcmdcheck(args = "--no-manual", error_on = "never")'`
  - Status OK, 0 errors, 0 warnings, 0 notes.
  - Optional suggested packages `enhancer`, `nadiv`, and `pedigreemm` were not
    available in the built-package sandbox and were INFO only.

## Public claim audit

Allowed claim: experimental metafounder and `H^Gamma` fits now expose supplied
`Gamma` and group-assignment provenance through `gamma_matrix()` and
`metafounder_groups()`.

Blocked claims:

- `Gamma` estimation.
- Metafounder-specific effect extraction (`metafounder_effects()`).
- BLUPF90, ASReml, DMU, WOMBAT, or equivalent same-estimand comparator evidence.
- Production-scale metafounder or `H^Gamma` support.
- Covered-status promotion.

## Tests of the tests

- Mock-object tests assert both new extractors return the exact supplied
  provenance and fail loudly when a fitted object lacks the needed fields.
- Live bridge tests assert `gamma_matrix()` and `metafounder_groups()` on the
  animal-only `metafounder` and constructed `H^Gamma` paths, using the sibling
  `HSquared.jl` checkout.
- A boundary-diagnostic regression test checks that a `metafounder` variance
  component is treated as a primary effect for the existing `at_boundary` row.

## Coordination notes

This closes the result-shape half of the immediate bridge cleanup. The
validation/comparator lane remains separate: MCMCglmm/JWAS agreement can add
useful evidence, but same-estimand REML parity still needs BLUPF90, ASReml, DMU,
WOMBAT, or another accepted REML comparator.

## What did not go smoothly

`pkgdown::check_pkgdown()` initially failed because the two new exported topics
were not listed in `_pkgdown.yml`. Adding them to the extractor contract
section fixed the issue and the rerun was clean.

## Known limitations

- `metafounder_groups()` reports supplied group labels; it does not infer or
  estimate metafounder membership.
- `gamma_matrix()` reports supplied `Gamma`; it is not an estimate and carries
  no standard error.
- No new engine capability, formula grammar, or validation status promotion was
  added.

## Next actions

1. Bank this branch as a narrow PR and watch remote R-CMD-check.
2. Start the external comparator-depth branch from refreshed `main`.
3. Keep same-estimand REML comparator blockers explicit until the toolchain is
   actually available.
