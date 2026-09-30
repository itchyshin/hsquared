# After-task report: live FA/GLLVM bridge recheck

## 1. Goal

Re-run the bounded four-trait Gaussian FA and three-trait Poisson genetic GLLVM R tests against the current Julia candidate.

## 2. Implemented

No package source or test files changed. The exact live bridge test command passed all 213 assertions against the Julia worktree named by `HSQUARED_JULIA_PROJECT`.

## 3a. Decisions and Rejected Alternatives

The failed default-cache attempt was treated as JuliaCall setup failure, because the error was opening a compiled-cache pidfile before the affected fits. The retry used the established writable task-local depot; it did not weaken the live-bridge requirement or skip tests.

## 4. Files Touched

- `docs/dev-log/check-log.d/2026-09-30-live-fa-gllvm-bridge-recheck.md`
- `docs/dev-log/after-task/2026-09-30-live-fa-gllvm-bridge-recheck.md`
- `docs/dev-log/check-log.md`
- `docs/dev-log/coordination-board.md`

## 5. Checks Run

- Focused live R/Julia tests: `devtools::test(filter = "fa-optin|gllvm-optin")` with `HSQUARED_REQUIRE_BRIDGE=true` and the exact Julia candidate. Result: **213 passed, 0 failed, 0 warnings, 0 skips** in 24.3 seconds.
- Initial default-depot attempt: 3 test errors after JuliaCall could not open the shared RCall pidfile due to EPERM. This was resolved with `JULIA_DEPOT_PATH=/private/tmp/hsq-julia-depot:/Users/z3437171/.julia`.
- The test files, bridge files, and three Julia route source files are pinned by SHA-256 in the check-log shard.
- No full `R CMD check` or `pkgdown` build was repeated; their latest local passes are recorded in the preceding check-log entries.

## 6. Tests of the Tests

The focused selection ran with `HSQUARED_REQUIRE_BRIDGE=true`, and all 213 assertions passed with zero skips. Thus the route tests invoked Julia rather than taking the optional no-bridge skip path. The failed first run was environmental; the successful retry preserved the same test selection and bridge requirement.

## 7a. Issue Ledger

- Closed for this slice: current R FA/GLLVM bridge tests execute against the current Julia candidate and pass.
- Carried: whole Julia source-wave coverage, complete cross-twin acceptance, hosted CI, wider FA recovery and inference, and experimental capability limits.

## 8. Consistency Audit

The R package remains experimental 0.9.0 and `public_covered_count` remains 7. This does not change the bounded FA/GLLVM route scope or promote either capability. The separate 0.9.0 CRAN review lane is untouched.

## 9. What Did Not Go Smoothly

The first attempt hit an EPERM while JuliaCall opened the shared `RCall` compiled-cache pidfile. The isolated writable depot retry passed. No source change or cache repair in the shared Julia depot was needed.

## 10. Known Residuals

This does not close A2, E1, or V3. A2 still needs broader ordinary-start recovery, weak-direction and uncertainty diagnostics, remaining source spans, and whole-wave signoff. E1 still needs complete pinned-source and bridge review. V3 still needs the final cross-twin ledger, Rose audit, and applicable final-candidate checks.

## 11. Team Learning

For live JuliaCall checks on this host, set a writable task-local Julia depot before initializing the bridge so shared compiled-cache permissions do not mask model-level evidence.

## 12. Cross-Product Coverage

This slice covers the live R FA/GLLVM routes against the pinned Julia source files. It does NOT cover every Julia source span, hosted CI, broad recovery/calibration, GPU execution, or release readiness.
