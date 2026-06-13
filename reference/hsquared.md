# Fit a quantitative-genetic model

`hsquared()` is the planned R entry point for heritability,
breeding-value, G-matrix, and inheritance-structured mixed models. The
current parser validates the narrow v0.1 animal-model contract and stops
before fitting.

## Usage

``` r
hsquared(
  formula,
  data,
  family = stats::gaussian(),
  REML = TRUE,
  control = hs_control(),
  ...
)
```

## Arguments

- formula:

  A model formula. The first planned v0.1 syntax is
  `y ~ fixed + animal(1 | id, pedigree = ped)`.

- data:

  A data frame containing model variables.

- family:

  A response family. The v0.1 parser accepts only
  [`gaussian()`](https://rdrr.io/r/stats/family.html).

- REML:

  Logical; whether the planned Gaussian animal model should use REML.
  This is recorded for the future v0.1 contract only.

- control:

  An object created by
  [`hs_control()`](https://itchyshin.github.io/hsquared/reference/hs_control.md).

- ...:

  Reserved for future arguments.

## Value

The current scaffold always errors before returning a fit.
