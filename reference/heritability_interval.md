# Extract an experimental heritability confidence interval

`heritability_interval()` returns an **experimental** large-sample
confidence interval for `h^2`. It is available only when an
`hsquared_fit` object contains the interval field, which the default
Gaussian animal-model fit (`engine = "fit"`) populates from the engine's
`HSquared.heritability_interval()` when a local Julia engine is present
and the estimate is interior to `(0, 1)`.

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

This mirrors the engine row `V1-HERIT-CI`, which is `partial`: the
interval is a REML-only, asymptotic (logit delta-method) approximation,
not a coverage-calibrated interval, and is unreliable at small `n`. It
is reported as a point estimate plus bounds, not a validated capability.
