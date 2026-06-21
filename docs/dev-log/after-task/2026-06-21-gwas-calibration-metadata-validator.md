# After-Task Report: GWAS Calibration Metadata Validator

## Goal

Add the first implementation scaffold from the GWAS threshold activation
contract: an internal validator for optional future calibration metadata on
`hs_gwas` objects.

## Active Lenses

Ada, Shannon, Jason, Fisher, Curie, Rose, Grace, and testing-r-packages.

Spawned subagents: none.

## Files Changed

- `R/gwas.R`
- `tests/testthat/test-gwas.R`
- `docs/dev-log/check-log.md`
- `docs/dev-log/coordination-board.md`
- `docs/dev-log/after-task/2026-06-21-gwas-calibration-metadata-validator.md`

## Checks Run

- `air format R/gwas.R tests/testthat/test-gwas.R`
  - Result: clean.
- `Rscript --vanilla -e 'devtools::test(filter = "gwas")'`
  - Result: 43 pass / 0 fail / 0 warn / 2 skip.
- `Rscript --vanilla -e 'devtools::test()'`
  - Result: 1314 pass / 0 fail / 0 warn / 58 skip.
- `Rscript --vanilla -e 'pkgdown::check_pkgdown()'`
  - Result: clean.
- `git diff --check`
  - Result: clean.
- `_R_CHECK_FORCE_SUGGESTS_=false Rscript --vanilla -e 'rcmdcheck::rcmdcheck(args = "--no-manual", error_on = "warning", check_dir = tempfile("hsq-check-"))'`
  - Result: 0 errors / 0 warnings / 0 notes.
- Boundary grep:
  - `rg -n "does not activate R significance thresholds|current `gwas\\(\\)` output remains unchanged|optional future `hs_gwas` calibration metadata|no calibration payload|marker scans beyond partial" R/gwas.R tests/testthat/test-gwas.R docs/dev-log/check-log.md docs/dev-log/coordination-board.md docs/dev-log/after-task/2026-06-21-gwas-calibration-metadata-validator.md`
  - Result: confirms the validator/non-activation boundary.

## Public Claim Audit

Clean. Current `gwas()` output remains unchanged because the live engine result
carries no calibration payload. The new validator only defines what an optional
future calibration payload must contain before R can preserve it on an
`hs_gwas` object.

No R significance threshold, permutation cutoff, realistic-LD production
calibration, external scan comparator, QTL/eQTL threshold, or covered-status
promotion is claimed.

## Tests Of The Tests

The focused tests exercise:

- no calibration attribute when no payload exists;
- missing required fields;
- `calibration_method = "none"` rejection;
- out-of-range p-value thresholds;
- scan-method mismatch;
- non-integer replicate counts;
- successful preservation of a complete future metadata payload.

## Coordination Notes

This prepares the R object surface for a future engine calibration payload
without changing user-facing scan claims. The next activation step still needs
real calibration evidence and a comparator/negative-control story.

## What Did Not Go Smoothly

No blocker. The main subtlety was keeping the scaffold inert for current engine
output while still making future metadata strict.

## Known Limitations

- No threshold is activated.
- No engine calibration payload is consumed today.
- No external scan comparator evidence exists.
- No QTL/eQTL threshold path exists.

## Next Actions

1. When Julia exposes a calibration payload, add a live skip-guarded parity test
   that preserves the metadata through `gwas()`.
2. Add plot/table threshold rendering only after calibration evidence and
   comparator gates pass.
