# Sparse Multivariate Production Plan

Status: **design note only**. The current multivariate path is opt-in,
experimental, dense / validation-scale, and `partial`. This note does not
promote multivariate, factor-analytic, genomic, or GPU capability.

## Purpose

The first `cbind()` multivariate bridge proved the R-to-Julia shape:

```r
hsquared(
  cbind(y1, y2) ~ x + animal(1 | id, pedigree = ped),
  data = dat,
  family = gaussian(),
  control = hs_control(
    engine = "julia",
    engine_control = list(target = "multivariate")
  )
)
```

That path is enough for validation fixtures and extractor design, but it is not
the final computational architecture. Production multivariate animal models
need to keep pedigree and record structure sparse, keep trait covariance dense
only at trait scale, and avoid silently forming large relationship or marginal
covariance matrices.

## Scout Notes

Jason scout checked the local comparison map and sibling code before this note.
The main lessons are:

- `HSquared.jl` already records the boundary: current Phase 4 / 4B utilities
  estimate dense validation-scale `G0`/`R0` and structured `G0` constraints, but
  still lack production sparse multivariate fitting, external comparator parity,
  and full loading-rotation interpretation.
- `GLLVM.jl/src/fit_phylo.jl` is the strongest local pattern for using
  Woodbury and sparse Cholesky without forming a dense covariance. It keeps the
  low-level linear algebra close to the likelihood.
- `DRM.jl/src/location_only.jl` is the strongest local pattern for a sparse
  marginal likelihood with profiled fixed effects, Woodbury solves, and
  Takahashi selected-inverse traces.
- `HSquared.jl/docs/design/00-ecosystem-lessons.md` is the process guardrail:
  use the sibling repos as algorithm and documentation leads, not as automatic
  copy sources.

External anchors checked for this note:

- Gilmour's AI-REML practice review describes why ASReml-style software leans
  on average-information REML, parameter-space guards, sparsity, and
  factor-analytic structures for general mixed models:
  <https://pubmed.ncbi.nlm.nih.gov/31247685/>.
- Meyer and Hill's multivariate AI-REML / reduced-rank animal-model paper is a
  direct anchor for sparse tools, trait-wise simplifications, canonical
  transformations, and reduced-rank genetic covariance estimation:
  <https://faculty.washington.edu/tathornt/BIOST551/articles_2012/AI_Meyer.pdf>.
- Masuda's BLUPF90 large-scale REML tutorial is a practical anchor for sparse
  mixed-model equations, selected inverse / Takahashi traces, dense blocks in
  multi-trait models, and solver options such as YAMS:
  <https://masuday.github.io/blupf90_tutorial/largescale_reml.html>.

## Target Model

For `n` records, `q` animals, and `t` traits:

```text
vec(Y) = vec(X B) + (I_t kron Z) vec(U) + vec(E)

vec(U) ~ N(0, G0 kron A)
vec(E) ~ N(0, R0 kron I_n)       initially
```

Equivalent precision form:

```text
precision(vec(U)) = inv(G0) kron Ainv
precision(vec(E)) = inv(R0) kron I_n
```

The engine should prefer the precision representation whenever `Ainv` is
available. `G0` and `R0` are small dense trait-scale matrices. `Ainv`, `Z`, and
record-incidence pieces are large and should stay sparse.

## What May Be Dense

Dense is acceptable for:

- `G0`, `R0`, and their Cholesky factors (`t x t`);
- fixed-effect cross-products of size `p x p`, when `p` is moderate;
- low-rank loading matrices, e.g. `Lambda` (`t x k`);
- small validation fixtures, where dense formulas are the oracle.

Dense is not acceptable by default for:

- `A`, the relationship matrix implied by `Ainv`;
- the marginal covariance of all observed trait records;
- `Z A Z'`;
- Kronecker-expanded random-effect precision at large `q * t`, unless stored
  and factored sparsely with explicit memory checks.

## Computational Ladder

### 1. Validation Dense Path

Keep the current path as the reference implementation:

- simple to test;
- direct `G0`/`R0` interpretation;
- useful for R extractor and comparator fixtures;
- not production-scale.

This path is the oracle for the next sparse path.

### 2. Sparse Mixed-Model Equations

Build multivariate Henderson equations using sparse blocks:

```text
C =
[ X' Rinv X              X' Rinv Z_t
  Z_t' Rinv X   Z_t' Rinv Z_t + inv(G0) kron Ainv ]
```

where `Z_t` is the trait-expanded random-effect design over observed trait
cells. Missing trait cells should remove observed rows, not whole records.

Use this path first for:

- BLUPs/EBVs;
- profiled REML objective;
- determinant identities;
- sparse selected-inverse diagonals later.

### 3. AI-REML With Sparse Traces

After sparse MME likelihood agrees with the dense oracle, add AI-REML score and
average-information terms. The key future gate is trace computation. Candidate
approaches:

