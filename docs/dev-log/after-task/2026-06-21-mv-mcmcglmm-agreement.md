# After-task — Multivariate MCMCglmm Bayesian agreement probe (2026-06-21)

## Task Goal

Record a reproducible R-lane `MCMCglmm` agreement probe for the shared
`phase4_multitrait_parity` multivariate animal-model fixture, without promoting
`V4-MV-REML` beyond `partial`.

## Active Lenses And Spawned Agents

- Active lenses: Ada, Shannon, Jason, Curie, Fisher, Mrode, Rose, Grace, Pat.
- Spawned agents: none.
- Lane: R validation/comparator evidence.

## Files Changed

- `data-raw/multivariate-mcmcglmm-agreement-study.R`
- `R/validation-status.R`
- `tests/testthat/test-comparator-scripts.R`
- `tests/testthat/test-phase0-api.R`
- `NEWS.md`
- `docs/design/04-validation-canon.md`
- `docs/design/06-public-claims-register.md`
- `docs/design/12-multivariate-comparator-plan.md`
- `docs/design/capability-status.md`
- `docs/design/validation-debt-register.md`
- `docs/dev-log/check-log.md`
- `docs/dev-log/coordination-board.md`
- `docs/dev-log/issue-map.md`
- `vignettes/articles/g-matrix-interpretation.Rmd`
- `vignettes/articles/model-status.Rmd`
- `vignettes/articles/multivariate.Rmd`

## Evidence Produced

Command:

```sh
Rscript --vanilla data-raw/multivariate-mcmcglmm-agreement-study.R
```

Result:

- `MCMCglmm` 2.36.
- Seed 20260621.
- `nitt = 50000`, `burnin = 10000`, `thin = 40`.
- 1000 posterior samples.
- Serialized HSquared.jl target inside 95% HPD intervals for all 8 covariance
  elements, all 4 fixed effects, and both per-trait h2 values.
- Posterior-mean agreement:
  - `max|dG0| = 0.0385`
  - `max|dR0| = 0.00647`
  - `max|dbeta| = 0.00697`
  - `max|dh2| = 0.0253`
  - EBV correlations 0.9998 and 0.9997
  - `max|dEBV| = 0.0458`
  - minimum effective sample size 777.4 for VCV and 867.4 for solutions

Local comparator availability was refreshed:

- available: `sommer` 4.4.3, `MCMCglmm` 2.36;
- unavailable: `nadiv`, `asreml`, `pedigreemm`, `enhancer`, `AGHmatrix`;
- BLUPF90-family executable availability remains blocked from earlier probes.

## Public Claim Audit

Clean with explicit blockers. The `MCMCglmm` leg is a Bayesian/MCMC agreement
probe. It is not a same-estimand REML comparator and does not clear the second
comparator blocker beyond `sommer`.

`V4-MV-REML` remains `partial`. Covered promotion remains twin-gated and still
needs recovery-gate acceptance or broadening plus another independent
same-estimand comparator such as ASReml, BLUPF90/AIREMLF90, DMU/WOMBAT, or an
accepted equivalent.

## Tests Of The Tests

The new cheap test in `test-comparator-scripts.R` does not run the MCMC chain on
ordinary test runs. It checks that the opt-in script exists, carries the fixed
seed and MCMC settings, computes the HPD target check, and contains the
"not a same-estimand REML comparator" / "must not promote V4-MV-REML" fences.

`test-phase0-api.R` additionally guards that `validation_status()` surfaces the
MCMCglmm evidence while preserving the same-estimand REML blocker.

## Checks Run

- `air format .` clean.
- `Rscript --vanilla -e 'devtools::test(filter = "phase0-api|comparator-scripts")'`
  returned 134 pass / 0 fail / 0 warn / 0 skip.
- `Rscript --vanilla -e 'pkgdown::check_pkgdown()'` clean.
- `git diff --check` clean.
- `_R_CHECK_FORCE_SUGGESTS_=false Rscript --vanilla -e 'rcmdcheck::rcmdcheck(args = "--no-manual", error_on = "never")'`
  returned 0 errors / 0 warnings / 0 notes.

The first `rcmdcheck` attempt caught a build-sandbox failure because `data-raw`
is excluded from the source package. The script guard now runs in the source
tree and skip-guards when the script is absent from built-package checks.

## What Did Not Go Smoothly

The first draft used an overly strong inverse-Wishart scale and one residual
variance target missed the 95% HPD interval. The final script uses
`V = diag(2) * 0.02, nu = 3`, which keeps the probe weak enough for this small
fixture and puts all serialized targets inside the 95% HPD intervals.

The branch also contained stale pre-existing text references to
`data-raw/multivariate-mcmcglmm-agreement.R` and EBV correlations `> 0.9999`.
Those were reconciled to the actual script name and run output.

## Known Limitations

- Bayesian posterior summaries are not REML equality tolerances.
- This does not replace ASReml/BLUPF90-family/DMU/WOMBAT-style comparator work.
- No production-scale, deep-pedigree, or structured-covariance promotion follows
  from this slice.

## Next Actions

1. Run checks and bank this as a narrow evidence PR.
2. Continue the true second same-estimand comparator lane only when an accepted
   REML comparator is available locally or as a manual artifact.
3. Keep MCMCglmm/JWAS evidence classified as agreement evidence unless the
   estimand and fitting method are explicitly changed.
