# GLLVM initial control honesty

Goal: align public R help with the `genetic_gllvm` bridge allowlist and test rejection of the unsupported `initial` key.

- `Rscript --vanilla -e 'roxygen2::roxygenise(roclets = "rd")'`: `man/hs_control.Rd` updated; installed roxygen2 8.0.0 warned that package minimum is 8.1.0.
- `OPENBLAS_NUM_THREADS=1 JULIA_NUM_THREADS=4 JULIA_DEPOT_PATH=/private/tmp/hsquared-fa-gllvm-depot:/Users/z3437171/.julia HSQUARED_JULIA_PROJECT=/Users/z3437171/.codex/worktrees/hsquared-fa-gllvm-foundations/HSquared.jl HSQUARED_JULIA_TESTS=true Rscript --vanilla -e 'devtools::test(filter = "gllvm-optin")'`: 54 passed, 0 failed, 0 warnings, 0 skipped; 12.3 seconds; exit 0.
- `Rscript --vanilla -e 'rcmdcheck::rcmdcheck(".", args = "--no-manual", error_on = "error")'`: Status OK, 0 errors, 0 warnings, 0 notes; 1m02.1s; exit 0. Package indexes were unreachable; dependency checking completed from the installed library.
- `git diff --check`: clean on edited files.

Claim boundary: help and negative-input coverage only. No `initial` payload is accepted or forwarded; no ordinary-start recovery or new model capability is claimed.
