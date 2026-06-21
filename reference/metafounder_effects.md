# Reserved metafounder effect extractor

`metafounder_effects()` reserves the extractor name for future fitted
metafounder solutions. Current experimental metafounder and `H^Gamma`
fits expose supplied `Gamma` and group-assignment provenance via
[`gamma_matrix()`](https://itchyshin.github.io/hsquared/reference/gamma_matrix.md)
and
[`metafounder_groups()`](https://itchyshin.github.io/hsquared/reference/metafounder_groups.md),
but the engine does not yet return explicit combined-system metafounder
effects for extraction.

## Usage

``` r
metafounder_effects(object, ...)
```

## Arguments

- object:

  A fitted model object.

- ...:

  Reserved for future arguments.

## Value

This extractor currently errors for all objects.
