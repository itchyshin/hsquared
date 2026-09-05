# Factor-analytic covariance: R planned surface

Status: planned on the R surface; no R-public FA fit is activated.

## Boundary

The R package reserves factor-analytic genetic covariance for a future
structured-covariance grammar:

```r
animal(trait | id, pedigree = ped, cov = fa(K = 2))
```

The corresponding `engine_control = list(genetic_structure =
"factor_analytic")` value is also a reserved control. Both forms reject with a
planned-path error. They do not construct a model specification, call Julia,
or return loadings.

This is deliberately separate from the Julia engine. HSquared.jl `V4-FA` is
engine-covered for its declared validation-scale engine target
(`HSquared.jl` commit `60895208`, issue #300). That engine evidence does not
activate the R formula, R bridge payload, R extractors, or an R-public claim.

## What remains out of scope on R

The R package does **not** currently cover:

- parsing or fitting `cov = fa(...)`;
- constructing or marshalling a factor-analytic G payload;
- returning factor loadings, specific variances, or loading-based inference;
- selecting or validating the rank `K`;
- comparator or recovery evidence for an R FA route;
- a rotation-dependent public interpretation.

The cross-twin contract is rotation-safe: future bridge output may expose
rotation-invariant functionals, but it must not expose loadings as if their
orientation were identified without a separately ratified convention.

## Current alternatives

For an R multivariate Gaussian model, the current bridge accepts the
unstructured G0 path and the rotation-free diagonal path:

```r
animal(1 | id, pedigree = ped)
control = hs_control(
  engine = "julia",
  engine_control = list(
    target = "multivariate",
    genetic_structure = "diagonal"
  )
)
```

These alternatives are not FA substitutes and do not change the R FA status.
`public_covered_count` remains **7**.

## Promotion requirements

An R FA surface would require, at minimum, a frozen formula and payload
contract, rank and identifiability rules, rotation-safe extractors, an
independent recovery gate, an external same-estimand comparator, R--Julia
parity tests, documentation, and a separate claim review. Until that chain is
complete, the correct user-facing result is a clear planned-path rejection.
