# Session Handoff: the 0.2.0 code arc — supplied-K/repeatability evidence + relmat()/precision() + Track A hardening

**Meta:** 2026-07-10→11 · from **Claude** (Opus 4.8), long autonomous session · to Claude/Codex (fresh) · repos: `hsquared` (R lane) + `HSquared.jl` (twin, sim/ lane-exception) · goal: **ship an honest `0.2.0`**.

## Critical Context

1. **`0.2.0` is a conservative, honest 0.x increment — `public_covered_count` STAYS 5. No covered flip, no G10 anywhere.** Maintainer decisions (2026-07-10): supplied-K escape hatch **IN as EXPERIMENTAL** (wire the R surface, do NOT flip to covered); the C1 interval claim-upgrade **kept experimental for now** (evidence banked, deferred). So `0.2.0` = a new experimental surface + honesty hardening + banked evidence. `1.0` stays the north star; the CRAN/Julia number tracks honest capability.

2. **The prudence discipline caught a real bias. Do NOT rescue it.** The repeatability `t` estimator **marginally FAILED its pre-registered 2000-rep confirm** (converged 1999/2000; bias −0.00120, MCSE 0.00057, |bias|/MCSE = 2.10 > 2.0). Per **R4 (doc 34 §9)** the gate is NOT moved and **no higher-rep/re-seeded re-run is scheduled**. Banked negative; repeatability stays experimental with a ~0.2%-downward point-bias caveat (finite-sample ratio-nonlinearity, NOT an engine defect — supplied-K components recover cleanly at the same tier). supplied-K, by contrast, is **CLEAN at 2000 seeds** (3 cells).

## What Was Accomplished

- **Rehydrated + pressure-tested the v1.0 plan** (6-lens council): sound but predated its execution; patched 6 defects. Mapped the per-pillar runway to a capable 1.0.
- **Built + ran a full pre-registered evidence pipeline** on DRAC `fir`, every driver ADEMP-reviewed → adversarially re-verified → local-smoked → cluster-smoked before its run (the gate caught a real bug in *every* driver, incl. a `@printf` load bug only the local smoke saw):
  - **C1** univariate interval coverage (2000 reps): h² directional-conservative; σ²a Wald under-covers (0.897), profile calibrated → *earns* a claim-level upgrade (deferred, kept experimental per maintainer).
  - **C8** multivariate recovery (500 seeds, 16 cells): 500/500 converged, base_inside passes (no R9), 14/16 pass; **#268 bias pinned to single-record × extreme-rg only**.
  - **supplied-K** screen 3/3 → **confirm CLEAN** (2000 seeds × arbK/identity/pedA).
  - **repeatability** screen interior pass → **confirm MARGINAL FAIL** (banked negative, above).
