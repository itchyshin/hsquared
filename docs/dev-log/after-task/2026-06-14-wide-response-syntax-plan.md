# After-Task Report: Wide-Response Matrix Syntax Plan

Date: 2026-06-14

## Task Goal

Define the future R syntax boundary for high-dimensional GLLVM, omics, and
community response matrices without crowding the current v0.1 animal-model API
or implying current support.

## Active Lenses And Spawned Agents

- Active lenses: Ada, Shannon, Boole, Noether, Jason, Pat, Rose, Grace.
- Spawned subagents: none.
- Current lane: coordinator/docs.

## Files Changed

- `docs/design/16-wide-response-syntax-plan.md`
- `docs/dev-log/scout/2026-06-14-wide-response-syntax-scout.md`
- `docs/design/05-roadmap.md`
- `docs/design/07-genomics-qtl-gpu-plan.md`
- `docs/design/11-next-50-slices.md`
- `docs/dev-log/check-log.md`
- `docs/dev-log/coordination-board.md`
- `docs/dev-log/after-task/2026-06-14-wide-response-syntax-plan.md`

## Formula Contract Review

- Accepted future wide syntax: `traits(...) ~ ...` for one row per unit and one
  response column per trait.
- Accepted future long syntax: `value ~ ...`, with explicit `trait =` and
  `unit =` arguments, compiling to the same observed-cell object as the wide
  route.
- Current live path remains `cbind(...) ~ animal(1 | id, pedigree = ped)` with
  opt-in `target = "multivariate"`.
- Deferred syntax: bare matrix LHS such as `Y ~ ...`, `expr_matrix ~ ...`, and
  `hsquared_matrix(Y, X, ...)`.
- Rejected for first public high-dimensional use: very large `cbind(...)`
  response lists.

## Checks Run

- `git diff --check` — passed.
- `rg -n "traits\\(\\.\\.\\.\\) fits|GLLVM support|omics model|ordination available|per-trait families supported|wide response matrices supported|supports GLLVM|fits GLLVM|implements GLLVM" docs/design/16-wide-response-syntax-plan.md docs/dev-log/scout/2026-06-14-wide-response-syntax-scout.md docs/design/05-roadmap.md docs/design/07-genomics-qtl-gpu-plan.md docs/design/11-next-50-slices.md` — only the scout note's explicit high-risk phrase list matched.
- `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64 /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e "pkgdown::check_pkgdown()"` — passed, "No problems found."
- `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64 /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e "devtools::check(document = FALSE, args = '--no-manual')"` — passed, 0 errors / 0 warnings / 0 notes.
- Previous commit `c0a3563` remote checks were green:
  - R-CMD-check `27505365372`
  - pkgdown `27505365382`
  - Pages `27505414409`

## Public Claim Audit

Clean with limitations. The design note repeatedly states that `traits(...)`,
long stacked-cell GLLVM syntax, omics models, ordination, per-trait family
support, and wide-response matrix fitting are planned. No parser, bridge, engine,
or extractor support is claimed.

## Tests Of The Tests

This was a documentation/design slice. The meaningful tests were:

- pkgdown and package checks to ensure the repository still builds;
- a targeted Rose grep for common over-claim phrasing;
- source/scout links to local sister packages and external GLLVM references so
  the syntax decision is not chat-only.

## Coordination Notes

This was R/coordinator documentation only. No Julia files were edited. The note
explicitly says the Julia engine must define the matrix/observed-cell payload
before R exposes live wide-response fitting.

## What Did Not Go Smoothly

No implementation blocker. The main design risk is ambiguity around a bare
matrix left-hand side (`Y ~ ...`), so the note defers that syntax in favour of
explicit `traits(...)`.

## Known Limitations

- `traits(...)` is not exported or parsed in `hsquared`.
- No `sample_factors()`, `site_factors()`, `animal_fa()`, or GLLVM-style engine
  target exists in `hsquared`.
- No non-Gaussian wide-response bridge exists.
- No ordination, loading interpretation, per-trait family, or missing-cell
  prediction support exists.

## Next Actions

- Commit and push this design slice, then watch R-CMD-check and pkgdown.
- A future R slice can reserve `traits(...)` only when it also adds explicit
  planned-not-implemented errors and `formula_status()` rows.
- A future Julia slice should define the observed-cell payload and tiny
  wide-to-long equivalence fixture before any live bridge is attempted.
