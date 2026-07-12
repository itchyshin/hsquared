# After-Task: doc-site R-lane quick-win batch (H6/M1/M2/M3/L5/L6)

**Date:** 2026-07-12 · **Lane:** R (vignettes + `_pkgdown.yml`) ·
**Owner:** Ada / Rose · **PR:** #133 · **Branch:** `docs/2026-07-12-docsite-quickwins`

## Task goal

Land the R-lane subset of the 2026-07-11 doc-site audit quick wins: fix the one
true R-side honesty overclaim (H6) plus the under-claim doc-drift and navbar-sync
items (M1/M2/M3/L5/L6). Doc/YAML only — no code-path change, no covered flip,
`public_covered_count` untouched. Larger positioning work (H1/H2/H3/H5) and the
twin's Documenter items (H4/M8/M9/M10/L8–L12) are explicitly out of scope.

## Active lenses and spawned agents

- Lenses: Ada (integration), Florence (H6 uncertainty display), Rose (honesty),
  Boole (grammar wording), Jason (navbar/best-practice).
- Spawned subagents: **1** — `rose-systems-auditor` (independent honesty audit of
  the diff vs `capability-status.md`).
- Current lane: R.

## Files created or changed

- `_pkgdown.yml` — two navbar Articles entries added (M1).
- `vignettes/articles/visualizing-models.Rmd` — `heritability` attached to the
  illustrative `fit_mv` (H6).
- `vignettes/hsquared.Rmd` — common_env covered split + relmat/precision to
  opt-in experimental (L5, M2).
- `vignettes/articles/model-status.Rmd`, `vignettes/articles/inheritance-systems.Rmd`
  — relmat/precision to opt-in experimental (M2).
- `vignettes/articles/qtl-gwas-eqtl-status.Rmd`,
  `vignettes/articles/genomic-prediction.Rmd` — scoped `genome_wide` permutation
  framing (M3) + orphaned-qualifier join (L6).
- `docs/dev-log/check-log.md` (2026-07-12 entry), this report.

## Checks run and exact outcomes

- `Rscript -e 'pkgdown::check_pkgdown()'` → **No problems found**.
- `rmarkdown::render("vignettes/articles/visualizing-models.Rmd")` → **OK**,
  706 KB HTML, figures rendered.
- H6 assertion (`devtools::load_all()` + `autoplot(fit_mv, "g_matrix")`):
  subtitle carries the "involves a low-h² (< 0.1) trait — correlation imprecise"
  flag, **`ANY_DAGGER_FLAG: TRUE`** (was FALSE at audit).
- PR #133 R-CMD-check triggered on push (doc-only; no R source or tests touched).

## Public claim audit

- Every wording edit keyed to `capability-status.md`: row 29 (common_env
  **covered** at validation scale), row 33 (relmat/precision **partial /
  experimental / NOT covered**, count unchanged), row 46 (scoped
  `method="single", genome_wide=TRUE` add-one permutation; mixed/loco
  uncalibrated).
- No surface flipped from partial→covered; `public_covered_count` untouched (no
  edit to any count-bearing line).
- H6 removes a real overclaim (a promised safety flag that did not render); it
  does not add a new capability claim — the flag is a labelled heuristic, still
  "not a calibrated precision statement" per `R/autoplot.R`.

## Tests of the tests

- The H6 assertion is run against the *exact* object the vignette now defines
  (copied verbatim), so a green assertion proves the rendered figure — not a
  hand-tuned variant — carries the flag.
- `check_pkgdown()` validates the navbar↔articles↔reference wiring, so the M1
  additions are proven consistent, not just syntactically valid YAML.

## Coordination notes

- Twin-lane Documenter items from the same audit (H4 validation-status codegen,
  M8 missing api.md symbols, M9 `warnonly` scoping, M10/L10–L12 reconciliations)
  remain **owed on `HSquared.jl`** — not editable from this repo; to be prepared
  turnkey for a Codex/user session, never concurrently.

## What did not go smoothly

- The audit path `vignettes/visualizing-models.Rmd` was actually
  `vignettes/articles/visualizing-models.Rmd`; located via `ls vignettes/articles`.

## Known limitations

- Positioning quick wins (H1 runnable examples + toy `data()`, H2 README
  restructure, H3 article regrouping, H5 mission-control demotion) are a separate
  larger slice, not attempted here.
- No engine required for any check; live-fit rendering of gryphon/G-matrix
  figures (L7) not addressed.

## Next actions

1. Merge PR #133 after R-CMD-check green (with #131/#132 in the maintainer's merge
   order).
2. Prepare the twin Documenter items turnkey for the next Codex/user session.
3. Resume the DO-NEXT fork the maintainer picks (MV-5 threaded-Julia port; NG-1
   §8 → Boole freeze; or #131/#132 merge + 0.5 release decisions).
