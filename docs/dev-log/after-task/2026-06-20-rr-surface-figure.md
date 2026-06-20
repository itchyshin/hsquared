# After-task — rr_surface figure; plotting catalog complete (2026-06-20 s5)

## Goal

Build the last cataloged-but-unbuilt §1 figure — the reaction-norm genetic
covariance/correlation surface — completing the plotting standard's figure catalog.

## Shipped

- **`R/autoplot.R`** — `autoplot(fit, "rr_surface")`: the genetic covariance
  surface `S(s,t) = phi(s)' K_g phi(t)` over the covariate grid as a tile heatmap;
  `correlation = TRUE` draws the genetic-correlation surface (unit diagonal).
  Auto-detects `rr_covariance_surface_plot_data` (recompute via the internal
  Legendre design + `rr_covariance()` fallback). New `type` + `correlation` arg.
- **Standard** — §1 catalog row (built), §3 binding set now fully enforced
  (`rr_surface` moved from "guarded when it ships" to enforced), §7 parity note.
- **Tests** — payload-consume (`test-autoplot`), recompute + correlation-option
  unit-diagonal (`test-random-regression`), live marshalled-consume leg
  (`test-plot-data-parity`).

## Honesty

- Supplied-`K_g` descriptive; `rotation_status = "rotation_invariant"` (the genetic
  covariance function is basis-rotation-invariant). Payload path forward-looking;
  recompute is the live path. The correlation surface errors clearly if a covariate
  point has non-positive genetic variance.

## Verification

- `air` clean; `devtools::document()`; `test-autoplot` + `test-random-regression`
  all pass; `pkgdown::check_pkgdown()` clean; `rcmdcheck(args="--no-manual")`
  **0/0/0**; **LIVE** `test-plot-data-parity` **26/26** (surface == engine).

## Milestone

**The §1 plotting catalog is complete** — every cataloged figure is built:
variance, breeding_values, g_matrix (+ low-h² flag), g_geometry scree,
reaction_norm, rr_eigenfunctions, rr_surface, Manhattan, QQ (+ λGC),
recovery_forest. Each engine `*_plot_data` preparer that has landed is consumed
with a live parity guard.

## Next

1. Single-step construction bridge (`docs/design/25`) — the ranked capability work.
2. LOCO / single-marker `gwas()` (#4). No cataloged figures remain.
