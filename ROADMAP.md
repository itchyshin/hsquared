# hsquared Roadmap

`hsquared` and `HSquared.jl` are twin packages with one project identity.
`hsquared` owns the R interface; `HSquared.jl` owns the sparse Julia engine.

## Phase 0: Team Operating System And Public Scaffold

Status: complete for the public scaffold.

- Install repo-visible memory, team roles, local skills, coordination board,
  and claim gates.
- Keep README/DESCRIPTION wording honest: this is a scaffold, not working
  animal-model software.
- Coordinate with the Julia twin thread for `HSquared.jl`.
- Create labels, milestones, and issues once the Phase 0 docs are committed.

Gate: both repos have honest READMEs, CI, team docs, and no unsupported fitting
claims.

Julia twin status: `HSquared.jl` is public and green on GitHub Actions as of
the Phase 0 scaffold. R twin status: `hsquared` is public and green on
GitHub Actions as of commit `2268ff4`.

Issue ledger:

- `hsquared`: issues #1-#7 cover Phase 0 and initial Phase 1 R/coordinator
  work.
- `HSquared.jl`: issues #1-#7 cover Phase 0 and initial Phase 1 Julia engine
  work.

## Phase 1: Simple Gaussian Animal Model

Status: started.

- R formula: `animal(1 | id, pedigree = ped)` parser is partial.
- Julia sparse pedigree parser and Ainv.
- Gaussian ML/REML engine.
- EBVs/BLUPs, variance components, heritability.
- First tiny and Mrode-style validation examples.

Standing Phase 1+ rule: check local sister packages and relevant statistical
literature before changing grammar, engine contracts, validation claims, or
roadmap promises.

### Next work queue (R lane, Phase 1 frontier)

The active R-lane frontier is surfacing the Julia twin's experimental sparse
REML estimator (`HSquared.fit_sparse_reml`) through R behind an opt-in fence,
reusing existing local sister-package code rather than reinventing it:

- B2 — opt-in fenced sparse-REML bridge path (`engine = "julia"`,
  `engine_control = list(target = "sparse_reml", ...)`); default `hsquared()`
  still validates-and-stops. Adapt the R-to-Julia bridge discipline already
  proven in `gllvmTMB/R/julia-bridge.R` and `drmTMB/R/julia-bridge.R`.
- B3 — estimated-vs-supplied variance provenance in `fit_diagnostics()` and
  `validation_status()`.
- B4 — sparse REML estimate-recovery validation fixture (optimizer improves the
  REML objective over a known start; not data-generating recovery). Reuse the
  comparator discipline in `DRM.jl/src/comparison.jl`.
- B5 — record the sparse-REML bridge contract in `03-engine-contract.md`.

Sister-package leads for later sparse PEV/reliability and production sparse
fitting: `GLLVM.jl` / `DRM.jl` `structured_schur.jl` and `takahashi_selinv.jl`
(selected inverse), `GLLVM.jl/src/likelihood.jl`. Adapt architecture and process
patterns and record provenance; do not copy statistical claims without
independent validation.

B2 activates as the public-facing path only once the twin's `validation_status()`
marks `fit_sparse_reml` green; until then it ships fenced and skip-guarded.

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
- Loadings, specific variance, latent breeding values, eigen and evolvability
  tools.

## Phase 5: Genomic And Single-Step Models

Status: planned.

- GBLUP, SNP-BLUP, `Ginv`, `Hinv`, single-step HBLUP, APY, marker-derived
  genomic relationships, genomic feature/QTL-style effects, and simulation
  validation.

## Phase 6: Non-Gaussian And GLLVM Animal Models

Status: planned.

- Poisson, negative binomial, binomial, beta-binomial, ordinal, zero-inflated
  and hurdle extensions.
- Wide response matrices, latent genetic axes, ordination, and community
  ecology examples.

## Phase 7: Non-Standard Inheritance

Status: planned.

- Selfing, clonal/asexual, haplodiploid, polyploid, cytoplasmic, dominance,
  epistasis, and custom inheritance kernels.

## Phase 8: Huge-Scale And Accelerator Strategy

Status: planned.

- Disk-backed workflows, PCG/preconditioners, GPU-aware dense/factor models,
  and million-record benchmarks.

### Standing performance directive (user, 2026-06-13)

Find the fastest REML and ML algorithms for the engine — be creative; try
different combinations (AI-REML, EM, Newton / Fisher-scoring, sparse Cholesky vs
PCG/preconditioners, selected inverse, etc.). Optimize CPU first (establish the
best CPU baseline before GPU), then report the winner. Engine speed is
Julia-lane-led (`HSquared.jl`); the R lane provides the benchmarking harness and
honest surfacing. Reuse local sister code rather than reinventing:
`DRM.jl` / `GLLVM.jl` `takahashi_selinv.jl` (selected inverse),
`structured_schur.jl`, `GLLVM.jl/src/likelihood.jl`. The same directive was
given to the Julia twin; coordinate via the shared bridge contract and the
coordination board.

### Standing missing-data directive (user, 2026-06-13)

Plan for model-based missing-data handling for **both** missing phenotypes
(response) and missing covariates (predictors) in the animal/quant-gen models.
Reuse the substantial (incomplete) work already in the sister teams rather than
reinventing: `drmTMB` / `gllvmTMB` (R) and `DRM.jl` / `GLLVM.jl` (Julia). Core
approach: model-based FIML / marginal ML via Laplace (not impute-then-analyze,
not Bayesian/MCMC); missing responses kept via an observed-`y` mask (zero
likelihood contribution, retain prediction/imputation, ASReml-like); missing
predictors as latent variables integrated over with a level-aware covariance
(e.g. species → pedigree/relmat). Syntax surface: an `mi(x)` formula token plus a
`miss_control()`-style control. The integration is Julia-engine work
(`HSquared.jl`); the R lane surfaces the syntax and validation. Important for
`HSquared.jl` too — coordinate via shared repo memory.
