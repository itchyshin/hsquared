# After-task -- Boole R3: reject REML = FALSE on validate

**Date:** 2026-09-02
**Lane:** R (`claude/lane-h2-twin-20260901`)
**Worktree:** `~/local-scratch/lanes/hsquared-h2-twin-20260901`
**Active lenses:** Boole (spawned reviewer; implementing)
**Spawned subagents:** none
**Checks:** `docs/dev-log/check-log.d/2026-09-02-h2-boole-reml-false-validate.md`

## Goal

`engine = "validate"` + `REML = FALSE` must not succeed and describe a
REML contract. One rule with the default fit path. Nearest path is
`REML = TRUE`. No covered flip.

## Files changed

- `R/conditions.R` -- `hs_abort_reml_false()` nearest-path message;
  public-door hook that reads the live `hsquared()` control
- `R/model-spec.R` -- `hs_validate_model_inputs()` calls that hook
- `tests/testthat/test-reml-false-validate.R` -- honesty pins
- this report and the check-log shard

## Accepted / rejected syntax

| User types | Behaviour | Nearest path |
|---|---|---|
| `hsquared(..., REML = TRUE, control = hs_control(engine = "validate"))` | accepted | live preview path |
| `hsquared(..., REML = FALSE, control = hs_control(engine = "validate"))` | rejected | `REML = TRUE` |
| `hsquared(..., REML = FALSE)` (default fit) | rejected | `REML = TRUE` |
| `model_spec(..., REML = FALSE)` / internal `hs_build_model_spec()` | still builds an ML-labelled spec | not the public door |
| `engine = "julia"` supplied-variance Henderson / metafounder / snp_blup | unchanged exemptions in `R/hsquared.R` | -- |

Files that must change together if the message is retouched:
`R/conditions.R`, `tests/testthat/test-reml-false-validate.R`, and the
existing fit-path pin in `tests/testthat/test-phase0-api.R`.

## Public-claim audit

No status word moved. `public_covered_count` stays **5**. No
`validation_status()` row. ML is still not implemented.

## Tests of the tests

Validate + `REML = FALSE` must be `hsquared_unsupported_syntax` and must
not contain `Validated the v0.1`. Internal builders and `model_spec()`
must still be able to label a spec `ML`.

## Coordination

Did not edit `R/hsquared.R` or `man/hsquared.Rd` (Pat R1 lease
`cursor:hsquared:pat-hsquared-frontdoor`). Grace ASCII lease had
expired; leftover dirty `man/*.Rd` left unstaged. Coordination board
not prepended (Pat holds it). Getting started still says "rejected on
the fit path" (`vignettes/hsquared.Rmd` held by `88158`).

The default-fit abort in `R/hsquared.R` is now reached after this
earlier hook; the user-visible fit message is the shared nearest path.

## What did not go smoothly

R1 claimed `R/hsquared.R` after this dispatch. The reject lives in
control/spec validation so the front-door help rewrite can finish.

## Known limitations

`engine = "julia"` ML rejection copy is still the older fit-path
sentence. Getting started still names only the fit path. Neither is
this lease.

## Next actions

R4 (formula-grammar Error rule) if still open. Do not add covered rows
here. After R1 releases `R/hsquared.R`, the dead fit-branch abort can
call `hs_abort_reml_false()` directly.
