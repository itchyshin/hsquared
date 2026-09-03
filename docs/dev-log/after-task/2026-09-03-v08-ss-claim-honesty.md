# After-task — R SS claim-surface honesty (no flip)

Date: 2026-09-03. Lane: R (`hsquared`). Branch:
`cursor/08-ss-honesty-r-20260903`. Type: honesty rewrite (no flip).

```
PLATFORM: cursor | LANE: cursor/08-ss-honesty-r-20260903
OTHER LANES: Codex DRAFT #137 cite-only · Dropbox FOREIGN ·
             R #164 cite-only (broad catch-up, not this slice)
Active lenses: Rose (this honesty) · Ada/Shannon fence
Spawned subagents: none
Current lane: R SS claim-surface honesty only
```

## Goal

Stop the R capability-status construction row from saying
“AGHmatrix/BLUPF90 comparator parity remain planned” after Julia #295
AGHmatrix construction AGREE and R #167 Hinv-cell parity landed. Name
that evidence as **existing**. Do not flip. Do not claim n≫6 recovery
is external-comparator-complete. Do not claim 0.8.0.

## What landed

- `docs/design/capability-status.md` construction-row claim column.
- Board one-liner + this report + matching `check-log.d` entry.

Independent of #164 (broad catch-up; not merged).

## Public claim audit

Allowed: “engine AGHmatrix construction AGREE + #167 Hinv-cell parity
exist; n≫6 is known-truth on the engine; R SS stays partial; count
stays 7.”
Blocked: R-public covered SS; ordinary-route activation; 0.8.0; count 8.

## Checks this slice

Docs-only. No `devtools::test()`. CI is the R-CMD-check on this PR.

## Next

Twin Julia honesty PR. Fresh SS Rose packet after both merge. FA
waiting owner `G10 FA`.
