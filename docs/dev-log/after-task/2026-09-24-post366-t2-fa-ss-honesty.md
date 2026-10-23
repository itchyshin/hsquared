# After-task: Post-#366 T2 FA / ordinary single-step honesty

**Lane:** `cursor/post366-t2-fa-ss-honesty` @ `~/local-scratch/lanes/hsquared-post366-t2`  
**Date:** 2026-09-24  
**Lenses:** Ada, Shannon, Boole, Hopper, Rose (perspective)  
**Spawned subagents:** none  
**Current lane:** R

## What landed

Honesty-only close of silent 0.8.0 pins on live FA/SS claim surfaces after
experimental **0.9.0** was already on `DESCRIPTION`. Engine `V4-FA` /
`V2-SSHINV` covered remains ≠ R-public. Ordinary/default `single_step()` stays
held; FA/`lowrank` stay named planned rejects.

## Files

- `docs/design/capability-status.md` — T2 banner; FA/SS rows pin **0.9.0**
- `docs/design/06-public-claims-register.md` — SS construction pin **0.9.0**
- `R/conditions.R` — default-path + wrong-target SS notes name `V2-SSHINV` /
  ordinary hold / count 7
- `R/hsquared.R` — wire SS wrong-target note
- `R/julia-bridge.R` — `lowrank` reject pins count 7
- `tests/testthat/test-fa-planned-surface.R`, `test-single-step.R`
- `tests/testthat/fixtures/ss_hinv_parity/README.md`

## Not done (explicit)

- No covered flip; `public_covered_count` stays **7**
- No version bump (stays **0.9.0**)
- No `cov = fa` activation; no ordinary SS activation
- Avoided #237 cbind+permanent, genomic default, #365 loglik, cran-comments
- Julia twin not required for this R honesty slice

## Checks

See companion check-log entry.

## Rose

CLEAN for claim-vs-evidence on this slice: R FA planned, R SS opt-in partial,
engine-covered pointers unchanged, count 7, version 0.9.0.
