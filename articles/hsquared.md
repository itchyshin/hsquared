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

Current status: this formula is parsed and validated, and the R side
builds the first tested internal bridge payload. Model fitting and live
Julia execution are not implemented yet. The package stops at the
planned Julia bridge boundary. The first extractor functions exist for
future `hsquared_fit` objects, but
[`hsquared()`](https://itchyshin.github.io/hsquared/reference/hsquared.md)
does not return fitted objects yet.
[`hs_data()`](https://itchyshin.github.io/hsquared/reference/hs_data.md)
can collect phenotype, pedigree, genotype, marker, expression,
annotation, and environment inputs into a checked container for future
integrated workflows.

The interface rule is: easy, easy, easy. Users are gold. The common
animal model should be obvious before the package exposes genomic,
multivariate, factor-analytic, non-Gaussian, or unusual-inheritance
machinery.

## Current parser contract

The parser currently accepts:

- one
  [`animal()`](https://itchyshin.github.io/hsquared/reference/animal.md)
  term;
- random-intercept syntax: `1 | id`;
- `pedigree = ped`;
- numeric Gaussian responses.

Unsupported syntax is still important because it defines the roadmap.
Terms such as `cov = fa(K = 2)`, `genomic()`, `single_step()`, QTL
effects, selfing, polyploidy, haplodiploidy, and GLLVM-style latent
genetic axes are planned lanes, not current fitting features.

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
