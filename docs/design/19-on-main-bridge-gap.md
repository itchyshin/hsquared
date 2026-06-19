# 19 — On-main engine vs R-surface gap (WS2 Step 0)

**As of `HSquared.jl origin/main` = `4e8ffde`** ("Merge PR #57: BT1 closeout + process
scaffolding"), verified read-only 2026-06-19. This is the WS2 **Step-0 gate**: it records which
engine functions are on `origin/main`, their `validation_status()` row + status, the R surface
today, and whether R can build the bridge **now** (claiming *experimental/partial*) vs gated on
a twin result-payload change.

> **The twin is actively reshaping `main`** (it advanced abf777d → c4fb442 → 4e8ffde within one
> hour, and closed all 19 open PRs via the trunk merge PR #36). Pin each WS2 slice to a known
> `origin/main` SHA and coordinate the result-payload shape via the bridge-activation issues
> (HSquared.jl#42–#45) before relying on new dict fields.

## Headline correction to the prior snapshot

The earlier Explore snapshot ("`origin/main` = abf777d, Phases 1–4 only; FA/Phase 5 unmerged
drafts") is **stale**. PR #36 landed **Phase 4B (factor-analytic) + Phase 5 (marker scan)**
engine work to `main`, and **Phase 6** non-Gaussian functions are also present. Every WS2
bridge candidate function is now on `origin/main` and exported.

## Honesty status is unchanged

`validation_status()` on `origin/main` still has only **7** non-`partial` rows:
`covered` = V0-LOAD, V1-PED, V1-AINV-TINY, V1-AI-REML; `covered_external` = V1-AINV-MRODE9,
V1-MRODE-FIT, V1-COMPARATORS. Every new capability row (V1-HERIT-CI, V1-SELINV-PEV, V2-GREML,
V2-SSHINV, V3-REPEAT-REML, V4-MV-REML, V4-FA, V5-MARKER-*) is **`partial`**; V5-GENOMIC-QTL is
`planned`. **So R may build these bridges but must surface them as opt-in / experimental.**

## Gap table

| Engine function (on `origin/main`) | Validation row · status | R surface today | R-buildable now? | Mechanism |
| --- | --- | --- | --- | --- |
| `heritability_interval` | V1-HERIT-CI · partial | `heritability()` point only | **Yes (Class A)** | bridge calls the exported fn on the fit; normalize a CI field — #11 |
| `repeatability_interval` | V3-REPEAT-REML · partial | repeatability target, no CI | **Yes (Class A)** | same, on the repeatability target — #12 |
| `prediction_error_variance(...; method=:selinv)`, `reliability` | V1-SELINV-PEV · partial | opportunistic enrichment only | **Yes (Class A)** | call selinv methods on the fit; normalize fields — #21 |
| `fit_gblup_reml` / `fit_snp_blup_reml` | V2-GREML · partial | supplied-variance fitters only | **Yes (Class A)** | route genomic/snp_blup to the `_reml` variant when variances absent — #13 |
| `fit_single_step` / `fit_single_step_reml` | V2-SSHINV · partial | **verified correct (#14)**: supplied `Hinv` → `fit_ai_reml` on the inverse (= ssGBLUP REML), not SNP-BLUP | n/a (no bug) | dedicated `fit_single_step` + `Hinv` construction is a separate planned item |
| `factor_analytic_covariance` + `genetic_structure`/`genetic_loadings`/`genetic_uniqueness` | V4-FA · partial (calibration failed 8/10, 9/10) | bridge rejects non-`unstructured`; reserved extractors error | **Partial (Class B)** | accessors exist; needs the multivariate result payload to expose loadings/uniqueness (twin #42) + failing calibration — #22 |
| `single_marker_scan`/`mixed_model_marker_scan`/`loco_*`, `gwas_table`/`qtl_table`/`eqtl_table` | V5-MARKER-* · partial | reserved extractors error | **No yet (Class B)** | needs the twin's post-fit scan payload (#45) + calibrated thresholds — #23 |
| `fit_laplace_reml`, `laplace_reml_interval`, `NonGaussianFit` | (Phase 6; no committed row yet) | R parser rejects non-Gaussian `family` | **No yet (Class B)** | needs `MarginalMethod` dispatch + `NonGaussianFit` result shape + R `family=` acceptance (twin #44) — #18 |

## WS2 work order

**Class A — R-buildable now (no twin change; R calls the exported fn on the returned fit):**
1. ✅ **#11** `heritability_interval` (experimental CI) — **shipped** `56f8fb5`.
2. ✅ **#14** `single_step` routing — **verified correct, no bug**.
3. ✅ **#12** `repeatability_interval` — **shipped** `e66e648` (experimental).
4. ✅ **(critic's find)** `variance_component_standard_errors()` + `heritability_standard_error()` — **shipped** `4266169` (V1-HERIT-CI names them; experimental).
5. ⏸ **#13** REML genomic variants — **deferred** (ultracode honesty_ok=false + regression; needs the V2-SNPBLUP row updated + the existing supplied-variance test reconciled first).
6. ☐ **#21** PEV/reliability via `:selinv` — ready; modest value (already enriched with the default method), needs a live probe for the method symbol.
7. ☐ **#26** multivariate covariance SEs (`:unstructured`) — ready; must disclaim the failed 6/10 calibration + unstructured-only.

Each: bridge probe (live Julia smoke to confirm signature + return shape against the pinned SHA)
→ impl in `R/julia-bridge.R` (+ `R/extractors.R`) → parity fixture → multi-lens review
(Hopper/Emmy/Fisher/Curie + specialist) → Rose audit → checks → after-task. **Claim stays
`partial`/experimental** (the rows are partial).

**Class B — gated on a twin result-payload / refactor (coordinate via the bridge-activation issues):**
- **#22** structured covariance — twin exposes loadings/uniqueness in the multivariate payload
  (#42) + V4-FA calibration.
- **#23** post-fit marker scans — twin post-fit scan payload (#45) + calibrated thresholds.
- **#18** non-Gaussian LA/VA — twin `MarginalMethod` refactor + `NonGaussianFit` payload (#44).

## Caveat on Class A

The engine functions are exported, but R should call them **on the returned fit object** (as the
bridge already does for opportunistic PEV/reliability enrichment), not assume `result_payload()`
includes the new fields — the twin's "promote into the standard payload" steps (#42/#43) are
still open. A live bridge probe per slice confirms the exact call + return shape before R commits
to a normalization.
