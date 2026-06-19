# Diagnostic plots for a fitted animal model

A base-graphics diagnostic plot for `hsquared_fit` objects. Two panels
are available:

## Usage

``` r
# S3 method for class 'hsquared_fit'
plot(x, type = c("variance", "residuals"), ...)
```

## Arguments

- x:

  An `hsquared_fit` object.

- type:

  Which panel to draw: `"variance"` or `"residuals"`.

- ...:

  Passed to the underlying base-graphics call.

## Value

`x`, invisibly.

## Details

- `type = "variance"` (default) plots the estimated variance components
  as points. When the fit carries the **experimental**
  variance-component standard errors (see
  [`variance_component_standard_errors()`](https://itchyshin.github.io/hsquared/reference/variance_component_standard_errors.md)),
  it adds approximate `+/- 1.96 * SE` whiskers and labels the panel
  experimental; those intervals are asymptotic, REML-only, and not
  coverage-calibrated.

- `type = "residuals"` plots residuals against fitted values (with a
  zero reference line), when the fit carries fitted values and a
  response.

No plotting dependency is added; this uses base graphics only.
