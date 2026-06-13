# R PEV And Reliability Extractors

Date: 2026-06-13

Active lenses: Fisher, Pat, Emmy, Hopper, Rose, Grace.

Spawned subagents: none.

## Scope

Add R-side extractor contract support for prediction error variances and
reliability after the Julia twin added dense experimental low-level extractors.

This slice does not claim that the current live R-to-Julia bridge payload
returns PEV or reliability. It prepares the R object contract for those fields.

## Implementation

Added:

- `prediction_error_variance()`
- `prediction_error_variance.hsquared_fit()`
- `reliability()`
- `reliability.hsquared_fit()`

Updated:

- future-compatible Julia result normalization if `result_payload()` later
  includes `prediction_error_variance` or `reliability`;
- fit-object tests over mocked result fields;
- live bridge test to confirm reliability is absent from the current payload;
- pkgdown reference index;
- status, claim, validation, README, NEWS, and model-status docs.

## Validation

Local checks:

- `air format .`: completed.
- `Rscript -e "devtools::document()"`: regenerated `NAMESPACE` and Rd topics.
- `Rscript -e "devtools::test()"`: `111 pass`, `0 fail`, `0 warnings`,
  `0 skips`.
- `git diff --check`: clean.
- `Rscript -e "pkgdown::check_pkgdown()"`: `No problems found.`
- `Rscript -e "devtools::check()"`: `0 errors | 0 warnings | 0 notes`.

## Rose Audit

Verdict: clean with limitations.

Allowed wording:

- R fitted-object extractor contract includes PEV and reliability;
- mocked `hsquared_fit` tests cover those fields;
- live bridge can normalize those fields if Julia adds them later.

Blocked wording:

- current live bridge returns PEV or reliability;
- production sparse PEV/reliability exists;
- reliability has Mrode or external comparator validation;
- accuracy/reliability is ready for applied breeding decisions.

## Next Work

1. Ask the Julia lane to add PEV/reliability to `result_payload()` only when
   the bridge contract is updated and tested on both sides.
2. Add Mrode or tiny canonical validation for PEV/reliability.
3. Decide whether `accuracy()` should be a separate extractor or derived from
   `sqrt(reliability)`.
