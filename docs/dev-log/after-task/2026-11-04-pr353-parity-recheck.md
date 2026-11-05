# PR 353 parity recheck

## 1. Goal

Independently exercise the R–Julia animal-model parity fixture on its pinned
sources and record what the hosted checks did and did not cover.

## 2. Implemented

The existing fixture was run against isolated source exports. No R code,
model specification, fixture value, or package capability changed.

## 3a. Decisions and Rejected Alternatives

Used the PR's recorded Julia commit rather than a newer engine. The assumption
is that checking the pinned route is the right evidence for this fixture; wider
engine-version compatibility remains separate.

## 4. Files Touched

This report and `docs/dev-log/check-log.d/2026-11-04-pr353-parity-recheck.md`.

## 5. Checks Run

R PR source `d8275983a51804971366fa31793a15ac579b0986`, Julia source
`8f58b13a616ef27a982bff4f2eff8f9558b39b86`, and Julia 1.12.6 were used.
With `HSQUARED_JULIA_TESTS=true`, `HSQUARED_REQUIRE_BRIDGE=true`, and
`HSQUARED_JULIA_PROJECT` pointing to the Julia export, the focused
`testthat::test_local(filter = "^engine-parity-animal-model$", reporter =
"summary", stop_on_failure = TRUE)` run passed 19 assertions without skips.
The resolved Julia manifest SHA-256 was
`f6d678a46c18c19345c151a4ea3c106e4c554db51a15ff8219d666acb70aef56`.
Existing hosted Ubuntu and Windows checks passed on the original PR head.
New hosted checks are required for this documentation update.

## 6. Tests of the Tests

The hosted logs explicitly show that the live test was skipped there. The
local opt-in run exercised it; the retained test output has 19 pass markers,
no skip section and exit status zero. The remaining fixture checks independently
rebuild the likelihood and information matrix in R.

## 7a. Issue Ledger

PR #353 supplies a bounded bridge parity fixture; it does not close a
scientific validation gate or change a validation-status row.

## 8. Consistency Audit

The test and fixture files are the only functional changes on the PR. The
routed project manifest, lane preflight and scoped leases were consulted.
The Golden Set was not run; no hub guard was changed.

## 9. What Did Not Go Smoothly

Green hosted checks initially looked like live bridge evidence, but both
platform logs showed that the live case was skipped.

## 10. Known Residuals

This is one fixture against one pinned engine. New-head CI and later
post-merge checks remain pending. No coverage or external-comparator result
is claimed.

## 11. Team Learning

For an optional bridge test, check the skip output before describing a green
package check as a live cross-language test.

## 12. Cross-Product Coverage

This covers the univariate Gaussian pedigree fixture and its pinned engine.
It does NOT cover other model families, broad bridge parity, external
comparators, interval calibration, or scientific acceptance gates.
