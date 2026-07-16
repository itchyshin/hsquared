# Retry-7 S7 bounded-worker recovery — local gate (2026-07-16)

Scope: recovery of the incomplete clean-deployment synthetic rehearsal. This
changes only the synthetic harness operational envelope; it does not invoke
official phenotype or bootstrap RNG, fitting, preseal, adjudication, D1-D4, or
activation.

## Recovery change

- `v07_genomic_recovery_v3_synthetic_lifecycle.R` now requires GNU `timeout`
  for each fresh worker, with `TERM`, a 15-second kill grace period, and a
  strict `HSQUARED_RETRY7_SYNTHETIC_WORKER_TIMEOUT_SECONDS` bound (default 900,
  maximum 3600 seconds).
- A nonzero worker exit aborts the lifecycle before any later worker launches;
  status 124 reports the elapsed bound explicitly.
- A deployment check requires clean sibling deployed R and Julia git roots
  before synthetic materialization. The launcher exposes that check separately
  for the clean/dirty remote rehearsal controls.

The prior Totoro attempt was manually interrupted after D1 post-run review
receipts while it was still making progress. It is incomplete operational
evidence, not demonstrated evidence of a worker deadlock.

## Local checks from the new R source head

- `air format` completed on the changed R tool and launcher test.
- Synthetic worker self-test: PASS. It verifies timeout argument construction,
  rejects invalid bounds, and proves a failing first worker prevents the
  second action from launching.
- Focused launcher test: PASS.
- Full `devtools::test()`: PASS (existing documented skips only).
- Fresh `R CMD build --no-build-vignettes`: PASS.
- Fresh ordinary `R CMD check --no-manual --no-vignettes`: stops only because
  optional Suggests package `pedigreemm` is unavailable locally.
- Fresh `_R_CHECK_FORCE_SUGGESTS_=false R CMD check --no-manual --no-vignettes`:
  Status OK; the missing optional package remains an explicit INFO.
- Julia `Pkg.test()`, Documenter build, and `tools/preamble_cap.sh`: PASS.
- Synthetic lifecycle tool sidecar: PASS (`ad082246bebce50ec79d8255f7f7997bcc2bc27a103b7221cfbba88dbec024cc`).
- `git diff --check`: PASS.

## Remaining gates

The new source head invalidates old exact-head CI and review receipts. Fresh
CI, narrow review batches, a clean and intentionally dirty Totoro deployment
control, and a fresh bounded full D0F-to-D1 lifecycle remain required before
S7 can clear. The official seed bases `2042000000` and `2043000000` remain
reserved and unspent.
