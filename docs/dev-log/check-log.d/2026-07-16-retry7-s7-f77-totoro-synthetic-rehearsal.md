# Retry-7 S7 exact-head Totoro synthetic rehearsal

**Date:** 2026-07-16  
**Scope:** pre-RNG deployment rehearsal only; no official phenotype or bootstrap
seed was materialized or consumed.

## Exact deployed heads

- R: `f77acc072c6d917fb86855fb49dfd8f222c3d7ce`
- Julia: `976814393043d3a4af5ce343d8ac4b05c43eac41`
- Clean sibling deployment root:
  `/home/snakagaw/hsq_work/retry7-s7-receipt-f77acc0-97681439`
- Lifecycle workspace:
  `/home/snakagaw/hsq_work/retry7-s7-receipt-f77acc0-97681439/synthetic-lifecycle`

Both deployed clone status checks were empty before the rehearsal.

## Result

The deployed launcher completed the full synthetic D0F-to-D1 lifecycle under
the receipt-bound worker configuration (`timeout=900`, `TERM`, 15-second kill
grace): `recovery-v3 synthetic lifecycle: PASS`.

- Synthetic run receipt:
  `72f902d93b3eea0095c45f18b51f6783636ed3713f1d8096066a01a3beea0f0c`
- D0F adjudication receipt (`COMPLETE`):
  `6df58977ac430a8abeedff63e72b0d889923d0c342fb4dba5ced622afab1415b`
- D1 adjudication receipt (`ELIGIBLE=12`):
  `e5bd7c8c1b72207060ee3387a573712d0f8d12009fe10830dee0e0a1aeb73e16`
- D0F route lineage (9 rows):
  `b7641b1e50776e3a4a29163b813ccb76258fc5a9049bd043fadfe5cb53ce0793`
- D1 route lineage (36 rows):
  `82606a1ea2b67e59bd4ff3f82950a78dddb4d094b920d62006eb6278660df1b0`
- Launcher log:
  `cbbdb65cf43f195633c625b9d249fcfaa86b29bdf26d2dff328e7601a41c48ca`

The run logged five CLEAN post-run reviews for each stage, recognised an
existing byte-identical receipt, and completed D0F and D1 final validation.
The receipt and each adjudication receipt matched its `.sha256` sidecar.

## Dirty-deployment negative control

An independent sibling clone at
`/home/snakagaw/hsq_work/retry7-s7-receipt-f77acc0-dirty-control` received only
a control sentinel. `deployment-check` exited 1 and emitted
`deployed implementation worktree is dirty`, as required. This control did not
touch the clean deployment or lifecycle workspace.

## Refreshed local built-source check

`R CMD build --no-build-vignettes` followed by
`_R_CHECK_FORCE_SUGGESTS_=false R CMD check --no-manual` completed from an
isolated temporary directory on the exact R head. The result was
`Status: 2 WARNINGs`: the existing `vignettes/hsquared.Rmd` has no matching
`inst/doc` output. `pedigreemm` is unavailable locally and was reported as a
non-fatal Suggests INFO under the deliberate non-forced-Suggests setting.
Tests completed (`Running 'testthat.R'`).

## Boundary

This is rehearsal evidence only. It does not preseal a canonical root, perform
the Sol seed-contract/chronology decision, materialize bootstrap data, draw a
phenotype, or authorize the 576-fit campaign.
