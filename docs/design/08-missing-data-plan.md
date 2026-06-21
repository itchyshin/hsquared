# Missing-Data Handling Plan (PLANNED)

Status: **planned, not implemented. No capability is claimed.** The M0 grammar
contract below is ratified as the planned R surface, but there is still no
missing-data fitting code in the R lane (no exported `mi()`, `miss_control()`,
`impute_model()`, `imputed()`, or `na.action` override) and no missing-data
engine support in `HSquared.jl`. This note records the contract and sister-repo
reuse map so the eventual implementation reuses proven patterns rather than
reinventing them.

## Why this note

The standing missing-data directive (user, 2026-06-13; recorded verbatim in
[`ROADMAP.md`](../../ROADMAP.md), commit `acc54af`) asks the project to plan
model-based missing-data handling for **both** missing phenotypes (response) and
missing covariates (predictors), reusing the substantial work already in the
sister teams — `drmTMB` / `gllvmTMB` (R) and `DRM.jl` / `GLLVM.jl` (Julia) —
rather than reinventing it. The directive specifies the approach: model-based
FIML / marginal ML via Laplace (not impute-then-analyze, not Bayesian/MCMC). It
assigns the R lane the syntax surface and validation, and the integration to the
Julia engine. This note synthesizes four read-only sister-repo scouts against
that directive.

## Scope

Two regimes, both model-based:

- **(A) Missing responses (missing phenotypes, `y`).** Rows with missing `y` are
  kept in the model frame, not dropped, and contribute zero direct likelihood
  via an observed-`y` mask. Fitted values, EBVs/BLUPs, residuals, and
  predictions are retained for the masked cells (the ASReml-like behaviour the
  directive names).
- **(B) Missing covariates (missing predictors, `x`).** The missing values
  become latent quantities integrated out by the engine, conditional on an
  explicit predictor model whose covariance is **level-aware**: an
  individual/animal-level covariate can borrow additive-genetic structure
  (pedigree → `Ainv` / `relmat`); a higher-level covariate (e.g. species) can
  borrow that level's structure. This is the directive's "species →
  pedigree/relmat" requirement expressed in hsquared's own grammar.

**Explicit non-scope for the first implementation slices** (state this in any
public text to prevent overclaim): multiple simultaneous missing covariates;
transformed `mi()` terms (`mi(log(x))`); missing values inside the predictor
formula RHS; non-Gaussian missing-covariate predictor models with structured
effects; combined missing-response + REML; MNAR / non-ignorable missingness
(sensitivity analysis is a later gate). Multiple imputation is a separate
workflow, not part of `miss_control()`.

## Approach (FIML / Laplace)

The shared mechanism across all four sister packages is consistent and should be
the spine of the implementation:

1. **Observed-`y` mask (regime A).** Carry a logical mask parallel to `y`; gate
   each per-row likelihood contribution so a masked row adds zero log-likelihood
   but keeps its design contribution (its fitted value / EBV stays defined).
   Identical pattern in `drmTMB` (`if (observed_y(i) == 1)`), `gllvmTMB`
   (`is_y_observed`), `DRM.jl` (row-wise `observed` mask, expand to full length
   with `NaN`), and `GLLVM.jl` (per-cell `ismissing(y[t])` → score/weight 0,
   Hessian stays SPD). Cheap correctness gate: a *sentinel-invariance* test (the
   fit is identical whether the masked `y` is `0` or `1e6`).
2. **Latent-variable integration (regime B).** Factor the joint density as
   `p(y | x, θ) · p(x | predictor model, θ_x)`; for observed `x` evaluate both
   terms, for missing `x` integrate over the latent `x`. Family-dispatched:
   Gaussian covariate → latent continuous integrated by Laplace; discrete
   covariate → exact finite-state summation (log-sum-exp), returning state
   probabilities; continuous non-Gaussian → fixed-node quadrature. For the v0.1
   univariate Gaussian animal model the only in-scope target is Laplace
   integration of one latent **Gaussian** covariate.
3. **Level-aware predictor covariance.** The predictor model's RHS may carry
   hsquared's existing structured terms so the latent covariate borrows the
   right covariance — `animal(1 | id, pedigree = ped)` / `relmat(1 | id, K = K)`
   for an individual-level covariate. (`gllvmTMB` reuses its own
   `phylo(0+1|species)` precision inside the impute formula; `GLLVM.jl`
   augments the loading rank for a site-level Gaussian covariate.)
4. **Frequentist output vocabulary.** Point estimates are conditional modes /
   EBLUPs; SEs come from the joint Hessian. Use "EBLUP" / "conditional mode" /
   "prediction SE" / "imputed (conditional mode)" — **never** "posterior mean"
   or "credible interval" (enforces the no-Bayesian directive).

## Ratified M0 R syntax surface (planned, not implemented)

Missing responses:

