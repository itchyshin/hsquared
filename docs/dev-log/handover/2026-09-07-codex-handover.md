# Session Handoff: Path FULL 0.9 finish — Cursor → Codex

Meta: 2026-09-07 (Denver) · from Cursor (Claude, AUTHOR=claude) · TARGET=codex · owner
STOPPED the Cursor "Path FULL continuous" goal at this point (not a crash, not a usage-limit
cutoff — an explicit owner stop). Context %: not applicable (fresh doc, not a compaction
handoff).

**You are Codex, picking up the R `hsquared` lane of the twin-repo Path FULL 0.9 finish.**
This is the **primary** resume doc for the whole 0.9 campaign. The Julia twin's handover
(`HSquared.jl/docs/dev-log/handover/2026-09-07-codex-handover.md`) is a **pointer** — it names
what Julia still owes and sends you back here for the full narrative. Read this doc fully
before touching either repo.

---

## Twin strategy — which line does Codex run? (Shinichi asked explicitly)

**One Codex session = one repo checkout.** Codex cannot safely drive both `hsquared` and
`HSquared.jl` from inside one session/context the way this campaign has been run — the two
repos have independent git remotes, independent CI, and (right now) independently dirty
Dropbox working trees on an unrelated foreign branch (see Gotchas). Splitting by repo, not by
task, keeps each session's `git status` legible and keeps a bad command in one repo from ever
touching the other's tree.

**Recommendation:**

| Line | Repo | Role | When |
| --- | --- | --- | --- |
| **Primary resume** | R `hsquared` (this repo) | Land the remaining Layer B / FA-SS / bridge-fence honesty PRs, run `devtools::check()`, prep the 0.9 release paperwork (still WITHHELD) | **Start here** |
| **Secondary** | Julia `HSquared.jl` | Land the Julia FA/SS honesty PR, run `Pkg.test()` + `docs/make.jl`, mirror the coordination-board refresh | Either a **second Codex thread** in parallel, or the **same human** switches checkouts after the R slice lands |

Keep the twins aligned through the **coordination board** (`docs/dev-log/coordination-board.md`
in each repo) and `~/local-scratch/h2-09-finish-CONTINUOUS-RUN-STATUS.md` (owner-facing status,
outside either repo) — **not** by editing both Dropbox trees inside one session. If you run two
Codex threads at once, each thread reads only its own repo's `AGENTS.md` and this handover set;
neither thread should `cd` into the other repo.

---

## Critical Context

- **Version is 0.8.0 on both twins. `public_covered_count` is 7 on both twins. 0.9.0 is
  NOT authorized.** Do not bump either `DESCRIPTION`/`Project.toml`, do not tag, do not flip
  any `capability-status.md` row, do not touch CRAN/Registrator/1.0 language. These are hard
  fences the owner has repeated at every gate this campaign.
- **The owner STOPPED the continuous run.** A background "Path FULL continuous" authorization
  was live in Cursor (owner paste 2026-09-07, receipt
  `~/local-scratch/receipts/continuous/PATH-FULL-CONTINUOUS-2026-09-07.receipt`) and drove steps
  0–11 of the critical path (see Landing State). The owner then stopped that Cursor goal — **do
  not assume continuous authorization carries into this Codex session.** Treat every remaining
  step as needing its own read of live state, not a resumed autopilot.
- **Both twins' Dropbox working trees are dirty and on a stale foreign branch**
  (`codex/2026-07-13-v07-performance-localization`, ~40 uncommitted files, ~25 unpushed
  branches from mid-July). This is **pre-existing, unrelated debris from an earlier Codex arc**
  — it is not part of the 0.9 finish and this handover does not touch it. See Gotchas for the
  exact command to reproduce this finding and the standing rule about it.
