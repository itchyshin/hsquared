# 2026-09-02 — DP-10 loud-failure guard (prerequisite only)

**Arc:** DP-10 Tier-1 prerequisite from `~/local-scratch/h2-dp10-tier1-ci-plan.md`.
**Lane:** R (`hsquared`).
**Branch:** `claude/lane-h2-twin-20260901`. **Not pushed.**

## What landed

- `hs_require_bridge()` in `tests/testthat/helper-julia-skip.R`
  (mirrors A26b `hs_require_suggests`).
- `hs_a26_skip_bridge()` now calls `hs_require_bridge("A26 parity")`.
- Unit tests `tests/testthat/test-hs-require-bridge.R` (positive, loud fail, quiet skip).
- Optional `workflow_dispatch`-only `.github/workflows/bridge-parity-tier1.yaml`
  with `HSQUARED_REQUIRE_BRIDGE=true` and zero-skip assertion floor `>= 44`.
- Stub `bridge-parity-tier1.stub.yaml` **untouched** (`if: false` stays).
- **Not** added to `pull_request` / `push`; **not** required status check.
- Owner DP-10 B-vs-C still open; criterion 8 still NOT MET until owner decides
  and a cited green run exists (or Option C rewords the criterion).

## Commands and outcomes

| Command | Result |
|---|---|
| `testthat::test_file("tests/testthat/test-hs-require-bridge.R")` with live twin project | **PASS 3 / FAIL 0 / SKIP 0** |
| Forced missing `Project.toml` + `HSQUARED_REQUIRE_BRIDGE=false` | **skip** (quiet) |
| Forced missing `Project.toml` + `HSQUARED_REQUIRE_BRIDGE=true` | **error** containing `HSQUARED_REQUIRE_BRIDGE=true was set` |
| Live bridge + require true/false | both return `TRUE` |

Bridge via `HSQUARED_JULIA_PROJECT` → Julia campaign worktree. No Totoro/DRAC.

## Fence

No covered flip · `public_covered_count` **5** · no push · stub not flipped ·
Tier-1 not always-on · criterion 8 still unmet pending owner DP-10.
