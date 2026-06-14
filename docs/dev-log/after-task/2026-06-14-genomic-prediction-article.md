# Genomic Prediction Article

Date: 2026-06-14

## Task goal

Add a practical genomic prediction article that shows the currently available
opt-in R syntax and keeps planned genomic construction, APY, QTL/GWAS/eQTL, and
production-comparator work clearly fenced.

## Active lenses and spawned agents

Active lenses: Ada, Shannon, Pat, Jason, Hopper, Fisher, Rose, Grace.

Spawned agents: none.

Current lane: R/docs.

## Files created or changed

- `vignettes/articles/genomic-prediction.Rmd`: new pkgdown article.
- `_pkgdown.yml`: added the article to the navbar and article index.
- `NEWS.md`: added a user-facing documentation bullet.
- `docs/dev-log/scout/2026-06-14-genomic-prediction-vignette-scout.md`:
  recorded local tests/status and genomic-prediction source checks.
- `docs/design/11-next-50-slices.md`: marked row 30 done.
- `docs/dev-log/check-log.md`: recorded command evidence.
- `docs/dev-log/coordination-board.md`: added this slice row.
- `docs/dev-log/after-task/2026-06-14-genomic-prediction-article.md`: this
  report.

## Checks run and exact outcomes

- `git diff --check`: passed.
- `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e
  "pkgdown::check_pkgdown()"`: passed, "No problems found."
- `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e
  "devtools::check(document = FALSE, args = '--no-manual')"`: passed, 0 errors
  / 0 warnings / 0 notes.
- Remote checks for previous commit `381cf60` were green: R-CMD-check
  `27504202880`, pkgdown `27504202884`, Pages `27504252638`.

## Public claim audit

Rose verdict: clean.

The article marks supplied-`Ginv`, marker-built GREML, SNP-BLUP, and supplied
`Hinv` single-step as opt-in and experimental. It explicitly fences automatic
H construction, APY, low-rank large-marker workflows, marker scans, QTL, GWAS,
eQTL, PLINK/VCF readers, and production comparator parity as planned.

## Tests of the tests

This is a prose/docs slice. `devtools::check()` rebuilt the vignettes and ran
the package tests from the built tarball.

## Coordination notes

This closes next-50 row 30 on the R/docs side. Julia still owns genomic
relationship scaling/blending, H construction, APY, and large-marker
performance work.

## What did not go smoothly

No implementation blocker. The main risk was wording drift from "opt-in
experimental path" into "genomic selection package"; the article now separates
the live syntax from the roadmap features.

## Known limitations

The article is documentation only. It does not change `validation_status()`,
capability status, or any genomic estimator.

## Next actions

- Commit and push.
- Watch R-CMD-check, pkgdown, and Pages for the pushed commit.
- Continue the R-safe docs/comparator runway, or let the Julia twin advance
  genomic construction and Phase 4B structured covariance recovery.
