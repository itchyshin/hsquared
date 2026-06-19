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

Heavy caveats (engine row `V4-MV-REML`, `partial`): the multivariate
REML recovery calibration did **not** pass (6/10 unstructured seeds).
These SEs are asymptotic, REML-only, **unstructured-only** (the engine
refuses structured / factor-analytic fits, whose loadings are
rotation-nonidentified), omitted at a flat/boundary optimum, not
coverage-calibrated, and not a validated capability.
