# Extract an experimental heritability confidence interval

`heritability_interval()` returns an **experimental** large-sample
confidence interval for `h^2`. It is available only when an
`hsquared_fit` object contains the interval field, which the default
Gaussian animal-model fit (`engine = "fit"`) populates from the engine's
`HSquared.heritability_interval()` when a local Julia engine is present
and the estimate is interior to `(0, 1)`. On the opt-in two-effect fit
it returns the direct-heritability ratio interval (`ratio1`), and on the
opt-in multi-effect fit (`target = "multi_effect"`, K \>= 3 blocks) it
returns the ANIMAL block's ratio interval (the animal additive variance
over the total phenotypic variance); the other blocks' variance-ratio
intervals are surfaced separately in
`fit$result$variance_ratio_intervals`.

## Usage

``` r
heritability_interval(object, ...)
```

## Arguments

- object:

  A fitted model object.

- ...:

  Reserved for future arguments.

## Value

A one-row data frame with `estimate`, `lower`, `upper`, `level`, `se`
(`NA` for the profile method), and `method`, for `hsquared_fit` objects
that contain it.

## Details

The interval leg is a REML-only, asymptotic (logit delta-method)
approximation, not a coverage-calibrated interval, and is unreliable at
small `n` (as with the `partial` `V1-HERIT-CI`). The underlying
estimators `V3-TWOEFFECT-REML` / `V3-NEFFECT-REML` are `covered`, but
this interval is reported as a point estimate plus bounds, not a
validated (coverage-calibrated) capability.
