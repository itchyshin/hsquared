# FA R bridge diagnostics follow-up

## 1. Goal

Make FA multi-start diagnostics available and validated in the bounded R opt-in fit, including Julia `nothing` values in an explicit one-start fit.

## 2. Implemented

The Julia-to-R serializer now emits the FA start strategy, selected start, attempt count, objective range, covariance disagreement measures, uniqueness-floor diagnostics, and per-start results. The R normalizer validates required metadata, types, lengths, and selected-start validity, then exposes the fields in `fit_diagnostics()`. A one-start `nothing` value is represented as an R missing value. The live fixture uses a sire-linked pedigree with repeated records in pedigree order. A separate bridge-input test uses unsorted pedigree labels to check ID-to-incidence alignment.

`fit_diagnostics()` now renders the per-start table as a compact readable row instead of `<list>`, and the multivariate vignette names the reported start fields. The FA and GLLVM capability rows remain partial. No public covered count, formula grammar, or release status changed.

## 3a. Decisions and Rejected Alternatives

The single-start bridge test checks serialization independently of convergence. Its user-supplied initialization is not a convergence fixture. The multi-start FA test remains the convergence check. The failed assertion from the first run exposed this distinction and was not counted as a passing test.

## 4. Files Touched

- `R/julia-bridge.R`
- `R/extractors.R`
- `tests/testthat/test-fa-optin.R`
- `vignettes/articles/multivariate.Rmd`
- `vignettes/articles/twin-boundary.Rmd`
- `docs/dev-log/check-log.md`
- `docs/dev-log/coordination-board.md`
- This report.

Other dirty files in this worktree predate this follow-up and belong to the same candidate or earlier lane work; they are not attributed to this slice.

## 5. Checks Run

- `devtools::test(filter = "fa-optin")`: **110 passed, 0 failed, 0 warnings, 0 skipped**, using the candidate Julia worktree and a writable temporary Julia depot.
- Follow-up red-green regression for readable `fa_start_starts`: **2 expected failures** before the extractor change, with the value rendered as `<list>`; **113 passed, 0 failed, 0 warnings, 0 skipped** after the fix, exit 0 against the live Julia bridge.
- `devtools::test(filter = "gllvm-optin")`: **53 passed**, recorded earlier in this task.
- `devtools::test(filter = "bridge-engine-status-crosslinks|package-help-honesty|direct-maternal")`: **129 passed**, recorded earlier in this task.
- Julia `test/test_multivariate_fa_multistart.jl`: **37 passed**, recorded earlier in this task.
- `pkgdown::check_pkgdown()`: **No problems found** after the twin-boundary wording correction.
- `git diff --check`: clean on the final candidate diff.
- Local `rcmdcheck::rcmdcheck(".", args = "--no-manual", error_on = "never")`: **Status: OK, 0 errors, 0 warnings, 0 notes**, 1m27s, R 4.6.0 on macOS Tahoe. CRAN/Bioconductor package indexes were unreachable, but the dependency check completed using the installed library.
- A separate `devtools::test()` run and GitHub CI: not run / not verified. `R CMD check` ran the package's applicable `testthat.R` suite successfully.
- `slop_check.py`: 0 findings; `check-after-task.R`: structure check passed. `closeout.py check` remains **FAIL** because the hub acceptance-ledger recheck exits with `Execution halted`; its shared ledger is outside this candidate worktree and was not changed.
- The 110-assertion live pass above predates the three readable-row assertions. The final live `fa-optin` run passed **113/113** after the red-green regression (two expected failures before the formatter), exit 0. A fresh `rcmdcheck::rcmdcheck(".", args = "--no-manual", error_on = "never")` then returned **Status: OK, 0 errors, 0 warnings, 0 notes** in 1m02.8s. `devtools::document()` and `pkgdown::check_pkgdown()` exited 0. Installed roxygen2 8.0.0 is below the package's recorded 8.1.0; its only generated diff was NAMESPACE formatting, which was discarded.

