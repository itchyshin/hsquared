# hsquared

`hsquared` is the planned R interface for an open, Julia-backed
quantitative-genetic modelling system. The R package owns the applied-user
surface: formula syntax, data validation, summaries, extractors, examples, and
eventually the bridge to the `HSquared.jl` engine.

Version 0.1 fits the univariate Gaussian animal model
`y ~ fixed + animal(1 | id, pedigree = ped)` by REML through the `HSquared.jl`
engine. The default `hsquared()` call fits the model and returns heritability,
variance components, breeding values (EBVs/BLUPs), fixed effects, fitted values,
residuals, and diagnostics. Fitting requires a local Julia, the `JuliaCall`
package, and an `HSquared.jl` checkout; without them the default call errors with
install guidance, and `control = hs_control(engine = "validate")` validates the
contract without fitting. Use `model_spec()` to preview the parsed fixed-effect
design, sparse animal-effect design, normalized pedigree ordering, and Julia
targets without fitting.

The v0.1 fit is validated by known-truth recovery (a replicated DGP study in
which the engine recovers the generating variance components near-unbiased), by
the published gryphon REML estimate (Wilson et al. 2010, which the engine
recovers within the maintainer-signed-off comparator band), and by agreement
with the `sommer` package. The fitted-object
extractors — variance components, heritability, EBVs/BLUPs, PEV, reliability,
accuracy, fixed effects, random effects, log-likelihood, AIC, prediction, fitted
values, residuals, `summary()`, `coef()`, `nobs()`, and `fit_diagnostics()`
(including an `at_boundary` flag) — operate on the fitted object. Standard errors
and confidence intervals for variance components and heritability are out of v0.1
scope. The advanced `control = hs_control(engine = "julia")` path exposes
explicit engine targets (supplied-variance Henderson MME, sparse REML). A
lightweight `hs_data()` container now records phenotype, pedigree, genotype, expression,
marker, annotation, and environment inputs for future integrated workflows,
including optional expression-feature annotation diagnostics through
`annotation_id` and environment-key diagnostics through `environment_id`.
The package also provides readable formula vocabulary for genomic/QTL terms and
standard quantitative-genetic extensions. Several now fit through an opt-in,
experimental engine path (`engine = "julia"`, REML-only or supplied-variance,
not the default, each mirroring a `partial` validation gate): permanent
environment, common environment, maternal-genetic, genomic (GREML or SNP-BLUP),
single-step effects, and the multivariate Gaussian animal model via a `cbind()`
response. The rest — paternal effects, dominance, epistasis, cytoplasmic
inheritance, imprinting, custom relationship or precision matrices, and
marker/QTL scans — are syntax reservations only and currently abort as planned,
not implemented.
Use `formula_status()` to inspect the parsed, reserved, and planned formula
grammar from R. Output extractor names such as `qtl_table()`, `gwas_table()`,
`eqtl_table()`, `marker_variance_explained()`, and `lod_scores()` are reserved
for future fitted marker/QTL/eQTL results; `marker_effects()` is live for the
opt-in SNP-BLUP path.

The intended two-package shape is:

```text
hsquared       R package: friendly modelling interface for applied users
HSquared.jl    Julia package: sparse quantitative-genetic engine
```

The v0.1 fit is the univariate Gaussian animal model:

```r
fit <- hsquared(
  y ~ sex + age + animal(1 | id, pedigree = ped),
  data = dat,
  family = gaussian(),
  REML = TRUE
)
```

This fits by default: the R side builds the `y`, `X`, sparse `Z`, and normalized
pedigree payload, the `HSquared.jl` engine builds `Ainv`, estimates the variance
components by REML, and returns an `hsquared_fit` object. A genomic GREML /
SNP-BLUP effect, single-step, and the multivariate Gaussian animal model also
fit through the opt-in, experimental `engine = "julia"` path (not the default);
factor-analytic and non-Gaussian models remain planned.
For the multivariate Gaussian path, use:

