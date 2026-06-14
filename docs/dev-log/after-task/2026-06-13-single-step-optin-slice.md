# Opt-in single-step model

Date: 2026-06-13 (autonomous overnight; user away till ~05:00)

Active lenses: Ada, Hopper, Henderson, Kirkpatrick, Emmy, Rose. Spawned
subagents: one Explore review agent — clean (0 blocking, 0 should-fix, 1 cosmetic
nit: the shared `hs_eval_genomic_ginv`/`hs_validate_genomic_ginv` retain
genomic-specific names).

Current lane: R (hsquared). No twin edits.

## Goal and context

Sixth opt-in slice. Surface single-step (`single_step(1 | id, Hinv = Hinv)`),
which fits by REML on a user-supplied single-step relationship inverse `Hinv` —
structurally identical to genomic GREML (the same `fit_ai_reml`-on-a-supplied-
inverse estimator), so this was built by **generalising** the genomic primary
into a shared "supplied-relationship-inverse primary". Twin gate `V2-SSHINV` is
`partial`.

## What changed

- `R/model-spec.R` — refactored the genomic parser into a generic
  `hs_parse_relinv_primary_call()` (+ `hs_is_relinv_primary_call()` =
  genomic-or-single_step) that handles `genomic()` (`Ginv`) and `single_step()`
  (`Hinv`) with one code path; the primary-effect detection and bridge target
  use it. The genomic path is unchanged (verified by review + tests).
- `R/bridge-payload.R` — `hs_build_genomic_bridge_payload` → generic
  `hs_build_relinv_bridge_payload(spec, primary)`, carrying `primary$relationship`.
- `R/julia-bridge.R` — the fit fn relabels the genetic component and provenance
  by `payload$relationship` (genomic / single_step); `hs_second_effect_target`
  and `hs_validate_julia_target` gain `single_step`.
- `R/hsquared.R` — the genomic target branch generalised to
  `target %in% c("genomic", "single_step")`.
- `R/model-spec-inspect.R` — the `model_spec()` guard generalised to error on
  either genomic or single_step.
- `R/{formula-status,validation-status,hs_control}.R`, `man/*`, `NEWS.md`,
  `ROADMAP.md`, `docs/design/{capability-status,06-public-claims-register}.md` —
  the supplied-relationship validation row was BROADENED (still 19 rows) to
  "experimental supplied-relationship estimator (opt-in: genomic, single-step)";
  formula-status marks `single_step()` fitted (opt-in); all surfaces mark it
  experimental/opt-in/REML-only, mirroring `V2-GREML` / `V2-SSHINV`, with building
  `Hinv` from pedigree+G (single-step HBLUP construction) noted as planned.

## Tests

- `tests/testthat/test-single-step.R` — parser acceptance, `Hinv` required,
  ids-in-`Hinv`, target validation, default-fit rejection, `model_spec()` error,
  and a skip-guarded **live single-step fit**.
- `tests/testthat/{test-model-spec-inspect,test-formula-animal}.R` — the
  placeholder `single_step()` rejection assertions (single_step was my
  "still-planned" example) now use genuinely-planned markers (`marker_scan()`,
  `markers()`).

## Checks

- `air format`; `devtools::document()`; `pkg::`-grep clean; `check_pkgdown()`
  clean; full `testthat` with juliaup + `NOT_CRAN` + sommer + enhancer (live
  single-step fit ran) — 0/0/0; `rcmdcheck(--as-cran)` 0 errors, 0 warnings, 1
  NOTE (benign). Review: clean.

## Boundary

Experimental, opt-in, REML-only; reachable only via `engine = "julia", target =
"single_step"` with a `single_step(1 | id, Hinv = Hinv)` term. The user supplies
the single-step relationship inverse; **building** `Hinv` from a pedigree + a
genomic relationship (single-step HBLUP construction), low-rank solves, and
comparator parity remain planned. Mirrors the twin `V2-SSHINV` gate (`partial`):
not the default, not ML, not production or comparator-validated. The v0.1,
repeatability, two-effect, and genomic paths are unchanged.

## State of the autonomous run

This is the sixth model surfaced in this run (default v0.1 animal model +
repeatability, common-environment, maternal, genomic GREML, single-step). All the
twin-engine-supported opt-in capabilities on Julia `main` are now surfaced. The
remaining roadmap (multivariate, factor-analytic G, non-Gaussian/GLLVM, unusual
inheritance, GPU) needs twin engine work that is not yet on `main`.
