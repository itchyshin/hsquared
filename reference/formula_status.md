# Inspect formula grammar status

`formula_status()` reports which pieces of the planned
[`hsquared()`](https://itchyshin.github.io/hsquared/reference/hsquared.md)
formula language are parsed today, reserved as syntax markers, or still
roadmap-only. It is a status table, not a model-fitting helper.

## Usage

``` r
formula_status()
```

## Value

A data frame of formula grammar records with class
`"hs_formula_status"`.
