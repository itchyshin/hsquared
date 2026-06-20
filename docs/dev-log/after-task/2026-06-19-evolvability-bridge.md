# After-task — G-matrix geometry / evolvability extractors (#55, 2026-06-19 s3)

## Goal

Bridge the twin's evolvability/G-geometry tooling (HSquared.jl #55, `6047fe2`) — the
first slice under the FA rotation convention ratified on #61 (bridge only
rotation-invariant functionals of G, never loadings).

## Shipped (`35bf92f`, live-verified)

- `eigen_G(fit)` (the reserved name now implemented), `g_max()`,
  `mean_evolvability()`, and directional `evolvability()`/`respondability()`/
  `conditional_evolvability()`/`autonomy()` (Hansen & Houle 2008), matching the
  engine's `evolvability.jl` names (transferable syntax). New `R/evolvability.R`.
- Rotation-invariant functionals of the estimated G → defined for any
  multivariate fit, no loading convention needed. `genetic_loadings()`/
  `specific_variance()`/`latent_breeding_values()` stay reserved.
- Computed R-side from `genetic_covariance(fit)` (works on a saved fit without a
  live engine); the engine owns the canonical definitions, a live parity test
  guards drift.

## Verification

- Hand-computed correctness on a known G (eigenvalues, evolvability = G[1,1],
  conditional = det/G22, autonomy, mean = tr/t, sign-canonicalised eigenvectors)
  + input/singular-G/non-multivariate guards.
- **Live parity** (Julia 1.10 + HSquared.jl origin/main): R ==
  `HSquared.evolvability/respondability/conditional_evolvability/autonomy/
  mean_evolvability/genetic_pca/g_max` on a random PD 3x3 G — equal.
- `devtools::test()` **907 / 0 / 0 / 34**; `pkgdown::check_pkgdown()` clean;
  `devtools::check(args="--no-manual")` **0 / 0 / 0**.

## Honesty / lane

Experimental/partial, no SEs, inherits the multivariate fit's status; nothing
promoted to covered. R-lane only; the convention was ratified jointly on #61.
Flipped the reserved `eigen_G()` to working (eigenstructure is rotation-invariant)
and updated the two `test-fit-object.R` assertions that expected it to error.

## Next

Extends automatically when the twin's widened `multivariate_result_payload`
(eigenbasis + invariants, no loadings) + a `:lowrank`/`:fa` parity fixture land
(holding on #42/#61). Next buildable bridge: the `#45` post-fit `gwas()` wrapper
(uncalibrated significance, per the #61 agreement).
