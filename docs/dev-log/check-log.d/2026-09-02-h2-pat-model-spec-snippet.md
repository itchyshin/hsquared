# 2026-09-02 — Pat walk pain: leftover `model_spec(spec)` on current-limits

**Lane:** R (`hsquared`). **Branch:** `claude/lane-h2-twin-20260901`.
**Worktree:** `~/local-scratch/lanes/hsquared-h2-twin-20260901`.
**Lens:** Pat (applied-user docs). **No covered flip.**
**No `validation_status()` row added.** `public_covered_count` stays 5.

## Goal

`model_spec()` requires `formula` and `data`. Golden-path sibling `65ec743`
already rewrote README / Getting started / function-map. The limits article
still called `model_spec(spec)`, which errors with `` `data` is required. ``

## Commands and outcomes

| Command | Result |
|---|---|
| `rg -n 'model_spec\(spec\)'` after edit | no remaining user-facing hits |
| `Rscript -e 'pkgdown::check_pkgdown()'` | **No problems found** |
| Live `https://itchyshin.github.io/hsquared/articles/current-limits.html` | **404** (article is not on `origin/main`; campaign tree already lists it in `_pkgdown.yml`) |

`devtools::document()` / `devtools::test()` / `devtools::check()` not run:
vignette snippet + ledger only.

## Claim boundary

- Live API unchanged: `model_spec(formula, data, family = gaussian(), REML = TRUE, ...)`.
- Article exists at `vignettes/articles/current-limits.Rmd` and is already in
  `_pkgdown.yml` navbar + articles. Deploy stays 404 until this lands on `main`.
- No capability, validation, or `public_covered_count` edit.
