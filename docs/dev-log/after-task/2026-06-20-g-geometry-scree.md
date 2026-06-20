# After-task — g_geometry eigenvalue scree figure (2026-06-20 s5)

## Goal

Realize the cataloged-but-unbuilt `g_geometry` figure (plotting standard §1) as a
rotation-invariant eigenvalue **scree**, consuming the landed engine
`genetic_pca_plot_data` preparer with an `eigen_G()` recompute fallback.

## Shipped

- **`R/autoplot.R`** — `autoplot(fit, "g_geometry")`: a bar scree of the genetic
  eigenvalues (variance per axis) with % variance-explained labels. Auto-detects
  `object$result$genetic_pca_plot_data`; recomputes from the fit's `G` via
  `eigen_G()` otherwise. **Axis directions / loadings are never drawn** (the §2
  honest-status: rotation-arbitrary, span-ambiguous under repeated eigenvalues).
  New `type = "g_geometry"` in the `autoplot.hsquared_fit` enum + Details.
- **Tests** — `test-autoplot.R`: scree values == `eigen(G)`, variance shares sum
  to 1, §3 binding-rule meta (`rotation_status = "rotation_invariant"`), univariate
  error, payload consumption, and the guard/edge cases (see Verification).
- **`test-plot-data-parity.R`** — live: engine `genetic_pca_plot_data` eigenvalues
  == `eigen(G)`; `is_eigenstructure_not_loadings`/`rotation_invariant` TRUE; a
  marshalled payload consumed end-to-end through `autoplot`.
- **Docs** — standard §1 catalog row (g_geometry now built; axis directions never
  drawn) and the capability-status visualization row updated.

## Honesty

- The scree shows ONLY rotation-invariant eigenvalues + % variance explained — no
  eigenvectors, loadings, or axis directions (the reason g_geometry was previously
  "plot planned"). Stated in the subtitle, `hsquared_meta$notes`, and the docs.
- The payload path now enforces BOTH `rotation_invariant` and
  `is_eigenstructure_not_loadings` (§3): a payload that disclaims eigenstructure
  status falls through to the PSD-gated recompute rather than being drawn.
- A non-PSD payload (negative eigenvalue) draws the raw (negative) bar as an honest
  signal but **omits** the percent-variance labels and flags "non-positive-definite
  G" — the recompute path is already PSD-gated.
- Payload consumption is forward-looking (the bridge does not attach the payload at
  fit time yet); recompute via `eigen_G()` is the live path.

## Verification

- **Adversarial verify** (Workflow `wf_bef66f21-dfb`, Florence/Curie) caught a
  **blocker** — the payload branch did not enforce `is_eigenstructure_not_loadings`,
  so a loadings payload would be drawn as a scree (the exact leak the figure exists
  to avoid). Fixed + tested. Applied the non-PSD-label should-fix and Curie's
  coverage gaps (loadings-flag fallback, non-PSD, ve/axis length-mismatch, all-zero
  NA, payload-vs-recompute parity).
- `air` clean; `devtools::document()`; `test-autoplot` all pass;
  `pkgdown::check_pkgdown()` clean; `rcmdcheck(args="--no-manual")` **0/0/0**.
- **LIVE** (`test-plot-data-parity`): **21/21**.

## Cross-lane

- No twin edit; consumes the landed `genetic_pca_plot_data` preparer. The §6 naming
  map already lists it.

## Next

1. Single-step H⁻¹ construction bridge (#3) — engine `single_step_inverse` /
   `fit_single_step_reml` proven; the R wiring (pedigree + genotyped-subset markers)
   is the work.
2. LOCO / single-marker `gwas()` (#4).
3. RR-variance / rr-surface / rr-eigenfunctions consumers when the `value` rename
   and those figures land.
