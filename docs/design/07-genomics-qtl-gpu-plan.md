# Genomics, QTL, GLLVM, And Accelerator Plan

This document is the long-range technical plan for `hsquared` and
`HSquared.jl`. It is a roadmap and design contract, not a claim that these
features are implemented today.

## 1. Executive Summary

Build this as a two-layer system with one scientific identity:

```text
hsquared    R package: applied-user interface, formula grammar, outputs
HSquared.jl Julia package: sparse/dense engine, solvers, accelerators
```

The core modelling idea is:

```text
phenotype =
  fixed effects
  + pedigree genetic effects
  + genomic marker effects
  + QTL/eQTL/GWAS effects
  + maternal/paternal effects
  + environment/common effects
  + latent multivariate factors
  + residual variation
```

The first public path must stay simple:

```r
fit <- hsquared(
  y ~ sex + age + animal(1 | id, pedigree = ped),
  data = pheno,
  family = gaussian(),
  REML = TRUE
)
```

The long-range target is open, Julia-powered software for ASReml-style
pedigree and genomic mixed models, then beyond: QTL/eQTL, high-dimensional G
matrices, GLLVMs, unusual inheritance, and benchmarkable CPU/GPU backends.

## 2. Scientific Motivation

Quantitative-genetic users need one workflow that can connect phenotypes,
pedigrees, genotypes, environments, omics, inheritance systems, and selection
targets. Most tools cover part of that space. The opportunity for `hsquared` is
not merely "faster ASReml"; it is a coherent modelling language where all these
sources enter as structured mixed-model components.

The package should serve animal breeding, plant breeding, evolutionary ecology,
and genetics users who ask:

- What is h2?
- What are the EBVs or BLUPs?
- What is the G matrix?
- Which markers or QTL matter?
- How do pedigree, genomic, maternal, and environmental structure combine?
- Can a high-dimensional trait matrix be read as latent genetic structure?
- Can the same model run on CPU and, when appropriate, GPU?

## 3. Software Architecture: `hsquared` Versus `HSquared.jl`

`hsquared` owns:

- easy R formula syntax;
- `hs_data()` and input validation;
- ID matching and user-facing error messages;
- S3 fitted objects, extractors, summaries, plots, and diagnostics;
- bridge payload construction;
- pkgdown articles and applied examples;
- public capability status and claim boundaries.

`HSquared.jl` owns:

- sparse pedigree and relationship machinery;
- direct sparse `Ainv` construction;
- REML, ML, AI-REML, Laplace, and later variational methods;
- sparse and dense linear algebra;
- genomic relationship and marker computations;
- factor-analytic and GLLVM-style engines;
- CPU/GPU backend dispatch;
- engine diagnostics, benchmarks, and numerical quality gates.

Every stable R concept should eventually have a Julia engine counterpart.
Julia may carry experimental work first, but R public docs must not advertise it
until validation exists.

## 4. Core Formula Grammar

The grammar should be readable before it is clever.

Phase 1:

```r
y ~ fixed + animal(1 | id, pedigree = ped)
```

Repeated records:

```r
y ~ sex + age +
  animal(1 | id, pedigree = ped) +
  permanent(1 | id)
```

Maternal, paternal, and common environment:

```r
y ~ sex + age +
  animal(1 | id, pedigree = ped) +
  maternal_genetic(1 | dam, pedigree = ped) +
  maternal_env(1 | dam) +
  paternal_genetic(1 | sire, pedigree = ped) +
  paternal_env(1 | sire) +
  common_env(1 | litter)
```

Use explicit names first. A short `maternal()` alias can wait until the package
can disambiguate maternal genetic, maternal environmental, cytoplasmic,
imprinting, and maternal identity effects without surprising users.

Planned genomics and scan syntax:

```r
y ~ sex + batch + genomic(1 | id, Ginv = Ginv)
y ~ sex + batch + markers(M, model = "random")
y ~ sex + batch + marker_scan(M, map = marker_map)
y ~ sex + batch + qtl_scan(chromosome, position, genotype_probs = probs)
```

Multivariate syntax:

```r
y ~ trait + trait:sex +
  animal(trait | id, pedigree = ped, cov = us()) +
  residual(trait | unit, cov = us())
```

Factor-analytic syntax:

```r
y ~ trait + trait:sex +
  animal(trait | id, pedigree = ped, cov = fa(K = 2)) +
  residual(trait | unit, cov = fa(K = 1))
```

