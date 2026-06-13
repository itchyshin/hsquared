# User-Docs Honesty Pass for the Sparse REML Path (B8)

Date: 2026-06-13

Active lenses: Pat, Rose, Grace.

Spawned subagents: none.

Current lane: coordinator/docs.

## Goal

Keep user-facing docs in sync with capability (Rose/Pat lens). The new
experimental, opt-in sparse REML estimator path (B2-B7) was not yet visible in
the user-facing model-status article, and the vision "Current Status" understated
the package by omitting the experimental opt-in bridge.

## Files Changed

- `vignettes/articles/model-status.Rmd` — added a fenced "what exists" bullet for
  the opt-in `target = "sparse_reml"` estimator bridge (Julia-owned; opt-in;
  default still validates-and-stops; not estimation via the public R interface,
  production, AI-REML, or ASReml parity; cross-checked vs dense and pure-R REML).
- `docs/design/00-vision.md` — refreshed "Current Status" to mention the
  experimental opt-in `engine = "julia"` bridge (Henderson MME + `sparse_reml`)
  while keeping the honest "no fitting in the R package itself / not production"
  framing.

## Verification

- `pkgdown::build_articles(lazy = FALSE)` + `pkgdown::check_pkgdown()`:
  `model-status.html` rebuilt; "No problems found."
- `rcmdcheck::rcmdcheck()`: `0 errors`, `0 warnings`, `0 notes`.
- `air format .` and `git diff --check`: clean.
- Remote (commit `1e89593`): R-CMD-check `27469723178`, pkgdown `27469723172`,
  Pages `27469763549` all passed.

## Public Claim Audit (Rose)

Docs now match capability: the experimental path is described with its full
boundary; no new claim is introduced. Default `hsquared()` still validates and
stops.

## Next Actions (maintainer decision)

The honest in-reach R-lane validation rungs are exhausted without either a new
dependency or twin engine work:

1. External REML comparator needs `sommer`/`pedigreemm` installed (absent);
   `MCMCglmm` is Bayesian and excluded by the comparator discipline. Decide
   whether to add a Suggests-gated comparator.
2. Fitted-Mrode against published estimates, production sparse PEV/reliability,
   and AI-REML are Julia-engine (twin) work — await the twin's green
   `validation_status()` before any public fitting claim.
