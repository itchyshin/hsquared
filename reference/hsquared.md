# Fit a quantitative-genetic model

`hsquared()` is the planned R entry point for heritability,
breeding-value, G-matrix, and inheritance-structured mixed models. The
current parser validates the narrow v0.1 animal-model contract. The
default control path stops after validation; the experimental Julia
engine can fit tiny local bridge examples when a sibling `HSquared.jl`
checkout is available.

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
  `y ~ fixed + animal(1 | id, pedigree = ped)`, with `animal(1 | id)`
  also accepted when `data` is an
  [`hs_data()`](https://itchyshin.github.io/hsquared/reference/hs_data.md)
  object with a pedigree component.

- data:

  A data frame containing model variables, or an
  [`hs_data()`](https://itchyshin.github.io/hsquared/reference/hs_data.md)
  object whose `phenotypes` component contains the model variables. When
  `data` is an `hs_data` object, formula arguments such as
  `pedigree = pedigree` can refer to named components in the bundle, and
  `animal(1 | id)` uses the bundle pedigree by default.

- family:

  A response family. The v0.1 parser accepts only
  [`gaussian()`](https://rdrr.io/r/stats/family.html).

- REML:

  Logical; whether the Gaussian animal model should use REML when the
  experimental Julia engine is selected.

- control:

  An object created by
  [`hs_control()`](https://itchyshin.github.io/hsquared/reference/hs_control.md).

- ...:

  Reserved for future arguments.

## Value

A `"hsquared_fit"` object for the experimental Julia engine, or an
informative error for the default validation-only path.
