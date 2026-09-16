# After-task — Boole item 2 remainder: front-door `?hs_control` + DESCRIPTION

**Date:** 2026-09-02
**Lane:** R (`claude/lane-h2-twin-20260901`)
**Worktree:** `~/local-scratch/lanes/hsquared-h2-twin-20260901`
**Active lenses:** Boole (implementing)
**Spawned subagents:** none
**Checks:** `docs/dev-log/check-log.d/2026-09-02-h2-boole-hs-control-targets.md`

## Goal

Close the remaining Boole item 2 front-door honesty on files this
slice owns: `?hs_control` must list live targets including covered
opt-in routes; DESCRIPTION must not call non-Gaussian models planned.

## Files changed

- `R/hs_control.R` — live target list + covered opt-in notes +
  `multi_effect` / `direct_maternal` / `random_regression` /
  `relmat` / `precision` paragraphs
- `man/hs_control.Rd` — via `devtools::document()`
- `DESCRIPTION` — non-Gaussian is opt-in experimental; factor-analytic
  remains planned
- `tests/testthat/test-hs-control-targets.R` — pins the Rd list and
  the DESCRIPTION sentence
- this report and the check-log shard

## Public-claim audit

No status word moved. No auto-route. `public_covered_count` stays **5**.
No `validation_status()` rows. Covered-at-validation-scale wording
matches `formula_status()`.

## Tests of the tests

The new Rd test requires every `hs_validate_julia_target()` name,
including `random_regression`, `direct_maternal`, `multi_effect`,
`relmat`, and `precision`. DESCRIPTION must contain "non-Gaussian"
and must not contain "non-Gaussian models are planned".

## Coordination

Did not edit `R/formula-status.R` (sibling). Reverted incidental
`document()` ASCII rewrites on other `man/*.Rd` pages so this slice
does not take `validation_status.Rd` / `hsquared.Rd`. Coordination
board not edited (shared file).

## What did not go smoothly

`devtools::document()` also rewrote ten other Rd files (ASCII
punctuation from earlier source commits). Those were reverted.

## Known limitations

`?hsquared` / `?animal` family-and-return copy is still item 2
remainder if another slice has not taken it. `R/hsquared-package.R`
already called non-Gaussian opt-in; only DESCRIPTION was stale.

## Next actions

None for this front-door pair. Rose can read the DESCRIPTION
one-liner; no promotion is implied.
