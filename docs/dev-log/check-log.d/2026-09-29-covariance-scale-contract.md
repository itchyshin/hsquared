# Scale-standardized covariance contract

- Candidate: `codex/hsquared-fa-gllvm-20260927`, HEAD
  `fa98c262eb21694d672e671c9672491ce3369cec`; changes remain uncommitted.
- Source files:
  - `R/julia-bridge.R`: SHA-256
    `4cb8074949c8b843727cd4d6acf8ef720113967e5820f135c5170bc3496e24c2`
  - `tests/testthat/test-gllvm-optin.R`: SHA-256
    `a7f33d6ff78f7f3296bcf1a4eec95c735711e5af0e3de77e8532b7d0c08d4bc7`
  - `tests/testthat/test-fa-optin.R`: SHA-256
    `196a9962e0aa3019819eb1b12fd3bdee1b9b0d1c043170a6b66506d0ead51f35`
  - `tests/testthat/test-multivariate.R`: SHA-256
    `a81c1629ab5ef7e0f27ea6d019d1f4b3ff1d36710066672d99ed03272c7ecdaa`
- Test-first evidence: focused GLLVM suite before the fix failed exactly two
  new expectations. The heterogeneous-scale negative-correlation matrix and
  the small-block asymmetry were both accepted by the old raw-scale checks.
- Final focused command, with live Julia candidate configured:
  `JULIA_DEPOT_PATH=/private/tmp/hsq-goal-julia-depot:/Users/z3437171/.julia`
  `HSQUARED_JULIA_PROJECT=/Users/z3437171/.codex/worktrees/hsquared-fa-gllvm-foundations/HSquared.jl`
  `HSQUARED_JULIA_TESTS=true HSQUARED_REQUIRE_BRIDGE=true NOT_CRAN=true`
  `Rscript -e 'devtools::test(filter = "fa-optin|gllvm-optin")'`
  Result: **213 passed, 0 failed, 0 warnings, 0 skips**. The suite includes
  rank-two positive-semidefinite covariance under heterogeneous trait units.
- `air format R/julia-bridge.R tests/testthat/test-gllvm-optin.R` exited 0.
  `git diff --check` exited 0.
- `R CMD build --no-manual --no-resave-data .` exited 0, including vignette
  creation. Archive `hsquared_0.9.0.tar.gz`, SHA-256
  `bb68d0cc48dad1d149ffcc40e0f0bc52165c9bafa678087e41fe74557c2af5ff`.
- Initial full local check used the same live Julia environment:
  `R CMD check --no-manual --output=/private/tmp/hsq-rfa-final-check2 hsquared_0.9.0.tar.gz`
  Result: **Status: OK** on R 4.6.0, aarch64 Apple Darwin, macOS Tahoe.
  `testthat.Rout`: **3,767 passed, 0 failed, 26 warnings, 47 skips**.
  CRAN and Bioconductor indexes could not be reached; dependency checks passed
  using the installed library. This does not establish hosted CI.
- Final test-inclusive rebuild check used
  `R CMD check --no-manual --output=/private/tmp/hsq-rfa-final-check3 hsquared_0.9.0.tar.gz`
  and returned **Status: OK**; testthat reported **3,768 passed, 0 failed,
  26 warnings, 47 skips**. Final archive SHA-256:
  `667668f1de0951e11016d2cc57b1eed0e27b8a29560216d69fdce54d78f665fd`.
- Status boundary: bridge validation only. No claim of covariance estimator
  identifiability, recovery, calibrated inference, external comparator parity,
  or broad validation. FA and GLLVM remain partial/experimental;
  `public_covered_count` remains 7; version remains 0.9.0. No release action.
- Noether's adversarial numerical review found no blocker. Rose's delta review
  found no public claim or status expansion. Mixed-scale underflow/overflow is
  not a direct regression case; the implementation divides sequentially by
  marginal SDs and rejects nonfinite normalized geometry.
