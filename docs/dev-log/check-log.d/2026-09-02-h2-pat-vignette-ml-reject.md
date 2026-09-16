# 2026-09-02 -- Pat: remaining vignette ML reject wording

**Lane:** R (`hsquared`). **Branch:** `claude/lane-h2-twin-20260901`.
**Worktree:** `~/local-scratch/lanes/hsquared-h2-twin-20260901`.
**Lens:** Pat (applied user). **No covered flip.**
**No `validation_status()` row added.** `public_covered_count` stays 5.
**No push.**

## Goal

Align `fitting-models.Rmd`, `model-status.Rmd`, and `validation-evidence.Rmd`
with `ef54db4` / Getting started (`9ee0ca7`) so `REML = FALSE` is not
described as rejected only on the fit path.

## Commands and outcomes

| Command | Result |
|---|---|
| Python ASCII scan of the edited ML / validate lines in the three articles | ASCII only |
| `rg` for `fit path` in those three files | no matches |
| `git diff --check` | clean |

`devtools::test()` / `devtools::check()` / pkgdown not run: three
vignette sentences; no `R/` change. Behaviour already pinned by
`test-reml-false-validate.R` at `ef54db4`. No MC / Firefox.

## Claim boundary

- No `validation_status()` rows.
- No `public_covered_count` move.
- No LOOP edit.
- No push.
