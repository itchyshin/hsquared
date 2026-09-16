# 2026-09-02 -- Boole R3: REML = FALSE rejected on validate

**Lane:** R (`hsquared`). **Branch:** `claude/lane-h2-twin-20260901`.
**Worktree:** `~/local-scratch/lanes/hsquared-h2-twin-20260901`.
**Lens:** Boole (formula / API). **No covered flip.**
**No `validation_status()` row added** (G-AG-5 owner). `public_covered_count` stays 5.

## Goal

`hsquared(..., REML = FALSE, control = hs_control(engine = "validate"))`
must reject and name `REML = TRUE` as the live path. Same rule as the
default fit path. Internal spec builders stay able to label ML.

## Commands and outcomes

| Command | Result |
|---|---|
| `air format` on `R/conditions.R` `R/model-spec.R` `tests/testthat/test-reml-false-validate.R` | clean |
| ASCII scan of those three files | ASCII only |
| `devtools::load_all()` + `testthat::test_file("tests/testthat/test-reml-false-validate.R")` | **FAIL 0 / WARN 0 / SKIP 0 / PASS 11** |
| `testthat::test_file("tests/testthat/test-phase0-api.R")` | **FAIL 0 / WARN 0 / SKIP 0 / PASS 145** |
| `testthat::test_file("tests/testthat/test-unsupported-syntax-condition.R")` | **FAIL 0 / WARN 0 / SKIP 0 / PASS 25** |
| `testthat::test_file("tests/testthat/test-bridge-payload.R")` | **FAIL 0 / WARN 0 / SKIP 0 / PASS 38** |
| `testthat::test_file("tests/testthat/test-negative-control.R")` | **FAIL 0 / WARN 0 / SKIP 0 / PASS 25** |
| `testthat::test_file("tests/testthat/test-validation-fixtures.R")` | **FAIL 0 / WARN 0 / SKIP 12 / PASS 43** |

`devtools::document()` not run: no roxygen change. `devtools::check()`
not run: control/spec honesty only. No `man/*.Rd` touch (Grace leftover
dirt + Pat R1 holds `man/hsquared.Rd`).

## Claim boundary

- No `validation_status()` rows.
- No `public_covered_count` move.
- No auto-route.
- `engine = "julia"` supplied-variance exemptions unchanged.
- `R/hsquared.R` not edited (Pat R1 lease).
