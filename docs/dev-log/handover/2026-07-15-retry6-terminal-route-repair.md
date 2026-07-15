# Handover — Retry-6 terminal; seed-free route repair landed

Meta: 2026-07-15 MDT · sole sequential H² lane

## Start here

Retry 6 is permanently
`UNADJUDICATED_POSTRUN_ADJUDICATOR_ROUTE_BLOCKER`. Read
`docs/dev-log/recovery-checkpoints/2026-07-15-v07-d0f-retry6-postrun-adjudicator-route-blocker.md`.

All three 576-row routes and summaries completed, but the first post-run
receipt writer rebound Julia replay rows to the ordinary route during summary
reconstruction and stopped before writing any receipt. The root and complete
`2040000000` / `2041000000` spaces are immutable and retired; D1/D2 never
opened.

## Landed prospective repair

- `b8096e5`: route-aware D0F/D1 summary reconstruction and negative controls.
- `562b93e`: retire Retry-6 phenotype/bootstrap seeds; no proposed D0F stage.

The repair is seed-free and cannot repair, replay, or adjudicate Retry 6.

## Hard guards

- Spend no fresh seed; no successor D0F base exists.
- Preserve all retired roots and seed spaces.
- Preserve the two unstaged H2-2 Retry-5 drafts.
- Preserve the Julia quarantined scaffold, SHA-256 `30838979…6155`.
- Do not activate, promote, merge, release, claim G10, or change count 5.
- A successor needs a new preregistration, mutations, exact reviews, clean
  deploy, preseal, chronology audit, and explicit disjoint seed allocation.
- Totoro/DRAC only, never Actions, for campaign compute.

H2-2 was archived, not deleted; this is the sole active H² task. The task-name
and ownership announcement lesson is recorded in durable user memory.
