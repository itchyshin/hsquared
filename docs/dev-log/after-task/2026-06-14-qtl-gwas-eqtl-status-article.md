# QTL/GWAS/eQTL Status Article

Date: 2026-06-14

## Task goal

Add a practical status article for marker scans, QTL, GWAS, and eQTL that keeps
the future vocabulary visible without implying scan support.

## Active lenses and spawned agents

Active lenses: Ada, Shannon, Jason, Boole, Fisher, Pat, Rose, Grace.

Spawned agents: none.

Current lane: R/docs.

## Files created or changed

- `vignettes/articles/qtl-gwas-eqtl-status.Rmd`: new pkgdown article.
- `_pkgdown.yml`: added the article to the navbar and article index.
- `NEWS.md`: added a documentation bullet.
- `docs/dev-log/scout/2026-06-14-qtl-gwas-eqtl-status-scout.md`: recorded
  local syntax/status, sister-package, and source checks.
- `docs/design/11-next-50-slices.md`: marked row 36 done.
- `docs/dev-log/check-log.md`: recorded command evidence.
- `docs/dev-log/coordination-board.md`: added this slice row.
- `docs/dev-log/after-task/2026-06-14-qtl-gwas-eqtl-status-article.md`: this
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
- Remote checks for previous commit `2923042` were green: R-CMD-check
  `27504500020`, pkgdown `27504500023`, Pages `27504554393`.

## Public claim audit

Rose verdict: clean.

The article states that `marker_effects()` is live only for opt-in SNP-BLUP and
that `marker_scan()`, `qtl_scan()`, `qtl_table()`, `gwas_table()`,
`eqtl_table()`, `lod_scores()`, scan plots, LOCO, and production-scale scans are
planned. It does not promote any capability row.

## Tests of the tests

This is a prose/docs slice. `devtools::check()` rebuilt the vignettes and ran
the package tests from the built tarball. `pkgdown::check_pkgdown()` checked the
new article registration.

## Coordination notes

This closes next-50 row 36 on the R/docs side. Julia still owns scan kernels,
LOCO, eQTL primitives, and accelerator-sensitive scan execution.

## What did not go smoothly

The first broad local sister search matched generated pkgdown favicon content.
The scout was re-run with generated assets excluded and with source/docs files
prioritized.

## Known limitations

The article is documentation only. It adds no scan engine, result-table
producer, plotting function, or validation row.

## Next actions

- Commit and push.
- Watch R-CMD-check, pkgdown, and Pages for the pushed commit.
- Next R-safe bite: decide the `hsquaredQTL` extension boundary before adding
  more scan vocabulary to core, or continue with inheritance-system roadmap
  examples while Julia owns scan kernels.
