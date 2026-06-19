# Response-scale prediction helpers

[`predict()`](https://rdrr.io/r/stats/predict.html),
[`fitted()`](https://rdrr.io/r/stats/fitted.values.html), and
[`residuals()`](https://rdrr.io/r/stats/residuals.html) are part of the
planned v0.1 fitted-object contract for univariate `hsquared_fit`
objects. They are univariate-only: the opt-in multivariate target
(`target = "multivariate"`) fits multiple traits jointly and is
intentionally out of v0.1 response-scale scope, so these methods stop
with a scope message pointing to
[`breeding_values()`](https://itchyshin.github.io/hsquared/reference/breeding_values.md),
[`genetic_covariance()`](https://itchyshin.github.io/hsquared/reference/multivariate_extractors.md),
and
[`residual_covariance()`](https://itchyshin.github.io/hsquared/reference/multivariate_extractors.md).

## Usage

``` r
# S3 method for class 'hsquared_fit'
predict(object, ...)

# S3 method for class 'hsquared_fit'
fitted(object, ...)

# S3 method for class 'hsquared_fit'
residuals(object, ...)
```

## Arguments

- object:

  A fitted model object.

- ...:

  Reserved for future arguments.

## Value

Response-scale predictions, fitted values, or residuals for univariate
`hsquared_fit` objects.
