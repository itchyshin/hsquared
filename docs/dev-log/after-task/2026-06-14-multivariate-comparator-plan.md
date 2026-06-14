# Multivariate comparator plan

Date: 2026-06-14

## Task goal

Turn the vague "plan R sommer / ASReml / BLUPF90 comparators" runway into a
concrete, evidence-bounded comparator ladder for the opt-in multivariate animal
model.

## Active lenses and spawned agents

Active lenses: Ada, Shannon, Jason, Curie, Fisher, Rose, Grace.

Spawned agents: none.

Current lane: coordinator/docs.

## Files created or changed

- `docs/design/12-multivariate-comparator-plan.md`: comparator ladder,
  same-estimand contract, local pilot results, and promotion rule.
- `docs/dev-log/scout/2026-06-14-multivariate-comparator-scout.md`: scout note
  with sister-package lessons, local package availability, and `sommer` pilot
  outcome.
- `docs/design/11-next-50-slices.md`: marked the comparator-planning items as
  planned and cleaned two stale "done locally" status rows.
- `docs/dev-log/check-log.md`: recorded commands and outcomes.
- `docs/dev-log/coordination-board.md`: added this coordinator/docs slice row.
- `docs/dev-log/after-task/2026-06-14-multivariate-comparator-plan.md`: this
  report.

## Checks run and exact outcomes

Pre-edit scout commands:

- `git status --short --branch`: clean at `main...origin/main`.
- `git log --oneline --decorate -5`: head was `b5242c1`.
- Local R package availability check reported `sommer` 4.4.5, `MCMCglmm` 2.36,
  `nadiv` 2.18.0, `pedigreemm` 0.3.5; `asreml` and `AGHmatrix` were not
  installed.
- Comparator executable check returned no `asreml`, `airemlf90`, `blupf90`,
  `renumf90`, `dmuai`, or `wombat` executable on `PATH`.
- `sommer` diagonal-residual pilot on the shared fixture fit successfully and
  matched serialized Julia `G0` and `diag(R0)` at printed precision.
- `sommer` full-residual `usm(trait)` pilot failed with
  `Mat::operator(): index out of bounds`.
- `sommer` wide `cbind()` pilot failed under the installed 4.4.5 API.

Post-edit checks:

- `git diff --check`: passed.
- `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "pkgdown::check_pkgdown()"`: passed, "No problems found."
- `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "devtools::check(document = FALSE, args = '--no-manual')"`: passed, 0 errors
  / 0 warnings / 0 notes.
- Remote checks for `c3e5a26`: R-CMD-check `27500073218`, pkgdown
  `27500073217`, and Pages `27500113544` all passed.

## Public claim audit

Rose verdict: clean if the note remains a comparator plan.

The new wording says the feasible `sommer` path is partial and
diagonal-residual only. It explicitly blocks promotion until same-estimand
external comparison, signed-off known-truth recovery, or recorded manual
ASReml/BLUPF90 evidence exists.

## Tests of the tests

No test was added in this slice. The pilot exposed the narrower target for a
future optional test.

## Coordination notes

This closes the planning intent behind the twin board items:

- Plan R sommer comparator.
- Plan ASReml comparator if available.
- Plan BLUPF90/AIREMLF90 comparator if practical.

It does not close "add comparator evidence" or "promote multivariate evidence"
because those require committed test or manual-run outputs.

## What did not go smoothly

Sommer's full residual covariance specification failed locally, and the wide
`cbind()` route did not accept the same structure. That is useful negative
evidence: the first external comparator should be intentionally narrower rather
than pretending to validate the full hsquared/Juila estimand.

## Known limitations

The local fixture is tiny and internally generated. It is good for a comparator
smoke test, but not enough for recovery or broad accuracy wording.

## Next actions

- Add a skip-safe optional `sommer` comparator test for G0, diag(R0), and
  diagonal-target heritability if the narrower target is accepted.
- Keep ASReml-R and BLUPF90/AIREMLF90 as manual gates until installed evidence
  is available.
