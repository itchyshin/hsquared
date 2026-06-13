# Planned quantitative-genetic formula markers

These functions reserve readable formula vocabulary for later standard
quantitative-genetic, parental, inheritance, and custom-kernel models.
They are inert syntax markers today. The current parser rejects them
with a planned-not-implemented message instead of treating them as
ordinary fixed effects.

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
