# Retry-7 D0F bootstrap materialization — repaired exact head

**Date:** 2026-07-16
**Scope:** D0F bootstrap indices only. No phenotype seed, attempt, fit,
recomputation, corpus lock, adjudication, or D1 action was invoked.

## Canonical sealed root

- Totoro root: `/home/snakagaw/hsq_work/retry7-preseal-9f7ed27-97681439-c`
- Stage root: `/home/snakagaw/hsq_work/retry7-preseal-9f7ed27-97681439-c/d0f`
- R driver/recomputer commit: `9f7ed27263b19a486a595f81b1c0b1a8b94702f6`
- Julia replay/candidate commit: `976814393043d3a4af5ce343d8ac4b05c43eac41`
- Stage-preseal SHA-256:
  `be42dc7d58f8747fdc7bff44c553a630bba4da48c05b9ce8faae97b32e87a312`

The materializer was invoked exactly once through
`run-v07-genomic-recovery-v3.sh materialize-bootstrap`. It first accepted the
pristine sealed stage, then wrote only the create-once bootstrap primary and
sidecar, and completed its post-write bound-stage validation.

## Receipt

- Bootstrap manifest: `d0f_bootstrap_indices.tsv`
- Manifest SHA-256:
  `f53967b5496aef51fcbac166e8dc5a00aaa6d69f8a8eb68cca42c05adbff7162`
- Sidecar SHA-256:
  `ac49fb10a2b2cb9969b8ce2adc7030934f2c719afda29dfc0d7ceda0d634fc78`
- Rows: `720001` including header (`720000` bootstrap rows)
- Deterministic byte comparison against
  `v3p_d0f_bootstrap_manifest(10000L)`: passed.

The revalidated preseal continues to bind the unspent phenotype space and the
reserved bootstrap base `2043000000`. No phenotype-related namespace or other
forbidden runtime output exists in the stage root.

## Hard stop

This receipt does **not** admit Julia preflight, chronology auditing for
phenotype admission, phenotype generation, fitting, D0F adjudication, D1-D4,
activation, merge, or release. The next gate requires separate explicit
authorization.
