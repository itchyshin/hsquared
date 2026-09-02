# After-task — leftover formula-grammar Error rule

**Date:** 2026-09-02
**Lane:** R (`hsquared`) — campaign worktree
`~/local-scratch/lanes/hsquared-h2-twin-20260901`, branch
`claude/lane-h2-twin-20260901`.
**Active lenses:** Pat (applied-user walk). Ada/Shannon/Rose as perspectives.
**Spawned subagents:** none
**Current lane:** R docs only
**Checks:** `docs/dev-log/check-log.d/2026-09-02-h2-pat-formula-grammar-error-rule.md`

**Fence held:** `public_covered_count` **5** · no `validation_status()` row ·
draft #141 · no G10 · no merge-to-main claim.

---

## Task goal

Replace the stale formula-grammar Error rule so a breeder who types
`markers()` or `common_env()` sees the same words the package actually
prints.

## Files changed

- `vignettes/articles/formula-grammar.Rmd` — Error rule now shows
  reserved-marker + nearest-path (`hs_stop_planned_marker`, `9ba841d`)
  and one `common_env()` next-call paste (`672368c`).
- this report + `docs/dev-log/check-log.d/2026-09-02-h2-pat-formula-grammar-error-rule.md`

No `R/` edit. Coordination board not edited (shared file; sibling R1–R3
slices are live).

## Checks run and exact outcomes

- Live `markers()` / `common_env()` errors captured with
  `devtools::load_all()` before the rewrite; article examples use those
  words (`data = dat` in the paste, matching the golden-path object name).
- Stale `` `marker()` is planned `` gone from this article.
- Error-rule section is ASCII (0 non-ASCII).
- `pkgdown::check_pkgdown()` → **No problems found**.

## Public claim audit

Docs restatement only. Common-environment two-effect stays covered for
point estimates at validation scale; intervals stay experimental. No
capability-status, validation-debt, or `validation_status()` edit.

## Tests of the tests

None. The article chunks stay `eval = FALSE`. Live wording is already
pinned in `tests/testthat/test-formula-animal.R` and
`tests/testthat/test-common-env.R`.

## Coordination notes

Took Ada remaining-R4 lease on `vignettes/articles/formula-grammar.Rmd`.
Read `git diff HEAD..codex/2026-07-13-v07-performance-localization --`
that file before writing: the foreign Error rule is an older leftover
(parser-only-`animal`), not a next-call implementation. Did not adopt it.
Did not touch Codex v0.7 files. Did not touch dirty sibling `R/` / `man/`
from other catch-up slices.

## What did not go smoothly

Lane-check flagged the Codex branch. Their article also still says
`permanent()` / `common_env()` / `maternal_genetic()` are inert. That is
the campaign honesty this branch already fixed. Building on their text
would regress it.

## Known limitations

- `maternal_genetic()` parser stops that fire *before* the default-path
  abort remain R2 (not this lease).
- The article still says reserved names "error as planned, not
  implemented" in earlier sections. That is still the first sentence of
  the live reserved-marker stop.

## Next actions

Keep the fence. R5 quieter status prints only after R1–R4 land.
