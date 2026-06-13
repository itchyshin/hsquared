# hsquared

`hsquared` is the planned R interface for an open, Julia-backed
quantitative-genetic modelling system. The R package owns the
applied-user surface: formula syntax, data validation, summaries,
extractors, examples, and eventually the bridge to the `HSquared.jl`
engine.

This repository has moved past the initial scaffold into early Phase 1
parser and bridge-contract work. It can validate the narrow v0.1 formula
contract and build a tested internal R-to-Julia payload shape. Use
[`model_spec()`](https://itchyshin.github.io/hsquared/reference/model_spec.md)
to preview the parsed fixed-effect design, sparse animal-effect design,
normalized pedigree ordering, and Julia targets without fitting a model.
The default call validates and stops, while an experimental opt-in
`control = hs_control(engine = "julia")` path can send a tiny v0.1
payload to a sibling `HSquared.jl` checkout through JuliaCall. This is
still a narrow local validation path, not general animal-model support.
The same opt-in bridge can also call `HSquared.jl::henderson_mme()` at
explicitly supplied variance components for tiny validation examples.
That path does not estimate variance components or provide a
log-likelihood. When the sibling Julia checkout exposes applicable dense
validation extractors, the target also attaches PEV and reliability
fields. The fitted-object extractor contract now includes variance
components, heritability, EBVs/BLUPs, PEV, reliability, accuracy, fixed
effects, random effects, log-likelihood, AIC, prediction, fitted values,
residuals, summaries, [`coef()`](https://rdrr.io/r/stats/coef.html),
[`nobs()`](https://rdrr.io/r/stats/nobs.html), and
[`fit_diagnostics()`](https://itchyshin.github.io/hsquared/reference/fit_diagnostics.md)
for convergence and optimizer metadata. In the experimental local
bridge, PEV/reliability are enriched from exported `HSquared.jl` dense
validation extractors when available; this is still not production
sparse reliability or general animal-model support. A lightweight
[`hs_data()`](https://itchyshin.github.io/hsquared/reference/hs_data.md)
container now records phenotype, pedigree, genotype, expression, marker,
annotation, and environment inputs for future integrated workflows,
including optional expression-feature annotation diagnostics through
`annotation_id` and environment-key diagnostics through
`environment_id`. The package also reserves planned formula markers for
genomic/QTL terms and standard quantitative-genetic extensions such as
permanent environment, maternal/paternal effects, dominance, epistasis,
cytoplasmic inheritance, imprinting, and custom relationship or
precision matrices. Those markers are syntax reservations only and
currently abort as planned, not implemented. Use
[`formula_status()`](https://itchyshin.github.io/hsquared/reference/formula_status.md)
to inspect the parsed, reserved, and planned formula grammar from R.
Output extractor names such as
[`qtl_table()`](https://itchyshin.github.io/hsquared/reference/marker_extractors.md),
[`gwas_table()`](https://itchyshin.github.io/hsquared/reference/marker_extractors.md),
[`eqtl_table()`](https://itchyshin.github.io/hsquared/reference/marker_extractors.md),
[`marker_effects()`](https://itchyshin.github.io/hsquared/reference/marker_extractors.md),
[`marker_variance_explained()`](https://itchyshin.github.io/hsquared/reference/marker_extractors.md),
and
[`lod_scores()`](https://itchyshin.github.io/hsquared/reference/marker_extractors.md)
are also reserved for future fitted marker/QTL/eQTL results.

The intended two-package shape is:

``` text
hsquared       R package: friendly modelling interface for applied users
HSquared.jl    Julia package: sparse quantitative-genetic engine
```

The first implementation target is a univariate Gaussian animal model:

``` r

fit <- hsquared(
  y ~ sex + age + animal(1 | id, pedigree = ped),
  data = dat,
  family = gaussian(),
  REML = TRUE
)
```

That syntax is parsed and validated as the first contract. The R side
now constructs the intended `y`, `X`, sparse `Z`, method, family, ID,
and normalized pedigree metadata payload. With
`control = hs_control(engine = "julia")`, internal tests can send the
sparse `Z` design through Julia CSC slots, build Julia-side `Ainv`, and
run the current validation target when a local sibling `HSquared.jl`
checkout is available. General public fitting waits for a production
bridge and validation-canon evidence. For supplied-variance MME checks,
use:

``` r

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

This is a validation bridge target with supplied variances, not an
optimizer. Current validation atoms include tiny deterministic `Ainv`
checks, an optional Mrode9/nadiv pedigree-Ainv comparator, and a
supplied-variance Henderson MME fixture that compares R reference fixed
effects, EBVs, fitted values, h2, and optional dense validation-path
PEV/reliability with Julia when available. Use
[`validation_status()`](https://itchyshin.github.io/hsquared/reference/validation_status.md)
to inspect validation evidence and planned comparator lanes from R.

``` r

spec <- model_spec(
  y ~ sex + age + animal(1 | id, pedigree = ped),
  data = dat,
  family = gaussian()
)

summary(spec)
```

For integrated workflows, the same parser can read phenotypes and
pedigree from an
[`hs_data()`](https://itchyshin.github.io/hsquared/reference/hs_data.md)
bundle:

``` r

bundle <- hs_data(phenotypes = dat, pedigree = ped)
summary(bundle)
data_status(bundle)

spec <- model_spec(
  y ~ sex + age + animal(1 | id),
  data = bundle
)
```

Marker maps can also be checked in the same container:

``` r

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

Expression feature annotations and environment metadata can also be
checked without fitting eQTL, omics, or environmental models:

``` r

bundle <- hs_data(
  phenotypes = dat,
  expression = expr,
  annotation = genes,
  annotation_id = "gene_id"
)
```

``` r

bundle <- hs_data(
  phenotypes = dat,
  pedigree = ped,
  environment = env,
  environment_id = "site"
)
```

The expression-feature, genotype-column, marker-map, annotation-feature,
and environment-key checks are metadata validation only. Genomic,
QTL/eQTL, omics, and environment-effect models remain planned.
`summary(bundle)` and `data_status(bundle)` report pedigree coverage,
founder and parent-link counts, marker-map size, genotype marker-column
count, missing genotype value counts, unnamed or duplicate genotype
marker columns, chromosome count, coordinate range, whether the
genotype-marker alignment was checked, expression row and feature
counts, unnamed or duplicate expression features, expression-feature
annotation coverage when `annotation_id` is supplied, and environment
metadata coverage when `environment_id` is supplied. When both
`genotypes` and `markers` are supplied, genotype marker column names
must match marker-map IDs exactly. The animal-model parser uses the
bundle pedigree by default, so `animal(1 | id)` is equivalent to
spelling `animal(1 | id, pedigree = pedigree)` for `data = bundle`.

The interface rule is deliberately simple: easy, easy, easy. Applied
users are gold; the package should make the common quantitative-genetic
model feel obvious before it exposes specialist machinery.

## Installation

``` r

# install.packages("pak")
pak::pak("itchyshin/hsquared")
```

## Development

Run the local checks with:

``` r

devtools::check()
```

The project operating system lives in:

- `AGENTS.md`
- `ROADMAP.md`
- `docs/design/`
- `docs/dev-log/`
- `.agents/skills/`

Repository memory is authoritative. Chat memory only points agents
toward the right files.
