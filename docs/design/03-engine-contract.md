# Engine Contract

The initial bridge contract is deliberately small. It should not expose
algorithm choices before the Julia engine has a stable control surface.

## Initial Payload

```text
response: numeric vector y
fixed_design: matrix X
random_design: sparse matrix Z
Ainv: NULL on the current R side; sparse precision matrix after Julia build
method: :REML or :ML
family: gaussian only
ids: encoded animal IDs
pedigree: normalized id, sire, dam, parent indices, original order
metadata: original names, fixed columns, observed ID map, bridge targets
```

The current R payload builder creates `y`, `X`, sparse `Z`, method, family,
encoded IDs, normalized pedigree metadata, and a Julia target string. It does
not create `Ainv` on the R side.

An experimental JuliaCall path now validates the tiny payload against a sibling
`HSquared.jl` checkout by calling `normalize_pedigree()`,
`pedigree_inverse()`, `fit_animal_model()`, and `result_payload()`. That path
is reachable only with `control = hs_control(engine = "julia")` and sends
R-side `Matrix::dgCMatrix` random-effect designs through sparse CSC slots using
Julia's `sparse_csc_matrix()` helper. It is for local cross-repo contract
testing and is not yet a production bridge.

The same opt-in bridge has an explicit supplied-variance validation target:

```r
hs_control(
  engine = "julia",
  engine_control = list(
    target = "henderson_mme",
    variance_components = c(sigma_a2 = 1.2, sigma_e2 = 0.8)
  )
)
```

That path calls Julia `henderson_mme()` after building `Ainv`. It returns fixed
effects, EBVs/BLUPs, fitted values, variance components, h2, and dense
validation-path PEV/reliability for tiny validation examples. It does not
optimize variance components, does not return a log-likelihood, and is not a
production sparse fitting or production reliability claim.

The same supplied-variance validation shape also supports the experimental
animal-only metafounder target:

```r
hs_control(
  engine = "julia",
  engine_control = list(
    target = "metafounder",
    variance_components = c(sigma_a2 = 1.2, sigma_e2 = 0.8)
  )
)
```

R sends `group_of` labels aligned to normalized pedigree IDs and a dense,
supplied, finite symmetric positive-semidefinite `Gamma` matrix, then calls
Julia `metafounder_animal_model()`. `Gamma` and variance components are supplied,
not estimated; this path is dense validation-scale only.

## Initial Julia Result

```text
converged
optimizer_status
loglik
reml_loglik
variance_components
fixed_effects
breeding_values
prediction_error_variance
reliability
heritability
gradient_norm
iterations
warnings
id_map
```

The R fitted-object contract currently expects these fields to arrive as a
compact result list. Extractor methods are already defined for
`variance_components`, `heritability`, `breeding_values`, `fixed_effects`,
`random_effects`, `loglik`, `df`, `nobs`, `predictions`, `diagnostics`, and
`converged`. The experimental Julia engine path can normalize the current Julia
result into this shape for a tiny example. Default, sparse, and explicit
AI-REML bridge routes consume the standard `prediction_error_variance` and
`reliability` fields from Julia `result_payload()` when present; current engines
emit them via `:selinv`. Direct calls to exported dense validation extractors
are retained only as a backward-compatible fallback for older local engines
whose payloads do not yet carry those fields. R `fitted()` and `residuals()`
methods use the normalized
`predictions` field and stored response vector when both are available. R
`EBV()` and `BLUP()` are aliases for `breeding_values()`, and `accuracy()` is a
derived square-root reliability extractor when reliability estimates are
present.

The supplied-variance Henderson MME bridge returns a smaller result shape:

```text
variance_components
heritability
fixed_effects
breeding_values
random_effects
predictions
nobs
prediction_error_variance
reliability
diagnostics
converged
```

It deliberately omits `loglik` and `df`. PEV and reliability are attached
unconditionally on the current Henderson MME bridge as dense validation-path
fields; they are not production sparse reliability.

The supplied-variance animal-only metafounder bridge returns the same smaller
shape, with component labels normalized to `metafounder` and diagnostics marking
`variance_components = "supplied_metafounder"` plus `gamma_source = "supplied"`.

## Sparse REML Estimator Path (experimental)

An opt-in, fenced bridge target surfaces the Julia-owned, REML-only sparse
optimizer. It is reachable only via:

```r
hs_control(
  engine = "julia",
  engine_control = list(
    target = "sparse_reml",
    initial = c(sigma_a2 = 1, sigma_e2 = 1),
    iterations = 1000L
  )
)
```

R builds the model spec with `method = :REML` and calls Julia
`HSquared.fit_sparse_reml(spec; initial = (sigma_a2, sigma_e2), iterations)`,
then normalizes the returned `result_payload(fit)` through the same shape as the
default fitted path (`variance_components`, `heritability`, `fixed_effects`,
`breeding_values`, `random_effects`, `loglik`, `df`, `nobs`, `predictions`,
`diagnostics`, `converged`). The R bridge tags
`diagnostics$variance_components = "estimated_sparse_reml"` so `fit_diagnostics()`
reports an estimated (not supplied) variance provenance, distinct from the
`"supplied"` Henderson MME path.

Ownership and boundary:

- The estimator is Julia-owned; R only surfaces it. R tracks the twin by reading
  `HSquared.jl` exports and `validation_status()`, never by editing Julia source.
- Experimental and opt-in: the default `hsquared()` fits via `ai_reml`, not
  `sparse_reml`. This sparse-REML path stays opt-in (`engine = "julia"`,
  `target = "sparse_reml"`). Promote it to a public-facing claim only once the
  twin's `validation_status()` marks `fit_sparse_reml` green (currently partial).
- Not variance-component estimation via the public R interface, not production
  sparse fitting, not AI-REML, and not an ASReml-parity claim. Live tests are
  skip-guarded when JuliaCall, Julia, or the sibling checkout is unavailable.

## Storage Policy

- Save minimal metadata by default.
- Do not save dense A.
- Do not save full design matrices unless requested.
- Do not densify large relationship matrices silently.
- Compute fitted values and residuals lazily when feasible.

## Future Control Surface

Algorithmic Julia choices should live under a future engine-specific control
surface rather than overloading R-native controls.
