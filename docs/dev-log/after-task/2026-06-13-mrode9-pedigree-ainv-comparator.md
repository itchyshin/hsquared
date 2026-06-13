# Mrode9 Pedigree Ainv Comparator

Date: 2026-06-13

Active lenses: Curie, Fisher, Gauss, Jason, Rose, Grace.

Spawned subagents: none.

## Scope

Add an optional Mrode-sourced pedigree `Ainv` comparator for the validation
canon. This verifies pedigree inverse agreement only. It does not validate a
full fitted animal model, REML estimands, EBVs, heritability, or comparator
software parity.

## Source

The fixture uses `nadiv::Mrode9`, documented by `nadiv` as a pedigree adapted
from example 9.1 of Mrode (2005), *Linear Models for the Prediction of Animal
Breeding Values*.

## Implementation

Added:

- optional `nadiv` entry in `Suggests`;
- `hs_mrode9_pedigree_validation_fixture()`;
- `tests/testthat/test-mrode-validation.R`.

The test loads `nadiv::Mrode9`, computes `nadiv::makeAinv()`, aligns matrix
names, then asks the sibling Julia checkout to compute
`HSquared.pedigree_inverse()` from the same pedigree. The two `Ainv` matrices
are compared to numerical tolerance.

## Validation

Local checks:

- `air format . && Rscript -e "devtools::test(filter = 'mrode-validation')"`:
  `8 pass`, `0 fail`, `0 warnings`, `0 skips`; live comparator activated
  sibling `HSquared.jl`.
- `air format . && Rscript -e "devtools::test()"`: `132 pass`, `0 fail`,
  `0 warnings`, `0 skips`; live bridge activated sibling `HSquared.jl`.
- `git diff --check`: clean.
- `Rscript -e "pkgdown::check_pkgdown()"`: `No problems found.`
- `Rscript -e "devtools::check()"`: `0 errors | 0 warnings | 0 notes`.

## Rose Audit

Verdict: clean with limitations.

Allowed wording:

- optional Mrode9/nadiv pedigree-Ainv comparator;
- Julia `pedigree_inverse()` matches `nadiv::makeAinv()` for `nadiv::Mrode9`
  when optional dependencies are available.

Blocked wording:

- fitted Mrode animal-model validation is covered;
- Mrode EBV, h2, REML, or variance-component outputs are validated;
- ASReml, BLUPF90, DMU, or WOMBAT comparison is covered;
- production sparse fitting or large-pedigree readiness is validated.

## Next Work

1. Extend the Mrode lane from pedigree `Ainv` to a fitted model with recorded
   response, fixed effects, estimator target, expected variance components,
   EBVs, and h2.
2. Decide whether Mrode fixtures live in hsquared core tests or a future
   validation-data extension once fitted outputs become larger.
