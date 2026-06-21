# After-Task Report: GWAS Threshold Activation Contract

## Goal

Record the R-side contract for when experimental `gwas(fit, markers)` output may
grow user-facing calibrated genome-wide significance thresholds.

## Active Lenses

Ada, Shannon, Jason, Fisher, Curie, Rose, and Grace.

Spawned subagents: none.

## Files Changed

- `docs/design/28-gwas-threshold-activation-contract.md`
- `docs/design/11-next-50-slices.md`
- `docs/dev-log/check-log.md`
- `docs/dev-log/coordination-board.md`
- `docs/dev-log/after-task/2026-06-21-gwas-threshold-activation-contract.md`

## Checks Run

- `Rscript --vanilla -e 'pkgdown::check_pkgdown()'`
  - Result: clean.
- `git diff --check`
  - Result: clean.
- Boundary grep:
  - `rg -n "no threshold is activated|gwas\\(\\) remains experimental and uncalibrated|required calibrated-result fields|Validation Gates|external scan comparator|covered-status promotion" docs/design/28-gwas-threshold-activation-contract.md docs/design/11-next-50-slices.md docs/dev-log/check-log.md docs/dev-log/coordination-board.md docs/dev-log/after-task/2026-06-21-gwas-threshold-activation-contract.md`
  - Result: confirms the contract/non-activation boundary.

## Public Claim Audit

Clean. The slice does not change R behavior, public `gwas()` output, plots,
`validation_status()`, or capability status.

The current claim remains: `gwas()` reports nominal Wald p-values plus
Bonferroni/BH summaries over the supplied marker panel. It is not
genome-wide calibrated. HSquared.jl PR #134 is useful fixed-panel smoke
infrastructure, not an R threshold activation.

## Tests Of The Tests

This is a docs-only contract slice. The relevant test of the test is the
boundary grep: the edited surfaces name required fields and gates while also
stating that no threshold is activated.

## Coordination Notes

The next implementation slice should add a pure-R validator for optional
calibration metadata on `hs_gwas` objects and reject incomplete or inconsistent
threshold payloads. That still should not activate thresholds. A later slice can
consume a real engine calibration payload once Julia evidence and comparator
gates exist.

## What Did Not Go Smoothly

No implementation blocker. The main coordination hazard is terminology:
Bonferroni/BH summaries are already present, but they must stay framed as
deterministic supplied-panel summaries, not calibrated genome-wide thresholds.

## Known Limitations

- No permutation-backed cutoff.
- No realistic-LD production calibration.
- No external PLINK/GenABEL/GEMMA/GCTA-style comparator.
- No QTL/eQTL threshold activation.
- No covered-status promotion.

## Next Actions

1. Add an internal `hs_gwas` calibration-metadata validator with negative tests.
2. Consume a real engine calibration payload only after required fields are
   present and validation evidence exists.
3. Keep QTL/eQTL thresholds separate from post-fit GWAS thresholds.
