# Genomics, QTL, GLLVM, And Accelerator Plan

This document records the long-range technical plan for `hsquared` and
`HSquared.jl`. It is a roadmap and design contract, not a claim that these
features are implemented today.

## 1. Executive Summary

`hsquared` and `HSquared.jl` should become a coherent modelling language for
quantitative genetics:

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

`hsquared` owns the easy R interface. `HSquared.jl` owns the sparse, dense,
low-rank, and accelerator-aware computation. The first user path should remain
easy:

```r
fit <- hsquared(
  y ~ sex + age + animal(1 | id, pedigree = ped),
  data = pheno,
  family = gaussian(),
  REML = TRUE
)
```

The larger target is open, Julia-powered software for ASReml-style
pedigree/genomic models and then beyond: QTL/eQTL, high-dimensional G matrices,
GLLVMs, unusual inheritance, and benchmarkable CPU/GPU backends.

## 2. Scientific Motivation

Quantitative-genetic users want the same model to connect:

- phenotypes;
- pedigrees;
- genotypes and markers;
- genomic relationship matrices;
- QTL/eQTL/GWAS evidence;
- expression and multi-omics traits;
- maternal, paternal, family, litter, plot, and block structure;
- high-dimensional trait covariance;
- non-standard inheritance systems.

Existing tools each cover important parts of this space. `hsquared` should not
be a bundle of unrelated genetics utilities. It should express these pieces as
structured mixed-model components with a friendly syntax and a high-performance
engine.

## 3. Software Architecture

### R Layer: `hsquared`

Responsibilities:

- friendly formula grammar;
- data validation and ID matching;
- readable errors and status messages;
- S3 fitted objects, extractors, plots, and reports;
- bridge payload construction;
- pkgdown documentation and applied vignettes.

### Julia Layer: `HSquared.jl`

Responsibilities:

- sparse pedigree and relationship-matrix machinery;
- REML, ML, AI-REML, Laplace, and later variational methods;
- sparse and dense linear algebra;
- factor-analytic and GLLVM-style engines;
- genomic and marker computations;
- CPU/GPU backend dispatch;
- benchmarking, diagnostics, and numerical quality gates.

Julia should cover every stable concept that R exposes. Julia may also carry
experimental features ahead of R if they are clearly marked and do not leak into
R as public promises.

## 4. Core Formula Grammar

The grammar should stay easy and composable.

### Phase 1

```r
y ~ fixed + animal(1 | id, pedigree = ped)
```

### Standard Quantitative Genetics

```r
y ~ sex + age +
  animal(1 | id, pedigree = ped) +
  permanent(1 | id) +
  common_env(1 | litter)
```

### Maternal And Paternal Effects

Prefer explicit names when biology differs:

```r
y ~ sex + age +
  animal(1 | id, pedigree = ped) +
  maternal_genetic(1 | dam, pedigree = ped) +
  maternal_env(1 | dam) +
  paternal_genetic(1 | sire, pedigree = ped) +
  paternal_env(1 | sire) +
  cytoplasmic(1 | maternal_line) +
  imprinting(1 | id, pedigree = ped, parent = "maternal")
```

Short aliases such as `maternal()` can be considered later, but the first public
grammar should avoid hiding distinct biological effects behind one word.

## 5. Data Model

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

Required capabilities:

- integer ID encoding;
- phenotype-pedigree-genotype ID matching;
- marker-to-position matching;
- expression-to-gene or transcript matching;
- missing phenotype and genotype handling;
- genotyped/no-phenotype and phenotyped/no-genotype individuals;
- repeated measures;
- long and wide multi-trait data;
- multiple environments.

Scalable formats:

- CSV/TSV for examples;
- Arrow/Parquet for large phenotypes;
- PLINK BED/BIM/FAM;
- VCF/BCF;
- dosage matrices;
- sparse genotype matrices;
- HDF5/Zarr-like stores;
- memory-mapped and chunked arrays;
- streaming computations for marker scans.

## 6. Animal-Model And Inheritance Modules

The engine abstraction is:

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

Phase 1 should implement only the simple diploid animal model. Later
inheritance kernels should be separate, tested modules.

## 7. Genomic Prediction Modules

First genomic targets:

- GBLUP;
- Ginv input;
- SNP-BLUP;
- Hinv input;
- single-step GBLUP/HBLUP;
- APY approximation;
- genotype ID matching;
- basic marker-effect output.

Example grammar:

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

Mathematical relation:

