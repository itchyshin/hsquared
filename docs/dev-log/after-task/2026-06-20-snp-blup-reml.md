# After-task — REML-estimated SNP-BLUP (2026-06-20 s6, closes hsquared#13 build half)

## Goal

From the cross-lane opportunity scout (ranked A2): surface
`HSquared.fit_snp_blup_reml` (now on twin main) so `genomic(1 | id, markers = M)`
with `target = "snp_blup"` estimates the genomic and residual variances by REML
instead of requiring the user to supply them. The scout corrected the stale #13
premise — the R `genomic` target already REML-estimates via `fit_ai_reml` on a
built/supplied `Ginv`, so `fit_gblup_reml` is redundant; only the `snp_blup` path
was supplied-variance-only.

## Shipped

- **`R/hsquared.R`** — the `snp_blup` dispatch routes on whether
  `variance_components` is supplied: NULL → `hs_fit_julia_snp_blup_reml_payload`
  (REML), supplied → `hs_fit_julia_snp_blup_payload` (unchanged). The
  `REML = FALSE` exemption is now conditional (see Honesty/B1).
- **`R/julia-bridge.R`** — `hs_fit_julia_snp_blup_reml_payload` calls
  `fit_snp_blup_reml(y, X, markers_rec)`, recomputes per-individual GEBV at the
  fit's allele frequencies, and extracts estimated σ²g/σ²e + loglik + converged.
  The shared `hs_normalize_julia_snp_blup_result` gained
  `provenance`/`converged`/`loglik` params (provenance `estimated_snp_blup_reml`,
  `optimizer_status`); the REML path sets `df = ncol(X) + 2` so `AIC`/`BIC` work.
- **Tests** (`test-snp-blup.R`) — pure-R routing test (off-bridge: the old
  supplied-variance gate is gone); live REML test (interior σ²g/σ²e, converged,
  AIC finite, estimate ≠ the (1,1) default, parity vs a direct `fit_snp_blup_reml`
  to 1e-6); the supplied-variance live test unchanged.
- **Docs** — capability-status, NEWS, `validation_status()` (label + evidence +
  claim boundary), `?hs_control`, and the model-status / genomic-prediction /
  fitting-models / qtl-gwas vignettes.

## Honesty

- Experimental, opt-in, dense/validation-scale, not comparator-validated, not the
  default (V2-SNPBLUP partial). No engine edit (lane discipline).
- Adversarial verify (5-lens Workflow): Hopper **clean** (bridge marshalling + the
  σ²g = σ²a·k scaling correct). FIX-FIRST caught:
  - **B1 (real bug):** the `REML = FALSE` exemption was unconditional for
    `snp_blup`, but the no-variance branch genuinely REML-estimates — so
    `REML = FALSE` + omitted variances was silently accepted (the exact failure
    the gate exists to prevent). Now `snp_blup` is exempt only when variances are
    supplied; the REML branch rejects `REML = FALSE`.
  - **Fisher:** the REML path left `df` unset, so `AIC`/`BIC` returned NA → set
    `df = ncol(X) + 2` (fixed effects + two estimated VCs).
  - **B2/B3 + majors (stale honesty surfaces):** `?hs_control` and
    `validation_status()` still said "supplied-variance only / REML planned"; four
    vignettes lumped `snp_blup` with the supplied-variance paths. All reconciled;
    a Rose-principle sweep confirmed no remaining stale text.

## Verification

- `air`; `devtools::document()`; pure-R `test-snp-blup` **14/0**; **LIVE** **37/0/0/1**
  on the bridge; `pkgdown::check_pkgdown()` clean; `rcmdcheck(args="--no-manual")`
  **0/0/0**.

## Next

1. **Close hsquared#13** (the build half is done; correct the stale premise).
2. A3 — attach engine `*_plot_data` payloads at fit time (#93 close-out).
3. A4 — Henderson MME PEV/reliability unconditional. Validation depth.
