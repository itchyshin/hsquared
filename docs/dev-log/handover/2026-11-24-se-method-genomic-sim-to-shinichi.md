# Handover to Shinichi: SE method and simulated genomic case study (2026-11-24)

**From:** Szymek, with Claude (Opus 5.5) in this session. **To:** Shinichi
(and any agent he assigns). Lanes: R (`hsquared`) and, for one slice, Julia
(`HSquared.jl`), both assigned by Szymek. This file on `origin` is the record;
check every item against live `git` before acting. Labels: **DONE**, **OWED**
(someone should do it), **DECIDE** (needs your call).

## Message to paste

```text
Shinichi, handover from Szymek's 2026-11-09 to 11-12 slice (SE method + simulated genomic case study). Everything is merged; full record in docs/dev-log/handover/2026-11-24-se-method-genomic-sim-to-shinichi.md on hsquared main.

What landed
1. SE method. hsquared's SEs were 2-7% wider than ASReml-R on the great tit animal + PE model. Neither was wrong: ASReml inverts the average information (AI), hsquared inverted the finite-difference observed information. New hs_control(se_method = c("ai", "observed")), default "ai", now matches ASReml-R to every printed digit on both traits. "observed" stays available (MCMCglmm posterior SDs tracked it on clutch size). Julia side: information = :ai | :observed on the SE functions (HSquared.jl#500; Cursor's #502 then tightened the keyword's validation). R side: hsquared#365. Evidence: dev-test/se-investigation/RESULTS.md.
   Behaviour change: the sparse animal + PE route (scale_method = "auto") moved from observed to AI SEs. Recorded in NEWS.
2. Simulated genomic case study (hsquared#376 data, #377 article). Gene-drop population, known h2 = 0.4, 2,000 phenotyped animals, 10,000 SNPs, 200 causal. Over 20 replicates genomic GREML h2 = 0.408 (MCSE 0.008), SD of estimates 0.035 vs mean AI SE 0.034; GEBV beats EBV in 20/20; gwas() 114/116 Bonferroni hits causal. New pkgdown article "Simulated genomic case study" under Fit.

Fences unchanged: public_covered_count 7, no validation_status change, SEs still asymptotic/not coverage-calibrated, GWAS p-values nominal.

Needs you
- DECIDE: R now defaults to AI SEs on univariate, genomic, and sparse animal+PE routes, but the Julia K-effect functions still default to :observed and the two-effect / n-effect / direct-maternal / multivariate / dense-repeatability routes were not threaded. Do you want one convention everywhere (AI, as ASReml/WOMBAT/BLUPF90 report)?
- OWED (Julia lane): the R genomic route (target = "genomic") still runs dense AI-REML, not the spectral solver from HSquared.jl#453 that closed #420. Our 2026-11-12 fit shows variance_components_source = estimated_genomic_ai_reml and 14 s warm at n = 2,000.
- OWED (Julia lane): test_issue_421_sparse_laplace.jl:193 asserts fitpath.time < 10.0 and fails on GitHub ubuntu runners (14.6-14.9 s), on main too.
- OWED (small): the 2026-11-09 check-log entry went into the frozen docs/dev-log/check-log.md instead of a check-log.d/ shard. Left in place; move it if you want the frozen file kept clean.
```

## DONE

| Item | Where | Merged |
| --- | --- | --- |
| Great tit SE investigation: base-R reference, ASReml-R, MCMCglmm (6 × 65k) | `dev-test/se-investigation/` (`RESULTS.md`) | hsquared#365, 2026-11-12 |
| `hs_control(se_method = c("ai", "observed"))`, default `"ai"`; stamped on `fit$result$se_method` and `fit_diagnostics()` | `R/hs_control.R`, `R/julia-bridge.R`, `R/hsquared.R`, `tests/testthat/test-se-method.R` | hsquared#365 |
| Julia `information = :ai \| :observed` on `variance_component_covariance`, `variance_component_standard_errors`, `heritability_standard_error`, `heritability_interval`, `variance_component_uncertainty`, five `multi_effect_*` SE functions | `HSquared.jl/src/likelihood.jl`, `test/test_se_information_switch.jl` | HSquared.jl#500, 2026-11-12 |
| Validation of the `information` keyword (Symbol only) and `variance_components_plot_data(information =)` | HSquared.jl#502 (Cursor, closes #503) | merged |
| Genomic simulation data and replicate study | `dev-test/genomic-sim/` (`simulate.R`, `replicate.R`, `reps/`, `sim-seed1.rds`, `fit-seed1.rds`) | hsquared#376 |
| Article "Simulated genomic case study" + 3 figures | `vignettes/articles/genomic-simulation-case-study.Rmd`, `man/figures/genomic-sim-*`, `_pkgdown.yml` (Fit) | hsquared#377, 2026-11-24 |
| Correction on HSquared.jl#420: the 130-140 s genomic fits were BLAS oversubscription in parallel runs, not the engine | comment on HSquared.jl#420 | — |

