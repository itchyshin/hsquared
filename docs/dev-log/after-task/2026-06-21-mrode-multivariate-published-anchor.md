# Mrode multivariate published anchor

Date: 2026-06-21

## Task goal

Close the R-owned published/Mrode-style multivariate validation blocker with a
CI-runnable target, while keeping `V4-MV-REML` partial.

## Active lenses and spawned agents

Active lenses: Ada, Shannon, Curie, Fisher, Mrode, Jason, Rose, Grace.

Spawned agents: none.

Current lane: R validation/docs.

## Files changed

- `R/validation-fixtures.R`: added Mrode Example 5.1 fixture and a pure-R
  multivariate Henderson MME reference solve.
- `tests/testthat/test-mrode-multivariate-anchor.R`: new published-target test
  and test-of-test.
- `R/validation-status.R` and `tests/testthat/test-phase0-api.R`: status table
  now records the Mrode Example 5.1 anchor while preserving the remaining V4
  blockers.
- `docs/design/04-validation-canon.md`
- `docs/design/11-next-50-slices.md`
- `docs/design/12-multivariate-comparator-plan.md`
- `docs/design/capability-status.md`
- `docs/design/validation-debt-register.md`
- `docs/dev-log/issue-map.md`
- `docs/dev-log/check-log.md`
- `docs/dev-log/coordination-board.md`

## Checks run and exact outcomes

- `air format .`: passed.
- `Rscript --vanilla -e 'devtools::test(filter = "mrode-multivariate-anchor|phase0-api")'`:
  94 pass, 0 fail, 0 warn, 0 skip.
- `Rscript --vanilla -e 'devtools::test()'`: 1210 pass, 0 fail, 0 warn, 55
  skip.
- `Rscript --vanilla -e 'pkgdown::check_pkgdown()'`: passed, no problems
  found.
- `git diff --check`: passed.
- `_R_CHECK_FORCE_SUGGESTS_=false Rscript --vanilla -e 'rcmdcheck::rcmdcheck(args = "--no-manual", error_on = "never")'`:
  0 errors, 0 warnings, 0 notes.

## Public claim audit

Rose verdict: clean if the row remains `partial`.

This slice adds a published supplied-covariance BLUP/MME target: Mrode Example
5.1 multiple-trait fixed effects and animal BLUPs at supplied `G0` and `R0`.
It does not estimate variance components, does not validate the dense
multivariate REML optimizer by itself, and does not add an ASReml/BLUPF90/JWAS
same-estimand comparator run.

The remaining R/J validation blockers are now explicit:

- recovery gate must be accepted as declared or broadened;
- another independent same-estimand comparator beyond `sommer` is still needed;
- Julia/twin owns the covered promotion gate for `V4-MV-REML`.

## Tests of the tests

The new test has a perturbation guard: adding 0.01 to the published animal BLUP
vector fails against the 5e-5 published-digit tolerance.

## Coordination notes

This is the R counterpart to the Big 1 validation-to-coverage path. Julia is
separately preparing the BLUPF90/RENUMF90/AIREMLF90 starter-packet route in
HSquared.jl PR #127; that PR is setup only and does not create comparator
evidence.

## What did not go smoothly

The first raw URLs for Masuda's sample data were not the right repository path.
The LUKE PDF provided the direct Mrode Example 5.1 data, pedigree, covariance
matrices, fixed effects, and animal BLUPs needed for a pinned target.

## Known limitations

- This is supplied-covariance BLUP/MME validation, not REML variance-component
  recovery.
- The target uses printed published/reproduced digits, so the numeric tolerance
  is intentionally at the printed-digit scale.
- Local comparator availability remains limited: `sommer` and `MCMCglmm` are
  installed; `nadiv`, `pedigreemm`, `asreml`, `AGHmatrix`, `enhancer`, and
  `JWAS` are not installed, and BLUPF90-family executables are not on `PATH`.

## Next actions

- Watch Julia PR #127 for the BLUPF90 starter packet.
- When a BLUPF90/AIREMLF90, ASReml, JWAS, or accepted equivalent run is
  available, record it under `docs/dev-log/comparator-runs/`.
- Decide whether the existing 100-replicate cold-start recovery study is the
  declared V4 recovery gate or whether the recovery grid should be broadened.
