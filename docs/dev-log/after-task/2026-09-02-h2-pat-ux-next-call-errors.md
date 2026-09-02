# After-task — Pat UX item 4: errors that print the next call

**Date:** 2026-09-02
**Lane:** R (`claude/lane-h2-twin-20260901`)
**Worktree:** `~/local-scratch/lanes/hsquared-h2-twin-20260901`
**Active lenses:** Boole (spawned reviewer; implementing)
**Spawned subagents:** none
**Checks:** `docs/dev-log/check-log.d/2026-09-02-h2-pat-ux-next-call-errors.md`

## Goal

Make the natural-formula abort paste the next working call, and warn once
on default-path `cbind()` that multivariate is experimental.

## Files changed

- `R/conditions.R` — next-call formatter, route notes, cbind warn-once
- `R/hsquared.R` — default-path aborts + default-path cbind warning
- `tests/testthat/test-common-env.R`
- `tests/testthat/test-maternal.R`
- `tests/testthat/test-repeatability.R`
- `tests/testthat/test-random-regression.R`
- `tests/testthat/test-multivariate.R`
- this report and the check-log shard

## Public-claim audit

No status word moved. `public_covered_count` stays **5**. Multivariate stays
`partial`. The new text restates already-documented coverage: common-env
two-effect covered at validation scale; repeatability experimental;
maternal `two_effect` experimental and `direct_maternal` covered as a
Willham triple; RR covered at k = 2.

## Tests of the tests

Existing genomic / relmat / single-step default-path tests still require
the old "experimental and opt-in" wording. Those routes were not given
the next-call abort.

## Coordination

Lease: `R/hsquared.R`, `R/conditions.R`, `tests/testthat/` message content.
README left to the sibling slice. Coordination board not edited (shared
file; sibling UX items 1 and 3 already landed on this branch).

## What did not go smoothly

`air format` on whole test files rewrapped unrelated fixtures. Reverted
and re-applied only the message assertions.

## Known limitations

Warn-once is session-scoped in a package env; tests reset it. The warning
fires only when the default path actually reaches the multivariate fitter
(Julia available). `engine = "validate"` does not warn.

## Next actions

Pat UX item 5 (first-screen hiding) if still assigned. Do not auto-route
second effects.
