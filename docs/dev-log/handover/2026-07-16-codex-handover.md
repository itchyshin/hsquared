# Session handover — Retry-7 repaired-sidecar preseal

**To:** Codex  
**Date:** 2026-07-16  
**State:** pre-RNG admission packet complete; stop this lane here.

## Critical context

Retry-7 has a canonical D0F preseal, not an official result. Do not spend a
Retry-7 seed or widen the work to phenotypes, the 576-fit campaign, D1-D4,
activation, coverage/count changes, merge, or release without a new explicit
task and its own gate.

## What was accomplished

- Repaired the recovery-v3 driver sidecar and restarted all exact-head evidence
  on R `01ad843c8a2968b9180188f70bf9955cf433908c` and Julia
  `976814393043d3a4af5ce343d8ac4b05c43eac41`.
- Recorded full R and Julia checks, exact-source CI, fresh clean/dirty Totoro
  deployment controls, and the full zero-fit synthetic D0F-to-D1 lifecycle.
- Obtained fresh Grace/Rose Batch A and Batch B reviews plus enforced Sol
  `CLEAR_PRESEAL` adjudication.
- Wrote canonical D0F preseal at
  `/home/snakagaw/hsq_work/retry7-preseal-01ad843-97681439/d0f` and completed
  an RNG-unchanged chronology audit.

Authoritative detail:

- `docs/dev-log/check-log.d/2026-07-16-retry7-01ad843-canonical-preseal.md`
- `docs/dev-log/after-task/2026-07-16-retry7-01ad843-preseal-admission.md`

## Current working state

- **Working:** canonical preseal exists; its SHA-256 is
  `3013cbabee4c6374b0def49f205e81faa93cb7cfde484867ca7ba9c1f748809b`.
- **Verified absent:** bootstrap indices, attempts, recomputations, corpus,
  and stage adjudication output.
- **Not started:** all official RNG-derived work and all public/release actions.

## Key decisions and guards

- A source/schema/tool-byte change restarts the exact-head gate.
- Keep the current R and Julia source heads fixed until the next gate says
  otherwise.
- Use Totoro/DRAC only for campaign work; never GitHub Actions.
- Preserve all unrelated protected state. Use explicit path staging and avoid
  unscoped status/diff commands.

## Landing state

| Artifact | Branch | State |
| --- | --- | --- |
| Repaired-sidecar admission packet | `codex/2026-07-13-v07-performance-localization` | LANDED and pushed as `9e83f7e` |
| This handover | same branch | to be landed and pushed by this closeout commit |
| Unrelated protected worktree state | same checkout | CARRIED-OVER; do not inspect, stage, edit, or name it |

## Next immediate steps

1. Read `AGENTS.md`, this handover, the preseal evidence, and the after-task
   audit before running anything.
2. Confirm the canonical preseal SHA-256 and that all official-output paths are
   still absent.
3. If explicitly authorized, perform only the bound bootstrap-materialization
   step under the preseal contract, then stop for the next gate.

## Gotchas

- Canonical preparation fails closed unless Totoro uses the pinned Julia path
  and all numerical thread variables are one.
- The first two prepare attempts failed safely (missing thread pinning, then
  missing Julia `PATH`) and removed their incomplete stage roots. Do not treat
  them as evidence.
- The local R check has two existing vignette warnings; exact-source CI passed.

## How to resume

Start Codex in this repository and paste:

```text
Rehydrate from docs/dev-log/handover/2026-07-16-codex-handover.md and the AGENTS.md snapshot. Preserve the pre-RNG boundary; continue only with the Next Immediate Steps if explicitly authorized.
```
