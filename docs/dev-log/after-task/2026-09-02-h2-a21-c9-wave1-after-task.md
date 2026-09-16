# After-task / substitution — A21 C9 wave-1 (C5 / C6)

**Date:** 2026-09-02
**Lane:** R (`hsquared`) — campaign worktree
`~/local-scratch/lanes/hsquared-h2-twin-20260901`, branch
`claude/lane-h2-twin-20260901`.
**Active lenses:** Ada, Shannon, Rose (perspectives; Fisher/Noether/Falconer
on the cited C5/C6 work)
**Spawned subagents:** none
**Current lane:** coordinator / ledger only

Panel: `~/local-scratch/h2-a21-estimand-claim-panel-2026-09-02.md` §5.3 / §6
item **C9**. This is the wave-1 close-out, not a new design number and not a
covered flip.

**Fence held:** `public_covered_count` **5** · R multivariate **partial** ·
draft PR **#141** · no G10 · no Darwin ink · no Registrator · no merge ·
no capability-status count edit.

---

## Goal

Record what wave-1 landed after C5 and C6, and close A21 C9 for this lane
without writing a retroactive narrative for commits that already have
contemporaneous evidence (C6) or that were docs-only citation locks (C5).

## Substitution note

A21 C9 asked for a consolidated after-task plus a recorded substitution,
not eight reconstructed reports. Block 1 overnight debt already has an
adopted Option B decision
(`HSquared.jl` `docs/dev-log/decisions/2026-09-02-block1-check-log-substitution.md`).
This file is the **wave-1** substitution:

| Wave-1 item | Contemporaneous after-task? | How C9 treats it |
| --- | --- | --- |
| **C5** Willham lock `529a5a2` | **no** — docs-only citation lock, no shard | this report indexes the commit; no invented reflection |
| **C6** `r_am` identity `0c96fd3` | **yes** — `2026-09-02-h2-a21-c6-ram-identity.md` + check-log shard of the same name | cited, not restated |

No new `docs/design/NN-` ID. No new decision file (lease is after-task +
optional board line).

---

## What wave-1 landed (R)

| Item | SHA | What it did |
| --- | --- | --- |
| **C5** | `529a5a2b76cda71bf786ae2a64c9f342fd108cfe` | Locked `h2_T`, `m2`, and `r_am` in `docs/design/04-validation-canon.md` §Locked Derived-Estimand Identities with full Willham 1963/1972 citations (journal, volume, pages). Retrospective citation lock; `r_am` identity **test** still marked owed (C4). |
| **C6** | `0c96fd34dd92fcf5b81cf9786088e7dabdae0889` | Named the two `m2` denominators on the capability fences; pinned `direct_heritability()` to `heritability()` `h2_direct`; repaired `make_dm_fit` so an `r_am` identity assertion can hold. Evidence: the C6 after-task and `docs/dev-log/check-log.d/2026-09-02-h2-a21-c6-ram-identity.md`. |

Both SHAs are on `origin/claude/lane-h2-twin-20260901` and are ancestors of
draft PR [#141](https://github.com/itchyshin/hsquared/pull/141) (head at
C9 write time: `0c96fd3`).

Twin wave-1 (Julia lane; recorded in the sibling C9 report):

- JL-7 `ca4b4fcf9d64d25a0d09a67823bb71b4abaf06b3` — README / validation-status
  page: `public_covered_count` is a register label, not a callable.
- JL-8 `c0f53e0ddaf57d002100a55ee5798c5051e87095` — matfree fence `src/` scan
  is recursive (`walkdir`).
- Draft PR [#277](https://github.com/itchyshin/HSquared.jl/pull/277).

## Files changed (this C9 slice)

- this report
- one short prepended coordination-board row (existing Block 1 row left
  untouched)

## Checks

Ledger only. No package tests, `devtools::check()`, or capability-status
recount were run for C9. C6 already recorded
`devtools::test(filter = "direct-maternal")` → **FAIL 0 / WARN 0 / SKIP 1 /
PASS 67** and live `validation_status()` **21 / 4 covered**. C5 was a
canon-file citation lock with no test delta.

## Public-claim audit

No status word moved. `public_covered_count` stays **5**. C5 does not
promote the experimental two-effect maternal leg. C6's fence sentences
distinguish two already-documented estimands.

## Tests of the tests

None new here. C6's fence-prose guard was mutation-checked in that slice.

## Coordination

- PLATFORM: cursor | ON BRANCH: `claude/lane-h2-twin-20260901` | LANE: A21 C9
  wave-1 ledger. OTHER LANES: `codex/2026-07-13-v07-performance-localization`
  — not touched.
- Foreign-lane preflight flagged the Claude twin branch as expected; this
  slice stays inside `docs/dev-log/after-task/` plus one board line.
- Draft PRs stay draft. No merge.

## What did not go smoothly

C5 landed without its own after-task. Writing one after the fact would
manufacture the reflective half the A21 panel warned against (§5.2–§5.3).
Indexing the SHA is the honest substitute.

## Known limitations

- Julia-lane `r_am` identity test still owed (C4 / C6 next-action).
- Claims-register two-`m2` sentence still optional (A4 skipped while
  register-busy).
- G-AG-5 `validation_status()` rows still owner-gated.
- Darwin ink, G10, and Registrator remain owner-gated.

## Next actions

Keep the fence. Do not flip, merge, or register. Remaining A21 leisure
items (C4 Julia identity, C7 attach/register disclosure, C8 keep `R`
absent) are other leases.
