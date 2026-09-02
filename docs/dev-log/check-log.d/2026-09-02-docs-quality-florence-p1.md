# 2026-09-02 — Florence P1 docs figures (pkgdown)

- Branch: `cursor/docs-quality-060-20260902` (continues draft PR #150 after P0).
- Lane: `cursor:hsquared-docs-quality-p1` (vignettes/, man/figures/, pkgdown/, docs/dev-log/). G10 vignette lease clear.
- Added: F4 `man/figures/twin-bridge.svg` → `fitting-models.Rmd`; F2 `man/figures/g0-rg-teaching.svg` + `autoplot(..., "g_matrix")` mock → `g-matrix-interpretation.Rmd` / callout `multivariate.Rmd`; remaining `hs-banner` on articles that lacked F5 chrome (fitting-models, gryphon, rr/multi-effect comparators, genomics-gpu-roadmap, inheritance-systems, benchmark-comparators, model-status, formula-grammar, function-map).
- `pkgdown::check_pkgdown()`: No problems found.
- `pkgdown::build_article()` for fitting-models / g-matrix-interpretation / multivariate: exit 0; img tags point at `../reference/figures/{twin-bridge,g0-rg-teaching}.svg`; autoplot PNG rendered.
- Rose fence: no covered flip; banners use frozen Florence templates; twin-bridge labels default `engine = "fit"` vs opt-in targets; G0/r_g is experimental / point display / loadings not shown.
- Twin: HSquared.jl PR #283 same branch name.
