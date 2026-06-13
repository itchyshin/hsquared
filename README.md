# hsquared

`hsquared` is the planned R interface for an open, Julia-backed
quantitative-genetic modelling system. The R package owns the applied-user
surface: formula syntax, data validation, summaries, extractors, examples, and
eventually the bridge to the `HSquared.jl` engine.

This repository has moved past the initial scaffold into early Phase 1 parser
and bridge-contract work. It can validate the narrow v0.1 formula contract and
build a tested internal R-to-Julia payload shape. Use `model_spec()` to preview
the parsed fixed-effect design, sparse animal-effect design, normalized
pedigree ordering, and Julia targets without fitting a model. The default call
validates and stops, while an experimental opt-in
`control = hs_control(engine = "julia")` path can send a tiny v0.1 payload to a
sibling `HSquared.jl` checkout through JuliaCall. This is still a narrow local
validation path, not general animal-model support. The same opt-in bridge can
also call `HSquared.jl::henderson_mme()` at explicitly supplied variance
components for tiny validation examples. That path does not estimate variance
components or provide a log-likelihood. When the sibling Julia checkout exposes
applicable dense validation extractors, the target also attaches PEV and
reliability fields. The fitted-object extractor contract now includes variance
components, heritability, EBVs/BLUPs, PEV, reliability, accuracy, fixed
effects, random effects, log-likelihood, AIC, prediction, fitted values,
residuals, and summaries. In the experimental local bridge, PEV/reliability
are enriched from exported `HSquared.jl` dense validation extractors when
available; this is still not production sparse reliability or general
animal-model support. A lightweight
`hs_data()` container now records phenotype, pedigree, genotype, expression,
marker, annotation, and environment inputs for future integrated workflows.
The package also reserves planned formula markers for genomic/QTL terms and
standard quantitative-genetic extensions such as permanent environment,
maternal/paternal effects, dominance, epistasis, cytoplasmic inheritance,
imprinting, and custom relationship or precision matrices. Those markers are
syntax reservations only and currently abort as planned, not implemented.
Use `formula_status()` to inspect the parsed, reserved, and planned formula
grammar from R. Output extractor names such as `qtl_table()`, `gwas_table()`,
`eqtl_table()`, `marker_effects()`, `marker_variance_explained()`, and
`lod_scores()` are also reserved for future fitted marker/QTL/eQTL results.

The intended two-package shape is:

```text
hsquared       R package: friendly modelling interface for applied users
HSquared.jl    Julia package: sparse quantitative-genetic engine
```

The first implementation target is a univariate Gaussian animal model:

```r
fit <- hsquared(
  y ~ sex + age + animal(1 | id, pedigree = ped),
  data = dat,
  family = gaussian(),
  REML = TRUE
)
```

That syntax is parsed and validated as the first contract. The R side now
constructs the intended `y`, `X`, sparse `Z`, method, family, ID, and normalized
pedigree metadata payload. With `control = hs_control(engine = "julia")`,
internal tests can send the sparse `Z` design through Julia CSC slots, build
Julia-side `Ainv`, and run the current validation target when a local sibling
`HSquared.jl` checkout is available. General public fitting waits for a
production bridge and validation-canon evidence.
For supplied-variance MME checks, use:

```r
fit_mme <- hsquared(
  y ~ sex + age + animal(1 | id, pedigree = ped),
  data = dat,
  family = gaussian(),
  REML = FALSE,
  control = hs_control(
    engine = "julia",
    engine_control = list(
      target = "henderson_mme",
      variance_components = c(sigma_a2 = 1.2, sigma_e2 = 0.8)
    )
  )
)
```

This is a validation bridge target with supplied variances, not an optimizer.
Current validation atoms include tiny deterministic `Ainv` checks, an optional
Mrode9/nadiv pedigree-Ainv comparator, and a supplied-variance Henderson MME
fixture that compares R reference fixed effects, EBVs, fitted values, h2, and
optional dense validation-path PEV/reliability with Julia when available. Use
`validation_status()` to inspect validation evidence and planned comparator
lanes from R.

```r
spec <- model_spec(
  y ~ sex + age + animal(1 | id, pedigree = ped),
  data = dat,
  family = gaussian()
)

summary(spec)
```

For integrated workflows, the same parser can read phenotypes and pedigree
from an `hs_data()` bundle:

```r
bundle <- hs_data(phenotypes = dat, pedigree = ped)
summary(bundle)
data_status(bundle)

spec <- model_spec(
  y ~ sex + age + animal(1 | id),
  data = bundle
)
```

Marker maps can also be checked in the same container:

```r
bundle <- hs_data(
  phenotypes = dat,
  pedigree = ped,
  genotypes = geno,
  markers = data.frame(
    marker = c("m1", "m2"),
    chr = c("1", "1"),
    pos = c(10, 20)
  )
)
```

The marker-map check is metadata validation only. Genomic and QTL/eQTL models
remain planned. `summary(bundle)` and `data_status(bundle)` report pedigree
coverage, founder and parent-link counts, marker-map size, genotype
marker-column count, chromosome count, coordinate range, and whether the
genotype-marker alignment was checked. When both `genotypes` and `markers` are
supplied, genotype marker column names must match marker-map IDs exactly.
The animal-model parser uses the bundle pedigree by default, so
`animal(1 | id)` is equivalent to spelling `animal(1 | id, pedigree = pedigree)`
for `data = bundle`.

The interface rule is deliberately simple: easy, easy, easy. Applied users are
gold; the package should make the common quantitative-genetic model feel
obvious before it exposes specialist machinery.

## Installation

```r
# install.packages("pak")
pak::pak("itchyshin/hsquared")
```

## Development

Run the local checks with:

```r
devtools::check()
```

The project operating system lives in:

- `AGENTS.md`
- `ROADMAP.md`
- `docs/design/`
- `docs/dev-log/`
- `.agents/skills/`

Repository memory is authoritative. Chat memory only points agents toward the
right files.