Status rule: parsed, reserved, and planned terms must stay visibly separate in
docs, errors, `formula_status()`, and the claims register.

## 5. Data Model For Phenotypes, Pedigrees, Genotypes, And Omics

R-side user object:

```r
hs_data(
  phenotypes = pheno,
  pedigree = ped,
  genotypes = geno,
  markers = marker_map,
  expression = expr,
  annotation = annot,
  environment = env
)
```

Julia-side engine object:

```julia
HSData(
    phenotypes = pheno,
    pedigree = ped,
    genotypes = geno,
    markers = marker_map,
    expression = expr,
    annotation = annot,
    environment = env
)
```

The data system must support:

- integer ID encoding;
- phenotype-pedigree-genotype ID matching;
- marker-to-position matching;
- expression-to-gene or transcript matching;
- missing phenotypes and missing genotypes;
- ungenotyped individuals with pedigree;
- genotyped individuals without phenotype;
- phenotyped individuals without genotype;
- repeated measures, multiple traits, and multiple environments.

Scale path:

- CSV/TSV for examples;
- Arrow/Parquet for large phenotypes;
- PLINK BED/BIM/FAM;
- VCF/BCF;
- dosage matrices;
- sparse genotype matrices;
- HDF5/Zarr-like stores;
- memory-mapped arrays;
- chunked loading and streaming marker scans.

First implementation should keep `hs_data()` lightweight and in-memory. The
file-backed and streaming interfaces should be designed before being promised.

## 6. Animal-Model And Inheritance Modules

Generic engine abstraction:

```text
random effect = design matrix Z
relationship = K or precision Q
trait covariance = G0
overall covariance = K kron G0
overall precision = Q kron inv(G0)
```

Relationship syntax:

```r
animal(1 | id, pedigree = ped)
animal(1 | id, Ainv = Ainv)
genomic(1 | id, G = G)
genomic(1 | id, Ginv = Ginv)
single_step(1 | id, H = H)
single_step(1 | id, Hinv = Hinv)
dominance(1 | id, pedigree = ped)
epistasis(1 | id, pedigree = ped)
relmat(1 | id, K = K)
precision(1 | id, Q = Q)
```

Inheritance syntax:

```r
animal(1 | id, pedigree = ped, inheritance = diploid())
animal(1 | id, pedigree = ped, inheritance = selfing(rate = s))
animal(1 | id, pedigree = ped, inheritance = clonal())
animal(1 | id, pedigree = ped, inheritance = haplodiploid())
animal(1 | id, pedigree = ped, inheritance = polyploid(ploidy = 4))
animal(1 | id, pedigree = ped, inheritance = cytoplasmic())
```

Phase 1 should implement only the simple diploid animal model. Plant, clonal,
polyploid, haplodiploid, cytoplasmic, dominance, and epistasis kernels belong
in later modules with their own validation rows.

## 7. Genomic Prediction Modules

Core targets:

- GBLUP;
- `G` and `Ginv` input;
- SNP-BLUP;
- random marker effects;
- fixed marker tests;
- single-step GBLUP/HBLUP with `H` or `Hinv`;
- blending and scaling of `G` with `A`;
- APY approximation for large genomic relationship inverses;
- genotype ID matching and missing genotype hooks.

Example:

```r
fit <- hsquared(
  y ~ sex + batch + genomic(1 | id, Ginv = Ginv),
  data = pheno,
  family = gaussian()
)
```

Marker-effect route:

```r
fit <- hsquared(
  y ~ sex + batch + markers(M, model = "random"),
  data = pheno,
  genotypes = geno,
  family = gaussian()
)
```

Mathematical relations:

- GBLUP: `u ~ N(0, G * sigma_g^2)`.
- SNP-BLUP: `alpha ~ N(0, I * sigma_alpha^2)` and breeding values are
  `M * alpha`.
- Single-step: pedigree and genomic relationships are combined into `H` or
  `Hinv`.
- Bayesian marker models can remain future work or be delegated to JWAS.jl
  comparisons.

## 8. QTL, GWAS, And eQTL Modules

Three levels:

1. single-marker scan;
2. multi-marker penalized or random-effect model;
3. joint model with pedigree/genomic random effects.

Mixed-model GWAS:

