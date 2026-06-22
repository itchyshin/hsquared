# Draft refresh for HSquared.jl #61 (joint cross-lane critical path)

Date: 2026-06-22 · Lane: R coordinator (Shannon/Ada lenses) · Status: **DRAFT —
not posted.**

This is a proposed refresh of the body of the Julia twin's coordination issue
`itchyshin/HSquared.jl#61` ("[from R lane] Joint critical path"). The R lane does
**not** edit the Julia repository or post to its issues (lane discipline); this
draft is for the maintainer or the Codex/Julia lane to review and post. Posting
is the user's call.

## Why a refresh is needed

A read of the live Julia repo (main `38286b1`/#154) during the 2026-06-22
cross-lane planning found that **#61's body cites stale repository heads**: it
references twin head `6d14df5` and R head `9fa9193`. Both are behind:

- **Julia `main` is now `38286b1`** (`Correct non-Gaussian bridge gap status
  (#154)`).
- **R `main` is now `d4ec85d`** (`Sync Julia non-Gaussian status correction
  (#97)`).

The #61 **priority ordering remains current and authoritative** — only the head
references and a few "since then" status lines are stale. This draft updates the
references and records the R-lane progress made since #61 was written, without
changing the agreed priorities.

## Proposed edits to #61 (surgical)

1. **Update the head references**: `twin 6d14df5 → 38286b1 (#154)`;
   `R 9fa9193 → d4ec85d (#97)`.
2. **Add a "Since #61 was written (R lane, 2026-06-22)" note** capturing the
   cross-lane items the R lane has now banked or queued (all docs/contract/plan;
   no capability promotion):
   - **FA/eigenbasis convention ratified on the R lane.** The structured-
     covariance eigenbasis-only bridge payload contract is ratified in
     `hsquared` `docs/design/29-structured-covariance-eigenbasis-bridge-contract.md`
     — this is the R ack the Julia FA decision
     (`HSquared.jl/docs/dev-log/decisions/2026-06-19-fa-rotation-convention.md`)
     was holding for. **The engine may now widen `multivariate_result_payload`
     to `:lowrank`/`:factor_analytic` (eigenbasis + invariants + invariant-only
     SEs, never raw loadings).** (twin #42 / R #22)
   - **Comparator/validation runbooks queued** for the R-lane-owned external
     evidence: a multivariate second same-estimand comparator runbook
     (ASReml-R/DMU/WOMBAT), a genomic external-comparator runbook
     (AGHmatrix/rrBLUP/BGLR/sommer/JWAS), a marker-scan threshold-calibration
     plan, and a metafounder Γ-estimation + external-validation plan. All are
     protocols/plans; every binary-dependent leg is blocked on the local host →
     a capable host / Codex. (twin #49/#48/#41/#53)
   - **R-activation plans queued**: per-record varying-trial Binomial activation
     (twin #44) and the random-regression R next-increments roadmap (PE term,
     heterogeneous residual, curve-valued EBV PEV, multivariate RR) (twin #54).
   - **SE/LRT row refresh is the Julia lane's**: the R extractors
     `covariance_standard_errors()` / `covariance_structure_lrt()` already ship;
     the twin `validation_status()` V4-MV-REML / V4-FA rows still list SEs/LRT as
     "missing" and should be refreshed on the Julia side (twin #41/#47).
3. **Re-affirm "R is not the bottleneck"**: the bridge-activation asks (#42-#45
   family) are shipped or prepared on R main; the open cross-lane gates are
   engine slices (payload widening, PEV `:selinv`, fitted-Mrode fixture,
   marker-scan entry point) and comparator execution on a capable host.

## Boundary

- This draft posts nothing and changes no issue state.
- It proposes only reference/status corrections to #61; it does not change the
  agreed cross-lane priorities.
- No capability/validation/public-claim promotion in either lane.