- **`0.2.0` CODE (both un-gated units, done + verified + PR'd):**
  - **`relmat()`/`precision()`** experimental supplied-relationship surface — follows the `genomic()` supplied-inverse pattern; 59/59 live; reduction anchors to machine precision. PR **#127**.
  - **Track A hardening** — `hsquared_unsupported_syntax` condition class (51 sites) + lifecycle experimental badges (93/94 exports; only `hsquared()`/`hs_control()` unbadged). 1664/0 full suite; `--as-cran` 0E/0W/2 pre-existing NOTEs. PR **#128**.
- **Evidence + pre-registration** durably recorded (doc 34 + results checkpoint, corrected to the confirm tier). PR **#129**.

## Current Working State

- Everything committed + pushed; three `0.2.0` PRs open against `main` (#127/#128/#129), plus this handover. Nothing mid-flight, no uncommitted work.
- **Twin `HSquared.jl`** `sim/2026-07-10-coverage-recovery-drivers` holds the 4 evidence drivers + confirm sbatch (sim/-only lane-exception, recorded on the board). Raw result TSVs on DRAC `/project` under `sim/drac/results/{c1_rerun_boot199,w1_v5,supplied_k,rr_repeat,rr_confirm}/`.
- **Blocked on the maintainer:** the release *cut* — `0.2.0` builds on the `0.1.0` honesty baseline (PRs #125, twin #267/#268), which must merge FIRST.

## Key Decisions & Rationale

Ship an honest `0.x` whose number tracks covered capability at CRAN/Julia-submission time · supplied-K escape hatch **IN as experimental** (no flip) · C1 interval upgrade **deferred** (kept experimental) · repeatability **banked-negative, gate frozen (R4)** · `relmat()/precision()` reuse the covered `genomic()`/`fit_ai_reml` supplied-inverse route (no new engine work) · lifecycle badges are the honesty mechanism over 96 exports (only 2 covered R surfaces unbadged).

## Landing State

| Artifact / branch | Committed | Pushed | PR | State |
|---|---|---|---|---|
| `feat/2026-07-10-relmat-precision-experimental` (`736c8be`) | y | y | #127 | LANDED, review-ready |
| `feat/2026-07-10-track-a-hardening` (`3556e49`) | y | y | #128 | LANDED, review-ready |
| `docs/2026-07-10-interval-prereg-evidence` (`b90d4c3`) | y | y | #129 | LANDED, review-ready |
| Twin `sim/2026-07-10-coverage-recovery-drivers` | y | y | — | LANDED (sim/ lane-exception) |
| This handover | y | y | (this PR) | LANDED |

## Next Immediate Steps

1. **Maintainer merges, in order:** the 0.1 honesty PRs (`#125`, twin `#267/#268`) → then the two feature PRs (`#127`, `#128`) → the evidence PR (`#129`). That assembles the `0.2.0` baseline.
2. **Maintainer decisions still owed:** stale-`v0.1.0`-tag call · `SystemRequirements` wording (declare `Julia (>= 1.10)` vs keep out — either way `--as-cran` must pass engine-free) · release-go sequencing (**Julia registers `v0.x` FIRST**, 3-day AutoMerge clock, then R CRAN).
3. **Final assembly pass (Claude/Codex, un-gated, on the merged baseline):** NEWS `0.2.0` (honest — new experimental surface + hardening, **count 5**, intervals still experimental, repeatability point-bias caveat) · `DESCRIPTION` `.9000 → 0.2.0` (LAST) · vignette/man engine-free build audit · 3-leg `R CMD check --as-cran` + `check-log` · `cran-comments.md`.
4. **Non-blocking, deferred (Codex/twin):** confirm the repeatability t-bias mechanism (finite-sample ratio-nonlinearity) via the clean supplied-K control; HSquared.jl Aqua/JET; the twin `0.2.0`.

## Blockers / Open Questions

Release cut gated on the `0.1.0` honesty merge. Maintainer: stale-tag, SystemRequirements, release-go. The supplied-K covered *flip* (future, not 0.2.0) still owes: a `sommer vsr(id,Gu=K)` comparator + n-ladder + Rose + escape-hatch-to-covered + G10.

## Gotchas & Failed Approaches

- **repeatability confirm: DO NOT re-run at higher reps to pass** (R4 §9). The 2000-rep tier is the pre-declared gate; its marginal fail stands.
- **Live JuliaCall bridge from R:** set `Sys.setenv(HSQUARED_JULIA_PROJECT = normalizePath("../HSquared.jl"))` (the `normalizePath` matters) + `julia` on PATH (`~/.juliaup/bin`), else `hs_julia_bridge_available()` returns FALSE and live tests skip. A **single embedded-Julia process cannot run the whole live suite** (JuliaCall segfault/OOM from many back-to-back fits) — run per-file or use `filter=`.
- **`air format .` reformats the WHOLE repo** (existing code isn't fully air-conformant) — use `air format <files>`.
- **SLURM `COMPLETED` ≠ Julia success**; `--parseable` is unsupported on this SLURM; memory `G` = 1024M. seed-array + per-task TSVs + a resume-aggregate pool is the confirm-tier pattern (the wellpowered n=3200 fit is ~112 s/seed → 2000 seeds must parallelize; a 50-seed/task × 40 array timed out at 90 min, needs ≥ 2h/task or fewer seeds/task).

## How To Resume

```sh
cd "/Users/z3437171/Dropbox/Github Local/hsquared"
# rehydrate: hsquared-rehydrate skill; read this handover; then:
#   docs/design/34-interval-recovery-pre-registration.md (the honesty anchor)
#   docs/dev-log/recovery-checkpoints/2026-07-10-coverage-recovery-results.md (confirm-tier results)
# PRs #127/#128/#129 are review-ready; the release cut waits on the 0.1 honesty merge.
```

Read order: (1) this file · (2) doc 34 + the results checkpoint · (3) the three PRs · (4) `capability-status.md` (relmat/precision now partial/experimental). `public_covered_count` = **5**, unchanged.
