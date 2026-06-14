# Sparse multivariate production plan

Date: 2026-06-14

## Task goal

Record the production sparse architecture for future multivariate and
factor-analytic animal models before adding more syntax or widening claims.

## Active lenses and spawned agents

Active lenses: Ada, Shannon, Jason, Noether, Henderson, Kirkpatrick, Karpinski,
Rose, Pat.

Spawned agents: none.

Current lane: coordinator/docs.

## Files created or changed

- `docs/design/13-sparse-multivariate-production-plan.md`: new design note.
- `docs/design/05-roadmap.md`: Phase 4 pointer to the production-sparse note.
- `docs/design/11-next-50-slices.md`: current-status update and row 33 marked
  done.
- `docs/dev-log/check-log.md`: scout evidence and note creation recorded.
- `docs/dev-log/coordination-board.md`: added this slice row.
- `docs/dev-log/after-task/2026-06-14-sparse-multivariate-production-plan.md`:
  this report.

## Checks run and exact outcomes

- `git diff --check`: passed.
- `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "pkgdown::check_pkgdown()"`: passed, "No problems found."
- `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript -e
  "devtools::check(document = FALSE, args = '--no-manual')"`: passed, 0 errors
  / 0 warnings / 0 notes.
- Remote checks for commit `3ea321d`: GitHub Actions R-CMD-check
  `27502628759`, pkgdown `27502628772`, and Pages `27502672768` all passed.

## Public claim audit

Rose verdict: clean, with one condition: the note must stay visibly labelled as
design only.

The note does not claim production sparse multivariate fitting, factor-analytic
fitting, GPU acceleration, external comparator parity, or validation coverage.
It explicitly keeps the current multivariate path `partial` and
validation-scale.

## Tests of the tests

No code tests were added. The useful test here is prose discipline: the note
separates current dense validation paths from future sparse, structured, and
GPU paths.

## Coordination notes

This closes next-50 row 33 on the R/coordinator side. Julia still owns the
actual sparse MME builder, rank-deficient engine guard, determinant/loglik
agreement tests, and any structured-covariance recovery evidence.

## What did not go smoothly

The first broad sibling `rg` search was too noisy and was interrupted. The
useful scout was narrowed to targeted local files in `HSquared.jl`, `GLLVM.jl`,
and `DRM.jl`, then supplemented with three external anchors: Gilmour's AI-REML
practice review, Meyer/Hill multivariate AI-REML/reduced-rank work, and a
BLUPF90 large-scale REML tutorial.

## Known limitations

The design note is not an implementation. It does not add R syntax, Julia
engine code, benchmarks, or comparator results.

## Next actions

- Commit and push.
- Continue with either row 34 (production-sparse FA design note) or a
  documentation/claim audit slice while the Julia twin owns structured recovery.
