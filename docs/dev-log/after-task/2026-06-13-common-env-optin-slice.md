# Opt-in common-environment (two-effect) model

Date: 2026-06-13

Active lenses: Ada, Hopper, Boole, Emmy, Curie, Rose, Darwin (perspectives).
Spawned subagents: a 2-agent adversarial review (`wziz2f7mm`: hopper-bridge /
rose-honesty — both clean pass, 0 blocking; one should-fix + one nit applied).

Current lane: R (hsquared). Twin engine read read-only; no twin edits.

## Goal and context

Second Phase 2 increment under the "finish the packages" directive (continuing
autonomously after the repeatability slice). Surface the common-environment
model — animal additive genetic effect + an IID environmental effect (e.g.
litter or cage) — behind the same opt-in, experimental fence, using the twin's
`fit_two_effect_reml`. Twin gate `V3-TWOEFFECT-REML` is `partial`, so the R
surface is honestly experimental.

## What changed

- `R/model-spec.R` — generalised the `permanent()`-specific parser into a shared
  "second random effect" mechanism (`hs_is_second_effect_call`,
  `hs_parse_second_effect_call`). `common_env(1 | group)` is now parsed as the
  common-environment effect: a random intercept on an environmental grouping
  (a separate column from the animal id), carrying an identity relationship.
  At most one second effect (`permanent()` or `common_env()`) is allowed.
- `R/bridge-payload.R` — builds a second design matrix `Z2` (records → environment
  levels) and `effect2` metadata when a `common_env()` term is present.
- `R/julia-bridge.R` — `hs_fit_julia_two_effect_payload()` marshals `Z2`, builds
  an identity `Ainv2` sized to the number of environment levels in Julia, and
  calls `HSquared.fit_two_effect_reml(y, X, Z, Ainv, Z2, Ainv2; initial = (sigma1,
  sigma2, sigma_e2), ids1, ids2)`. `hs_normalize_two_effect_result` maps the
  three components (animal, common_env, residual), `heritability` (= ratio1),
  the common-environment proportion (= ratio2), breeding values, and
  common-environment effects; provenance `estimated_two_effect_reml`.
  `hs_second_effect_target()` maps `permanent` → `repeatability`, `common_env` →
  `two_effect`.
- `R/hsquared.R` — opt-in `target = "two_effect"` branch; the default and
  `engine = "julia"` guards generalised to any second effect (default `engine =
  "fit"` rejects any second effect; a `common_env()` formula needs `target =
  "two_effect"`; that target needs a `common_env()` term; REML only).
- `R/extractors.R` — new exported `common_env_effects()`.
- `R/{formula-status,validation-status,hs_control}.R`, `NAMESPACE`, `man/*`,
  `NEWS.md`, `ROADMAP.md`, `_pkgdown.yml`,
  `docs/design/{capability-status,06-public-claims-register}.md` — all mark the
  capability experimental / opt-in / REML-only, mirroring `V3-TWOEFFECT-REML`
  (partial), and note that correlated direct–maternal (2×2 G) remains planned.
  `validation_status()` is now 18 rows.

## Tests

- `tests/testthat/test-common-env.R` — parser acceptance, the "at most one second
  effect" guard, intercept-only + unknown-column validation, target validation,
  default-fit rejection, target-requires-common_env, the bridge payload guard,
  the extractor default, and a skip-guarded **live fit** (founders + offspring in
  litters; contract/smoke only — no recovery claim).
- `tests/testthat/{test-repeatability,test-formula-animal}.R` — updated the
  obsolete `common_env()` rejection assertions (now parsed); the multiple-second-
  effect error message generalised.

## Checks

- `air format .`; `devtools::document()`; **`pkgdown::check_pkgdown()` clean**
  (run locally this time — the lesson from the repeatability pkgdown miss).
- Full `testthat` with juliaup + `NOT_CRAN` + sommer + enhancer (live two-effect
  fit ran): **0 failures, 0 warnings, 0 skipped**.
- `rcmdcheck(--as-cran)`: **0 errors, 0 warnings, 1 NOTE** (benign).
- Review `wziz2f7mm`: 0 blocking; the should-fix (defensive `Z2` dgCMatrix check)
  and nit (bridge_target metadata string) applied.

## Boundary

Experimental, opt-in, REML-only; reachable only via `engine = "julia", target =
"two_effect"`. Two independent random effects (additive genetic + IID common
environment). Mirrors the twin `V3-TWOEFFECT-REML` gate (`partial`): not the
default, not ML, not production, not comparator/known-truth-validated. Correlated
direct–maternal (2×2 G) effects remain planned. The v0.1 single-effect path and
the repeatability path are unchanged.

## Next

The maternal-genetic two-effect case (Z2 = dam incidence, Ainv2 = pedigree) and
the correlated 2×2 direct–maternal G are the natural follow-ons; genomic/GBLUP
(`genomic()` → `fit_gblup`) is the higher-value Phase 5 thread. Promotion of the
two-effect claims awaits the twin promoting `V3-TWOEFFECT-REML` to `covered`.