```r
fit <- hsquared(
  y ~ sex + age +
    genomic(1 | id, Ginv = Ginv) +
    marker_scan(M, map = marker_map, leave_one_chr_out = TRUE),
  data = pheno,
  genotypes = geno,
  family = gaussian()
)

gwas <- gwas_table(fit)
plot_manhattan(gwas)
plot_qq(gwas)
```

QTL interval scan:

```r
fit <- hsquared(
  y ~ sex + age +
    animal(1 | id, pedigree = ped) +
    qtl_scan(chromosome, position, genotype_probs = probs),
  data = pheno,
  family = gaussian()
)
```

High-dimensional eQTL:

```r
fit <- hsquared(
  expr_matrix ~ batch + sex +
    marker_scan(M, map = marker_map) +
    sample_factors(K = 5) +
    genomic(1 | id, Ginv = Ginv),
  data = expr_data,
  genotypes = geno,
  family = gaussian()
)
```

Scale concerns:

- thousands to tens of thousands of expression traits;
- hundreds of thousands to millions of markers;
- kinship/genomic correction;
- population structure;
- batch, tissue, cell-type, and environment effects;
- cis/trans windows;
- multiple-testing correction.

Basic scans can live in `hsquared` after the engine exists. Heavy eQTL,
fine-mapping, and very large scan infrastructure may become optional
extensions such as `hsquaredQTL` and `HSquaredQTL.jl`.

## 9. Multivariate G-Matrix And Factor-Analytic Modules

Classical multivariate animal model:

```r
fit <- hsquared(
  y ~ trait + trait:sex + trait:age +
    animal(trait | id, pedigree = ped, cov = us()) +
    residual(trait | unit, cov = us()),
  data = long_dat,
  family = gaussian()
)
```

Factor-analytic G matrix:

```r
fit <- hsquared(
  y ~ trait + trait:sex + trait:age +
    animal(trait | id, pedigree = ped, cov = fa(K = 2)) +
    residual(trait | unit, cov = fa(K = 1)),
  data = long_dat,
  family = gaussian()
)
```

Definitions:

```text
cov = us()        full unstructured covariance
cov = diag()      trait-specific variances only
cov = lowrank(K)  G = Lambda Lambda'
cov = fa(K)       G = Lambda Lambda' + Psi
```

This is where `hsquared` goes beyond ordinary animal-model output: G matrices
become biological latent structures, not only covariance tables.

## 10. GLLVM Integration Strategy

GLLVM-style models should sit on the same ladder as multivariate animal
models:

- low-rank latent factors;
- GLM response families;
- factor-analytic genetic covariance;
- sample/environment latent factors;
- fourth-corner trait-environment interactions;
- phylogenetic and spatial random effects;
- ordination output;
- missing response matrices.

Example:

```r
fit <- hsquared(
  Y ~ treatment + environment +
    animal_fa(K = 3, id = id, pedigree = ped, psi = TRUE) +
    site_fa(K = 2) +
    common_env(1 | batch_id),
  data = community_or_omics_data,
  family = negative_binomial()
)
```

Engine strategy:

- Gaussian closed form where possible;
- Woodbury identity for low-rank plus diagonal covariance;
- matrix determinant lemma for repeated low-rank updates;
- Laplace approximation for non-Gaussian random effects;
- variational approximation as an optional high-dimensional path;
- AD-backed gradients plus finite-difference and simulation checks.

Local lesson: `GLLVM.jl` already demonstrates low-rank Gaussian profiling,
family dispatch, Laplace machinery, and structured Schur/Woodbury thinking.
`HSquared.jl` should reuse the computational spirit while making the
quantitative-genetic contract central.

The future R syntax boundary for high-dimensional response matrices is recorded
in `docs/design/16-wide-response-syntax-plan.md`: keep the current `cbind(...)`
path for live small Gaussian multivariate animal models, and reserve
`traits(...)` / long stacked-cell grammar for future GLLVM, omics, and community
models after parser, bridge, engine, validation, and extractor evidence exist.

## 11. CPU/GPU Backend Architecture

R controls:

```r
fit_cpu <- hsquared(
  y ~ trait + trait:sex +
    animal(trait | id, pedigree = ped, cov = fa(K = 2)),
  data = long_dat,
  family = gaussian(),
  control = hs_control(backend = "cpu")
)

fit_gpu <- hsquared(
  y ~ trait + trait:sex +
    animal(trait | id, pedigree = ped, cov = fa(K = 2)),
  data = long_dat,
  family = gaussian(),
  control = hs_control(backend = "auto", accelerator = "gpu")
)
```

