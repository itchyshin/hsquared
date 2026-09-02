# After-task -- Boole R2: maternal parser pastes the next call

**Date:** 2026-09-02
**Lane:** R (`claude/lane-h2-twin-20260901`)
**Worktree:** `~/local-scratch/lanes/hsquared-h2-twin-20260901`
**Active lenses:** Boole (spawned reviewer; implementing)
**Spawned subagents:** none
**Checks:** `docs/dev-log/check-log.d/2026-09-02-h2-boole-maternal-parser-next-call.md`

## Goal

`maternal_genetic()` parser stops that fire before the default-path abort
must name the data requirement and paste the covered
`target = "direct_maternal"` call first, experimental `two_effect` second.
Same order as `9ba841d`. No auto-route. No covered flip.

## Files changed

- `R/model-spec.R` -- extra-args and missing-column stops only; shared
  guidance helper reuses `hs_maternal_genetic_default_path_message()`
- `tests/testthat/test-maternal.R` -- message-content pins
- this report and the check-log shard

## Public-claim audit

No status word moved. No auto-route. `public_covered_count` stays **5**.
No `validation_status()` row (G-AG-5 untouched). Extra `pedigree=` is
still rejected; dams are still not taken from the pedigree table.

## Tests of the tests

Extra `pedigree=` must fail before the missing-column stop. Both
messages require `direct_maternal` before `two_effect`, plus the data
requirement (column of `data`, mothers of records, IDs in the animal
pedigree). `common_env()` extra-args copy from `672368c` is unchanged.

## Coordination

Did not edit `R/conditions.R`, `R/hsquared.R`, `R/formula-status.R`,
`R/hs_control.R`, or `man/*.Rd`. Sibling attach/help dirt left unstaged.
Coordination board not prepended (collision-prone; Shannon).

## What did not go smoothly

The worktree already had uncommitted `man/*.Rd` and attach-message work
from parallel R1 / Pat slices. Those paths were left alone.

## Known limitations

Parser paste is the `9ba841d` control snippet, not a full `hsquared()`
call. The user's illegal `pedigree=` formula is not replayed. Design
doc `02-formula-grammar.md` still lists
`maternal_genetic(1 | dam, pedigree = ped)` as later grammar; this
slice does not accept that form.

## Next actions

R3 (`REML = FALSE` on validate) and R4 (formula-grammar Error rule)
remain on the catch-up list. Do not add covered rows here.
