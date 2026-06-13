# Fit Diagnostics Extractor

Date: 2026-06-13

Active lenses: Emmy, Hopper, Jason, Pat, Rose, Grace

Spawned subagents: none

Current lane: R

## Goal

Add a conservative diagnostics extractor for `hsquared_fit` objects, following
local sibling-package patterns where fitted objects expose convergence and
optimizer metadata early. This slice improves user inspection without widening
the fitting claim.

## Sibling Learning

Checked local `drmTMB`, `gllvmTMB`, `GLLVM.jl`, and `DRM.jl` post-fit patterns.
Those projects surface convergence, log-likelihood, AIC, and iteration status
as first-class fit information. The hsquared adaptation is deliberately smaller:
`fit_diagnostics()` only reports metadata already present in an `hsquared_fit`
payload.

Scout note:

- `docs/dev-log/scout/2026-06-13-fit-diagnostics-sibling-scout.md`

## Changed

- Added `fit_diagnostics()` generic, default method, and `hsquared_fit` method.
- Added `print.hs_fit_diagnostics()`.
- Preserved bridge-supplied scalar diagnostics such as `gradient_norm`.
- Added tests for normal extraction, print shape, and default error.
- Updated README, NEWS, model-status article, public claims register,
  capability status, pkgdown index, and generated Rd/NAMESPACE.

## Verification

- `Rscript -e "devtools::document()" && air format . && Rscript -e "devtools::test(filter = 'fit-object|julia-bridge|phase0-api')"`:
  `171 pass`, `0 fail`, `0 warnings`, `0 skips`; live Julia bridge activated
  sibling `HSquared.jl`.
- `Rscript -e "devtools::test()"`: `408 pass`, `0 fail`, `0 warnings`,
  `0 skips`; live Julia bridge activated sibling `HSquared.jl`.
- `Rscript -e "pkgdown::build_articles(lazy = FALSE); pkgdown::check_pkgdown()"`:
  articles rebuilt; `No problems found.`
- `Rscript -e "devtools::check()"`: first run had `0 errors`, `0 warnings`,
  `1 note` for local time verification; rerun had `0 errors`, `0 warnings`,
  `0 notes`.
- `git diff --check`: clean.
- GitHub Actions R-CMD-check `27465212098`: passed in 1m30s.
- GitHub Actions pkgdown `27465212092`: passed.
- GitHub Pages build/deploy `27465247244`: passed, with the existing upstream
  Node 20 deprecation annotation for Pages actions.

## Claim Boundary

This slice does not add model fitting, production bridge execution, production
sparse reliability/PEV, Mrode fitted-output validation, ASReml parity, or GPU
execution. It exposes diagnostics for result payloads that already exist.

## Next Actions

1. Notify issue #5 and the Julia twin that the R side now has a diagnostics
   extractor over the existing result payload.
2. Consider a Julia-side matching `fit_diagnostics()` or `diagnostics()`
   helper only if the twin wants parallel vocabulary.
