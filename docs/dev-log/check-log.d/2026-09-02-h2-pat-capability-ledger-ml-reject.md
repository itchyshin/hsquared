# 2026-09-02 -- Pat: capability-ledger ML reject wording

**Lane:** R (`hsquared`). **Branch:** `claude/lane-h2-twin-20260901`.
**Worktree:** `~/local-scratch/lanes/hsquared-h2-twin-20260901`.
**Lens:** Pat (applied user). **No covered flip.**
**No `validation_status()` row added.** `public_covered_count` stays 5.
**No push.**

## Goal

Align the generated v0.1 capability-ledger card with `ef54db4` /
Getting started (`9ee0ca7`) / leftover articles (`7e66f29`) so
`REML = FALSE` is not described as "ML is rejected on this path".

## Commands and outcomes

| Command | Result |
|---|---|
| R parse of `hs_route_table()[[1]]$scope` | matches the include sentence; names `REML = FALSE`, `REML = TRUE`, default fit, and `engine = "validate"`; says covered is this REML estimator, not ML |
| Python ASCII scan of the edited ML / validate sentence in the include and generator | ASCII only |
| `rg` for `ML is rejected on this path` in the include and generator | no matches |
| `git diff --check` | clean |

`devtools::test()` / `devtools::check()` / pkgdown not run: one
generated card sentence; no `R/` change. Behaviour already pinned by
`test-reml-false-validate.R` at `ef54db4`. No MC / Firefox.

## Claim boundary

- No `validation_status()` rows.
- No `public_covered_count` move.
- No LOOP edit.
- No push.
