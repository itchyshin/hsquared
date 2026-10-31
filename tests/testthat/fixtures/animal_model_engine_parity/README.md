# Engine-parity fixture: univariate animal model on a small inbred pedigree

HSquared.jl fits this model directly (no R, no bridge) and serializes the
result. `test-engine-parity-animal-model.R` then checks that an R-side REML
rebuild and a live `hsquared()` fit both reproduce it.

## Model

```r
hsquared(y ~ sex + animal(1 | id, pedigree = ped), data = phenotypes,
         family = gaussian(), REML = TRUE)
```

30 animals over three generations; one record each. Two full-sib matings make
4 animals inbred (F = 0.25). The REML optimum is interior
(sigma_a2 = 1.14, sigma_e2 = 0.83).

## Files

- `pedigree.csv`: `id,sire,dam` (unknown parent = empty).
- `phenotypes.csv`: `id,sex,y`.
- `expected_variance_components.csv`: `component,estimate,se` (`animal`,
  `residual`); SEs from the engine's average-information matrix.
- `expected_beta.csv`: `term,estimate` (`(Intercept)`, `sexM`).
- `expected_metadata.csv`: pinned `engine_commit`, `engine_version`,
  `julia_version`, `route`, `h2`, `h2_se`, `loglik` (full REML, constants
  included), `converged`, counts.
- `make_data.R`: realizes the pedigree and phenotypes (needs `nadiv`).
- `generate.jl`: fits the model with the same engine calls as the hsquared
  default route (`fit_ai_reml`) and writes the `expected_*` files.

## Regenerate

```sh
git -C /path/to/HSquared.jl checkout <engine_commit>
julia --project=/path/to/HSquared.jl generate.jl /path/to/HSquared.jl
```

Update `hs_parity_engine_commit` in the test when the pin moves.

## What this does and does not show

It shows the R bridge passes the engine's estimates through unchanged, and
that base-R linear algebra agrees with the engine's REML log-likelihood,
optimum, GLS fixed effects and AI-based SEs. It is not external validation
against an independent package and does not move any `validation_status()` row.
