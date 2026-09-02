# Retry-7 exact-head local gate — 2026-07-16

Scope: source-safe, pre-RNG verification of R `b190a0cebbefa9af195b0722a5ab77be72474a71`
with Julia replay head `976814393043d3a4af5ce343d8ac4b05c43eac41`.
No official phenotype or bootstrap seed was invoked.

## R package gate

- Focused `devtools::test(filter = "v07-genomic-recovery-v3")`: PASS.
- Full `devtools::test()`: `PASS 2983`, `FAIL 0`, `WARN 0`, `SKIP 69`.
- Fresh `R CMD build .`: PASS.
- Initial `R CMD check --no-manual`: stopped only because optional Suggests
  package `pedigreemm` is unavailable locally.
- Fresh `_R_CHECK_FORCE_SUGGESTS_=false R CMD check --no-manual`: `Status: OK`;
  `pedigreemm` is recorded as unavailable-for-checking INFO, not hidden.

## Full-cardinality synthetic D0F-to-D1 rehearsal

The first local invocation correctly failed closed when the real subprocess
recomputation guard rejected a non-Totoro/non-DRAC host. The documented,
tested `HSQUARED_RETRY7_SYNTHETIC_LOCAL=true` synthetic-only worker exemption
was then used; it does not invoke official compute or a reserved seed.

- Root: `/private/tmp/hsq-retry7-synthetic-exacthead-local-b190a0c-97681439`.
- D0F: 576-row manifest; receipt SHA-256
  `3f34d389025ecddd842c84af4a5dad00b80cc427f37231981f7b3448f5ce32d2`;
  route-lineage SHA-256
  `fc45ab55c0a40c57f100a668138ea21ff23e5237726f579f2bbe9c6480c0168d`;
  `PASS` / `COMPLETE`; official/base-R/Julia lineage weights each 576.
- D1: 576-row manifest; receipt SHA-256
  `ae99bee82bfd6e5239b8d0551b6c64f71e4fbdf13243582a4b20eae9b711b0f3`;
  route-lineage SHA-256
  `46f7d7d41af538981ec2e926ac6da20ff6a8a0a32f2c9c3261173e7dc00569f6`;
  `PASS` / `ELIGIBLE=12`; official/base-R/Julia lineage weights each 576.
- Both stages exercised real R subprocess summary, lineage, five post-run
  `CLEAN` review receipts, adjudication, idempotent receipt recognition, and
  final-tree validation. The deterministic sorted-file digest-list SHA-256 is
  `17915dd0be4bec67de9011056da3a63569ae1dfdbfd39bbf8560b9716247f1a2`.

This is synthetic architecture evidence only. It does not replace exact-head
CI, independent review batches, clean Totoro deployment, preseal, chronology,
or any official D0F compute.
