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

Status: v0.1 default fit landed. The default `hsquared()` call fits the
univariate Gaussian animal model `y ~ fixed + animal(1 | id, pedigree = ped)`
by REML (average-information) through the `HSquared.jl` engine; validated by
known-truth recovery, the published gryphon anchor, and sommer agreement. ML is
not implemented (REML only). Broader Phase 1 hardening (large/real pedigrees,
engine boundary stability) continues.

- R formula: `animal(1 | id, pedigree = ped)` parser; fits by default.
- Julia sparse pedigree parser and Ainv.
- Gaussian REML engine (ML deferred).
- EBVs/BLUPs, variance components, heritability.
- First tiny and Mrode-style validation examples.

Standing Phase 1+ rule: check local sister packages and relevant statistical
literature before changing grammar, engine contracts, validation claims, or
roadmap promises.

### Phase 1 frontier (completed arc + next)

The default fit now uses the average-information REML estimator
(`HSquared.fit_ai_reml`). An earlier arc (B2-B5, complete) surfaced the Julia
twin's separate experimental sparse REML estimator
(`HSquared.fit_sparse_reml`) through R behind an opt-in fence, reusing existing
local sister-package code rather than reinventing it:

- B2 — opt-in fenced sparse-REML bridge path (`engine = "julia"`,
  `engine_control = list(target = "sparse_reml", ...)`); this stays opt-in and
  is not the default (the default fits via `ai_reml`). Adapted the R-to-Julia
  bridge discipline already proven in `gllvmTMB/R/julia-bridge.R` and
  `drmTMB/R/julia-bridge.R`.
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

Status: started (opt-in). Several standard models are now surfaced opt-in and
**covered at validation scale**: common-environment (`target = "two_effect"`) and
its arbitrary-N independent `(1 | g)` generalization (`target = "multi_effect"`),
plus the k=2 random-regression reaction-norm model
(`target = "random_regression"`). The repeatability / permanent-environment model
(`target = "repeatability"`, mirroring the twin `V3-REPEAT-REML` partial gate) and
the maternal-genetic two-effect leg are opt-in and experimental; the remaining
standard models are planned.

- Repeatability / permanent environment — opt-in, experimental (REML, needs
  repeated records).
- Common environment — opt-in, **covered at validation scale**
  (`target = "two_effect"`, common-environment leg; mirrors the twin
  `V3-TWOEFFECT-REML` covered gate), with an arbitrary-N independent `(1 | g)`
  generalization (`target = "multi_effect"`, also covered; mirrors the twin
  `V3-NEFFECT-REML`). The maternal-genetic two-effect leg (A2 = pedigree) uses the
  same estimator but stays experimental. The correlated direct–maternal (2×2 G) model is a
  separate opt-in target (`target = "direct_maternal"`), now **covered at
  validation scale** (mirrors the twin `V4-DIRECT-MATERNAL`; pre-declared 48-seed
  gate PASSED + `sommer` `covm()` comparator AGREE; Willham labelled-triple `h²`,
  dense n≤~1000, not the default).
- Sire models.
- Groups and unknown parent groups.
- Inbreeding coefficients.
- Random-regression k=2 reaction-norm slice — opt-in, **covered at validation
  scale** (`target = "random_regression"`; mirrors the twin `V3-RR-REML`).

## Phase 3: Multivariate Gaussian Animal Models

Status: partial. The Julia engine `HSquared.fit_multivariate_reml` (estimating
the `t × t` genetic `G0` and residual `R0` covariances by REML, with
missing-trait records, genetic correlations, per-trait h2, and cross-trait EBVs)
is on Julia `main`, and the R package surfaces it through an opt-in
experimental `engine = "julia", target = "multivariate"` path. The R surface
uses a `cbind(...)` multi-trait response grammar, an NA-preserving `Y` matrix
payload, and genetic-correlation / G / per-trait-h2 / cross-trait-EBV
extractors. This remains dense validation-scale and `partial`: no ASReml-style
production multi-trait claim and no t>=2 known-truth recovery claim until the
twin adds committed recovery/comparator evidence. See
[`docs/design/09-multivariate-plan.md`](docs/design/09-multivariate-plan.md).

- `cbind(...)` multi-trait response grammar.
- Full G and R matrices.
- Missing trait records.
- Genetic correlations and cross-trait EBVs.

## Phase 4: Factor-Analytic G Matrices

