# START HERE — session handoff 6 (2026-06-20 s4, the long autonomous run)

Resume rule: **live repo state wins over this doc.** Run `hsquared-rehydrate`,
then read the coordination board (newest rows) + latest `check-log` entry + this
file. Supersedes handoff-5.

## Inherit (carry forward)

- **Goal:** work autonomously toward finishing the package(s); keep the
  mission-control widget current; **communicate and bridge the R and Julia
  lanes** (the maintainer asks both lanes the same questions). Drive order:
  Julia unlocks → bridge → docs/validation.
- **Mission control widget:** gitignored at `.mission-control/status.json`;
  refresh it as you go (Python: load JSON, update fields, write, validate).
- **Live bridge recipe (Julia off-PATH):**
  ```sh
  PATH="$HOME/.juliaup/bin:$PATH" \
  HSQUARED_JULIA_PROJECT="/Users/z3437171/Dropbox/Github Local/HSquared.jl" \
  NOT_CRAN=true Rscript -e 'devtools::load_all(); testthat::test_file("tests/testthat/test-<x>.R")'
  ```
  Run heavy live work one process per file; save results before teardown.

## What landed this session (s4) — all on `main`, pushed, CI green

| Area | What | Commits |
| --- | --- | --- |
| Validation | **Multivariate t=2 validation**: 100-rep cold-start recovery (no detectable bias) + full-unstructured `sommer` comparator (≤8e-5) vs the twin `phase4_multitrait_parity` target. V4-MV-REML kept partial. | `94e94d3` |
| Cross-lane | **Metafounder Q1–Q4 contract** answered on #61; `metafounder()` marker reserves `Gamma=`. | `47d46e1` |
| Engine prototype | **Batched marker-scan** (exact 46.8× drop-in for `_mixed_marker_scan_stats`) → twin #51. | `0d7f635` |
| Engine prototype | **AI-REML hardening** (guard `cholesky(check=true)` PD-failure → clear error) → twin #58. | `41079a2` |
| Housekeeping | **Issue-ledger audit** (2-lens Workflow): R #10 progress comment, R #23 `blocked`→dropped; twin coordination comments #49/#41/#53. | — |
| **Viz** | **ggplot2 visualization layer** — `autoplot()` for variance/h² forest, EBV caterpillar (PEV bands), rotation-invariant G heatmap, gwas Manhattan, **reaction_norm** trajectories; `hs_recovery_forest()`; `theme_hsquared()`. brms/bayesplot-style, consistent with drmTMB/gllvmTMB. + "Visualizing an animal model" article (renders figures on the site). | `fd6140e`, `149cd81`, `5c22444` |
| Bridge flip | **`rr_eigenfunctions()`** extractor (engine PR #88), live-verified == engine to ~1e-15; dropped the now-**ratified** rr() grammar caveat; reconciled the 21-nongaussian doc. | `59fef9b`, `71e3b63` |

Each slice: live-verified where engine-coupled, `rcmdcheck` 0/0/0, `check_pkgdown`
clean, recorded in check-log + board + after-task, posted to the twin on #61.

## Twin state + cross-lane decisions (on #61)

Twin `main` advanced to **PRs #87–#91**: genetic-GLLVM scope (#87), rr_eigenfunctions
(#88), **`metafounder_animal_model`** MME solve (#89, animal-only descriptive),
closeout v8 (#90), **RR plotting layer (#91)**. The twin posted a cross-lane
**reconciliation** (most of #61's "pending payload" items are already flipped).

**Decisions I posted (unblock the twin):**
- **FA structured payload: invariants-only** (eigenbasis/evolvability/correlations,
  never raw loadings). Twin will ship the eigenbasis payload.
- **Metafounder: option (a)** — combined `(m+n)` inverse entry point (matches A4:
  `metafounder_effects()` + `gamma(fit)` + negative-F handling). Twin builds the
  entry point + `:metafounder` payload + `metafounder_parity/` fixture.
- **Non-Gaussian method wire-token: freeze** `"laplace"`/`"variational"`; R maps
  user-facing `method="LA"/"VA"`. **Binomial-with-trials:** in near-term R scope.

## Next backlog (ranked)

1. **LOCO / single-marker `gwas()`** (R-owned flip; engine `loco_mixed_model_marker_scan`
   + `single_marker_scan(fit, markers)` exported). NOTE: meaningful LOCO needs
   per-group relationship precisions (`loco_relationship_precisions`) — for the
   pedigree-based `gwas()` this is genomic; check the helper before wiring. The
   uncorrected `single_marker_scan` is the cleaner first flip (a contrast to the
   relatedness-corrected `gwas()`).
2. **Single-step H⁻¹ construction bridge** — **engine contract PROVEN this session**
   via a probe: `fit_single_step_reml(y,X,Z,Ainv,A,G,genotyped_rows)` with `G=A₂₂`
   (all genotyped) == `fit_ai_reml(Ainv)` to **0.00e+00** (vc/EBV/loglik). The R
   wiring is the work: it must combine the **pedigree payload path** (id/sire/dam →
   A/Ainv, like `animal()`) with a **genotyped-subset marker path** (markers rownames
   ⊂ pedigree ids; do NOT require observed ⊆ markers). New parser branch + payload
   builder + `target="single_step_construct"` + the `G=A₂₂` reduction live-test.
3. **Reaction-norm autoplot is done**; consider an eigenfunction autoplot panel.
4. **Await twin payloads:** `:metafounder` (option a) → wire `metafounder_effects()`
   unpack + parity; FA eigenbasis → wire onto `eigen_G()`/evolvability.
5. **Twin-gated (don't start):** calibrated GWAS (#48), production sparse fitting,
   correlated direct-maternal.

## Discipline (unchanged)

Per-slice: implement → adversarially verify (Workflow) → live-verify if
engine-coupled → `air format` + `document/test/check_pkgdown/check` → check-log →
board → after-task → commit (plain imperative, no Co-Authored-By) → push → record
CI → post to twin #61. Honesty: only `covered` is "working"; everything else is
experimental/partial; promotions are twin-gated.
