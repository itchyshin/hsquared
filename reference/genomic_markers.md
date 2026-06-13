# Planned genomic and QTL formula markers

These functions reserve readable formula vocabulary for later genomic,
single-step, marker-effect, GWAS, and QTL/eQTL models. They are inert
syntax markers today. The v0.1 parser rejects them with a
planned-not-implemented message instead of silently treating them as
ordinary fixed effects.

## Usage

``` r
genomic(formula, G = NULL, Ginv = NULL, ...)

single_step(formula, H = NULL, Hinv = NULL, ...)

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
