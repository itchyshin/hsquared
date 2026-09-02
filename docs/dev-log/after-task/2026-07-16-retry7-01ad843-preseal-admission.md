# After-task audit — Retry-7 repaired-sidecar preseal admission

## Goal

Restart the exact-head pre-RNG admission packet after correcting the
recovery-v3 driver sidecar, then write and audit a canonical D0F preseal
without consuming any official RNG.

## Active lenses and agents

Grace and Rose completed fresh, separate Batch A and Batch B reviews. Sol was
used as the single enforced ceiling adjudicator (`gpt-5.6-sol`, ultra effort),
and returned `CLEAR_PRESEAL`.

## Files changed

- `tools/v07_genomic_recovery_v3.R.sha256` — corrected before this restarted
  packet (source commit `01ad843`).
- `docs/dev-log/check-log.d/2026-07-16-retry7-01ad843-exact-head-rehearsal.md`
- `docs/dev-log/check-log.d/2026-07-16-retry7-01ad843-canonical-preseal.md`
- `docs/dev-log/reviews/2026-07-16-retry7-01ad843-batch-*.tsv`
- `docs/dev-log/check-log.md` and `docs/dev-log/coordination-board.md`

## Checks and outcomes

- Full R suite: 2,991 pass, 0 fail, 0 warn; 69 documented skips.
- Julia `Pkg.test()`: passed; docs build completed with pre-existing warnings;
  preamble cap passed.
- Exact R-source GitHub R-CMD-check run `29537291400`: success.
- Local R-CMD-check: no errors; two existing vignette warnings under
  non-forced Suggests.
- Fresh clean Totoro synthetic lifecycle: passed, D0F `COMPLETE`, D1
  `ELIGIBLE=12`, matching R/Julia summaries.
- Fresh dirty Totoro deployment control: rejected with exit 1.
- Canonical preseal audit: passed with `rng_unchanged=true` and
  `official_outputs_absent=true`.

## Public-claim audit

Nothing is activated or promoted. The preseal is a chronology and provenance
boundary, not evidence of an official recovery result or public coverage.

## Tests of the tests

The clean deployment accepted the exact source and the independent dirty clone
was rejected. Synthetic R and Julia D0F/D1 summaries matched, and all five
synthetic reviewer receipts were clean at both stages.

## Coordination notes

Earlier exact-head evidence was explicitly discarded because the sidecar was a
tool byte. All review and remote evidence cited here was recreated after that
repair; none was reused as clearance.

## What did not go smoothly

Canonical preparation initially failed safely because the one-thread runtime
environment, then Totoro's pinned Julia `PATH`, were absent. Each failed
prepare removed its incomplete stage root; no preseal existed until the
successful, fully pinned invocation.

## Known limitations

Only synthetic lifecycle evidence exists. Official bootstrap material,
phenotype data, attempts, recomputations, corpus, fit results, and
adjudication remain absent. The local R check retains two known vignette
warnings.

## Next action

In a fresh controlled task, reread the canonical preseal and audit record,
then perform only the bound bootstrap-materialization step. Do not widen into
phenotype generation or fitting without its separate gate.