Headline numbers:

- **SEs, great tit** (ASReml-R 4.2.0.482 vs hsquared `"ai"`): clutch size
  SE(V_A) 0.0663271, SE(h²) 0.0255754; laying date 0.832305, 0.0215506.
  Identical to every printed digit.
- **Timing, great tit** (idle machine, median of 7 warm runs; clutch size /
  laying date): ASReml 0.71 / 0.65 s; hsquared `"ai"` 0.77 / 0.90 s;
  `"observed"` 0.90 / 1.03 s.
- **Genomic simulation** (20 replicates): genomic h² 0.408 (bias +0.008, MCSE
  0.008); pedigree 0.403; 19/20 intervals cover 0.4 for both; GEBV accuracy
  0.765 vs EBV 0.743; λGC 1.05-1.14. Seed 1 on merged main: genomic fit 14 s
  warm, 32 s cold; `gwas()` 14 s.

Checks: Julia `Pkg.test()` passed on 1.12.6; `devtools::check()` 1 error /
0 warnings / 0 notes for #365 (the error was 3 test failures from the missing
`sommer` Suggests gate); CI green on #365, #377 and #500 except the
known timing flake below. Details: the 2026-11-09 entry in
`docs/dev-log/check-log.md` and
`docs/dev-log/check-log.d/2026-11-12-genomic-simulation-case-study.md`.
After-task reports: `docs/dev-log/after-task/2026-11-09-se-method-ai-default.md`,
`docs/dev-log/after-task/2026-11-12-genomic-simulation-case-study.md`.

## DECIDE

1. **One SE convention?** R defaults to AI on the univariate animal model,
   genomic GREML and the sparse animal + PE route. The two-effect, n-effect,
   direct-maternal, multivariate and dense-repeatability routes keep their own
   method; the dense repeatability interval is observed-based. Julia defaults
   are unchanged: univariate `:ai`, K-effect `:observed`. AI is what
   ASReml/WOMBAT/BLUPF90/DMU report; observed is what MCMCglmm posterior SDs
   tracked on clutch size. Both are asymptotically equivalent.
2. **Is the ASReml agreement usable evidence?** It is recorded as development
   evidence on one dataset. ASReml is still not a permitted covered-comparator
   leg, so nothing was flipped.

## OWED

1. **Julia lane: R genomic route does not use the spectral solver.** HSquared.jl#420
   was closed because spectral GREML (`fit_gblup_reml`, `solver = :spectral`,
   #453) is the default there. The R `target = "genomic"` route still reports
   `variance_components_source = estimated_genomic_ai_reml`,
   `optimizer_status = converged`, 8 iterations, 14 s warm at n = 2,000 ×
   10,000 SNPs (`dev-test/genomic-sim/case-study-log.txt`, engine `a4b7894a`).
   Either route the R call to the spectral path or record why not.
2. **Julia lane: wall-clock flake.** `test/test_issue_421_sparse_laplace.jl:193`
   asserts `fitpath.time < 10.0`; GitHub ubuntu runners take 14.6-14.9 s, on
   `main` as well. Loosen or move to a benchmark.
3. **Check-log placement.** The 2026-11-09 entry was appended to the frozen
   `docs/dev-log/check-log.md`. It could move to a `check-log.d/` shard.
4. **Replicate study.** `dev-test/genomic-sim/replicate.R` records genomic but not
   pedigree convergence; add it if the study is rerun. The replicate timings in
   `reps/` are inflated by parallel BLAS oversubscription; use the serial
   timings in `case-study-log.txt`.
5. **Overlap to watch.** Open draft hsquared#396 (Codex, Refs #363) edits the
   genomic GREML example in `fitting-models`; the new case study links to
   `genomic-prediction`, not that example, so they should not conflict.

## Practical notes for whoever reruns this

- Running replicates in parallel: give each process one BLAS thread
  (`JuliaCall::julia_command("using LinearAlgebra; BLAS.set_num_threads(1)")`
  or `OPENBLAS_NUM_THREADS=1`). Otherwise fits slow down 5-50×.
- `~/.Renviron` on Szymek's machine sets `HSQUARED_JULIA_PROJECT`; scripts in
  `dev-test/` override it with `Sys.setenv()`. For `devtools::check()`, use an
  empty `R_ENVIRON_USER` file and pandoc from Quarto via `RSTUDIO_PANDOC`.
- ASReml-R: `asreml::ainverse()` failed intermittently on the great tit
  pedigree; `dev-test/se-investigation/01-asreml.R` builds the `ginv` from
  `nadiv::makeAinv()` instead.
