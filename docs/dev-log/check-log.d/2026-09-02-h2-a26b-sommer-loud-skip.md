# 2026-09-02 — A26b: MV-1 sommer Suggests fail loudly under NOT_CRAN

**Arc:** A26b (MV-1 silent-skip harden).
**Lane:** R (`hsquared`).
**Worktree:** `~/local-scratch/lanes/hsquared-h2-twin-20260901`
**Branch:** `claude/lane-h2-twin-20260901`. **Not pushed.**

## Problem measured

MV-1 (`test-multivariate.R` full-unstructured `sommer::mmer` leg) already had
`skip_on_cran()`, but then `skip_if_not_installed("sommer")`. Under
`NOT_CRAN=true` (CI / maintainer), a Suggests install failure became a **silent
skip**, not a red build — wrong failure mode for a flip-gate comparator.

## Strategy chosen

**Loud on maintainer path; quiet on CRAN.**

- New helper `hs_require_suggests(pkg, gate)` in
  `tests/testthat/helper-suggests-require.R`.
- If Suggests present → continue.
- If missing and `NOT_CRAN=true` → **`stop()`** naming the gate.
- If missing otherwise → `skip_if_not_installed()` (CRAN-safe).
- Applied to MV-1 and MV-1b (`sommer` + `nadiv`).
- Claim surfaces updated: silent-skip caveat → `hs_require_suggests` wording.

## Commands and outcomes

| Command | Result |
|---|---|
| `testthat::test_file("tests/testthat/test-hs-require-suggests.R")` | **PASS 3 / FAIL 0** (loud fail + quiet skip + installed no-op) |
| `testthat::test_file("tests/testthat/test-phase0-api.R")` | **PASS** (claim_boundary pins `hs_require_suggests`) |
| `testthat::test_file("tests/testthat/test-multivariate.R")` with `NOT_CRAN=true` | **FAIL 0**; 2 expected live-Julia skips; sommer legs exercised |

## Fence

- No covered flip; R multivariate stays **partial**.
- `public_covered_count` remains **5**.
- No push; no Totoro/DRAC; no G10; no Registrator; no version bump.