An exact-source local package-check rerun on 2026-09-29 returned **Status: OK, 0 errors, 0 warnings, 0 notes** in 1m02.1s (`/private/tmp/hsquared-rcmdcheck-final-20260929.log`). Package indexes were unreachable, but dependency checks completed from the installed library.

## 6. Tests of the Tests

The original single-start convergence assertion failed on the expanded sire-linked fixture. Inspection showed that this test's purpose is the `nothing`-to-missing serialization contract, while the independent multi-start test checks convergence. The assertion now checks the presence of the convergence field and continues to verify the strategy, attempt count, and missing diagnostics. The focused FA file then passed all 110 checks. The final local package check built the package and vignettes and returned Status: OK.

## 7a. Issue Ledger

- Fixed: FA start diagnostics were omitted from the R result payload.
- Fixed: `nothing` cross-start numeric diagnostics are now transported as `NaN` and normalized to missing R values.
- Open: independent and broader FA recovery, interior and external-package fitted comparisons, broader calibration, GLLVM matched comparator and population recovery, remaining Julia engine source-review waves, and final PR CI verification.

## 8. Consistency Audit

The implementation only exposes diagnostics for the existing opt-in FA fit. The FA and genetic GLLVM rows remain partial. `public_covered_count` remains 7. `cov = fa()` remains closed; no loading inference, automatic rank, non-Gaussian FA uniqueness, Bernoulli, missing-response, or response-scale heritability claim was added. Rose's read-only audit found that `twin-boundary.Rmd` still called the bounded R payload planned; this wording is corrected to distinguish the existing opt-in payload from the closed formula grammar. Rose's audit is clean after that correction.

## 9. What Did Not Go Smoothly

The first rerun inherited an unwritable Julia depot and failed at JuliaCall's manifest lock. The next run used the prepared temporary depot. The expanded pedigree also showed that the user-initialized single-start fit was not converged, so convergence was removed from that serialization-only assertion rather than weakening the separate multi-start convergence test. Independent review then caught the flat diagnostic table's `<list>` rendering; the added regression reproduced it in two assertions before the compact formatter was added.

## 10. Known Residuals

This slice does not complete the FA or GLLVM arcs, does not change either capability status, and does not establish broad recovery, calibration, loading inference, automatic rank selection, an external GLLVM comparator, or release eligibility. CI remains unverified. Separately, Astra's read-only Julia non-Gaussian source review reproduced two unresolved numerical issues: all-success probit data can be accepted as a finite Laplace mode despite an improper flat-intercept integral, and large ordinary Poisson counts can overflow an undamped Newton step. These are Julia-lane findings and require their own source fixes and regression tests; they are not changed by this R follow-up.

## 11. Team Learning

Hopper reviewed the bridge contract and confirmed the live one-start serialization test closes the `nothing` conversion gap. A second read-only Hopper pass found that the flat diagnostic table rendered the nested per-start frame as `<list>`; the regression failed before and passed after formatting. Rose completed the read-only claim audit; the stale vignette wording was corrected and aligned to the capability row's intercept and residual-covariance limits. Memory receipt: `/Users/z3437171/.codex/memories/MEMORY.md`, task group `HSquared.jl/hsquared v0.9.0 release, capability status, and deferred hardening`; repository capability and validation-debt rows are the technical source of truth. Golden Set: not run; this was a bridge diagnostics and claim-surface follow-up, so targeted malformed-payload/live-route tests and package checks supplied the task-specific regression evidence. No reviewer-role name is used as if it were a GitHub account.

## 12. Cross-Product Coverage

R consumes the candidate Julia FA result and returns validated start diagnostics through the existing explicit opt-in route. This does NOT cover a new model cell, automatic rank, formula-level FA syntax, broader FA identification, or promotion beyond partial experimental status.
