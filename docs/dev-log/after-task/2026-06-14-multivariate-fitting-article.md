# Multivariate fitting article

Date: 2026-06-14

## Task goal

Add a short user-facing pkgdown article for the opt-in multivariate Gaussian
animal model so users can see the live `cbind()` path, missing response-cell
handling, result extractors, and the structured-covariance boundary in one
place.

## Active lenses and spawned agents

Active lenses: Ada, Shannon, Boole, Noether, Pat, Rose, Grace, Jason.

Spawned agents: none.

Current lane: R/docs.

## Files created or changed

- `_pkgdown.yml`: adds the multivariate article to the navbar and article
  index.
- `vignettes/articles/multivariate.Rmd`: new article.
- `vignettes/articles/fitting-models.Rmd`: adds the multivariate model to the
  fitting tour and fixes stale "multivariate remains on the roadmap" wording.
- `docs/design/11-next-50-slices.md`: records the slice and next R-safe bites.
- `docs/dev-log/check-log.md`, `docs/dev-log/coordination-board.md`: evidence
  and lane update.

## Checks run and exact outcomes

- `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64 /Library/Frameworks/R.framework/Resources/bin/Rscript -e "pkgdown::check_pkgdown()"`:
  passed, "No problems found."
- `rg -n "Multivariate, factor-analytic|multivariate.*remain on the roadmap|ASReml-style production|t>=2|target = \"multivariate\"|cov = us|cov = fa" README.md DESCRIPTION ROADMAP.md docs vignettes R tests`:
  no stale "multivariate remains on the roadmap" wording; remaining hits are
  intentional opt-in/partial/planned-boundary language.
- `/Library/Frameworks/R.framework/Resources/bin/Rscript -e "devtools::test()"`:
  0 failures / 0 warnings / 27 live-Julia skips / 561 passes.
- `git diff --check`: passed.
- `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64 /Library/Frameworks/R.framework/Resources/bin/Rscript -e "devtools::check(document = FALSE, args = '--no-manual')"`:
  0 errors / 0 warnings / 0 notes.

## Public claim audit

Rose verdict: clean with limitations.

The article says the multivariate model is experimental, opt-in, REML-only,
animal-model-only, dense validation-scale, and `partial`. It explicitly blocks
ASReml-style production wording, structured covariance grammar claims, external
comparator claims, and t>=2 known-truth recovery claims.

## Formula and prose review

Accepted syntax:

```r
cbind(weight, length) ~ sex + age + animal(1 | id, pedigree = ped)
```

with:

```r
control = hs_control(
  engine = "julia",
  engine_control = list(target = "multivariate")
)
```

Deferred syntax:

```r
animal(trait | id, pedigree = ped, cov = us())
animal(trait | id, pedigree = ped, cov = fa(K = 2))
```

Boole/Noether verdict: syntax, model equation, and engine target align.

Pat verdict: the article starts from the biological question, shows the current
path first, then labels the unsupported grammar.

## Jason scout

Checked local sister package documentation patterns in:

- `gllvmTMB/vignettes/articles/covariance-correlation.Rmd`;
- `gllvmTMB/vignettes/articles/animal-model.Rmd`;
- `drmTMB/vignettes/phylogenetic-spatial.Rmd`.

Borrowed the pattern of pairing syntax with the covariance equation and putting
implemented-vs-planned status close to the example.

## Tests of the tests

The built-package check rebuilt vignette outputs and would fail if the new
article had missing dependencies, invalid R Markdown, or pkgdown article-index
problems. The claim scan would catch a return of the stale "multivariate remains
on the roadmap" wording.

## Coordination notes

This is R-lane documentation only. The Julia lane still owns structured
covariance recovery, shared deterministic multivariate fixtures, and promotion
evidence.

## What did not go smoothly

No blocker. Plain `pkgdown::check_pkgdown()` still needs the RStudio Pandoc path
in this shell.

## Known limitations

No new fitting capability was added. The multivariate model remains partial and
opt-in. The article examples are not evaluated during pkgdown builds because
they require a local Julia/`HSquared.jl` bridge.

## Next actions

- Commit and push this article slice, then watch R-CMD-check, pkgdown, and
  Pages.
- Next R-safe bite: add extractor documentation examples for
  `genetic_covariance()` / `genetic_correlation()`, or consume the shared
  deterministic multivariate fixture after the Julia twin writes it.
