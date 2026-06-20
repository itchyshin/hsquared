# START HERE — session handoff 7 (2026-06-20, end of the long s4 run)

Resume rule: **live repo state wins over this doc.** Run `hsquared-rehydrate`,
then read the coordination board (newest rows) + latest `check-log` entry + this
file. Supersedes handoff-6.

## Inherit (carry forward)

- **Goal:** finish the package(s) toward completion; **communicate and bridge the
  R and Julia lanes** (the maintainer asks both lanes the same questions); keep the
  mission-control widget current. Drive order: Julia unlocks → bridge →
  docs/validation. Ultracode is on (use Workflows; adversarially verify).
- **Plotting is a maintainer priority:** "R sets the plotting standard, Julia
  mirrors it." That standard is now set — see `docs/design/24-plotting-standard.md`.
- **Mission control widget:** gitignored at `.mission-control/status.json`; refresh
  as you go (Python: load JSON, edit fields, write, validate).
- **Live bridge recipe (Julia off-PATH):**
  ```sh
  PATH="$HOME/.juliaup/bin:$PATH" \
  HSQUARED_JULIA_PROJECT="/Users/z3437171/Dropbox/Github Local/HSquared.jl" \
  NOT_CRAN=true Rscript -e 'devtools::load_all(); testthat::test_file("tests/testthat/test-<x>.R")'
  ```
  Run heavy live work one process per file; save results before teardown.

## Current state (repo = truth)

- R `main` clean @ **`54becf7`**, synced with origin; CI green (pkgdown + pages).
  22 commits this session (`ad6584f..54becf7`). `rcmdcheck` 0/0/0; `check_pkgdown`
  clean throughout.
