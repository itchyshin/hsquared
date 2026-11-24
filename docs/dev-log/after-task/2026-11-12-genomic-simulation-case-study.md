# Simulated genomic case study article

Date: 2026-11-12. Lane: R (docs). Assigned by Szymek as thread 2 of the
2026-11-09 request. Branch `claude/genomic-sim-case-study`.

Active lenses: Ada, Curie, Fisher, Darwin, Pat, Florence, Rose (perspectives,
not spawned). Spawned subagents: none.

## What was asked

A working simulation test of the genomic arm: a reasonably sized simulated SNP
dataset and estimation of genomic heritability of a continuous trait, then,
once it works, a documented simulated case study.

## What exists now

- Article `vignettes/articles/genomic-simulation-case-study.Rmd`, listed under
  **Fit** in the navbar and article index. It includes the base-R gene-drop
  simulator, the genomic GREML, pedigree and `gwas()` calls, seed-1 results, a
  20-replicate recovery table, running times, BLAS-thread advice for parallel
  runs, and a "does not show" section. `eval = FALSE`; figures precomputed.
- Figures `man/figures/genomic-sim-h2-recovery.svg`,
  `genomic-sim-gebv.png`, `genomic-sim-manhattan.png` (PNG for the two
  dense scatter plots: 0.2 MB each instead of 0.5-1 MB as SVG).
- Reproduction: `dev-test/genomic-sim/case-study.R` (seed 1 on merged main,
  serial timings) and `make-figures.R`.

## Result

Genomic GREML recovers h² = 0.4 without detectable bias (0.408, MCSE 0.008)
and its AI SEs match the replicate spread (0.034 vs 0.035). GEBVs beat
pedigree EBVs in 20/20 replicates. `gwas()`: 114 of 116 Bonferroni hits
causal. Warm genomic fit 14 s at n = 2,000 × 10,000 SNPs.

## Rose audit

Clean. The banner and closing section state: simulated data, one design, no
coverage calibration from 20 replicates, nominal GWAS p-values, no
`validation_status` change, `public_covered_count` 7. Two claims were removed
or narrowed before commit because the replicate summaries could not support
them: that the 2 non-causal hits lay near causal SNPs, and that all 40 fits
converged (only genomic convergence was recorded).

## Process note

The 2026-11-09 SE-method entry was appended to the frozen
`docs/dev-log/check-log.md` instead of a `check-log.d/` shard. It is merged;
left in place. This slice uses a shard.

## Follow-ups

- The earlier after-task note (2026-11-09) said genomic fits take 130-140 s;
  that was BLAS oversubscription, corrected on HSquared.jl#420 and in the
  check log. Serial warm fit is 14 s.
- Possible: record pedigree convergence in `replicate.R` if the study is rerun.
