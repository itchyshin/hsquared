# Sparse-vs-Dense REML Optimizer Agreement (B6)

Date: 2026-06-13

Active lenses: Curie, Gauss, Fisher, Hopper, Rose.

Spawned subagents: none.

Current lane: R + twin-coordinated (read-only against the twin engine).

## Goal

A follow-on validation after the planned Phase B arc: cross-check the
experimental sparse REML optimizer against the dense REML optimizer. Both
maximize the same REML objective via different linear algebra, so on the same
data they must reach the same optimum. This is the first internal-comparator rung
toward the external-comparator gap; it is not an external comparator, DGP
recovery, or production-fitting claim.

## Files Changed

- `tests/testthat/test-validation-fixtures.R` — skip-guarded live test fitting
  the Mrode fixture with REML through both the dense optimizer
  (`fit_variance_components`, default `target = "fit_animal_model"`) and the
  sparse optimizer (`fit_sparse_reml`, `target = "sparse_reml"`); asserts the
  same REML log-likelihood optimum (tol 1e-3) and matching variance estimates
  (tol 5e-2).
- `docs/design/04-validation-canon.md` — new sparse-vs-dense agreement atom.
- `docs/design/capability-status.md`, `docs/design/validation-debt-register.md`
  — strengthened the experimental sparse REML estimator evidence.

## Verification

- `devtools::test()` full: `486 pass`, `0 fail`, `0 warnings`, `0 skips` (live
  Julia bridge active; the dense and sparse optimizers both ran and agreed).
- `rcmdcheck::rcmdcheck()`: `0 errors`, `0 warnings`, `0 notes`.
- `air format .`: clean.
- Remote (commit `f84b959`): R-CMD-check `27469342270`, pkgdown `27469342263`,
  Pages `27469378298` all passed.

## Result / Finding

The sparse and dense REML optimizers reach the same REML optimum on the Mrode
fixture (matching log-likelihood and variance estimates). This cross-validates
the surfaced `fit_sparse_reml` optimizer against the independent dense path.

## Public Claim Audit (Rose)

Allowed: the sparse REML optimizer agrees with the dense REML optimizer on the
same fixture (internal cross-check of the same estimand).

Blocked: external-comparator parity (ASReml/BLUPF90/...), DGP recovery,
production sparse fitting, AI-REML, accuracy claims.

## Next Actions

1. External comparator rung: if a local R animal-model package (e.g. `sommer`,
   `pedigreemm`) is available, compare estimates on a shared example under the
   comparator discipline (same DGP/estimator/scale).
2. Promote `sparse_reml` to a public claim once the twin's `validation_status()`
   marks `fit_sparse_reml` green.
