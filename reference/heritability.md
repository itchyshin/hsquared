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
