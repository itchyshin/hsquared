# After-task — experimental version 0.7.0 → 0.8.0

Date: 2026-09-04. Lane: R package (`hsquared`). Branch:
`cursor/08-ver-080-r-20260903`. Type: experimental number only.

```
PLATFORM: cursor | LANE: cursor/08-ver-080-r-20260903
OTHER LANES: Codex DRAFT #137/#274 cite-only · Dropbox FOREIGN
Active lenses: Ada / Shannon fence · Rose (bump surfaces only)
Spawned subagents: none
Current lane: scratch WT — Dropbox FOREIGN
```

## Goal

Fire owner **`bump 0.8.0`** lockstep with HSquared.jl. Change the
experimental number 0.7.0 → 0.8.0. Leave `public_covered_count` at **7**.
Leave the experimental label on. Do not promote R FA or R SS.

## What landed

- Version surfaces: DESCRIPTION, NEWS, `.onAttach`, package.R, README,
  pkgdown callout, vignette, citation fallback, honesty + harness pins,
  capability live version lines, design-41 0.8 ladder pointer, board,
  this report.
- R FA stays **planned**. R `single_step()` stays **opt-in partial**.

## Public-claim audit

**Allowed:** experimental **0.8.0** number. Version tracks the engine
pillar pair, not R-public count.

**Blocked:** count 7→8 · R-public FA · R-public SS · ordinary-route
`single_step()` · `cov = fa` · experimental lift · tag / CRAN / 1.0.

## Twin

Julia lockstep branch `cursor/08-ver-080-jl-20260903`. Merge together
after both CI green. Julia first or same hour.


## Local checks

- `DESCRIPTION` Version **0.8.0**; `.onAttach` says experimental 0.8.0
- `devtools::document()` wrote `man/hsquared-package.Rd` 0.8.0
- `testthat::test_file(...test-d41-experimental-honesty.R)` PASS
- `devtools::test()` exit 0 (skips are live-Julia / Suggests only; no failures)
- `pkgdown::check_pkgdown()` No problems found
- `R/validation-status.R` public_covered_count stays **7**
