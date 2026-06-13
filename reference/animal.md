# Animal-model formula marker

`animal()` marks an additive-genetic random effect in an
[`hsquared()`](https://itchyshin.github.io/hsquared/reference/hsquared.md)
formula. The first implemented parser contract accepts only
`animal(1 | id, pedigree = ped)`. Fitting still waits for the Julia
engine bridge, so this function is a syntax marker rather than a
standalone modelling helper.

## Usage

``` r
animal(formula, pedigree, ...)
```

## Arguments

- formula:

  A random-effect expression. The v0.1 parser accepts `1 | id`.

- pedigree:

  A pedigree data frame with individual, sire, and dam columns.

- ...:

  Reserved for future syntax such as `cov =`.

## Value

`NULL`, invisibly. The call is interpreted by
[`hsquared()`](https://itchyshin.github.io/hsquared/reference/hsquared.md)
when it appears inside a model formula.
