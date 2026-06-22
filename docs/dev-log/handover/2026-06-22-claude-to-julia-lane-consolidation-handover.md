# Handover: Claude (R lane) → Julia lane — consolidate both packages under one owner

Date: 2026-06-22 · From: Claude (R lane, `hsquared`) · To: the Julia lane
(`HSquared.jl`) · Type: lane-closing / ownership-consolidation handover.

## The decision

The Claude/R lane is **closing**. Development of **both** packages —
`hsquared` (R) and `HSquared.jl` (Julia) — consolidates under **one owner: the
Julia lane**, working across both repos simultaneously.

Why (evidence, not preference): the dominant cost of the two-lane structure has
been **cross-lane synchronization**, not the work itself. The coordination board
and recent PR history are dominated by `Sync Julia X status`, `Mirror fixture`,
and bridge-gap-wording PRs — a communication tax that exists *only* because two
owners kept two ledgers that had to be reconciled. One owner across both repos
deletes that entire class of work, and it is ideal for the **R↔Julia bridge**,
the project's highest-value and highest-friction surface (one owner writes the
engine payload + the R marshalling + the live round-trip in a single pass).

Shape of the consolidation: **keep the two repos**, one owner, a **single
cross-repo Definition of Done**, and **keep the review lenses** (Rose's
claim-vs-evidence audit especially — that discipline is independent of lane
count). The engine is the substance and R is the thinner glue, so the
engine-capable lane absorbing the R glue is the cheaper direction.

## Precondition (the one thing that actually matters)

The consolidated lane must be able to run **both** toolchains. This session
confirmed the host has `devtools`, `testthat`, `JuliaCall`, and the CRAN
comparator stack, and Julia is reachable via `~/.juliaup/bin/julia` — it was just
not on the non-interactive `PATH`. **Put `julia` on `PATH`** (e.g.
`export PATH="$HOME/.juliaup/bin:$PATH"`) so `hs_julia_bridge_available()` is
TRUE and the skip-guarded live R↔Julia tests actually run. With that, one owner
can do end-to-end bridge work that the split lanes could not.

## Current state (precise, source-of-truth pointers)

- **Capability truth:** `docs/design/capability-status.md` is authoritative — 8
  covered (only **one** user-facing model: the v0.1 univariate Gaussian animal
  model), 34 partial, 4 planned. `docs/design/validation-debt-register.md` is the
  paired evidence ledger.
- **Bridge:** production-covered = the v0.1 Gaussian default (`engine = "fit"`)
  only; ~10 opt-in experimental targets at dense/validation scale; production
  sparse is planned.
- **Julia engine:** `validation_status()` — V0/V1 covered/covered_external,
  everything V2+ partial.

## This session's banked work (stacked PRs — MERGE IN ORDER)

All stacked on the handover branch; each based on the previous, so **merge in
order #98 → A → B → C → D → E → F → G**. R-CMD-check only runs once each base
becomes `main`.

| PR | Content |
| --- | --- |
| #98 | coordination-board stale-row cleanup (R-CMD-check green) |
| #99 (A) | **structured-covariance eigenbasis bridge contract RATIFIED** (doc 29) — unblocks the engine `multivariate_result_payload` widening; V4 SE/LRT honesty |
| #100 (B) | comparator/validation runbooks (MV 2nd-comparator, genomic, marker-scan thresholds; metafounder Γ plan doc 30) |
| #102 (C) | activation plans — non-Gaussian per-record trials (doc 31), RR roadmap (doc 32) |
| #103 (D) | board normalization + cross-lane coordination + **the Codex engine hand-off** |
| #104 (E) | **non-Gaussian per-record varying-trial R side implemented** + pure-R tested (live round-trip is the gate) |
| #105 (F) | **genomic external comparator EXECUTED** (rrBLUP/BGLR agree > 0.999) + V4 gate review (doc 33) |
| #106 (G) | VanRaden `G` formula parity with AGHmatrix (exact) + V4 honesty fixes |

Closed and superseded: **PR #101** (a rogue subagent's unverified non-Gaussian
*activation* against `main`) — its branch is preserved and routed to the engine
work list (slice 18) for verification, not merge.

## The engine work list

