# 2026-09-02 — A25a: cite banked C8 broader-DGP confirm on claim surfaces

**Arc:** A25a (compute-free register reconcile; follow-up to A28 inventory).
**Lane:** R (`hsquared`).
**Worktree:** `~/local-scratch/lanes/hsquared-h2-twin-20260901`
**Branch:** `claude/lane-h2-twin-20260901`. **Not pushed.**

## Problem

Twin C8 confirm evidence was banked in
`docs/dev-log/recovery-checkpoints/2026-07-10-coverage-recovery-results.md` but
absent from R claim surfaces; broader-recovery debt still read as if only W1
(5/8 at 50 seeds) existed, and MV-5 looked code-missing rather than
authorization-gated.

## Verified numbers (from banked checkpoints; no re-run)

| Field | Value |
|---|---|
| Job | `47925486` |
| Design | 16 cells × 500 seeds |
| Convergence | **500/500** every cell |
| Gate | **14/16 pass** |
| Failures | only `rg_090_rec1`, `rg_095_rec1` |
| Covered-scope control | `base_inside` PASSES |

## Changes

- `docs/design/capability-status.md` — multivariate row cites C8; MV-5 flagged
  **authorization-gated** (driver+doc40 committed, NOT RUN); MV-1
  `skip_if_not_installed("sommer")` silent-skip caveat; status stays **partial**.
- `docs/design/validation-debt-register.md` — same citations/flags.
- `docs/design/06-public-claims-register.md` — multivariate notes updated.
- `R/validation-status.R` + `tests/testthat/test-phase0-api.R` — claim_boundary
  cites C8 / MV-5 auth-gate / skip risk; pins updated.

## Commands and outcomes

| Command | Result |
|---|---|
| `devtools::load_all()` + `validation_status()` | multivariate status **partial**; claim contains `14/16 pass`, `authorization-gated`, `skip_if_not_installed` |
| `testthat::test_file("tests/testthat/test-phase0-api.R")` | **FAIL 0 / WARN 0 / SKIP 0 / PASS 121** |

## Fence

- No covered flip; R multivariate stays **partial**.
- `public_covered_count` remains **5**.
- No push; no Totoro/DRAC; no G10; no Registrator.
