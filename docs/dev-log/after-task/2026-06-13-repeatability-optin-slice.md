# Opt-in repeatability (permanent-environment) model

Date: 2026-06-13

Active lenses: Ada, Hopper, Boole, Emmy, Curie, Rose, Falconer (perspectives).
Spawned subagents: yes — a scout workflow (`w0hj6t9xq`, cancelled early by an
interactive interrupt; redone inline) and a 3-agent adversarial review
(`wckuklv5h`: rose-honesty / hopper-bridge / curie-tests — all clean pass, one
should-fix closed).

Current lane: R (hsquared). The twin engine was read read-only; no twin edits.

## Goal and context

First Phase 2 increment under the "finish the packages" directive, authorised by
the maintainer ("Build & ship it (opt-in/experimental)"). Surface the
repeatability (permanent-environment) model — the textbook second quantitative-
genetic model — behind an opt-in, experimental fence, exactly mirroring the
`sparse_reml`/`ai_reml` opt-in pattern. The twin gate `V3-REPEAT-REML` is
`partial` on Julia main, so the R surface is honestly experimental, never
covered/default/production.

## What changed

- `R/model-spec.R` — the parser now accepts `permanent(1 | id)` alongside
  `animal(1 | id, ...)` as the permanent-environment effect: `hs_is_permanent_call`
  + `hs_parse_permanent_call` (intercept-only, must share the animal grouping —
  the engine shares the animal incidence `Z` with `A2 = I`). `permanent()` is
  exempted from the planned-marker rejection; every other planned marker still
  errors. The bridge target becomes `fit_repeatability_reml` when `permanent()`
  is present.
- `R/julia-bridge.R` — `hs_fit_julia_repeatability_payload()` calls the twin's
  `HSquared.fit_repeatability_reml(y, X, Z, Ainv; initial = (sigma_a2, sigma_pe2,
  sigma_e2), iterations, ids)` and normalises the three-component result
  (`hs_normalize_repeatability_result`): variance components (animal, permanent,
  residual), `repeatability`, `heritability`, breeding values, permanent-
  environment effects, provenance `estimated_repeatability_reml`.
  `hs_validate_repeatability_initial()` enforces the three named components.
- `R/hsquared.R` — opt-in `engine = "julia", target = "repeatability"` branch.
  The default `engine = "fit"` rejects `permanent()` (pointer to the opt-in
  target); a `permanent()` formula with any other target errors; `target =
  "repeatability"` without `permanent()` errors; REML-only (`REML = FALSE`
  rejected). `hs_validate_julia_target` accepts `"repeatability"`.
- `R/extractors.R` — new exported `repeatability()` and `permanent_effects()`
  extractors (generic + default-error + `hsquared_fit` methods).
- `R/formula-status.R`, `R/validation-status.R` (new `partial` row, 17 rows),
  `R/hs_control.R`, `NEWS.md`, `ROADMAP.md` (Phase 2 "started (opt-in)"),
  `docs/design/{capability-status,06-public-claims-register}.md` — all mark the
  capability experimental / opt-in / REML-only / "needs repeated records",
  mirroring `V3-REPEAT-REML` partial. Nothing claims covered/default/recovery.

## Tests

- `tests/testthat/test-repeatability.R` — parser acceptance + the five guards
  (default rejects `permanent()`, target requires `permanent()`, `permanent()`
  needs the repeatability target, `REML = FALSE` rejection, three-component
  `initial` validation), extractor defaults, and a skip-guarded **live fit** on a
  related pedigree (offspring of founders, so `A != I`) with repeated records
  (contract/smoke only — no recovery claim).
- `tests/testthat/test-formula-animal.R` — dropped the obsolete `permanent()`
  rejection assertion (other planned markers still error).
- `tests/testthat/test-phase0-api.R` — `validation_status()` now 17 rows; the
  repeatability row is `partial`.

## Checks

- `air format .`; `devtools::document()` (new `repeatability.Rd`,
  `permanent_effects.Rd`; NAMESPACE exports).
- Full `testthat` suite with juliaup on PATH + `NOT_CRAN` + sommer + enhancer
  (the live repeatability fit ran): **0 failures, 0 warnings, 0 skipped**.
- `rcmdcheck(--as-cran)`: **0 errors, 0 warnings, 1 NOTE** (benign new submission).
- Adversarial review `wckuklv5h`: 0 blocking; the one should-fix (untested
  `REML = FALSE` rejection on the repeatability target) is now covered.

## Boundary

Experimental, opt-in, REML-only. Reachable only via `engine = "julia", target =
"repeatability"`; the default `engine = "fit"` stays single-effect. σ²a and σ²pe
are identifiable only with repeated records per individual. Mirrors the twin
`V3-REPEAT-REML` gate (`partial`): not the default, not ML, not production, and
not a comparator- or known-truth-recovery claim. The v0.1 single-effect path is
unchanged.

## Next

Subsequent increments (when prioritised): a Mrode-style repeatability validation
fixture (known-answer), the two-effect maternal/common-environment surface (the
engine already exports `fit_two_effect_reml`), and — pending the twin gate going
`covered` + maintainer sign-off — promotion of the repeatability claim.
