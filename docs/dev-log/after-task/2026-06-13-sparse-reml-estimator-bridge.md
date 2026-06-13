# Experimental Sparse REML Estimator Bridge (B2)

Date: 2026-06-13

Active lenses: Jason, Hopper, Lovelace, Gauss, Fisher, Curie, Rose.

Spawned subagents: B2 scout (Jason/Hopper/Curie) and B2 review
(Hopper/Fisher/Rose), both via Workflow.

Current lane: R + twin-coordinated.

## Goal

Surface the Julia twin's experimental, REML-only sparse optimizer
`HSquared.fit_sparse_reml()` through a fenced, opt-in R bridge target so local
users can reach it deliberately. The default `hsquared()` still validates and
stops. This is NOT general fitting, variance-component estimation via the public
R interface, production sparse fitting, AI-REML, or ASReml parity; the estimator
is Julia-owned and R only surfaces it.

## Reuse (do not reinvent; license-clean)

- Mirrored hsquared's own MIT `hs_fit_julia_payload()` / `henderson_mme` bridge
  pattern and reused `hs_normalize_julia_result()` for the result shape (the
  twin's sparse-REML `result_payload()` matches the dense fit shape).
- Adapted R-Julia bridge idioms (session cache, availability guard, defensive
  coercion, capability guard) — patterns only — from the GPL-3 sibling bridges
  `gllvmTMB/R/julia-bridge.R` and `drmTMB/R/julia-bridge.R`. No GPL code was
  copied into MIT hsquared.

## Files Changed

- `R/julia-bridge.R` — `hs_validate_julia_target()` accepts `"sparse_reml"`; new
  `hs_validate_iterations()` and `hs_fit_julia_sparse_reml_payload()`.
- `R/hsquared.R` — dispatch branch for `target = "sparse_reml"`.
- `R/hs_control.R` + `man/hs_control.Rd` — document the `sparse_reml` target,
  `initial`, and `iterations`.
- `tests/testthat/test-julia-bridge.R` — target/iterations validators, a
  payload-guard test, and a skip-guarded live estimator test.
- `NEWS.md`, `docs/design/capability-status.md`,
  `docs/design/validation-debt-register.md`,
  `docs/design/06-public-claims-register.md` — fenced claim rows.

## Verification

- `NOT_CRAN=true` `testthat::test_dir(filter = "julia-bridge")`: the live
  sparse-REML test ran against the sibling `HSquared.jl` and passed.
- `devtools::test()` full: `473 pass`, `0 fail`, `0 warnings`, `0 skips` (live
  Julia bridge active).
- `rcmdcheck::rcmdcheck()`: `0 errors`, `0 warnings`, `0 notes`.
- `air format .` and `git diff --check`: clean.
- Remote (commit `6add692`): R-CMD-check `27468442096`, pkgdown `27468442094`,
  Pages `27468475645` all passed.

## Multi-lens review (Workflow)

Hopper (bridge payload/result parity), Fisher (estimand + claim boundary), and
Rose (claim-vs-evidence across code + registers) each returned `clean` — no
blocking or required findings.

## Public Claim Audit (Rose)

Allowed: an experimental, opt-in `engine_control = list(target = "sparse_reml")`
path that surfaces the Julia-owned `fit_sparse_reml()` REML-only sparse
optimizer; skip-guarded live test checks positive estimated variances, finite
REML log-likelihood, and h2 in (0,1).

Blocked: general animal-model fitting; variance-component estimation in the
public R interface; production sparse fitting; AI-REML; fitted-Mrode validation;
ASReml/BLUPF90 parity; DGP recovery.

## Known Limitations

- Activation gate: the path ships fenced and skip-guarded; it should be promoted
  to a public-facing claim only once the twin's `validation_status()` marks
  `fit_sparse_reml` green (currently partial).
- B2 records provenance via `spec$target = "sparse_reml"`; the explicit
  `variance_components_source` extractor + `validation_status()` row is B3.

## Next Actions

1. B3: estimated-vs-supplied variance provenance in `fit_diagnostics()` /
   `validation_status()`.
2. B4: sparse REML estimate-recovery validation fixture (reuse
   `DRM.jl/src/comparison.jl` comparator discipline).
3. Notify issues #6/#7 and the Julia twin that R now surfaces `fit_sparse_reml`
   behind the fenced `sparse_reml` target.
