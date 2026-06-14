# Factor-Analytic G-Matrix Production Plan

Status: **design note only**. The current R package does not parse or fit
`cov = fa(K)` syntax. `HSquared.jl` has experimental Julia-local structured
genetic covariance utilities, but R-facing factor-analytic animal models,
loading extractors, rotation choices, and production sparse fitting remain
planned.

## Purpose

Factor-analytic G matrices are the natural next step after ordinary
multivariate animal models:

```text
unstructured: G0 = full trait covariance
diagonal:     G0 = diag(g)
lowrank:      G0 = Lambda Lambda'
fa:           G0 = Lambda Lambda' + Psi
```

The production goal is not just to fit fewer covariance parameters. It is to let
users describe latent genetic axes across traits while keeping the ordinary
question easy:

```r
# planned, not current
fit <- hsquared(
  y ~ trait + trait:sex +
    animal(trait | id, pedigree = ped, cov = fa(K = 2)),
  data = long_dat,
  family = gaussian()
)
G_matrix(fit)
loadings(fit, effect = "animal")
latent_breeding_values(fit)
```

The first public teaching should still be invariant:

- What is the estimated G matrix?
- What are the genetic correlations?
- How much trait variance is genetic?
- Which latent axes summarize genetic covariance, if a rotation convention is
  declared?

## Scout Notes

Local sources checked:

- `HSquared.jl/docs/dev-log/decisions/2026-06-14-loading-rotation-identifiability.md`
  records the current Phase 4B policy: loading columns are sign-canonicalized
  for deterministic metadata, but rotations are not identified.
- `HSquared.jl/test/runtests.jl` has structured-covariance tests for
  `diagonal`, `lowrank`, and `factor_analytic`, including copy-returning
  `genetic_loadings()` / `genetic_uniqueness()` accessors.
- `GLLVM.jl/src/postfit.jl` has a mature extraction pattern: report loadings
  and scores with an explicit rotation option, and count loading parameters
  modulo rotational degrees of freedom.
- `gllvmTMB/R/diagnose.R` is a user-facing warning pattern: covariance
  summaries are rotation-invariant; loading axes need constraints or rotation
  before interpretation.
- Meyer/Hill's multivariate AI-REML / reduced-rank work remains the external
  statistical anchor for reduced-rank genetic covariance in animal models:
  <https://faculty.washington.edu/tathornt/BIOST551/articles_2012/AI_Meyer.pdf>.

## Accepted Future Syntax

The planned grammar stays:

```r
animal(trait | id, pedigree = ped, cov = diag())
animal(trait | id, pedigree = ped, cov = lowrank(K = 2))
animal(trait | id, pedigree = ped, cov = fa(K = 2))
```

Definitions:

```text
diag():      G0 = diag(g)
lowrank(K):  G0 = Lambda Lambda'
fa(K):       G0 = Lambda Lambda' + Psi
```

Boole verdict: this syntax is memorable and matches the existing formula
grammar note, but it must remain planned until the engine exposes a validated
R-facing result contract.

## Deferred Or Rejected Syntax

Deferred:

```r
animal_fa(K = 2, id = id, pedigree = ped)
animal(trait | id, pedigree = ped, cov = fa(K = 2, rotation = "varimax"))
loadings(fit, rotate = "varimax")
```

These may become useful, but they mix model fitting, post-fit rotation, and
high-dimensional GLLVM-style syntax too early.

Rejected for now:

```r
animal(trait | id, pedigree = ped, cov = rr(K = 2))
```

`rr()` is avoided because quantitative-genetic users may read it as random
regression rather than reduced rank.

## Parameterization

Production code should keep the fitted covariance as the primary invariant:

```text
G0 = Lambda Lambda' + Psi
Psi = diag(psi), psi > 0
```

Recommended internal constraints:

- optimize log-uniqueness for `Psi`;
- keep `G0` positive definite for `fa()`;
- allow `lowrank()` to be positive semidefinite, but keep residual `R0`
  positive definite;
- report rank `K`, trait order, loading matrix dimensions, and uniqueness
  vector length in diagnostics.

The R object should always store or reconstruct `G0` first. Loadings and
uniqueness are metadata over `G0`, not a replacement for covariance extraction.

