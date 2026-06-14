# Multivariate (Multi-Trait) Animal Model Plan (PARTIAL)

Status: **implemented as an opt-in, experimental R surface; still partial.**
`hsquared` now parses a `cbind(...)` multivariate response, builds an
NA-preserving `Y` bridge payload, surfaces Julia
`HSquared.fit_multivariate_reml()` through `engine = "julia", target =
"multivariate"`, and exposes G/R covariance and correlation matrices,
per-trait heritability, and cross-trait EBVs. The Julia engine is on
`HSquared.jl` `main` (`f9da6bb`). This is not the default path, not
ASReml-style production multi-trait parity, not an external-comparator claim,
and not a t>=2 known-truth recovery claim.

## Why this note

This is Phase 3 of [`ROADMAP.md`](../../ROADMAP.md) (multivariate Gaussian
animal models). The first R slice deliberately stays narrow: ordinary
`cbind()` multi-trait responses with one additive `animal()` term. Long-format
`animal(trait | id, cov = ...)`, factor-analytic covariance structures, external
comparators, and recovery promotion remain future gates.

## Engine contract

`src/multivariate.jl` exports `fit_multivariate_reml`, `multivariate_mme`, and
`genetic_correlation`. Gate rows `V4-MULTIVARIATE` and `V4-MV-REML` are
`partial` on Julia `main`.

```
fit_multivariate_reml(Y, X, Z, Ainv; initial = (G0 = ..., R0 = ...), iterations, ids, traits)
```

- `Y` is `n × t` (records × traits); **missing trait records are supported**
  (an internal observed-mask drops only the missing trait cells, not the whole
  record).
- `X` is `n × p` (fixed-effect design), `Z` is `n × q` (record→individual
  incidence), `Ainv` is `q × q` (sparse pedigree inverse). `Z`/`Ainv` are
  identical to the univariate animal-model path.
- Estimates `G0` (`t × t` additive-genetic covariance) and `R0` (`t × t`
  residual covariance) by REML (NelderMead on a Cholesky parameterization,
  positive-definite by construction).
- Returns: `genetic_covariance` (G0), `residual_covariance` (R0),
  `genetic_correlation`, `residual_correlation`, `heritability` (per-trait
  diagonal `G0[k,k]/(G0[k,k]+R0[k,k])`), `beta` (fixed effects),
  `breeding_values = (ids, traits, values)` (cross-trait EBVs), `loglik`,
  `converged`, `iterations`, `traits`.

### Build notes from the merge-readiness review (2026-06-14)

A 6-lens independent review (run `wf_113bd991-2b0`) of the engine returned
**0 blockers** (full twin test suite passes locally; math verified live). The
following concrete findings **must be folded into the R slice** when it is
built:

- **Missing-trait marshalling.** The engine's missing sentinel is `NaN` (or
  Julia `missing`), not R `NA` per se. `JuliaCall::julia_assign` delivers an R
  `NA_real_` in a numeric matrix as Julia `NaN`, which the engine masks
  correctly — so the R bridge marshals `Y` as a plain numeric matrix and lets
  `NA → NaN` happen by default. This is **not** already exercised by the `X`
  path (`X` never carries `NA`); the slice must add a test that an `NA` cell
  round-trips to a dropped trait record.
- **`initial` is a named tuple.** The engine reads `initial.G0` / `initial.R0`,
  so the bridge must emit Julia `(G0 = ..., R0 = ...)` (mirroring the univariate
  `(sigma_a2 = ..., sigma_e2 = ...)`), not a bare 2-tuple.
- **`loglik` is not always a valid REML logLik.** On a rank-deficient `X`
  (redundant fixed effects — a common user mistake) the optimizer never finds a
  finite REML objective, returns `converged = false`, and `loglik` falls back to
  a non-REML value. The R bridge must **guard rank-deficient `X` up front** (R
  `model.matrix` can produce it) and must **not** present `loglik` for LRT/AIC
  when `converged` is false.
