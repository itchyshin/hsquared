# Opt-in SNP-BLUP / RR-BLUP marker-effect model (supplied-variance)

Date: 2026-06-13 (autonomous overnight; user away till ~05:00)

Active lenses: Ada, Hopper, Gauss, Henderson, Kirkpatrick, Curie, Rose.
Spawned subagents: 2-agent review — `hopper-r-julia-translator`
(`a105f3f97181ec007`, alignment/regression/wiring) and `rose-systems-auditor`
(`ad54a93ee199c04b7`, honesty). Both found the **same one BLOCKER** (a botched
claims-register table edit) plus one should-fix and one nit; all fixed. The
bridge/engine logic itself was reviewed CLEAN.

Current lane: R (hsquared). Twin engine read read-only; no twin edits.

## Goal and context

The genomic-surface capstone among models on twin `origin/main` (`100adbe`):
SNP-BLUP / RR-BLUP marker effects. `fit_snp_blup` (V2-SNPBLUP, `partial`) is a
supplied-variance marker model (the twin twin of GBLUP, with the pinned
GBLUP↔SNP-BLUP GEBV equivalence). A direct bridge probe confirmed the call and
result shape (`marker_effects`, `gebv`, `beta`, `k`, `p`) and that the GBLUP
equivalence holds at `ridge = 0` (the 4.95e-3 gap in the probe was exactly the
genomic-inverse ridge in the comparison, not SNP-BLUP). Twin Phase 3/4
multivariate work is branch-only — not surfaceable — so this is the honest
frontier for buildable models.

## What changed

- `R/hsquared.R` — opt-in `target = "snp_blup"` routing branch (requires a
  `genomic(1 | id, markers = M)` markers primary and `variance_components`
  named `sigma_g2`/`sigma_e2`, validated in the routing before the bridge so
  the error is deterministic without Julia). The single-effect guard now uses
  `hs_effect_targets()` (vector) so a genomic markers primary may fit via either
  `genomic` (GREML) or `snp_blup`. `snp_blup` joins `henderson_mme` as a
  supplied-variance target exempt from the `REML = FALSE` rejection.
- `R/julia-bridge.R` — `hs_fit_julia_snp_blup_payload` builds the per-record
  marker design `Z %*% markers` (aligned with `y` via the shared `ids` order),
  calls `fit_snp_blup` at the supplied variances, and recomputes the
  per-individual GEBV as `centered_markers(markers; allele_frequencies = snp.p).W
  * marker_effects` (same centering as the fit, so per-individual GEBV equals the
  per-record GEBV exactly). `hs_normalize_julia_snp_blup_result` returns
  per-marker effects, per-individual GEBVs, fixed effects, supplied-variance h2,
  and `variance_components_source = "supplied"`. Added
  `hs_validate_snp_blup_variances`, `hs_effect_targets`, and `snp_blup` to
  `hs_validate_julia_target`.
- `R/bridge-payload.R` — carry `marker_names` (the marker matrix colnames, which
  `unname()` strips) so `marker_effects()` can label the rows.
- Honesty surfaces — `R/{validation-status,hs_control,extractors}.R`, `man/*`,
  `NEWS.md`, `ROADMAP.md` (Phase 5: SNP-BLUP moved from planned to a surfaced
  opt-in bullet), `docs/design/{capability-status,06-public-claims-register}.md`,
  `vignettes/articles/{model-status,fitting-models}.Rmd`: a new `partial`
  SNP-BLUP row (`validation_status()` now 20 rows), all fenced as
  experimental/opt-in/supplied-variance mirroring `V2-SNPBLUP`; `marker_effects()`
  carved out of the "reserved placeholder" set across NEWS, the register, the
  vignette, and the roxygen.

## Tests

- `tests/testthat/test-snp-blup.R` — target acceptance, markers-required (animal
  formula and supplied-`Ginv` both rejected), variance_components-required, the
  `sigma_g2`/`sigma_e2` validator, and a skip-guarded **live SNP-BLUP fit**
  asserting `marker_effects()` length = m and marker labels, `breeding_values()`
  length = n individuals, supplied-variance h2, and `"supplied"` provenance.
- `tests/testthat/test-phase0-api.R` — `validation_status()` nrow 19 → 20.

## Checks

- `air format`; `devtools::document()`; `pkg::`-grep clean (only declared
  `JuliaCall::`) + `pkgdown::check_pkgdown()` clean; full `testthat` with juliaup
  + `NOT_CRAN` + sommer + enhancer (live SNP-BLUP fit ran) — **0/0/0**;
  `rcmdcheck(--as-cran)` **0 errors / 0 warnings / 1 NOTE** (benign new submission).
- Review: hopper cleared the corruption-class checks — per-record marker
  alignment is permutation-free, per-individual GEBV is internally consistent
  (shared `snp.p` centering), routing is non-regressive, extractor wiring is
  correct. Both reviewers caught a botched claims-register edit (line 23 merged
  the SNP-BLUP row with the orphaned tail of the fitted-object/extractor row,
  silently deleting that row's leading cells); restored — register is +1 net row
  with the fitted-object row intact.

## Boundary

Experimental, opt-in, **supplied-variance** (the user supplies `sigma_g2` and
`sigma_e2`, e.g. from a prior GREML fit; the variances are NOT estimated);
reachable only via `engine = "julia", target = "snp_blup"` with a
`genomic(1 | id, markers = M)` term. Returns per-marker effects and per-individual
GEBVs. Mirrors the twin `V2-SNPBLUP` gate (`partial`); the GBLUP↔SNP-BLUP
equivalence is the twin's pinned property and is CITED, not re-tested through the
R surface (the R live test is a shape/label/provenance smoke test). REML
estimation of the marker variance, weighted/Bayesian marker priors, low-rank
m≫n Woodbury solves, and JWAS/sommer/BLUPF90 comparator parity remain planned.
Not the default, not comparator/known-truth-validated. The v0.1 animal,
repeatability, two-effect, genomic (supplied-`Ginv` and markers), and single-step
paths are unchanged.

## Frontier note

With SNP-BLUP landed, the R lane has surfaced every model whose engine support
is on Julia `main` (`100adbe`): v0.1 animal (default, covered) + six opt-in
experimental models (repeatability, common-environment, maternal-genetic,
genomic GREML supplied-`Ginv`-or-markers, single-step, SNP-BLUP). The next
substantial capability is **multivariate / multi-trait** (genetic correlations,
cross-trait EBVs), which the twin is actively building on the
`phase4-multivariate-reml` BRANCH (`fit_multivariate_reml`, `multivariate_mme`,
unbalanced/missing-trait) — NOT yet on Julia `main`, so it is not honestly
surfaceable from R yet. Phases 4/6/7/8 (factor-analytic G, non-Gaussian/GLLVM,
non-standard inheritance, GPU/scale) are unstarted in the engine. This is the
honest stopping point for buildable R-lane model surfacing until the twin lands
multivariate on `main`.
