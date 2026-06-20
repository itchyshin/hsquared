# After-task — reaction_norm consumer + #93 Q6 RR parity test (2026-06-20 s5)

## Goal

Complete the plotting-consumer arc: make `autoplot(fit, "reaction_norm")` consume
the landed engine `rr_genetic_variance_plot_data` preparer, and deliver the live
R↔engine RR parity test the twin asked both lanes to co-own on #93 Q6. The handoff
held this on the `genetic_variance → value` rename; resolved by making the consumer
rename-robust rather than waiting.

## Shipped

- **`R/autoplot.R` `hs_autoplot_reaction_norm()`** — auto-detects
  `object$result$rr_genetic_variance_plot_data` (covariate + genetic-variance +
  heritability) when the user has not passed a custom grid (`at`); recomputes via
  `rr_genetic_variance()`/`rr_heritability()` otherwise. **Rename-robust**: reads
  `value` (the #93-agreed field) or the current `genetic_variance`.
- **`tests/testthat/test-plot-data-parity.R`** — the **#93 Q6 RR parity guard**:
  engine `rr_genetic_variance_plot_data` `v_g(t)` == R `hs_rr_variance_values()` on
  a seeded `K_g` / standardized grid (skip-guarded live).
- **`tests/testthat/test-autoplot.R`** — payload-consumption + rename-robustness
  tests (payload-only fits, so consumption is proven: recompute would error).

## Honesty

- Payload consumption is forward-looking (the bridge does not attach
  `rr_genetic_variance_plot_data` at fit time yet); recompute is the live path.
- Rename-robustness is the honest way to lift the handoff's "hold until rename":
  the consumer cannot break whether the field is `value` or `genetic_variance`.
- The reaction-norm honest-status is unchanged (descriptive supplied-`K_g`;
  `h²(t)` can overstate without a permanent-environment term).

## Verification

- `air` clean; `devtools::document()` no man change; `test-autoplot` all pass;
  the recompute-path reaction_norm test (`test-random-regression.R`) still green;
  `pkgdown::check_pkgdown()` clean; `rcmdcheck(args="--no-manual")` **0/0/0**.
- **LIVE** (`test-plot-data-parity`): **24/24** (incl. the RR parity).
- Focused Curie review (no blockers; branch logic sound): applied both should-fix coverage gaps (the `at`-forces-recompute bypass guard + the recompute-path value check are now tested) and the rename-precedence / partial-payload / live-marshalled nits.

## Cross-lane

- Delivers #93 Q6 (the shared RR parity fixture). All four landed plot-data
  preparers (genetic_correlation, variance_components, genetic_pca,
  rr_genetic_variance) are now consumed with a live parity guard each.

## Next

1. Single-step H⁻¹ construction bridge (#3) — the remaining ranked capability.
2. LOCO / single-marker `gwas()` (#4).
