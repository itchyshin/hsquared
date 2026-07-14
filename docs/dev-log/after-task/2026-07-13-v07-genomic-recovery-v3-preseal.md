# After-task report — v0.7 genomic recovery-v3 pure preseal layer

## 1. Goal

Build a prospective, acyclic, cross-twin evidence contract for D0F and D1 that
cannot generate or admit official recovery data until exact code, environment,
review, provenance, tree, and mutation gates are satisfied.

## 2. Implemented

- Amended doc 49 after Fisher/Curie and adversarial bridge/reproducibility
  review.
- Added the canonical 36-cell table.
- Added pure R preseal, manifest, admission, summary, provenance, and parity
  kernels plus focused mutation tests.
- Added the Julia packet/replay/summary verifier with typed D0F/D1 parity.
- Repaired the historical v2 test so it asserts immutable candidate Git objects
  without requiring evolving HEAD to equal the execution checkout.

## 3a. Decisions and Rejected Alternatives

- Changed D0F from 8 panels x 24 phenotypes to 24 x 8 at the same 576 fits;
  bootstrap replication cannot manufacture independent panels.
- Replaced the impossible cyclic seal with preseal -> corpus lock ->
  recomputation -> adjudication.
- Kept official R runtime/RSS as the scientific performance source; Julia
  replay performance is diagnostic only.
- Did not weaken exact commit/tree gates, reinterpret failed cells, generate
  seeds, or promote the route.

## 4. Files Touched

- `docs/design/49-v07-genomic-recovery-v3-sample-size-ladder.md`
- `docs/design/v07_genomic_recovery_v3_cell_table.tsv`
- `tools/v07_genomic_recovery_v3_preseal.R`
- `tests/testthat/test-v07-genomic-recovery-v3-preseal.R`
- `tests/testthat/test-v07-genomic-recovery-v2.R`
- the D0 check-log wording correction
- this report, the matching check log, and coordination/check-log indices
- Julia twin `sim/phase2_v07_genomic_recovery_v3_stage_replay.jl` plus mirrored
  repo-visible evidence.

## 5. Checks Run

See `docs/dev-log/check-log.d/2026-07-13-v07-genomic-recovery-v3-preseal.md`.
The full R suite finished at 2,276 pass / 0 fail / 0 warn / 68 skip; the full
Julia suite and both focused selftests passed.

## 6. Tests of the Tests

Every material evidence surface has an executable red mutation, including
trees, sidecars, commits/blobs, live environment, D0 identity, failed attempts,
low convergence, information degeneracy, all parity fields, and performance
source selection.

## 7a. Issue Ledger

| Issue | Disposition |
| --- | --- |
| Cyclic stage seal | Replaced prospectively by an acyclic four-step chain. |
| Weak between-panel D0F allocation | Changed prospectively to 24 x 8. |
| Declarative hashes/environment | Replaced with live primary, sidecar, Git-blob, ancestry, clean-tree, and runtime verification. |
| Cross-language summary drift | Frozen typed D0F and D1 fixtures with mutation-red gates. |
| Missing official driver/adjudicator | Explicit next-slice blocker; all official/final modes remain fail-closed. |

## 8. Consistency Audit

The sweep covered doc 49, the actual committed table, both tools, all ordered
schemas, v2 historical provenance, D0 immutable evidence, tree phases, route
provenance, runtime semantics, and public claim boundaries. Capability and
validation rows remain unchanged because this slice creates no recovery
evidence.

## 9. What Did Not Go Smoothly

Ordinary selftests initially missed a cryptographic cycle, declarative receipt
hashes, malformed unsuccessful rows, 0/1-success summaries, zero-information
ratios, path encoding under R 4.6, substring host matching, path-scoped clean
checks, deleted Git surfaces, decimal table representation, and a floating
`1 - 0.8` canonicalization difference. Independent adversarial reviews found
these before any official phenotype.

## 10. Known Residuals

- No official D0F/D1 driver, base-R recomputer, adjudicator, launcher, preseal,
  phenotype, attempt, or result exists yet.
- D2-D4, postrun reviews, Rose activation audit, G10, default-route merge, and
  any capability/count change remain pending.
- The planned evidence remains conditional on HWE/no-LD markers, sample allele
  frequencies, VanRaden1, ridge 0.01, Gaussian REML, and validation-scale dense
  fitting.

## 11. Team Learning

Before trusting a green, mutate the gate and inspect the dependency graph. A
cryptographic receipt is only evidence when its inputs are actual verified
primaries and no hash depends transitively on itself.

## 12. Cross-Product Coverage

This slice covers prospective evidence integrity for the narrow held genomic
route. It does not cover recovery, robustness, production scale, activation,
release, or a new covered capability. `public_covered_count` remains 5.
