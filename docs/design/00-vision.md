# Vision

`hsquared` is an open, sparse, inheritance-aware quantitative-genetic modelling
system for R and Julia.

The R package gives applied users a friendly formula interface for
heritability, breeding values, G matrices, and inheritance-structured mixed
models. `HSquared.jl` provides the sparse precision engine for pedigree,
genomic, and high-dimensional quantitative-genetic computation.

## Niche

The project aims for:

```text
ASReml-style animal-model capability
+ MCMCglmm-like biological flexibility
+ brms/drmTMB-like syntax
+ Julia sparse precision computation
+ GLLVM-style high-dimensional G-matrix modelling
+ unusual inheritance systems
+ open community software
```

This should not be presented as a general mixed-model package. It is a
specialized quantitative-genetic package.

## Current Status

Phase 0 scaffold. No model fitting is implemented in the R package yet.

## First Capability Target

The first working slice should be a simple Gaussian animal model with sparse
pedigree precision:

```r
hsquared(y ~ sex + age + animal(1 | id, pedigree = ped),
  data = dat,
  family = gaussian(),
  REML = TRUE
)
```
