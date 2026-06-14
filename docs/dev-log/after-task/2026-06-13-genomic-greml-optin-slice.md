# Opt-in genomic GREML model

Date: 2026-06-13 (autonomous overnight; user away till ~05:00)

Active lenses: Ada, Hopper, Henderson, Kirkpatrick, Emmy, Curie, Rose.
Spawned subagents: 2-agent review `woigtw1b0` (hopper-parser-align +
rose-honesty). hopper found no defects; rose found one **blocking** defect
(`model_spec()` crash on genomic) + one should-fix (a test), both fixed.

Current lane: R (hsquared). Twin engine read read-only; no twin edits.

## Goal and context

Fourth opt-in slice under "finish the packages" (Phase 5, genomic). Surface
genomic GREML — variance-component estimation on a user-supplied genomic
relationship inverse. A direct bridge probe confirmed the engine path:
`fit_ai_reml` runs on an `animal_model_spec` built with a `Ginv` (the same REML
estimator as v0.1, only the relationship source differs). Twin gate `V2-GREML`
is `partial`.

## What changed

- `R/model-spec.R` — generalised the parser's **primary** effect to be exactly
  one of `animal()` (pedigree) or `genomic()` (a user-supplied `Ginv`).
  `hs_parse_genomic_call` validates `genomic(1 | id, Ginv = Ginv)`: intercept-
  only, group in data, `Ginv` a square dimnamed numeric matrix, ids ⊆ `Ginv`
  dimnames. `random[[primary_type]] <- primary_spec` (additive; the animal path
  is unchanged when genomic is absent). Second effects require an `animal()`
  primary (genomic is single-effect).
- `R/bridge-payload.R` — `hs_build_genomic_bridge_payload` builds `Z` from the
  genotyped-record incidence and carries the `Ginv` (in its dimname order; `Z`
  columns, `Ginv`, and `ids` share one id order — verified by review).
- `R/julia-bridge.R` — `hs_fit_julia_genomic_payload` marshals `y`, `X`, `Z`,
  `Ginv`, calls `fit_ai_reml` on the Ginv spec, reuses the standard result
  normalizer, and relabels the genetic component as `genomic`; provenance
  `estimated_genomic_ai_reml`.
- `R/hsquared.R` — opt-in `target = "genomic"` branch; the default/`engine="julia"`
  guards generalised (the default `engine = "fit"` rejects `genomic()`; a
  `genomic()` formula needs `target = "genomic"`; REML only).
- `R/model-spec-inspect.R` — **(review blocker fix)** `model_spec()` previews the
  pedigree animal grammar only and now errors clearly on a genomic formula
  (pointing to the opt-in fit) instead of crashing on `spec$random$animal`.
- `R/{formula-status,validation-status,hs_control}.R`, `NAMESPACE`, `man/*`,
  `NEWS.md`, `ROADMAP.md` (Phase 5 "started (opt-in)"),
  `docs/design/{capability-status,06-public-claims-register}.md` — new `partial`
  genomic GREML row (`validation_status()` now 19 rows); all mark it
  experimental/opt-in/REML-only, mirroring `V2-GREML`, with marker-based `Ginv`
  construction, single-step (`Hinv`), and comparator parity noted as planned.

## Tests

- `tests/testthat/test-genomic.R` — parser acceptance, one-primary-effect,
  `Ginv` required, ids-in-`Ginv`, target validation, default-fit rejection, the
  bridge payload guard, and a skip-guarded **live GREML fit** (marker-derived G).
- `tests/testthat/{test-model-spec-inspect,test-formula-animal}.R` — obsolete
  `genomic()` rejection assertions updated to a still-planned marker
  (`single_step()`); a new test that `model_spec()` errors on genomic.

## Checks

- `air format`; `devtools::document()`; **`pkg::`-vs-Imports grep** (clean — only
  declared `JuliaCall::`/`Matrix::`); **`pkgdown::check_pkgdown()` clean**; full
  `testthat` with juliaup + `NOT_CRAN` + sommer + enhancer (live GREML fit ran) —
  0/0/0; `rcmdcheck(--as-cran)` 0 errors, 0 warnings, 1 NOTE (benign). NOTE:
  `--as-cran` (installed-package tests) caught a model-spec test divergence that
  `test_dir(load_all)` did not — `--as-cran` is the authoritative gate.
- Review `woigtw1b0`: 1 blocking (model_spec crash) + 1 should-fix, both fixed;
  Z/Ginv/ids alignment and the primary-effect generalisation verified correct.

## Boundary

Experimental, opt-in, REML-only; reachable only via `engine = "julia", target =
"genomic"` with a `genomic(1 | id, Ginv = Ginv)` term. The user supplies the
genomic relationship inverse; **building** `Ginv`/`G` from markers, single-step
(`Hinv`), low-rank m≫n solves, and AGHmatrix/sommer/BLUPF90 comparator parity
remain planned. Mirrors the twin `V2-GREML` gate (`partial`): not the default,
not ML, not production or comparator/known-truth-validated. The v0.1 animal,
repeatability, and two-effect paths are unchanged.
