# Opt-in maternal-genetic two-effect model

Date: 2026-06-13

Active lenses: Ada, Hopper, Henderson, Emmy, Curie, Rose, Falconer.
Spawned subagents: 2-agent review `wrgi3zo2o` (hopper-alignment + rose-honesty),
0 blocking / 0 should-fix; the critical Z2/Ainv2 pedigree-alignment concern was
verified correct.

Current lane: R (hsquared). Twin engine read read-only; no twin edits.

## Goal and context

Third Phase 2 increment (autonomous continuation under "finish the packages").
Surface the maternal-genetic model — a direct additive genetic effect plus a
maternal genetic effect expressed through the dam, both carrying the pedigree
relationship — reusing the `two_effect` infrastructure. Twin gate
`V3-TWOEFFECT-REML` is `partial` (it serves both common-environment and maternal
via the same `fit_two_effect_reml`), so the R surface stays experimental/opt-in.

## What changed

- `R/model-spec.R` — `maternal_genetic(1 | dam)` is parsed as a second effect
  with `relationship = "pedigree"`. `hs_parse_maternal_genetic_call` validates
  intercept-only and that the dam ids are animals in the `animal()` pedigree; its
  `levels` are the full pedigree ids (the maternal effect is predicted for every
  animal). Added to `hs_is_second_effect_call` / the dispatcher.
- `R/bridge-payload.R` — `Z2` is now built generically for whichever second
  effect is present (`common_env` or `maternal_genetic`): `match(values, levels)`,
  carrying the effect's `relationship`.
- `R/julia-bridge.R` — the two-effect bridge branches on
  `effect2$relationship`: `"pedigree"` ⟶ `Ainv2 = hsq_Ainv`, `ids2 = hsq_ped.ids`
  (so `Z2` columns align with the same normalized pedigree as `Z1`); `"identity"`
  ⟶ a sparse identity over the levels. The result normalizer names the second
  component by `effect2$type` and stores `maternal_effects` /
  `maternal_proportion` (or the common-env equivalents).
  `hs_second_effect_target()` maps `maternal_genetic` ⟶ `two_effect`.
- `R/extractors.R` — new exported `maternal_effects()`.
- `R/{formula-status,validation-status,hs_control}.R`, `NAMESPACE`, `man/*`,
  `NEWS.md`, `ROADMAP.md`, `_pkgdown.yml`,
  `docs/design/{capability-status,06-public-claims-register}.md` — the existing
  two-effect validation row was BROADENED (not added: still 18 rows) to
  "experimental two-effect estimator (opt-in: common-env, maternal)"; all public
  surfaces mark maternal experimental/opt-in/REML-only, mirroring
  `V3-TWOEFFECT-REML`, with correlated direct–maternal (2×2 G) noted as planned.

## Tests

- `tests/testthat/test-maternal.R` — parser acceptance (pedigree relationship),
  dams-in-pedigree validation, intercept-only, the wrong-target guard, and a
  skip-guarded **live fit** (founders + offspring, maternal effect via the dam).
- `tests/testthat/{test-repeatability,test-formula-animal}.R` — the obsolete
  `maternal_genetic()` rejection assertions now use a still-planned marker
  (`dominance()`).

## Checks

- `air format .`; `devtools::document()`; **`pkg::`-vs-Imports hygiene grep**
  (lesson from the `methods::` miss — my diff adds only declared `JuliaCall::`);
  **`pkgdown::check_pkgdown()` clean**; full `testthat` with juliaup + `NOT_CRAN`
  + sommer + enhancer (live maternal fit ran) — 0 failures, 0 warnings, 0
  skipped; `rcmdcheck(--as-cran)` 0 errors, 0 warnings, 1 NOTE (benign).
- Review `wrgi3zo2o`: 0 blocking, 0 should-fix.

## Boundary

Experimental, opt-in, REML-only; reachable only via `engine = "julia", target =
"two_effect"` with a `maternal_genetic()` term. Two INDEPENDENT effects (direct
additive + maternal genetic, no direct–maternal covariance). Mirrors the twin
`V3-TWOEFFECT-REML` gate (`partial`). The correlated 2×2 direct–maternal model
remains planned. The v0.1, repeatability, and common-environment paths are
unchanged.

## Next

Phase 2 second-random-effect family is now well-covered (repeatability,
common-environment, maternal). The genomic/GBLUP thread (`genomic()` →
`fit_gblup`, twin gate `V2-GBLUP` partial) is the higher-value next target.
