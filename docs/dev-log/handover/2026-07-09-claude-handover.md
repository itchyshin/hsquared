# Session Handoff: road to v1.0 — 0.1.0 honesty pass shipped + first covered-flip evidence banked

**Meta:** 2026-07-09 · from **Claude** (Opus 4.8), long autonomous session · to Claude/Codex (fresh) · repos: `hsquared` (R lane) + `HSquared.jl` (twin, lane-exception) + `shinichi-brain` (hub).

## Critical Context

Two things or the next session goes wrong:

1. **The goal is heading to v1.0, and the decision is: ship the near-term public release as `0.1.0`, NOT `1.0`.** A "1.0" over-claims a stable API against only 5 R-public-covered surfaces. The programme's own v1.0 (`HSquared.jl/docs/design/18-programme-plan-2026-06.md:53`) is the *Standard/workhorse* tier (multivariate + genomic-to-R + hardened bridge); "1.0-complete" (FA-G, non-Gaussian, inheritance, GPU) is the roadmap, honestly labelled partial/planned. The full plan is at `~/.claude/plans/to-finish-up-to-twinkly-moore.md`; the interactive mission-control + team-council artifacts are linked there.

2. **Verify, don't trust a green — this session repeatedly caught its own over-claims.** SLURM `COMPLETED` ≠ Julia succeeded (the script's last `echo` exits 0). `air format .` reformats the WHOLE repo (use `air format <files>`). `julia` is at `~/.juliaup/bin`, not on PATH. Totoro is SHARED (a labmate ran ~500 GB tonight) — check `free -g`/`who` before any submit; **memory is the binding constraint, not cores**; route heavy CPU to DRAC arrays. Compute accounts: `def-snakagaw_cpu` / `def-snakagaw_gpu`; DRAC checkout `~/projects/def-snakagaw/HSquared.jl` (`module load julia/1.10.10`, depot on `/project`).

## What Was Accomplished

