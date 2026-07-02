# Extract heritability estimates

`heritability()` is part of the planned v0.1 fitted-object contract. It
works for `hsquared_fit` objects that contain a Julia result.

## Usage

``` r
heritability(object, ...)
```

## Arguments

- object:

  A fitted model object.

- ...:

  Reserved for future arguments.

## Value

Heritability results for `hsquared_fit` objects.

## Details

Falconer fence for the opt-in two-effect model
(`target = "two_effect"`): the reported number is the **narrow-sense
direct heritability** `h2 = sigma_a2 / (sigma_a2 + sigma_2 + sigma_e2)`
*within that model* (the additive-genetic variance is divided by the
total phenotypic variance, which now includes the second component
`sigma_2`). The second component's variance ratio (common-environment
`c2` or maternal `m2`) is **not** a heritability and is returned
separately by
[`common_env_proportion()`](https://itchyshin.github.io/hsquared/reference/common_env_proportion.md)
/
[`maternal_proportion()`](https://itchyshin.github.io/hsquared/reference/maternal_proportion.md).

Willham fence for the opt-in direct-maternal correlated model
(`target = "direct_maternal"`): `heritability()` returns the **labelled
triple** — direct h2_d, maternal m2, Willham total h2_T, and r_am — as a
data frame (Willham 1963, 1972).
`sigma_P = sigma_ad + sigma_am + sigma_dm + sigma_e2 = Var(y_i)`
(coefficient 1 on sigma_dm). A warning is issued because h2 is
denominator-dependent under maternal effects and h2_T \< h2_d is
expected when r_am \< 0. Use
[`direct_heritability()`](https://itchyshin.github.io/hsquared/reference/direct_maternal_extractors.md)
or
[`total_heritability()`](https://itchyshin.github.io/hsquared/reference/direct_maternal_extractors.md)
for targeted accessors without the warning.
