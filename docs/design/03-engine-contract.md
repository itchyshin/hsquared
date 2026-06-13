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
result into this shape for a tiny example; default `hsquared()` calls still stop
before returning a fitted object. The R extractor contract also includes
`prediction_error_variance` and `reliability`, but the current live Julia
`result_payload()` does not return those fields yet.

## Storage Policy

- Save minimal metadata by default.
- Do not save dense A.
- Do not save full design matrices unless requested.
- Do not densify large relationship matrices silently.
- Compute fitted values and residuals lazily when feasible.

## Future Control Surface

Algorithmic Julia choices should live under a future engine-specific control
surface rather than overloading R-native controls.
