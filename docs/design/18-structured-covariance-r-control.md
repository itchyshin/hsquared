# Structured Covariance R-Control Contract

Status: **design note only**. No R-facing structured covariance fit is exposed
by this note. The current live multivariate grammar remains the opt-in
`cbind(...) ~ ... + animal(1 | id, pedigree = ped)` path with unstructured
`G0`/`R0`.

## Purpose

The Julia twin has a Phase 4B branch with partial structured genetic covariance
support (`diagonal`, `lowrank`, and `factor_analytic`). The branch has green PR
checks, but the commits are not on `HSquared.jl` `origin/main`, and R has no
bridge tests for the structured result shape. This note defines the R contract
to implement once that engine surface is on main and R can verify it.

## Current Live Path

Users who need the current multivariate path write traits on the left-hand
side:

```r
fit <- hsquared(
  cbind(y1, y2) ~ sex + animal(1 | id, pedigree = ped),
  data = dat,
  family = gaussian(),
  control = hs_control(
    engine = "julia",
    engine_control = list(target = "multivariate")
  )
)
```

This estimates unstructured trait-scale `G0` and `R0` through the Julia-owned
dense validation-scale REML path. It remains opt-in, experimental, and partial.

## First Structured Bridge

The first R bridge should preserve the current formula and add only an expert
control field:

```r
fit_diag <- hsquared(
  cbind(y1, y2, y3) ~ sex + animal(1 | id, pedigree = ped),
  data = dat,
  family = gaussian(),
  control = hs_control(
    engine = "julia",
    engine_control = list(
      target = "multivariate",
      genetic_structure = "diagonal"
    )
  )
)
```

Accepted planned values:

```text
unstructured
diagonal
lowrank
factor_analytic
```

The R bridge should map these to Julia symbols only after the engine is on
main:

```text
"unstructured"     -> :unstructured
"diagonal"         -> :diagonal
"lowrank"          -> :lowrank
"factor_analytic"  -> :factor_analytic
```

The control field is intentionally named `genetic_structure`, not `cov`, because
the first bridge constrains only the additive-genetic `G0`. Residual covariance
`R0` remains unstructured unless a separate, validated residual-structure
contract is added.

## Rank And Initial Values

`rank` is required for low-rank and factor-analytic structures:

```r
engine_control = list(
  target = "multivariate",
  genetic_structure = "lowrank",
  rank = 2
)

engine_control = list(
  target = "multivariate",
  genetic_structure = "factor_analytic",
  rank = 2
)
```

Initial values should be named and structure-specific:

```r
# unstructured / current live shape
initial = list(
  G0 = diag(1, ntraits),
  R0 = diag(1, ntraits)
)

# diagonal
initial = list(
  genetic_variance = rep(1, ntraits),
  R0 = diag(1, ntraits)
)

# lowrank
initial = list(
  loadings = matrix(0.1, ntraits, rank),
  R0 = diag(1, ntraits)
)

# factor analytic
initial = list(
  loadings = matrix(0.1, ntraits, rank),
  uniqueness = rep(0.5, ntraits),
  R0 = diag(1, ntraits)
)
```

R should not silently recycle or invent dimensions when users provide
structure-specific initial values. A rank or dimension mismatch should stop
before calling Julia.

## Future Formula Grammar

The public formula grammar remains planned:

```r
animal(trait | id, pedigree = ped, cov = us())
animal(trait | id, pedigree = ped, cov = diag())
animal(trait | id, pedigree = ped, cov = lowrank(K = 2))
animal(trait | id, pedigree = ped, cov = fa(K = 2))
```

Definitions:

```text
us():          G0 full unstructured covariance
diag():        G0 = diag(g)
lowrank(K):    G0 = Lambda Lambda'
fa(K):         G0 = Lambda Lambda' + Psi
```

The formula grammar should wait until the R lane has:

- long/wide trait ordering tests;
- structured covariance parser tests;
- result metadata tests;
- planned-error tests for unsupported combinations;
- documentation that separates `G0` structure from residual `R0` structure.

## Result Payload

Future structured results should preserve the invariant covariance fields first:

```text
genetic_covariance
residual_covariance
genetic_correlation
residual_correlation
heritability
breeding_values
```

Structured metadata should be additive:

```text
genetic_structure
genetic_rank
genetic_loadings
genetic_uniqueness
loading_sign_convention
rotation_method
```

The R object should remain useful even when users ignore loadings: `G_matrix()`,
`R_matrix()`, `genetic_correlation()`, and `heritability()` must still be the
first teaching surface.

## Error Rules

Until formula-level grammar is live, R should keep failing loudly:

```text
`animal()` argument `cov` is planned, not implemented.
```

The R bridge now accepts the reserved expert control only for the current
unstructured case and blocks the structured cases before Julia marshalling:

```text
`engine_control$genetic_structure` must be one of "unstructured", "diagonal",
"lowrank", or "factor_analytic".

Structured multivariate genetic covariance controls
(`genetic_structure = "diagonal"`, "lowrank", or "factor_analytic") are
planned, not implemented in the R bridge. The current opt-in multivariate path
estimates unstructured G0/R0 only; omit `genetic_structure` or set it to
"unstructured".
```

For formula-level `cov = ...`, the error should continue pointing users to the
current `cbind()` path and say that long-format structured covariance grammar is
planned.

## Validation Gates

Before exposing any structured bridge in R:

1. The Julia structured covariance commits are on `HSquared.jl` `main`.
2. Julia `validation_status()` keeps the row `partial` unless recovery evidence
   passes signed-off thresholds.
3. R bridge tests cover `genetic_structure = "diagonal"` with a deterministic
   fixture and expected zero off-diagonal `G0`.
4. R bridge tests cover `rank` and initial-value validation for `lowrank` and
   `factor_analytic`.
5. Extractor tests confirm `G_matrix()` reconstructs
   `Lambda Lambda' (+ Psi)` from returned metadata.
6. Rotation/sign metadata is present before `loadings()` returns interpretable
   values.
7. Public docs still say partial unless there is known-truth recovery and
   comparator evidence.

## Scout Summary

Local lessons:

- `gllvmTMB` shows the importance of targeted guardrails for diagonal,
  reduced-rank, full-rank, and unique/residual covariance terms.
- `GLLVM.jl` shows the computation pattern for low-rank-plus-diagonal
  covariance: keep `Lambda Lambda' + diag(d)` explicit and use Woodbury-style
  operations rather than materialising large dense matrices.
- `HSquared.jl` already has a structured covariance branch with tests and
  partial validation rows, but it is not on main.

External lessons:

- sommer and ASReml both make named covariance structures central to
  multivariate mixed-model workflows, but their syntax is not the contract for
  `hsquared`.
- gllvm reinforces the need to separate latent-factor modelling from ordinary
  covariance extraction: users can read covariance matrices before interpreting
  axes.

## Immediate Next Slices

1. Watch `HSquared.jl#17` and only build R bridge code after the branch reaches
   Julia `main`.
2. Add R tests for diagonal `genetic_structure` first, because it has the
   clearest invariant (`G0` off-diagonal entries are zero).
3. Add low-rank and factor-analytic R bridge tests only after rank and loading
   metadata are stable.
4. Keep `cov = diag()` / `lowrank()` / `fa()` as planned formula grammar until
   long-format trait ordering and residual-structure semantics are settled.
