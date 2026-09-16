# 2026-09-02 -- Boole R2: maternal parser pastes covered next call

**Lane:** R (`hsquared`). **Branch:** `claude/lane-h2-twin-20260901`.
**Worktree:** `~/local-scratch/lanes/hsquared-h2-twin-20260901`.
**Lens:** Boole (formula / error wording). **No covered flip.**
**No `validation_status()` row added.** `public_covered_count` stays 5.
**No auto-routing** of `maternal_genetic()` on `engine = "fit"`.

## Goal

Extra `pedigree=` and missing grouping-column stops on
`maternal_genetic()` must name the data requirement and paste
`target = "direct_maternal"` first, then experimental `two_effect`.
`common_env()` copy from `672368c` is left unchanged.

## Commands and outcomes

| Command | Result |
|---|---|
| `air format` on `R/model-spec.R` `tests/testthat/test-maternal.R` | clean |
| `devtools::load_all()` + `testthat::test_file("tests/testthat/test-maternal.R")` | FAIL 0 / WARN 0 / SKIP 1 (live Julia) / PASS 58 |
| `testthat::test_file("tests/testthat/test-common-env.R")` | FAIL 0 / SKIP 1 / PASS 48 |
| `testthat::test_file("tests/testthat/test-formula-animal.R")` | FAIL 0 / SKIP 2 / PASS 96 |
| `git diff --check` on the two code files | clean |

`devtools::document()` not run: no exported roxygen change.
`devtools::check()` not run: error-string wording only.

## Claim boundary

- Extra `pedigree=` still rejected (unsupported syntax class).
- Missing `dam` still a plain data-validation stop.
- Dams are still not taken from the pedigree table.
- `hs_second_effect_target("maternal_genetic")` still returns `"two_effect"`.
- Covered vs experimental status words match the `9ba841d` default-path helper.

## Test of the tests

Extra-args assertions require the missing-column sentence to be absent.
Missing-column assertions require the extra-args sentence to be absent.
Both require `direct_maternal` before `two_effect` and the data-requirement
phrases (column of `data`, mothers of the records, animal pedigree).
