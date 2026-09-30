# GLLVM optimizer and inner-mode diagnostics

## 1. Goal

Expose the convergence diagnostics already returned by the Julia genetic GLLVM fitter in the R result and make the public article describe them accurately.

## 2. Implemented

The R bridge now transfers outer-optimizer convergence, inner-mode convergence, inner gradient norm, inner iterations, stop reason, and backtracks. Result normalization validates the scalar fields and the combined convergence contract, and `fit_diagnostics()` exposes the separate fields. A failed outer optimizer remains distinguishable from an inner-mode failure. The article documents those diagnostics and retains the dense validation-scale limitation.

## 3a. Decisions and Rejected Alternatives

Forward the Julia diagnostics that already exist instead of adding or inferring new convergence measures. Keep `converged` as the conjunction of outer and inner convergence; report `optimizer_status` from the outer optimizer alone.

## 4. Files Touched

- `R/julia-bridge.R`
- `tests/testthat/test-gllvm-optin.R`
- `vignettes/articles/genetic-gllvm.Rmd`
- This report.
- `docs/dev-log/check-log.d/2026-09-29-gllvm-diagnostics-payload.md`

Other dirty files in the worktree were preserved.

## 5. Checks Run

- Red test-first run of `devtools::test(filter = "gllvm-optin")`: 15 expected failures reproduced missing diagnostics and absent malformed-input rejection.
- `OPENBLAS_NUM_THREADS=1 JULIA_NUM_THREADS=4 JULIA_DEPOT_PATH=/private/tmp/hsquared-fa-gllvm-depot:/Users/z3437171/.julia HSQUARED_JULIA_PROJECT=/Users/z3437171/.codex/worktrees/hsquared-fa-gllvm-foundations/HSquared.jl HSQUARED_JULIA_TESTS=true Rscript --vanilla -e 'devtools::test(filter = "gllvm-optin")'`: 69 passed, 0 failed, 0 warnings, 0 skipped; 10.9 seconds. The live R-to-Julia parity case ran.
- `rcmdcheck::rcmdcheck(args = c("--no-manual", "--as-cran"), error_on = "error")`: package build and vignette creation succeeded; check summary reported 0 errors, 0 warnings, 0 notes. CRAN and Bioconductor indexes were unreachable in this environment; Quarto version probing also reported unavailable.
- `git diff --check`: clean.

## 6. Tests of the Tests

The tests first failed on missing diagnostic fields and acceptance of malformed gradient/convergence data. The corrected focused run exercises the synthetic normalization contract, diagnostics extractor, malformed values, failed outer optimizer status, and live same-input R/Julia field parity.

## 7a. Issue Ledger

- Closed: R results omitted Julia's already-computed inner-mode diagnostics.
- Closed: combined convergence was not checked against its outer and inner components.
- Open: recovery from ordinary starts and broader restart behavior remain unvalidated.

## 8. Consistency Audit

The R result preserves the fixed three-trait, rank-two Poisson genetic GLLVM cell. No formula grammar, model, capability status, covered count, release state, or Julia source was changed. The documented fit remains experimental and dense at validation scale.

## 9. What Did Not Go Smoothly

The first green-intended run exposed an existing test that set the combined convergence flag false without setting either component false. The fixture was corrected to represent an outer-optimizer failure. The first focused run also showed the infinite-gradient error was too generic; normalization now names the finite-gradient requirement.

## 10. Known Residuals

This work does not establish ordinary-start recovery, broad calibration, external same-objective comparison, loading inference, missing-response behavior, or large-scale sparse computation. Julia engine gates A2, E1, and V3 remain open.

## 11. Team Learning

Hopper's bridge review identified the existing Julia diagnostics contract and confirmed they could be forwarded without changing Julia. The test-first red run made the omitted R fields explicit before implementation. Next, continue the remaining engine review and close the open capability gates on their owned candidate branches.

## 12. Cross-Product Coverage

This change covers R transport and presentation of existing Julia diagnostics for the bounded genetic GLLVM route. It does NOT cover new fitting behavior, ordinary-start recovery, broad calibration, external same-objective comparison, loading inference, missing-response behavior, or large-scale sparse computation; it does not promote the capability beyond experimental status.