```r
fit_mv <- hsquared(
  cbind(weight, height) ~ sex + animal(1 | id, pedigree = ped),
  data = dat,
  family = gaussian(),
  REML = TRUE,
  control = hs_control(
    engine = "julia",
    engine_control = list(target = "multivariate")
  )
)

genetic_covariance(fit_mv)
genetic_correlation(fit_mv)
heritability(fit_mv)
breeding_values(fit_mv)
```

This multivariate path is REML-only, animal-model-only, dense validation-scale,
and `partial`: it returns G/R covariance and correlation matrices, per-trait
h2, and cross-trait EBVs, but it is not yet an ASReml-style production
multi-trait claim or a t>=2 known-truth recovery claim.
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
Mrode9/nadiv pedigree-Ainv comparator, a supplied-variance Henderson MME
fixture that compares R reference fixed effects, EBVs, fitted values, h2, and
optional dense validation-path PEV/reliability with Julia when available, and a
Mrode-style supplied-variance output fixture that pins Ainv, fixed effects,
EBVs, fitted values, PEV, reliability, h2, ML log-likelihood, and dense/sparse
REML log-likelihood. Optional local tests also compare Julia dense REML and
sparse REML likelihood evaluators on a tiny supplied-variance three-founder
fixture. All of these are tiny supplied-variance or deterministic validation
fixtures — they check the engine arithmetic, not estimation, and are not
reachable from the default call. Use `validation_status()` to inspect validation
evidence and planned comparator lanes from R.

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

Expression feature annotations and environment metadata can also be checked
without fitting eQTL, omics, or environmental models:

```r
bundle <- hs_data(
  phenotypes = dat,
  expression = expr,
  annotation = genes,
  annotation_id = "gene_id"
)
```

```r
bundle <- hs_data(
  phenotypes = dat,
  pedigree = ped,
  environment = env,
  environment_id = "site"
)
```

The expression-feature, genotype-column, marker-map, annotation-feature, and
environment-key checks are metadata validation only. Genomic, QTL/eQTL, omics, and
environment-effect models remain planned.
`summary(bundle)` and `data_status(bundle)` report pedigree coverage, founder
and parent-link counts, marker-map size, genotype marker-column count,
missing genotype value counts, unnamed or duplicate genotype marker columns,
chromosome count, coordinate range, whether the genotype-marker alignment was
checked, expression row and feature counts, unnamed or duplicate expression
features, expression-feature annotation coverage when `annotation_id` is
supplied, and environment metadata coverage when `environment_id` is supplied.
When both `genotypes` and `markers` are supplied, genotype marker column names
must match marker-map IDs exactly.
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

Fitting also needs a local [Julia](https://julialang.org/), the
[`JuliaCall`](https://cran.r-project.org/package=JuliaCall) R package, and a
local [`HSquared.jl`](https://github.com/itchyshin/HSquared.jl) checkout (the
engine that performs the fit). Without them, `hsquared()` still parses and
validates the model — `control = hs_control(engine = "validate")` — but the
default fit call errors with install guidance.

### Engine setup

`HSquared.jl` is a from-source Julia checkout, not a package-managed
dependency: `pak::pak("itchyshin/hsquared")` installs the R package only. To
reach a working fit:

1. Install [Julia](https://julialang.org/downloads/) and the bridge R package:

   ```r
   install.packages("JuliaCall")
   ```

2. Clone the engine to a local directory:

   ```sh
   git clone https://github.com/itchyshin/HSquared.jl
   ```

3. Tell `hsquared` where the checkout lives, in one of two ways:

   ```r
   # (a) for the session, or persistently via .Renviron
   Sys.setenv(HSQUARED_JULIA_PROJECT = "/path/to/HSquared.jl")

   # (b) per call
   fit <- hsquared(
     y ~ sex + age + animal(1 | id, pedigree = ped),
     data = dat,
     control = hs_control(
       engine_control = list(julia_project = "/path/to/HSquared.jl")
     )
   )
   ```

Until the engine is registered, `control = hs_control(engine = "validate")`
parses and validates the model without fitting.

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