Julia backends:

```julia
CPUBackend()
ThreadsBackend()
CUDABackend()
AMDGPUBackend()
MetalBackend()
OneAPIBackend()
AutoBackend()
```

CPU is always the trusted default. GPU is an accelerator path, not a
requirement. GPU packages should be optional Julia extensions, not hard
dependencies:

```text
HSquaredCUDAExt
HSquaredAMDGPUExt
HSquaredMetalExt
HSquaredOneAPIExt
```

## 12. Mac/Metal, CUDA, AMDGPU, oneAPI, And CPU Support Strategy

Backend plan:

- CPU first and stable.
- Threaded CPU second for safe parallel loops and BLAS-heavy workloads.
- CUDA first for production HPC GPU work.
- Metal early for Mac development and smoke tests.
- AMDGPU for ROCm clusters after real hardware testing.
- oneAPI for Intel accelerators, treated as experimental until a reliable
  Linux/Intel test surface exists.
- KernelAbstractions-style kernels for custom kernels that can be written once
  and dispatched across device families.

Array discipline:

Julia code should avoid hard-coded `Array` assumptions and dispatch on
`AbstractArray`, sparse matrix types, and device arrays where possible:

```text
Array
SubArray
SparseMatrixCSC
CuArray
ROCArray
MtlArray
oneArray
```

Numerical policy:

- Float64 default for REML and publication-quality variance components.
- Float32 optional for exploratory huge GLLVM/genomic scans.
- Mixed precision later, and only after CPU/GPU agreement tests.
- Report random seeds, tolerance, device, precision, and nondeterminism
  warnings.
- Minimize host-device transfers; chunk marker scans and response matrices
  when device memory is limiting.

What runs where:

- CPU-first: pedigree validation, sorting, ID recoding, sparse `Ainv`,
  symbolic factorization, small univariate models.
- GPU-friendly: dense genomic operations, marker multiplication, large
  response matrices, factor-analytic/GLLVM likelihoods, simulation, bootstrap,
  prediction batches.
- Hybrid: sparse iterative solvers, PCG with GPU matrix-vector products, CPU
  preconditioners, CPU sparse factorization plus GPU dense updates, single-step
  models with sparse `A` and dense `G`.

## 13. Benchmarking And CPU/GPU Comparison Framework

User-facing comparison:

```r
bench <- benchmark_backend(
  y ~ trait + trait:sex +
    animal(trait | id, pedigree = ped, cov = fa(K = 2)),
  data = long_dat,
  family = gaussian(),
  backends = c("cpu", "metal")
)

compare_backends(fit_cpu, fit_gpu)
```

Metrics:

- wall-clock time;
- CPU memory and device memory;
- number of iterations;
- log-likelihood difference;
- parameter differences;
- EBV differences;
- heritability differences;
- G-matrix differences;
- gradient norm and convergence status.

Benchmark tiers:

```text
tiny     unit-test scale
small    vignette scale
medium   laptop scale
large    workstation scale
huge     HPC scale
extreme  national-computer scale
```

Benchmark categories:

- pedigree animal model;
- genomic GBLUP;
- single-step HBLUP;
- SNP-BLUP;
- QTL/GWAS scan;
- eQTL scan;
- multivariate G matrix;
- factor-analytic G matrix;
- GLLVM animal model.

Do not assume GPU is faster. Benchmark and decide.

## 14. HPC Cluster Workflow

HPC support should include:

- SLURM templates;
- Julia project activation and precompilation;
- thread control;
- GPU selection;
- memory and device-memory logging;
- checkpointing and restartable fits;
- batch benchmark scripts;
- distributed simulation;
- multi-node and multi-GPU experiments later.

R workflow target:

```r
fit <- hsquared(
  y ~ sex + batch + genomic(1 | id, Ginv = Ginv),
  data = "phenotypes.parquet",
  family = gaussian(),
  control = hs_control(
    backend = "cuda",
    threads = 32,
    checkpoint = "fit_checkpoint/",
    save = "minimal"
  )
)
```

Julia target:

```julia
fit = hsquared(
    model,
    data;
    backend = CUDABackend(),
    checkpoint = "checkpoints/run1",
    save = :minimal,
)
```

Scripts to provide later:

- CPU animal-model benchmark;
- GPU dense/factor benchmark;
- multi-trait G-matrix benchmark;
- GLLVM benchmark;
- genomic prediction benchmark;
- QTL/eQTL scan benchmark;
- ASReml/JWAS/GLLVM comparator benchmarks where licenses permit.

