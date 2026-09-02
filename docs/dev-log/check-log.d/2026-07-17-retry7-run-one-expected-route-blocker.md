# Retry-7 D0F run-one blocker — `v3d_validate_attempt` omits `expected_route`

**Date:** 2026-07-17 · **Lane:** R twin (hsquared). Found during the Retry-7 D0F campaign
(executed by Claude, user-authorized). Banked negative; `public_covered_count` stays 5.

## Defect (bound tool — do NOT patch on the sealed `-c` root)

Every official `run-one` fit fails-closed:
```
v3d_run_one -> v3d_validate_attempt -> v3p_validate_results:
  argument "expected_route" is missing, with no default
```
- `tools/v07_genomic_recovery_v3.R:1162` (`v3d_validate_attempt`) calls
  `v3p_validate_results(attempt, manifest, manifest_columns, label, binding)` — **5 args**.
- `tools/v07_genomic_recovery_v3_preseal.R:1588` declares
  `v3p_validate_results(attempts, manifest, manifest_columns, label, binding, expected_route)` —
  **6 required; `expected_route` has no default.**

The route-binding repair `b8096e5` made `expected_route` required (fail-loud on wrong route) but
**missed this `run-one` attempt-validation call site.** The defect is in both `9f7ed27` (the sealed
`-c` bound head) and current HEAD `cb7391d` (bound tools byte-identical). It was never caught because
`v07_genomic_recovery_v3_synthetic_lifecycle.R` fabricates attempts and bypasses `run-one`, and the
zero-seed preflight + the D0F tail regression tests
(`test-v07-genomic-recovery-v3-recompute.R`, added 2026-07-17) target the adjudicator/recompute path,
not the fit-entry driver path.

## Fix (for a repaired-head successor — its own gate; NOT on the sealed `-c` root)

1. `v3d_validate_attempt` must pass `expected_route` to `v3p_validate_results` — the official public
   route (`ordinary_auto_genomic`) for a real fit. Confirm the exact source (literal vs a `binding`
   field / `PUBLIC_ROUTE`) against the repaired summary/adjudicator call sites.
2. **Close the blind spot**: add a testthat regression that drives `v3d_run_one` /
   `v3d_validate_attempt` on a synthetic marker panel (no official seed) so a driver↔preseal argument
   mismatch fails on the Mac, not on the live draw.
3. This is a preseal-bound tool change → it requires a **new preseal + fresh admission gate** under
   the repaired R head (the sealed `-c` root binds `r_driver_sha256`; changing the driver invalidates
   it). Do not edit `v3.R` on the `-c` root.

## Env note (Totoro, not a tool change)

`run-one`'s JuliaCall K/Q construction needs a **stable `TMPDIR`** (e.g.
`/home/snakagaw/hsq_work/jltmp`); R's ephemeral per-session `TMPDIR` breaks the Julia precompile
worker (`SystemError: opening file "/tmp/jl_*.ji"`). Export it for any live run.

## Root state

The sealed `-c/d0f` root is **pristine** — Julia preflight re-PASSes, hashes unchanged, no
`attempts/`/`packets/`. No official seed persistently spent. Local commit only (no push, per the
shared-branch race guard). Protected retry5 carryover untouched.
