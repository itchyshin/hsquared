# After-task — opt-in non-Gaussian (Poisson/Bernoulli) animal-model bridge (#44, 2026-06-19 s3)

## Task goal

Build the R bridge side of the twin's just-landed non-Gaussian engine
(`nongaussian_result_payload` + `MarginalMethod`, HSquared.jl `29b66c5`), so an
applied user can fit a `poisson`/`binomial` animal model — the highest-value
uncovered bridge surface. Division of labour confirmed with the active Julia
thread on #61: they race the engine, the R lane takes the bridge side of each
landing (different repos, no collision).

## What shipped (`31f200c`, live-verified)

- `hsquared(family = poisson()/binomial(), control = hs_control(engine = "julia",
  engine_control = list(target = "nongaussian")))` → `HSquared.fit_laplace_reml()`
  (marginal Laplace REML). New `hs_fit_julia_nongaussian_payload()` +
  `hs_normalize_nongaussian_result()`; `"nongaussian"` added to the target
  validator; family gate widened by an `allow_families` argument threaded from
  `hsquared()` (default stays gaussian-only); the family error now points to the
  opt-in path instead of "planned".
- Returns the latent-scale additive-genetic variance, breeding values, fixed
  effects, marginal logLik. **No heritability** (no residual-variance scale for a
  non-Gaussian family); `heritability()` errors honestly.
- Experimental/partial, REML/Laplace-only (`marginal = "laplace"`; variational +
  `binomial`-with-trials deferred to twin-signalled follow-ups). Mirrors engine
  row `V6-LAPLACE` (partial): not calibrated, no external comparator, Bernoulli
  `sigma_a2` boundary-prone.

## Verification (julia now live in-session — off-PATH juliaup 1.10)

- Live: Poisson + Bernoulli animal models fit through the bridge against
  `HSquared.jl origin/main` — variance component finite/≥0, breeding values per
  animal, marginal logLik, `heritability()` errors. `test-nongaussian.R` live leg
  passes (no segfault).
- Non-live: shape-verified normalizer + family-gate/rejection tests pass;
  `devtools::test()` **889 / 0 / 0 / 33**; `pkgdown::check_pkgdown()` clean;
  `devtools::check(args = "--no-manual")` **0 / 0 / 0** (after fixing a non-ASCII
  em-dash I introduced in an error string).

## Review

Rose honesty audit: the slice's own surfaces are clean (no overclaim, no
promotion to covered, lane-clean, the no-heritability gate is genuine). Rose
found + I fixed **4 stale "non-Gaussian remains planned" claims** the slice
missed — `R/hsquared.R` + `R/hsquared-package.R` roxygen, `README.md`, and the old
`#6` NEWS entry. Re-audited clean.

## Lane discipline

R-lane only; zero edits to `HSquared.jl`. Coordinated via #61 (division of
labour) and #44 (bridge-landed-live-verified + the two deferred follow-ups,
asking the twin for the `n_trials` grammar preference).

## Not done / follow-ups

- Variational (`marginal = :variational`) R surface — gated to `laplace` for now.
- `binomial` with a trial count — deferred pending an `n_trials`/`weights`
  grammar decision (asked the twin on #44).
- Promotion toward covered — needs the twin's V6-LAPLACE calibration + an
  external comparator; not buildable R-side.
