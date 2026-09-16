# 2026-09-02 — Boole item 2 remainder: ?hs_control live targets + DESCRIPTION

**Lane:** R (`hsquared`). **Branch:** `claude/lane-h2-twin-20260901`.
**Worktree:** `~/local-scratch/lanes/hsquared-h2-twin-20260901`.
**Lens:** Boole (front-door docs). **No covered flip.**
**No `validation_status()` row added.** `public_covered_count` stays 5.
**Did not edit** `R/formula-status.R` (sibling slice).

## Goal

`?hs_control` must list every live `hs_validate_julia_target()` name,
including the covered opt-in routes. DESCRIPTION must not call
non-Gaussian models "planned".

## Commands and outcomes

| Command | Result |
|---|---|
| `air format` on `R/hs_control.R` and `tests/testthat/test-hs-control-targets.R` | clean |
| `devtools::document()` | regenerated `man/hs_control.Rd`; incidental ASCII Rd rewrites on other pages were reverted |
| `testthat::test_file("tests/testthat/test-hs-control-targets.R")` | FAIL 0 / PASS 26 |
| `testthat::test_file("tests/testthat/test-d41-experimental-honesty.R")` | FAIL 0 / PASS 34 |
| `testthat::test_file("tests/testthat/test-package.R")` | FAIL 0 / PASS 1 |
| `read.dcf("DESCRIPTION")` | 17 fields; Description ends with opt-in non-Gaussian + planned factor-analytic |
| `git diff --check` on the four owned paths | clean |

`devtools::check()` not run: documentation honesty only.

## Claim boundary

- No status word moved. Covered opt-in wording copies `formula_status()`:
  `two_effect`/`common_env()`, `direct_maternal`, `multi_effect`, and
  `random_regression` at k = 2 are covered at validation scale and not
  the default path.
- `relmat` / `precision` / `nongaussian` stay experimental opt-in.
- Factor-analytic remains planned.