```r
hsquared(y ~ sex + animal(1 | id, pedigree = ped), data = dat,
         family = gaussian(), REML = TRUE,
         missing = miss_control(response = "include"))
```

Missing covariate (latent path):

```r
hsquared(y ~ sex + mi(body_mass) + animal(1 | id, pedigree = ped),
         data = dat, family = gaussian(),
         missing = miss_control(predictor = "model"),
         impute  = list(body_mass = body_mass ~ sex + animal(1 | id, pedigree = ped)))
```

Planned control object (mirrors `gllvmTMB::miss_control()`):

```r
miss_control(response  = c("drop", "include"),   # default "drop": complete-case, backward compatible
             predictor = c("fail", "model"),     # default "fail": error on missing x unless modeled
             engine    = "laplace")               # only accepted value in v1; "em"/"profile" reserved
```

- `mi(x)` marks `x` as missing-and-modelled; **bare variable only** in v1 (no
  transforms/interactions), with a clear error otherwise (matches both R
  sisters).
- `impute = list(<var> = <var> ~ <rhs>)`; the RHS may carry hsquared structured
  terms for the level-aware covariance. A non-Gaussian predictor family would
  use a proposed `impute_model(x ~ rhs, family = ...)` factory (only
  `gaussian()` needed for v0.1).
- Proposed extractors: `predict_missing(fit, type=)` (masked-response cells +
  fitted values); `imputed(fit, variable=, rows=, se=)` (covariate conditional
  modes + SE, or discrete state probabilities); `fit$missing_data` metadata.

Token name `mi()` is accepted deliberately for cross-package transfer
(`drmTMB`, `gllvmTMB`, and the planned `GLLVM.jl` R bridge all use `mi()`),
supporting the "R and Julia syntax stay transferable" mantra.

### Accepted, deferred, and error wording

Accepted planned syntax:

- `missing = miss_control(response = "include")` for future masked-response
  rows.
- `missing = miss_control(predictor = "model")` plus one `mi(x)` term for a
  future modelled missing predictor.
- `impute = list(x = x ~ ...)` as the predictor-model surface; bare formulas are
  Gaussian shorthand, and `impute_model()` remains the future family-explicit
  factory.
- Explicit structured terms in the impute RHS, e.g.
  `animal(1 | id, pedigree = ped)`, rather than inferred level mapping.

Deferred or rejected syntax for the first implementation:

- transformed or interacting `mi()` terms such as `mi(log(x))` or `mi(x):z`;
- more than one `mi()` predictor;
- missing values inside impute-model predictors;
- missing-predictor models under `REML = TRUE`;
- multiple imputation, MCMC, posterior summaries, MNAR sensitivity, and
  predictor-model families beyond the first Gaussian slice.

Planned user-facing errors should be specific:

- `mi()` terms require `missing = miss_control(predictor = "model")`.
- The first `mi()` layer supports only a bare predictor such as `mi(body_mass)`.
- `impute = list(body_mass = body_mass ~ ...)` must name the same variable used
  inside `mi(body_mass)`.
- Missing-data handling is planned in hsquared; no `mi()` or `miss_control()`
  function is exported yet.

## Julia-lane integration (PLANNED — twin work, do not implement from this repo)

The directive states this is "important for `HSquared.jl` too." When designed,
record the payload additions in [`03-engine-contract.md`](03-engine-contract.md)
via the shared bridge contract (Hopper/Gauss/Karpinski/Noether coordinate):

- `observed_response::BitVector` parallel to `y`; gate every likelihood
  contribution. SPD of the coefficient matrix is preserved (masked rows add zero
  weight).
- For a missing covariate: an `mi_family` dispatch code, `mi_observed` mask,
  observed values, the predictor-model design, and the structured-precision
  handle (the same sparse `Ainv` already marshalled for `animal()`).
- Mask-gated likelihood reuses the existing sparse-REML / Henderson MME path
  (regime A). Latent-covariate integration appends the latent covariate to the
  Laplace-integrated set and delta-corrects the affected rows' linear predictor
  (regime B).
- Return EBLUPs + prediction SEs from the joint Hessian inverse block; fitted
  values for masked responses. No posterior/MCMC objects.

**Key engine caveat:** `DRM.jl` supports missing responses for *fixed-effect*
models only and explicitly rejects random-effect/structured missing-response;
it has no missing-predictor support. So the animal-model masked-response path
and any missing-predictor path are **new** `HSquared.jl` work adapting these
patterns, not a lift of finished code.

## Reuse map

Distinguish files verified PRESENT in the local checkouts from one
FORWARD/UNVERIFIED reference. Adapt the architecture/process; do not copy
statistical claims without independent validation.

R-lane references (surface to adapt — present, verified):

- `drmTMB/R/missing-data.R` — `miss_control()` signature, `impute_model()`
  factory + family validators, `mi()` parsing, `imputed()` extractor.
