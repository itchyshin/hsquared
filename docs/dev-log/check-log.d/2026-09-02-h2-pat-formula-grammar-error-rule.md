# 2026-09-02 — Pat leftover R4: formula-grammar Error rule

**Lane:** R (`hsquared`). **Branch:** `claude/lane-h2-twin-20260901`.
**Worktree:** `~/local-scratch/lanes/hsquared-h2-twin-20260901`.
**Lens:** Pat (applied-user docs). **No covered flip.**
**No `validation_status()` row added.** `public_covered_count` stays 5.

## Goal

The formula-grammar Error rule still quoted a stale

```text
`marker()` is planned, not implemented. Run `formula_status()` ...
```

stop. Live reserved markers use `hs_stop_planned_marker()` (nearest-path
clause from `9ba841d`). Parsed-but-not-default terms paste the next
`hsquared()` call (`672368c`).

## Commands and outcomes

Live errors captured with `devtools::load_all()` in this worktree before
the edit:

| Call | Live first sentence / paste |
|---|---|
| `markers(M, model = "random")` | `` `markers()` is planned, not implemented. The live marker path is `genomic(1 \| id, markers = )` or `gwas(fit, markers)`. `` then `formula_status()` |
| `common_env(1 \| litter)` on the default path | `` `common_env()` is not on the default path. `` then `Closest working call:` and `target = "two_effect"` |

| Command | Result |
|---|---|
| `rg -n 'marker\(\)\|currently accepts only\|exported but inert' vignettes/articles/formula-grammar.Rmd` after edit | no hits |
| Python scan of the Error rule section | **0** non-ASCII code points |
| `Rscript -e 'pkgdown::check_pkgdown()'` | **No problems found** |

`devtools::document()` / `devtools::test()` / `devtools::check()` not run:
docs article only.

## Claim boundary

- Docs only. No `R/` change. No auto-route. No sixth covered model.
- The `common_env()` example restates the already-documented validation-scale
  common-environment coverage. Intervals stay experimental.
- Foreign `codex/2026-07-13-v07-performance-localization` also edits this
  article; its Error rule is a different leftover (`marker()` plus
  "parser currently accepts only `animal(...)`"). Not adopted.