- Two PRs (**R #193** six-surface content, **R #194** Layer B+Gate-6 evidence; Julia mirror
  **#313**) are **open, clean, CI green, NOT merged** — they were prepared during the
  continuous run and are ready for a merge-when-green pass. Do not assume they are landed.

## What Was Accomplished (this Cursor session, 2026-09-07 continuous run, before the stop)

Verified live via `gh`/`git` at handover time (not taken on trust from scratch notes):

1. **R #191** ("Layer B B1/B2 honesty wording") — **MERGED** `06bce49249d563bdf1dcf5c6fa2c8cc742139624`,
   `2026-09-07T13:04:10Z`. Fisher F-1/F-2 wording fixes on `R/fit-object.R` +
   `docs/design/01-v0.1-contract.md` + `docs/design/39-h0-univariate-coverage-flip.md` +
   `docs/dev-log/recovery-checkpoints/2026-07-10-coverage-recovery-results.md`. No count/version
   change. Boole freeze receipt `receipts/layerb/BOOLE-FREEZE-2026-09-07.receipt`; fresh Rose
   verdict **CLEAN WITH NITS** `receipts/layerb/ROSE-LAYERB-FRESH-2026-09-07.receipt`.
2. **R #192** ("demote plotted variance-component SE claim", the "L-4" fix) — **MERGED**
   `fc7230c2c7eaa8a92e1eb28cb3c0300a17d650f8`, `2026-09-07T13:44:30Z`. `R/plot.R` +
   `man/plot.hsquared_fit.Rd` no longer claim the raw VC-SE plot "covers approximately
   nominally" (falsified — the measured σ²a delta/Wald cell under-covers at 0.897 < 0.90).
   Receipt `receipts/layerb/L4-PLOT-MERGED-2026-09-07.receipt`.
3. **`ratify H0 Layer B`** — owner-authorized under continuous unlock, banked
   `receipts/layerb/RATIFY-H0-LAYERB-2026-09-07.receipt`.
4. **Gate-6 Rose** (fresh audit of both live `main` tips post-#191) — **CLEAN WITH NITS**,
   `~/local-scratch/h2-09-finish-ROSE-GATE6-VERDICT.md` /
   `receipts/gate6/ROSE-GATE6-FRESH-2026-09-07.receipt`. Explicit: **"Authorize 0.9.0
   recommended? No."** Five nits listed (falsified plot sentence — now fixed by #192; stale
   board rows; missing check-log/after-task for the day's landing; open PR debt; standing
   correctly-disclosed limitations). None block, none inflate the count.
5. **`defer H1/H3 science from 0.9`** — owner paste, banked
   `receipts/h1h3/DEFER-H1H3-FROM-09-2026-09-07.receipt`. H1/H3 interval-coverage science stays
   off the 0.9 critical path.
6. **`G10 no — hold V1-MATFREE-REML`** — owner paste, banked
   `receipts/g10/HOLD-V1-MATFREE-REML-2026-09-07.receipt`. The Julia matrix-free REML fitter is
   held at experimental; the evidence packet was judged insufficient for an
   experimental→covered flip. This is a **Julia-lane** decision recorded here because it was
   part of the same continuous run.
7. **R #193** ("Layer B six-surface honesty wording, H0 ratified") opened from scratch branch
   `scratch/layerb-six-surface-content` (base commit `834e64a`) — **OPEN, MERGEABLE, CLEAN,
   R-CMD-check SUCCESS, NOT merged.** 8 files: `NEWS.md`, `R/extractors.R`, `R/fit-object.R`,
   `docs/design/01-v0.1-contract.md`, `docs/design/06-public-claims-register.md`,
   `docs/design/capability-status.md`, `man/heritability_interval.Rd`,
   `man/variance_component_standard_errors.Rd`. PR body explicitly excludes L-4 (separately
   landed as #192), FA/SS honesty (separate PR), and bridge production fences (separate PR).
8. **R #194** ("Layer B #191 + Gate-6 Rose evidence, not 0.9.0") opened — **OPEN, MERGEABLE,
   CLEAN, R-CMD-check SUCCESS, NOT merged.** Refreshes `docs/dev-log/coordination-board.md`
   (the stale 2026-09-05 row), adds check-log.d shards + after-task notes for the #191 merge
   and the Gate-6 Rose audit, and re-touches the same six-surface files (additive, same intent
   as #193 — **verify overlap before merging both**; see Next Immediate Steps).
9. **Julia #313** ("Gate-6 Rose evidence mirror, not 0.9.0") opened, mirroring #194 on the
   Julia coordination board — **OPEN, MERGEABLE, CLEAN, checks SUCCESS/SKIPPED, NOT merged.**

**NOT yet turned into PRs** (still scratch-only, unpushed, per
`~/local-scratch/h2-09-finish-SCRATCH-LANDING-QUEUE.md`):

- R FA/SS status honesty — commit `0c02f57` on `~/local-scratch/hsquared-09-post191/`,
  branch `scratch/fa-ss-status-honesty`.
- Julia FA/SS status honesty — commit `2b1ad22` on `~/local-scratch/HSquared.jl-09-post191/`,
  branch `scratch/fa-ss-status-honesty`.
- R bridge production fences — commit `ef06f0e` on `~/local-scratch/hsquared-09-post191/`,
  branch `scratch/bridge-production-fences`.
- Julia bridge production fences — commit `d47aa3f` on `~/local-scratch/HSquared.jl-09-post191/`,
  branch `scratch/bridge-production-fences`.

## Current Working State

- **Working (merged, verified live):** #191, #192 on R main; the honesty wording they carry is
  live and correct.
- **In progress (open PRs, CI green, not merged):** R #193, R #194, Julia #313. These need a
  human/agent merge-when-green pass, in an order that avoids the #193/#194 file overlap (both
  touch `docs/design/capability-status.md`, `docs/design/06-public-claims-register.md`,
  `R/extractors.R`, `R/fit-object.R`, `NEWS.md`, and the two `man/*.Rd` files — **check the
  actual diff overlap before merging the second one; rebase if needed**).
- **Not started / scratch-only:** FA/SS honesty (both twins), bridge production fences (both
  twins) — drafted but never pushed or opened as PRs.
- **Not working / blocked:** nothing is broken; nothing is CI-red. The blocker is sequencing
  and owner-gated authorization, not a defect.
- **Explicitly forbidden right now:** `authorize 0.9.0`, any `DESCRIPTION`/`Project.toml`
  version bump, any `capability-status.md` covered-flip, Registrator/CRAN/1.0 language, forging
  a Boole/Rose/Fisher receipt, merging R #193/#194 or Julia #313 without checking CI is still
  green at merge time (CI status can go stale).

## Key Decisions & Rationale

- **Pins stay fixed through 0.9:** version **0.8.0**, `public_covered_count` **7**. The whole
  campaign's job is to land already-earned *honesty wording* (no new capability, no new
  evidence-backed flip) before anyone touches the version number.
- **After 0.9 ships, the next version is 0.10.x, not 1.0.** 1.0 is a separate, much larger
  decision (interval calibration, production bridge, full evidence review) — do not let any PR
  description imply otherwise.
- **G10 held V1-MATFREE-REML** rather than flipping it: the owner judged the evidence packet
  (SMOKE + one feasibility probe, no full recovery gate run) insufficient for
  experimental→covered. This is a **hold**, not a rejection — S5's frozen pre-declaration
  (`33ab68f6` in the Julia repo) stays frozen for a future run, it was simply not run this
  session.
- **H1/H3 interval-coverage science is deferred from the 0.9 critical path**, not cancelled.
  The harness exists (`tests/testthat/test-...` + the C1-ext harness per PR #294 history); it
  is simply not gating this release.
- **Six-surface, FA/SS, and bridge-fences are deliberately split into separate PRs** rather than
  one giant PR, specifically so each can be reviewed and merged independently and so a
  CI failure or Rose nit in one does not block the others. Do not squash them together.
- **Split Codex by repo, not by task** (this section's twin-strategy answer) because the two
  repos' git states, CI systems, and (right now) dirty-tree situations are independent; mixing
  them in one context risks a command landing in the wrong repo.

## Landing State — the git ledger

Paste-ready `handoff_gate.sh` finding (2026-09-07, this session): **both Dropbox working
trees are dirty and on the wrong branch** (`codex/2026-07-13-v07-performance-localization`,
pre-existing, unrelated). This handover was written and will be committed from a **clean
worktree off `origin/main`**, not the dirty Dropbox tree — see Gotchas.

| Artifact / branch | Committed | Pushed | PR | State |
| --- | --- | --- | --- | --- |
| R #191 Layer B B1/B2 (`8a3f597`) | y | y | [#191](https://github.com/itchyshin/hsquared/pull/191) merged `06bce492` | **LANDED** |
| R #192 L-4 plot/man (`7050f966`) | y | y | [#192](https://github.com/itchyshin/hsquared/pull/192) merged `fc7230c2` | **LANDED** |
| R #193 six-surface content | y | y | [#193](https://github.com/itchyshin/hsquared/pull/193) OPEN, CLEAN, CI green | **CARRIED-OVER** — merge-when-green owed |
| R #194 Layer B+Gate-6 evidence | y | y | [#194](https://github.com/itchyshin/hsquared/pull/194) OPEN, CLEAN, CI green | **CARRIED-OVER** — merge-when-green owed; check overlap vs #193 first |
| Julia #313 Gate-6 evidence mirror | y | y | [#313](https://github.com/itchyshin/HSquared.jl/pull/313) OPEN, CLEAN, checks green | **CARRIED-OVER** (Julia lane) |
| R FA/SS honesty (`0c02f57`) | y (scratch clone) | **n** | none | **CARRIED-OVER** — resume: `cd ~/local-scratch/hsquared-09-post191 && git checkout scratch/fa-ss-status-honesty`, rebase onto post-#193/#194 main, open PR |
| Julia FA/SS honesty (`2b1ad22`) | y (scratch clone) | **n** | none | **CARRIED-OVER** (Julia lane) — resume: `cd ~/local-scratch/HSquared.jl-09-post191 && git checkout scratch/fa-ss-status-honesty`, open PR |
| R bridge production fences (`ef06f0e`) | y (scratch clone) | **n** | none | **CARRIED-OVER** — resume: `cd ~/local-scratch/hsquared-09-post191 && git checkout scratch/bridge-production-fences`, open PR |
| Julia bridge production fences (`d47aa3f`) | y (scratch clone) | **n** | none | **CARRIED-OVER** (Julia lane) |
| R #185 (air-format style debt) | y | y | [#185](https://github.com/itchyshin/hsquared/pull/185) OPEN, `mergeable=UNKNOWN` (stale) | **CARRIED-OVER** — optional, not on the 0.9 critical path; re-check mergeability before touching |
| Julia #267 (honesty-engine accessor) | y | y | [#267](https://github.com/itchyshin/HSquared.jl/pull/267) OPEN, checks show a FAILURE | **CARRIED-OVER** (Julia lane) — isolated, pre-existing, not part of this campaign |
| Julia #265 (chore: archive superseded snapshot) | y | y | [#265](https://github.com/itchyshin/HSquared.jl/pull/265) OPEN | **CARRIED-OVER** (Julia lane) — chore, not blocking |
| This handover doc + Julia mirror | committing now | pending this session | opening now | see Commit section below |
| Dropbox `hsquared` foreign-branch debris (`codex/2026-07-13-…`) | n/a (pre-existing) | n/a | n/a | **CARRIED-OVER (not this session's to resolve)** — flag to owner; do not silently clean it |
| Dropbox `HSquared.jl` foreign-branch debris (same branch name) | n/a (pre-existing) | n/a | n/a | **CARRIED-OVER (not this session's to resolve)** |

**FINDINGS-OF-RECORD:** none beyond what is already banked in the receipts cited above and in
`~/local-scratch/h2-09-finish-ROSE-GATE6-VERDICT.md` / `ROSE-LAYERB-VERDICT.md` (both already
vault-durable scratch files, read at handover time, not re-derived).

## Next Immediate Steps (ordered, specific, actionable — R lane)

1. **Re-verify live state first.** `gh pr list --state open` and `gh pr view 193/194` against
   current `main` — CI status and mergeability can go stale between this doc's write time and
   your session start.
2. **Diff #193 vs #194 for real overlap** (`gh pr diff 193 --name-only` vs `gh pr diff 194
   --name-only`; both touch `capability-status.md`, `06-public-claims-register.md`,
   `R/extractors.R`, `R/fit-object.R`, `NEWS.md`, both `.Rd` files). If the hunks conflict,
   merge #193 first (it is the larger content PR per the six-surface plan), then rebase #194
   on top before merging it. If they are genuinely additive/disjoint at the line level, merge
   in either order but re-run CI on the second after the first lands.
3. **Merge #193 then #194 (or the reconciled order from step 2) when green**, using the
   existing `pr_merge_when_green.sh` pattern this campaign already used for #191/#192 (see
   `~/local-scratch/h2-09-finish-191-MERGE-WHEN-GREEN-RUNBOOK.md` for the exact invocation
   pattern). **Do not auto-merge without checking CI is green at merge time.**
4. **Land the R FA/SS honesty PR.** From `~/local-scratch/hsquared-09-post191/`, checkout
   `scratch/fa-ss-status-honesty` (commit `0c02f57`), rebase onto the post-#193/#194 `main`,
   resolve any conflicts (expected: none per the pre-flight conflict matrix in
   `SCRATCH-LANDING-QUEUE.md`, since FA/SS touches disjoint FA/SS rows), open a PR, wait for
   green CI, merge.
5. **Land the R bridge-production-fences PR.** Same clone, branch `scratch/bridge-production-fences`
   (commit `ef06f0e`), same pattern.
6. **Run fresh local checks on live `main`** after all four PRs land: `devtools::document()`,
   `devtools::test()`, `pkgdown::check_pkgdown()`, `devtools::check()`. Record exact commands
   and outcomes in `docs/dev-log/check-log.md` (a check-log entry for **today's** landing does
   not yet exist on live main — Rose's Gate-6 nit #3 flagged this).
7. **Write an after-task report** for the 0.9-finish landing stack (mirrors the check-log
   entry) in `docs/dev-log/after-task/`.
8. **Do NOT authorize 0.9.0 yourself.** Once steps 1–7 are done and the coordination board is
   current on both twins, the remaining EARNED_09 chain items are: Julia twin done its own
   FA/SS + bridge-fences + checks (coordinate via the Julia handover doc, not by editing
   `HSquared.jl` from here), then a fresh joint after-task closing note, **then** wait for the
   owner's own `authorize 0.9.0` paste. That paste is the owner's, never an agent's, to write.
9. **If asked to open PR #185's air-format debt or Julia #267/#265:** these are pre-existing,
   off-critical-path items from before this campaign. Treat them as optional cleanup, not part
   of the 0.9 gate — re-verify their mergeability live before touching, since `mergeable=UNKNOWN`
   suggests GitHub has not recomputed their merge state recently (likely stale/rebased-needed).

## Blockers / Open Questions

- **Owner `authorize 0.9.0` / `EARNED_09`**: not this session's call under any circumstances.
- **Owner or Ada/Shannon decision on whether to re-open the "Path FULL continuous" mode** for
  Codex, or run this as a normal gated session (recommended default: gated — the owner just
  stopped continuous mode, so assume they want to check in between gates again unless told
  otherwise).
- **The dirty Dropbox foreign-branch debris** (both repos, `codex/2026-07-13-v07-performance-localization`)
  is old enough (~2 months) and large enough (dozens of unpushed branches) that it likely needs
  its own triage session — flag to the owner rather than attempting to resolve it inside a 0.9
  slice.
- **R #185 / Julia #267 / #265 mergeability** — all showed non-CLEAN or stale merge state at
  handover time; not investigated further since they are off the critical path.

## Gotchas / Failed Approaches

- **Do not run this handover's git operations inside the Dropbox `hsquared` or `HSquared.jl`
  checkouts directly.** Both are on branch `codex/2026-07-13-v07-performance-localization`
  with ~40 uncommitted files and ~25 unpushed branches — leftover from an unrelated, much
  older arc. `git status --short --branch` in either Dropbox tree will show this immediately.
  This handover's own commit was made from a **disposable worktree** off `origin/main`
  (`~/local-scratch/hsquared-codex-handover-2026-09-07`, branch
  `handover/2026-09-07-codex-handover`) specifically to avoid touching that tree. If you need
  to do real R-lane work after this handover, either clean up that Dropbox tree first (stash
  or discard the ~40 modified files, decide what to do with the ~25 unpushed branches — an
  **owner decision**, not an agent's) or work from your own fresh worktree/clone the same way.
- **Scratch clones already exist and are ahead of a stale `main`.**
  `~/local-scratch/hsquared-09-post191/` and `~/local-scratch/HSquared.jl-09-post191/` were
  branched from `main` at the point right after #191 merged (`06bce49`/pre-#192). Before
  reusing them, `git fetch origin main && git rebase origin/main` inside each, since #192,
  #193, #194 have since landed or opened on top.
- **Do not trust the local scratch narrative docs' PR-state claims over live `gh`.** Several
  of the `~/local-scratch/h2-09-finish-*.md` notes (written earlier in the day) say #191 is
  "OPEN" or Gate-6 Rose is "NOT READY" — both stale by the time this handover was written.
  Rose's own Gate-6 audit flagged this exact staleness. **Always re-verify PR/merge state with
  `gh` before acting on any scratch note's claim.**
- **Six-surface (#193) and the Gate-6 evidence PR (#194) both touch the same
  `capability-status.md` / `06-public-claims-register.md` rows.** This was flagged in advance
  in `SCRATCH-LANDING-QUEUE.md` ("touches same files as FA/SS draft — merge FA/SS after or
  combine in one PR with care") but the risk is symmetric for #193 vs #194 too — check the
  actual diff before assuming they're conflict-free.
- **The Julia twin's `AGENTS.md` "Live Phase Snapshot" pointer had gone stale on `main` since
  2026-07-12** (commit `e6bf8a17`) — almost two months — because the entire Szymek arc and the
  September #294–#313 stack landed via ordinary PRs that never touched that block. The
  "2026-08-04 Szymek handover" narrative some agents may recall from the dirty Dropbox tree was
  **never on `main`**; it lives only on the abandoned, unmerged branch
  `codex/2026-07-13-v07-performance-localization`. This handover refreshes the real `main`
  pointer (see the Julia handover doc's own "Standing drift found" section) — flagging it here
  too since it's a cross-twin process gap, not just a Julia-lane detail.

## Owed Chain to 0.9 (from `~/local-scratch/h2-09-finish-ROADMAP-NOW-2026-09-07.md`, re-verified)

Steps 1–9 of the 12-step ordered chain are **PAID** (Boole freeze → fresh Rose → #191 merge →
ratify H0 → Gate-6 Rose → H1/H3 defer → G10 hold → #192/L-4 merge). Steps 10–16 remain:

```
10. authorize 0.9.0                  PRE-AUTHORIZED (chain earned) but NOT PASTED — owner-only
11. Version bump 0.9.0 both twins    WITHHELD until 10
12. Land remaining scratch honesty   IN FLIGHT (#193/#194 open; FA/SS + bridge fences scratch-only) — THIS SESSION'S JOB
13. Fresh phase-1 checks on Dropbox  OWED (devtools::check / Pkg.test / Documenter) — after 12
14. Grace twin alignment + after-task  OWED — after 13
15. EARNED_09 evidence chain complete  OWED — after 14
16. Site deploy / release tags        WITHHELD until 10
```

**Your job this session is step 12 and, once that's clean, step 13.** Steps 10, 11, 16 are not
yours to perform under any authorization you might see in a stale note — only a live owner
paste authorizes them.

## How to Resume

```sh
cd "/Users/z3437171/Dropbox/Github Local/hsquared"
# AGENTS.md is native to Codex — it is read automatically.
# Then read this doc in full, then:
git status --short --branch   # confirm you are NOT accidentally on the dirty foreign branch
git fetch origin main && git log --oneline -5 origin/main
gh pr list --state open
```

Live-toolchain checks Codex should run (this repo, once on a clean branch off `main`):

```sh
Rscript -e 'devtools::document()'
Rscript -e 'devtools::test()'
Rscript -e 'pkgdown::check_pkgdown()'
Rscript -e 'devtools::check()'
```

Then work the Next Immediate Steps in order, re-verifying `gh` state before every merge.

---

## Mission-control summary

| Repo | Branch/main | CI | What shipped today | Plan by leverage |
| --- | --- | --- | --- | --- |
| `hsquared` (R) | `main` @ `fc7230c2` (post-#191, post-#192) | Green on merged PRs | Layer B honesty (#191, #192) merged; six-surface (#193) + Gate-6 evidence (#194) open/clean | **Highest leverage next:** merge #193→#194, then FA/SS + bridge fences, then fresh `devtools::check()` + check-log/after-task |
| `HSquared.jl` (Julia) | `main` @ `b571184a` | Green on merged PRs | Gate-6 evidence mirror (#313) open/clean | See Julia handover doc — FA/SS honesty + bridge fences + `Pkg.test()`/`docs/make.jl` |

**Both twins:** version **0.8.0**, `public_covered_count` **7**, **0.9.0 NOT authorized**, next
version after 0.9 is **0.10.x**, not **1.0**. No Registrator/CRAN.

Made with Cursor (Claude, Sonnet 5) · handed to Codex.