- `gllvmTMB/R/missing-predictor.R` — **primary R reference** (closest design
  intent): `miss_control(response, predictor, engine="laplace")`, the recursive
  `mi()` parser, impute-contract validation, and the `phylo()`-in-impute-formula
  level-aware pattern that maps to hsquared's `animal()`-in-impute-formula.
- `gllvmTMB/R/fit-multi.R` — how the latent covariate name is appended to the
  integrated set (what the R lane must marshal).
- `drmTMB/vignettes/missing-data.Rmd` — template for the hsquared vignette.

Engine references (Julia/C++ patterns — present, verified):

- `DRM.jl/src/gaussian_core.jl` — response-mask mechanism (regime A); fixed-effect
  only (rejects structured), so adapt, don't lift.
- `DRM.jl/src/sparse_aug_plsm.jl` — **high-value reuse**: sparse augmented-state
  prior precision from a tree/relmat topology = the level-aware covariance the
  directive names; inner mode-finder `estep_mode`; pair with
  `takahashi_selinv.jl` for O(p) gradients.
- `GLLVM.jl/src/families/laplace.jl` — per-cell masking + Fisher-scoring Laplace
  mode-finder; the cleanest pure-Julia Laplace marginal to model the engine loop on.
- `drmTMB/src/drmTMB.cpp`, `gllvmTMB/src/gllvmTMB.cpp` — the `mi_family` dispatch
  architecture and the covariate delta-correction idiom (TMB/C++ patterns to
  mirror in Julia, not portable).

FORWARD / UNVERIFIED (do not cite as present):

- `GLLVM.jl/src/missing_predictor_fiml.jl` (`fit_gaussian_mi_fiml`, cited at
  commit `9dc5a42`) — the closed-form Gaussian mi-FIML kernel (rank `K → K+1`
  augmented loading) was **not found in the current checkout**. Treat as a
  forward reference on an unmerged branch; locate and confirm the commit before
  adapting. The closed-form idea is conceptually the best fit for an all-Gaussian
  level covariate, but its provenance is unverified.

## Phasing (planned ordering)

- **M0 (this note):** record the design as PLANNED. No fitting code. Boole signs
  off the syntax surface; Noether/Henderson sign off the level-aware estimand;
  Hopper records the planned payload additions in the engine contract; Rose
  audit confirms no capability claim leaks into README/DESCRIPTION/vignettes.
  The formula-status table now lists the planned missing-data surface so users
  can see the reserved direction without any parser activation.
- **M1 (after the v0.1 fit gate opens):** missing responses for the univariate
  Gaussian animal model (regime A) — smallest honest slice; reuses the
  REML/Henderson path with a mask gate. Gate: sentinel-invariance + EBV-retention
  + a Mrode-style fixture with an artificially masked phenotype.
- **M2:** one missing Gaussian covariate at the animal level with a
  pedigree/relmat-structured predictor model (regime B, the directive's core).
  Gate: parameter recovery vs complete-case on simulated data; Laplace-vs-bootstrap
  SE cross-check; level-aware-vs-independent comparison.
- **M3+ (with the multivariate / GLLVM phases):** discrete missing covariates
  (exact summation), multiple missing covariates, and missing covariates under
  multivariate/factor-analytic G. MNAR sensitivity is a separate later gate.

Missing-data handling is **not part of v0.1** and must not block or contaminate
the v0.1 REML promotion predicate (both R sisters defer REML + missing-data, so
M1/M2 are ML-first with REML deferred). The R lane can land M0 and the M1
syntax+validation surface ahead of the engine, exactly as the fenced opt-in
bridge targets (`sparse_reml`/`ai_reml`) were surfaced ahead of production
fitting.

## Resolved contract decisions and open questions

Resolved for M0:

1. Keep `miss_control()` separate from `hs_control()` because it describes the
   statistical missing-data treatment, not engine execution.
2. Use `mi()` as the token name for cross-package transfer from `drmTMB` and
   `gllvmTMB`.
3. Use `impute = list(x = x ~ ...)`; a future `impute_model()` factory supplies
   explicit predictor families.
4. Require explicit level mapping in the impute RHS rather than inferring it
   from `hs_data()` keys.
5. Keep the default response behavior as `"drop"` for backward compatibility.
6. Treat M1/M2 as ML-first with REML deferred, isolated from the v0.1 REML
   predicate.
7. Use frequentist output vocabulary only: EBLUP, conditional mode, prediction
   SE, fitted missing response. Do not use posterior or credible-interval
   wording for this route.

Still open:

1. Confirm the `GLLVM.jl` mi-FIML provenance (commit `9dc5a42` / branch) before
   treating it as a reuse asset.
2. Identifiability (Noether/Henderson/Fisher): is a pedigree-structured latent
   covariate identifiable when the response model also carries `animal(1|id)` on
   the same level? `gllvmTMB` warns of confounding and defaults to independent
   structure; hsquared needs its own ruling for the animal model before M2.