## Identifiability And Rotation

The hard rule:

```text
G0 is interpretable.
Lambda is not uniquely interpretable without a rotation or constraint.
```

The current Julia sign convention is useful only for deterministic tests:

- each loading column's largest-absolute loading is made non-negative;
- this removes arbitrary column sign flips;
- it does not solve rotations when `K > 1`.

Before R exposes loading interpretation, the programme must choose and document
one of:

- fitted lower-triangular constraints with positive diagonal;
- post-fit SVD rotation, as in the local `GLLVM.jl` extraction pattern;
- varimax / promax-style post-fit rotation for biological interpretation;
- trait-anchored target rotation for a named breeding or ecology use case.

Any rotation must preserve the fitted covariance and likelihood when it is
post-fit. If rotation is fitted as a constraint, comparator alignment must use
the same convention.

## Result Contract

Future R result fields should be compact and explicit:

```text
genetic_covariance
genetic_correlation
genetic_structure: "diagonal" | "lowrank" | "factor_analytic"
genetic_rank
genetic_loadings
genetic_uniqueness
rotation_method
loading_sign_convention
latent_breeding_values
diagnostics
```

Deferred fields:

```text
loading_se
loading_ci
rotation_uncertainty
factor_scores_se
LRT_for_rank
```

Those are inference surfaces and must stay blocked until Fisher/Curie evidence
exists.

## Extractor Contract

Invariant extractors can come first:

```r
G_matrix(fit)
genetic_covariance(fit)
genetic_correlation(fit)
heritability(fit)
eigen_G(fit)
```

Loading extractors come only with rotation metadata:

```r
loadings(fit, effect = "animal")
specific_variance(fit, effect = "animal")
latent_breeding_values(fit)
rotation(fit, effect = "animal")
```

If `loadings()` is added before a full rotation decision, it must print or carry
an attribute saying:

```text
Loading columns are sign-canonicalized but rotation-nonunique; interpret the
covariance/correlation matrix unless a rotation method is declared.
```

## Sparse Computation

The sparse MME architecture from
`docs/design/13-sparse-multivariate-production-plan.md` should not change for
factor-analytic G matrices. What changes is the map from free parameters to
`G0`, `inv(G0)`, and derivative matrices.

Initial production ladder:

1. Dense validation oracle: current Julia local structured fits.
2. Sparse MME with supplied structured `G0`, agreeing with the dense oracle.
3. Sparse REML / AI-REML with `diag`, `lowrank`, and `fa` parameter maps.
4. Exact trace mode for small/moderate fits; approximate trace mode only if
   reported.
5. Matrix-free iterative mode for very large trait/animal systems.

## User Documentation Order

Do not start with loadings. Start with:

1. Full multivariate G matrix.
2. Genetic correlations and heritabilities.
3. Diagonal vs unstructured vs factor-analytic as parameter-count choices.
4. Loadings as one possible biological summary, with rotation warnings.
5. Latent breeding values only after extractor semantics are stable.

Pat verdict: breeders and ecologists should not have to learn rotation theory
before they can read `G_matrix(fit)`.

## Validation Gates

Before any R-facing `fa(K)` claim:

1. Julia recovery evidence for `t >= 3`, `K >= 1`, and at least one `K > 1`
   case.
2. Tests that `Lambda Lambda' + Psi` reconstructs `G0` after any returned
   rotation/sign convention.
3. Tests that fitted covariance and log likelihood are invariant under post-fit
   rotation.
4. Rank-selection guidance: do not expose LRT/AIC rank advice until likelihood
   and boundary behavior are validated.
5. External comparator plan: ASReml/sommer/BLUPF90-family where available, with
   covariance-level comparison first and loading comparison only after matching
   rotation conventions.
6. Rose audit of all wording that says "latent axis", "factor", "loading", or
   "evolvability".

## Immediate Next Slices

1. Julia: add deterministic `t >= 3`, `K = 1` and `K = 2` structured recovery
   fixtures outside CI, then promote only what the evidence supports.
2. Julia: add roundtrip tests from free parameters to covariance and metadata.
3. R/docs: keep `cov = fa(K)` examples planned-only until the engine row is
   stronger than partial.
4. R: reserve extractor names only if they error with rotation-aware planned
   wording.

