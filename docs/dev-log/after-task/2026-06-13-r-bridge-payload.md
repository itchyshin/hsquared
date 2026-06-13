# R Bridge Payload Slice

## Task Goal

Advance issue #6 by turning the parsed v0.1 animal-model specification into a
tested internal R-to-Julia payload shape without claiming live Julia execution.

## Active Lenses And Spawned Agents

- Active lenses: Ada, Shannon, Hopper, Lovelace, Emmy, Grace, Rose, Curie.
- Spawned subagents: none.
- Current lane: R.

## Files Created Or Changed

- Added `R/bridge-payload.R`.
- Updated `R/model-spec.R` to preserve observed animal IDs, normalize pedigree
  order, detect pedigree cycles, and record parent indices.
- Updated `R/hsquared.R` to build the payload and report the current Julia
  `animal_model_spec()` target.
- Added `tests/testthat/test-bridge-payload.R`.
- Hardened `tests/testthat/test-formula-animal.R` by replacing brittle
  snapshots with direct error assertions.
- Updated README, NEWS, vignettes, design docs, claim/status registers, the
  coordination board, and this dev-log evidence.

## Checks Run And Exact Outcomes

- `Rscript -e "devtools::document()"`: completed; package Rd regenerated.
- `Rscript -e "devtools::test()"`: passed with `49 pass`, `0 fail`.
- `git diff --check`: clean.
- `Rscript -e "pkgdown::check_pkgdown()"`: `No problems found.`
- First `Rscript -e "devtools::check()"`: failed because an ordinary
  testthat snapshot differed in built-package context.
- Final `Rscript -e "devtools::check()"`: passed with `0 errors`,
  `0 warnings`, `0 notes`.

## Public Claim Audit

Public wording says the R package now builds an internal bridge payload. It
does not say that `hsquared()` executes Julia, constructs `Ainv`, estimates
variance components, returns EBVs, or fits animal models.

## Tests Of The Tests

The new bridge tests assert the actual payload shape: `y`, `X`, sparse `Z`,
normalized pedigree IDs, parent indices, observed ID mapping, method/family
fields, and Julia target metadata. A deliberately unsorted pedigree test checks
parent-before-offspring normalization. A two-node cycle test checks that
invalid pedigree graphs stop before payload construction.

## Coordination Notes

The Julia twin should treat this payload as the R-side target for the next
`HSquared.jl` alignment slice:

```julia
pedigree = normalize_pedigree(id, sire, dam)
Ainv = pedigree_inverse(pedigree)
spec = animal_model_spec(y, X, Z, Ainv; ids = ids, method = :REML)
fit = fit_animal_model(spec)
```

## What Did Not Go Smoothly

Snapshot tests were noisier than useful for ordinary parser errors. They passed
interactively after acceptance but failed under R CMD check. The fix was to use
direct `expect_error()` assertions for stable one-line errors.

## Known Limitations

- The payload is internal and not exported.
- `Ainv` remains `NULL` on the R side and is expected to be built in Julia.
- No JuliaCall bridge execution exists yet.
- No fitted object, variance components, heritability, or EBVs exist yet.

## Next Actions

1. Push the R bridge-payload commit and watch R-CMD-check/pkgdown CI.
2. Coordinate the Julia twin to align `animal_model_spec()` tests/docs with the
   R payload.
3. Start the first live bridge execution slice only after the Julia target is
   stable on its side.
