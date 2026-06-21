# After-task report: multivariate comparator availability

Date: 2026-06-21

## Task goal

Advance the multivariate validation/comparator lane by proving the current
local blocker for the next same-estimand REML comparator beyond `sommer`, and
recording the exact next run instructions for a machine with the required
tools.

## Active lenses and spawned agents

- Active lenses: Ada, Shannon, Jason, Curie, Fisher, Rose, Grace.
- Spawned agents: none.
- Current lane: R validation/comparator.

## Files changed

- `docs/dev-log/comparator-runs/2026-06-21-multivariate-tool-availability.md`
- `docs/dev-log/comparator-runs/README.md`
- `docs/dev-log/check-log.md`
- `docs/dev-log/coordination-board.md`

The two pre-existing untracked Codex handover files were left untouched.

## Checks run and outcomes

- `Rscript --vanilla -e 'pkgdown::check_pkgdown()'` - clean.
- `git diff --check` - clean.
- Claim-boundary grep over the changed report/check-log/board files confirmed
  the slice is framed as a blocker report, not new comparator evidence.

## Public claim audit

Allowed claim: this host can rerun the existing `sommer` and `MCMCglmm` legs,
but lacks local ASReml/BLUPF90-family/DMU/WOMBAT tooling for the next
same-estimand REML comparator.

Blocked claims:

- New comparator evidence.
- Same-estimand parity beyond `sommer`.
- V4-MV-REML covered promotion.
- Any change to `validation_status()`.

## Tests of the tests

This is a docs/provenance slice. The executable and R-package probes are copied
verbatim into the report so the blocker is reproducible.

## Known limitations

The report proves local unavailability only. It does not say the comparator
cannot be run elsewhere, and it does not replace a future sanitized run report.

## Next actions

1. Run the BLUPF90-family starter packet on a host with `renumf90` and
   `airemlf90`, or use licensed ASReml-R.
2. Record the run using `docs/dev-log/comparator-runs/TEMPLATE.md`.
3. Only then revisit multivariate validation-status promotion.
