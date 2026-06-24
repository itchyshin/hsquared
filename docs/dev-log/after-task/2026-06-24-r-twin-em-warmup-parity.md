# After-task — R-twin parity: expose `em_warmup` through the bridge — 2026-06-24

## Task goal

Twin-parity for the HSquared.jl engine slice **A** (PR #186): the opt-in EM-REML
warm-start (`fit_ai_reml(...; em_warmup = k)`). Expose it from the R side via
`hs_control(engine_control = list(em_warmup = k))` → bridge → the Julia
`fit_ai_reml` call. `[R]` lane; experimental opt-in bridge control; **no**
`covered` promotion, **no** new estimand.

## What landed

- `R/julia-bridge.R`:
  - `hs_validate_em_warmup()` (NEW) — mirrors `hs_validate_iterations()` but allows
    `0` (off / default); rejects negatives, non-integers, length != 1.
  - `hs_fit_julia_ai_reml_payload()` gained an `em_warmup = 0L` argument; it is
    validated, assigned (`hsq_em_warmup`), and threaded into the engine call as
    `fit_ai_reml(...; iterations = ..., em_warmup = hsq_em_warmup)`.
- `R/hsquared.R`: both `hs_fit_julia_ai_reml_payload()` call sites — the default
  `engine = "fit"` path and the `target = "ai_reml"` path — now pass
  `em_warmup = hs_engine_control_value(control, "em_warmup", 0L)`.
- `R/hs_control.R` + `man/hs_control.Rd`: `em_warmup` added to the recognized
  `engine_control` controls and documented on the `ai_reml` estimator (non-negative
  integer, default `0`; `0` is byte-identical to the prior behaviour; a small
  positive value can rescue convergence from poor starting variances; on an
  identified fit it reaches the same optimum).
- `tests/testthat/test-julia-bridge.R`: a pure-R validator test, and a
  skip-guarded live-bridge test (forwarding + optimum-invariance).

## Honest result

- ✅ **Forwarding works (live-verified):** with JuliaCall + a local HSquared.jl
  checkout (engine on `main` `95c82b1a`, has #186), the bridge emits a well-formed
  `fit_ai_reml(...; em_warmup = 3)` call (a mis-named/malformed kwarg would make the
  Julia call error — it does not).
- ✅ **Optimum-invariant (live-verified):** on the Mrode supplied-variance fixture,
  `em_warmup = 0` and `em_warmup = 3` reach the SAME REML optimum — VC
  `(1.653473, 0.082870)` both, max abs diff `5.3e-9` (tol `1e-6`).
- **Scope fence:** `em_warmup = 0` (default) is byte-identical to the pre-#186 call.
  The bad-start convergence *rescue* is an **engine** property validated in
  HSquared.jl (#186), not re-claimed here. No new estimand, no coverage claim, no
  `validation_status()` row (an optimum-invariant robustness knob on the existing,
  already-covered `V1-AI-REML` estimator — consistent with how the Julia A slice
  extended `fit_ai_reml` without a new row).

## Checks run and exact outcomes

- `devtools::document()` regenerated `man/hs_control.Rd` only (four unrelated `.Rd`
  files were touched by roxygen2 version drift — author-list rendering, `examplesIf`
  wrapper, `\link` format — and were reverted to keep the change surgical).
- `devtools::check(document = FALSE, args = "--no-manual")`: **0 errors**, **1
  warning**, **1 note**. The warning is the **pre-existing** non-ASCII one in
  `R/validation-status.R` (NOT touched by this slice); this slice adds **no new**
  non-ASCII to any `.R` — the only non-ASCII *in code* that trips the warning remains
  that one untouched file (the three changed `.R` sources contain non-ASCII only in
  pre-existing comments/roxygen, which `R CMD check` exempts). The note is the spurious
  "unable to verify current time". No new error/warning/note relative to baseline.
- Pure-R validator test passes; the live forwarding/invariance test passes when the
  bridge is wired (`HSQUARED_JULIA_PROJECT` + julia on PATH + `NOT_CRAN=true`); it
  skips on CRAN / without Julia, matching every other live-bridge test.

## Next actions

1. Rose claim-vs-evidence audit on the diff; commit + push + PR.
2. Twin parity for slice A is complete. Remaining cross-lane parity candidates
   (recorded, not claimed): the engine D `preconditioner = :ichol` PCG path is an
   internal solver primitive with no R surface, so no R parity is owed.
3. Pre-existing out-of-scope: the `R/validation-status.R` non-ASCII WARNING (the
   `\uxxxx`-escape cleanup that would make `R CMD check` fully green) — flagged
   separately, not fixed in this slice.
