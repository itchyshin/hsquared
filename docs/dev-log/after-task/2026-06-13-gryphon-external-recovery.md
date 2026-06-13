# Gryphon external published-REML recovery atom

Date: 2026-06-13

Active lenses: Curie, Fisher, Jason, Rose (perspectives). Spawned subagents:
none for this slice (built on the earlier `gate-source-scout` run `wo62dphp0`
and the local triple-agreement verification).

Current lane: R (hsquared). No twin edits.

## Goal and context

Under the standing finish-directive (the user asked the autonomous run to keep
going to finish what it needs), add the first externally-anchored REML-recovery
validation atom in the R lane. The gate-source scout recommended the gryphon
birth-weight univariate animal model, and I independently verified that
hsquared's own pure-R REML reference recovers the published estimates to ~4 dp.
This slice commits that as a skip-guarded test, mirroring the existing
`pedigreemm` external-comparator precedent.

This is a judgement call made autonomously under delegation: the scout/audit had
flagged the *gate anchor* choice as maintainer-owned. This atom does NOT open
the gate — it cross-checks the R reference optimizer against a published
external estimate. The maintainer may re-point the anchor; the dependency
(`enhancer`/`sommer`) and the test are reversible.

## What changed

- `R/validation-fixtures.R` — `hs_gryphon_published_reml()` helper returning the
  published constants + citation (dep-free).
- `tests/testthat/test-validation-fixtures.R` — skip-guarded test: hsquared's
  `hs_reml_estimate_reference` recovers the published gryphon VA/VE/h2 (Wilson et
  al. 2010) within 0.02, and optionally agrees with `sommer::mmes` (wrapped in
  `tryCatch`, robust to sommer API churn).
- `DESCRIPTION` — Suggests: `enhancer` (CRAN, ships the gryphon data) and
  `sommer` (CRAN, agreement comparator).
- `R/validation-status.R` (+ `test-phase0-api.R`) — added the
  `external published-REML recovery (gryphon, R reference)` row; status table now
  15 rows (8 partial + 7 planned).
- `docs/design/capability-status.md`, `docs/design/validation-debt-register.md`
  — recorded the atom with its explicit boundary.

## Finding / evidence

Triple agreement on the gryphon BWT model: published (VA=3.3954, VE=3.8286,
h2=0.470) ↔ `sommer::mmes` (VA=3.3954, VE=3.8286) ↔ hsquared's pure-R REML
reference (VA=3.3953, VE=3.8287, h2=0.4700, converged ~4 s). This is genuine
external-anchor evidence — strictly stronger than the self-referential
supplied-variance fixtures and the one-sided `pedigreemm` log-likelihood floor.

## Verification

- `devtools::test()` (NOT_CRAN, no Julia needed for this atom): the gryphon test
  ran and passed.
- `rcmdcheck::rcmdcheck(args = c("--no-manual", "--as-cran"))`: 0 errors,
  0 warnings, 1 note (benign new-submission/dev-version).
- `air format .`: clean (reformatted the new test to house style).
- Remote (commit `952075b`): R-CMD-check `27474821889`, pkgdown `27474821893`,
  Pages `27474859398` — all passed. The gryphon test ran on CI (NOT_CRAN, with
  `sommer`/`enhancer` installed) and passed.

## Boundary (Rose)

External-anchor cross-check of the pure-R REML reference only. NOT the production
fit path; does NOT satisfy the twin-owned `V1-MRODE-FIT` gate row; does NOT open
the v0.1 default fit. Gryphon is teaching/simulated data — the maintainer should
confirm the headline numbers against the paper before any promotion. The
DESCRIPTION still states the package does not fit models yet. No public
overclaim.

## What remains (unchanged)

The v0.1 default-fit gate still needs: the twin to build/flip `V1-MRODE-FIT` and
`V1-COMPARATORS` (twin is currently on Phase 2 genomics, not the gate); the
predicate's boundary/identifiability item (engine work); the maintainer's
tolerance/threshold sign-off; and the verified twin `V1-AI-REML` evidence-string
fix (still present on the twin at `validation_status.jl:97`). The R-lane gryphon
atom is the R side's contribution to that gate evidence.
