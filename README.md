# hsquared

`hsquared` is the planned R interface for an open, Julia-backed
quantitative-genetic modelling system. The R package owns the applied-user
surface: formula syntax, data validation, summaries, extractors, examples, and
eventually the bridge to the `HSquared.jl` engine.

This repository has moved past the initial scaffold into early Phase 1 parser
and bridge-contract work. It can validate the narrow v0.1 formula contract and
build a tested internal R-to-Julia payload shape, but it does not execute Julia
or fit animal models yet. The first fitted-object and extractor methods are
also defined over an internal `hsquared_fit` contract, ready for the Julia
result once fitting exists. A lightweight `hs_data()` container now records
phenotype, pedigree, genotype, expression, marker, annotation, and environment
inputs for future integrated workflows.

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
pedigree metadata payload. Fitting waits for Julia-side `Ainv` construction,
bridge execution, and the Gaussian animal-model solver.

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