## 15. Validation Against Mrode, ASReml, JWAS, XSim, And GLLVM

Validation hierarchy:

1. tiny deterministic hand checks;
2. pedigree and `Ainv` known examples;
3. Mrode-style animal-model examples;
4. ASReml comparisons where available;
5. BLUPF90/DMU/WOMBAT comparisons where reproducible;
6. JWAS comparisons for genomic workflows;
7. XSim simulation truth for selection, QTL, and genomic prediction;
8. GLLVM.jl comparisons for latent-variable engines;
9. CPU/GPU numerical agreement tests.

Promotion rule: public docs may advertise a capability as working only after
implementation, tests, docs, and validation evidence exist. "Planned" and
"partial" are not marketing synonyms for "implemented".

Algorithm leads:

- AI-REML and sparse mixed-model equations for Phase 1+ variance components.
- EM or PX-EM warm starts when variance components are fragile.
- Newton/trust-region refinement after stable starts.
- PCG and block preconditioners for huge systems.
- Takahashi selected inversion for selected inverse entries, PEV, and
  reliability after sparse factorization exists.
- Woodbury and determinant-lemma paths for low-rank G and GLLVM modules.
- APY for large genomic relationship inverse approximations.

Local lead: `DRM.jl` already carries a Takahashi selected-inverse module and
`GLLVM.jl` carries low-rank/Woodbury and structured precision machinery. These
are design references, not automatic copy sources.

## 16. Output And Extractor Functions

Animal/genomic outputs:

```r
variance_components(fit)
heritability(fit)
breeding_values(fit)
EBV(fit)
BLUP(fit)
reliability(fit)
accuracy(fit)
prediction_error_variance(fit)
genetic_correlations(fit)
G_matrix(fit)
R_matrix(fit)
P_matrix(fit)
```

Genomics/QTL outputs:

```r
marker_effects(fit)
marker_variance_explained(fit)
qtl_table(fit)
eqtl_table(fit)
gwas_table(fit)
lod_scores(fit)
manhattan_plot(fit)
qq_plot(fit)
regional_plot(fit)
fine_map(fit)
```

GLLVM/multivariate outputs:

```r
loadings(fit, effect = "animal")
specific_variance(fit, effect = "animal")
latent_breeding_values(fit)
ordination(fit)
trait_scores(fit)
individual_scores(fit)
species_scores(fit)
eigen_G(fit)
evolvability(fit)
conditional_G(fit)
```

Computation outputs:

```r
backend(fit)
device_info(fit)
benchmark(fit)
memory_profile(fit)
compare_backends(fit_cpu, fit_gpu)
```

The extractor mantra is simple: make it easy to ask what the user naturally
wants to know.

## 17. Documentation And Vignettes

R pkgdown pages:

- getting started;
- model status;
- formula grammar roadmap;
- animal model;
- genomic prediction;
- QTL/GWAS/eQTL;
- multivariate G matrices;
- GLLVM and omics;
- CPU/GPU backends;
- validation and comparator evidence;
- HPC workflows.

Julia Documenter pages:

- engine contract;
- pedigree and `Ainv`;
- solver design;
- backend architecture;
- GPU extension policy;
- benchmarks;
- API reference.

Documentation rule: every page that shows planned syntax must say whether it is
parsed, reserved, or fitted. Long-format and wide-format examples should be
paired for high-dimensional trait workflows when both are intended.

## 18. Development Roadmap

Phase 0: operating system and public memory.

Phase 1: simple Gaussian animal model.

Phase 2: genomic relationship models: `G`, `Ginv`, GBLUP, SNP-BLUP, HBLUP, and
first marker-effect outputs.

Phase 3: maternal, paternal, repeatability, common-environment, dominance,
cytoplasmic, and inheritance kernels.

Phase 4: multivariate G matrices: `us()`, `diag()`, `lowrank(K)`, and
`fa(K)`.

Phase 5: QTL/GWAS/eQTL scans, LOCO option, multiple testing, and basic plots.

Phase 6: GLLVM and multi-omics integration.

Phase 7: CPU/GPU acceleration: CPU, threads, Metal, CUDA, AMDGPU, oneAPI, and
portable kernels.

Phase 8: HPC and production scaling: checkpointing, disk-backed data,
streaming marker scans, distributed computation, multi-GPU experiments, and
national-computer benchmarks.

