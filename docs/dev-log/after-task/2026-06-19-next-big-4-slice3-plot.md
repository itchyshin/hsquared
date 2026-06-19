# After-task — Next-big-4 slice 3 (#30): base-R plot.hsquared_fit (2026-06-19)

## Task goal

Program-2 workstream #2 (UX/figures): the first Florence figures — a base-graphics `plot()`
method for `hsquared_fit`, surfacing the variance components (with experimental SE whiskers when
present) and a residuals-vs-fitted panel. No new dependency.

## Active lenses / agents

- Lenses: Florence (figure design), Pat (reader), Emmy (S3), Fisher (uncertainty framing), Rose
  (honesty). No spawned subagents (bounded R-ownable feature).
- Lane: R.

## Files changed

- `R/plot.R` — new `plot.hsquared_fit(x, type = c("variance", "residuals"), ...)` + internal
  `hs_plot_variance()` / `hs_plot_residuals()`. Base graphics only (`graphics::`/`grDevices::`).
- `tests/testthat/test-plot.R` — draws to a null device; asserts the call runs and returns the fit
  invisibly, with and without SE whiskers, plus graceful errors when fields are absent.
- `_pkgdown.yml` — `plot.hsquared_fit` in the reference index.
- `NEWS.md` — dev-section bullet (#30).
- `man/plot.hsquared_fit.Rd` — generated.

## Design

- `type = "variance"` (default): variance-component point plot; when the fit carries the
  experimental `variance_component_se`, it adds `+/- 1.96 * SE` whiskers and labels the panel
  experimental/asymptotic. Otherwise plain points.
- `type = "residuals"`: residuals (`y - fitted`) vs fitted, with a zero reference line.
- Errors clearly when the needed fields are absent (no silent empty plot).

## Checks

- `air format` clean; `devtools::document()` (registered `S3method(plot, hsquared_fit)`);
  `devtools::test()` 836 pass / 0 fail / 0 warn / 27 skip; `pkgdown::check_pkgdown()` clean;
  `devtools::check(--no-manual)` 0/0/0 (see CI-evidence note). pkgdown deploys on push.

## Public claim audit (Rose lens, applied)

- No capability claim. The SE whiskers reuse the already-experimental `variance_component_se`
  surface (engine row V1-HERIT-CI, partial) and the panel is labelled experimental/asymptotic.
  The plot only draws fields a fit already carries; absent fields raise a clear error.

## Tests of the tests

- The error tests guard against drawing when variance components / fitted values are absent; the
  with/without-SE tests confirm both code paths.

## Known limitations / next actions

- Base graphics only (no ggplot2 dependency); richer displays (EBV accuracy, G-matrix heatmaps)
  can follow if a plotting dependency is later adopted.
- Next program-2 R-ownable slices: #26 (multivariate covariance SEs), #29 (gryphon vignette), #33
  (comparator policy), #32 (Mrode beyond 3.1).
