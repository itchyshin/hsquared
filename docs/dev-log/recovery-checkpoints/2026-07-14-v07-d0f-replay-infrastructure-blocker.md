# v0.7 D0F replay-infrastructure blocker and fresh-retry checkpoint

## Verdict

The first official D0F corpus is complete on the R side but permanently
**unadjudicated**. It is a `REPLAY_INFRASTRUCTURE_BLOCKER`, not scientific
recovery evidence and not a negative estimator result.

## Immutable blocked corpus

- Totoro root: `/home/snakagaw/hsq_work/v07-genomic-recovery-v3-d0f-official-0a9d882-1a538212`
- Official R attempts: 576/576 complete and converged.
- Independent base-R recomputations: 576/576 complete.
- Julia replay rows: 0.
- Preseal SHA-256: `2498301ca09949c584e74aa7bed0d468cd49cee893b1d6ded42d4785e30e1a32`.
- Corpus-lock SHA-256: `dee0bb91f40bf0e9183ff6ccd8525b3ba97271edae8819413f90d57fa94bb963`.
- Provisional R-summary SHA-256: `3f09b47037e8cfccb090efb2ea76bfa0825e1f01aed8ebacabd8b17731c577c2`.
- Presealed Julia replay commit/tool: `1a538212e258ca8e355ecd07420351a5097e3111` /
  `c8b4d2ceb4c01f807efa610002763fc1f5416c35a666427975a7f7972a3b0826`.

The Julia preflight validator called `only()` on all eight phenotype rows for
each fixed panel. It stopped before examining or writing any replay estimate.
Because the preseal binds the exact broken tool bytes, a repaired replay cannot
retroactively adjudicate this root. The provisional R summary is diagnostic
only and may not be pooled with, substituted for, or used to tune the retry.

## Prospective repair

The Julia validator now requires exactly phenotype ranks `1:8`, verifies that
all fixed-panel fields and fingerprints agree across those eight rows, and only
then selects rank 1 as the canonical 72-row panel representative. Positive and
mutation-red tests cover the valid 576-to-72 projection, duplicate/missing
ranks, a changed fixed-panel precision hash, and a changed rank-8 fingerprint.

The exact 576 spent phenotype seeds are now expanded as the true
3-design by 24-panel by 8-phenotype grid at base `2029000000`; the three spent
bootstrap seeds at base `2031000000` are also retired. The prospective retry
uses phenotype base `2032000000` and bootstrap base `2033000000`. The verifier
proves these spaces are unique, in range, and disjoint from all historical and
planned recovery-v3 seeds.

## Admission boundary

Before a retry phenotype is generated, both repaired twins must be committed,
five fresh hash-bound Fisher/Noether/Hopper/Grace/Rose receipts must pass, and a
new root and preseal must be minted. The 24-by-8 allocation, fixed panels,
estimand, ridge, model, summaries, tolerances, and stopping rules are unchanged.
D1 remains paused until the fresh D0F corpus is independently recomputed and
adjudicated.

No recovery, activation, capability promotion, G10, release, or
`public_covered_count` change follows from this checkpoint. The ordinary route
remains held and the count remains 5.
