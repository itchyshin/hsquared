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

  A data frame containing model variables.

- family:

  A response family. The current parser accepts only
  [`gaussian()`](https://rdrr.io/r/stats/family.html).

- REML:

  Logical; whether the target Gaussian animal model would use REML.

- ...:

  Reserved for future arguments.

## Value

An `"hs_model_spec"` object.
