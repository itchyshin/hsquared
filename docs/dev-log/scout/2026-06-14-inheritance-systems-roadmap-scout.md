# Inheritance Systems Roadmap Scout

Date: 2026-06-14

## Question scouted

How should `hsquared` show future selfing, clonal, haplodiploid, polyploid,
cytoplasmic, imprinting, dominance, epistasis, and custom-kernel examples
without implying current support?

## Sources checked

- `R/qg-effects.R`, `R/model-spec.R`, `vignettes/articles/model-status.Rmd`,
  and `vignettes/articles/formula-grammar.Rmd` for current live and reserved
  inheritance vocabulary.
- `docs/design/07-genomics-qtl-gpu-plan.md` and `docs/design/05-roadmap.md`
  for the inheritance-as-kernel design rule.
- Local sister-package search over `gllvmTMB`, `drmTMB`, `DRM.jl`, and
  `GLLVM.jl`. Useful lessons: `gllvmTMB` carries pedigree/nadiv comparison
  discipline and known-relatedness wording; `GLLVM.jl` documents known
  structured covariance matrices. No local selfing/polyploid/haplodiploid
  kernel implementation was found to copy.
- nadiv package paper for non-additive genetic relatedness matrices:
  https://besjournals.onlinelibrary.wiley.com/doi/10.1111/j.2041-210X.2012.00213.x
- AGHmatrix paper for diploid/autopolyploid A/G/H relationship construction:
  https://pubmed.ncbi.nlm.nih.gov/37471595/
- AGHmatrix autotetraploid relationship-matrix anchor:
  https://pubmed.ncbi.nlm.nih.gov/27902800/

## Relevant lessons

- The article should keep the common user path short and move unusual
  inheritance into explicit kernels or named effects.
- Current opt-in maternal/common/permanent paths are stepping stones, not proof
  that unusual inheritance is implemented.
- Dominance and epistasis need non-additive relationship matrices and should be
  compared against `nadiv` where possible.
- Polyploid and plant-breeding relationship matrices need ploidy and double
  reduction assumptions; `AGHmatrix` is the natural comparison anchor.
- Cytoplasmic and imprinting examples need hard wording to avoid confusing
  maternal environment, dam identity, and parent-of-origin effects.

## hsquared action

- Add `vignettes/articles/inheritance-systems.Rmd`.
- Add the article to pkgdown.
- Mark next-50 row 48 done with planned-only wording.

## Claim wording risk

High-risk phrases: "supports selfing", "polyploid model", "dominance model",
"custom kernels work", "cytoplasmic inheritance fit", and "imprinting support".
These must remain planned until the Julia engine has kernels, tests,
comparators, and R extraction/summary wording.
