# After-task -- Pat: remaining vignette ML reject wording

**Date:** 2026-09-02
**Lane:** R (`claude/lane-h2-twin-20260901`)
**Worktree:** `~/local-scratch/lanes/hsquared-h2-twin-20260901`
**Active lenses:** Pat (applied user tester; implementing)
**Spawned subagents:** none
**Current lane:** R docs hygiene (leftover from Getting started). Assigned
continuation of this Claude-named branch; no other live write on these
article paths.
**Checks:** `docs/dev-log/check-log.d/2026-09-02-h2-pat-vignette-ml-reject.md`

## Goal

Align the three leftover articles with `ef54db4` / Getting started:
`REML = FALSE` is rejected on validate as well as on the default fit.
Local commit only. No push. No covered flip.

## Files changed

- `vignettes/articles/fitting-models.Rmd` -- ML reject names `REML = TRUE`
  for both the default fit and `engine = "validate"`
- `vignettes/articles/model-status.Rmd` -- same rule in the default-path
  limits list and in "Not implemented yet"
- `vignettes/articles/validation-evidence.Rmd` -- honest-boundaries REML
  bullet matches Getting started
- this report and the check-log shard

## Public-claim audit

No status word moved. `public_covered_count` stays **5**. No
`validation_status()` row. ML is still not implemented.

## Tests of the tests

Docs only. Behaviour already pinned by
`tests/testthat/test-reml-false-validate.R`.

## Coordination

Did not touch LOOP. Did not prepend the coordination board. Did not
edit `R/`. Stale July / metafounder / MCMCglmm branches still touch
`model-status.Rmd` on other sentences; they are not a competing ML-reject
fix. Lease `cursor:hsquared:88158` holds other paths
(`vignettes/hsquared`, extractors); this slice used the three articles.

## What did not go smoothly

Lane preflight flags this Claude-named branch as foreign. This is the
assigned leftover from the Getting started slice (`9ee0ca7`), not a
new claim of that branch.

## Known limitations

`vignettes/articles/includes/capability-ledger-summary.md` still says
"ML is rejected on this path" on the v0.1 animal-model card. That "path"
is the covered estimator, not fit-versus-validate. Left scoped out.

## Next actions

Owner push if wanted. No merge. No covered flip.
