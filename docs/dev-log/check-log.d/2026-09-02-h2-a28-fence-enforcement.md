# 2026-09-02 — A28 remainder: §H.3 discharged + fence enforcement

**Arc:** A28 remainder (after capability-id alias part1).
**Lane:** R (`hsquared`).
**Worktree:** `~/local-scratch/lanes/hsquared-h2-twin-20260901`
**Branch:** `claude/lane-h2-twin-20260901`. **Not pushed.**

## What closed

1. **Doc-38 §H.3 discharged by MV-1.** Ratification text now records that the
   in-suite comparator was promoted to full-unstructured (`sommer::mmer` +
   `vsr(..., Gtc = unsm(2))`), discharging the residual-structure gate decision
   for the 0.6 flip packet. (A26b hardens the Suggests failure mode.)

2. **`k ≥ 3` and `diagonal` fences enforced (option a), not merely documented.**
   - Parser: `cbind(y1,y2,y3)` still builds a 3-trait multivariate payload
     (parseable-and-fittable-but-experimental).
   - Control: `genetic_structure = "diagonal"` accepted; `lowrank` /
     `factor_analytic` abort with planned-not-implemented.
   - Claim surfaces: `validation_status()` claim_boundary and
     `formula_status()` `current_behavior` pin
     `scoped to k = 2 unstructured`, `k >= 3 … experimental`, and
     `"diagonal" stays experimental`.
   - Contract tests: `tests/testthat/test-multivariate-fence-contract.R`.

## Commands and outcomes

| Command | Result |
|---|---|
| `testthat::test_file("tests/testthat/test-multivariate-fence-contract.R")` | **PASS 4 / FAIL 0** |
| `testthat::test_file("tests/testthat/test-phase0-api.R")` | **PASS** (fence strings pinned) |

## Fence

- **No covered flip.** Multivariate stays **partial**; structured/diagonal stays
  experimental/partial.
- `public_covered_count` remains **5**.
- No push; no Totoro/DRAC; no G10; no Registrator; no version bump.
