# External REML Comparator: pedigreemm (B9)

Date: 2026-06-13

Active lenses: Jason, Fisher, Curie, Gauss, Rose.

Spawned subagents: none.

Current lane: R + twin-coordinated (read-only against the twin engine).

## Goal

First external-comparator rung (validation-hierarchy level 4): compare the
surfaced sparse REML estimator against an established, independent REML
animal-model package (`pedigreemm`, lme4-based), under the comparator discipline
(same model, same estimand, same data).

## Investigation / finding (the comparator did its job)

- On the saturated one-record-per-animal Mrode fixture, `pedigreemm` cannot fit
  at all (lme4's `nlevels == nobs` guard); the model is only identifiable via the
  pedigree relationship matrix. So a replicated design is required.
- Even on a replicated design, `pedigreemm` converged to a slightly sub-optimal
  point: under the common, machine-precision-verified REML objective
  (`hs_gaussian_loglik_reference`), hsquared/the pure-R reference reach the true
  REML optimum (verified by multi-start + grid search) while `pedigreemm` lands
  slightly worse (e.g. loglik -52.284 vs -52.310; h2 0.40 vs 0.43).
- Conclusion: the discrepancy is a `pedigreemm` optimizer/convergence
  limitation, not an hsquared bug. The honest, robust claim is therefore
  "hsquared is at least as good as `pedigreemm` by REML log-likelihood," not a
  tight point-estimate match (REML surfaces are flat).

## Files Changed

- `R/validation-fixtures.R` — `hs_replicated_animal_comparator_fixture()`:
  deterministic replicated dataset (3 records/animal on the Mrode pedigree;
  response simulated once with `set.seed(1)` and embedded verbatim).
- `tests/testthat/test-validation-fixtures.R` — `pedigreemm`-gated test: fit with
  `pedigreemm`, assert hsquared's REML solution achieves a REML logLik at least
  as high (common verified objective) and heritabilities agree within a sane band.
- `DESCRIPTION` — Suggests: `pedigreemm`, `withr`, and `lme4` (the test calls
  `lme4::VarCorr`).
- `docs/design/04-validation-canon.md`, `capability-status.md`,
  `validation-debt-register.md`, `R/validation-status.R` — recorded the external
  comparator and the finding.

## Verification

- `devtools::test()` full: `492 pass`, `0 fail`, `0 warnings`, `0 skips` (live
  Julia + pedigreemm; the comparator test ran and passed).
- `rcmdcheck::rcmdcheck(args = c("--no-manual", "--as-cran"))`: `0 errors`,
  `0 warnings`, `1 note` (benign "new submission / dev version" note).
- Remote (final commit `dcef460`): R-CMD-check `27470343823`, pkgdown
  `27470343838`, Pages `27470387166` all passed.

## What did not go smoothly (and the fix)

The first push (`9b2af4e`) FAILED CI: under `--as-cran`, R CMD check raised
`checking for unstated dependencies in 'tests' ... WARNING: '::' import not
declared from: 'lme4'`, and the workflow's `error-on: "warning"` turned it into a
failure. My local gate had used `--no-build-vignettes` without `--as-cran`, so it
missed the `--as-cran`-only check. Fix: declared `lme4` in Suggests (`dcef460`);
re-ran `--as-cran` locally (0 warnings) before re-pushing. **Lesson: run
`devtools::check()` / `rcmdcheck(--as-cran)` locally to match CI's
`--as-cran` + `error-on=warning`, not a lighter check.**

## Public Claim Audit (Rose)

Allowed: hsquared's REML solution is at least as good (by REML log-likelihood) as
the external `pedigreemm` package on a replicated animal-model dataset.

Blocked: ASReml/BLUPF90/DMU/WOMBAT parity; production-software validation; DGP
recovery; accuracy claims. Status stays `partial`.

## Next Actions

1. Promote the sparse REML path to a public claim only once the twin's
   `validation_status()` marks `fit_sparse_reml` green.
2. Heavier comparator/validation (ASReml/BLUPF90, fitted-Mrode, production sparse
   PEV/reliability, AI-REML) is Julia-engine (twin) work.
