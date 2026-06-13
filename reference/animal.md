# Animal-model formula marker

`animal()` marks an additive-genetic random effect in an
[`hsquared()`](https://itchyshin.github.io/hsquared/reference/hsquared.md)
formula. The first implemented parser contract accepts
`animal(1 | id, pedigree = ped)`, or `animal(1 | id)` when `data` is an
[`hs_data()`](https://itchyshin.github.io/hsquared/reference/hs_data.md)
object with a pedigree component. General fitting still waits for the
production Julia engine bridge, so this function is a syntax marker
rather than a standalone modelling helper.

## Usage

``` r
animal(formula, pedigree = NULL, ...)
```

## Arguments

- formula:

  A random-effect expression. The v0.1 parser accepts `1 | id`.

- pedigree:

  A pedigree data frame with individual, sire, and dam columns. Optional
  only when the enclosing
  [`hsquared()`](https://itchyshin.github.io/hsquared/reference/hsquared.md)
  or
  [`model_spec()`](https://itchyshin.github.io/hsquared/reference/model_spec.md)
  call uses `data = hs_data(..., pedigree = ...)`.

- ...:

  Reserved for future syntax such as `cov =`.

## Value

`NULL`, invisibly. The call is interpreted by
[`hsquared()`](https://itchyshin.github.io/hsquared/reference/hsquared.md)
when it appears inside a model formula.
