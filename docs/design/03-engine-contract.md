# Engine Contract

The initial bridge contract is deliberately small. It should not expose
algorithm choices before the Julia engine has a stable control surface.

## Initial Payload

```text
response: numeric vector y
fixed_design: matrix X
random_design: sparse matrix Z
ainv: sparse precision matrix Ainv
method: :REML or :ML
family: gaussian only
ids: encoded animal IDs
metadata: original names, levels, pedigree map
```

## Initial Julia Result

```text
converged
optimizer_status
loglik
reml_loglik
variance_components
fixed_effects
breeding_values
heritability
gradient_norm
iterations
warnings
id_map
```

## Storage Policy

- Save minimal metadata by default.
- Do not save dense A.
- Do not save full design matrices unless requested.
- Do not densify large relationship matrices silently.
- Compute fitted values and residuals lazily when feasible.

## Future Control Surface

Algorithmic Julia choices should live under a future engine-specific control
surface rather than overloading R-native controls.
