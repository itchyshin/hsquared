# After-task -- Boole: developer-table REML caveat

**Date:** 2026-09-02
**Lane:** R (`claude/lane-h2-twin-20260901`)
**Worktree:** `~/local-scratch/lanes/hsquared-h2-twin-20260901`
**Active lenses:** Boole (formula / API; implementing)
**Spawned subagents:** none
**Current lane:** R developer-table leftover from the capability-ledger
ML-reject slice. Assigned continuation of this Claude-named branch.
**Checks:** `docs/dev-log/check-log.d/2026-09-02-h2-boole-validation-status-reml-caveat.md`

## Goal

Align the default-route `claim_boundary` in `R/validation-status.R` with
`ef54db4`: `REML = FALSE` is rejected on the default fit and on
`engine = "validate"`. Keep developer-table honesty. No
`validation_status()` row. No covered flip. ASCII. Local commit only.
No push. No MC.

## Files changed

- `R/validation-status.R` -- default-route caveat now names
  `REML = FALSE` / `REML = TRUE` for both public doors and says the
  covered claim is this REML estimator, not ML
- `tests/testthat/test-phase0-api.R` -- honesty pin on that caveat
- this report and the check-log shard

## Accepted / rejected syntax

| User types | Behaviour | Nearest path |
|---|---|---|
| `hsquared(..., REML = TRUE)` | accepted | default fit |
| `hsquared(..., REML = TRUE, control = hs_control(engine = "validate"))` | accepted | live preview path |
| `hsquared(..., REML = FALSE)` | rejected | `REML = TRUE` |
| `hsquared(..., REML = FALSE, control = hs_control(engine = "validate"))` | rejected | `REML = TRUE` |
| `model_spec(..., REML = FALSE)` / internal `hs_build_model_spec()` | still builds an ML-labelled spec | not the public door |

Files that must change together if this caveat is retouched:
`R/validation-status.R` and the pin in
`tests/testthat/test-phase0-api.R`. The public-door abort remains
`R/conditions.R` / `tests/testthat/test-reml-false-validate.R`.

## Public-claim audit

No status word moved. `public_covered_count` stays **5**. No
`validation_status()` row added. Row count stays 21. ML is still not
implemented. The table remains a developer evidence table.

## Tests of the tests

The default-route row must stay `covered`, must name `REML = FALSE`,
the default fit, and `engine = "validate"`, and must not say
"rejected on the fit path".

## Coordination

Did not prepend the coordination board. Did not edit LOOP. Did not
touch `docs/design/capability-status.md` or
`docs/design/06-public-claims-register.md`. Lease
`cursor:hsquared-h2-twin-20260901` held the edited paths.

## What did not go smoothly

Lane preflight flags this Claude-named branch as foreign. This is the
assigned leftover from Pat's capability-ledger ML-reject slice
(`503292e`), not a new claim of that branch. Older
`claude/fix-validation-status-non-ascii` still has the old "fit path"
sentence; it is not a competing fix.

## Known limitations

`docs/design/06-public-claims-register.md`,
`docs/design/capability-status.md`, and `NEWS.md` still say
"rejected on the fit path". Not this developer-table slice.

## Next actions

Owner push if wanted. No merge. No covered flip.