- **Rehydrated + landed the AoG plotting slice** (`HSquared.jl` PR #264 **merged** → `main` @ 50131e69) + a docs close-out (#266). Fixed two dead honesty gates in the hub (`shinichi-brain` `rose-pattern-scan.R` root guard + locale-independence, pushed to `master`).
- **Full v1.0 plan** (31-agent analysis workflow) + **mission-control widget** + a real **21-agent named-team council** (all 19 lenses seated, Ada synthesis, Rose record). The council corrected two false premises and surfaced the #1 ship-blocker.
- **0.1.0 honesty pass — SHIPPED to PRs** (`hsquared` #125, `HSquared.jl` #267):
  - **#1 ship-blocker resolved**: `summary()`/figures printed intervals the v0.1 contract forbade. Amended the Uncertainty Scope (three claim levels: point / directional-conservative / experimental); labelled surfaces **target-specifically** (see finding below).
  - **Single-source ledger accessor** `validation_status_counts()` → `55 = 13 + 3 + 38 + 1`, verified live; retires the 52/53/55 drift. Exposes covered(13) AND covered_incl_external(16).
  - **Six ship-0.1 decisions** → `decisions.md` + covered-flip DoD → `AGENTS.md`; stale board header fixed; `enhancer` confirmed on CRAN AND shipping `DT_gryphon`; `man/` audit clean; articles excluded from the tarball.
- **Compute — two covered-flip campaigns banked on DRAC (fir):**
  - **Bootstrap interval coverage** (job 47870067, in #267): closed the arm the earlier study skipped. **Finding that corrected my own commit**: h² intervals over-cover (conservative, 0.997→0.964) but the raw **variance-component SE is ~nominal** (`delta_z` ≈ 0.92) — so "conservative" is claimed **for h² only**. Per-target not per-axis (profile best for σ²a; adaptive-Satterthwaite *under*-covers it; bootstrap well-calibrated).
  - **Broader-DGP multivariate recovery** (C8, job 47889484, PR #268): 8 cells × 50 seeds. Finding: the additive genetic (co)variance carries a mild **downward bias**, sharp at single-record × extreme-rg (under-recovers the genetic covariance). Characterization only, nothing promoted.

## Current Working State

- **Working:** everything committed + verified. `hsquared` main clean; both honesty branches + the C8 branch pushed with PRs. R: 1644 tests / 0 fail. Julia accessor live-checked.
- **In progress:** nothing mid-flight. No uncommitted work in either repo.
- **Blocked (on the maintainer):** the 3 PRs await sign-off; and the pending decisions below gate the rest of Track A/B.

## Key Decisions & Rationale

Ship 0.1.0 not 1.0 · **three claim levels** for intervals, target-specific · **per-target not per-axis** coverage (brain map + job 47870067) · **payload_v2 freeze-and-sequence** at the Track A/B seam · **migrate-first-then-flip** (bridge path on payload_v2 + parity test before an R surface is covered) · **Julia registration precedes R CRAN**. Recorded in `hsquared/docs/dev-log/decisions.md` (commit 33cc7d1) + `AGENTS.md` DoD. Council record: `scratchpad/v1/council.json`.

## Landing State

| Artifact / branch | Committed | Pushed | PR | State |
|---|---|---|---|---|
| `hsquared` `feat/2026-07-09-v01-honesty` (4 commits) | y | y | #125 open | LANDED (awaiting maintainer sign-off) |
| `HSquared.jl` `feat/2026-07-09-v01-honesty-engine` (2 commits) | y | y | #267 open | LANDED (lane-exception; awaiting sign-off) |
| `HSquared.jl` `sim/2026-07-09-c8-mv-recovery-breadth` | y | y | #268 open | LANDED (evidence; awaiting sign-off) |
| `HSquared.jl` PR #264 (plotting) | y | y | #264 **merged** | LANDED |
| `shinichi-brain` `master` (gate fixes) | y | y | — | LANDED @ bbc1c34 |
| Plan + artifacts | `~/.claude/plans/to-finish-up-to-twinkly-moore.md` + `scratchpad/v1/*.json` | — | — | LANDED (local) |

Nothing is CARRIED-OVER. The pending compute + code work below is NOT yet started (not "in progress").

## Next Immediate Steps

1. **Maintainer:** approve/adjust the 3 PRs; settle the pending decisions (interval-scope amendment is already applied per your "amend" call — confirm; covered=13-vs-16 definition; the covered-routing grammar to freeze before any Standard flip; repeatability priority; `hs_install_engine()` scope).
2. **Track B wave (NOT started — the heavier work):**
   - **Coverage-driver new-family extension** (Julia): add two/multi-effect ratio, repeatability, Fisher-z rg to `sim/phase1_small_sample_interval_calibration.jl` (spec in `scratchpad/v1/fanout.json`; NOTE: adding method labels invalidates `--resume` against the committed detail TSV).
   - **Bridge payload_v2 migration** (compute-free): ~16 `target=` paths, only 2 migrated; migrate-first-then-flip, byte-identical parity test each (map in `scratchpad/v1/fanout.json`).
   - **Comparators:** BLUPF90 already runs on the Mac (`comparator/bin/`); build a **Linux-static BLUPF90** for DRAC arrays + a **WOMBAT** stand-up (closes the single-leg gap for RR + multivariate).
   - **C18 GPU correctness parity** on **Vulcan** (`def-snakagaw_gpu`) — Float64/Float32/TF32 before any speed claim.
   - Optional: re-run C8 at the pre-declared 2000-rep tier to firm up the genetic-covariance bias magnitude.

## Blockers / Open Questions

The council's maintainer-only queue (in the plan + `decisions.md`): Uncertainty-Scope confirmation · stale `v0.1.0` tag (retag vs bump) · covered vs covered_external definition · covered-routing grammar + arg-naming (freeze before Standard) · supplied-K/Q escape hatch IN/OUT · repeatability priority · haplodiploid A-scale · `hs_install_engine()` scope · ML (`REML=FALSE`) · every `public_covered_count` move (G10, non-delegable).

## Gotchas & Failed Approaches

- **SLURM `COMPLETED` ≠ success** — always read the `.out` exit + the TSV. **`air format .` is repo-wide** — reverted 20+ stray files this session; use `air format <files>`. **Totoro shared/memory-bound** — check first, prefer DRAC. **Coverage driver `--resume`** breaks if method labels change. The **multivariate "segfault" is a JuliaCall/Rcpp teardown quirk (R-process), not an engine bug** — on DRAC (pure Julia) MV runs clean. The first team-council run returned a **hollow synthesis** (a script bug killed all 19 members; Ada reconstructed from context) — it was discarded and re-run; a `seated < 10 → throw` guard was added.

## How to Resume

```sh
cd "/Users/z3437171/Dropbox/Github Local/hsquared"
# rehydrate: run the hsquared-rehydrate skill; read this doc; then the plan:
#   ~/.claude/plans/to-finish-up-to-twinkly-moore.md
# spawn Rose (rose-systems-auditor) before any covered/claim statement.
```

Read order: (1) this file · (2) the plan · (3) `HSquared.jl/docs/design/18-programme-plan-2026-06.md` (v1.0 def) · (4) `scratchpad/v1/{synth,council,fanout}.json` (the analysis + specs) · (5) the two coverage checkpoints in `HSquared.jl/docs/dev-log/recovery-checkpoints/2026-07-09-*`.

**One-command resume (paste in your authenticated terminal):**
```
claude "Rehydrate from hsquared docs/dev-log/handover/2026-07-09-claude-handover.md + the v1.0 plan at ~/.claude/plans/to-finish-up-to-twinkly-moore.md. The 0.1.0 honesty pass is on PRs #125/#267 (+ C8 evidence #268), awaiting maintainer sign-off. Next is the Track B wave: coverage-driver new-family extension, bridge payload_v2 migration, Linux-BLUPF90 + WOMBAT comparators, and C18 GPU parity on Vulcan. Compute: DRAC def-snakagaw_cpu/_gpu (Totoro is shared/memory-bound — check first). Verify every green; do not move public_covered_count without maintainer G10."
```

## Mission Control

| Item | State |
|---|---|
| Near-term release | **0.1.0** (honest), not 1.0 |
| 0.1 honesty pass | **SHIPPED** → PRs #125 (R) + #267 (engine), awaiting sign-off |
| #1 ship-blocker (interval-vs-contract) | **resolved** (h² conservative, VC ~nominal) |
| Ledger accessor | `validation_status_counts()` → 13/16/38/1, live-verified |
| Bootstrap coverage (47870067) | **banked** in #267; corrected the VC over-claim |
| C8 MV recovery breadth (47889484) | **banked** → #268; genetic-covariance downward bias |
| Coverage-driver new families | spec ready, **NOT built** |
| Bridge payload_v2 migration | map ready (2/16 done), **NOT built** |
| Comparators (Linux-BLUPF90 + WOMBAT) | **NOT built** |
| C18 GPU parity (Vulcan) | **NOT started** |
| Coverage pins | `public_covered_count` **5**, rows **55**, covered **13** — UNCHANGED, nothing promoted |