- GBLUP: breeding values have covariance `G * sigma_g^2`.
- SNP-BLUP: marker effects are random and breeding values are `M * alpha`.
- Single-step: pedigree and genomic relationships are combined into `H`.
- Bayesian marker models are future or may remain better served by JWAS.jl.

## 8. QTL, GWAS, And eQTL Modules

Three analysis levels:

1. single-marker scan;
2. multi-marker penalized or random-effect model;
3. joint model with pedigree/genomic random effects.

Single-marker or mixed-model GWAS:

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

eQTL:

```r
fit <- hsquared(
  expression ~ genotype_marker +
    covariates(batch, sex, age) +
    genomic(1 | id, Ginv = Ginv),
  data = expr_long,
  genotypes = geno,
  family = gaussian()
)
```

Scale concerns:

- thousands to tens of thousands of expression traits;
- hundreds of thousands to millions of markers;
- kinship/genomic correction;
- population structure;
- cis/trans windows;
- multiple testing.

Core outputs:

```r
qtl_table(fit)
eqtl_table(fit)
gwas_table(fit)
marker_effects(fit)
marker_variance_explained(fit)
fine_map(fit)
```

Basic scans can live in `hsquared` once the engine exists. Heavy eQTL and
fine-mapping may become optional extensions such as `hsquaredQTL` and
`HSquaredQTL.jl`.

## 9. Multi-Omics And Gene-Level Models

The first principle is not to create a separate modelling language for every
omics type. Use a response-matrix interface plus family-specific likelihoods.

```r
fit <- hsquared(
  Y ~ treatment + batch +
    animal_fa(K = 3, id = id, pedigree = ped, psi = TRUE) +
    sample_factors(K = 5),
  data = omics_data,
  family = gaussian()
)
```

Count data:

```r
fit <- hsquared(
  counts_matrix ~ treatment + batch +
    animal_fa(K = 3, id = id, pedigree = ped, psi = TRUE) +
    sample_factors(K = 5),
  data = rnaseq_data,
  family = negative_binomial()
)
```

This connects GLLVMs, latent environmental axes, latent genetic axes, and
multi-trait G matrices.

## 10. Multivariate G Matrices And Factor Analysis

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

This makes G matrices biological latent structures, not just printed covariance
tables.

## 11. GLLVM Integration Strategy

GLLVM-style models should sit on the same ladder as multivariate animal models:

- low-rank latent factors;
- GLM response families;
- factor-analytic genetic covariance;
- sample/environment latent factors;
- fourth-corner trait-environment interactions;
- phylogenetic and spatial random effects;
- ordination output;
- missing response matrices.

Likely engine methods:

- Gaussian closed form where possible;
- Woodbury identity for low-rank plus diagonal covariance;
- Laplace approximation for non-Gaussian random effects;
- variational approximation as an optional high-dimensional path;
- AD-backed gradients with finite-difference and simulation checks.

`GLLVM.jl` is the nearest computational reference. `HSquared.jl` should borrow
the spirit of low-rank, multivariate, family-aware computation while rewriting
the quantitative-genetic contract.

## 12. CPU/GPU Backend Architecture

R controls:

