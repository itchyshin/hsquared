# 2026-09-02 — Boole item 1: formula_status() print header from the table

**Lane:** R (`hsquared`). **Branch:** `claude/lane-h2-twin-20260901`.
**Worktree:** `~/local-scratch/lanes/hsquared-h2-twin-20260901`.
**Lens:** Boole (formula / print honesty). **No covered flip.**
**No `validation_status()` row added** (G-AG-5 owner). `public_covered_count` stays 5.

## Goal

`print.hs_formula_status` must not headline a stale subset of the grammar.
Header is derived from the printed rows. Quiet/useful per Pat: no
`$current_behavior` dump.

## Commands and outcomes

| Command | Result |
|---|---|
| `air format` on `R/formula-status.R` `tests/testthat/test-phase0-api.R` | clean |
| `devtools::document()` | wrote `man/formula_status.Rd`; other Rd regenerations from a parallel `hs_control` slice were left unstaged |
| `testthat::test_file("tests/testthat/test-phase0-api.R")` | **FAIL 0 / WARN 0 / SKIP 0 / PASS 145** |

`devtools::check()` not run: print/header honesty only.

## Claim boundary

- No `validation_status()` rows.
- No `public_covered_count` move.
- Fitting strings and `$current_behavior` fences unchanged.
- Header lists default `animal(); cbind()` and opt-in names from this table
  (including `animal(rr())`, `single_step()`, `metafounder()`, `relmat()`,
  `precision()`, `(1 | group)`).

## Test of the tests

Length-guard compares the six helper vectors. Header-derivation test requires
RR / single-step / metafounder / relmat / precision in the full print, and
requires a one-row RR print to omit `cbind()` / `default:`.
