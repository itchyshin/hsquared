# Overnight honesty sweep: stale "planned/inert" claims for now-opt-in models

Date: 2026-06-13 (autonomous overnight; user away till ~05:00)

Active lenses: Ada, Rose, Boole, Pat, Emmy, Fisher, Curie (via a multi-agent
audit workflow). Spawned subagents: a 26-agent Workflow
(`hsquared-overnight-honesty-audit`, run `wf_158f535d-1c2`) — 6 parallel audit
dimensions → adversarial refutation of every candidate → prioritized confirmed
list. Current lane: coordinator + R (docs/strings only). No twin edits.

## Why this task

After eight autonomous commits in one night added opt-in experimental models
(repeatability, common-env, maternal, genomic GREML, single-step, SNP-BLUP),
the per-slice reviews updated the surfaces each slice touched but did not
revisit older surfaces. A package-wide audit was run to catch any cross-slice
drift. It confirmed **16 defects** (from 20 candidates after adversarial
verification), all one class: stale "planned / not implemented / inert"
wording for models that now fit opt-in. Notably the audit found **zero
over-claims** — the honesty discipline's main guard (never advertise
non-`covered` work as working) held all night; every defect *under*-claimed a
shipped opt-in capability. Critical dimensions came back CLEAN: opt-in wiring
(every documented target has routing + bridge + live test + an engine fn on twin
`origin/main`), multivariate correctly NOT claimed anywhere, the claims register
well-formed (42 rows × 4 cols), and the 3 `covered` rows correctly backed.

## What changed (all docs/strings; no fitting logic)

- `README.md` — the "reserves planned formula markers … abort as planned, not
  implemented" blanket and the "genomic … remain planned" line now carve out the
  opt-in fitted models (permanent/common-env/maternal/genomic/single-step) with
  the experimental/opt-in/not-default fence; `marker_effects()` noted live for
  SNP-BLUP.
- `DESCRIPTION` — "genomic … planned" → genomic/single-step fit opt-in.
- `R/genomic-markers.R`, `R/qg-effects.R` roxygen (→ `man/genomic_markers.Rd`,
  `man/qg_effect_markers.Rd`) — the help pages no longer claim genomic()/
  single_step()/permanent()/common_env()/maternal_genetic() are "inert … the
  parser rejects them"; they describe the opt-in fitted paths and keep the
  genuinely-inert markers (markers/marker_scan/qtl_scan, paternal/dominance/…)
  as rejected.
- `R/formula-status.R` — **bug**: the live `formula_status()` table advertised
  `maternal_genetic(1 | dam, pedigree = ped)`, a form the parser rejects
  ("takes no extra arguments"); corrected to the working `maternal_genetic(1 | dam)`.
- `R/validation-status.R` — evidence over-statements: the repeatability,
  two-effect, and genomic/single-step rows claimed the live tests check "finite
  REML logLik" (they do not; only the sparse_reml/ai_reml/default rows assert
  it); removed that clause and scoped the per-leg heritability claims to the legs
  that actually assert them (common-env leg; supplied-Ginv genomic leg). Status
  table unchanged (20 rows: 3 covered / 10 partial / 7 planned).
- `docs/design/capability-status.md`, `docs/design/06-public-claims-register.md`
  — the "Genomic/QTL formula markers" rows no longer say genomic()/single_step()
  are purely inert/"no genomic fitting"; scoped to the default path with a
  pointer to the opt-in genomic GREML / single-step row (resolving a
  self-contradiction with those same documents' partial rows).
- `vignettes/{hsquared,articles/formula-grammar,articles/genomics-gpu-roadmap}.Rmd`
  — the getting-started, grammar, and genomics-roadmap pages no longer describe
  the opt-in models as "do not fit / planned"; each now fences them as opt-in
  experimental. `vignettes/articles/mission-control.Rmd` — stale "16
  validation-status rows" metric → 20.

## Checks

- `air format`; `devtools::document()` (regenerated the two help pages);
  `pkg::`-grep clean (no new deps); `pkgdown::check_pkgdown()` clean; full
  `testthat` with juliaup + `NOT_CRAN` + sommer + enhancer — **0/0/0**;
  `rcmdcheck(--as-cran)` **0/0/1** (benign). `validation_status()` 20 rows
  (3/10/7) and `formula_status()` maternal term verified post-edit.

## Boundary

Documentation/string honesty only; no fitting-capability change. The fixes make
every surface consistent with the package's own `formula_status()` /
`validation_status()` tables and with the standing fence (experimental, opt-in,
Julia-owned, REML-only or supplied-variance, not the default, not
comparator/known-truth-validated). The audit's CLEAN dimensions (opt-in wiring,
multivariate-not-claimed, register well-formedness, covered-row backing) are
recorded as positive evidence.
