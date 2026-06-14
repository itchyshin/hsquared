# QTL/GWAS/eQTL Status Scout

Date: 2026-06-14

## Question scouted

How should `hsquared` explain planned marker scans, QTL, GWAS, and eQTL while
keeping current genomic/SNP-BLUP support and reserved extractor names honest?

## Sources checked

- `.agents/skills/quantgen-scout/references/packages.md` for the local package
  map.
- `R/genomic-markers.R`, `R/extractors.R`, `R/formula-status.R`, and current
  parser tests for the exact live and reserved vocabulary.
- `vignettes/articles/genomic-prediction.Rmd` and
  `vignettes/articles/genomics-gpu-roadmap.Rmd` for current user-facing
  boundaries.
- Local sister-package search over `drmTMB`, `gllvmTMB`, `DRM.jl`, and
  `GLLVM.jl` source/docs. Useful lessons were known-matrix/relationship
  wording, BLUP/diagnostic discipline, and GLLVM-scale response-matrix
  thinking; no local QTL scan implementation was found to copy.
- Lander & Botstein (1989), QTL interval-mapping anchor:
  https://pubmed.ncbi.nlm.nih.gov/2563713/
- Kang et al. (2010), EMMAX mixed-model GWAS:
  https://pubmed.ncbi.nlm.nih.gov/20208533/
- Zhou & Stephens (2012), GEMMA mixed-model association:
  https://pubmed.ncbi.nlm.nih.gov/22706312/
- Broman et al. (2019), R/qtl2:
  https://pubmed.ncbi.nlm.nih.gov/30591514/
- GTEx Consortium (2020), cis/trans regulatory atlas:
  https://pmc.ncbi.nlm.nih.gov/articles/PMC7737656/

## Relevant lessons

- Users need a status article because `marker_effects()` is live for
  SNP-BLUP, but scan tables and scan formulas are intentionally reserved.
- The GWAS path should be described as a future mixed-model scan with
  relationship correction, not a simple marker regression.
- The QTL path should call out cross/design metadata, genotype probabilities,
  map positions, LOD scores, and thresholds before any support claim.
- The eQTL path must be presented as high-dimensional and chunked from day one;
  the result schema matters as much as the formula.
- Local sister packages reinforce the same discipline: make known covariance or
  relationship structures explicit, report BLUPs/diagnostics carefully, and do
  not claim scale before a benchmark.

## hsquared action

- Add `vignettes/articles/qtl-gwas-eqtl-status.Rmd`.
- Add the article to pkgdown.
- Mark next-50 row 36 done with an explicit no-scan/no-production boundary.

## Claim wording risk

High-risk phrases: "GWAS supported", "QTL mapping", "eQTL analysis",
"marker_scan works", "LOCO", "Manhattan plot", "production marker scans", and
"GPU-accelerated scans". These must stay planned until an engine target produces
tested scan-result tables.
