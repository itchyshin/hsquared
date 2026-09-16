# After-task — Boole item 1: formula_status print header honesty

**Date:** 2026-09-02
**Lane:** R (`claude/lane-h2-twin-20260901`)
**Worktree:** `~/local-scratch/lanes/hsquared-h2-twin-20260901`
**Active lenses:** Boole (spawned reviewer; implementing)
**Spawned subagents:** none
**Checks:** `docs/dev-log/check-log.d/2026-09-02-h2-boole-formula-status-print.md`

## Goal

Stop the `formula_status()` print header lagging the live grammar table.
Quiet/useful print per Pat. No covered flip. No `validation_status()` rows.

## Files changed

- `R/formula-status.R` — length-guard on the six helpers; header derived from
  the printed rows; table shows `term` / `syntax_status` / `fitting_status`
- `tests/testthat/test-phase0-api.R` — length-guard + derived-header tests
- `man/formula_status.Rd` — via `document()`
- this report and the check-log shard

## Public-claim audit

No status word moved. `public_covered_count` stays **5**. G-AG-5 untouched.
`$current_behavior` fences are pointed at, not rewritten.

## Tests of the tests

A one-row RR subset print must not claim `cbind()` as default. Planned-only
subset print must not claim default or opt-in fits.

## Coordination

Did not edit `R/validation-status.R`, `R/zzz.R`, or `R/hs_control.R`. A
parallel slice already had uncommitted `hs_control` / DESCRIPTION / Rd work
in this worktree; those files were left unstaged.

## What did not go smoothly

`devtools::document()` also regenerated Rd for the parallel `hs_control`
slice. Only `man/formula_status.Rd` is in this commit.

## Known limitations

`validation_status()` still omits RR k = 2 and `direct_maternal` rows
(G-AG-5 owner). Attach still has to name those two routes.

## Next actions

Item 2+ of `~/local-scratch/h2-boole-emmy-ultracode-2026-09-02.md` if still
assigned. Do not add covered rows here.
