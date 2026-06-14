# G-Matrix Interpretation Article

Date: 2026-06-14

## Task goal

Add a short, applied, honest article that helps users interpret the current
multivariate G and R matrices without implying factor-analytic, evolvability,
selection-response, or production multivariate support.

## Active lenses and spawned agents

Active lenses: Ada, Shannon, Pat, Darwin, Kirkpatrick, Fisher, Jason, Rose,
Grace.

Spawned agents: none.

Current lane: R/docs.

## Files created or changed

- `vignettes/articles/g-matrix-interpretation.Rmd`: new pkgdown article.
- `_pkgdown.yml`: added the article to the navbar and article index.
- `NEWS.md`: added a user-facing documentation bullet.
- `docs/dev-log/scout/2026-06-14-g-matrix-interpretation-scout.md`: recorded
  the local sister/twin and literature scout.
- `docs/design/11-next-50-slices.md`: marked row 21 done.
- `docs/dev-log/check-log.md`: recorded command evidence.
- `docs/dev-log/coordination-board.md`: added this slice row.
- `docs/dev-log/after-task/2026-06-14-g-matrix-interpretation-article.md`:
  this report.

## Checks run and exact outcomes

- `git diff --check`: passed.
- `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e
  "pkgdown::check_pkgdown()"`: passed, "No problems found."
- `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64
  /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e
  "devtools::check(document = FALSE, args = '--no-manual')"`: passed, 0 errors
  / 0 warnings / 0 notes.
- Remote checks for previous commit `7e4cce3` were green: R-CMD-check
  `27503967568`, pkgdown `27503967586`, Pages `27504011650`.

## Public claim audit

Rose verdict: clean.

The article says the multivariate surface is experimental and opt-in, and it
explicitly fences standard errors, confidence intervals, selection-response
prediction, factor-analytic loadings, production sparse fitting, and
`P_matrix()` as planned/gated work.

## Tests of the tests

This is a prose/docs slice. The package check rebuilt vignettes and ran the
package test suite from the built tarball.

## Coordination notes

This closes next-50 row 21 on the R/docs side. Julia still owns structured
covariance recovery and loading/rotation hardening.

## What did not go smoothly

The first local `rg` scout over all sister repos returned too much output. The
useful durable findings were reduced into the scout note rather than copied
into the article.

## Known limitations

The article is interpretive guidance, not validation evidence. It does not
change `validation_status()`, capability status, or public claims beyond
documenting the existing partial multivariate boundary.

## Next actions

- Commit and push.
- Watch R-CMD-check, pkgdown, and Pages for the pushed commit.
- Continue with another R-safe docs/comparator runway slice or wait for the
  Julia twin's structured-covariance recovery work.
