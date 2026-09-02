# 2026-09-02 — Boole item 6: maternal_genetic default-path names covered sibling

**Lane:** R (`hsquared`). **Branch:** `claude/lane-h2-twin-20260901`.
**Worktree:** `~/local-scratch/lanes/hsquared-h2-twin-20260901`.
**Lens:** Boole (formula / error wording). **No covered flip.**
**No `validation_status()` row added.** `public_covered_count` stays 5.
**No auto-routing** of `maternal_genetic()` on `engine = "fit"`.

## Goal

Default-path `animal() + maternal_genetic()` must point at the covered
`direct_maternal` sibling first, then name experimental `two_effect`.
Reserved-marker errors name a nearest live path. `common_env()` paste
copy from `672368c` is left unchanged.

## Commands and outcomes

| Command | Result |
|---|---|
| `air format` on `R/hsquared.R` `R/model-spec.R` `tests/testthat/test-maternal.R` `tests/testthat/test-formula-animal.R` | clean |
| `devtools::load_all()` + `testthat::test_file("tests/testthat/test-maternal.R")` | FAIL 0 / SKIP 1 (live Julia) / PASS 31 |
| `testthat::test_file("tests/testthat/test-formula-animal.R")` | FAIL 0 / SKIP 2 / PASS 96 |
| `testthat::test_file("tests/testthat/test-engine-setup-and-honesty.R")` | FAIL 0 / PASS 18 |
| `testthat::test_file("tests/testthat/test-direct-maternal.R")` | FAIL 0 / SKIP 1 / PASS 67 |

`devtools::document()` not run: no exported roxygen change.
`devtools::check()` not run: error-string wording only.

## Claim boundary

- `hs_second_effect_target("maternal_genetic")` still returns `"two_effect"`.
- Covered vs experimental status words match `formula_status()`: correlated
  2x2 G / Willham triple is covered; independent maternal stays experimental.
- `common_env()` still uses the `672368c` paste helper.

## Test of the tests

Default-path assertions require `direct_maternal` *before* `two_effect`,
plus `neither is auto-routed`. Wrong-target path still matches
`needs target = "two_effect"` and now also names covered vs experimental.
Planned-marker tests keep the first-sentence pin and add nearest-path pins.
