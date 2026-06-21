# Structured Covariance R-Control Contract

Status: **partial**. The rotation-free `:diagonal` genetic-covariance structure
is now R-surfaced as an experimental engine control —
`engine_control = list(genetic_structure = "diagonal")` on the opt-in
multivariate target, with `covariance_structure_lrt()` for the
diagonal-vs-unstructured test (fixture-verified against the twin
`structured_covariance_parity` target; live fit skip-guarded). The current live
multivariate grammar remains the opt-in
`cbind(...) ~ ... + animal(1 | id, pedigree = ped)` path with `unstructured` (or
now `diagonal`) `G0` and unstructured `R0`. The `lowrank`/`fa` structured fits
and the `cov = us()/diag()/lowrank()/fa()` formula grammar described below
remain design-note only, gated on a validated rotation/interpretation
convention for the loadings.

## Purpose

The Julia twin and R bridge now expose the rotation-free `diagonal` subset of
structured genetic covariance as an experimental control. This note records the
current R contract for that shipped subset and the still-gated contract for
`lowrank`/`factor_analytic` support once loading metadata, rotation semantics,
and validation evidence are ready.

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

The R bridge accepts the reserved expert control for the current unstructured
and diagonal cases, and blocks the rotation-ambiguous structured cases before
Julia marshalling:

```text
`engine_control$genetic_structure` must be one of "unstructured", "diagonal",
"lowrank", or "factor_analytic".

Structured multivariate genetic covariance controls
(`genetic_structure = "lowrank"` or "factor_analytic") are planned, not
implemented in the R bridge. The current opt-in multivariate path estimates
unstructured or diagonal G0 with unstructured R0; use "unstructured" or
"diagonal".

`engine_control$rank` is reserved for future `lowrank` and `factor_analytic`
structured covariance controls. The current multivariate bridge estimates
unstructured or diagonal G0 only; remove `rank` until low-rank or
factor-analytic support is available.
```

For formula-level `cov = ...`, the error should continue pointing users to the
current `cbind()` path and say that long-format structured covariance grammar is
planned.

## Validation Gates

Before exposing more structured bridge support in R:

1. The Julia structured covariance commits are on `HSquared.jl` `main`.
2. Julia `validation_status()` keeps the row `partial` unless recovery evidence
   passes signed-off thresholds.
3. R bridge tests continue to cover `genetic_structure = "diagonal"` with a
   deterministic fixture and expected zero off-diagonal `G0`.
4. New R bridge tests cover `rank` and initial-value validation for `lowrank` and
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
- `HSquared.jl` already has partial structured covariance support on main. R
  only surfaces the rotation-free diagonal subset; loading-bearing
  low-rank/factor-analytic support remains gated.

External lessons:

- sommer and ASReml both make named covariance structures central to
  multivariate mixed-model workflows, but their syntax is not the contract for
  `hsquared`.
- gllvm reinforces the need to separate latent-factor modelling from ordinary
  covariance extraction: users can read covariance matrices before interpreting
  axes.

## Immediate Next Slices

1. Keep `genetic_structure = "diagonal"` fixture coverage green while validation
   evidence remains partial.
2. Add low-rank and factor-analytic R bridge tests only after rank and loading
   metadata are stable.
3. Keep `cov = diag()` / `lowrank()` / `fa()` as planned formula grammar until
   long-format trait ordering and residual-structure semantics are settled.
