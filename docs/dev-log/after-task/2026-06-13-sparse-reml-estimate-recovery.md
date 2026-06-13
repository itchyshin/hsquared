# Sparse REML Estimate-Recovery Validation Fixture (B4)

Date: 2026-06-13

Active lenses: Curie, Gauss, Fisher, Mrode, Jason, Rose.

Spawned subagents: none (the B2 scout already covered the sister-repo comparator
discipline; B4 is a focused test + canon/register update, self-audited for the
estimand trap).

Current lane: R.

## Goal

Give the experimental, opt-in sparse REML estimator its first honest behavioural
evidence without falling into the comparator estimand trap the validation canon
warns about. The check is **start-independence**: the optimizer reaches the same
REML optimum from two different starting variance components. This validates the
optimizer, NOT data-generating recovery, supplied-truth recovery, an external
comparator, or ASReml parity.

## Reuse / discipline

Applies the comparator discipline from `DRM.jl/src/comparison.jl` and
`04-validation-canon.md`: compare the SAME estimand (the REML objective) across
the two starts. External-comparator validation (ASReml/BLUPF90/DMU/WOMBAT)
remains a tracked gap and, when added, is governed by the same rule.

## Files Changed

- `tests/testthat/test-validation-fixtures.R` — skip-guarded live test: two fits
  via the opt-in `target = "sparse_reml"` path from starts (0.5, 0.5) and
  (3.0, 1.5); asserts same REML optimum (loglik tol 1e-3, variance estimates tol
  1e-2), positive estimates, and `variance_components_source =
  "estimated_sparse_reml"`.
- `docs/design/04-validation-canon.md` — new estimate-recovery atom bullet with
  the explicit no-DGP-recovery / no-comparator boundary.
- `docs/design/capability-status.md`, `docs/design/validation-debt-register.md`
  — strengthened the experimental sparse REML estimator evidence to include the
  start-independence check.

## Verification

- `devtools::test()` full: `481 pass`, `0 fail`, `0 warnings`, `0 skips` (live
  Julia bridge active; the two-start test ran).
- `rcmdcheck::rcmdcheck()`: `0 errors`, `0 warnings`, `0 notes`.
- `air format .`: clean.
- Remote (commit `8a2009a`): R-CMD-check `27468842532`, pkgdown `27468842514`,
  Pages `27468886120` all passed.

## Public Claim Audit (Rose)

Allowed: the opt-in sparse REML optimizer reaches the same REML optimum from
different starts (start-independence) with positive estimated variances.

Blocked: data-generating recovery; supplied-truth recovery; external-comparator
parity; AI-REML; production sparse fitting; accuracy claims.

## Known Limitations

- Start-independence is necessary but not sufficient for production confidence;
  external-comparator validation (ASReml/BLUPF90) remains a tracked gap.
- The live test runs only when the sibling `HSquared.jl` checkout is available
  (skip-guarded; skipped on CI/CRAN).

## Next Actions

1. B5: record the sparse-REML bridge contract in `03-engine-contract.md` and
   close the surfacing arc on the coordination board.
2. Notify issue #7 and the Julia twin that the R lane now has start-independence
   evidence for the surfaced `fit_sparse_reml` path.
