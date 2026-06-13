# Fit a quantitative-genetic model

`hsquared()` is the R entry point for heritability, breeding-value,
G-matrix, and inheritance-structured mixed models. v0.1 fits the
univariate Gaussian animal model
`y ~ fixed + animal(1 | id, pedigree = ped)` by REML through the
`HSquared.jl` engine. The default `control` fits when a local Julia and
`HSquared.jl` are available and otherwise errors with install guidance;
`hs_control(engine = "validate")` validates the contract without
fitting. Multivariate, genomic, and non-Gaussian models remain planned.

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

  Logical; whether to use REML estimation. The v0.1 fit path supports
  REML only (the default, `TRUE`); `REML = FALSE` (ML) is not yet
  implemented and is rejected with an error.

- control:

  An object created by
  [`hs_control()`](https://itchyshin.github.io/hsquared/reference/hs_control.md).

- ...:

  Reserved for future arguments.

## Value

A `"hsquared_fit"` object from the fitted v0.1 Gaussian animal model, or
an informative error when the Julia engine is unavailable or
`engine = "validate"` is used.
