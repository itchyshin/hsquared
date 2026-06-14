# Standard QG marker claim audit

Date: 2026-06-14

## Task goal

Audit public wording after the recent opt-in Phase 2 paths and correct stale
ledger rows that still described permanent/common-environment/maternal markers
as planned-only.

## Active lenses and spawned agents

Active lenses: Ada, Shannon, Boole, Pat, Rose, Grace.

Spawned agents: none.

Current lane: coordinator/docs.

## Files created or changed

- `docs/design/06-public-claims-register.md`: standard QG marker row now carves
  out opt-in experimental `permanent()`, `common_env()`, and
  `maternal_genetic()` paths.
- `docs/design/capability-status.md`: same correction.
- `docs/design/validation-debt-register.md`: same correction.
- `docs/design/11-next-50-slices.md`: current status updated.
- `docs/dev-log/check-log.md`: audit evidence recorded.
- `docs/dev-log/coordination-board.md`: added this slice row.
- `docs/dev-log/after-task/2026-06-14-standard-qg-marker-claim-audit.md`: this
  report.

## Checks run and exact outcomes

- `git diff --check`: passed.
- `rg -n "Standard quantitative-genetic formula markers exist|Quantitative-genetic effect markers" docs/design/06-public-claims-register.md docs/design/capability-status.md docs/design/validation-debt-register.md`:
  passed; the three rows now carve out the opt-in paths and keep remaining
  markers planned-only.
- `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "pkgdown::check_pkgdown()"`: passed, "No problems found."
- `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "devtools::check(document = FALSE, args = '--no-manual')"`: passed, 0 errors
  / 0 warnings / 0 notes.

## Public claim audit

Rose verdict: clean-with-limitations.

The fix is a wording correction. It does not promote repeatability,
common-environment, or maternal-genetic models beyond opt-in experimental
`partial` status.

## Tests of the tests

No executable package code changed. The relevant checks are docs/package
checks.

## Coordination notes

The Julia twin is actively working on `phase4b-factor-analytic-g`; R did not
edit the twin repository.

## What did not go smoothly

No execution issue.

## Known limitations

Paternal, maternal-environment, dominance, epistasis, custom-kernel,
cytoplasmic, and imprinting syntax remains planned-only.

## Next actions

- Run docs/package checks.
- Commit and push.
- Watch R-CMD-check/pkgdown/Pages.
