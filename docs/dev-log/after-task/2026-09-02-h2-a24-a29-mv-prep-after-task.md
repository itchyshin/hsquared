# After-task — A24–A29 MV prep cluster (R lane)

**Date:** 2026-09-02  
**Lane:** R (`hsquared`) — campaign worktree
`~/local-scratch/lanes/hsquared-h2-twin-20260901`, branch
`claude/lane-h2-twin-20260901`. **Not pushed.**  
**Lenses (as run):** Boole (A24/A28), Rose (A25/A29), Curie (A25a/A26b/A28),
Hopper (A26), Grace (DoD backfill / DP-10 guard companion).  
**Fence held:** R multivariate **partial** · `public_covered_count` **5** · no
covered flip · no push · no G10 · no Registrator · no version bump.

This is one consolidated after-task for the A24–A29 prep cluster, not nine
polished narratives. Facts come from the dated `check-log.d/` shards and the
scratch receipts already written at arc time. Where a reflective flourish would
be invented after the fact, it is omitted (A23 Option B honesty).

B0–B6 overnight after-task debt is **not** reconstructed here; it is covered by
the twin decision
`HSquared.jl/docs/dev-log/decisions/2026-09-02-block1-check-log-substitution.md`
(Option B). B4 already has
`2026-09-01-h2-b4-bridge-phase1-after-task.md`.

---

## 1. What this cluster did

| Arc | Outcome (one line) | Tip commit(s) | Check-log shard(s) |
| --- | --- | --- | --- |
| A24 | Corrected post-MV-4 “fitted only through opt-in engine” falsehoods on claim surfaces, help, and errors | `8ed0837`, `14f5a7b`, `a13595d` | `2026-09-01-h2-a24-mv4-claim-surface-honesty.md` |
| A25 | DESCRIPTION still said multivariate was opt-in; highest-reach wording fixed. MV-5 disposition **still open** (owner) | `469ab94` | `2026-09-02-h2-a25-rose-description-honesty.md` |
| A25a | Cited banked C8 broader-DGP confirm on R claim surfaces (no re-run) | (register reconcile commit in tip range) | `2026-09-02-h2-a25a-c8-register-reconcile.md` |
| A26 | Element-wise R↔engine k=2 parity; tolerances predeclared then measured (44/0/0 live) | `0ec917f` → `37843d8` → `74ba7d6` → `806f7a7` | `…-predeclaration.md`, `…-mv-bridge-parity.md`, `…-juliacall-na-segfault.md` |
| A26b | MV-1/`MV-1b` Suggests fail loudly under `NOT_CRAN` via `hs_require_suggests` | `d59d98e` | `2026-09-02-h2-a26b-sommer-loud-skip.md` |
| A28 | Capability-id **alias** (not rename); §H.3 discharged; `k≥3` / `diagonal` fences pinned in contract tests | `22cb5cd`…`e822db3` | `…-a28-capability-id-alias.md`, `…-a28-fence-enforcement.md` |
| A29 follow-up | Gate item 2 no-anchor disclosure **MET**; A26 language → “discharged locally, NOT CI-backed”; twins paired | `2fd5e31` | `2026-09-02-h2-a29-no-anchor-disclosure-a26-sync.md` |

Scratch companions (not repo files): `~/local-scratch/h2-a24-…`, `h2-a25-…`,
`h2-a26-…`, `h2-a26b-a28-…`, `h2-a29-…`, `h2-dp10-tier1-ci-plan.md`.

---

## 2. What was deliberately not done

- No R multivariate `partial → covered` flip.
- No push; CI remains **unverified**.
- No Tier-1 parity workflow enabled; stub stays `if: false`.
- Darwin A27 ink left blank (owner).
- DP-10 B-vs-C left to the owner; loud-failure guard is a separate Grace slice.
- A4 “(when flipped)” conditional and A5 `public_covered_count` ordinal
  normalisation left open (low value pre-flip / interacts with flip mechanics).

---

## 3. Checks (already recorded in shards; not re-run for this report)

Representative tip-era evidence from the A29 follow-up shard:

- `devtools::check(args = "--no-manual")` → **0 errors / 0 warnings / 0 notes**
- Full `devtools::test()` → **FAIL 0 / WARN 0 / SKIP 72 / PASS 2384**
- Live A26 parity → **44 pass / 0 fail / 0 skip**
- Live fences: multivariate **partial**; covered rows **4** / 21; count **5**

Exact commands live in the shards named above. This report does not invent new
numbers.

---

## 4. Coordination / DoD

- Coordination-board row prepended 2026-09-02 (Block 1 + MV prep).
- This file is the A24–A29 after-task required under the A23 “standard after-task
  from A24+” rule.
- Gate criterion 9 (Definition of Done) for this cluster is what this backfill
  addresses; Darwin ink and DP-10 remain owner blockers for any covered flip.
