# Genomics, QTL, and CPU/GPU roadmap

This page is a roadmap, not an implemented-feature page.

`hsquared` is designed to grow from a simple animal-model interface into
a coherent modelling language for phenotypes, pedigrees, genotypes,
QTL/eQTL, G matrices, inheritance systems, and high-dimensional traits.

## Design principle

``` text
phenotype =
  fixed effects
  + pedigree/genetic effects
  + genomic marker effects
  + maternal/paternal effects
  + environment/common effects
  + latent multivariate factors
  + residual variation
```

The R package should keep this easy to say. The Julia package should
provide the performance-oriented engine, with speed and scale treated as
benchmarked claims rather than slogans.

## Planned genomic syntax

``` r

fit <- hsquared(
  y ~ sex + batch + genomic(1 | id, Ginv = Ginv),
  data = pheno,
  family = gaussian()
)
```

Marker and scan syntax is planned later:

``` r

fit <- hsquared(
  y ~ sex + age +
    genomic(1 | id, Ginv = Ginv) +
    marker_scan(M, map = marker_map, leave_one_chr_out = TRUE),
  data = pheno,
  genotypes = geno,
  family = gaussian()
)
```

## Planned backend strategy

CPU is the trusted default. GPU is an accelerator path that must be
benchmarkable and numerically checked.

Planned Julia backends:

- CPU and threaded CPU;
- CUDA for NVIDIA GPUs;
- Metal for Mac/Apple Silicon testing;
- AMDGPU for ROCm systems;
- oneAPI for Intel accelerators;
- portable kernels where appropriate.

## Evidence gate

The package will not claim ASReml-level performance, GPU speedup,
genomic support, QTL/eQTL support, or GLLVM support until code, tests,
docs, and validation evidence exist.
