# Multivariate + permanent-environment (hsquared #237)

Status: **experimental R grammar + distinct bridge** (2026-09-26).
No covered flip. Version stays **0.9.0**. `public_covered_count` stays **7**.

## Verdict

The default `cbind()` route now accepts

```r
hsquared(cbind(y1, y2) ~ sex + animal(1 | id, pedigree = ped) + permanent(1 | id),
         data = dat, family = gaussian(), REML = TRUE)
```

`permanent()` is iid PE per animal (not pedigree-related). Animal `G0` stays
trait x trait. PE is a separate random-effect block so Va and Vpe can be
identified. R does **not** call `fit_multivariate_reml` on this formula: that
animal-only fitter would absorb V_PE into G0.

## R contract (this lane)

| Surface | Contract |
| --- | --- |
| Grammar | `cbind(...) + animal(...) + permanent(1 \| id)` parses; PE shares the animal grouping and is intercept-only |
| Default route | `engine = "fit"` and `engine = "julia"` with no target auto-select `multivariate_repeatability` |
| Explicit alias | `target = "multivariate"` + PE upgrades to `multivariate_repeatability`; `target = "repeatability"` + cbind remains a named reject (univariate target) |
| Payload | `Y` (n x t), pedigree animal block, iid `permanent` block sharing `Z`, `relmat_status = "identity"` |
| Engine call | `HSquared.fit_multivariate_repeatability_reml(Y, X, Z, Ainv; initial = (G0, P0, R0), iterations, ids, traits)` |
| Missing engine | named abort; never silent absorb |
| Other seconds | cbind + common_env / maternal / genomic / iid extras / rr stay planned rejects |

## Julia sibling (frozen; do not redesign)

Landed on HSquared.jl#398, branch `cursor/237-mv-permanent-jl` @ `410f7efd`.
Do **not** merge that PR from this R lane.

```text
fit_multivariate_repeatability_reml(Y, X, Z, Ainv; initial, iterations, ids, traits)
```

payload-v2: `Y` + one pedigree + one iid PE dispatches
`:multivariate_repeatability`. Result target is
`"multivariate_repeatability_reml"` with `status = "experimental"`.
`component_names = ["animal", "permanent", "residual"]`.
Per-trait `h2_k = G0kk / (G0kk + P0kk + R0kk)` and
`t_k = (G0kk + P0kk) / denom`. Breeding values and PE effects are
`(ids, traits, values)`. G0, P0, and R0 stay separate.

R control target stays `multivariate_repeatability`. R never calls
`fit_multivariate_reml` on this formula.

## Honesty

Experimental / partial only. Recovery of known-truth `G0` **and** `P0` plus a
same-estimand comparator is still required before any status move. Univariate
repeatability stays `partial`. Count stays 7.

## Pointers

- Issue: https://github.com/itchyshin/hsquared/issues/237
- Twin issue: HSquared.jl#352 (univariate PE) one dimension up
- Tests: `tests/testthat/test-multivariate-permanent-237.R`
