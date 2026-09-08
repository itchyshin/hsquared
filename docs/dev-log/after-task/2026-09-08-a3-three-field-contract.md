# After-task — 2026-09-08 A3 three-field contract (R)

## 1. Goal

Implement the maintainer-authorized R1–R5 public-R/bridge half of the paired
0.9 three-field contract, with required tests and documentation only. No
campaign, remote compute, promotion, release, version, tag, or registry action.

## 2. Implemented

The opt-in non-Gaussian target validates the narrow intercept-only animal-model
admission contract, builds the versioned Julia call, and strictly normalizes
the three labelled fields. Poisson returns latent/count-observation; Binomial
returns latent/liability and literal `NaN` observation (`not_yet_ratified`).
Binary plus scalar/varying `cbind` trial counts are admitted; unsupported cells
give directed errors. The old normalizer remains an explicit legacy path.

## 3a. Decisions and Rejected Alternatives

The ratified NaN-only Binomial observation outcome is retained exactly. Rejected:
legacy normalizer replacement, extra families/scales, public capability
promotion, remote compute, and all release actions.

## 4. Files Touched

Bridge, model-spec/control/status sources; A3 tests; generated Rd files;
NEWS/DESCRIPTION/roadmap/vignette/status ledgers; and historical design-record
reconciliation notices. `.Rbuildignore` excludes local ledgers and `LOOP` from
the source bundle.

## 5. Checks Run

- Focused A3 test, including deterministic local R-to-Julia Poisson transport — PASS.
- Full `devtools::test()` — PASS with documented external/live skips.
- Ordinary `R CMD check --no-manual` of the isolated source tarball — Status: OK.
- Maintainer live-Julia check — exit 0, 0 errors/0 warnings; a reproducible
  macOS temporary `dsymutil-*` NOTE is retained as environmental evidence.
- `git diff --check` and Unlazy A3 ledger — PASS, 8/8 gates.

## 6. Tests of the Tests

Unit/mutation coverage checks exact identities, rejected fields and trial
forms, schema/normalizer failures, and explicit NaN retention. The live bridge
test validates that R selects the versioned Julia path. Obsolete tests are
fenced as legacy rather than being current-route evidence.

## 7a. Issue Ledger

Resolved: stale historical design records and old live-route tests could
overstate the A3 surface. Deferred: calibration, campaign, and external
same-estimand comparator evidence.

## 8. Consistency Audit

Rose passed the final claim surface. The result is experimental/partial and
explicitly not a REML/AI-REML, calibrated, comparator-backed, covered, default,
or release claim.

Rose passed the final claim surface. The result is experimental/partial and
explicitly not a REML/AI-REML, calibrated, comparator-backed, covered, default,
or release claim. The R and Julia worktrees remain isolated; the Dropbox R
checkout was not modified.

## 9. What Did Not Go Smoothly

Several historical design notes and legacy tests described a broader prior
route. They now declare their historical/deferred scope, avoiding a public
contradiction with A3.

## 10. Known Residuals

No calibration protocol result, retained campaign evidence, external
same-estimand comparator, or release evidence exists. The Binomial observation
field is intentionally `NaN`, not an estimate.

## 11. Team Learning

Legacy compatibility tests must never silently stand in for a current public
contract. Fencing them and pointing to the versioned evidence keeps the failure
mode visible without corrupting the A3 claim.

## 12. Cross-Product Coverage

Covers R admission/errors, bridge normalization, Poisson and Binomial field
semantics, scalar/varying trials, live transport selection, ordinary package
checks, and public claim reconciliation. It does not cover H0/H1/H3 campaign
evidence, calibration, comparator evidence, promotion, versioning, or release.
