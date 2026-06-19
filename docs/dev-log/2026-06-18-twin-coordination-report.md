# Twin coordination report — HSquared.jl as of 2026-06-18

Read-only cross-lane scout (`wf_69b0c5de-446`, 6 lenses: Shannon, Kirkpatrick,
Hopper, Gauss, Curie, Karpinski). The R lane made **zero edits** to the twin.
Purpose: map `main` vs pending, find the highest-leverage unblock for the R lane,
and hand off twin-lane items precisely.

## Twin `main` map (corrects stale R-board references)

- `origin/main` tip = **`abf777d`** ("Link Documenter from repository landing
  page", #21) — one docs-only commit ahead of `f9da6bb`. Older R notes citing
  `f9da6bb`/`100adbe` as the tip are stale.
- **On main** (exported engine): `fit_animal_model`, `fit_sparse_reml`,
  `fit_ai_reml`, `fit_variance_components`, `fit_diagnostics`, `fit_gblup`,
  `fit_snp_blup`, `fit_repeatability_reml`, `fit_two_effect_reml`,
  `fit_multivariate_reml`. So Phases 1-4 are all on main.
- `validation_status()` on main: V0-LOAD / V1-PED / V1-AINV-TINY / V1-AI-REML
  **covered**; V1-AINV-MRODE9 / V1-MRODE-FIT / V1-COMPARATORS **covered_external**;
  all V2/V3 + V4-MV-REML/V4-MULTIVARIATE **partial**; V5-GENOMIC-QTL **planned**.
- **The R surface is consistent with main** — every twin entrypoint the R bridge
  calls is on main. No shipped-surface overlap/collision risk.

## BREAKTHROUGH — the single highest-leverage unblock: land PR #17

**`#17 phase4b-factor-analytic-g` → main** is the move. It is a **clean
fast-forward of main (0 behind / 24 ahead), green on all CI + Documenter**, and
delivers exactly the engine API the R lane already *reserves*:
`fit_multivariate_reml(...; genetic_structure = :diagonal|:lowrank|:factor_analytic, rank = K)`
plus `genetic_structure()` / `genetic_loadings()` / `genetic_uniqueness()`
accessors, and new `V4-FA` + `V5-MARKER-FIXED` validation rows.

The R lane reserves precisely this and **guardrails it off today**
(`R/julia-bridge.R:1361-1395` accepts only `genetic_structure = "unstructured"`;
`R/hs_control.R:90`; `R/model-spec.R:534`). **The moment #17 lands on main, the
next R bridge slice is unblocked**: lift the guardrail, add the structured-
covariance payload + `loadings()`/`specific_variance()`/`latent_breeding_values()`/
`eigen_G()` extractors (already reserved as planned errors). Until then the R
lane MUST keep erroring on `diag/lowrank/fa` — surfacing them now would claim
capability not on Julia main.

**Lane discipline: this is a Julia-lane merge decision. The R lane must not
self-merge twin engine source.** Kirkpatrick flags two small twin-side pre-merge
fixes for #17: `genetic_uniqueness` for low-rank should return `nothing` not
`zeros(t)` (`mv.jl:444`); reword the eigen-G claim to experimental.

## Phase 5 GWAS/QTL/eQTL tower (#18-#35) — NOT landable yet

A 16-PR **stacked chain** (each based on the previous branch, not on main),
**all draft**, with **no GitHub CI checks reported on any** (`gh pr checks` =
"no checks reported"), and **#28 is CONFLICTING/DIRTY**. Karpinski: zero quality
tooling (no Aqua/JET/`@inferred`/`@allocated`; test target is `Test` only). It
cannot be assessed for merge until restructured.

- **Hopper's minimal-slice recommendation**: split the **fixed-effect
  single-marker GWAS path** (`single_marker_scan` + `marker_scan_table` +
  `gwas_table`) off the bottom of the stack as a standalone PR targeting main,
  ahead of the mixed-model/LOCO/QTL/eQTL/FA work. That is the smallest landing
  that yields a real R `marker_scan()` capability. Caveat: engine p-values are
  uncalibrated supplied-variance Wald — surface honestly.

## Numerical readiness (Gauss) — twin-lane

- No high-`cond(A)` / deep-inbreeding stress test exercises the dense
  `inv(Symmetric(Ainv))` paths (`likelihood.jl:131,770,1068`; `multivariate.jl`
  ~614; `genomic.jl:515`). The documented `inv(Ainv)` conditioning caveat is
  untested — add a stress test before any production-scale claim.
- **Flag**: the multivariate recovery calibration did not pass on the predeclared
  seed sets (unstructured). R already labels multivariate `partial` /
  not-recovery-validated, so the R claim stays honest — but this gates any future
  promotion to covered.
- Low-rank / factor-analytic boundary fragility when a trait's genetic variance
  collapses — relevant once #17 lands.

## Integrity / honesty (Curie) — one item is R-routable via handoff

- **V1-AI-REML "250-animal" integrity bug is RESOLVED on the validation ladder**:
  the string is gone from `src/validation_status.jl` on main and
  `test/runtests.jl:201` guards its absence. The repeated cross-lane re-flags are
  stale.
- **The one remaining instance** is `docs/design/03-engine-contract.md:277`
  (also branch `:454`), which still asserts "ratio ~0.99 on a 250-animal
  simulation". Curie independently recommended the same reword the maintainer
  requested. **Handoff recorded** in the coordination board (replace with the
  committed finite-difference REML Hessian check, ~8%, `test/runtests.jl:2789-2799`;
  keep the Gaussian-LMM-exact caveat). Julia-lane edit (or maintainer-authorized).

## Housekeeping (Julia lane)

- `#16 docs-api-engine-docstrings` is non-draft, CI+Documenter green, mergeable
  (7 behind → trivial rebase) — ready to land independently.
- Deletable merged branches: `origin/phase2-genomic-engine`,
  `origin/v01-gate-validation-status`, `origin/roadmap-status-reconcile`.
  PRs #12/#14/#15 already closed.

## R-lane action map

| Twin event | R-lane next slice (ready) |
| --- | --- |
| PR #17 lands on main | Lift the `genetic_structure` guardrail; surface `cov = diag()/lowrank()/fa()` + loadings/specific-variance/latent-BV/eigen-G extractors (all reserved). **Highest value.** |
| Fixed-effect single-marker GWAS PR lands | Surface `marker_scan()` opt-in with honest uncalibrated-Wald wording. |
| Multivariate recovery calibration passes (twin) | Promote multivariate evidence toward covered. |
| (now) | Continue R-safe finishing; no new capability is honestly surfaceable until the above land. |
