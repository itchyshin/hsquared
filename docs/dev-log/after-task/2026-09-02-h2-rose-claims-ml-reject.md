# After-task -- Rose: leftover claims-register ML reject

**Date:** 2026-09-02
**Lane:** R (`claude/lane-h2-twin-20260901`)
**Worktree:** `~/local-scratch/lanes/hsquared-h2-twin-20260901`
**Active lenses:** Rose (systems auditor; implementing)
**Spawned subagents:** none
**Current lane:** R design-docs leftover from the developer-table
REML-caveat slice. Assigned continuation of this Claude-named branch.
**Checks:** `docs/dev-log/check-log.d/2026-09-02-h2-rose-claims-ml-reject.md`

## Goal

Align leftover "ML rejected on the fit path" wording in the public
claims register, capability-status, and NEWS with `ef54db4`:
`REML = FALSE` is rejected on the default fit and on
`engine = "validate"`. The covered claim is this REML estimator, not
ML. No covered flip. ASCII. Local commit only. No push. No MC.

## Files changed

- `docs/design/06-public-claims-register.md` -- two v0.1 caveat cells
  now name both public doors and say covered is this REML estimator,
  not ML
- `docs/design/capability-status.md` -- simple Gaussian animal model
  caveat matches that rule
- `NEWS.md` -- default-fit bullet matches that rule (em-dash dropped
  on the edited sentence)
- this report and the check-log shard

## Public-claim audit

No status word moved. `public_covered_count` stays **5**. No
`validation_status()` row. ML is still not implemented. Covered still
means this REML estimator.

**Verdict: clean-with-limitations.**

## Tests of the tests

Docs only. Behaviour already pinned by
`tests/testthat/test-reml-false-validate.R`.

## Coordination

Did not prepend the coordination board. Did not edit LOOP. Did not
edit `R/`. Stale July / genomic / metafounder branches still carry
the old "fit path" sentence; they are not a competing fix. Lease
`cursor:hsquared` held the edited paths.

## What did not go smoothly

Lane preflight flags this Claude-named branch as foreign. This is the
assigned leftover from Boole's developer-table slice (`65d3e4e`), not
a new claim of that branch.

## Known limitations

`docs/design/capability-status.md` still says "ML is rejected." on the
fit-entry-point row and "REML only (ML rejected)" on the AI-REML row.
Those do not say "fit path" and were left scoped out.
`06-public-claims-register.md` still names an "opt-in experimental
R-to-Julia fit path"; that is a route name, not the leftover ML
reject.

## Next actions

Owner push if wanted. No merge. No covered flip.
