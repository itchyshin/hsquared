# Extract multivariate covariance and correlation matrices

These extractors return the genetic (`G`) and residual (`R`) covariance
or correlation matrices from opt-in multivariate `hsquared_fit` objects
(`target = "multivariate"`).

## Usage

``` r
genetic_covariance(object, ...)

residual_covariance(object, ...)

genetic_correlation(object, ...)

residual_correlation(object, ...)
```

## Arguments

- object:

  A fitted model object.

- ...:

  Reserved for future arguments.

## Value

A numeric matrix for `hsquared_fit` objects that contain the requested
multivariate result field.
