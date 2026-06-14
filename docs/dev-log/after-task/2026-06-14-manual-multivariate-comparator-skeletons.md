# Manual multivariate comparator skeletons

Date: 2026-06-14

## Task goal

Add reproducible manual-gate scaffolds for future ASReml-R and
BLUPF90/AIREMLF90 multivariate animal-model comparator runs.

## Active lenses and spawned agents

Active lenses: Ada, Shannon, Jason, Curie, Fisher, Rose, Grace.

Spawned agents: none.

Current lane: R/coordinator.

## Files created or changed

- `inst/comparator-scripts/README.md`: manual-gate purpose and claim boundary.
- `inst/comparator-scripts/asreml/multivariate-animal.R`: ASReml-R candidate
  script with dry-run mode and licensed `--run` mode.
- `inst/comparator-scripts/blupf90/prepare-multivariate-animal.R`: BLUPF90
  fixture exporter.
- `inst/comparator-scripts/blupf90/multivariate-animal.renf90`: RENUMF90-style
  template.
- `inst/comparator-scripts/blupf90/multivariate-animal.par`: AIREMLF90/BLUPF90+
  template.
- `docs/dev-log/comparator-runs/README.md`: required provenance for real manual
  outputs.
- `docs/design/12-multivariate-comparator-plan.md`: updated to point to the
  skeletons.
- `docs/design/11-next-50-slices.md`: updated the current status.
- `docs/dev-log/check-log.md`: recorded dry-run evidence.
- `docs/dev-log/coordination-board.md`: added this lane row.
- `docs/dev-log/after-task/2026-06-14-manual-multivariate-comparator-skeletons.md`:
  this report.

## Checks run and exact outcomes

- `/Library/Frameworks/R.framework/Resources/bin/Rscript inst/comparator-scripts/asreml/multivariate-animal.R --dry-run`:
  passed; prepared 160 long-format records, 2 traits, and 20 animals without
  requiring ASReml.
- `/Library/Frameworks/R.framework/Resources/bin/Rscript inst/comparator-scripts/blupf90/prepare-multivariate-animal.R`:
  passed; prepared 80 data rows and 20 pedigree rows without writing files.
- BLUPF90 temp-write smoke using `mktemp -d`: passed; wrote README, data,
  pedigree, `.renf90`, and `.par` files and rendered the template filenames.

- `git diff --check`: passed.
- `/Library/Frameworks/R.framework/Resources/bin/Rscript -e "devtools::test()"`:
  passed, 0 failures / 0 warnings / 27 live-Julia skips / 585 passes.
- `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "pkgdown::check_pkgdown()"`: passed, "No problems found."
- `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "devtools::check(document = FALSE, args = '--no-manual')"`: passed, 0 errors
  / 0 warnings / 0 notes.

## Public claim audit

Rose verdict: clean if the skeletons stay manual gates.

These files do not record ASReml, BLUPF90, or AIREMLF90 results. They only make
future runs reproducible. Public docs must still say that full external
multivariate comparator parity is missing.

## Tests of the tests

The dry-run paths require only base R and the existing fixture. The BLUPF90
write smoke writes to a temporary directory and deletes it immediately.

## Coordination notes

This advances the ASReml/BLUPF90 manual-gate infrastructure. It does not change
the Julia twin backlog: full residual covariance comparator evidence and t >= 2
known-truth recovery remain open gates.

## What did not go smoothly

No execution issue after removing a dead helper line from the BLUPF90 preparer.

## Known limitations

The ASReml syntax is a candidate ASReml-R 4 model and must be reviewed on a
licensed local installation before any result is treated as evidence. The
BLUPF90 templates are starting points; real AIREMLF90/BLUPF90+ runs must record
the executable version, convergence output, and scale mapping.

## Next actions

- Run package checks.
- Commit and push if checks pass.
- Later, on a machine with ASReml-R or BLUPF90-family executables, run the
  scripts and record outputs under `docs/dev-log/comparator-runs/`.
