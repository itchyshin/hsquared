# GLLVM vignette limits

Goal: disclose current diagnostics and dense validation-scale boundaries in the GLLVM article.

- `Rscript --vanilla -e 'rmarkdown::render("vignettes/articles/genetic-gllvm.Rmd", output_file="/private/tmp/genetic-gllvm.html", quiet=TRUE)'`: exit 0; rendered HTML contains the diagnostics limitation and dense-scale limitation.
- `python3 /Users/z3437171/shinichi-brain/tools/slop_check.py /private/tmp/hsquared-fa-gllvm-20260927/vignettes/articles/genetic-gllvm.Rmd`: 0 findings / 340 words.
- `git diff --check -- vignettes/articles/genetic-gllvm.Rmd`: clean.

Claim boundary: documentation only. The render leaves example code unevaluated; no new model or scale validation is claimed. The prior exact-candidate live R to Julia parity receipt remains 166 checks (FA 113, GLLVM 53); it was not rerun for this prose change.