- Takahashi selected inverse for required diagonal / block-pattern elements;
- Hutchinson trace estimates only as an explicitly approximate large-scale mode;
- exact dense traces only for validation fixtures.

Do not mix exact and approximate trace modes without reporting the mode in
`fit_diagnostics()`.

### 4. Structured Genetic Covariance

Treat structured `G0` as trait-scale constraints:

```text
diag:      G0 = diag(g)
lowrank:   G0 = Lambda Lambda'
fa:        G0 = Lambda Lambda' + Psi
```

The sparse solver should not change because of the covariance parameterization;
only `G0`, `inv(G0)`, derivatives, and metadata change. R syntax should wait
until the Julia row has recovery evidence and a loading sign/rotation policy.

### 5. Matrix-Free And Iterative Mode

For very large `q * t`, sparse direct factorization may still be too large.
The next design target is a matrix-free operator:

```text
v -> C v
```

with preconditioned conjugate gradients for BLUP solves. Preconditioning should
start on CPU with block-diagonal or incomplete-factorization options. GPU
matrix-vector products are a later accelerator path, not the trusted default.

## R Contract

The R interface should stay simple:

```r
hsquared(
  cbind(y1, y2, y3) ~ sex + age + animal(1 | id, pedigree = ped),
  data = dat,
  family = gaussian(),
  REML = TRUE,
  control = hs_control(engine = "julia", engine_control = list(target = "multivariate"))
)
```

Future structured covariance syntax should be introduced only when the engine
has evidence:

```r
# planned, not current
animal(trait | id, pedigree = ped, cov = diag())
animal(trait | id, pedigree = ped, cov = lowrank(K = 2))
animal(trait | id, pedigree = ped, cov = fa(K = 2))
```

The common user should not need to choose sparse factorization, selected
inverse, or GPU kernels directly. Those belong in diagnostics and expert
controls after the default is credible.

## Diagnostics Required Before Promotion

A production sparse multivariate fit must report:

- `converged`, optimizer status, iterations, gradient norm;
- dense-oracle agreement on tiny fixtures;
- missing-trait cell counts per trait;
- number of records, animals, traits, nonzeros in `Z`, nonzeros in `Ainv`, and
  nonzeros in the fitted sparse system;
- whether trace calculations are exact, selected-inverse, approximate, or
  dense-validation only;
- whether `A` was ever formed densely;
- rank checks for fixed effects;
- boundary flags for near-zero variance and near-singular `G0`/`R0`;
- condition warnings for relationship matrices and trait covariance matrices.

## Validation Gates

Before changing public wording from `partial` to `covered`, require:

1. Dense oracle agreement on tiny and small multivariate fixtures.
2. Committed `t >= 2` known-truth recovery for genetic correlations and
   per-trait heritabilities.
3. External comparator evidence where feasible: `sommer` first for partial
   diagonal-residual checks, ASReml-R / BLUPF90-family / DMU / WOMBAT only when
   versions, inputs, and estimands are recorded.
4. Missing-trait fixtures with at least one dropped trait cell and one complete
   record.
5. Rank-deficient fixed-effect rejection in R and Julia.
6. Memory audit showing large relationship matrices are not densified silently.
7. Rose audit of README, vignettes, claims register, and `validation_status()`.

## CPU/GPU Boundary

CPU sparse direct and iterative solvers are the trusted default. GPU work should
start only after the CPU sparse path is stable.

Likely CPU-first:

- pedigree validation and `Ainv` construction;
- sparse symbolic factorization;
- small and moderate sparse MME factorization;
- exact selected-inverse traces.

Likely GPU-friendly later:

- dense trait-scale batches for many traits or many bootstrap/refit jobs;
- marker and genomic matrix products;
- matrix-free `C v` products for very large systems;
- GLLVM-style dense/low-rank response-matrix operations.

Any GPU claim must come with `compare_backends()` evidence: same data, same
parameters, timing, memory/device memory, log-likelihood difference, covariance
difference, EBV difference, and tolerance.

## Immediate Next Slices

1. Julia: add a sparse multivariate MME builder that agrees with the dense
   validation path at supplied covariance components.
2. Julia: add rank-deficient fixed-effect guard to the multivariate engine.
3. Julia: add exact small-fixture determinant/log-likelihood agreement tests.
4. R: keep `cbind()` as the only live multivariate grammar until structured
   covariance rows have recovery evidence.
5. R/docs: keep structured `cov = ...` examples fenced as planned.

## References To Revisit Before Implementation

- Gilmour, A. R. (2019). Average information residual maximum likelihood in
  practice. <https://pubmed.ncbi.nlm.nih.gov/31247685/>
- Meyer, K. and Hill, W. G. (1997). Average-information REML for reduced-rank
  genetic matrices / covariance functions. Local planning copy:
  <https://faculty.washington.edu/tathornt/BIOST551/articles_2012/AI_Meyer.pdf>
- BLUPF90 large-scale REML tutorial:
  <https://masuday.github.io/blupf90_tutorial/largescale_reml.html>
