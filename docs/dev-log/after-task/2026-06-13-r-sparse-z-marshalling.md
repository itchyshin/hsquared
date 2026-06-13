# R Sparse Z Bridge Marshalling

Date: 2026-06-13

Active lenses: Hopper, Lovelace, Karpinski, Grace, Rose.

Spawned subagents: none.

## Scope

Update the opt-in R-to-Julia bridge to send sparse `Matrix::dgCMatrix` random
effect designs through Julia CSC slots instead of densifying `Z`.

This follows the Julia twin's `HSquared.jl` commit
`6b530e4 Add sparse CSC bridge marshalling`.

## Implementation

Added:

- `hs_sparse_csc_slots()`
- `hs_julia_assign_sparse_csc()`

Changed:

- `hs_julia_assign_payload()` now constructs `hsq_Z` in Julia with
  `HSquared.sparse_csc_matrix()`;
- `hs_fit_julia_payload()` no longer checks or uses `max_dense_cells`;
- `hs_control()` documentation no longer advertises `max_dense_cells`.

## Validation

Local checks:

- `air format .`: completed.
- `Rscript -e "devtools::document()"`: regenerated `hs_control` Rd.
- `Rscript -e "devtools::test()"`: `116 pass`, `0 fail`, `0 warnings`,
  `0 skips`; live bridge activated sibling `HSquared.jl`.
- `git diff --check`: clean.
- `Rscript -e "pkgdown::check_pkgdown()"`: `No problems found.`
- `Rscript -e "devtools::check()"`: `0 errors | 0 warnings | 0 notes`.

## Rose Audit

Verdict: clean with limitations.

Allowed wording:

- sparse `Z` CSC marshalling exists for the opt-in R-to-Julia bridge;
- R sends `Matrix::dgCMatrix` slots to Julia's `sparse_csc_matrix()`;
- live tiny bridge tests pass through sparse `Z`.

Blocked wording:

- production sparse fitting works;
- large data are supported;
- sparse relationship objects beyond `Z` are bridged;
- bridge performance has been benchmarked;
- Mrode validation is covered.

## Next Work

1. Add sparse marshalling for other relationship or precision payloads when
   they enter the R bridge.
2. Add Mrode/tiny validation through the opt-in bridge.
3. Keep the default `hsquared()` engine as validation-only until public
   validation is stronger.
