# After-task report: H^Gamma result-surface evidence

Date: 2026-06-21

## Goal

Mirror the Julia-side nonzero-`Gamma` `H^Gamma` bridge-readiness proof on the
R side without changing the public capability boundary.

## Active Lenses

Ada, Shannon, Hopper, Henderson, Curie, Fisher, Rose, Grace.

## Files Changed

- `tests/testthat/test-single-step-construct.R`
- `docs/design/capability-status.md`
- `docs/design/validation-debt-register.md`
- `docs/dev-log/check-log.md`
- `docs/dev-log/coordination-board.md`
- `docs/dev-log/after-task/2026-06-21-hgamma-result-surface-evidence.md`

The unrelated Codex handover files remain untracked and untouched.

## What Changed

The skip-guarded live nonzero-`Gamma` single-step `H^Gamma` test now asserts
that the result travels through the standard `hsquared_fit` surface:

- `fit_diagnostics()` reports `target = "metafounder_single_step"`.
- `fit_diagnostics()` reports
  `variance_components_source = "estimated_metafounder_single_step_ai_reml"`.
- `fit_diagnostics()` reports `gamma_source = "supplied"`.
- `prediction_error_variance()` returns finite values for all pedigree IDs.
- `reliability()` returns all pedigree IDs with values in `[0, 1]`.
- `accuracy()` is the square root of `reliability()`.

The capability and validation-debt ledgers now mention this result-surface
assertion while keeping the row partial.

## Claim Boundary

Allowed claim: the experimental, opt-in R bridge consumes a nonzero-`Gamma`
`H^Gamma` result through the standard fitted-object diagnostics, PEV,
reliability, and accuracy surface when the sibling Julia bridge is available.

Blocked claims:

- `Gamma` estimation.
- Returned metafounder-specific effects.
- BLUPF90, ASReml, DMU, WOMBAT, or other external comparator evidence.
- Production-scale sparse/APY support.
- Covered-status promotion for metafounder or `H^Gamma`.

## Checks

- `air format tests/testthat/test-single-step-construct.R`
- `HSQUARED_JULIA_PROJECT="/Users/z3437171/Dropbox/Github Local/HSquared.jl" NOT_CRAN=true Rscript --vanilla -e 'devtools::test(filter = "single-step-construct")'`:
  105 pass / 0 fail / 0 warn / 0 skip.
- `Rscript --vanilla -e 'devtools::test(filter = "phase0-api|single-step-construct|fit-object")'`:
  262 pass / 0 fail / 0 warn / 7 skip.
- `Rscript --vanilla -e 'devtools::test()'`: 1290 pass / 0 fail /
  0 warn / 58 skip.
- `Rscript --vanilla -e 'pkgdown::check_pkgdown()'`: clean.
- `git diff --check`: clean.
- `_R_CHECK_FORCE_SUGGESTS_=false Rscript --vanilla -e 'rcmdcheck::rcmdcheck(args = "--no-manual", error_on = "warning", check_dir = tempfile("hsq-check-"))'`:
  0 errors / 0 warnings / 0 notes.

## Next Actions

1. Bank as a narrow R-lane PR if green.
2. Continue external comparator depth separately; this slice does not unblock
   covered-status promotion.
