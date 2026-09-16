# 2026-09-02 -- Boole: developer-table REML caveat

**Lane:** R (`hsquared`). **Branch:** `claude/lane-h2-twin-20260901`.
**Worktree:** `~/local-scratch/lanes/hsquared-h2-twin-20260901`.
**Lens:** Boole (formula / API). **No covered flip.**
**No `validation_status()` row added.** `public_covered_count` stays 5.
**No push.** No MC.

## Goal

Align the default-route developer-table caveat with `ef54db4` so
`REML = FALSE` is rejected on the default fit and on
`engine = "validate"`, not described as "ML is rejected on the fit
path".

## Commands and outcomes

| Command | Result |
|---|---|
| `air format` on `R/validation-status.R` `tests/testthat/test-phase0-api.R` | clean |
| Python ASCII scan of the four edited files | ASCII only |
| `rg` for `rejected on the fit path` in `R/validation-status.R` | no matches |
| R parse of default-route `claim_boundary` | names `REML = FALSE`, `REML = TRUE`, default fit, and `engine = "validate"`; says covered is this REML estimator, not ML |
| `validation_status()` nrow / default-row status | 21 rows; default route stays `covered` |
| `devtools::load_all()` + `testthat::test_file("tests/testthat/test-phase0-api.R")` | **FAIL 0 / WARN 0 / SKIP 0 / PASS 149** |
| `git diff --check` | clean |

`devtools::document()` not run: no roxygen change. `devtools::check()`
not run: developer-table caveat only. Behaviour already pinned by
`test-reml-false-validate.R` at `ef54db4`. No MC / Firefox.

## Claim boundary

- No `validation_status()` rows.
- No `public_covered_count` move.
- No LOOP edit.
- No push.
