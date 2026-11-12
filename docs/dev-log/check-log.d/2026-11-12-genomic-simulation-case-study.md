# 2026-11-12 Simulated genomic case study article

Goal: thread 2 of Szymek's 2026-11-09 request. A simulated genotyped, pedigreed
population with known h² = 0.4, fitted with genomic GREML, the pedigree animal
model and `gwas()`, written up as a pkgdown article.

Branch: `claude/genomic-sim-case-study` from `main` `cb976e95` (after #365 and
#376). Engine: HSquared.jl `main` `a4b7894a` (after #500). Docs, figures and
dev-test scripts only; no R code, tests or NAMESPACE changed.

## Commands

```sh
export PATH="$HOME/.juliaup/bin:$PATH"
Rscript dev-test/genomic-sim/case-study.R      # seed 1, serial, merged main
Rscript dev-test/genomic-sim/make-figures.R    # 3 figures into man/figures
RSTUDIO_PANDOC=/Applications/quarto/bin/tools/aarch64 Rscript -e 'pkgdown::check_pkgdown()'
RSTUDIO_PANDOC=/Applications/quarto/bin/tools/aarch64 Rscript -e 'pkgdown::build_article("articles/genomic-simulation-case-study", new_process = FALSE)'
bash tools/preamble_cap.sh
bash tools/build_check_log.sh --check
git diff --check
```

## Results

- Seed 1 on merged main reproduces the earlier run exactly: genomic h² 0.3659
  (SE 0.0345, AI; delta interval 0.301-0.436), pedigree h² 0.3329 (SE 0.0376),
  realised h² 0.414. `fit$result$se_method = "ai"` on both. GEBV accuracy 0.755,
  EBV 0.731. Bonferroni hits 6/6 causal; BH q < 0.05 9/9 causal; λGC 1.14.
- Serial timings (Julia 1 thread, BLAS 12): simulate 2.1 s; genomic GREML 14.0 s
  warm (32.4 s cold, incl. Julia start); pedigree model 0.54 s; `gwas()` 14.2 s.
- 20-replicate summary (`dev-test/genomic-sim/reps/`, run before #365 merged;
  genomic and univariate routes were AI-native then, so SEs are unchanged):
  genomic mean h² 0.408 (bias +0.008, MCSE 0.008), SD 0.035 vs mean SE 0.034,
  19/20 cover 0.4; pedigree 0.403 (+0.003, MCSE 0.010), SD 0.043 vs mean SE
  0.038, 19/20. GEBV beats EBV in 20/20 (by 0.016-0.031). 114/116 Bonferroni
  hits causal. λGC 1.05-1.14. All 20 genomic fits converged; pedigree
  convergence was not recorded in the replicate summaries.
- `pkgdown::check_pkgdown()`: No problems found. Single-article build writes
  the page; its "missing images" note also appears for existing
  `current-limits` and goes once `copy_figures()` runs. Headless-Chrome
  screenshot of the rendered page checked by eye.
- `preamble_cap.sh`: CAP OK. `git diff --check`: clean.
- Not run: `devtools::check()` / `devtools::test()` (no R code or tests
  changed). The article is `eval = FALSE`, so it does not execute at build.

## Claim boundary

Development evidence on one simulation design. No `validation_status` change;
`public_covered_count` stays 7; the GWAS p-values stay nominal. 20 replicates
do not calibrate interval coverage.

## CI

hsquared#377 (`0fa808d5`): R-CMD-check ubuntu-latest **pass**, windows-latest
**pass** (run 43206652169); test-coverage **pass**, test-coverage-julia
**pass** (run 43206652417).
