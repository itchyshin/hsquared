# Estimated-vs-Supplied Variance Provenance (B3)

Date: 2026-06-13

Active lenses: Emmy, Fisher, Rose, Pat.

Spawned subagents: none (additive diagnostic plumbing done solo).

Current lane: R.

## Goal

Make an estimated-variance fit honestly distinguishable from a supplied-variance
fit. After B2 surfaced the Julia-owned `fit_sparse_reml()` estimator, its fit
object must not look identical to the supplied-variance `henderson_mme` fit. B3
tags variance provenance and exposes it through `fit_diagnostics()`, and adds a
`validation_status()` row for the experimental estimator path.

## Files Changed

- `R/julia-bridge.R` — the sparse-REML path tags
  `result$diagnostics$variance_components <- "estimated_sparse_reml"` (the
  `henderson_mme` path already tags `"supplied"`); `fit_diagnostics()` surfaces
  it as `variance_components_source`.
- `R/validation-status.R` — new "experimental sparse REML estimator (opt-in)"
  row (Phase 1, partial), with synchronized phase/status/evidence/boundary
  vectors (now 13 rows).
- `tests/testthat/test-julia-bridge.R` — the live sparse-REML test now asserts
  `fit_diagnostics()` reports `target = "sparse_reml"` and
  `variance_components_source = "estimated_sparse_reml"`.
- `tests/testthat/test-phase0-api.R` — `validation_status()` row count 12 -> 13;
  new row asserted `partial`.

## Verification

- `devtools::test()` full: `476 pass`, `0 fail`, `0 warnings`, `0 skips` (live
  Julia bridge active; the provenance assertions ran).
- `rcmdcheck::rcmdcheck()`: `0 errors`, `0 warnings`, `0 notes`.
- `air format .` clean.
- Remote (commit `503734e`): R-CMD-check `27468654232`, pkgdown `27468654248`,
  Pages `27468689299` all passed.

## Public Claim Audit (Rose)

Allowed: fits now carry an explicit `variance_components_source` provenance
(`supplied` for Henderson MME, `estimated_sparse_reml` for the opt-in sparse
estimator); the experimental estimator path appears in `validation_status()` as
`partial`.

Blocked: provenance labelling is not an accuracy, recovery, production-fitting,
or comparator claim; it only records which path produced a fit's variances.

## Known Limitations

- The default dense `fit_animal_model` path is not relabelled here (out of scope);
  only the supplied vs estimated-sparse distinction is made explicit.

## Next Actions

1. B4: sparse REML estimate-recovery validation fixture (reuse
   `DRM.jl/src/comparison.jl` comparator discipline; optimizer improves the REML
   objective over a known start — not DGP recovery).
2. B5: record the sparse-REML bridge contract in `03-engine-contract.md`.
