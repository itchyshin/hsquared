# R Fitted Object And Extractor Contract

## Task Goal

Advance issue #5 by defining the first `hsquared_fit` object and extractor
contract, without claiming that `hsquared()` can fit animal models yet.

## Active Lenses And Spawned Agents

- Active lenses: Emmy, Pat, Fisher, Rose, Grace, Ada, Shannon.
- Spawned subagents: none.
- Current lane: R.

## Files Created Or Changed

- Added `R/fit-object.R`.
- Added `R/extractors.R`.
- Added `tests/testthat/test-fit-object.R`.
- Regenerated `NAMESPACE` and extractor Rd topics.
- Updated `_pkgdown.yml`, README, NEWS, vignettes, design docs,
  capability/claim/status registers, coordination board, and check log.

## Checks Run And Exact Outcomes

- `Rscript -e "devtools::document()"`: completed; namespace and extractor Rd
  topics regenerated.
- `git diff --check`: clean.
- `Rscript -e "devtools::test()"`: passed with `65 pass`, `0 fail`.
- First `Rscript -e "pkgdown::check_pkgdown()"`: failed because new extractor
  topics were missing from the pkgdown reference index.
- Final `Rscript -e "pkgdown::check_pkgdown()"`: `No problems found.`
- First `Rscript -e "devtools::check()"`: completed with `1 note` from an
  unqualified `logLik()` call in `AIC.hsquared_fit()`.
- Final `Rscript -e "devtools::check()"`: passed with `0 errors`,
  `0 warnings`, `0 notes`.

## Public Claim Audit

Public wording says the extractor contract exists for internal/future
`hsquared_fit` objects. It does not say that users can fit models, obtain
variance components, estimate heritability, or compute EBVs from real data yet.

## Tests Of The Tests

Tests construct a mocked internal `hsquared_fit` object and confirm that each
extractor returns the matching result field. Default-method tests confirm that
ordinary objects error instead of implying fitted-model support. Missing-field
tests confirm that incomplete fit objects fail loudly.

## Coordination Notes

The Julia result object should aim to provide fields compatible with the R
contract:

```text
variance_components
heritability
breeding_values
fixed_effects
random_effects
loglik
df
nobs
predictions
diagnostics
converged
```

## What Did Not Go Smoothly

Pkgdown correctly blocked new exported topics until they were indexed. R CMD
check also caught the unqualified `logLik()` call in `AIC.hsquared_fit()`.

## Known Limitations

- `hs_new_fit()` is internal.
- Extractor methods are tested only with mocked result fields.
- `hsquared()` still stops before Julia execution and returns no fit.
- No variance-component, EBV, heritability, or prediction computation exists.

## Next Actions

1. Push the extractor-contract commit and watch CI.
2. Update issue #5 with evidence.
3. Ask the Julia twin to align its result object fields with this R contract.
