# START HERE — session handoff 9 (2026-06-20, end of the s6 capability + cleanup run)

Resume rule: **live repo state wins over this doc.** Run `hsquared-rehydrate`,
then read the coordination board (newest rows) + latest `check-log` entries + this
file. Supersedes handoff-8.

## Inherit (carry forward)

- **Goal:** finish the package(s); **communicate and bridge the R and Julia lanes**;
  keep the mission-control widget current. Drive order: Julia unlocks → bridge →
  docs/validation. **Ultracode on** (use Workflows; adversarially verify every
  substantive slice).
- **Discipline (per slice):** implement → adversarially verify (Workflow) →
  live-verify if engine-coupled → `air` + `document`/`test`/`check_pkgdown`/`check`
  → check-log → board → after-task → commit (plain imperative, no Co-Authored-By) →
  push → record CI → post to twin. Only `covered` is "working"; promotions
  twin-gated; never plot raw factor loadings; **lane discipline — never edit
  `HSquared.jl`** (bridge + GitHub coordination only).
- **Live bridge recipe (Julia off-PATH):**
  ```sh
  PATH="$HOME/.juliaup/bin:$PATH" \
  HSQUARED_JULIA_PROJECT="/Users/z3437171/Dropbox/Github Local/HSquared.jl" \
  NOT_CRAN=true Rscript -e 'devtools::load_all(); testthat::test_file("tests/testthat/test-<x>.R")'
  ```
  Run heavy live work one process per file. **Trust `rcmdcheck` / the default
  testthat reporter — NOT a hand-rolled `as.data.frame(test_file())` count** (that
  masked a failing test this session).

## Current state (repo = truth)

- R `main` clean @ **`f5e00b7`** (CI-record tip), synced; CI green throughout
  (pkgdown `27892365616`). `rcmdcheck(--no-manual)` **0/0/0**; `check_pkgdown`
  clean. Live on the bridge: `test-gwas` 59, `test-single-step-construct` 54,
  `test-nongaussian` 39, `test-binomial-counts` 20, `test-snp-blup` 40,
  `test-julia-bridge` 96, `test-plot-data-parity` 32 — all green.
- Twin `HSquared.jl` `main` @ **`0e5018f`** — landed `breeding_values_plot_data`
  (#116, last #93 preparer), HSquaredMakieExt (#117), genetic-GLLVM
  `GeneticGLLVMFit` + per-trait REML (#50, internal), production-sparse (#6),
  CPU baseline. `fit_snp_blup_reml` / `fit_gblup_reml` / binomial `n_trials` /
  variational marginal all exported.

## What landed this session (s6) — all on `main`, pushed, CI green

| Slice | What | Verify |
| --- | --- | --- |
| LOCO `gwas()` (#4) | `gwas(method="loco", marker_groups=)` — per-group genomic LOCO | 5-lens; non-square-Z regression |
| single_step bundle shorthand | `single_step(1\|id)` resolves ped+genotypes from `hs_data()` (closes doc-25 deferral) | 6-lens; caught a shipped failing test |
| VA non-Gaussian marginal | `engine_control marginal="variational"`/`la`/`va`; ELBO honestly tagged | 5-lens; answered twin #44 |
| **binomial cbind-counts (BUG FIX)** | `cbind(succ,fail)+binomial()` was silently a 2-trait Gaussian → now binomial-counts GLMM | 6-lens; correctness-first |
| SNP-BLUP REML (#13) | `genomic(markers)` estimates σ²g/σ²e when unsupplied (`fit_snp_blup_reml`) | 5-lens; caught a real REML=FALSE bug + AIC df gap |
| Henderson PEV unconditional | dropped the legacy probe; PEV/reliability always attached (dense) | live |
| GBLUP↔SNP-BLUP atom | validation: GEBV equivalence cor 0.999998 (ridge accounts for residual) | live |
| breeding_values_plot_data | consume the last #93 preparer — **all 7 consumed, #93 closed R-side** | live parity 1e-8 |

A **4-agent cross-lane opportunity scout** ranked the backlog and drove this run.

## Issue hygiene + twin coordination (this session)

- **Closed:** hsquared #13 (SNP-BLUP REML done + premise corrected), #17 (FA-G EM
  note), #18 (LA/VA dispatch). **Commented/scoped:** #23 (gwas scan done; narrow to
  map-table), #21 (PEV), #10 (MV validation boxes).
- **Twin posts:** #44 (VA + binomial-counts answer both pending R-coordination items
  + per-record `n_trials` request), #45 (marker-scan hand-off complete), #50 (exact
  GLLVM exports R needs: `fit_gllvm_laplace_reml` + `GeneticGLLVMFit` +
  `genetic_gllvm_result_payload`), #48 (LOCO), #61 (VA), #93 (R-closed).

## Next backlog (ranked, from the scout plan)

1. **A3 — attach engine `*_plot_data` at fit time.** All 7 preparers are consumed
   via recompute + parity; the bridge does **not** attach payloads at fit time yet,
   so recompute is the live path. Wiring the attach (in the result normalizers,
   gated on bridge-available, keeping recompute fallback) flips figures to
   engine-payload and is the one remaining #93-adjacent R item. Live-probe the
   engine NamedTuple keys vs the autoplot auto-detect names first.
2. **Validation depth** — more recovery/comparator atoms (e.g. seeded SNP-BLUP-REML
   recovery in `data-raw/`; the GBLUP↔SNP-BLUP equivalence atom landed this session).
3. **Genetic-GLLVM R bridge** — deferred until the twin exports the fitter +
   `genetic_gllvm_result_payload` (requested on #50). Big new model class.
4. **Twin-gated (don't start):** calibrated GWAS (#48), FA structured covariance
   (#22/#42), production sparse, metafounder/FA payloads (#61).
5. **Pre-existing gap (spawned task):** `formula_status()` doesn't enumerate the
   single_step construction/bundle or binomial-counts forms.

## Cross-lane threads open

- **#61** joint critical path; **#48** calibrated GWAS; **#42/#22** FA structured;
  **#50** genetic-GLLVM exports (R bridge waits on these); **#44** per-record
  binomial `n_trials` (engine feature request from this session).