- **Conditioning caveat (honesty fence).** The GLS/REML/BLUP path re-inverts the
  supplied `Ainv` to a dense `A`; this is exact on well-conditioned pedigrees but
  degrades on deep inbreeding (large `cond(A)`). The R validation row /
  boundary must carry this as an experimental, dense, validation-scale caveat
  (it is a twin-side `SHOULD-FIX`, recorded for the Julia lane).
- **Promotion gate.** The committed twin tests do not yet include a known-truth
  `t ≥ 2` genetic-correlation + per-trait-h2 recovery fixture (the cited
  12-replicate sim is uncommitted), and the log-Cholesky map has no direct
  roundtrip unit test. The R multivariate validation row must therefore stay
  honestly `partial` (no recovery claim) until the twin adds those tests.

## R surfacing

### Grammar

A multi-trait response via the standard R `cbind()` idiom on the LHS, reusing
the existing `animal()` primary unchanged:

```r
hsquared(
  cbind(weight, height) ~ sex + animal(1 | id, pedigree = ped),
  data = dat,
  family = gaussian(),
  REML = TRUE
)
```

- `cbind(...)` is the transferable multivariate-response convention (sommer,
  MCMCglmm, `brms::mvbind`), so the common multi-trait path reads like the model
  an applied user already has in mind (User Interface Mantra).
- The LHS columns map directly to the engine's `Y` (`n × t`); `NA` cells become
  missing trait records (the engine masks them). The RHS fixed and `animal()`
  terms are parsed exactly as in the univariate path.
- Trait labels come from the `cbind` column names and flow to `traits`.

Trait order is a binding part of the payload and extractor contract. The
standing ordering rule is recorded in
`docs/design/17-trait-ordering-contract.md`: preserve the user-declared
left-to-right `cbind(...)` order in `Y`, `G0`, `R0`, per-trait h2, EBVs, and
comparator files.

### Bridge payload

The only new payload piece is `Y` (an `n × t` numeric matrix, `NA`-preserving)
plus `trait_names`. `X`, sparse `Z` (CSC), `Ainv`, and the pedigree path are
reused verbatim from the univariate animal model. The R→Julia marshalling of
`Y` reuses the dense-matrix assignment already used for `X`; the `Z`/`Ainv`
alignment invariant (Z columns, `Ainv`, and `ids` share one id order) is
unchanged.

### Target and fence

Surface first as opt-in/experimental — `engine = "julia", target =
"multivariate"` — mirroring the twin `V4-MV-REML` gate (`partial`), REML only,
Julia-owned. Promote toward a default multi-trait path only when the twin marks
`V4-MV-REML`/`V4-MULTIVARIATE` `covered` on Julia `main` and the maintainer
signs off recovery thresholds (a multivariate analogue of the v0.1 promotion
predicate: genetic-correlation recovery, per-trait h2 recovery, convergence
rate, boundary behaviour at |r_g| → 1).

### Extractors

- `genetic_correlation(fit)` and `genetic_covariance(fit)` (the G matrix);
  `residual_correlation(fit)`.
- `heritability(fit)` returns per-trait h2 (one row per trait).
- `breeding_values(fit)` returns cross-trait EBVs (id × trait).
- Kirkpatrick-lens tools (eigenstructure of G, evolvability) are a later
  factor-analytic-G concern (Phase 4), not this slice.

## Promotion gates

Before any claim moves off `partial`, the twin must add committed t>=2
known-truth genetic-correlation and per-trait-h2 recovery evidence, and the
programme needs external-comparator policy for multi-trait fits. The R lane
already has the opt-in grammar/payload/bridge/extractor smoke tests, including
an NA-to-NaN missing-trait marshalling check.

## Lane / coordination

The engine work is the Julia lane's (twin); the R lane owns the grammar, bridge,
and validation surfacing. Do not edit `HSquared.jl` from this repo. The current
R slice is: `cbind` LHS parser -> `Y` payload -> `target = "multivariate"`
bridge -> genetic-correlation/G/per-trait-h2/cross-trait-EBV extractors ->
opt-in fence mirroring `V4-MV-REML`.
