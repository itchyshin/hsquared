# After-task report - Structured-covariance eigenbasis bridge ratification (PR A)

Date: 2026-06-22

Branch: `codex/structured-cov-ratification` (stacked on `codex/claude-cross-lane-handover`/PR #98)

Active lenses: Boole, Noether, Kirkpatrick, Fisher, Hopper, Rose

Spawned subagents: Rose (rose-systems-auditor) — independent claim-vs-evidence audit

Current lane: R / coordinator (docs + contract; no R code change)

## 1. Goal

Batch 1 of the 20-slice goal — slices 1, 2, 5. Ratify, on the R lane, the
structured-covariance eigenbasis bridge contract so the Julia engine can widen
`multivariate_result_payload` to `:lowrank`/`:factor_analytic` (twin #42, held
pending R ack), reconcile the R structured-covariance docs to that convention,
and verify the R SE/LRT honesty claim. No capability promotion.

## 2. Implemented

- **Slice 1 (ratify):** new `docs/design/29-structured-covariance-eigenbasis-bridge-contract.md`
  — R-lane ack mirroring the twin decision
  (`HSquared.jl/docs/dev-log/decisions/2026-06-19-fa-rotation-convention.md`):
  pins exactly the rotation-invariant fields the bridge MAY carry (G/R,
  correlations, h², diag(G)/tr(G), eigenvalues, sign-canonicalized principal
  axes, evolvability family, Ψ for FA, structure/rank/n_params/loglik, SEs on
  invariants only) and the fields it MUST NOT carry (raw Λ as identified,
  SEs/CIs on Λ or eigenvectors, "factor loads on X" claims). Records the R ack
  that unblocks the engine payload-widening.
- **Slice 5 (lowrank/fa prose review):** reconciled
  `docs/design/18-structured-covariance-r-control.md` — status note now points to
  the ratified convention (doc 29) and narrows the remaining gate to engine
  payload-widening + recovery/comparator; the Result Payload section now lists
  rotation-invariant eigenbasis fields and explicitly fences raw
  `genetic_loadings` (display-only, no SE, never a bridged biological axis).
  Updated `capability-status.md` row 44 to cite the both-lanes ratification
  (doc 29) and the narrowed gate.
- **Slice 2 (V4 SE/LRT honesty):** verified — no R change needed. The R
  extractors `covariance_standard_errors()` (`R/extractors.R:948`) and
  `covariance_structure_lrt()` (`R/extractors.R:998`) already exist, are
  exported (`NAMESPACE:155-156`), and are consumed by the bridge
  (`R/julia-bridge.R:1087`); `capability-status.md` rows 32/36 already credit
  them honestly. The stale "SEs/LRT missing" wording is on the **Julia**
  `validation_status()` rows (V4-MV-REML/V4-FA), which is the twin's to refresh —
  routed to Codex (twin #41/#47).

## 3a. Decisions and Rejected Alternatives

- **Separate ratification doc (29) rather than only editing doc 18.** The
  contract is a discrete cross-lane gate the Julia decision explicitly waits on;
  a dedicated, citable file is cleaner for the twin to reference than a buried
  section. Doc 18 is reconciled to point at it.
- **Did not touch R code.** Slice 2 confirmed the SE/LRT surface already exists;
  editing extractors would need live tests (Codex lane) for no gain.
- **Kept the row `partial`.** Ratifying a contract is not evidence; promotion
  still needs engine payload-widening + recovery + comparator. The twin's
  per-seed calibration (FA ~8/10, LR ~9/10) has not passed.
- **Stacked on PR #98** so the shared `check-log`/`board`/`capability-status`
  accumulate conflict-free across the batch (merge order #98→A→B→C→D).

## 4. Files Touched

- `docs/design/29-structured-covariance-eigenbasis-bridge-contract.md` (new)
- `docs/design/18-structured-covariance-r-control.md` (status note + payload section)
- `docs/design/capability-status.md` (row 44 gate wording)
- `docs/dev-log/check-log.md` (entry)
- `docs/dev-log/coordination-board.md` (row)
- `docs/dev-log/after-task/2026-06-22-structured-cov-ratification.md` (this file)

No `R/`, `tests/`, `man/`, NAMESPACE, or DESCRIPTION change.

## 5. Checks Run

- `Rscript --vanilla -e 'pkgdown::check_pkgdown()'` (result in check-log).
- after-task validator on this report (result in check-log).
- `git diff --check`.
- Extractor/NAMESPACE existence greps (slice 2 evidence) recorded above.

## 6. Tests of the Tests

No behavioral tests (docs/contract only). The honesty claim in slice 2 is
falsifiable and was checked: greps confirm the SE/LRT extractors are defined and
exported and the bridge consumes the engine SE field — if they were absent, the
"already surfaced" claim would have failed the grep.

## 7a. Issue Ledger

Advances `hsquared#22` / twin `HSquared.jl#42`, `#37`, `#61`. No issue closed,
no GitHub state changed (issue edits are a separate coordination slice). No
capability/validation promotion.

## 8. Consistency Audit

- Swept `docs/design/` for lowrank/fa/loadings prose; doc 18 was the one surface
  implying raw loadings would be bridged — reconciled. Doc 14
  (factor-analytic-production-plan) and doc 20 (em-initializer) describe
  engine/estimation, not the bridge payload, so they stay as-is; doc 29 is the
  payload authority they will defer to.
- Confirmed the new doc's exposable/withheld lists match the twin decision
  item-by-item (no R/Julia drift).
- Confirmed capability-status row 44 still says `partial` and still fences the
  formula grammar.

## 9. What Did Not Go Smoothly

Nothing notable. The twin decision file is precise, so the ratification was a
faithful mirror rather than a fresh derivation.

## 10. Known Residuals

- Engine payload-widening itself is twin/Codex work (twin #42); this is only the
  R ack that unblocks it.
- Julia `validation_status()` SE/LRT "missing" wording still needs a twin-side
  refresh (Codex; twin #41/#47).
- Structured-fit recovery/comparator evidence remains open — no promotion.

## 11. Team Learning

When a twin decision is "decided, gated on the other lane's ack," the unblocking
move is a small, citable ratification doc that mirrors the decision's
exposable/withheld lists exactly — not a re-derivation. Verify "already
surfaced" honesty claims with a grep before asserting them in status docs.
