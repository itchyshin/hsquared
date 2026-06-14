# Factor-analytic G-matrix production plan

Date: 2026-06-14

## Task goal

Record the R-facing and engine-facing design boundaries for future
factor-analytic G matrices before adding `cov = fa(K)` syntax, loading
extractors, or biological latent-axis wording.

## Active lenses and spawned agents

Active lenses: Ada, Shannon, Boole, Noether, Kirkpatrick, Fisher, Jason, Rose,
Pat.

Spawned agents: none.

Current lane: coordinator/docs.

## Files created or changed

- `docs/design/14-factor-analytic-production-plan.md`: new design note.
- `docs/design/05-roadmap.md`: Phase 4 pointer to the factor-analytic note.
- `docs/design/11-next-50-slices.md`: current-status update and row 34 marked
  done.
- `docs/dev-log/check-log.md`: scout and review evidence recorded.
- `docs/dev-log/coordination-board.md`: added this slice row.
- `docs/dev-log/after-task/2026-06-14-factor-analytic-production-plan.md`: this
  report.

## Checks run and exact outcomes

- `git diff --check`: passed.
- `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "pkgdown::check_pkgdown()"`: passed, "No problems found."
- `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "devtools::check(document = FALSE, args = '--no-manual')"`: passed, 0 errors
  / 0 warnings / 0 notes.

## Public claim audit

Rose verdict: clean, with one condition: the note must keep every `cov = fa(K)`
and loading/rotation example visibly planned.

No R parser, engine bridge, loading extractor, latent breeding value extractor,
rank-selection tool, standard error, confidence interval, LRT, GPU path, or
external comparator claim is added.

## Tests of the tests

No code tests were added. The design note itself records the future tests that
must exist before any R-facing factor-analytic claim: reconstruction,
rotation-invariance, recovery, comparator, and wording audits.

## Coordination notes

This closes next-50 row 34 on the R/coordinator side. Julia owns structured
recovery, loading metadata hardening, and any future R-bridgeable result shape.

## What did not go smoothly

The local `rg` scout was large, but useful. The stable lessons were narrowed to
the twin rotation decision, `GLLVM.jl` postfit rotation pattern, and `gllvmTMB`
rotation-advisory wording.

## Known limitations

This is not implementation. It does not add `cov = fa(K)` syntax, does not make
loadings interpretable, and does not promote Phase 4B beyond partial.

## Next actions

- Commit and push.
- Consider row 20 / reserved extractor names only if they error with
  rotation-aware planned wording.
