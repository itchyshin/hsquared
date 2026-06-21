# START HERE — session handoff 8 (2026-06-20, end of the s5 plotting-consumer run)

Resume rule: **live repo state wins over this doc.** Run `hsquared-rehydrate`,
then read the coordination board (newest rows) + latest `check-log` entry + this
file. Supersedes handoff-7.

## Inherit (carry forward)

- **Goal:** finish the package(s); **communicate and bridge the R and Julia lanes**
  (the maintainer asks both lanes the same questions); keep the mission-control
  widget current. Drive order: Julia unlocks → bridge → docs/validation. Ultracode
  on (use Workflows; adversarially verify).
- **Plotting standard:** `docs/design/24-plotting-standard.md` (R-authored; the
  Julia lane mirrors). The plotting-consumer arc is now **complete** (see below).
- **Live bridge recipe (Julia off-PATH):**
  ```sh
  PATH="$HOME/.juliaup/bin:$PATH" \
  HSQUARED_JULIA_PROJECT="/Users/z3437171/Dropbox/Github Local/HSquared.jl" \
  NOT_CRAN=true Rscript -e 'devtools::load_all(); testthat::test_file("tests/testthat/test-<x>.R")'
  ```
  Run heavy live work one process per file; save results before teardown.
- **Discipline (per slice):** implement → adversarially verify (Workflow) →
  live-verify if engine-coupled → `air` + `document`/`test`/`check_pkgdown`/`check`
  → check-log → board → after-task → commit (plain imperative, no Co-Authored-By) →
  push → record CI → post to twin. Only `covered` is "working"; promotions
  twin-gated; never plot raw factor loadings.

## Current state (repo = truth)

- R `main` clean @ **`5f0e25f`** (CI-record tip, VA marginal), synced; CI green
  throughout (pkgdown `27889972721`). `rcmdcheck(--no-manual)` 0/0/0;
  `check_pkgdown` clean; live `test-single-step-construct` **54/54**, `test-gwas`
  **59/59**, `test-nongaussian` **39/39** on the bridge.
- **s6 (this session):** (1) LOCO gwas landed — `gwas(method = "loco",
  marker_groups = chrom)` completes #4 (live dimension probe resolved the design
  Q; 5-lens verify added a non-square-Z regression; doc 26 IMPLEMENTED).
  (2) `single_step(1 | id)` `hs_data()` bundle shorthand landed — resolves
  pedigree + genotypes from the container (closes the doc-25 deferral); 6-lens
  verify caught + fixed a shipped failing test (a `fixed=TRUE`/backtick mismatch
  that an `as.data.frame(test_file)` summary had masked — trust rcmdcheck) + a
  stale `?single_step` roxygen + a misleading bare-call error.
  (3) **Variational (VA) non-Gaussian marginal** landed — `engine_control =
  list(target = "nongaussian", marginal = "variational")` (aliases `la`/`va`)
  surfaces the engine's VA/ELBO marginal, answering the twin's "pending R-lane
  coordination" method-string item (no engine edit — the engine pre-built the
  R-name map). 5-lens verify: Hopper+Curie clean; fixed a stale-claim blocker +
  the ELBO-scale honesty surface + a Rose-principle sweep of "Laplace-only" text
  across 6 files. Next non-Gaussian bridge slice: Binomial(n-trials) (engine-ready).
