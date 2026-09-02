# After-task -- Pat: Getting started REML rule + leftover ASCII Rd

**Date:** 2026-09-02
**Lane:** R (`claude/lane-h2-twin-20260901`)
**Worktree:** `~/local-scratch/lanes/hsquared-h2-twin-20260901`
**Active lenses:** Pat (applied user tester; implementing)
**Spawned subagents:** none
**Current lane:** R docs hygiene (Block 1 leftover). Assigned continuation
of this Claude-named branch; no other live write on these paths.
**Checks:** `docs/dev-log/check-log.d/2026-09-02-h2-pat-getting-started-reml.md`

## Goal

Fold leftover `document()` ASCII `man/*.Rd` if they match current `R/`.
Align Getting started with `ef54db4`: `REML = FALSE` is rejected on
validate as well as on the default fit. Local commit only. No push.
No covered flip. Leave LOOP alone.

## Files changed

- `vignettes/hsquared.Rmd` -- ML reject names `REML = TRUE` for both
  the default fit and `engine = "validate"`; nearby em-dash / `h^2`
  made ASCII
- eight leftover `man/*.Rd` regenerated from current roxygen (ASCII
  `--`, `h^2`, `chi^2`, `beta`, `sigma`)
- this report and the check-log shard

## Public-claim audit

No status word moved. `public_covered_count` stays **5**. No
`validation_status()` row. ML is still not implemented.

## Tests of the tests

Docs / generated help only. Behaviour already pinned by
`tests/testthat/test-reml-false-validate.R`.

## Coordination

Did not touch LOOP (absent on this worktree). Did not prepend the
coordination board. Did not edit `R/`. Stale July branch
`codex/2026-07-13-v07-performance-localization` still has the old
Getting started "fit path" sentence; it is not a competing fix.

## What did not go smoothly

`cursor:hsquared:88158` had previously held `vignettes/hsquared`. This
is the assigned leftover from Melissa's DoD verify, not a new slice.

## Known limitations

`vignettes/articles/fitting-models.Rmd`, `model-status.Rmd`, and
`validation-evidence.Rmd` still say "rejected on the fit path".
Not first-touch Getting started; left for a later polish.

## Next actions

Owner push if wanted. No merge. No covered flip.
