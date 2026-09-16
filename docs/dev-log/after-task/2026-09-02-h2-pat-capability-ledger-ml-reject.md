# After-task -- Pat: capability-ledger ML reject wording

**Date:** 2026-09-02
**Lane:** R (`claude/lane-h2-twin-20260901`)
**Worktree:** `~/local-scratch/lanes/hsquared-h2-twin-20260901`
**Active lenses:** Pat (applied user tester; implementing)
**Spawned subagents:** none
**Current lane:** R docs hygiene (leftover from article ML-reject). Assigned
continuation of this Claude-named branch; no other live write on this
include.
**Checks:** `docs/dev-log/check-log.d/2026-09-02-h2-pat-capability-ledger-ml-reject.md`

## Goal

Align `vignettes/articles/includes/capability-ledger-summary.md` with
Getting started / `ef54db4`: `REML = FALSE` is rejected on validate as
well as on the default fit. Keep the v0.1 card's `covered` meaning as
the REML estimator, not a vague "ML path". Local commit only. No push.
No covered flip.

## Files changed

- `tools/write-capability-ledger-summary.R` -- default-path scope string
  now names `REML = FALSE` / `REML = TRUE` for both the default fit and
  `engine = "validate"`, and says the covered claim is this REML
  estimator, not ML
- `vignettes/articles/includes/capability-ledger-summary.md` -- same
  sentence on the v0.1 animal-model card (kept in lockstep with the
  generator; full `Rscript` regen not run)
- this report and the check-log shard

## Public-claim audit

No status word moved. `public_covered_count` stays **5**. No
`validation_status()` row. ML is still not implemented. The card still
says the default route is covered as REML only.

## Tests of the tests

Docs / generated include only. Behaviour already pinned by
`tests/testthat/test-reml-false-validate.R`.

## Coordination

Did not touch LOOP. Did not prepend the coordination board. Did not
edit `R/`. Lease `cursor:hsquared-h2-twin-20260901:88158` held these
paths for this slice.

## What did not go smoothly

Lane preflight flags this Claude-named branch as foreign. This is the
assigned leftover from the article ML-reject slice (`7e66f29`), not a
new claim of that branch.

## Known limitations

`R/validation-status.R` still says "ML is rejected on the fit path" on
the default-route caveat. Developer evidence table; left scoped out.
A pre-existing em-dash remains in the include header ("covered routes
-- two covered routes"); not on the edited sentence.

## Next actions

Owner push if wanted. No merge. No covered flip.
