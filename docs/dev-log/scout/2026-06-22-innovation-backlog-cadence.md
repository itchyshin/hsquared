# Innovation-backlog triage & scout cadence

Date: 2026-06-22 · Lane: R coordinator (Jason/Ada/Shannon lenses) · Twin gate:
`HSquared.jl#56` (recurring innovation scout cadence).

**Scope note.** This is a **coordination / cadence** record: it triages the
existing innovation backlog and fixes the scout cadence so the next pass is
scoped. It does **not** report new literature findings (no new external search
was run for this note) and it promotes nothing — every backlog item stays
`planned`. New literature/package findings belong in their own dated scout note.

## Current innovation backlog (live issues)

R lane (`itchyshin/hsquared`):

- **#24** augmented AI-REML single-solve for multi-trait REML (Strandén et al.
  2024) — `status:planned`, phase-8, julia-engine.
- **#25** SQUAREM EM accelerator as a generic engine utility — `status:planned`,
  innovation.

Julia twin (`itchyshin/HSquared.jl`):

- **#50** Genetic GLLVM (latent genetic factors for high-dim responses) —
  planned, phase-6 (depends on the FA/eigenbasis bridge #42 + the published
  multivariate target #37).
- **#51** open matrix-free scaling stack (PCG + APY + MC-REML) — planned,
  phase-2 (PCG MME solver already DONE per the twin snapshot; APY + MC-REML +
  matrix-free operator remain).
- **#52** Covariance Reaction Norms (CRN) in sparse REML — planned, phase-3.
- **#55** reduced-rank G & evolvability tooling — planned, phase-4 (evolvability
  functionals already shipped/partial; reduced-rank G is the FA bridge #42).
- **#58** engine perf ideas (augmented AI-REML, SQUAREM, Woodbury low-rank
  Cholesky) — planned, phase-8 (the Julia mirror of R #24/#25).
- **#56** recurring innovation scout cadence — this cadence item.

## Triage (what is gated on what)

- **Unblocked by the 2026-06-22 R ratification (doc 29):** the FA/eigenbasis
  bridge (#42) — and therefore the downstream **#55** reduced-rank G and **#50**
  Genetic GLLVM — now wait only on the engine payload-widening, not on a
  convention decision.
- **Performance backlog (#24/#25/#58/#51 partial):** engine-owned (Codex), and
  several are explicitly phase-8 / phase-2 deferred. These edge into
  performance-claim territory and must be benchmark-gated before any speed claim
  (the standing rule). No R-lane action until the engine lands them.
- **CRN (#52):** phase-3, engine-owned; depends on the random-regression engine
  line (twin #54) maturing first — cross-reference the RR roadmap
  (`docs/design/32-random-regression-r-roadmap.md`).
- **Net:** no innovation-backlog item is R-lane-actionable right now beyond
  keeping the issue ledger and roadmap honest; all are engine-first (Codex) or
  phase-deferred.

## Existing scout notes (do not duplicate)

The `docs/dev-log/scout/` history already covers:

- `2026-06-19-literature-innovation-scout.md` — the broad innovation scan that
  seeded #24/#25/#50-#58.
- `2026-06-20-apy-sparse-ginv-scout.md` — APY / sparse Ginv (feeds #51).
- `2026-06-18-gllvm-la-va-sister-source-scout.md` — GLLVM LA/VA from sister repos
  (feeds #50 and the non-Gaussian line).
- `2026-06-14-wide-response-syntax-scout.md` — wide-response syntax (feeds the
  GLLVM/omics surface).
- `2026-06-21-mi-miss-control-contract.md` — missing-data grammar scout.

A future scout pass should extend these, not restate them.

## Scout cadence (proposed, twin #56)

- **Mechanism:** the Codex app automation `hsquared-weekly-innovation-scout`
  already exists (recorded on the coordination board, branch
  `codex/issue-map-close-20`; R #20 closed). It is the cadence vehicle.
- **Frequency:** weekly is heavier than the backlog churn warrants while the
  programme is engine-first and phase-gated. Proposed cadence: **monthly**, or
  **on-demand before any slice that changes scientific design or a public claim**
  (the AGENTS.md "Jason scout pass" rule for Phase 1+ slices already mandates the
  on-demand case). Record the chosen cadence on twin #56.
- **Each pass should cover:** (1) new methods/papers for the open backlog items
  above; (2) sister-repo deltas (`drmTMB`, `gllvmTMB`, `DRM.jl`, `GLLVM.jl`);
  (3) comparator-tool landscape changes (ASReml/BLUPF90/DMU/WOMBAT/PLINK/GEMMA
  availability, since several validation gates are blocked on these);
  (4) anything that would change a capability claim — flagged to Rose.
- **Output:** a dated `docs/dev-log/scout/` note; issue-ledger updates only;
  no capability promotion without the full evidence chain.

## Boundary

Coordination/cadence only. No new literature findings asserted here, no issue
state changed, no capability/validation/public-claim promotion. The innovation
backlog remains `planned`/phase-deferred and engine-first.
