# Extract the common-environment variance ratio (c2)

`common_env_proportion()` returns the estimated common-environment
variance ratio `c2 = sigma_c2 / (sigma_a2 + sigma_c2 + sigma_e2)` from
the opt-in, experimental two-effect model (`target = "two_effect"` with
a
[`common_env()`](https://itchyshin.github.io/hsquared/reference/qg_effect_markers.md)
term).

## Usage

``` r
common_env_proportion(object, ...)
```

## Arguments

- object:

  A fitted model object.

- ...:

  Reserved for future arguments.

## Value

A one-row data frame with `term` and `estimate`, plus an
`"interpretation"` attribute, for two-effect `hsquared_fit` objects.

## Details

Falconer fence: `c2` is a **variance ratio** (the proportion of
phenotypic variance from the shared common-environment effect), **not a
heritability**. In the same fit,
[`heritability()`](https://itchyshin.github.io/hsquared/reference/heritability.md)
reports narrow-sense `h2 = sigma_a2 / (sigma_a2 + sigma_c2 + sigma_e2)`
*within this two-effect model*. The returned data frame carries this
note as an `"interpretation"` attribute. For an interval on `c2`, see
[`common_env_proportion_interval()`](https://itchyshin.github.io/hsquared/reference/common_env_proportion_interval.md).