```r
hs_control(
  backend = "auto",
  accelerator = "gpu",
  precision = "float64"
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
requirement.

Optional Julia package extensions:

```text
HSquaredCUDAExt
HSquaredAMDGPUExt
HSquaredMetalExt
HSquaredOneAPIExt
```

## 13. Backend Support Strategy

Current ecosystem anchors:

- CUDA.jl for NVIDIA GPUs and `CuArray`;
- AMDGPU.jl for AMD/ROCm GPUs;
- Metal.jl for macOS/Apple Silicon GPUs;
- oneAPI.jl for Intel accelerators;
- KernelAbstractions.jl for portable CPU/GPU kernels.

Maturity plan:

- CPU first and stable.
- CUDA first for production HPC.
- Metal early for Mac development and smoke testing.
- AMDGPU important for ROCm-based supercomputers.
- oneAPI useful but riskier; keep it behind explicit tests.
- KernelAbstractions or a similar layer for kernels that can be written once
  and dispatched across devices.

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
- Mixed precision later, only after CPU/GPU agreement tests.
- Reproducibility and GPU nondeterminism must be reported in diagnostics.

## 14. What Runs Where

CPU-first:

- pedigree validation;
- topological sorting;
- ID recoding;
- sparse Ainv construction;
- symbolic sparse factorization;
- small univariate models.

GPU-friendly:

- dense genomic matrix operations;
- marker matrix multiplication;
- GLLVM likelihood evaluation;
- large response-matrix operations;
- factor-analytic models;
- Woodbury repeated calculations;
- bootstrap and cross-validation batches;
- simulation;
- prediction over many individuals.

Hybrid:

- sparse iterative solvers;
- PCG with GPU matrix-vector products;
- CPU preconditioning;
- CPU sparse factorization plus GPU dense updates;
- single-step models with sparse A and dense G.

Advanced algorithm scout:

- AI-REML and average-information updates;
- EM or PX-EM warm starts for variance components;
- Newton/trust-region refinement after stable starts;
- PCG and block preconditioners;
- Takahashi selected inversion for selected inverse entries and PEV-like
  diagnostics;
- Woodbury and matrix determinant lemma for low-rank G and GLLVM components;
- APY for large genomic inverse approximations.

## 15. Benchmarking And CPU/GPU Comparison

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
- CPU and device memory;
- iterations;
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

## 16. HPC Cluster Workflow

HPC support should include:

- SLURM templates;
- Julia project activation;
- package precompilation;
- thread control;
- GPU selection;
- memory logging;
- checkpointing and restartable fits;
- batch benchmark scripts;
- distributed simulation;
- multi-node support later.

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

## 17. Validation

Validation hierarchy:

1. tiny deterministic tests;
2. Mrode-style animal-model examples;
3. sparse Ainv known examples;
4. ASReml comparisons where available;
5. BLUPF90/DMU/WOMBAT comparisons;
6. JWAS comparisons for genomic workflows;
7. XSim simulation truth for selection, QTL, and genomic prediction;
8. GLLVM.jl comparisons for latent-variable engines;
9. CPU/GPU numerical agreement tests.

No public page should claim "ASReml-level" or "faster" until comparator
evidence exists.

## 18. Output And Extractor Functions

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

## 19. Documentation And Vignettes

R pkgdown pages:

- getting started;
- model status;
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
- pedigree and Ainv;
- solver design;
- backend architecture;
- GPU extension policy;
- benchmarks;
- API reference.

## 20. Development Roadmap

Phase 0: architecture and public memory.

Phase 1: simple Gaussian animal model.

Phase 2: genomic relationship models.

Phase 3: maternal/paternal and inheritance modules.

Phase 4: multivariate G matrices.

Phase 5: QTL/GWAS/eQTL.

Phase 6: GLLVM integration.

Phase 7: CPU/GPU acceleration.

Phase 8: HPC and production scaling.

## 21. Risks And Tradeoffs

- Scope creep: solve by keeping v0.1 tiny and evidence-gated.
- User complexity: solve by keeping easy defaults and hiding specialist
  machinery behind clear terms.
- GPU overpromise: solve by benchmarking and defaulting to CPU.
- Package bloat: keep heavy QTL/eQTL and GPU features optional or extension
  based.
- Numerical drift across backends: record tolerances, seeds, and diagnostics.
- License/provenance risk: borrow patterns from sibling packages, but copy code
  only when license and ownership are explicit.

## 22. First Minimal Viable Implementation

The next implementation path should be:

1. R parser and model spec for `animal(1 | id, pedigree = ped)`.
2. Julia pedigree normalization and sparse `Ainv`.
3. R-to-Julia payload contract for `y`, `X`, `Z`, `Ainv`, method, IDs, and
   metadata.
4. Gaussian REML/ML objective for the univariate animal model.
5. Variance components, EBVs/BLUPs, and heritability extraction.
6. Tiny and Mrode validation.
7. pkgdown and Documenter pages that show implemented, partial, and planned
   status separately.

Only after that should genomic, QTL/eQTL, GLLVM, and GPU lanes move from
roadmap to implementation.

## Source Anchors

- CUDA.jl documentation: <https://cuda.juliagpu.org/stable/>
- Metal.jl documentation: <https://metal.juliagpu.org/stable/>
- AMDGPU.jl documentation: <https://amdgpu.juliagpu.org/>
- oneAPI.jl repository: <https://github.com/JuliaGPU/oneAPI.jl>
- KernelAbstractions.jl documentation:
  <https://juliagpu.github.io/KernelAbstractions.jl/>
- JWAS.jl documentation: <https://reworkhow.github.io/JWAS.jl/latest/>
- XSim.jl documentation: <https://reworkhow.github.io/XSim.jl/>
- AGHmatrix CRAN page: <https://cran.r-project.org/package=AGHmatrix>
- nadiv CRAN reference:
  <https://cran.r-project.org/web/packages/nadiv/refman/nadiv.html>
