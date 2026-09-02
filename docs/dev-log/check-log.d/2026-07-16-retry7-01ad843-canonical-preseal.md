# Retry-7 canonical D0F preseal after sidecar repair

**Date:** 2026-07-16  
**Scope:** canonical preseal only. It binds the repaired implementation before
any official RNG use; it does not materialize bootstrap indices, draw a
phenotype, create a corpus, recompute, or fit a model.

## Admission packet

- R source and auto-route commit:
  `01ad843c8a2968b9180188f70bf9955cf433908c`
- Julia replay and candidate commit:
  `976814393043d3a4af5ce343d8ac4b05c43eac41`
- Recovery-v3 driver SHA-256:
  `35fb2630e5f706694111e65aa5544ff9e37469bbe987f76541785ade90080543`
- Full local R test: 2,991 pass, 0 fail, 0 warn; Julia package tests passed.
- Exact-source R-CMD-check:
  [run 29537291400](https://github.com/itchyshin/hsquared/actions/runs/29537291400),
  success.
- Fresh Totoro synthetic lifecycle: D0F `COMPLETE`, D1 `ELIGIBLE=12`.
- Fresh Batch A and Batch B receipts from Grace and Rose: all `CLEAN`.

The enforced `gpt-5.6-sol` / `ultra` adjudication returned
`CLEAR_PRESEAL`, requiring the seal to precede any official material.

## Canonical root and seal

- Root: `/home/snakagaw/hsq_work/retry7-preseal-01ad843-97681439`
- Stage root: `/home/snakagaw/hsq_work/retry7-preseal-01ad843-97681439/d0f`
- Stage preseal SHA-256:
  `3013cbabee4c6374b0def49f205e81faa93cb7cfde484867ca7ba9c1f748809b`
- Bound D0F bootstrap base: `2043000000`
- `d0f_bootstrap_indices_absent_before_preseal`: `true`
- `output_subtrees_absent_before_preseal`: `true`

The stage preparation copied five create-once structural review receipts and
created the document, cell-table, seed-lock, fixed-panel, manifest, and
environment bindings before the seal.

## Independent chronology audit

The audit re-read and validated the stage preseal against the deployed
context, revalidated the historical seed spaces, and checked both `RNGkind()`
and `.Random.seed` around the audit. It passed:

`CHRONOLOGY_AUDIT_PASS ... rng_unchanged=true official_outputs_absent=true`

The following remained absent: bootstrap indices (and sidecar), attempts,
recomputations, corpus, and stage adjudication output.

## Boundary

The preseal authorizes only the next controlled materialization step under its
own contract. It is not a result, an activation, a public-coverage change, or
authorization for the 576-fit campaign.
