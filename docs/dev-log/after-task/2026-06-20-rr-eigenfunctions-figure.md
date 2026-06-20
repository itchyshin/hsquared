# After-task — rr_eigenfunctions figure (2026-06-20 s5)

## Goal

Build the cataloged-but-unbuilt reaction-norm eigenfunctions figure (plotting
standard §1), completing the random-regression figure family (trajectories +
eigenfunctions; surface remains the one unbuilt §1 figure).

## Shipped

- **`R/autoplot.R`** — `autoplot(fit, "rr_eigenfunctions")`: faceted `psi_j(t)`
  curves (eigenfunctions of `K_g` as covariate functions), labelled by % genetic
  variance per axis. Auto-detects `object$result$rr_eigenfunctions_plot_data`
  (recompute via `rr_eigenfunctions()` fallback). New `type` in the enum + Details.
- **Standard** (`docs/design/24-plotting-standard.md`) — §3 type enum + binding set
  (+`rr_eigenfunctions`), §1 catalog row, §6 naming map. R-proposes process (§7).
- **Tests** — payload-consume (`test-autoplot`), recompute on the real RR fit
  (`test-random-regression`: values == `rr_eigenfunctions()$eigenfunctions`,
  rotation-invariant meta), and a live consume leg (`test-plot-data-parity`).

## Honesty

- §2 caveat carried in the subtitle + `hsquared_meta$notes`: eigenfunction signs
  are arbitrary and the curves are span-ambiguous under repeated eigenvalues —
  do not over-read. `rotation_status="rotation_invariant"` (now in the §3 binding
  set, enforced in tests).
- Supplied-`K_g` descriptive (not an estimate). Payload path forward-looking
  (recompute is the live path); the bridge does not attach payloads yet.

## Verification

- `air` clean; `devtools::document()`; `test-autoplot` + `test-random-regression`
  all pass; `pkgdown::check_pkgdown()` clean; `rcmdcheck(args="--no-manual")`
  **0/0/0**.
- **LIVE** (`test-plot-data-parity`): **25/25** — the marshalled m×k eigenfunctions
  matrix consumed through `autoplot` == the engine matrix. Rendered figure verified
  (axis facets + % variance labels).
- (The engine vs R eigenfunction math is also separately live-parity-tested in
  `test-random-regression.R` to ~1e-15.)

## Cross-lane

- Standard amendment posted via the doc (R-proposes a new figure, §7); the twin
  mirrors via its Makie extension + the already-landed `rr_eigenfunctions_plot_data`.

## Next

1. Single-step construction bridge (`docs/design/25`).
2. LOCO / single-marker `gwas()` (#4); `rr_surface` (the last unbuilt §1 figure).