- Twin `HSquared.jl` `main` @ **`4559f16`** — landed `variance_components_plot_data`
  (set B, #95), plus the earlier RR/G-geometry/g-correlation preparers (#88/#91/#92)
  and the #93/#94 plotting coordination.

## What landed this session (s5) — all on `main`, pushed, CI green

| Area | What | Commit |
| --- | --- | --- |
| Cross-lane | Answered twin **#93**'s 8 plotting plot-data questions + settled the h² clamp divergence (raw + annotate, no clamp); fixed a `reaction_norm` meta §3 self-violation | `878638c` |
| Bridge (viz) | Consume `genetic_correlation_plot_data` in `autoplot("g_matrix")` + **low-h² cell flag** + live parity | `a9173dc` |
| Bridge (viz) | Consume `variance_components_plot_data` (set B) in `autoplot("variance")` forest + live parity | `df54258` |
| Bridge (viz) | New `autoplot("g_geometry")` **eigenvalue scree** (rotation-invariant; no loadings) + live parity | `70a8731` |
| Bridge (viz) | Consume `rr_genetic_variance_plot_data` in `autoplot("reaction_norm")` (rename-robust) + **the #93 Q6 RR parity test** | `34074f3` |
| Bridge (viz) | New `autoplot(scan, "qq")` QQ + genomic-inflation lambda_GC (Manhattan/QQ dispatch) | `ba0bb67` |
| Bridge (viz) | New `autoplot(fit, "rr_eigenfunctions")` (rotation-invariant ψ_j(t) curves) + #93 Q6-style parity | `df7ef4a` |
| Bridge (viz) | New `autoplot(fit, "rr_surface")` covariance/correlation surface — **completes the §1 figure catalog** | `9edc726` |
| Audit | Rose session-close honesty audit (CLEAN) + under-claim/NEWS reconciliation | `be43091` |
| Coordinator | **Closed the #93 loop** (all 4 preparers consumed, 24/24 live parity) + the **single-step construction R-wiring build-spec** (`docs/design/25`), live-confirmed | `1c96f86` |

**Plotting-consumer arc is COMPLETE:** all four landed `*_plot_data` preparers
(genetic_correlation, variance_components, genetic_pca, rr_genetic_variance) are
consumed via auto-detect + recompute fallback, each with a skip-guarded live
R↔engine parity guard in `tests/testthat/test-plot-data-parity.R`. The bridge does
**not** attach payloads at fit time yet, so recompute is the live path (stated
everywhere); the engine status flags (`rotation_invariant`,
`is_eigenstructure_not_loadings`, `interval_status`) are **enforced** R-side.
**The full §1 figure catalog is now built** (variance, breeding_values, g_matrix +
low-h², g_geometry, reaction_norm, rr_eigenfunctions, rr_surface, Manhattan, QQ +
λGC, recovery_forest) — no cataloged figures remain.

## Ranked #3 DONE — single-step H⁻¹ construction LANDED (s5, commit 80d27cf)

`single_step(1 | id, pedigree = ped, markers = M)` + `target = "single_step_construct"` now builds H⁻¹ engine-side and fits by REML (capability-status partial(R); doc 25 IMPLEMENTED; live reorder + differs-from-pedigree guards green). DO FIRST next: LOCO/single-marker `gwas()` (#4).

## (historical) the single-step build-spec

**`docs/design/25-single-step-construction-bridge.md`** is a complete, live-confirmed
R-wiring spec for the single-step H⁻¹ **construction** bridge
(`single_step(1 | id, pedigree = ped, markers = M)` → `target =
"single_step_construct"`). The engine contract is PROVEN and the exact command
sequence was live-confirmed this session (`additive_relationship`→A,
`fit_single_step_reml(y,X,Z,Ainv,A,G,g)` with G=A₂₂ all-genotyped ==
`fit_ai_reml` → **max|ΔVC| = 0.0**; engine fns verified exported). The build is now
mechanical: parser (§2) → `genotyped_rows` alignment (§3, the crux) → payload (§4)
→ bridge command (§5) → live reduction + alignment tests (§6). Honesty/risk in
§7/§8.

## Next backlog (ranked)

1. **DONE — `docs/design/25` single-step construction** landed (commit `80d27cf`);
   capability-status is now `partial (R)`. Remaining single-step follow-ups: the
   `hs_data()` pedigree shorthand (deferred), large-pedigree sparse `A`, and the
   twin-gated BLUPF90/AGHmatrix comparator to promote past `partial`.
2. **DONE — LOCO `gwas()`** (#4 complete, commit `a448f79`). The design question
   is resolved (`docs/design/26`): a live dimension probe proved the LOCO precision
   enters the `Ainv` slot, so it is built from **animal-level** markers
   (`n_animals²`) while the scan tests **record-level** markers (`Z·M`); the
   pedigree fit's `σ²a/σ²e` are reused (a single supplied σ — per-group VC
   re-estimation is out of the engine contract, so the genomic-vs-pedigree scale
   mismatch is caveated, not re-estimated). `gwas(method = "loco", marker_groups =
   chrom)` is live-verified (incl. a non-square-`Z` regression). The only remaining
   marker-scan work is twin-gated: calibration (#48) and a genomic-VC LOCO variant
   (would need a genomic fit + per-group σ, changing the `gwas(fit, …)` contract).
2b. **Plotting figures: DONE** — the full §1 catalog is built (s5). The only
   remaining plot-data parity gap is `breeding_values_plot_data`, which awaits its
   engine preparer (a #93 ask); wire it when the twin lands it.
3. **Await twin:** the §6 naming-map confirm + the optional `genetic_variance →
   value` rename (the RR consumer is already rename-robust, so non-blocking);
   metafounder option-(a) + FA-eigenbasis payloads (#61) → wire the unpacks.
4. **Twin-gated (don't start):** calibrated GWAS (#48), production sparse fitting,
   correlated direct-maternal, FA structured (loadings) fits.

## Cross-lane threads open

- **#93** (plotting plot-data contract): R side **done** — all preparers consumed +
  Q6 RR parity landed (`issuecomment-4760095710`). Ball with the twin: confirm the
  §6 naming map + the `value` rename when convenient.
- **#61** (joint critical path): metafounder/FA payloads pending; R surfaces are
  pre-staged.
