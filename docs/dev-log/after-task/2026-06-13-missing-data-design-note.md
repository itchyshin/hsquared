# Missing-data handling design note (planning)

Date: 2026-06-13

Active lenses: Jason (sister-repo reuse scout), Mendel/Noether/Boole (design
synthesis), Rose (claim audit). Spawned subagents: yes — workflow
`missing-data-reuse-scout` (5 agents: one reader per sister repo + synthesis,
run `wjk8w2xxe`).

Current lane: coordinator / docs. No twin edits, no code, no gate impact.

## Goal

Execute the standing missing-data directive's *planning* request (ROADMAP.md,
commit `acc54af`): plan model-based missing-data handling for missing responses
and missing covariates, reusing the sister teams (`drmTMB`/`gllvmTMB`,
`DRM.jl`/`GLLVM.jl`) rather than reinventing. This was chosen as the next safe,
non-pre-empting autonomous slice while the v0.1 fit gate waits on maintainer
decisions: it is doc-only, advances a standing directive, helps the twin, and
makes no API or capability commitment.

## What changed

- `docs/design/08-missing-data-plan.md` (new) — planned design: two regimes
  (observed-`y` mask for missing responses; latent-variable Laplace integration
  with a level-aware predictor model for missing covariates), a proposed R
  syntax surface (`mi(x)`, `miss_control()`, `impute=`) with alternatives, the
  planned Julia engine responsibilities, a sister-repo reuse map, a phased plan
  (M0–M3), and nine open questions for the maintainer.
- `ROADMAP.md` — pointer from the standing directive to the new note.
- `docs/dev-log/coordination-board.md` — slice row.

## Method / honesty

The reuse scout read all four sister repos read-only and the synthesis grounded
the design in their shared mechanism (observed-`y` mask; family-dispatched
latent integration; level-aware predictor covariance; frequentist EBLUP
vocabulary). One self-caught provenance correction: the
`GLLVM.jl/src/missing_predictor_fiml.jl` kernel the scout initially cited is
**not in the current checkout** — recorded in the note as a FORWARD/UNVERIFIED
reference, not a present asset. Every grammar/control choice is flagged
`PROPOSAL` for maintainer sign-off; nothing is committed as API.

## Verification

- `docs/design/08-missing-data-plan.md` is a repo design doc, not a package
  vignette or pkgdown article, so it is outside the R CMD check / pkgdown build.
  No code changed.
- Rose claim audit: status is PLANNED; no capability claim; README, DESCRIPTION,
  and vignettes were not touched, so no public-claim leak.

## Boundary

This is planning only. No `mi()`/`miss_control()` exists in `R/`; no engine
support exists in `HSquared.jl`. Missing-data handling is sequenced after the
v0.1 fit gate and must not contaminate the v0.1 REML promotion predicate. The
engine-contract payload additions are twin-lane work to be designed via the
shared bridge contract.

## Next actions (maintainer / twin)

1. Maintainer: rule on the nine open questions (syntax, control object, level
   mapping, defaults, output vocabulary, identifiability).
2. Twin: confirm the `GLLVM.jl` mi-FIML provenance and record the planned
   payload additions in `03-engine-contract.md`.
3. Implementation (M1: masked responses) waits on the v0.1 fit gate opening.
