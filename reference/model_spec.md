# Inspect a parsed hsquared model specification

`model_spec()` validates the narrow v0.1 animal-model grammar and
returns the R-side model specification that would be used to build the
Julia bridge payload. It is a preview and diagnostics helper: it does
not fit a model.

## Usage

``` r
model_spec(formula, data, family = stats::gaussian(), REML = TRUE, ...)
```

## Arguments

- formula:

  A model formula. The current implemented grammar is
  `y ~ fixed + animal(1 | id, pedigree = ped)`.

- data:

  A data frame containing model variables, or an
  [`hs_data()`](https://itchyshin.github.io/hsquared/reference/hs_data.md)
  object whose `phenotypes` component contains the model variables. When
  `data` is an `hs_data` object, formula arguments such as
  `pedigree = pedigree` can refer to named components in the bundle.

- family:

  A response family. The current parser accepts only
  [`gaussian()`](https://rdrr.io/r/stats/family.html).

- REML:

  Logical; whether the target Gaussian animal model would use REML.

- ...:

  Reserved for future arguments.

## Value

An `"hs_model_spec"` object.
