# After-task report: Julia #134 GWAS calibration sync

Date: 2026-06-21

## Goal

Synchronize R-lane wording after HSquared.jl PR #134 banked the fixed-panel
threshold calibration smoke harness, without activating any R-side significance
claim.

## Active Lenses And Agents

Active lenses: Ada, Shannon, Jason, Fisher, Rose, Grace.

Spawned agents: none.

## Files Changed

- `R/gwas.R`
- `R/autoplot.R`
- `docs/design/capability-status.md`
- `docs/design/validation-debt-register.md`
- `docs/dev-log/issue-map.md`
- `docs/dev-log/check-log.md`
- `docs/dev-log/coordination-board.md`
- `docs/dev-log/after-task/2026-06-21-julia-134-calibration-sync.md`

The unrelated Codex handover files remain untracked and untouched.

## What Changed

Replaced stale R-facing "gate #48" wording with the current split: Julia has
banked a fixed-marker-panel calibration smoke harness in PR #134, but R
`gwas()` still reports nominal Wald p-values with Bonferroni/BH over supplied
markers only.

The issue map now records that HSquared.jl #48 is closed while #45/#61 still
hold marker-scan bridge and coordination follow-up.

## Checks Run

- `air format .`: clean.
- `Rscript --vanilla -e 'devtools::document()'`: regenerated
  `man/gwas.Rd` and `man/hsquared-autoplot.Rd`.
- `Rscript --vanilla -e 'devtools::test(filter =
  "gwas|autoplot|phase0-api|fit-object")'`: 354 pass / 0 fail / 0 warn / 2
  skip.
- `Rscript --vanilla -e 'devtools::test()'`: 1301 pass / 0 fail / 0 warn / 58
  skip.
- `Rscript --vanilla -e 'pkgdown::check_pkgdown()'`: clean.
- Stale #48 wording audit across `R`, `docs/design`, `docs/dev-log/issue-map.md`,
  `man`, `vignettes`, `NEWS.md`, and `tests`: clean.
- `git diff --check`: clean.
- `_R_CHECK_FORCE_SUGGESTS_=false Rscript --vanilla -e
  'rcmdcheck::rcmdcheck(args = "--no-manual", error_on = "never")'`: 0 errors /
  0 warnings / 0 notes.

## Public Claim Audit

No public capability claim was promoted. This slice does not activate calibrated
R significance thresholds, does not add a permutation-calibrated cutoff, does
not claim realistic-LD production calibration, and does not claim an external
PLINK/GenABEL-style comparator.

## Tests Of The Tests

Updated the `eqtl_table()` default-error assertion so the test now guards the
new calibrated-threshold wording instead of the stale issue number.

## Coordination Notes

The live GitHub issue state and the Julia-lane handoff differ in wording: the
handoff said #48 was advanced but not closed, while `gh issue view 48` shows it
closed. This report follows live GitHub for issue state and keeps the
capability boundary independent of issue closure.

## What Did Not Go Smoothly

No code blocker. The main risk was semantic: issue closure could be mistaken for
R-side threshold activation.

## Known Limitations

The R `gwas()` surface remains experimental and dense/validation-scale.
Manhattan and QQ plots still show diagnostics, not calibrated significance.

## Next Actions

1. Run documentation and focused GWAS/autoplot/status tests.
2. Keep future threshold activation separate from this coordination sync.
