# Extract the maternal variance ratio (m2)

`maternal_proportion()` returns the estimated maternal variance ratio
`m2 = sigma_m2 / (sigma_a2 + sigma_m2 + sigma_e2)` from the opt-in,
experimental maternal two-effect model (`target = "two_effect"` with a
[`maternal_genetic()`](https://itchyshin.github.io/hsquared/reference/qg_effect_markers.md)
term).

## Usage

``` r
maternal_proportion(object, ...)
```

## Arguments

- object:

  A fitted model object.

- ...:

  Reserved for future arguments.

## Value

A one-row data frame with `term` and `estimate`, plus an
`"interpretation"` attribute, for maternal two-effect `hsquared_fit`
objects.

## Details

Falconer fence: `m2` is a **variance ratio** (the proportion of
phenotypic variance from the maternal (dam) genetic effect), **not a
heritability**. In the same fit,
[`heritability()`](https://itchyshin.github.io/hsquared/reference/heritability.md)
reports the narrow-sense *direct*
`h2 = sigma_a2 / (sigma_a2 + sigma_m2 + sigma_e2)` *within this
two-effect model*; the direct and maternal genetic effects are modelled
as uncorrelated here (no direct-maternal genetic covariance). The
returned data frame carries this note as an `"interpretation"`
attribute. For an interval on `m2`, see
[`maternal_proportion_interval()`](https://itchyshin.github.io/hsquared/reference/common_env_proportion_interval.md).
