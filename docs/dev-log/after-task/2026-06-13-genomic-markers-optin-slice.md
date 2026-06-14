# Opt-in marker-based genomic GREML (build the relationship from markers)

Date: 2026-06-13 (autonomous overnight; user away till ~05:00)

Active lenses: Ada, Hopper, Gauss, Henderson, Kirkpatrick, Curie, Rose.
Spawned subagents: 2-agent review (hopper-r-julia-translator regression/correctness
`a05b5e7c716abe0a6` + rose-systems-auditor honesty `af664757db1486c13`). Both
returned **no blockers**; their should-fix items were acted on (see below).

Current lane: R (hsquared). Twin engine read read-only; no twin edits.

## Goal and context

Extends the genomic GREML opt-in slice so the genomic relationship can be built
**from a raw marker matrix** in the engine, not only from a precomputed inverse:
`genomic(1 | id, markers = M)` as an alternative to `genomic(1 | id, Ginv = Ginv)`.
The engine builds `G = WWᵀ/k` (`HSquared.genomic_relationship_matrix`) and inverts
it with a ridge (`genomic_relationship_inverse`), then runs the same `fit_ai_reml`
REML estimator. Mirrors twin gates `V2-GREML` / `V2-GRM` / `V2-GINV` (all
`partial`).

## What changed

- `R/model-spec.R` — `hs_parse_relinv_primary_call` now accepts, for a `genomic()`
  primary, **exactly one** of `Ginv` or `markers` (both → error; neither →
  error; `single_step()` still accepts only `Hinv`). The markers branch validates
  the matrix (`hs_validate_genomic_markers`), takes `ids <- rownames(markers)`,
  checks data ids ⊆ marker rows, and returns a spec with `source = "markers"`,
  `markers = M` (and no `ginv`). `bridge_target` for the markers path is the
  engine `genomic_relationship_inverse(genomic_relationship_matrix(markers))`
  descriptor. `hs_eval_genomic_ginv` gained a `what` argument so the
  eval-failure message names the actual argument (`markers`/`Ginv`/`Hinv`)
  instead of always saying `Ginv` (**hopper should-fix #1**).
- `R/bridge-payload.R` — `hs_build_relinv_bridge_payload` branches on
  `source`: markers path carries `markers` + `relationship_source = "markers"`
  + `ridge = 0.01` and `Ginv = NULL`; supplied path is unchanged (`Ginv` set,
  `markers = NULL`). **Z/id alignment invariant** (verified by review): `Z`
  columns are laid out in `ids = rownames(markers)` order, `unname()` preserves
  row order into Julia, and `genomic_relationship_matrix`/`_inverse` are
  row-order-preserving — so `Z` column j ↔ `ids[j]` ↔ marker row j ↔ `Ginv`
  row/col j with no reordering step anywhere.
- `R/julia-bridge.R` — `hs_fit_julia_genomic_payload` branches on
  `relationship_source`: markers path assigns `hsq_markers` + `hsq_ridge` and
  runs `genomic_relationship_matrix` → `genomic_relationship_inverse(...;
  ridge = hsq_ridge)` → `sparse()`; supplied path still does `sparse(hsq_Ginv)`.
  Internal guards error clearly if `markers` is NULL on the markers path or
  `Ginv` is NULL on the supplied path. Same `fit_ai_reml`, normalizer, and
  `estimated_genomic_ai_reml` provenance.
- Honesty surfaces — `R/{validation-status,hs_control}.R`, `man/hs_control.Rd`,
  `NEWS.md`, `ROADMAP.md` (Phase 5 status paragraph **and** bullet now both name
  the marker option — **rose in-slice nit**), `docs/design/{capability-status,
  06-public-claims-register}.md`: the genomic GREML row stays `partial` and now
  says genomic accepts a supplied `Ginv` **or** a marker matrix (engine-built G),
  still REML-only / Julia-owned / not the default / not comparator-validated.

## Tests

- `tests/testthat/test-genomic.R` — new: parse `markers` → `source = "markers"`
  (and `ginv` absent); reject `Ginv` + `markers` together; marker ids must cover
  data ids; **two non-live payload tests** asserting the markers path sets
  `relationship_source = "markers"`/`Ginv = NULL`/`markers` populated and the
  supplied path stays `"supplied"`/`markers = NULL`/`Ginv` set (**hopper
  should-fix #3** — the markers→payload wiring previously had zero CI-runnable
  coverage, only the skip-guarded live fit); plus a skip-guarded **live
  marker-based GREML fit**.

## Checks

- `air format`; `devtools::document()`; **`pkg::`-vs-Imports grep** (clean — only
  declared `JuliaCall::`); **`pkgdown::check_pkgdown()` clean**; full `testthat`
  with juliaup + `NOT_CRAN` + sommer + enhancer (live marker fit ran) — **0/0/0**
  (0 skipped → the live Julia paths executed); `rcmdcheck(--as-cran)` **0 errors,
  0 warnings, 1 NOTE** (benign new-submission/dev-version boilerplate).
- Review (no blockers): hopper traced the supplied-`Ginv`/`Hinv` paths as
  un-regressed and confirmed the Z/G permutation-class risk is sound; rose
  confirmed all six honesty surfaces are consistent and the row stays `partial`.

## Boundary

Experimental, opt-in, REML-only; reachable only via `engine = "julia", target =
"genomic"`. `genomic(1 | id, markers = M)` builds `G` from the markers with a
fixed `ridge = 0.01` (no user knob yet); `genomic(1 | id, Ginv = Ginv)` and
`single_step(1 | id, Hinv = Hinv)` are unchanged. Weighted/standardized-marker
G variants, building `Hinv` from a pedigree + G, SNP-BLUP, APY, low-rank m≫n
solves, and AGHmatrix/sommer/BLUPF90 comparator parity remain planned. Mirrors
the twin `V2-GREML`/`V2-GRM`/`V2-GINV` gates (`partial`): not the default, not
ML, not production or comparator/known-truth-validated. The v0.1 animal,
repeatability, two-effect, supplied-`Ginv` genomic, and single-step paths are
unchanged.

## Follow-up (separate commit, same session)

The `model-status` vignette still listed `genomic()`/`single_step()`/
`permanent()`/`common_env()`/`maternal_genetic()` as "error as not implemented"
— stale since the earlier committed opt-in slices, not caused by this slice but
flagged by rose. Corrected in a follow-up commit: added an "Opt-in and
experimental (not the default)" section and removed the now-false
"not implemented" claims for those five terms.
