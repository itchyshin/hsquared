# Independent Pure-R REML Optimizer Cross-Check (B7)

Date: 2026-06-13

Active lenses: Curie, Gauss, Fisher, Rose.

Spawned subagents: none.

Current lane: R + twin-coordinated (read-only against the twin engine).

## Goal

Add a fully independent (non-Julia) check on the surfaced sparse REML estimator:
a pure-R `optim()` over the dense Gaussian REML objective. A clean external REML
comparator (sommer/pedigreemm) is not installed locally, and the available
`MCMCglmm` is Bayesian (different estimand, excluded by the comparator
discipline), so an independent pure-R optimizer is the honest in-reach rung.

## Files Changed

- `R/validation-fixtures.R` — new internal `hs_reml_estimate_reference()`:
  `optim()` (Nelder-Mead, log-variances) over `hs_gaussian_loglik_reference()`;
  returns the estimated variance components, log-likelihood, and convergence.
- `tests/testthat/test-validation-fixtures.R` — test: the pure-R optimizer
  converges to positive finite REML estimates on the Mrode fixture (runs on CI,
  no Julia), and, skip-guarded, the Julia `fit_sparse_reml()` estimate matches
  the pure-R optimum (tol 5e-2).
- `docs/design/04-validation-canon.md`, `docs/design/capability-status.md`,
  `docs/design/validation-debt-register.md` — recorded the independent-optimizer
  cross-check.

## Verification

- `devtools::test()` full: `490 pass`, `0 fail`, `0 warnings`, `0 skips` (live
  Julia bridge active; the pure-R optimum and the Julia estimate agreed).
- `rcmdcheck::rcmdcheck()`: `0 errors`, `0 warnings`, `0 notes`.
- `air format .`: clean.
- Remote (commit `1d576c8`): R-CMD-check `27469532263`, pkgdown `27469532270`,
  Pages `27469579694` all passed.

## Result / Finding

The Julia `fit_sparse_reml()` variance estimate matches an independent pure-R
REML optimization of the same objective on the Mrode fixture. With B6 (sparse-vs-
dense) this gives two independent cross-checks of the surfaced optimizer.

## Public Claim Audit (Rose)

Allowed: the sparse REML estimate matches an independent pure-R REML optimizer
(same estimand, independent implementation). The pure-R optimizer is a
validation reference, not a public estimation feature.

Blocked: external-comparator parity (ASReml/BLUPF90/...), DGP recovery,
production sparse fitting, AI-REML, accuracy claims.

## Next Actions (decisions for the maintainer)

1. External comparator needs `sommer` or `pedigreemm` installed (not present);
   `MCMCglmm` is Bayesian and excluded by the comparator discipline. Decide
   whether to add a Suggests-gated REML comparator dependency.
2. Fitted-Mrode against published estimates, production sparse PEV/reliability,
   and AI-REML are Julia-engine (twin) work — await the twin and its green
   `validation_status()` before any public fitting claim.
