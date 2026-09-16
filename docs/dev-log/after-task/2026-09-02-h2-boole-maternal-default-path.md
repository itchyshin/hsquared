# After-task — Boole item 6: maternal_genetic default-path wording

**Date:** 2026-09-02
**Lane:** R (`claude/lane-h2-twin-20260901`)
**Worktree:** `~/local-scratch/lanes/hsquared-h2-twin-20260901`
**Active lenses:** Boole (spawned reviewer; implementing)
**Spawned subagents:** none
**Checks:** `docs/dev-log/check-log.d/2026-09-02-h2-boole-maternal-default-path.md`

## Goal

Point the default-path `maternal_genetic()` abort at the covered
`direct_maternal` sibling, not only experimental `two_effect`. Add
nearest-path text to reserved-marker errors without touching the
`common_env()` paste owned by `672368c`.

## Files changed

- `R/hsquared.R` — default-path maternal abort; wrong-target note + covered next call
- `R/julia-bridge.R` — wording helpers; `hs_second_effect_target()` unchanged
- `R/model-spec.R` — `hs_planned_marker_nearest_path()`
- `tests/testthat/test-maternal.R`
- `tests/testthat/test-formula-animal.R`
- this report and the check-log shard

## Public-claim audit

No status word moved. No auto-route. `public_covered_count` stays **5**.
No `validation_status()` rows.

## Tests of the tests

Covered-first is pinned with `regexpr` order. Routing map still returns
`two_effect`. `common_env()` still prints the `672368c` paste helper.

## Coordination

Did not edit `R/conditions.R` or `tests/testthat/test-common-env.R`.

## What did not go smoothly

The live worktree moved under this slice (`672368c` landed the shared
paste helper, including a maternal extra that named `direct_maternal`
second). This slice took default-path maternal copy out of that helper
so covered is first.

## Known limitations

Default-path maternal copy is a control snippet, not a full pasteable
`hsquared()` call. The wrong-target path still pastes a full call.

## Next actions

None for this wording slice.
