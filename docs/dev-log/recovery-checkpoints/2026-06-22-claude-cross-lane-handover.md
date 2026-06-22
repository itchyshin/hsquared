# Claude Cross-Lane Handover: hsquared + HSquared.jl

Meta: 2026-06-22 America/Edmonton · from Codex R lane · to Claude session ·
context handoff after R PR #97 and Julia PR #154

## Critical Context

Start from live repository state, not chat memory. The handoff boundary was
prepared from these clean main heads:

- R repo: `/Users/z3437171/Dropbox/Github Local/hsquared`, `main` at
  `d4ec85d` (`Sync Julia non-Gaussian status correction (#97)`), with only the
  handover files changed on the handoff branch.
- Julia repo: `/Users/z3437171/Dropbox/Github Local/HSquared.jl`, `main` at
  `38286b1` (`Correct non-Gaussian bridge gap status (#154)`), clean before the
  mirrored handover branch.
- GitHub PR state checked during handoff: no open PRs in `itchyshin/hsquared`
  and no open PRs in `itchyshin/HSquared.jl`.
- Latest checked remote evidence: R `pkgdown` main run
  `27924488120` succeeded for `d4ec85d`; Julia `CI` run `27924194110` and
  `Documenter` run `27924194112` succeeded for `38286b1`.

If this handoff branch has been merged, the commit containing this file is the
fresh-session start boundary. If it has not been merged, start from the two main
heads above and read this file as an unmerged local checkpoint.

This file is the primary current checkpoint. The same handoff branch also
contains an earlier same-session twin packet,
`docs/dev-log/handover/2026-06-22-claude-twin-handoff.md`; keep it as useful
context, but prefer this recovery checkpoint for the final start order and
superseded-draft handling.

## What Was Accomplished

The last banked cross-lane sequence closed the non-Gaussian status ping-pong:

- hsquared PR #95 (`05fbdd3`) mirrored the Julia
  `test/fixtures/non_gaussian_parity/` fixture and added Julia-free
  `NonGaussianFit` normalizer tests for Poisson-Laplace and
  Binomial-variational payloads, including vector `n_trials` preservation.
- hsquared PR #96 (`e7c7a4a`) corrected stale R bridge-gap wording so it no
  longer says R rejects non-Gaussian families wholesale.
- hsquared PR #97 (`d4ec85d`) recorded Julia PR #154 as the corrected final
  Julia mirror for non-Gaussian bridge status.
- HSquared.jl PR #154 (`38286b1`) corrected Julia issue/status wording to credit
  the existing opt-in R `target = "nongaussian"` bridge while keeping the
  remaining per-record varying-trial and validation/comparator gates open.

The result: the R and Julia ledgers now agree that `V6-LAPLACE` is still
partial, but the basic opt-in Poisson/Binomial bridge and fixture-normalizer
consumption are banked.

## Current Working State

- Working:
  - v0.1 univariate Gaussian animal model remains the covered/default public
    capability.
  - Experimental opt-in R bridge surfaces exist for several Julia targets,
    including multivariate, genomic/SNP-BLUP, marker scans, metafounder/H^Gamma,
    random regression, and non-Gaussian Poisson/Binomial.
  - Recent R and Julia status ledgers are synchronized through R PR #97 and
    Julia PR #154.
- In progress / partial:
  - Multivariate `V4-MV-REML` remains partial despite strong evidence: R
    recovery, sommer same-estimand comparator, Mrode 5.1 supplied-covariance
    anchor, and MCMCglmm Bayesian agreement. Promotion still needs acceptance or
    broadening of the recovery gate plus another independent same-estimand
    comparator beyond sommer.
  - Non-Gaussian `V6-LAPLACE` remains partial. The basic bridge exists, but
    per-record varying-trial formula/bridge activation, external comparator
    evidence, and interval/calibration depth remain open.
  - Marker thresholds remain inactive and uncalibrated publicly.
  - Structured covariance is split: unstructured and diagonal controls are
    banked experimentally; lowrank/fa loading exposure and formula grammar are
    still blocked.
  - Metafounder/H^Gamma is supplied-Gamma only; no Gamma estimation or external
    comparator evidence.
- Blocked locally:
  - BLUPF90-family second-comparator evidence is blocked on local executable
    availability. Prior Julia checks recorded missing `renumf90`, `airemlf90`,
    `blupf90`, `remlf90`, and `gibbsf90` on PATH.
  - Marker-scan external comparator/calibration work is blocked on local tool
    and package availability for PLINK/GEMMA/GCTA/SAIGE-style tools and several
    R comparator packages; prior R records found `sommer` available but not the
    broader stack.

## Key Decisions & Rationale

- Keep the R and Julia lanes separate. R owns user syntax, R-style fitted
  objects, extractors, pkgdown, and bridge glue. Julia owns numerical engines,
  fixtures, result payloads, Documenter, and engine validation.
- Do not treat green PRs as capability promotion. Every promotion still needs
  the capability/validation rows, public-claims register, check-log evidence,
  issue state, and Rose audit to agree.
- For Claude specifically: prefer planning, prose/status cleanup, issue-body
  rationalization, and diff review. Hand live toolchain work back to Codex when
  it requires local R/Julia execution, JuliaCall, full package checks, or
  comparator executables.

## Files Created / Modified By This Handoff

In `hsquared`:

- already present on the handoff branch and preserved:
  `docs/dev-log/handover/2026-06-22-claude-twin-handoff.md`
