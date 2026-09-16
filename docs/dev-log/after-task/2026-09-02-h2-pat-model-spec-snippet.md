# After-task — leftover `model_spec(spec)` on the limits page

**Date:** 2026-09-02
**Lane:** R (`hsquared`) — campaign worktree
`~/local-scratch/lanes/hsquared-h2-twin-20260901`, branch
`claude/lane-h2-twin-20260901`.
**Active lenses:** Pat (applied-user walk). Ada/Shannon/Rose as perspectives.
**Spawned subagents:** none
**Current lane:** R docs only

**Fence held:** `public_covered_count` **5** · no `validation_status()` row ·
draft #141 · no G10 · no merge-to-main claim.

---

## Task goal

Fix the remaining copy-paste `model_spec(spec)` snippet that errors because
`data` is required, and confirm the current-limits pkgdown article exists in
the campaign tree.

## Files changed

- `vignettes/articles/current-limits.Rmd` — validate-only block now calls
  `model_spec(weight ~ sex + animal(1 | id, pedigree = ped), data = dat)`,
  matching `65ec743` and the live API.
- this report + `docs/dev-log/check-log.d/2026-09-02-h2-pat-model-spec-snippet.md`
- `docs/dev-log/coordination-board.md` (one row)

`_pkgdown.yml` was already listing `articles/current-limits` in Get started,
Status, and the articles index. No YAML edit.

## Checks run and exact outcomes

- `rg -n 'model_spec\(spec\)'` after the edit: **no remaining hits**
  (README / `vignettes/hsquared.Rmd` / function-map already fixed in `65ec743`).
- `Rscript -e 'pkgdown::check_pkgdown()'` → **No problems found**.
- Live site `articles/current-limits.html` → **404**. The article is absent
  from `origin/main` (`git ls-tree` / `_pkgdown.yml` grep). Campaign tree is
  correct; deploy is not claimed until `main`.

## Public claim audit

Snippet-only. No capability-status, validation-debt, or `validation_status()`
edit. The page still says most routes are experimental and that no interval
is coverage-calibrated.

## Tests of the tests

None. The chunk stays `eval = FALSE` (no pedigree in that article). The
working copy-paste path is the README / Getting started four-animal demo.

## Coordination notes

Took a docs-only slice on `claude/lane-h2-twin-20260901`. Did not touch
Boole's leased `R/` / test files (`cursor:hsquared-h2-twin-20260901:boole-item6-maternal-error`).
Foreign Codex v0.7 performance lane remains live — not touched.

## What did not go smoothly

Live pkgdown 404 is expected until merge-to-main + Pages deploy. Do not
read this commit as a live-site fix.

## Known limitations

- Limits-page chunk is still `eval = FALSE` (no local `ped`/`dat`).
- `_pkgdown.yml` already had the article; this slice does not change
  navbar structure.

## Next actions

Keep the fence. Merge/deploy of current-limits is a `main` event, not this
push.
