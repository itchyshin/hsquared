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

Status: v0.1 default fit landed. The default
[`hsquared()`](https://itchyshin.github.io/hsquared/reference/hsquared.md)
call fits the univariate Gaussian animal model
`y ~ fixed + animal(1 | id, pedigree = ped)` by REML
(average-information) through the `HSquared.jl` engine; validated by
known-truth recovery, the published gryphon anchor, and sommer
agreement. ML is not implemented (REML only). Broader Phase 1 hardening
(large/real pedigrees, engine boundary stability) continues.

- R formula: `animal(1 | id, pedigree = ped)` parser; fits by default.
- Julia sparse pedigree parser and Ainv.
- Gaussian REML engine (ML deferred).
- EBVs/BLUPs, variance components, heritability.
- First tiny and Mrode-style validation examples.

Standing Phase 1+ rule: check local sister packages and relevant
statistical literature before changing grammar, engine contracts,
validation claims, or roadmap promises.

### Phase 1 frontier (completed arc + next)

The default fit now uses the average-information REML estimator
(`HSquared.fit_ai_reml`). An earlier arc (B2-B5, complete) surfaced the
Julia twin’s separate experimental sparse REML estimator
(`HSquared.fit_sparse_reml`) through R behind an opt-in fence, reusing
existing local sister-package code rather than reinventing it:

- B2 — opt-in fenced sparse-REML bridge path (`engine = "julia"`,
  `engine_control = list(target = "sparse_reml", ...)`); this stays
  opt-in and is not the default (the default fits via `ai_reml`).
  Adapted the R-to-Julia bridge discipline already proven in
  `gllvmTMB/R/julia-bridge.R` and `drmTMB/R/julia-bridge.R`.
- B3 — estimated-vs-supplied variance provenance in
  [`fit_diagnostics()`](https://itchyshin.github.io/hsquared/reference/fit_diagnostics.md)
  and
  [`validation_status()`](https://itchyshin.github.io/hsquared/reference/validation_status.md).
- B4 — sparse REML estimate-recovery validation fixture (optimizer
  improves the REML objective over a known start; not data-generating
  recovery). Reuse the comparator discipline in
  `DRM.jl/src/comparison.jl`.
- B5 — record the sparse-REML bridge contract in
  `03-engine-contract.md`.

Sister-package leads for later sparse PEV/reliability and production
sparse fitting: `GLLVM.jl` / `DRM.jl` `structured_schur.jl` and
`takahashi_selinv.jl` (selected inverse), `GLLVM.jl/src/likelihood.jl`.
Adapt architecture and process patterns and record provenance; do not
copy statistical claims without independent validation.

B2 activates as the public-facing path only once the twin’s
[`validation_status()`](https://itchyshin.github.io/hsquared/reference/validation_status.md)
marks `fit_sparse_reml` green; until then it ships fenced and
skip-guarded.

## Phase 2: Standard Quantitative-Genetic Models

Status: started (opt-in). The repeatability / permanent-environment
model is surfaced opt-in and experimental
(`engine = "julia", target = "repeatability"`, mirroring the twin
`V3-REPEAT-REML` partial gate); the remaining standard models are
planned.

- Repeatability / permanent environment — opt-in, experimental (REML,
  needs repeated records).
- Common environment and maternal-genetic — opt-in, experimental
  (`target = "two_effect"`, mirroring the twin `V3-TWOEFFECT-REML`
  partial gate); two independent effects. The correlated direct–maternal
  (2×2 G) model remains planned.
- Sire models.
- Groups and unknown parent groups.
- Inbreeding coefficients.
- First random-regression slice.

## Phase 3: Multivariate Gaussian Animal Models

Status: partial. The Julia engine `HSquared.fit_multivariate_reml`
(estimating the `t × t` genetic `G0` and residual `R0` covariances by
REML, with missing-trait records, genetic correlations, per-trait h2,
and cross-trait EBVs) is on Julia `main`, and the R package surfaces it
through an opt-in experimental
`engine = "julia", target = "multivariate"` path. The R surface uses a
`cbind(...)` multi-trait response grammar, an NA-preserving `Y` matrix
payload, and genetic-correlation / G / per-trait-h2 / cross-trait-EBV
extractors. This remains dense validation-scale and `partial`: no
ASReml-style production multi-trait claim and no t\>=2 known-truth
recovery claim until the twin adds committed recovery/comparator
evidence. See
[`docs/design/09-multivariate-plan.md`](https://itchyshin.github.io/hsquared/docs/design/09-multivariate-plan.md).

- `cbind(...)` multi-trait response grammar.
- Full G and R matrices.
- Missing trait records.
- Genetic correlations and cross-trait EBVs.

## Phase 4: Factor-Analytic G Matrices

Status: planned. The R-side expert-control contract for the first
structured multivariate bridge is recorded in
[`docs/design/18-structured-covariance-r-control.md`](https://itchyshin.github.io/hsquared/docs/design/18-structured-covariance-r-control.md).
It keeps the current `cbind(...)` response grammar and reserves
`engine_control$genetic_structure` for a future opt-in bridge after the
Julia structured-covariance branch reaches `main` and R bridge tests
exist.

- `cov = diag()`.
- `cov = lowrank(K)`.
- `cov = fa(K)`.
- Loadings, specific variance, latent breeding values, eigen and
  evolvability tools.

## Phase 5: Genomic And Single-Step Models

Status: started (opt-in). Genomic GREML (variance-component estimation
on a user-supplied `Ginv`, or a marker matrix the engine turns into a
genomic relationship) is surfaced opt-in and experimental
(`genomic(1 | id, Ginv = Ginv)` or `genomic(1 | id, markers = M)`,
`target = "genomic"`, mirroring the twin `V2-GREML` partial gate). The
rest is planned.

- Genomic GREML on a supplied `Ginv` or a marker matrix (engine-built
  G), and single-step on a supplied `Hinv` — opt-in, experimental
  (REML), mirroring the twin `V2-GREML` / `V2-GRM` / `V2-GINV` /
  `V2-SSHINV` gates.
- SNP-BLUP / RR-BLUP marker effects on `genomic(1 | id, markers = M)` at
  supplied variances (`target = "snp_blup"`,
  [`marker_effects()`](https://itchyshin.github.io/hsquared/reference/marker_extractors.md))
  — opt-in, experimental, supplied-variance, mirroring the twin
  `V2-SNPBLUP` gate.
- Weighted/standardized-marker G variants, building `Hinv` from a
  pedigree + G, REML estimation of the SNP-BLUP marker variance,
  single-step HBLUP construction, APY, low-rank m≫n solves, genomic
  feature/QTL-style effects, comparator parity
  (AGHmatrix/sommer/BLUPF90/JWAS), and simulation validation — planned.

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

### Standing performance directive (user, 2026-06-13)

Find the fastest REML and ML algorithms for the engine — be creative;
try different combinations (AI-REML, EM, Newton / Fisher-scoring, sparse
Cholesky vs PCG/preconditioners, selected inverse, etc.). Optimize CPU
first (establish the best CPU baseline before GPU), then report the
winner. Engine speed is Julia-lane-led (`HSquared.jl`); the R lane
provides the benchmarking harness and honest surfacing. Reuse local
sister code rather than reinventing: `DRM.jl` / `GLLVM.jl`
`takahashi_selinv.jl` (selected inverse), `structured_schur.jl`,
`GLLVM.jl/src/likelihood.jl`. The same directive was given to the Julia
twin; coordinate via the shared bridge contract and the coordination
board.

### Standing missing-data directive (user, 2026-06-13)

Plan for model-based missing-data handling for **both** missing
phenotypes (response) and missing covariates (predictors) in the
animal/quant-gen models. Reuse the substantial (incomplete) work already
in the sister teams rather than reinventing: `drmTMB` / `gllvmTMB` (R)
and `DRM.jl` / `GLLVM.jl` (Julia). Core approach: model-based FIML /
marginal ML via Laplace (not impute-then-analyze, not Bayesian/MCMC);
missing responses kept via an observed-`y` mask (zero likelihood
contribution, retain prediction/imputation, ASReml-like); missing
predictors as latent variables integrated over with a level-aware
covariance (e.g. species → pedigree/relmat). Syntax surface: an `mi(x)`
formula token plus a `miss_control()`-style control. The integration is
Julia-engine work (`HSquared.jl`); the R lane surfaces the syntax and
validation. Important for `HSquared.jl` too — coordinate via shared repo
memory. The planned design and the sister-repo reuse map are recorded in
[`docs/design/08-missing-data-plan.md`](https://itchyshin.github.io/hsquared/docs/design/08-missing-data-plan.md)
(status: planned; every grammar/control choice is a proposal awaiting
maintainer sign-off).
