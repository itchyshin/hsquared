# 2026-09-02 — Boole 8 + Pat 5: pkgdown live verbs first

**Lane:** R (`hsquared`). **Branch:** `claude/lane-h2-twin-20260901`.
**Worktree:** `~/local-scratch/lanes/hsquared-h2-twin-20260901`.
**Lens:** Emmy (pkgdown / reference IA). **No covered flip.**
**No `validation_status()` row added.** `public_covered_count` stays 5.

## Goal

Put live verbs first on the reference index. Move genomic / G-matrix /
QTL pages out of the Status first screen into Developer. Leave
`validation_status()` rows and NAMESPACE alone.

## Commands and outcomes

| Command | Result |
|---|---|
| `Rscript -e 'pkgdown::check_pkgdown()'` | **No problems found** |

`devtools::document()` / `devtools::test()` / `devtools::check()` not run:
YAML information architecture only. `?hsquared` not shortened — Grace
holds `R/hsquared.R`.

## Claim boundary

- No export, no roxygen source, no capability or validation row.
- Genomic / G-matrix / QTL articles remain in the site under Developer.
- Reserved formula markers stay exported; they are now last on the
  reference index, not in Start here.
