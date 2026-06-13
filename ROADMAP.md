# hsquared Roadmap

`hsquared` and `HSquared.jl` are twin packages with one project
identity. `hsquared` owns the R interface; `HSquared.jl` owns the sparse
Julia engine.

## Phase 0: Team Operating System And Public Scaffold

Status: complete for the public scaffold.

- Install repo-visible memory, team roles, local skills, coordination
  board, and claim gates.
- Keep README/DESCRIPTION wording honest: this is a scaffold, not
  working animal-model software.
- Coordinate with the Julia twin thread for `HSquared.jl`.
- Create labels, milestones, and issues once the Phase 0 docs are
  committed.

Gate: both repos have honest READMEs, CI, team docs, and no unsupported
fitting claims.

Julia twin status: `HSquared.jl` is public and green on GitHub Actions
as of the Phase 0 scaffold. R twin status: `hsquared` is public and
green on GitHub Actions as of commit `2268ff4`.

Issue ledger:

- `hsquared`: issues \#1-#7 cover Phase 0 and initial Phase 1
  R/coordinator work.
- `HSquared.jl`: issues \#1-#7 cover Phase 0 and initial Phase 1 Julia
  engine work.

## Phase 1: Simple Gaussian Animal Model

Status: started.

- R formula: `animal(1 | id, pedigree = ped)` parser is partial.
- Julia sparse pedigree parser and Ainv.
- Gaussian ML/REML engine.
- EBVs/BLUPs, variance components, heritability.
- First tiny and Mrode-style validation examples.

Standing Phase 1+ rule: check local sister packages and relevant
statistical literature before changing grammar, engine contracts,
validation claims, or roadmap promises.

## Phase 2: Standard Quantitative-Genetic Models

Status: planned.

- Repeatability.
- Permanent environment.
- Maternal and common environment.
- Sire models.
- Groups and unknown parent groups.
- Inbreeding coefficients.
- First random-regression slice.

## Phase 3: Multivariate Gaussian Animal Models

Status: planned.

- Long-format trait grammar.
- Full G and R matrices.
- Missing trait records.
- Genetic correlations and cross-trait EBVs.

## Phase 4: Factor-Analytic G Matrices

Status: planned.

- `cov = diag()`.
- `cov = lowrank(K)`.
- `cov = fa(K)`.
- Loadings, specific variance, latent breeding values, eigen and
  evolvability tools.

## Phase 5: Genomic And Single-Step Models

Status: planned.

- GBLUP, SNP-BLUP, `Ginv`, `Hinv`, single-step HBLUP, APY,
  marker-derived genomic relationships, genomic feature/QTL-style
  effects, and simulation validation.

## Phase 6: Non-Gaussian And GLLVM Animal Models

Status: planned.

- Poisson, negative binomial, binomial, beta-binomial, ordinal,
  zero-inflated and hurdle extensions.
- Wide response matrices, latent genetic axes, ordination, and community
  ecology examples.

## Phase 7: Non-Standard Inheritance

Status: planned.

- Selfing, clonal/asexual, haplodiploid, polyploid, cytoplasmic,
  dominance, epistasis, and custom inheritance kernels.

## Phase 8: Huge-Scale And Accelerator Strategy

Status: planned.

- Disk-backed workflows, PCG/preconditioners, GPU-aware dense/factor
  models, and million-record benchmarks.
