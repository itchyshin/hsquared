# After-task report: structured diagonal claims reconciliation

Date: 2026-06-21

## Goal

Reconcile public-facing structured covariance wording after the rotation-free
diagonal genetic covariance bridge had already landed, without changing parser
or fitting behavior.

## Active Lenses

Ada, Shannon, Boole, Hopper, Kirkpatrick, Rose, Grace.

## Files Changed

- `R/hs_control.R`
- `man/hs_control.Rd`
- `docs/design/06-public-claims-register.md`
- `docs/dev-log/check-log.md`
- `docs/dev-log/coordination-board.md`
- `docs/dev-log/after-task/2026-06-21-structured-diagonal-claims-reconcile.md`

The unrelated Codex handover files remain untracked and untouched.

## Formula And Bridge Contract

Accepted current surface:

```r
hs_control(
  engine = "julia",
  engine_control = list(
    target = "multivariate",
    genetic_structure = "diagonal"
  )
)
```

This is the rotation-free structured subset for the existing `cbind(...)`
multivariate bridge. It fixes off-diagonal genetic covariances to zero.

Deferred surfaces:

- `genetic_structure = "lowrank"`
- `genetic_structure = "factor_analytic"`
- `engine_control$rank`
- long-format `animal(trait | id, pedigree = ped, cov = us())`
- long-format `animal(trait | id, pedigree = ped, cov = diag())`
- long-format `animal(trait | id, pedigree = ped, cov = lowrank(K = ...))`
- long-format `animal(trait | id, pedigree = ped, cov = fa(K = ...))`
- interpreted loading extractors

## Claim Boundary

Allowed claim: diagonal genetic covariance is an experimental/partial
`engine_control` surface on the opt-in multivariate bridge.

Blocked claims:

- factor-analytic or low-rank fitting is active;
- long-format structured covariance formula grammar is parsed;
- loadings are interpretable or extractable;
- structured covariance support is production-scale or covered.

## Checks

- `Rscript --vanilla -e 'devtools::document()'`
- `Rscript --vanilla -e 'devtools::test(filter = "phase0-api|formula-animal|multivariate|diagonal-multivariate|covariance-structure-lrt")'`:
  269 pass / 0 fail / 0 warn / 4 skip.
- `Rscript --vanilla -e 'pkgdown::check_pkgdown()'`: clean.
- `git diff --check`: clean.
- Rose overclaim grep over the structured-covariance claim surfaces:
  clean-with-limitations; diagonal is experimental/partial, while
  `lowrank`, `factor_analytic`, `rank`, and long-format `cov = ...` grammar
  remain planned/fenced.
- `_R_CHECK_FORCE_SUGGESTS_=false Rscript --vanilla -e 'rcmdcheck::rcmdcheck(args = "--no-manual", error_on = "warning", check_dir = tempfile("hsq-check-"))'`:
  0 errors / 0 warnings / 0 notes.

## Next Actions

1. Bank as a narrow claims-reconciliation PR if green.
2. Keep `lowrank` and `factor_analytic` behind the existing bridge gates until
   the loading rotation/interpretation contract is validated.