This roadmap is directional. Phase 1 validation quality is more important than
rushing into Phase 7.

## 19. Risks And Tradeoffs

- Scope creep: keep v0.1 tiny and evidence-gated.
- User complexity: keep common paths easy and hide specialist machinery behind
  clear optional terms.
- GPU overpromise: benchmark, default to CPU, and report agreement.
- Package bloat: make heavy QTL/eQTL and GPU components extension-based if the
  core becomes crowded.
- Numerical drift: record tolerances, precision, seeds, and diagnostics.
- License/provenance: borrow patterns from local sibling packages, but copy code
  only when license, authorship, tests, and provenance notes are explicit.
- Comparator limits: ASReml and some breeding tools may not be freely
  reproducible; record the limitation instead of pretending evidence exists.

## 20. First Minimal Viable Implementation

The immediate implementation path remains:

1. R parser and model spec for `animal(1 | id, pedigree = ped)`.
2. Julia pedigree normalization and sparse `Ainv`.
3. R-to-Julia payload contract for `y`, `X`, sparse `Z`, `Ainv`, method, IDs,
   and metadata.
4. Gaussian REML/ML objective for the univariate animal model.
5. Variance components, EBVs/BLUPs, PEV/reliability, and heritability
   extraction.
6. Tiny and Mrode validation.
7. pkgdown and Documenter pages that show implemented, partial, and planned
   status separately.

That minimal path is now validated for the v0.1 Gaussian animal model. Several
adjacent lanes have moved from roadmap to opt-in partial surfaces (genomic
GREML/SNP-BLUP, constructed single-step, simple non-Gaussian animal models, and
post-fit marker scans), but the broad roadmap here remains gated: QTL/eQTL
workflows, GLLVM/omics models, unusual inheritance kernels, production APY /
low-rank genomic scaling, and GPU acceleration still require their own code,
tests, comparator evidence, and status rows before public claims widen.

## Positioning Against Related Tools

`hsquared` should respect existing tools and define its own lane:

- ASReml-R: mature commercial animal-model capability; `hsquared` aims for
  open, Julia-backed, evidence-gated alternatives.
- MCMCglmm: Bayesian biological flexibility; `hsquared` first emphasizes
  REML/ML and scalable sparse/dense engines.
- BLUPF90, DMU, WOMBAT: production breeding engines; `hsquared` should learn
  validation targets and file-scale habits from them.
- sommer: accessible R mixed-model genetics; `hsquared` should keep R ease but
  move heavy computation into Julia.
- JWAS.jl: Bayesian genomic prediction and GWAS; `hsquared` should interoperate
  conceptually and compare, not pretend to replace every Bayesian marker model.
- GCTA and GEMMA: efficient genomic association models; `hsquared` should learn
  scan and kinship-correction discipline while staying broader in inheritance
  and multivariate genetics.
- BGLR: Bayesian genomic regression; useful comparator for marker models.
- XSim.jl: simulation truth for breeding programs, QTL, and selection.
- GLLVM.jl: computational sibling for low-rank, family-aware, multivariate
  latent-variable engines.
- drmTMB/DRM.jl: operating and bridge siblings; borrow formula discipline,
  status honesty, sparse/Laplace/selected-inverse leads, and R-Julia parity
  habits.

## Source Anchors

- CUDA.jl documentation: <https://cuda.juliagpu.org/stable/>
- Metal.jl documentation: <https://metal.juliagpu.org/stable/>
- AMDGPU.jl documentation: <https://amdgpu.juliagpu.org/>
- oneAPI.jl backend page: <https://juliagpu.org/backends/oneapi/>
- oneAPI.jl repository: <https://github.com/JuliaGPU/oneAPI.jl>
- KernelAbstractions.jl documentation:
  <https://juliagpu.github.io/KernelAbstractions.jl/>
- KernelAbstractions.jl repository:
  <https://github.com/JuliaGPU/KernelAbstractions.jl>
- JuliaGPU learning page: <https://juliagpu.org/learn/>
- JWAS.jl documentation: <https://reworkhow.github.io/JWAS.jl/latest/>
- XSim.jl documentation: <https://reworkhow.github.io/XSim.jl/>
- AGHmatrix CRAN page: <https://cran.r-project.org/package=AGHmatrix>
- nadiv CRAN reference:
  <https://cran.r-project.org/web/packages/nadiv/refman/nadiv.html>
