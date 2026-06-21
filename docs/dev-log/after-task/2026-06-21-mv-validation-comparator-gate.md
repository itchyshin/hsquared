# After-task report - 2026-06-21 multivariate validation/comparator gate

Active lenses: Ada, Shannon, Curie, Fisher, Mrode, Jason, Rose, Grace.
Spawned subagents: none.
Current lane: R validation.

## Goal

Start the validation/comparator lane from clean updated `main` after the two
banking PRs merged:

- `hsquared` #35, fit-time plot-data payload attachment;
- `HSquared.jl` #125, multivariate `sommer` comparator evidence.

This slice makes the R-facing validation gate explicit. It does not promote
`V4-MV-REML`.

## Files Changed

- `R/validation-status.R`
- `tests/testthat/test-phase0-api.R`
- `docs/design/04-validation-canon.md`
- `docs/dev-log/issue-map.md`
- `docs/dev-log/check-log.md`
- `docs/dev-log/coordination-board.md`

## Checks

- `air format .` - passed.
- `Rscript --vanilla -e 'devtools::test(filter = "phase0-api")'` - 87 passed,
  0 failed, 0 warnings, 0 skipped.
- `Rscript --vanilla -e 'pkgdown::check_pkgdown()'` - clean.
- `git diff --check` - clean.
- `_R_CHECK_FORCE_SUGGESTS_=false Rscript --vanilla -e 'rcmdcheck::rcmdcheck(args = "--no-manual", error_on = "never")'` -
  Status OK, 0 errors, 0 warnings, 0 notes.

The package check reported missing optional suggested packages `enhancer`,
`nadiv`, and `pedigreemm` as INFO only because forced suggests were disabled.

## Public Claim Audit

Rose status: clean with boundary.

The multivariate validation row remains `partial`. The R lane now says exactly
what exists:

- a 100-replicate cold-start t=2 known-truth recovery study;
- one reproduced full-unstructured `sommer` comparator leg against the shared
  `phase4_multitrait_parity` target.

The row also says what does not exist yet:

- no covered promotion;
- no ASReml/BLUPF90/JWAS/equivalent second independent comparator;
- no published or Mrode-style multivariate target;
- no production sparse/deep-pedigree claim.

## Tests Of The Tests

`test-phase0-api.R` now asserts the multivariate row:

- stays `partial`;
- mentions the 100-replicate cold-start study;
- mentions the full-unstructured `sommer` comparator;
- keeps covered promotion twin-gated;
- names the published/Mrode-style target blocker;
- names the second independent comparator blocker.

## Coordination Notes

Julia2 reported it merged both banking PRs remotely before the R delegation was
received. R refreshed `main` instead of attempting to re-merge #35. The two
unrelated Codex handover files remain untracked locally and were not touched.

Julia owns the `HSquared.jl` validation-status promotion mechanics. R owns this
R-facing status table, canon, and issue-map wording.

## Known Limitations

Local R currently has `sommer` and `MCMCglmm`, but not `nadiv`, `asreml`,
`pedigreemm`, or BLUPF90-family executables. `MCMCglmm` is Bayesian and is not a
drop-in same-estimand REML comparator.

## Next Actions

1. Bank this as a narrow R status/gate PR.
2. Coordinate with Julia2's `codex/mv-validation-comparator-gate` branch.
3. Choose the next actual evidence-producing leg: published/Mrode-style
   multivariate target, ASReml/BLUPF90/AIREMLF90/JWAS-equivalent comparator, or
   a re-declared broader recovery gate.
