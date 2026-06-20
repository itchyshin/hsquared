# Extract experimental multivariate covariance standard errors

`covariance_standard_errors()` returns **experimental** large-sample
(delta-method) standard errors for the multivariate genetic/residual
covariance and correlation matrices and per-trait `h²`, for an opt-in
**unstructured** multivariate fit, when the engine returned them.

## Usage

``` r
covariance_standard_errors(object, ...)
```

## Arguments

- object:

  A fitted model object.

- ...:

  Reserved for future arguments.

## Value

A named list of standard-error matrices `genetic_covariance`,
`residual_covariance`, `genetic_correlation`, `residual_correlation`,
and a per-trait `heritability` SE vector, for `hsquared_fit` objects
that contain them.

## Details

Heavy caveats (engine row `V4-MV-REML`, `partial`): the strict per-seed
recovery gate is still a non-pass (7/12 unstructured seeds in the
updated study), but a 12-seed bias/MCSE study (twin `HSquared.jl#78`)
shows **no detectable bias** — all six covariance parameters have
`|bias| ≤ 2·MCSE` (largest 0.84·MCSE), a low-power non-rejection
consistent with an unbiased estimator (not a proof), with EBV accuracy ≈
0.90 in both traits; a cold-start replication (#79) reaches the same
optimum on all 12 seeds, so it is not a warm-start artifact. The
per-seed gate failures reflect sampling variance of the estimated `G` at
this design, not a detected bias. These SEs remain asymptotic,
REML-only, **unstructured-only** (the engine refuses structured /
factor-analytic fits, whose loadings are rotation-nonidentified),
omitted at a flat/boundary optimum, not coverage-calibrated, with no
external comparator, and not a validated capability.
