# Validation Fixture Scout

Date: 2026-06-13

Active lenses: Curie, Fisher, Gauss, Jason, Rose.

Spawned subagents: none.

## Question

What should the first hsquared validation fixture prove before broader Mrode,
ASReml, BLUPF90, or genomic benchmarks exist?

## Sources Checked

- Local `drmTMB`:
  - `tests/testthat/test-animal-relmat-gaussian.R`
  - `tests/testthat/test-julia-bridge.R`
  - `docs/design/34-validation-debt-register.md`
- Local `gllvmTMB`:
  - `tests/testthat/test-pedigree-sparse-ainv.R`
  - `tests/testthat/test-pedigree-sparse-ainv-engine.R`
  - `vignettes/articles/cross-package-validation.Rmd`
  - `docs/dev-log/after-task/2026-06-09-gaussian-reml-pilot.md`
  - `docs/design/35-validation-debt-register.md`
- Henderson (1976), "A simple method for computing the inverse of a numerator
  relationship matrix used in prediction of breeding values":
  https://www.jstor.org/stable/2529339
- Mrode's *Linear Models for the Prediction of Animal Breeding Values* catalogue
  entry:
  https://www.cabidigitallibrary.org/doi/pdf/10.5555/20053196805
- AGHmatrix tutorial:
  https://cran.rstudio.com/web/packages/AGHmatrix/vignettes/Tutorial_AGHmatrix.html
- AGHmatrix paper:
  https://academic.oup.com/bioinformatics/article/39/7/btad445/7227072
- nadiv reference manual:
  https://cran.r-project.org/web/packages/nadiv/refman/nadiv.html

## Lessons

- Start with deterministic matrix facts, not broad model claims. `gllvmTMB`
  first tests sparse `Ainv` against a dense relationship construction before
  claiming end-to-end sparse animal-model coverage.
- Keep named ordering explicit. `drmTMB` and `gllvmTMB` both protect
  relationship-matrix work by aligning rows and columns by names before
  comparing.
- Make comparator scope visible. `gllvmTMB` separates live tests, partial rows,
  and future external-comparator sprints in public docs.
- Henderson-style direct inverse checks are the correct first atom for hsquared:
  the Julia lane owns sparse construction; the R lane must prove it sends
  ordered IDs and parent slots that reproduce the expected `Ainv`.
- AGHmatrix and nadiv show why the validation ladder must later widen beyond
  diploid additive `A`: G/H matrices, autopolyploid matrices, dominance, and
  sex-linked inverses are separate evidence rows, not one blended claim.

## hsquared Action

Add an internal three-animal fixture with:

- out-of-order input pedigree;
- expected normalized IDs;
- expected parent indices;
- expected sparse `Z` design;
- expected dense `Ainv` for the tiny calf/sire/dam pedigree.

Then test:

- R parser and bridge payload ordering without Julia;
- live Julia `pedigree_inverse()` agreement when a sibling `HSquared.jl`
  checkout is available.

## Claim Wording Risk

Allowed:

- "tiny deterministic Ainv validation fixture";
- "R payload ordering reproduces the expected Julia Ainv for a three-animal
  fixture when the local Julia bridge is available."

Blocked:

- "Mrode validation is covered";
- "ASReml comparison is covered";
- "sparse production fitting is validated";
- "large pedigree support is validated";
- "genomic or single-step validation exists."
