# GLLVM initial control honesty

## 1. Goal

Align the R help with the actual genetic GLLVM bridge contract and guard the rejected control with a test.

## 2. Implemented

Removed `initial` from the `genetic_gllvm` honoured-key list in the R help and regenerated Rd documentation. Added a public-route test that expects a supplied loading start to fail with the unsupported-control message before Julia is called. The bridge allowlist and Julia fitter were not changed.

## 3a. Decisions and Rejected Alternatives

Expose a raw loading-matrix start only after the R trait-order contract, validation, restart behavior, and ordinary-start recovery are established. Julia's current `initial` keyword supplies one loading-matrix starting point; restart behavior remains a separate, unvalidated contract.

## 4. Files Touched

- `R/hs_control.R`
- `man/hs_control.Rd`
- `tests/testthat/test-gllvm-optin.R`
- This report.
- `docs/dev-log/check-log.d/2026-09-29-gllvm-initial-control-honesty.md`

Other dirty files in the worktree were preserved.

## 5. Checks Run

- `Rscript --vanilla -e 'roxygen2::roxygenise(roclets = "rd")'`: wrote `man/hs_control.Rd`; warned that installed roxygen2 8.0.0 is older than required 8.1.0. The generated diff is limited to the corrected GLLVM control list.
- `OPENBLAS_NUM_THREADS=1 JULIA_NUM_THREADS=4 JULIA_DEPOT_PATH=/private/tmp/hsquared-fa-gllvm-depot:/Users/z3437171/.julia HSQUARED_JULIA_PROJECT=/Users/z3437171/.codex/worktrees/hsquared-fa-gllvm-foundations/HSquared.jl HSQUARED_JULIA_TESTS=true Rscript --vanilla -e 'devtools::test(filter = "gllvm-optin")'`: 54 passed, 0 failed, 0 warnings, 0 skipped; 12.3 seconds; exit 0.
- `Rscript --vanilla -e 'rcmdcheck::rcmdcheck(".", args = "--no-manual", error_on = "error")'`: **Status: OK, 0 errors, 0 warnings, 0 notes**; 1m02.1s; exit 0. CRAN and Bioconductor indexes were unreachable; dependency checking completed from the installed library.
- `git diff --check`: clean for the edited source, help, and test files.
- Hosted CI was not checked.

## 6. Tests of the Tests

The new assertion submits `initial` through the public `hsquared()` route and checks for the bridge's explicit not-honoured error. The live GLLVM parity test also ran in the same 54-check suite and passed against the configured Julia candidate.

## 7a. Issue Ledger

- Closed: help incorrectly promised that R forwards `initial` for genetic GLLVM.
- Closed: the opt-in test lacked a guard for this rejected key.
- Open: ordinary-start recovery and any future user-start/restart contract.

## 8. Consistency Audit

The public R control description now matches the bridge allowlist. The fixed three-trait, rank-two Poisson cell remains unchanged and experimental. No capability status, formula grammar, covered count, estimator, or release state changed.

## 9. What Did Not Go Smoothly

The installed roxygen2 version is behind the package minimum. Regeneration produced the intended focused Rd update, and local package checks accepted the generated help; repeat documentation generation under roxygen2 8.1.0 when available.

## 10. Known Residuals

This does not expose or validate user-supplied loading starts, multiple starts, general recovery, external same-objective comparison, uncertainty inference, or large-scale computation. The Julia engine gates A2, E1, and V3 remain open. R docs and status files with this wording are on other refs, so the fix is limited to the current candidate branch pending integration.

## 11. Team Learning

Boole's read-only contract review confirmed that Julia's `initial` is a raw T by K loading-matrix start, while the R target rejects it and does not forward it. Rose's earlier audit identified the documentation mismatch. Next, reconcile the stale FA assertion counts on an owned R docs path and continue the remaining Julia review on its candidate lineage.

## 12. Cross-Product Coverage

This change documents and tests the R-to-Julia input boundary for the existing GLLVM fit. It does NOT cover exposing loading starts, restart semantics, or ordinary-start recovery.
