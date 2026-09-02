# 2026-09-02 -- Pat: Getting started REML rule + leftover ASCII Rd

**Lane:** R (`hsquared`). **Branch:** `claude/lane-h2-twin-20260901`.
**Worktree:** `~/local-scratch/lanes/hsquared-h2-twin-20260901`.
**Lens:** Pat (applied user). **No covered flip.**
**No `validation_status()` row added.** `public_covered_count` stays 5.
**No push.**

## Goal

Regenerate leftover dirty `man/*.Rd` from current `R/` if they match
(ASCII). Align Getting started with `ef54db4` so `REML = FALSE` is not
described as rejected only on the fit path.

## Commands and outcomes

| Command | Result |
|---|---|
| `devtools::document()` | regenerated the same eight leftover Rd files; no extra `man/` or `NAMESPACE` delta |
| ASCII scan of those eight `man/*.Rd` | ASCII only |
| ASCII scan of the edited Getting started ML / converge lines | ASCII only (pre-existing em-dash and `h^2` on L73-74 converted) |
| `git diff --check` | clean |

`devtools::test()` / `devtools::check()` not run: generated help + one
vignette sentence; no `R/` change. Behaviour already pinned by
`test-reml-false-validate.R` at `ef54db4`.

## Claim boundary

- No `validation_status()` rows.
- No `public_covered_count` move.
- No LOOP edit.
- No push.
