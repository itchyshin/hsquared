# Retry-7 D0F campaign — tail regression tests (PRE-2/PRE-3)

**Date:** 2026-07-17 · **Lane:** R twin (hsquared), executed by Claude under express
authorization for the Retry-7 D0F campaign de-risk. **Test-only** — no bound tool changed.

## What

Added +426 lines of regression tests to
`tests/testthat/test-v07-genomic-recovery-v3-recompute.R` (6 new `test_that` blocks + helpers
`v3r_test_d0f_mixed_fixture` / `v3r_test_as_julia` / `v3r_test_route_binding` /
`v3r_test_d0f_bootstrap_sha`). They exercise the D0F adjudicator/receipt **tail** — where 6/6
prior retries died — at full 576 cardinality across all boundary-classification arms
(interior / interior_rescued / boundary_lower / boundary_upper / boundary_unresolved / error) and
**both** summary routes (`ordinary_auto_genomic` / `julia_profile_replay`):

- 576-conservation across all six arms + both routes; ordinary-vs-julia summary adjudication
  (`v3p_adjudicate_summaries`), incl. a negative (mutated `n_boundary_lower` → `summary mismatch`).
- Partial-failure denominator/`D0F_FIT_BLOCKER`/NA-arms + `attempts[-1L,]` rejection.
- Isolated-scratch-root `v3r_expected_summary` route dispatch at D0F (official + julia).
- Tag/tally position- and route-invariance; 576 route-lineage per kind.
- Boolean lowercase write/read/adjudicate (`v07d_format` → `"false"`); create-once byte-identical
  receipt from a fit-blocker summary; forged-route rejection at D0F.

## Result

`Rscript -e 'testthat::test_file(...)'` → **209 assertions, 0 failed, 0 warnings, 0 skipped**
(baseline 163 + 46 new; existing tests untouched). Bound tools byte-identical to the sealed bound
commit `9f7ed27` (empty `git diff --stat 9f7ed27 -- tools/`).

## Review (author ≠ reviewer)

Spawned fresh-context reviews: **Rose → PROMOTE**, **Hopper → SOUND-WITH-NOTES**. Both independently
traced the campaign adjudication path and confirmed coverage is genuine (all six arms non-zero,
192/design, 576 total; Variant-B fixture satisfies `v3p_validate_unsuccessful_results` field-for-field).

## Latent finding (characterized CAMPAIGN-SAFE; recorded, not fixed)

`v3p_compare_tables` (`tools/v07_genomic_recovery_v3_preseal.R:2479`) infers logical fields from the
**LEFT arg only**. A disk-read (character `"false"`) table in the LEFT/driver slot would mismatch an
in-memory logical `FALSE` — the **offset-7101 class**. Both reviewers independently traced every
campaign call site (`v3r_adjudicate_tables` `recompute.R:1559-1571`; `v3r_compare_summary_triplet`;
`v3p_adjudicate_summaries`) and confirmed the in-memory logical **driver is ALWAYS the LEFT arg** and
disk-read summaries are always RIGHT — so the asymmetry **cannot bite the campaign path**. It is truly
latent, guarded today only by call-site convention (an unasserted "driver-is-LEFT" invariant), not by
a guard inside `v3p_compare_tables`. **Deferred defensive-hardening** (a later slice): add a guard /
symmetric logical detection, or a note, so a future sealed-tool refactor that fed a disk-read summary
as driver cannot silently resurrect the class. Not a blocker for this campaign.

## Discipline

Test-only; nothing pushed (local commit on the shared `codex/` branch, per the no-race guard);
carried-over retry5 docs untouched; no phenotype, no Julia, no Totoro. This de-risks the tail before
any official seed is spent.
