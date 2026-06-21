# Extract supplied metafounder group assignments

`metafounder_groups()` returns the ID-keyed metafounder group
assignments carried by an experimental metafounder or `H^Gamma`
single-step `hsquared_fit` object. These assignments are provenance for
the supplied relationship, not estimated grouping parameters.

## Usage

``` r
metafounder_groups(object, ...)
```

## Arguments

- object:

  A fitted model object.

- ...:

  Reserved for future arguments.

## Value

A data frame with columns `id`, `metafounder_group`, and
`is_metafounder`.
