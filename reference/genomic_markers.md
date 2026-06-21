# Genomic and QTL formula markers

These functions provide readable formula vocabulary for genomic,
single-step, marker-effect, GWAS, and QTL/eQTL models. Called directly
they are inert (they return `NULL`); they take meaning only inside an
[`hsquared()`](https://itchyshin.github.io/hsquared/reference/hsquared.md)
formula. `genomic()` and `single_step()` now fit through an opt-in,
experimental engine path (`engine = "julia"`, REML-only or
supplied-variance, not the default, mirroring a `partial` validation
gate): `genomic(1 | id, Ginv = Ginv)` or `genomic(1 | id, markers = M)`
(GREML, or SNP-BLUP via `target = "snp_blup"`), and
`single_step(1 | id, Hinv = Hinv)` (a precomputed inverse) or
`single_step(1 | id, pedigree = ped, markers = M)` (the engine
constructs `H^-1` from the pedigree + genotyped-subset markers via
`target = "single_step_construct"`). Adding `group` plus supplied
`Gamma` validates a contract-only `H^Gamma` payload gate for the future
`target = "metafounder_single_step"` path; the live Julia fit is not
wired yet. When `data` is an
[`hs_data()`](https://itchyshin.github.io/hsquared/reference/hs_data.md)
container that bundles a pedigree and genotypes, `single_step(1 | id)`
resolves both from the bundle (the `animal(1 | id)` precedent), so
neither `pedigree =` nor `markers =` is required; explicit arguments
override the bundle. The remaining markers (`markers()`,
`marker_scan()`, `qtl_scan()`) are still inert syntax reservations that
the parser rejects with a planned-not-implemented message.

## Usage

``` r
genomic(formula, G = NULL, Ginv = NULL, ...)

single_step(
  formula,
  H = NULL,
  Hinv = NULL,
  pedigree = NULL,
  markers = NULL,
  group = NULL,
  Gamma = NULL,
  tau = 1,
  omega = 1,
  blend_weight = 0,
  ridge = 0,
  ...
)

markers(M, model = c("random", "fixed", "scan"), ...)

marker_scan(M, map = NULL, ...)

qtl_scan(position, genotype_probs = NULL, ...)
```

## Arguments

- formula:

  A random-effect expression such as `1 | id`.

- G, Ginv, H, Hinv:

  Relationship or precision matrices for future genomic and single-step
  models.

- ...:

  Reserved for future syntax.

- pedigree:

  A pedigree data frame (`id`, `sire`, `dam`) for the single-step `H^-1`
  *construction* path
  (`single_step(1 | id, pedigree = ped, markers = M)`), in place of a
  precomputed `Hinv`.

- markers:

  A genotyped-subset marker matrix (rows named by genotyped id) for the
  single-step construction path; the engine builds the genomic
  relationship from it.

- group:

  Animal-to-metafounder group labels for the future `H^Gamma`
  single-step path; must be supplied together with `Gamma`.

- Gamma:

  A supplied metafounder relationship matrix for the future `H^Gamma`
  single-step path; supplied, not estimated, and must be supplied
  together with `group`.

- tau, omega, blend_weight, ridge:

  Single-step construction tuning knobs (Aguilar et al. 2010); defaults
  `tau = omega = 1`, `blend_weight = ridge = 0`.

- M:

  A marker or dosage matrix for future marker-effect and scan models.

- model:

  Planned marker-effect mode.

- map:

  A marker map for future marker scans.

- position:

  A chromosome-position table or variable for future QTL scans.

- genotype_probs:

  Genotype probabilities for future interval/QTL scans.

## Value

`NULL`, invisibly. Calls are interpreted by
[`hsquared()`](https://itchyshin.github.io/hsquared/reference/hsquared.md)
when they appear inside model formulas.
