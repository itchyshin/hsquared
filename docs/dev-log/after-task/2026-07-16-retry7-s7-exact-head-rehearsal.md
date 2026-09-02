## 1. Goal

Close the Retry-7 S7 exact-head synthetic admission packet without crossing the Sol-owned preseal or RNG boundary.

## 2. Implemented

Bound the synthetic worker configuration in the exact R source, then produced
and pushed the exact-head S7 evidence packet. The packet records a clean Totoro
full-cardinality D0F-to-D1 rehearsal, the dirty-deployment rejection control,
the rebuilt-source R check, and two separated CLEAN review batches.

## 3a. Decisions and Rejected Alternatives

Kept synthetic evidence strictly separate from official RNG. Rejected treating
the synthetic PASS, a Batch B receipt, or an inherited reviewer as preseal
authority. A separately dispatched enforced Sol decision stalled without a
verdict and was terminated; therefore the preseal gate remains BLOCKED rather
than being inferred from the successful rehearsal.

## 4. Files Touched

- `tools/v07_genomic_recovery_v3_synthetic_lifecycle.R`
- `tools/v07_genomic_recovery_v3_synthetic_lifecycle.R.sha256`
- `tests/testthat/test-v07-genomic-recovery-v3-launcher.R`
- `docs/dev-log/check-log.d/2026-07-16-retry7-s7-durable-run-receipt-local.md`
- `docs/dev-log/check-log.d/2026-07-16-retry7-s7-f77-totoro-synthetic-rehearsal.md`
- `docs/dev-log/reviews/2026-07-16-retry7-f77-batch-a-grace.tsv`
- `docs/dev-log/reviews/2026-07-16-retry7-f77-batch-a-rose.tsv`
- `docs/dev-log/reviews/2026-07-16-retry7-f77-batch-b-grace.tsv`
- `docs/dev-log/reviews/2026-07-16-retry7-f77-batch-b-rose.tsv`
- `docs/dev-log/after-task/2026-07-16-retry7-s7-exact-head-rehearsal.md`

## 5. Checks Run

`Rscript --vanilla tools/v07_genomic_recovery_v3_synthetic_lifecycle.R
--mode=worker-selftest`, focused launcher tests, full `devtools::test()`, Julia
`Pkg.test()`, Julia docs, and `tools/preamble_cap.sh` passed on the exact source
heads. The exact R GitHub Actions run 29534748803 completed successfully.
The rebuilt-source `R CMD check --no-manual` completed with two existing
vignette warnings and a non-fatal unavailable-`pedigreemm` Suggests INFO under
`_R_CHECK_FORCE_SUGGESTS_=false`. Totoro emitted `recovery-v3 synthetic
lifecycle: PASS`; D0F was COMPLETE and D1 was ELIGIBLE=12.

## 6. Tests of the Tests

The synthetic worker selftest verifies wrapper argument ordering, receipt
fields, sidecar creation, timeout failure handling, and no later worker after a
bounded stop. The fresh Totoro dirty clone exited 1 with `deployed
implementation worktree is dirty` before synthetic materialization.

## 7a. Issue Ledger

Fixed the prior missing durable worker-configuration receipt. Deferred the
Sol-owned preseal/chronology decision because its dedicated Sol job did not
return a verdict. No issue tracker item was opened.

## 8. Consistency Audit

Checked source-hash sidecar, launcher test, remote clean sibling topology,
remote dirty rejection, run/adjudication receipt sidecars, D0F/D1 final
validation, exact-head CI, and separated Batch A/B claim reviews. Protected
Retry-5 drafts and the quarantined Julia scaffold were not inspected.

## 9. What Did Not Go Smoothly

The first strict built-source R check stopped at the locally missing
`pedigreemm` Suggests dependency; the standard non-forced-Suggests rerun
completed. The explicit Sol read-only process stalled in repeated empty waits
after its evidence read and produced no result file, so it was stopped rather
than allowed to imply clearance.

## 10. Known Residuals

The Sol preseal/chronology verdict is absent. No canonical preseal exists, no
official bootstrap materialization or phenotype draw has occurred, and no
official D0F/D1-D4 compute, default activation, public-count update, merge, or
release is authorized.

## 11. Team Learning

Memory receipt: `ultra-plan` and R-package verification procedures shaped the
separated review, exact-head check, and enforced Sol routing. The protected
state rule was applied throughout.

Golden Set: not run; this was an operational admission/rehearsal slice, not a
capability promotion.

## 12. Cross-Product Coverage

Covers: the synthetic full-cardinality D0F-to-D1 lifecycle, receipt-bound
timeouts, clean deployment, dirty rejection, and exact-head review evidence.

Does NOT cover: canonical preseal, Sol chronology clearance, official bootstrap
or phenotype RNG, any official model fit, the 576-fit campaign, D1-D4 compute,
default routing, public coverage, merge, or release.
