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
epistasis, cytoplasmic, imprinting, custom relationship/precision,
genetic groups / unknown-parent-groups, metafounders, and inbreeding)
are still inert syntax reservations that the parser rejects with a
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

group(formula, ...)

unknown_parent_group(formula, ...)

metafounder(formula, pedigree = NULL, group = NULL, Gamma = NULL, ...)

inbreeding(formula, ...)
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

- group:

  Planned animal-to-metafounder group assignment, aligned to the
  normalized pedigree IDs; reserved for the planned `metafounder()`
  bridge.

- Gamma:

  A supplied metafounder relationship matrix (an `m`-by-`m` covariance
  over the `m` metafounder pseudo-populations; Legarra et al. 2015).
  Supplied, not estimated; reserved for the planned `metafounder()`
  bridge.

## Value

`NULL`, invisibly. Calls are interpreted by
[`hsquared()`](https://itchyshin.github.io/hsquared/reference/hsquared.md)
when they appear inside model formulas.

## Details

Some markers use generic names (e.g. `group()`, `inbreeding()`). They
are formula-only tokens detected by call head and are not meant to be
called directly, so attaching `hsquared` alongside a package that
exports a same-named function (e.g.
[`pedigreemm::inbreeding()`](https://rdrr.io/pkg/pedigreemm/man/inbreeding.html))
may print a masking message; this is expected and harmless.
