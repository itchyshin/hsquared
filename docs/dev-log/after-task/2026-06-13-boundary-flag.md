# Boundary/identifiability flag in fit_diagnostics() and summary()

Date: 2026-06-13

Active lenses: Fisher (inference/identifiability), Emmy (extractors), Rose
(claims). Spawned subagents: none.

Current lane: R (hsquared).

## Goal

Implement the R-side **surfacing** half of v0.1 promotion-predicate item 4
(boundary/identifiability). The predicate requires the promoted fit to
distinguish an interior optimum from a `sigma_a2 = 0` (or `sigma_e2 = 0`)
boundary solution and surface that, so a boundary heritability is not read as an
ordinary interior estimate. This is an extractor responsibility the R lane owns;
the engine-stability half is twin work. Re-examining the predicate showed item 4
was not entirely twin-owned, as earlier handoffs implied.

## What changed

- `R/extractors.R` — `hs_fit_boundary_flag()` (internal): returns `TRUE` when a
  variance component is at/near zero (`h2 <= tol` or `h2 >= 1 - tol`, computed
  from the returned variance components), `NULL` when they are unavailable.
  `fit_diagnostics()` now reports an `at_boundary` row.
- `R/fit-object.R` — `summary()` carries the flag and `print()` emits a boundary
  note when it is `TRUE`.
- `tests/testthat/test-fit-object.R` — updated the pinned diagnostics metric set
  and added a detection test (a `sigma_a2 = 0` mock flags `TRUE`; an interior
  mock flags `FALSE`).
- `docs/design/01-v0.1-contract.md` — predicate item 4 now records the R-side
  surfacing as implemented, the engine-stability half as remaining twin work.
- `docs/design/capability-status.md` — extractor row notes the `at_boundary`
  flag.

## Verification

- `devtools::test()` `test-fit-object.R`: pass.
- `rcmdcheck::rcmdcheck(args = c("--no-manual", "--as-cran"))`: 0 errors,
  0 warnings, 1 note (benign).
- `air format .`: clean.
- Remote (commit `c53f927`): R-CMD-check `27476005389`, pkgdown, Pages
  `27476045834` — all passed.

## Boundary (Rose)

A diagnostic, not a fitting/default claim. It flags what is observable from the
returned variance components; it does not make the optimizer boundary-stable
(that is twin engine work) and does not flip the default fit. Capability stays
partial.

## What remains for predicate item 4

The engine-stability half: the optimizer returning a boundary-consistent,
finite, documented result as `h2 -> 0/1` (not a crash, negative variance, or
silently-pinned estimate). That is twin (`HSquared.jl`) work; the twin already
exercises a `sigma_a2 = 0` boundary fixture to extend.
