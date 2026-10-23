# Structured Covariance R-Control Contract

Status: **partial**. `diagonal` is an experimental multivariate engine control.
The four-trait, rank-one Gaussian pedigree `factor_analytic` cell is also an
experimental expert-control R route. Both use the opt-in
`cbind(...) ~ animal(1 | id, pedigree = ped)` grammar and estimate an
unstructured residual `R0`. `lowrank` and all `cov = us()/diag()/lowrank()/fa()`
formula grammar remain closed. The FA route is a bounded usable cell, not a
broad identifiability, inference, recovery, or comparator claim. In particular,
fixed rank alone does not identify every uniqueness variance. The
rotation/interpretation convention exposes invariant `G` functionals, never
raw loadings; see `29-structured-covariance-eigenbasis-bridge-contract.md`.

## Purpose

The Julia twin and R bridge expose `diagonal` and one bounded
`factor_analytic` cell as experimental controls. This note records their R
contract and the gates for wider structured covariance support.

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
dense validation-scale REML path. The two-trait unstructured model also has a
covered default route. The explicit control spelling shown here remains
available; this note's diagonal and bounded FA controls are partial.

The bounded FA route uses exactly four complete Gaussian traits, a pedigree
relationship, trait intercepts, one genetic factor, and estimated unstructured
`R0`:

```r
fit_fa <- hsquared(
  cbind(y1, y2, y3, y4) ~ animal(1 | id, pedigree = ped),
  data = dat,
  family = gaussian(),
  control = hs_control(engine = "julia", engine_control = list(
    target = "multivariate", genetic_structure = "factor_analytic",
    rank = 1L, julia_project = "/path/to/HSquared.jl"
  ))
)
G_matrix(fit_fa)
genetic_correlation(fit_fa)
specific_variance(fit_fa)
fit_diagnostics(fit_fa)
```

`julia_project` must identify an installed local Julia twin. The reported
uniqueness values are model parameters whose separate identification depends
on the fitted loading pattern; a four-trait rank-one shape alone does not
guarantee it. Structured covariance standard errors and raw-loading inference
are withheld.

## Structured Bridge Controls

The structured R bridge preserves the current formula and uses an expert
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

Accepted values and status:

```text
unstructured       live experimental
diagonal           live experimental
lowrank            reserved, rejected
factor_analytic    live only for the four-trait rank-one cell above
```

The R bridge maps the active values to Julia symbols:

```text
"unstructured"     -> :unstructured
"diagonal"         -> :diagonal
"lowrank"          -> :lowrank (reserved; rejected before dispatch)
"factor_analytic"  -> :factor_analytic
```

The control field is intentionally named `genetic_structure`, not `cov`, because
the bridge constrains only the additive-genetic `G0`. Residual covariance
`R0` remains unstructured unless a separate, validated residual-structure
contract is added.

## Rank And Initial Values

The live FA cell requires explicit `rank = 1L`. `lowrank` remains reserved;
its rank example is a design sketch, not an accepted control:

```r
engine_control = list(
  target = "multivariate",
  genetic_structure = "lowrank",
  rank = 2
)

engine_control = list(
  target = "multivariate",
  genetic_structure = "factor_analytic",
  rank = 1L
)
```

For the live FA bridge, only `G0` and `R0` matrix starts are accepted. The
Julia engine derives its loading and uniqueness starts from `G0`. Supplying
`loadings` or `uniqueness` through the R `initial` control errors explicitly;
it is not silently discarded. The following structure-specific starts remain
design sketches for a later widened bridge:

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

# factor analytic direct-loading starts are not R-accepted in this arc
```

R rejects unsupported start fields, rank values, and dimensions before calling
Julia.

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

Structured metadata should be additive and **rotation-invariant** (per the
ratified eigenbasis contract,
`29-structured-covariance-eigenbasis-bridge-contract.md`):

```text
genetic_structure
genetic_rank
genetic_eigenvalues        # additive genetic variance per principal axis
genetic_principal_axes     # sign-canonicalized eigenvectors of G
genetic_uniqueness         # Psi, live only in the bounded FA cell
n_genetic_params           # for nested-structure LRTs
```

Raw loadings (`genetic_loadings`) are **not bridged as identified estimates** and
carry no standard error; they may appear only as an explicitly-flagged,
display-only, rotation-arbitrary reconstruction. The R object should remain
useful even when users ignore loadings: `G_matrix()`, `R_matrix()`,
`genetic_correlation()`, and `heritability()` must still be the first teaching
surface.

## Error Rules

Until formula-level grammar is live, R should keep failing loudly:

```text
`animal()` argument `cov` is planned, not implemented.
```

The R bridge accepts the bounded FA expert control above and blocks wider
structured cases before Julia marshalling:

```text
`engine_control$genetic_structure` must be one of "unstructured", "diagonal",
"lowrank", or "factor_analytic".

`genetic_structure = "lowrank"` is reserved. `factor_analytic` requires the
explicit four-trait Gaussian rank-one pedigree cell; other trait counts,
families, missing responses, extra effects, and formula-level `cov = fa()` are
unsupported.

`engine_control$rank` must be `1L` for the bounded FA route and is rejected for
unstructured and diagonal controls. It does not trigger automatic rank
selection. Auto-rank is a separately validated usability follow-on.
```

For formula-level `cov = ...`, the error should continue pointing users to the
current `cbind()` path and say that long-format structured covariance grammar is
planned.

## Validation Gates

Before promoting or widening structured bridge support in R:

1. The Julia structured covariance engine and exact R bridge revision are
   pinned for comparison.
2. Julia `validation_status()` keeps the row `partial` unless recovery evidence
   passes signed-off thresholds.
3. R bridge tests continue to cover `genetic_structure = "diagonal"` with a
   deterministic fixture and expected zero off-diagonal `G0`.
4. R bridge tests cover the bounded FA rank and initial-value validation;
   low-rank remains a negative test.
5. Extractor tests confirm `G_matrix()` reconstructs
   `Lambda Lambda' (+ Psi)` from returned metadata.
6. A separate identification and uncertainty contract is signed before any
   `loadings()` inference claim.
7. Public docs still say partial unless there is known-truth recovery and
   comparator evidence.

## Scout Summary

Local lessons:

- `gllvmTMB` shows the importance of targeted guardrails for diagonal,
  reduced-rank, full-rank, and unique/residual covariance terms.
- `GLLVM.jl` shows the computation pattern for low-rank-plus-diagonal
  covariance: keep `Lambda Lambda' + diag(d)` explicit and use Woodbury-style
  operations rather than materialising large dense matrices.
- `HSquared.jl` has structured covariance support; R surfaces `diagonal` and
  the bounded four-trait rank-one FA cell. Broader loading-bearing support
  remains gated.
- HSquared.jl PR #144 (`023c675`) is a status/issue-body sync, not a new bridge:
  it separates the banked `:diagonal`/`:unstructured` payload evidence from the
  still-blocked lowrank/fa loading exposure, R activation, and comparator gates.

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
2. Validate the bounded FA bridge with same-data R/Julia parity and an
   independent same-model Gaussian FA/REML comparator. Keep failed fits in the
   denominator.
3. Keep `cov = diag()` / `lowrank()` / `fa()` as planned formula grammar until
   long-format trait ordering and residual-structure semantics are settled.
