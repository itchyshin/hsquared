# 2026-09-29 GLLVM status wording and focused checks

## Goal

Keep the general GLLVM capability planned while describing the bounded opt-in Poisson route and its evidence accurately.

## Change

`R/validation-status.R` distinguishes the partial three-trait, rank-two pedigree Poisson-log route from general GLLVM validation. It identifies the one-cell Julia ordinary-start evidence and 12-animal same-input R-to-Julia parity check, and retains the limits on recovery, calibration, matched external comparison, and covered status. The earlier four-scenario true-loading-start harness is separate evidence. The PATH_ONLY interval wording now uses ASCII punctuation for portable R source.

## Checks

- `Rscript --vanilla -e 'devtools::test(filter = "phase0-api|capability-ledger-summary")'`: PASS, 187 passed, 0 failed, 0 warnings, 0 skipped; duration 2.5 seconds.
- `bash tools/build_check_log.sh --check`: PASS, all 92 check-log shards well-formed.
- `git diff --check`: PASS.
- `Rscript -e 'rcmdcheck::rcmdcheck(".", args = c("--no-manual"), error_on = "never")'`: PASS, 0 errors, 0 warnings, 0 notes after replacing non-ASCII dashes in the R status prose and regenerating its Rd page.
- `Rscript -e 'pkgdown::check_pkgdown()'`: PASS, no problems found.
- Live opt-in checks with `HSQUARED_JULIA_PROJECT` set to the exact Julia candidate and `HSQUARED_REQUIRE_BRIDGE=true`: FA/GLLVM tests 200 passed, 0 failed, 0 skipped.
- Current hashes: `R/validation-status.R` `7d467a286dc9271ea56288c1da02d4469268ee9fbed7311d5050fb06ca439234`; `man/validation_status.Rd` `efaf0d2043e8d8630c75dee5a36cd493cedcda96edc0533b363453d7d078584c`.

## Claim boundary

This wording and test run do not establish broad GLLVM recovery, calibration, a matched external same-objective comparator, or covered capability status. No release or submission action was performed.
