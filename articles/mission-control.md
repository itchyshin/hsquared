# Mission control

This page is the R-side mission-control board for the `hsquared` /
`HSquared.jl` twin project. It is static and repo-versioned. The source
of truth remains the tests, GitHub Actions, issue ledger, check log, and
public claims register.

hsquared / HSquared.jl mission control

## One easy R interface, one Julia engine, one evidence gate.

This board tracks the R lane and its contract with the Julia twin. It
separates implemented package surfaces, experimental validation paths,
and roadmap capabilities that are deliberately still planned.

Phase 0 public scaffold complete v0.1 Gaussian animal model fits by
default (REML) Phase 1 validation and comparators active Multivariate,
genomic, GPU still planned

**1** public formula contract parsed today:
`animal(1 | id, pedigree = ped)`

**20** validation-status rows separating covered, partial, and planned
evidence

**1** model fitted by default: the v0.1 univariate Gaussian animal model
(REML via the HSquared.jl engine)

**0** production GPU, QTL/eQTL, or GLLVM capabilities (planned)

### R Interface Lane

Current focus: make the first animal-model contract obvious, tested, and
honest.

- Implemented: default fit of the v0.1 Gaussian animal model (REML via
  the HSquared.jl engine), package scaffold, pkgdown, parser
  diagnostics, data-container diagnostics, fitted-object extractors.
- Experimental: opt-in local Julia bridge targets for supplied-variance
  Henderson MME checks, REML optimizers,
  repeatability/two-effect/genomic/SNP-BLUP paths, and multivariate
  REML.
- Planned: production multivariate/genomic fitting, QTL/eQTL, GLLVMs,
  unusual inheritance, ML estimation, and real backend execution.

### Julia Twin Boundary

`HSquared.jl` owns engine utilities and performance work. R owns the
applied user language.

- Bridge payload: `y`, `X`, sparse `Z`, method, family, encoded IDs, and
  pedigree metadata.
- Result contract: compact fields that R can turn into summaries,
  extractors, and diagnostics.
- Rule: no public R claim moves from planned to working until the Julia
  path and R bridge are both validated.

### Phase Board

**Phase 0**Operating system, public memory, pkgdown, GitHub Actions,
claim gates.

**Phase 1**Simple Gaussian animal model: parser, Ainv, likelihood, MME,
EBVs, h2, validation fixtures.

**Phase 2**Repeatability, permanent environment, maternal/paternal
effects, common environment, dominance, custom kernels.

**Phase 3**Multivariate Gaussian animal models, G/R/P matrices, genetic
correlations, missing trait records.

**Phase 4**Factor-analytic G matrices with
[`diag()`](https://rdrr.io/r/base/diag.html), `lowrank(K)`, and `fa(K)`
covariance structures.

**Phase 5**GBLUP, SNP-BLUP, single-step, APY, marker effects,
QTL/GWAS/eQTL scans.

**Phase 6**GLLVM-style high-dimensional animal models, non-Gaussian
responses, omics, ordination.

**Phase 7**Selfing, clonal, haplodiploid, polyploid, cytoplasmic,
imprinting, epistasis, unusual inheritance.

**Phase 8**Accelerator-aware and HPC scaling: CPU default, optional GPU
backends, checkpoints, benchmarks.

### Evidence Now

| Surface | Status | Evidence |
|----|----|----|
| Formula parser | partial | `animal(1 | id, pedigree = ped)` and [`hs_data()`](https://itchyshin.github.io/hsquared/reference/hs_data.md) pedigree shorthand parse and validate. |
| Bridge payload | partial | Tests pin `y` or multivariate `Y`, `X`, sparse `Z`, IDs, method, family, pedigree metadata. |
| Validation atoms | partial | Tiny Ainv, Mrode9/nadiv Ainv comparator, Henderson MME, sparse REML identity, and Mrode-style supplied-variance output checks. |
| Fit object | partial | Extractor contract exists for objects that contain matching result fields. |
| Data container | partial | [`hs_data()`](https://itchyshin.github.io/hsquared/reference/hs_data.md) checks phenotype, pedigree, genotype, marker, expression, annotation, and environment metadata. |
| Backends | planned | [`hs_control()`](https://itchyshin.github.io/hsquared/reference/hs_control.md) stores planned names; [`backend_info()`](https://itchyshin.github.io/hsquared/reference/backend_info.md) marks execution unavailable. |

### Blocked Claims

- No production fitting beyond the v0.1 univariate Gaussian animal
  model. Genomic, repeatability, two-effect, SNP-BLUP, and multivariate
  targets are opt-in experimental; factor-analytic and non-Gaussian
  models remain planned.
- No standard errors / confidence intervals for variance components or
  h2 (out of v0.1 scope).
- No ASReml/BLUPF90-family multi-package parity or large-scale (\>10k)
  production-fitting claim; the v0.1 fit is validated to gryphon scale
  (~1300 animals) and on clean simulated pedigrees.
- No production genomic prediction, marker scan, QTL/eQTL, GLLVM, or
  unusual-inheritance fitting claim.
- No CPU/GPU execution, backend benchmark, or speedup claim.

### Review Lenses

These are review perspectives, not automatically running agents.

**Ada**programme integration

**Shannon**lane coordination

**Boole**formula grammar

**Noether**math consistency

**Gauss**numerical engine

**Fisher**inference and estimands

**Curie**validation canon

**Pat**applied user reading

**Rose**public claim audit

**Grace**CI and release gates

**Hopper**R-Julia bridge

**Karpinski**Julia performance

## Recovery Pointers

Before a substantial resumed slice, run the rehydrate commands in
`AGENTS.md`, then read:

- `docs/dev-log/coordination-board.md`;
- `docs/dev-log/check-log.md`;
- newest `docs/dev-log/after-task/*.md`;
- `docs/design/01-v0.1-contract.md`;
- `docs/design/06-public-claims-register.md`.

The short rule is still the one in the project memory:

``` text
Private memory routes us.
Repository memory governs us.
Live repo state verifies us.
```
