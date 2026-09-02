# 2026-09-02 — Pat leftover: shorten ?hsquared front door

**Lane:** R (`hsquared`). **Branch:** `claude/lane-h2-twin-20260901`.
**Worktree:** `~/local-scratch/lanes/hsquared-h2-twin-20260901`.
**Lens:** Pat (applied-user first screen). **No covered flip.**
**No `validation_status()` row added.** `public_covered_count` stays 5.

## Goal

`?hsquared` opened as a genomic / Laplace / Willham audit. After Grace
finished the ASCII sweep (`cd13ac9`) the leftover lease was stale
(session ended; Auto-review had blocked its `--release`). Shorten the
roxygen to the live animal-model path plus the limits link.

## Commands and outcomes

| Command | Result |
|---|---|
| `LANE_ID='cursor:hsquared:grace-ascii-141' lane_lease.sh --release` | released (holder gone) |
| `devtools::document()` | wrote `man/hsquared.Rd` only |
| `air format R/hsquared.R tests/testthat/test-hsquared-help-frontdoor.R` | formatted |
| `tools::showNonASCIIfile` on those two files | CLEAN |
| `devtools::test(filter = "hsquared-help-frontdoor")` | **FAIL 0 / WARN 0 / SKIP 0 / PASS 12** |
| `devtools::test(filter = "package-help-honesty\|hsquared-help-frontdoor\|d41-experimental-honesty")` | **FAIL 0 / WARN 0 / SKIP 0 / PASS 57** |

Full `devtools::test()` / `devtools::check()` not run: help text plus
one front-door assertion. Sibling dirty `man/*.Rd` left unstaged.

## Claim boundary

- Default path is the univariate Gaussian animal model.
- Report list is the limits article, not `validation_status()`.
- Family line names opt-in `poisson()` / `binomial()` without promoting
  them. No genomic-ratio, VanRaden, Laplace, or Willham copy on this
  page.
- No capability, validation, or `public_covered_count` edit.
