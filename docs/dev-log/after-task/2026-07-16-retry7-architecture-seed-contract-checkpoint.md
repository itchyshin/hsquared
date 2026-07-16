# Retry-7 architecture and seed-contract checkpoint

## 1. Goal

Close the research-informed Retry-7 route/adjudicator architecture and reserve
new disjoint D0F seed spaces without invoking official RNG.

## 2. Implemented

- Replaced mutable/defaulted route reconstruction with locked, route-specific
  admitted-evidence envelopes and S3 summary dispatch.
- Added canonical weighted route-lineage evidence for D0F and D1, five-review
  lineage binding, adjudication schema v2, a deterministic adjudication key,
  and byte-identical primary/sidecar receipt retry semantics.
- Added a full 576-row synthetic D0F-to-D1 lifecycle and a fail-closed mutation
  suite, including route forgery, lineage, receipt, chronology, concurrency,
  deployment, and post-preseal mutations.
- Amended Doc 49 for research-informed Retry 7 and reserved phenotype base
  `2042000000` plus bootstrap base `2043000000`. Expanding and checking these
  grids consumed no RNG.

## 3a. Decisions and Rejected Alternatives

Route identity is sealed at the R serialization boundary because TSV erases
Julia parametric types; Julia route types remain defence-in-depth. A caller
route argument and a mutable status field were rejected. Generic write-once
semantics remain strict; only the adjudication receipt has an exact-idempotent
recognition path. Shuffle invariance was rejected as insufficient because the
Retry-6 rebind was order-independent; weighted route-count conservation is the
decisive gate.

## 4. Files Touched

- `docs/design/49-v07-genomic-recovery-v3-sample-size-ladder.md`
- `docs/dev-log/after-task/2026-07-16-retry7-architecture-seed-contract-checkpoint.md`
- `docs/dev-log/check-log.md`
- `docs/dev-log/coordination-board.md`
- `tests/testthat/test-v07-genomic-recovery-v3-admission.R`
- `tests/testthat/test-v07-genomic-recovery-v3-downstream-contract.R`
- `tests/testthat/test-v07-genomic-recovery-v3-driver.R`
- `tests/testthat/test-v07-genomic-recovery-v3-launcher.R`
- `tests/testthat/test-v07-genomic-recovery-v3-preseal.R`
- `tests/testthat/test-v07-genomic-recovery-v3-recompute.R`
- `tests/testthat/test-v07-genomic-recovery-v3-retry7-mutations.R`
- `tests/testthat/test-v07-genomic-recovery-v3-tooling.R`
- `tools/run-v07-genomic-recovery-v3.sh`
- `tools/v07_genomic_recovery_v3.R`
- `tools/v07_genomic_recovery_v3_admission.R`
- `tools/v07_genomic_recovery_v3_admission.R.sha256`
- `tools/v07_genomic_recovery_v3_downstream_contract.R`
- `tools/v07_genomic_recovery_v3_downstream_contract.R.sha256`
- `tools/v07_genomic_recovery_v3_preseal.R`
- `tools/v07_genomic_recovery_v3_recompute.R`
- `tools/v07_genomic_recovery_v3_recompute.R.sha256`
- `tools/v07_genomic_recovery_v3_seed_lock.R`
- `tools/v07_genomic_recovery_v3_synthetic_lifecycle.R`
- `tools/v07_genomic_recovery_v3_synthetic_lifecycle.R.sha256`

The two modified Retry-5 draft reports are protected foreign state and were not
inspected, edited, staged, or included.

## 5. Checks Run

- Seed-lock selftest: PASS; 42,067 historical/retired seeds, 579 Retry-7
  reservations, and 91,728 D1-D4 candidates are mutually disjoint.
- Focused preseal, recompute, tooling, launcher, admission, downstream, driver,
  and mutation tests: PASS.
- `HSQUARED_RUN_RETRY7_MUTATIONS=true devtools::test(...)`: PASS with 59
  documented live/comparator skips and no failures.
- Canonical local synthetic lifecycle at
  `/private/tmp/hsq-retry7-synthetic-s7-canonical-v3`: D0F
  `PASS/COMPLETE`, D1 `PASS/ELIGIBLE=12`, five CLEAN reviews per stage,
  byte-identical retries, and `validate-final` PASS.
- `git diff --check`: PASS. Full `R CMD check` remains deliberately assigned to
  the fresh Terra/high implementation lane.

## 6. Tests of the Tests

The red controls reproduced default-route rebinding before repair and now reject
missing/rebound routes, raw frames, forged classes, changed row bytes, wrong
tool provenance, lineage count/group/inventory mutations, premature reviews,
relocated/orphaned reviews, stale/conflicting/orphaned receipts,
parse-equivalent but byte-different receipt pairs, concurrent writers, dirty
deployment, nested/unadjudicated predecessors, RNG drift, and post-preseal tree
mutation. Every rejected mutation checks receipt absence and/or unchanged tree
digest at its earliest gate.

## 7a. Issue Ledger

- Fixed: mutable route identity and default route rebinding.
- Fixed: synthetic helper initially bound its own bytes as recomputer bytes.
- Fixed: receipt retry accepted parse-equivalent noncanonical bytes.
- Fixed: test tree digest included mutable `.git` metadata.
- Fixed: stale Retry-6 seed and bootstrap-parity pins after Retry-7 reservation.
- Deferred: clean Totoro launcher rehearsal, `R CMD check`, exact-head CI and
  reviews, preseal, chronology audit, and official campaign.

## 8. Consistency Audit

The route, lineage, receipt, review, D1 predecessor, launcher, preseal, and seed
contracts were checked across their R and Julia consumers. No public R API,
formula grammar, result payload, or engine numerical surface changed. Retired
Retry-1--6 roots/spaces remain immutable; the H2-2 drafts and quarantined Julia
scaffold remain excluded.

## 9. What Did Not Go Smoothly

Three independent reviews found genuine pre-seed defects: mutable R envelope
forgery, stale Julia receipt schema, and synthetic recomputer misbinding. Fresh
tests also exposed a `.git`-inclusive digest oracle, uppercase synthetic
booleans, stale review bindings, and noncanonical receipt-byte acceptance. A
raw `testthat::test_dir()` run was stopped because it does not load the package
namespace; the correct `devtools::test()` run passed.

## 10. Known Residuals

The local lifecycle uses precomputed synthetic recomputation/replay evidence and
an explicit deployment-projection seam. It does not prove clean remote
deployment or production compute. No exact-head review receipt, preseal,
bootstrap manifest, phenotype, official fit, adjudication, D1 compute, or
activation exists yet.

## 11. Team Learning

Memory receipt: loaded `hsquared-rehydrate`, `ultra-plan`,
`engine-contract-review`, `r-package-development`, `testing-r-packages`, and
`after-task-audit`; they enforced sole ownership, contract boundaries,
red-to-green tests, and repo-visible closeout.

Golden Set: not in scope; this arc repaired a repo-specific adjudicator failure
and did not alter the brain retrieval system.

## 12. Cross-Product Coverage

Covers: internal D0F/D1 evidence admission, summary reconstruction, weighted
route lineage, review/receipt provenance, exact receipt retry, synthetic
lifecycle, and Retry-7 seed reservation.

Does NOT cover: public marker-route activation, `public_covered_count`, G10,
actual D1-D4 compute, public API/payload changes, release, merge, remote compute,
or scientific Retry-7 results.
