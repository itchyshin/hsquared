# Getting started with hsquared

`hsquared` is the R-facing package for an open quantitative-genetic
modelling system. Its partner package, `HSquared.jl`, owns the sparse
Julia engine.

The first user contract is intentionally simple:

``` r

fit <- hsquared(
  y ~ sex + age + animal(1 | id, pedigree = ped),
  data = dat,
  family = gaussian(),
  REML = TRUE
)
```

Current status: v0.1 **fits** this model.
[`hsquared()`](https://itchyshin.github.io/hsquared/reference/hsquared.md)
parses and validates the formula, marshals the model to the
`HSquared.jl` engine, and returns a fitted `hsquared_fit` object
carrying heritability, variance components, breeding values
(EBVs/BLUPs), fixed effects, fitted values, residuals, and diagnostics,
estimated by REML (average-information). Fitting is computed in
`HSquared.jl`, so it needs a local Julia, the `JuliaCall` R package, and
an `HSquared.jl` checkout; without them the default call errors with
install guidance, and `control = hs_control(engine = "validate")`
validates the contract without fitting. ML is not implemented —
`REML = FALSE` is rejected on the fit path. The fit is validated by
known-truth recovery, the published gryphon REML anchor, and agreement
with the `sommer` package.
[`hs_data()`](https://itchyshin.github.io/hsquared/reference/hs_data.md)
can collect phenotype, pedigree, genotype, marker, expression,
annotation, and environment inputs into a checked container for future
integrated workflows.

The interface rule is: easy, easy, easy. Users are gold. The common
animal model should be obvious before users reach for genomic,
multivariate, factor-analytic, non-Gaussian, or unusual-inheritance
machinery.

## Engine setup

Installing `hsquared` (`pak::pak("itchyshin/hsquared")`) gives you the R
interface; it does not install the engine. `HSquared.jl` is a
from-source Julia checkout, not a package-managed dependency. Install
[Julia](https://julialang.org/downloads/) and the `JuliaCall` R package,
clone the engine (`git clone https://github.com/itchyshin/HSquared.jl`),
then register the checkout in one of two ways:

``` r

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

Until the engine is registered,
`control = hs_control(engine = "validate")` parses and validates the
model without fitting.

## Current parser contract

The parser currently accepts:

- one
  [`animal()`](https://itchyshin.github.io/hsquared/reference/animal.md)
  term;
- random-intercept syntax: `1 | id`;
- `pedigree = ped`, or `animal(1 | id)` when `data` is an
  [`hs_data()`](https://itchyshin.github.io/hsquared/reference/hs_data.md)
  bundle with a pedigree component;
- numeric Gaussian responses.

Several terms beyond the default contract now fit through an opt-in,
experimental engine path (`engine = "julia"`, not the default, each
mirroring a `partial` validation gate):
[`permanent()`](https://itchyshin.github.io/hsquared/reference/qg_effect_markers.md),
[`common_env()`](https://itchyshin.github.io/hsquared/reference/qg_effect_markers.md),
[`maternal_genetic()`](https://itchyshin.github.io/hsquared/reference/qg_effect_markers.md),
[`genomic()`](https://itchyshin.github.io/hsquared/reference/genomic_markers.md)
(GREML or SNP-BLUP), and
[`single_step()`](https://itchyshin.github.io/hsquared/reference/genomic_markers.md).
See the “Fitting models” article for the opt-in calls.

The remaining grammar is still important because it defines the roadmap.
Terms such as `cov = fa(K = 2)`, QTL effects,
[`paternal_genetic()`](https://itchyshin.github.io/hsquared/reference/qg_effect_markers.md),
[`dominance()`](https://itchyshin.github.io/hsquared/reference/qg_effect_markers.md),
[`epistasis()`](https://itchyshin.github.io/hsquared/reference/qg_effect_markers.md),
[`relmat()`](https://itchyshin.github.io/hsquared/reference/qg_effect_markers.md),
[`precision()`](https://itchyshin.github.io/hsquared/reference/qg_effect_markers.md),
selfing, polyploidy, haplodiploidy, and GLLVM-style latent genetic axes
are planned lanes, not current fitting features.

## Twin-package flow

The intended flow is:

``` text
R formula + data
-> R validation and model specification
-> R bridge payload: y, X, sparse Z, method, IDs, pedigree metadata
-> HSquared.jl sparse engine
-> compact result
-> hsquared_fit object
-> R summaries, extractors, plots, and diagnostics
```

R owns the friendly interface. Julia owns speed, sparse computation, and
experimental engine work.