- `docs/dev-log/recovery-checkpoints/2026-06-22-claude-cross-lane-handover.md`
- `docs/dev-log/after-task/2026-06-22-claude-cross-lane-handover.md`
- `docs/dev-log/check-log.md`
- `docs/dev-log/coordination-board.md`
- removed stale untracked draft:
  `docs/dev-log/after-task/2026-06-21-codex-team-handover.md`
- removed stale untracked draft:
  `docs/dev-log/handover/2026-06-21-codex-team.md`

In `HSquared.jl` mirror branch:

- already present on the handoff branch and preserved:
  `docs/dev-log/recovery-checkpoints/2026-06-22-claude-twin-handoff.md`
- `docs/dev-log/recovery-checkpoints/2026-06-22-claude-cross-lane-handover.md`
- `docs/dev-log/check-log.d/2026-06-22-claude-cross-lane-handover.md`
- `docs/dev-log/after-task/2026-06-22-claude-cross-lane-handover.md`

## Next Immediate Steps

Recommended Claude start order:

1. Read `/Users/z3437171/shinichi-brain/AGENTS.md`.
2. In R repo, read `AGENTS.md`, this handoff, `docs/dev-log/check-log.md`,
   `docs/dev-log/coordination-board.md`, and
   `docs/dev-log/after-task/2026-06-21-julia-154-nongaussian-status-sync.md`.
3. In Julia repo, read `AGENTS.md`,
   `docs/dev-log/recovery-checkpoints/2026-06-22-claude-cross-lane-handover.md`,
   `docs/dev-log/check-log.d/2026-06-21-r-nongaussian-bridge-gap-correction.md`,
   and `docs/dev-log/after-task/2026-06-21-r-nongaussian-bridge-gap-correction.md`.
4. Run:

```sh
cd "/Users/z3437171/Dropbox/Github Local/hsquared"
git status --short --branch
gh pr list --repo itchyshin/hsquared --state open --limit 20
gh run list --repo itchyshin/hsquared --branch main --limit 5

cd "/Users/z3437171/Dropbox/Github Local/HSquared.jl"
git status --short --branch
gh pr list --repo itchyshin/HSquared.jl --state open --limit 20
gh run list --repo itchyshin/HSquared.jl --branch main --limit 5
```

5. Choose one narrow slice. Suggested order:
   - Audit and, if desired, clean stale historical `local edits in progress`
     rows in the R coordination board that are already banked in later PRs.
   - Draft the per-record varying-trial non-Gaussian R activation plan, but do
     not claim activation unless Codex/live tests prove the bridge path.
   - Write a comparator-runbook for the multivariate second same-estimand
     comparator, including BLUPF90 executable install expectations and exact
     output alignment checks.
   - Draft the genomic external-comparator route for the
     `genomic_gblup_snpblup_target` fixture, keeping it as target/internal
     evidence until an accepted package actually runs.
   - Review structured covariance lowrank/fa language and keep loadings fenced
     until Julia exposes a validated bridge payload.

## Blockers / Open Questions

- Does the next environment have BLUPF90-family executables? If yes, the
  Julia packet from PR #151 can become a real comparator run. If no, record the
  blocker and avoid a comparator-evidence claim.
- Does Claude have a live R/Julia toolchain? If not, keep it to plan/prose/diff
  review and route execution to Codex.
- Should stale historical board rows be corrected now? They do not change
  capability truth, but they can confuse future agents.
- Should the next non-Gaussian slice activate per-record varying trials in R, or
  should the team first run a deeper external comparator/calibration scout?

## Gotchas & Failed Approaches

- Do not re-open the old A3/#93 plot-data story as current work. That slice has
  already been banked and closed.
- Do not count MCMCglmm as same-estimand REML comparator parity. It is Bayesian
  agreement evidence.
- Do not claim BLUPF90 comparator evidence from packet generation alone. No
  BLUPF90-family executable run has been recorded locally.
- Do not treat `n_trials` fixture preservation as R formula activation for
  per-record varying trials. It proves normalizer/serialized payload handling.
- Do not edit both repos in the same branch as if this were a monorepo. If
  Claude changes both, use one narrow PR per repo and write the handoff between
  them explicitly.

## How to Resume

Paste this to Claude:

```text
You are taking over the hsquared / HSquared.jl twin-package handoff.

Start in:
/Users/z3437171/Dropbox/Github Local/hsquared

First read:
1. /Users/z3437171/shinichi-brain/AGENTS.md
2. /Users/z3437171/Dropbox/Github Local/hsquared/AGENTS.md
3. /Users/z3437171/Dropbox/Github Local/hsquared/docs/dev-log/recovery-checkpoints/2026-06-22-claude-cross-lane-handover.md
4. /Users/z3437171/Dropbox/Github Local/HSquared.jl/AGENTS.md
5. /Users/z3437171/Dropbox/Github Local/HSquared.jl/docs/dev-log/recovery-checkpoints/2026-06-22-claude-cross-lane-handover.md

Then run git status and gh PR/run checks in both repos. Treat R main d4ec85d
and Julia main 38286b1 as the pre-handoff evidence boundary; if handoff PRs are
merged, start at the merge commits containing the handoff files.

Goal: continue from a clean, honest cross-lane boundary. Pick one narrow next
slice, keep capability language conservative, and route live engine/comparator
work back to Codex if Claude cannot run the toolchain.
```

No widget/dashboard is currently running or required for this hsquared handoff.
Use the repo files plus GitHub Actions URLs above as the live status surface.