`docs/dev-log/handover/2026-06-22-codex-engine-comparator-handoff.md` — slices
13–18, each pointed at its prepared R-side contract/runbook/plan. Now that one
owner does both, these are simply the next engine slices:
13 PEV `:selinv` · 14 second MV comparator (licensed binary, or adopt the
substitutable gate) · 15 **eigenbasis payload widening (unblocked by #99)** ·
16 fitted-Mrode native fixture · 17 post-fit marker-scan entry point ·
18 non-Gaussian per-record live round-trip (R side done in #104).

## Open follow-ups / decisions now owned by one lane

- **V4 gate** (doc 33): make the second same-estimand REML comparator and the
  recovery-gate acceptance **substitutable** (there is no free CRAN
  multivariate-animal-model REML package besides `sommer`, so requiring two hard-
  couples a covered claim to a licensed binary). Plus the compute-only recovery
  broadening under a pre-declared gate.
- **Julia `validation_status()` SE/LRT rows** still say "missing"; the R
  extractors already ship — refresh the twin rows.
- **`HSquared.jl#61` ledger refresh** drafted at
  `docs/dev-log/coordination/2026-06-22-jl61-cross-lane-ledger-refresh-draft.md`.
- **Genomic:** the construction *algorithm* is exactly validated vs AGHmatrix; a
  supplied-p `G` *value* match still needs a supplied-frequency-capable tool.
  Optional: promote the full-unstructured `sommer` comparator from `data-raw` to a
  skip-guarded in-suite test.

## Unified mission control & web surfaces

With one owner over both packages, the status picture must be **merged**, not
R-only. Two things to keep in lockstep:

- **Two doc sites, both kept green and consistent.** `hsquared` publishes a
  **pkgdown** site and `HSquared.jl` publishes a **Documenter** site (both deploy
  to gh-pages; both CI green as of 2026-06-22). Treat them as one documentation
  surface for one project — neither should claim ahead of the other (the same
  covered / partial / planned story on both sites).
- **One merged mission-control dashboard** spanning both lanes, replacing the
  earlier R-only dashboard: the R capability-status counts (8 covered / 34
  partial / 4 planned), the Julia `validation_status` counts (4 covered + 3
  covered-external / 33 partial / 1 planned), the R↔Julia bridge state, the
  capability areas (R surface ↔ Julia engine), and the unified critical path,
  with links to both doc sites. A current snapshot was produced on 2026-06-22.

Action for the consolidated lane: **maintain the single merged mission control**
as the at-a-glance surface and **regenerate it each session** from the
authoritative sources — `docs/design/capability-status.md` (R) and
`HSquared.jl` `validation_status()` (Julia) — so it never drifts from the
ledgers; and keep **both** the pkgdown and Documenter sites building green and
telling the same story. This is now a standing maintenance item, not a one-off.

## How to start (rehydration)

1. `git status --short --branch` in both repos; `gh pr list` / `gh run list`.
2. Read `docs/design/capability-status.md`, `docs/dev-log/coordination-board.md`,
   the latest `docs/dev-log/check-log.md`, this note, and the Codex engine
   hand-off.
3. Merge the stacked PRs #98 → G in order; then start the engine slices (15 is the
   highest-leverage unblock — it activates structured covariance → FA → GLLVM).
4. Put `julia` on `PATH` and confirm the live bridge tests run.

## Bring across the R/Claude operating system (what's working)

These practices and assets carried the R lane; adopt them across **both** repos
(most already exist on the Julia side — run one unified set, don't fork two):

- **The review-lens roster + spawnable subagents.** ~21 named lenses (Ada lead ·
  Shannon coordination · Boole formula · Noether math · Gauss numerics · Fisher
  inference · Curie simulation/tests · Jason scout · Emmy R-architecture · Grace
  CI/release · Hopper R↔Julia bridge · Pat applied-user · Darwin biology ·
  Florence figures · Henderson animal-model · Mendel inheritance · Falconer
  quant-gen · Kirkpatrick G-matrix · Mrode validation-canon · Karpinski
  Julia-perf · Rose systems-auditor). The R repo carries them as spawnable
  subagents in `.claude/agents/`; the Julia repo mirrors the roster. Use the
  lane-routing table (which lens reviews which change class) and run **one**
  roster across both repos.
- **Rose claim-vs-evidence audit — keep it mandatory** before any covered move,
  public claim, or repo-visibility change. It earned its keep this session:
  it caught the AGHmatrix-≠-metafounder-Γ trap, the rogue PR #101
  unverified-activation overclaim, and every agreement-vs-parity distinction.
  Single most valuable practice.
- **The after-task protocol** — 11 fixed sections, validated by
  `~/shinichi-brain/tools/check-after-task.R` — closes every meaningful slice,
  paired with the check-log (exact commands + outcomes) and the coordination
  board.
- **Honest ledgers as the single source of truth:** `capability-status.md` +
  `validation-debt-register.md` (R) and `validation_status()` (Julia); strict
  covered / partial / planned separation.
- **Comparator-evidence discipline:** same-estimand parity vs agreement;
  "missing on host ≠ blocked" (install CRAN comparators and run; reserve
  host-gated for genuinely licensed/registration binaries); never fake a blocked
  run.
- **Repo-visible memory over chat** (board, check-log, recovery checkpoints,
  `decisions/`, `after-task/`); rehydrate from repo state before trusting chat.
- **Workflow:** narrow, reviewable slices; stacked PRs when slices share files;
  local checks over CI (run `document` / `test` / `check` / `pkgdown` and
  `Documenter` locally first, record exact commands in the check-log).
- **Skills (`.claude/skills/`):** `hsquared-rehydrate`, `hsquared-team-dispatch`,
  `after-task-audit`, `rose-pre-public-audit`, and the contract-review skills
  (formula / engine / bridge / pedigree-Ainv / validation-canon / quantgen-scout
  / prose-style). Share one skill set across both repos.

## Discipline to keep

The honest covered/partial/planned separation; no promotion without
implementation + tests + validation + a Rose audit; comparator evidence
distinguishes same-estimand parity from agreement and never fakes a blocked run;
repo-visible memory (board, check-log, after-task) over chat. These carry over
unchanged — they were never about how many lanes there are.

## Sign-off

The R lane is closing with a clean, audited boundary: every slice this session is
banked, Rose-clean, and honest about what is and isn't validated. The bridge is
the highest-value surface in the project — one owner should now own it
end-to-end. Over to the Julia lane.
