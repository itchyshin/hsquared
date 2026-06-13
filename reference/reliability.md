# Extract reliability and accuracy estimates

`reliability()` is part of the planned v0.1 fitted-object contract. It
returns values only when an `hsquared_fit` object contains a Julia
result field for reliability estimates. `accuracy()` returns the square
root of reliability for `hsquared_fit` objects.

## Usage

``` r
reliability(object, ...)

accuracy(object, ...)
```

## Arguments

- object:

  A fitted model object.

- ...:

  Reserved for future arguments.

## Value

Reliability estimates for `hsquared_fit` objects.
