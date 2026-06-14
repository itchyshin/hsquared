# Quantitative-genetic formula markers

These functions provide readable formula vocabulary for standard
quantitative-genetic, parental, inheritance, and custom-kernel models.
Called directly they are inert (they return `NULL`); they take meaning
only inside an
[`hsquared()`](https://itchyshin.github.io/hsquared/reference/hsquared.md)
formula. `permanent()`, `common_env()`, and `maternal_genetic()` now fit
through an opt-in, experimental engine path (`engine = "julia"`,
REML-only, not the default, mirroring a `partial` validation gate) as
the second random effect alongside
[`animal()`](https://itchyshin.github.io/hsquared/reference/animal.md).
The remaining markers (paternal/maternal-environment, dominance,
epistasis, cytoplasmic, imprinting, custom relationship/precision) are
still inert syntax reservations that the parser rejects with a
planned-not-implemented message.

## Usage

``` r
permanent(formula, ...)

common_env(formula, ...)

maternal_genetic(formula, pedigree = NULL, ...)

maternal_env(formula, ...)

paternal_genetic(formula, pedigree = NULL, ...)

paternal_env(formula, ...)

cytoplasmic(formula, ...)

imprinting(formula, pedigree = NULL, parent = c("maternal", "paternal"), ...)

dominance(formula, pedigree = NULL, D = NULL, Dinv = NULL, ...)

epistasis(formula, pedigree = NULL, E = NULL, Einv = NULL, ...)

relmat(formula, K = NULL, Kinv = NULL, Q = NULL, ...)

precision(formula, Q = NULL, ...)
```

## Arguments

- formula:

  A random-effect expression such as `1 | id`.

- ...:

  Reserved for future syntax.

- pedigree:

  A pedigree data frame for future parental and relationship effects.

- parent:

  Planned parent-of-origin side for imprinting effects.

- D, Dinv:

  Dominance relationship or precision matrices.

- E, Einv:

  Epistatic relationship or precision matrices.

- K, Kinv, Q:

  User-supplied relationship or precision matrices.

## Value

`NULL`, invisibly. Calls are interpreted by
[`hsquared()`](https://itchyshin.github.io/hsquared/reference/hsquared.md)
when they appear inside model formulas.
