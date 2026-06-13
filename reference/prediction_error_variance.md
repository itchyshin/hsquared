# Extract prediction error variances

`prediction_error_variance()` is part of the planned v0.1 fitted-object
contract. It returns values only when an `hsquared_fit` object contains
a Julia result field for prediction error variances.

## Usage

``` r
prediction_error_variance(object, ...)
```

## Arguments

- object:

  A fitted model object.

- ...:

  Reserved for future arguments.

## Value

Prediction error variances for `hsquared_fit` objects.