- Twin `HSquared.jl` `main` @ **`2fefd31`** (PRs #87–#94): genetic-GLLVM scope (#87),
  `rr_eigenfunctions` (#88), RR plot-data (#91), G-geometry plot-data (#92),
  `metafounder_animal_model` MME solve (#89, animal-only descriptive), closeout v8
  (#90), **plotting plot-data contract + R-twin alignment (#93/#94)**.

## What landed this session (s4) — all on `main`, pushed, CI green

| Area | What | Commit(s) |
| --- | --- | --- |
| Validation | Multivariate t=2: 100-rep cold-start recovery (no detectable bias) + full-unstructured `sommer` comparator (≤8e-5). V4-MV-REML kept partial. | `94e94d3` |
| Cross-lane | Metafounder Q1–Q4 contract (#61); `metafounder()` reserves `Gamma=`. | `47d46e1` |
| Engine prototype | Batched marker-scan (exact 46.8×) → twin #51. | `0d7f635` |
| Engine prototype | AI-REML hardening (guard cholesky PD-failure) → twin #58. | `41079a2` |
| Housekeeping | Issue-ledger audit: R #10 progress, R #23 unblocked; twin #49/#41/#53 coordination. | — |
| **Viz layer** | ggplot2 `autoplot()`: variance/h² forest, EBV caterpillar, rotation-invariant G heatmap, **reaction_norm** trajectories, Manhattan; `hs_recovery_forest()`; `theme_hsquared()`; **`hsquared_meta`** honest-status attr; "Visualizing an animal model" article. | `fd6140e`,`149cd81`,`5c22444`,`be65f81` |
| Bridge flip | `rr_eigenfunctions()` (engine PR #88), live-verified == engine to ~1e-15; dropped the now-ratified rr() caveat; reconciled the 21-nongaussian doc. | `59fef9b`,`71e3b63` |
| **Plotting standard** | `docs/design/24-plotting-standard.md` (R-authored; figure catalog, honest-status contract, `hsquared_meta` schema, data/naming contract). 4-lens reviewed; h² interval aligned (raw + boundary annotate, no clamp). | `ce572cf`,`9ef3027` |

## ACTIVE cross-lane threads (do these first)

### 1. `HSquared.jl#93` — plotting plot-data contract (TOP, answer now)
The twin (Hopper/Shannon/Florence) read `R/autoplot.R` end-to-end vs her landed
`*_plot_data` preparers (sets A/C/D landed; B planned) and **will adapt the engine
payloads to the R `autoplot` tidy contract.** She posted **8 structured questions
for the R lane** on #93:
1. Confirm `rr_genetic_variance_plot_data` field rename `genetic_variance → value`.
2. Melt ownership (engine ships wide, R melts — the current g_matrix idiom — vs engine ships long).
3. Set-B interval knob: `level=0.95` only, or also expose the method (delta vs AI)? **And: clamp h² to [0,1] engine-side or return raw?** ← reconcile with our standard.
4. `hsquared_meta` sourcing: engine emits a parallel `*_meta` NamedTuple, or R keeps asserting it?
5. Bridge-vs-fallback: R auto-consumes the payload when present, else recomputes (parity test as safety net)?
6. Parity-test home (R / Julia / both).
7. g_pca biplot arrow-scaling (engine ships `loadings_scaled = V·√λ`; enough?).
8. A `breeding_values_plot_data` preparer, or keep rank R-side?
**Divergence to settle:** our standard + `R/autoplot.R` now surface the **raw** h²
interval + annotate a `[0,1]` crossing (no silent clamp); the twin's set-B note
clamps h² to `[0,1]`. Pick one (recommend: raw + annotate, matching the engine's
`heritability_interval` boundary-throw discipline). Reply on the mirrored ledger.

### 2. `HSquared.jl#61` — decisions posted, awaiting her payloads
I posted (and she's acting on): **FA invariants-only** (she ships the eigenbasis
payload), **metafounder option (a)** combined `(m+n)` inverse (she builds the entry
point + `:metafounder` payload + `metafounder_parity/` fixture), **freeze method
wire-token** `"laplace"`/`"variational"`. When those payloads land: wire the
metafounder unpack (`metafounder_effects()`/`gamma(fit)`) + the FA eigenbasis onto
`eigen_G()`/evolvability.

## Next backlog (ranked)

1. **Answer `#93`'s 8 questions** + settle the h² clamp divergence (cross-lane, fast).
2. **Consume the landed preparers + the live parity test** (§7 of the standard;
   the twin's §5 risk-3 mitigation): switch `autoplot` set-C/RR to consume the
   bridge `*_plot_data` (auto-detect, recompute fallback) and add a skip-guarded
   `hs_rr_variance_values == rr_genetic_variance` parity test. **Engine-ready now.**
3. **Single-step H⁻¹ construction bridge** — **engine contract PROVEN** via a probe
   (`fit_single_step_reml(y,X,Z,Ainv,A,G,genotyped_rows)` with `G=A₂₂` all-genotyped
   == `fit_ai_reml(Ainv)` to 0.00e+00). The R wiring is the work: combine the
   **pedigree payload path** (id/sire/dam → A/Ainv, like `animal()`) with a
   **genotyped-subset marker path** (markers rownames ⊂ pedigree ids; do NOT require
   observed ⊆ markers). New parser branch + payload builder +
   `target="single_step_construct"` + the `G=A₂₂` reduction live-test. Complex —
   a focused fresh-context build.
4. **LOCO / single-marker `gwas()`** — `loco_mixed_model_marker_scan` +
   `single_marker_scan` exported; LOCO needs per-group precisions
   (`loco_relationship_precisions`, genomic) — check before wiring.
5. **Await twin payloads** (metafounder option-a, FA eigenbasis, set-B
   `variance_components_plot_data`), then wire the unpacks.
6. **Twin-gated (don't start):** calibrated GWAS (#48), production sparse fitting,
   correlated direct-maternal.

## Discipline (unchanged)

Per-slice: implement → adversarially verify (Workflow) → live-verify if
engine-coupled → `air format` + `document/test/check_pkgdown/check` → check-log →
board → after-task → commit (plain imperative, no Co-Authored-By) → push → record
CI → post to twin (#61 / #93). Honesty: only `covered` is "working"; everything
else experimental/partial; promotions twin-gated; never plot raw factor loadings.
