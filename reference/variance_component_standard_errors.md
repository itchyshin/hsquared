# Extract experimental variance-component and heritability standard errors

`variance_component_standard_errors()` and
`heritability_standard_error()` return **experimental** large-sample
(delta-method) standard errors derived from the REML average-information
matrix. They are available only when an `hsquared_fit` object contains
them; the default Gaussian animal-model fit populates them from the
engine when a local Julia engine is present and the AI matrix is
invertible.

## Usage

``` r
variance_component_standard_errors(object, ...)

heritability_standard_error(object, ...)
```

## Arguments

- object:

  A fitted model object.

- ...:

  Reserved for future arguments.

## Value

`variance_component_standard_errors()` returns a data frame with
`component` and `se`; `heritability_standard_error()` returns a single
numeric. Only for `hsquared_fit` objects that contain them.

## Details

These mirror the engine row `V1-HERIT-CI` (`partial`): asymptotic,
REML-only, and unreliable at small `n` or near a variance-component
boundary (where the AI matrix is ill-conditioned and the fields are
omitted). They are not coverage-calibrated and not a validated
capability.
