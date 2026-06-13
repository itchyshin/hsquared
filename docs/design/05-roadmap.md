# Detailed Roadmap

See `ROADMAP.md` for the public phase dashboard. This document records the
technical intent behind those phases.

## Phase 0

Install team memory, local skills, GitHub issues, CI, and honest placeholders.

## Phase 1

Implement sparse pedigree Ainv and the univariate Gaussian animal model.

## Phase 2

Add repeatability, permanent environment, maternal/common environment, sire
models, groups, inbreeding, and a first random-regression slice.

## Phase 3

Add long-format multivariate Gaussian animal models with full G and R matrices.

## Phase 4

Add factor-analytic G matrices:

```text
diag()
lowrank(K)
fa(K) = Lambda Lambda' + Psi
```

## Phase 5

Add genomic and single-step models: GBLUP, SNP-BLUP, HBLUP, APY, Ginv, Hinv.

## Phase 6

Add non-Gaussian and GLLVM-style animal models.

## Phase 7

Add non-standard inheritance: selfing, clonal, haplodiploid, polyploid,
cytoplasmic, dominance, epistasis, and custom kernels.

## Phase 8

Add huge-scale and accelerator-aware workflows only after CPU sparse paths are
credible.
