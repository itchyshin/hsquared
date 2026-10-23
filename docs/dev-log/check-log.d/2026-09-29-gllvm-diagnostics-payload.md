# GLLVM optimizer and inner-mode diagnostics

Goal: expose existing Julia outer and inner convergence diagnostics through the R result.

- Test-first red run: focused GLLVM tests reproduced 15 failures for absent diagnostic fields and missing malformed-value rejection.
- `OPENBLAS_NUM_THREADS=1 JULIA_NUM_THREADS=4 JULIA_DEPOT_PATH=/private/tmp/hsquared-fa-gllvm-depot:/Users/z3437171/.julia HSQUARED_JULIA_PROJECT=/Users/z3437171/.codex/worktrees/hsquared-fa-gllvm-foundations/HSquared.jl HSQUARED_JULIA_TESTS=true Rscript --vanilla -e 'devtools::test(filter = "gllvm-optin")'`: 69 passed, 0 failed, 0 warnings, 0 skipped; 10.9 seconds; live R/Julia parity included.
- `rcmdcheck::rcmdcheck(args = c("--no-manual", "--as-cran"), error_on = "error")`: package build and vignette creation succeeded; check summary 0 errors, 0 warnings, 0 notes. CRAN/Bioconductor indexes and Quarto version probe were unavailable.
- `git diff --check`: clean.

Claim boundary: R diagnostics transport and validation only. The bounded Poisson genetic GLLVM remains experimental; no capability promotion or release claim.
