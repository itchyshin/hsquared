# hsquared#379: GLLVM sparse incidence binary check

Date: 2026-11-12. Lane: R (bounded testing sweep, owner-approved 12 Nov 2026).

Active lenses: Ada, Shannon, Curie, Rose, Grace (perspectives). Spawned
subagents: none.

## Goal

Find decision-free pure-R bugs during a capped test sweep; land a minimal fix
with regression coverage via existing tests.

## Change

- `R/julia-bridge.R`: in `hs_validate_gllvm_optin_spec()`, replace
  `any(!Z %in% c(0, 1))` with `any(!(as.vector(Z) %in% c(0, 1)))` so validation
  works when `payload$Z` is the `dgCMatrix` from `hs_build_bridge_payload()`.

No API or default change. No new test file (`test-gllvm-optin.R`,
`test-coverage-hsquared-dispatch.R`).

## Checks

- `NOT_CRAN=true devtools::test(filter = "gllvm-optin|coverage-hsquared-dispatch")`:
  0 failures.
- Full `devtools::test()` (Julia absent): FAIL 0 | WARN 6 | SKIP 145 | PASS 5443
  on fix branch vs FAIL 2 on `main` for the same two GLLVM tests.
- `bash tools/preamble_cap.sh`: CAP OK.

## Public claims

No change. Genetic GLLVM stays partial; `public_covered_count` stays 7.

## Coordination

Issue #379 (filed by owner). Draft PR #378 → ready after CI on DoD commit.

## Limits

Live genetic GLLVM bridge test still skipped without Julia + HSquared.jl on PATH.
No `devtools::check()` on this host.

## Next actions

- Maintainer review/merge #378 when satisfied.
- Optional: Julia-host recheck of live `test-gllvm-optin.R:367` only.
