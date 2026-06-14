# Genomic Prediction Vignette Scout

Date: 2026-06-14

## Question scouted

How should `hsquared` explain its current opt-in genomic prediction paths
without implying production genomic selection, GWAS/QTL/eQTL, APY, or
single-step construction support?

## Sources checked

- `.agents/skills/quantgen-scout/references/packages.md` for the package map.
- `vignettes/articles/fitting-models.Rmd` for the existing short genomic,
  SNP-BLUP, and single-step examples.
- `vignettes/articles/genomics-gpu-roadmap.Rmd` for the planned QTL/eQTL/GPU
  boundary.
- `tests/testthat/test-genomic.R`, `test-snp-blup.R`, and
  `test-single-step.R` for the exact current syntax and guards.
- `docs/design/06-public-claims-register.md` and
  `docs/design/capability-status.md` for the current `partial` status wording.
- Meuwissen, Hayes & Goddard (2001), "Prediction of total genetic value using
  genome-wide dense marker maps": https://pubmed.ncbi.nlm.nih.gov/11290733/
- VanRaden (2008), "Efficient methods to compute genomic predictions":
  https://pubmed.ncbi.nlm.nih.gov/18946147/
- Aguilar, Misztal, Johnson, Legarra, Tsuruta & Lawlor (2010), "Hot topic: a
  unified approach to utilize phenotypic, full pedigree, and genomic
  information for genetic evaluation of Holstein final score":
  https://pubmed.ncbi.nlm.nih.gov/20105546/

## Relevant lessons

- The article should separate four live surfaces: supplied-`Ginv` GREML,
  marker-built GREML, SNP-BLUP at supplied variances, and supplied-`Hinv`
  single-step.
- The strongest user-facing distinction is variance estimation versus
  supplied-variance marker effects. SNP-BLUP must say `variance_components` are
  supplied, not estimated.
- The single-step path needs especially careful wording: `hsquared` can consume
  a supplied `Hinv`, but it does not build `Hinv` from pedigree plus genotype
  inputs yet.
- QTL/GWAS/eQTL names should stay visible as planned outputs, not implied by
  `genomic()`.
- The classic papers motivate the roadmap, but current public claims must stay
  anchored to parser, bridge, and skip-guarded live-test evidence.

## hsquared action

- Add `vignettes/articles/genomic-prediction.Rmd`.
- Add the article to the pkgdown navbar and article list.
- Keep the older "Genomics, QTL, and CPU/GPU roadmap" as the future-facing
  article.

## Claim wording risk

High-risk phrases: "genomic selection supported", "single-step HBLUP", "marker
scan", "GWAS", "QTL", "eQTL", "APY", "production", "large marker panel", and
"comparator validated". The article should explicitly label these as planned
unless the current surface truly implements them.
