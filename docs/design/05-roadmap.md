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

Surface the first multivariate Gaussian animal model through a simple
`cbind(...)` response and opt-in `target = "multivariate"` bridge. Long-format
`trait` grammar, structured G/R matrices, and promotion beyond `partial` require
the later recovery/comparator gates.

## Phase 4

Add factor-analytic G matrices:

```text
diag()
lowrank(K)
fa(K) = Lambda Lambda' + Psi
```

The production sparse path for multivariate and factor-analytic G matrices is
tracked in `docs/design/13-sparse-multivariate-production-plan.md`. Current
Phase 4 / 4B surfaces remain experimental and validation-scale until sparse
MME, recovery, comparator, and memory gates pass.

The factor-analytic G-matrix interpretation and rotation plan is recorded in
`docs/design/14-factor-analytic-production-plan.md`.

## Phase 5

Add genomic and single-step models: GBLUP, SNP-BLUP, HBLUP, APY, Ginv, Hinv,
marker-derived genomic relationships, and first QTL-style feature effects.
XSim.jl-style simulation should become part of the validation canon before
public genomic claims are widened.

The QTL/GWAS/eQTL boundary between the core package and optional future
extensions is recorded in
`docs/design/15-qtl-extension-boundary.md`.

## Phase 6

Add non-Gaussian and GLLVM-style animal models.

## Phase 7

Add non-standard inheritance: selfing, clonal, haplodiploid, polyploid,
cytoplasmic, dominance, epistasis, and custom kernels.

Plant breeding, animal breeding, and evolutionary ecology should all be visible
in this phase. AGHmatrix and nadiv are scout references for relationship-matrix
coverage, but `hsquared` should keep the user-facing syntax easy and consistent.

## Phase 8

Add huge-scale and accelerator-aware workflows only after CPU sparse paths are
credible.
