# Inspect hsquared data-container status

`data_status()` gives a direct user-facing view of the checks stored in
an
[`hs_data()`](https://itchyshin.github.io/hsquared/reference/hs_data.md)
object. It reports component presence, ID overlap diagnostics, pedigree
diagnostics, expression-feature diagnostics, and marker-map/
genotype-marker alignment diagnostics when those inputs are supplied.
When `annotation_id` is supplied, it reports expression-feature
annotation coverage diagnostics. When `environment_id` is supplied, it
also reports environment metadata coverage diagnostics. It does not fit
models, build genomic relationship matrices, add eQTL terms, or add
environment-effect terms.

## Usage

``` r
data_status(data)
```

## Arguments

- data:

  An
  [`hs_data()`](https://itchyshin.github.io/hsquared/reference/hs_data.md)
  object.

## Value

An `"hs_data_status"` object.
