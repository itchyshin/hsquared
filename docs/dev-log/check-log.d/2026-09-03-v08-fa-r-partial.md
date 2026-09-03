# Check-log — R FA planned → partial / experimental stubs (2026-09-03)

- Goal: stop calling R-twin FA "planned-only" after Julia #292 S4 PASS,
  without claiming covered or bumping `public_covered_count`.
- Branch: `cursor/08-fa-partial-20260903` from `origin/main` `96318bf`.
- Commands:
  - `devtools::document()` — wrote `man/hs_control.Rd`,
    `man/hsquared-package.Rd`.
  - `testthat::test_file("tests/testthat/test-phase0-api.R")` —
    FAIL 0 / WARN 0 / SKIP 0 / PASS 155.
  - `testthat::test_file("tests/testthat/test-formula-animal.R")` —
    FAIL 0 / WARN 0 / SKIP 2 / PASS 96.
  - `testthat::test_file("tests/testthat/test-multivariate.R")` —
    FAIL 0 / WARN 0 / SKIP 4 / PASS 73.
  - `testthat::test_file("tests/testthat/test-package-help-honesty.R")` —
    FAIL 0 / WARN 0 / SKIP 0 / PASS 11.
  - `testthat::test_file("tests/testthat/test-hs-control-targets.R")` —
    FAIL 0 / WARN 0 / SKIP 0 / PASS 26.
- Claim boundary: FA **partial / experimental**. R formula and bridge
  not activated. Count stays **7**. No 1.0 / CRAN.
- Board (not edited here; #160 holds the lease). Suggested row:

  `| 2026-09-03 | R 0.8 FA honesty | Ada/Shannon/Rose/Boole | cursor/08-fa-partial-20260903 | capability/claims/debt + formula_status reserved cov=fa + honest errors | **PARTIAL / EXPERIMENTAL.** Engine #292 S4 8/10 PASS cited. R does not fit FA. Count stays **7** | DESCRIPTION still says planned (#162 lease) | merge when CI green |`
