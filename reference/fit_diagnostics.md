# Inspect fitted-model diagnostics

`fit_diagnostics()` returns a compact diagnostics table for an
`hsquared_fit` object. It is an inspection helper over the current
result payload: it does not refit the model, rerun validation checks, or
promote an experimental bridge target to production support.

## Usage

``` r
fit_diagnostics(object, ...)
```

## Arguments

- object:

  A fitted model object.

- ...:

  Reserved for future arguments.

## Value

A data frame with `metric` and `value` columns and class
`"hs_fit_diagnostics"`.
