# Tiny Ainv Validation Fixture

Date: 2026-06-13

Active lenses: Curie, Fisher, Gauss, Jason, Rose, Grace.

Spawned subagents: none.

## Scope

Add the first tiny deterministic validation fixture for the v0.1 animal-model
contract. This is a bridge and sparse-Ainv validation atom, not a public model
fitting claim.

## Scout

Read local sibling patterns before editing:

- `drmTMB` known-relatedness and Julia-bridge tests;
- `gllvmTMB` sparse pedigree `Ainv` tests and validation ledgers;
- `gllvmTMB` cross-package validation article and Gaussian REML pilot report.

Checked public sources for the longer validation ladder:

- Henderson direct inverse rules;
- Mrode animal-model text catalogue entry;
- AGHmatrix tutorial and paper;
- nadiv reference manual.

Persistent scout note:

- `docs/dev-log/scout/2026-06-13-validation-fixtures.md`

## Implementation

Added:

- `hs_tiny_animal_validation_fixture()`;
- `tests/testthat/test-validation-fixtures.R`.

The fixture pins:

- out-of-order input pedigree;
- normalized IDs `sire`, `dam`, `calf`;
- parent indices `0, 0, 1` and `0, 0, 2`;
- sparse random-effect design `Z`;
- expected three-animal `Ainv`.

The live test asks the sibling Julia checkout to compute
`HSquared.pedigree_inverse()` from the R payload parent slots and compares the
result with the expected `Ainv`.

## Validation

Local checks:

- `air format .`: completed.
- `Rscript -e "devtools::test(filter = 'validation-fixtures')"`: `8 pass`,
  `0 fail`, `0 warnings`, `0 skips`; live fixture activated sibling
  `HSquared.jl`.
- `Rscript -e "devtools::test()"`: `124 pass`, `0 fail`, `0 warnings`,
  `0 skips`; live bridge activated sibling `HSquared.jl`.
- `git diff --check`: clean.
- `Rscript -e "pkgdown::check_pkgdown()"`: `No problems found.`
- `Rscript -e "devtools::check()"`: `0 errors | 0 warnings | 0 notes`.

Remote checks:

- Commit: `c161a7f Add tiny Ainv validation fixture`.
- GitHub Actions R-CMD-check `27457494019`: passed.
- GitHub Actions pkgdown `27457494023`: passed.
- GitHub Pages build/deploy `27457528612`: passed.

## Rose Audit

Verdict: clean with limitations.

Allowed wording:

- tiny deterministic Ainv validation fixture;
- R payload ordering reproduces expected Julia `Ainv` for a three-animal
  fixture when the local Julia bridge is available;
- first validation atom for issue #7.

Blocked wording:

- Mrode validation is covered;
- ASReml, BLUPF90, DMU, or WOMBAT comparison is covered;
- production sparse fitting is validated;
- large pedigree support is validated;
- genomic or single-step validation exists.

## Next Work

1. Ask the Julia twin to mirror the fixture name and expected `Ainv` in
   `HSquared.jl` docs/tests if not already explicit.
2. Add a true Mrode-style fixture with recorded source, estimand, and expected
   outputs.
3. Add comparator policy rows for ASReml/BLUPF90/DMU/WOMBAT before claiming
   broad parity.
