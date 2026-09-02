# 2026-09-02 -- Rose: leftover claims-register ML reject

**Lane:** R (`hsquared`). **Branch:** `claude/lane-h2-twin-20260901`.
**Worktree:** `~/local-scratch/lanes/hsquared-h2-twin-20260901`.
**Lens:** Rose (systems auditor). **No covered flip.**
**No `validation_status()` row added.** `public_covered_count` stays 5.
**No push.** No MC.

## Goal

Align leftover "rejected on the fit path" wording in
`docs/design/06-public-claims-register.md`,
`docs/design/capability-status.md`, and `NEWS.md` with `ef54db4` so
`REML = FALSE` is rejected on the default fit and on
`engine = "validate"`. Covered remains this REML estimator, not ML.

## Commands and outcomes

| Command | Result |
|---|---|
| Python ASCII scan of the four edited ML / validate sentences | ASCII only |
| `rg` for `rejected on the fit path` in those three files | no matches |
| `rg` for `public_covered_count` in capability-status / claims register | stays 5; no status word moved |
| `git diff --check` | clean |

`devtools::document()` / `devtools::test()` / `devtools::check()` not
run: three claim-surface sentences; no `R/` change. Behaviour already
pinned by `test-reml-false-validate.R` at `ef54db4`. No MC / Firefox.

## Claim boundary

- No `validation_status()` rows.
- No `public_covered_count` move.
- No LOOP edit.
- No push.
