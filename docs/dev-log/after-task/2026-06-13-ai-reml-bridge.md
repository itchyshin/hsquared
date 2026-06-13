# Opt-in AI-REML estimator bridge (target = "ai_reml")

Date: 2026-06-13

Active lenses: Hopper, Lovelace, Gauss, Fisher, Curie, Rose (review
perspectives; no subagents spawned).

Spawned subagents: none.

Current lane: R + twin-coordinated (read-only against the twin engine).

## Goal

Surface the Julia twin's newly committed average-information REML estimator
(`HSquared.fit_ai_reml`) through R behind the same opt-in fence already used for
`target = "sparse_reml"`. This is the intended fast default estimator for the
eventual real fit path and directly serves the standing performance directive
("find the fastest REML/ML algorithms"). The default `hsquared()` still
validates-and-stops; nothing here is promoted to a public/default claim.

## What changed

- `R/julia-bridge.R` — new `hs_fit_julia_ai_reml_payload()`, a faithful mirror
  of `hs_fit_julia_sparse_reml_payload()` that calls `HSquared.fit_ai_reml()`
  and tags the fit `target = "ai_reml"` with provenance
  `variance_components_source = "estimated_ai_reml"`. Added `"ai_reml"` to
  `hs_validate_julia_target()`.
- `R/hsquared.R` — dispatch branch for `target == "ai_reml"` (default
  `iterations = 100L`, the engine's documented default for this estimator).
- `R/hs_control.R` (+ regenerated `man/hs_control.Rd`) — documented the
  `target = "ai_reml"` opt-in path and its claim boundary.
- `R/validation-status.R` — added an `experimental AI-REML estimator (opt-in)`
  row (Phase 1, partial).
- `docs/design/capability-status.md`, `docs/design/validation-debt-register.md`
  — recorded the capability as partial with its evidence and boundary.
- Tests: always-on validator + payload-guard tests in `test-julia-bridge.R`; a
  skip-guarded live bridge behaviour test; a skip-guarded live cross-check in
  `test-validation-fixtures.R` (AI-REML reaches the same REML optimum as the
  sparse optimizer); updated the `validation_status()` row-count and content
  assertions in `test-phase0-api.R`.

## Method / TDD

RED first: `hs_validate_julia_target("ai_reml")` was rejected and
`hs_fit_julia_ai_reml_payload` did not exist. GREEN: the four minimal
production edits. The live behaviour was confirmed against the local twin
(Julia 1.10.0) before the live tests were added.

## Finding (the cross-check did its job)

On the Mrode supplied-variance fixture, AI-REML and the sparse NelderMead REML
optimizer reach the same REML optimum via different algorithms: REML logLik
agree to 1.3e-8 and the variance-component estimates to 2.7e-4 (the REML surface
is flat near the optimum). This cross-validates the AI-REML estimator against
the sparse one; it is not an external comparator, DGP recovery, or
production-fitting claim.

## Verification

- `devtools::test()` full with the live Julia bridge active (juliaup on PATH,
  `NOT_CRAN=true`): 508 pass, 0 fail, 0 warnings, 0 skips — the AI-REML live
  tests ran and passed.
- `rcmdcheck::rcmdcheck(args = c("--no-manual", "--as-cran"))`: 0 errors,
  0 warnings, 1 note (benign new-submission/dev-version). The first `--as-cran`
  run caught a stale `validation_status()` row-count assertion (13 → 14), which
  was fixed before commit. Lesson reaffirmed: gate with `--as-cran` locally to
  match CI.
- `air format .`: clean.

## Public claim audit (Rose)

Allowed: an experimental, opt-in `target = "ai_reml"` path surfaces the
Julia-owned average-information REML optimizer; it reaches the same REML optimum
as the sparse optimizer on the Mrode fixture.

Blocked: default/production fitting; variance-component estimation via the
public R interface; ASReml/BLUPF90/DMU parity; DGP recovery; accuracy claims.
Status stays `partial`, gated on the twin's `validation_status()` marking the
estimator green.

## Next actions

1. Critical-path keystone: a Mrode fitted-output validation (published expected
   variance components / EBVs / h2) end-to-end, which is what lets the estimator
   go from `partial` to green.
2. External fitted-output comparator (sommer/pedigreemm) on fitted outputs.
3. Once the engine is green, flip the R default for the exact v0.1 contract from
   validate-and-stop to a real fit.
