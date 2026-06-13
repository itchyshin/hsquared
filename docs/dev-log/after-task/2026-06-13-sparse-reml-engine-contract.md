# Sparse REML Bridge Contract Memory (B5)

Date: 2026-06-13

Active lenses: Shannon, Hopper, Lovelace, Rose, Pat.

Spawned subagents: none (coordinator-lane documentation; self-audited).

Current lane: coordinator.

## Goal

Record the agreed sparse-REML bridge contract in the contract of record so the
next session — or the Julia twin — can rehydrate it from disk, closing the
Phase B sparse-REML surfacing arc (B2 path -> B3 provenance -> B4
estimate-recovery -> B5 contract memory).

## Files Changed

- `docs/design/03-engine-contract.md` — new "Sparse REML Estimator Path
  (experimental)" section: the R `engine_control = list(target = "sparse_reml",
  initial, iterations)` surface, the Julia `fit_sparse_reml(spec; initial,
  iterations)` entry point, the estimated-variance result shape, the
  `variance_components_source = "estimated_sparse_reml"` provenance tag, and the
  ownership/boundary rules (Julia-owned; R reads exports + `validation_status()`,
  never edits Julia source; gated on the twin's green signal; experimental,
  opt-in, not the default, not production / AI-REML / ASReml parity).

## Verification

- `git diff --check`: clean (documentation-only, coordinator lane).
- Remote (commit `9e12821`): R-CMD-check `27468956169`, pkgdown `27468956186`,
  Pages `27468994647` all passed.

## Public Claim Audit (Rose)

The section documents the contract that B2-B4 implement and validate; it
introduces no new capability and no new public fitting claim. All boundary
language matches the registers (`capability-status`, `validation-debt`,
`06-public-claims`) and `validation_status()`.

## Phase B sparse-REML arc — complete

- B0 Mrode-style supplied-variance fixture closeout (`a437feb` / `262812e`).
- Phase A Claude agent roster + readiness (`b43b682` / `55b7da2`).
- B1 Phase B frontier record (`d2b12a8`).
- B2 fenced opt-in sparse-REML bridge path (`6add692` / `b3a007a`).
- B3 estimated-vs-supplied variance provenance (`503734e` / `f35dc35`).
- B4 sparse REML estimate-recovery fixture (`8a2009a` / `2bb4f10`).
- B5 sparse-REML engine-contract memory (`9e12821` / this evidence commit).

## Next Actions

1. Notify GitHub issues #6/#7 and the Julia twin that the R lane surfaces
   `fit_sparse_reml` behind the fenced `sparse_reml` target with provenance,
   estimate-recovery evidence, and a recorded contract.
2. Promote the sparse-REML path to a public-facing claim only once the twin's
   `validation_status()` marks `fit_sparse_reml` green.
3. Open next frontier when ready (fitted-Mrode + external comparator → production
   sparse PEV/reliability), coordinated with the twin per ROADMAP.
