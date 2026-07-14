# After-task report — v0.7 D0F replay repair and fresh retry

## 1. Goal

Preserve the failed official D0F corpus honestly, repair the deterministic
Julia preflight defect, and prospectively preregister a disjoint fresh D0F retry
without changing the scientific design.

## 2. Implemented

Retired the exact spent phenotype and bootstrap seed spaces, assigned new
disjoint retry bases, repaired the cross-twin fixed-panel validation contract,
recorded the failed root and hash ledger as unadjudicated evidence, and made D1
preparation/preseal fail closed unless it binds an exact external fresh-D0F
`PASS`/`COMPLETE` adjudication receipt whose complete final evidence tree is
independently reconstructed and validated.

## 3a. Decisions and Rejected Alternatives

A patched replay of the old corpus was rejected because its preseal binds the
broken Julia bytes. Reusing seeds, pooling estimates, relaxing thresholds, or
describing the incident as estimator failure were also rejected. The admitted
path is a fresh prospective retry with unchanged scientific contracts.

## 4. Files Touched

Doc 49, the seed-lock and preseal helpers, their direct tests, this report, the
recovery checkpoint, coordination/check-log/status ledgers, and the Julia twin
replay tool plus its sidecar and evidence notes.

## 5. Checks Run

The R seed-lock, driver, and preseal selftests pass. The focused R seed-lock,
launcher, and preseal test files pass warning-free. The Julia replay selftest
and full `Pkg.test()` pass. The Julia
tool sidecar and both worktree diff checks pass. A built-package
`R CMD check --no-manual` passes with status `OK`, including package tests.
Exact final commits and remote CI are still pending at this report stage.

## 6. Tests of the Tests

Controls turn red for a retired-seed collision, a duplicate proposed seed, the
known historical collision `2027142001`, an out-of-range bootstrap base,
duplicate/missing phenotype rank, changed fixed-panel precision, and a changed
rank-8 panel fingerprint. D1 also turns red for a non-COMPLETE predecessor,
wrong receipt hash, nested root, or the known blocked D0F root.

## 7a. Issue Ledger

| Issue | Disposition |
| --- | --- |
| Julia expected one D0F row per fixed panel | Require all eight ranks and common panel fingerprints before canonical projection. |
| Earlier seed audit expanded 3x8x24 instead of 3x24x8 | Replaced with the exact consumed grid and mutation-tested denominators. |
| Old preseal cannot admit repaired bytes | Preserve the old root unadjudicated and preregister a fresh retry. |
| Old bootstrap seeds were not fitted | Retire them anyway because they generated the observed provisional summary. |
| D1 sequencing was documented but not enforced | Stage-preseal schema 2 requires a canonical external D0F PASS/COMPLETE receipt and exact receipt hash before D1 preparation/preseal. |
| A forged receipt-only root passed the first schema-2 repair | D1 now invokes the operational exact final-tree validator; receipt-only roots fail. The launcher validates once before fan-out, and unattested direct workers validate fully. |
| Live admission did not execute the seed-space helper | Prepare and preseal now run exact historical/proposed disjointness, plus the D0F bootstrap-space gate. |
| The retired root was called physically immutable/read-only | Corrected to hash-locked, logically frozen, and never reused; its filesystem permissions remain writable. |

## 8. Consistency Audit

The sweep covered the old root, preseal, corpus lock, R summary, zero Julia
outputs, exact seed formulae, integer limits, cross-stage collisions, bootstrap
parity, unchanged D1 logic, capability wording, and both twin worktrees.

Memory receipt: the repository `AGENTS.md`, the rehydration skill, and prior
twin-package coordination memory required a live two-repository sweep and
repo-grounded status check. Repository files, tests, Git, and Totoro remained
technical truth. `route.py` returned no `LOAD-FIRST` manifest for this checkout.

Golden Set: this was a live validator and seed-enumeration defect,
not a suspected brain-retrieval regression, so the retrieval Golden Set was not
run.

## 9. What Did Not Go Smoothly

The original official R corpus completed before the Julia replay validator
exposed its cardinality bug. A neighbouring seed-lock defect then showed that
the earlier disjointness audit had not enumerated the exact consumed axes.
Neither defect changed an estimate, but both invalidated formal admission. A
local full `devtools::test()` sequence under testthat 3.3.2 also lost visibility
of the long-standing `helper-simulation.R` function in its final validation
file; that file passes in isolation and the clean built-package `R CMD check`
passes all tests, so this was recorded as a local runner residual rather than
widening the repair.

## 10. Known Residuals

Fisher's first exact review found the prose-only D1 sequencing gap, invalidating
that review set. The repaired commits still require five new preseal reviews and exact Totoro
deployment. Fresh D0F, independent recomputation, adjudication, D1, conditional
D2-D4, final Rose review, and G10 remain outstanding.

## 11. Team Learning

Preflight tooling is part of the experiment. A green stochastic run is not
evidence until every presealed independent replay and admission gate can pass;
seed-space audits must enumerate the scientific axes, not merely the expected
row count, and stage dependencies must be executable gates rather than prose.

## 12. Cross-Product Coverage

This slice repairs prospective evidence machinery only. It does NOT cover
recovery, robustness, activation, production scale, or a new capability.
`public_covered_count` remains 5.
