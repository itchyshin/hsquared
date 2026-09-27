## 1. Goal

Make the bounded FA and GLLVM expert controls legible and close the R side of the structured-result review without widening public coverage.

## 2. Implemented

Structured result normalization now checks block names, order, IDs, and effect lengths against the input payload. `AIC()` checks every supplied fit and compares only matching REML methods, objective conventions, responses, families, and fixed designs. `iterations` and `em_warmup` reject fractions, strings, non-finite values, and integer overflow before conversion. `?hs_control` and the formula grammar name the bounded FA and GLLVM routes. Public descriptions retain their partial status and the covered count of seven.

## 3a. Decisions and Rejected Alternatives

The AIC comparison uses the objective metadata returned by Julia rather than reconstructing likelihood constants in R. The deterministic converged three-block fixture replaces a random nonconverged reduction fixture. `cov = fa()` remains reserved; expert controls do not imply default-route or broad FA coverage. The `d = "auto"` idea remains outside this bounded candidate.

## 4. Files Touched

`DESCRIPTION`, `R/extractors.R`, `R/hs_control.R`, `R/hsquared.R`, `R/julia-bridge.R`, `man/hs_control.Rd`, `tests/testthat/test-v2-result-metadata.R`, `tests/testthat/test-formula-animal.R`, `tests/testthat/test-d41-experimental-honesty.R`, `tests/testthat/test-hs-control-targets.R`, `tests/testthat/test-julia-bridge.R`, `vignettes/articles/function-map-cheatsheet.Rmd`, `vignettes/articles/model-status.Rmd`, `vignettes/articles/genomics-gpu-roadmap.Rmd`, `vignettes/articles/progression-evidence.Rmd`, `docs/design/02-formula-grammar.md`, `docs/design/06-public-claims-register.md`, `docs/design/validation-debt-register.md`, this report, and `docs/dev-log/check-log.md`.

## 5. Checks Run

`devtools::document()` regenerated `man/hs_control.Rd`; the incidental NAMESPACE formatting change was restored. Focused validator and metadata tests passed (`/private/tmp/hsquared-boole-validators-green.log`). Live R–Julia three-block and direct-maternal tests passed with no failures or skips (`/private/tmp/hsquared-fa-gllvm-final-live-bridge-escalated.log`). `rcmdcheck::rcmdcheck()` returned zero errors, warnings, and notes after Rose's last prose correction (`/private/tmp/hsquared-fa-gllvm-rcmdcheck-20260927-final-rose.log`). `pkgdown::check_pkgdown()` found no problems. Git diff whitespace check passed. The after-task structure checker passed in this R checkout; the hub-level closeout wrapper reported unrelated open brain ledgers.

## 6. Tests of the Tests

Mixed-convention `AIC(fit1, fit2)` returned the wrong result before the change; the negative test failed. Truncated and permuted engine block lists passed their old self-referential validator and failed the new regression before repair. Four fractional/string integer-control cases failed before validation moved ahead of coercion. The prior genomic and sparse Julia failures are recorded in the sibling report.

## 7a. Issue Ledger

Fixed: R multi-fit AIC bypass, v2 block self-validation, integer-control coercion, missing GLLVM help target, stale FA grammar statement, and the nonconverged three-block test fixture. Open: full bilateral v2 schema freeze, independent same-objective GLLVM reference, broad FA/GLLVM calibration, CI, and the Julia four-wave source review.

## 8. Consistency Audit

The review covered extractor calls, input payload IDs, result shape, both integer-control validators, generated help, formula grammar, status vignettes, DESCRIPTION, package check, and paired Julia tests. Rose's claims register records only bounded partial routes. The R and Julia versions remain 0.9.0, and no submission or tag was made.

## 9. What Did Not Go Smoothly

The first multi-model AIC repair still returned a scalar because the delegated base `AIC.logLik` ignored additional inputs; the method now builds the checked comparison table. Live JuliaCall initially failed to write its package-cache pidfile inside the sandbox; an otherwise identical run with cache access passed. Roxygen emitted an incidental NAMESPACE formatting diff, which was removed.

## 10. Known Residuals

Only the narrow FA and genetic GLLVM cells have live parity evidence. Default-start breadth, interval coverage, response-scale GLLVM heritability, automatic rank selection, non-Gaussian FA uniqueness, and the broader source review remain open. Current CI will be checked after the candidate branches are pushed.

## 11. Team Learning

Memory receipt: the twin route manifests, repo capability and validation debt files, the lane ownership guard, and the prior bridge handover informed this slice. Golden Set: the unchanged genomic fixture was rerun in Julia; hub memory-regression tooling was outside this slice. Validate numerical controls before conversion, and derive expected result shape from the original payload rather than from the untrusted result.

## 12. Cross-Product Coverage

Covers: R structured v2 two-effect, multi-effect, and direct-maternal metadata extraction; checked single- and multi-fit AIC; bounded FA/GLLVM help and status prose; `iterations` and `em_warmup` control validation. This does NOT cover every estimator's likelihood convention, release acceptance, automatic FA/GLLVM rank choice, non-Gaussian uniqueness, missing-response fits, or the full Julia engine source review.