Status: partial (diagonal) / planned (lowrank, fa). The R-side expert-control
contract for the first structured multivariate bridge is recorded in
[`docs/design/18-structured-covariance-r-control.md`](docs/design/18-structured-covariance-r-control.md).
It keeps the current `cbind(...)` response grammar. The rotation-free
`engine_control$genetic_structure = "diagonal"` control is now R-surfaced
(experimental/partial), with `covariance_structure_lrt()` fixture-verified
against the twin `structured_covariance_parity` target (live fit skip-guarded).
`lowrank`/`fa` structured fits stay gated on a validated rotation convention.

- `cov = diag()`.
- `cov = lowrank(K)`.
- `cov = fa(K)`.
- Loadings, specific variance, latent breeding values, eigen and evolvability
  tools.

## Phase 5: Genomic And Single-Step Models

Status: partial (opt-in). Genomic GREML, SNP-BLUP / RR-BLUP marker effects,
constructed single-step `H^-1`, supplied-`Gamma` metafounder `A^Gamma`, and
supplied-`Gamma` single-step `H^Gamma` are surfaced experimentally through the
Julia bridge. The R lane now also carries Julia-free target/payload fixtures for
genomic GBLUP/SNP-BLUP and marker-scan result payloads. Production-scale genomic
workflows and external same-estimand comparator validation remain planned.

- Genomic GREML on a supplied `Ginv` or a marker matrix (engine-built G), and
  single-step on a supplied `Hinv` or constructed `H^-1` — opt-in,
  experimental (REML), mirroring the twin `V2-GREML` / `V2-GRM` / `V2-GINV` /
  `V2-SSHINV` gates.
- SNP-BLUP / RR-BLUP marker effects on `genomic(1 | id, markers = M)` at supplied
  variances or REML-estimated marker variance (`target = "snp_blup"`,
  `marker_effects()`) — opt-in, experimental, mirroring the twin
  `V2-SNPBLUP` gate.
- Post-fit `gwas(fit, markers)` marker scans are surfaced experimentally with
  mixed, single-marker, and LOCO methods; `gwas_table(scan)` and
  `lod_scores(scan)` are thin views of already-computed `hs_gwas` objects. They
  are not genome-wide calibrated and are not map-annotated QTL/eQTL workflows.
- Weighted/standardized-marker G variants, APY and low-rank m≫n production
  solves, PLINK/VCF readers, production-scale single-step, genomic feature/QTL
  effects, comparator parity (AGHmatrix/sommer/BLUPF90/JWAS), and simulation
  validation remain planned.

## Phase 6: Non-Gaussian And GLLVM Animal Models

Status: partial for simple non-Gaussian animal models, planned for GLLVM/omics.

- Poisson and binomial animal-model fits are surfaced experimentally through the
  Julia-owned Laplace/variational marginal path (`target = "nongaussian"`),
  including Bernoulli and equal-total binomial-count responses. No heritability
  is reported on the non-Gaussian scale. Negative binomial, beta-binomial,
  ordinal, zero-inflated, hurdle, and broader family extensions remain planned.
- Wide response matrices, latent genetic axes, ordination, and community
  ecology examples.
- Estimation by **both Laplace approximation (LA) and variational
  approximation (VA)**, mirroring the `gllvm` package's `method = "LA"` /
  `"VA"` options, so users can trade accuracy against speed on
  high-dimensional response matrices. Reuse the sister-team machinery rather
  than reinventing: Laplace from `gllvmTMB` / `GLLVM.jl` and `drmTMB` /
  `DRM.jl` (TMB / autodiff marginal Laplace); VA from `DRM.jl`
  (`src/variational.jl`) plus the `gllvmTMB` VA path. The estimator (LA + VA)
  is Julia-lane engine work in
  `HSquared.jl`; the R lane surfaces the `method` / control choice and the
  validation. Coordinate via the shared bridge contract and coordination board.

## Phase 7: Non-Standard Inheritance

Status: planned.

- Selfing, clonal/asexual, haplodiploid, polyploid, cytoplasmic, dominance,
  epistasis, and custom inheritance kernels.

## Phase 8: Huge-Scale And Accelerator Strategy

Status: planned / prototype-only.

- Disk-backed workflows, PCG/preconditioners, APY/low-rank production genomic
  inverses, GPU-aware dense/factor models, and million-record benchmarks.
- Existing APY/selected-inverse/sparse-prototype notes are design or prototype
  evidence only. No GPU backend, production APY path, or large-scale benchmark
  claim is active.

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
`HSquared.jl` too — coordinate via shared repo memory. The planned design and
the sister-repo reuse map are recorded in
[`docs/design/08-missing-data-plan.md`](docs/design/08-missing-data-plan.md)
(status: planned; every grammar/control choice is a proposal awaiting
maintainer sign-off).
