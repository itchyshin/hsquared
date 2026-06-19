# After-task — WS1 issue backbone (post-v0.1.0 program, 2026-06-19)

## Task goal

Execute WS1 of the approved post-v0.1.0 program plan: turn the roadmap / dead-field /
twin-gate backlog into a granular, labelled GitHub issue tracker across **both** repos so the
backlog *is* the shared plan, file cross-lane advice to the twin via issues, and index it all
in a single doc. Issues-first, then WS2 + WS3 in parallel.

## Active lenses and spawned agents

- Lenses: Ada (program structure), Shannon (cross-repo coordination), Grace (labels), Rose
  (honesty audit).
- **Spawned subagent:** `rose-systems-auditor` (one pass) — audited the issue backlog +
  `issue-map.md` against `validation_status()`. Returned CLEAN-WITH-NOTES.
- Current lane: coordinator (issue management only on both repos; no twin code edits).

## Files changed

- `docs/dev-log/issue-map.md` — **new** single index of the backlog (both repos →
  phase/lane/type/status/validation anchor + cross-lane mirror map + WS2 work order).
- `docs/dev-log/coordination-board.md` — WS1 row.
- `.mission-control/status.json` — refreshed (disposable; gitignored).
- GitHub (no repo files): labels + issues on `itchyshin/hsquared` and `itchyshin/HSquared.jl`.

## What was done (exact)

- **Labels** (both repos, idempotent `--force`): added `phase-3`…`phase-8`, `innovation`,
  `cross-lane`. Reused the existing bare-word scheme (`bridge`/`validation`/`documentation`/
  `roadmap`/`r-package`/`julia-engine`/`status:*`) rather than introducing a parallel
  `type:`/`lane:` namespace (surgical; matches convention).
- **hsquared existing-issue audit:** #2 → `phase-1`+`status:covered` (v0.1 contract shipped;
  scoped comment); #8 retitled to "live HSData marshalling parity" + comment; #10 → `phase-3`.
  #5/#6/#7/#9 epic comments enumerating children.
- **hsquared new child issues #11–#20:** bridge slices (#11 heritability_interval, #12
  repeatability_interval, #13 REML genomic, #14 single_step routing, #15 on-main gap audit),
  #16 eigen_G wording verify, innovation notes (#17 FA-G EM, #18 LA/VA, #19 mi()), #20
  recurring scout.
- **hsquared R-mirror issues #21–#23** (of the twin's hand-offs): #21 PEV/reliability standard
  fields, #22 structured covariance, #23 post-fit gwas wrapper.
- **HSquared.jl twin-advice issues #37–#41** (`[from R lane]`, `cross-lane`): V4-FA calibration
  + em_fa.jl warm-start; 03-engine-contract.md reword; Phase 5 stack merge; Phase 6 branch +
  LA/VA; validation gates R needs.
- **Cross-links:** the twin filed 4 bridge-activation hand-offs back (HSquared.jl#42–#45) during
  the session; cross-linked each to its R mirror (#21/#22/#23/#18) on both sides.

## Checks run and outcomes

- `gh label list` (both repos) → new labels confirmed present on both.
- `gh issue list` (both repos) → final state verified; all relabels/retitles applied.
- **Rose audit (spawned):** CLEAN-WITH-NOTES, 0 blockers. Confirmed no `status:` label exceeds
  `validation_status()`; the only `status:covered` (issue #2) is defensibly scoped to the
  shipped v0.1 univariate Gaussian contract; the R-lane claims in twin issues do not overstate.
- No R/ code, tests, or package files touched → prior `devtools::test()` 793/0/0/27 +
  `check(--no-manual)` 0/0/0 stand unchanged.

## Public claim audit

No capability promoted. Every modelling capability stays `partial`/`planned`/`blocked` in the
issue-map. Only `V1-AI-REML`, `V1-AINV-MRODE9`, `V1-MRODE-FIT`, `V1-COMPARATORS` are `covered`
(unchanged).

## Tests of the tests

N/A (no test/fixture change). Verification was against the live GitHub API (`gh label/issue
list/view`) and read-only twin git inspection (`gh pr view 17`, `git grep origin/main`).

## Coordination notes

- Lane discipline held: twin interaction was issues only; the twin thread is **live** and
  reciprocated (filed #42–#45). The cross-lane channel is now bidirectional and indexed.
- The mirror map (issue-map.md) keeps both trackers in sync; future drift is one `gh` refresh.

## What did not go smoothly

- **Stale fact corrected by Rose:** my initial framing gated the structured-covariance work on
  "land PR #17." Live check showed **PR #17 is CLOSED (unmerged) but the FA core is already on
  `origin/main`** (V4-FA = partial; recovery calibration failed 8/10–9/10). Fixed the gate text
  on issue-map.md (rows #22 + cross-lane map + WS2 order), hsquared #22/#17 bodies, and reframed
  twin #37 from a merge decision to the live calibration question. (Confirms the Explore snapshot
  was stale — live state wins.)

## Known limitations / uncertainty

- WS2 buildability is not yet verified per-function: the on-main-vs-surfaced gap audit (#15) is
  WS2 Step 0 and must run before any bridge claim. #21 (PEV/reliability) looks lowest-delta but
  still needs Step-0 confirmation that the selinv methods are exposed in the standard payload.
- The twin's "Engine status: complete (experimental)" phrasing on #42–#45 is generous vs the
  `partial` rows (Rose note 2) — flagged for the twin thread, not an R blocker.

## Next actions (WS2 + WS3, in parallel)

1. **WS2 Step 0 (#15):** read-only on-main-vs-surfaced gap table → decide buildable vs twin-issue.
2. **WS2 first slice:** #21 PEV/reliability (lowest-delta), then #11/#12/#14/#13, each via the
   per-slice loop (probe → impl → fixture → multi-lens review → Rose → checks → after-task).
3. **WS3 innovation batch #1:** design notes for #17 (FA-G EM), #18 (LA/VA), #19 (mi()); literature
   pass; then stand up the recurring scout (#20).
