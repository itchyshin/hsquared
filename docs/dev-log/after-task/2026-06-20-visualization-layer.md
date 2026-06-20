# After-task — ggplot2 visualization layer (2026-06-20 s4, maintainer-directed)

## Goal

Maintainer asked whether hsquared should have a brms/bayesplot-style figure
capability (like the drmTMB/gllvmTMB sisters are getting) to visualize results.
Answer: yes, strongly. Decisions taken (via AskUserQuestion): **ggplot2** engine,
**in-package `autoplot()`** methods designed for later extraction, and **all four**
figure families.

## Shipped (`fd6140e`)

`R/autoplot.R` + `tests/testthat/test-autoplot.R` (12 tests):

- `autoplot(fit, "variance")` — variance-component **and** per-trait `h²` forest
  with experimental 95% intervals (`± 1.96·SE`, labelled asymptotic/REML).
- `autoplot(fit, "breeding_values")` — sorted EBV caterpillar with `± 1.96·√PEV`
  bands; faceted by trait for multivariate fits.
- `autoplot(fit, "g_matrix")` — **rotation-invariant** genetic-correlation heatmap
  (raw factor loadings are never plotted — the ratified cross-lane convention).
- `autoplot(gwas_result)` — Manhattan plot carrying the uncalibrated-significance
  banner (gate HSquared.jl#48).
- `hs_recovery_forest()` — known-truth recovery (bias `± 2·MCSE`; intervals
  covering zero = no detectable bias).
- `theme_hsquared()` — exported shared theme.

ggplot2 + stats added to `Imports`; `_pkgdown.yml` Visualization group; the base-R
`plot()` method is unchanged. Helpers are modular (tidy df -> ggplot) for later
extraction into a shared viz package (matching the maintainer's intent to do this
across hsquared/drmTMB/gllvmTMB).

## Honesty

Figures are uncertainty-first and carry their own experimental fences (h²/variance
SEs labelled experimental/asymptotic; gwas significance labelled NOT
genome-wide-calibrated; G shown as rotation-invariant correlations only). No new
capability is claimed — these render the quantities the fit already carries.

## Verification

- **LIVE render** of all five figures from REAL fits (univariate + multivariate +
  gwas via the live Julia bridge; recovery forest from the real s4 recovery
  numbers) -> `/tmp/hsq-figs/*.png`, visually QA'd — all correct.
- `air format`; `devtools::document()`; `test-autoplot` 12/12; `rcmdcheck` 0/0/0
  (fixed one non-ASCII `²` -> `²`); `check_pkgdown` clean.
- Florence-led scout of the four sister repos (drmTMB/gllvmTMB/DRM.jl/GLLVM.jl)
  informed the conventions (Confidence Eye, rotated loadings, covariance tables).

## Cross-lane

Visualization is a shared concern — the maintainer is asking the Julia twin the
same question. Next: share the figure conventions (and the rotation-invariant
rule) with the twin on #61 so the R and Julia figure layers stay consistent.

## Next

A worked "Visualizing an animal model" vignette; extend to reaction-norm ribbons
and an evolvability rose; consider factoring the modular helpers into a shared
package across the three repos.
