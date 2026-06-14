# After-Task Report: Inheritance Systems Roadmap Article

Date: 2026-06-14

## Task Goal

Add a pkgdown article that shows the future inheritance-systems roadmap without
implying current support for selfing, clonal, haplodiploid, polyploid,
cytoplasmic, imprinting, dominance, epistasis, or custom-kernel models.

## Active Lenses And Spawned Agents

- Active lenses: Ada, Shannon, Jason, Mendel, Darwin, Pat, Rose, Grace.
- Spawned subagents: none.
- Current lane: R/docs.

## Files Changed

- `vignettes/articles/inheritance-systems.Rmd`
- `_pkgdown.yml`
- `NEWS.md`
- `docs/design/11-next-50-slices.md`
- `docs/dev-log/scout/2026-06-14-inheritance-systems-roadmap-scout.md`
- `docs/dev-log/check-log.md`
- `docs/dev-log/coordination-board.md`
- `docs/dev-log/after-task/2026-06-14-inheritance-systems-roadmap-article.md`

## Checks Run

- `git diff --check` — passed.
- `command -v air` — no `air` binary on PATH.
- `rg -n "supports selfing|polyploid model|dominance model|custom kernels work|cytoplasmic inheritance fit|imprinting support|fits selfing|fits clonal|fits haplodiploid|fits polyploid" vignettes/articles/inheritance-systems.Rmd docs/dev-log/scout/2026-06-14-inheritance-systems-roadmap-scout.md NEWS.md docs/design/11-next-50-slices.md` — only the scout note's explicit high-risk phrase list matched after the public article wording patch.
- `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64 /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e "pkgdown::check_pkgdown()"` — passed, "No problems found."
- `RSTUDIO_PANDOC=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64 /Library/Frameworks/R.framework/Resources/bin/Rscript --vanilla -e "devtools::check(document = FALSE, args = '--no-manual')"` — passed, 0 errors / 0 warnings / 0 notes.
- Previous commit `984fbd3` remote checks were green:
  - R-CMD-check `27505026686`
  - pkgdown `27505026688`
  - Pages `27505072608`

## Public Claim Audit

Clean for this slice. The article states that unusual inheritance examples are
roadmap placeholders and that `selfing()`, `clonal()`, `haplodiploid()`,
`polyploid()`, and `inheritance =` grammar are not exported or implemented.
It also says the sources motivate the roadmap, not current support.

## Tests Of The Tests

This was a documentation slice. The main tests-of-tests were:

- `pkgdown::check_pkgdown()` to verify article registration and links.
- `devtools::check(... --no-manual)` to verify vignette build and package
  integrity.
- A targeted Rose grep to make sure high-risk public over-claim phrases did not
  remain in the article.

## Coordination Notes

The slice is R/docs only. No Julia files were touched. The article keeps the
future Julia work framed as kernels, relationship matrices, precision matrices,
and validation gates.

## What Did Not Go Smoothly

The default shell PATH did not include `gh`; use `/opt/homebrew/bin/gh` for
GitHub checks in this environment. A targeted Rose grep also found a negative
sentence in the article containing "fits selfing"; that wording was changed to
avoid future audits needing to parse negation.

## Known Limitations

- No unusual-inheritance kernels exist in `HSquared.jl` yet.
- No R parser support exists for `inheritance =` inside `animal()`.
- `maternal_env()`, `paternal_genetic()`, `paternal_env()`, `cytoplasmic()`,
  `imprinting()`, `dominance()`, `epistasis()`, `relmat()`, and `precision()`
  remain planned syntax unless and until engine evidence and tests land.
- No comparator or recovery evidence exists for these unusual-inheritance
  systems in `hsquared`.

## Next Actions

- Commit and push this article slice, then watch R-CMD-check, pkgdown, and
  Pages.
- Julia lane can use the validation gates here when scoping dominance,
  epistasis, polyploid, selfing, clonal, haplodiploid, and cytoplasmic kernels.
- R lane should not expose fitting syntax for unusual inheritance until a
  concrete kernel, validation fixture, and public-claim audit exist.
