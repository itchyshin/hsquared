# Phase 1+ Big-Plan Scout

Date: 2026-06-13

Active lenses: Ada, Shannon, Jason, Boole, Hopper, Henderson, Mendel,
Kirkpatrick, Falconer, Mrode, Pat, Rose, Grace.

Spawned subagents: Julia twin thread is active for the `HSquared.jl` lane; no
tool-spawned subagents from this R lane.

## Question

How should `hsquared` grow beyond the first animal-model parser while staying
easy for users and reusable across the R and Julia twins?

## Local Repositories Checked

- `drmTMB`: R formula discipline, Julia bridge guardrails, fitted/planned/missing
  separation, after-task logs.
- `gllvmTMB`: animal keyword family, long/wide data discipline, capability
  tables, explicit unsupported-syntax errors.
- `DRM.jl`: Julia engine layout, bridge/parity files, benchmarks, sparse and
  inference experiments, Documenter-style package site.
- `GLLVM.jl`: high-dimensional Julia engine/documentation pattern.
- Local search did not find `PMTMB`, `JWAS`, `XSim`, `AGHmatrix`, or `nadiv`
  repositories under `/Users/z3437171/Dropbox/Github Local`.

## Literature And Package Anchors

- Henderson's direct inverse of the numerator relationship matrix anchors
  sparse `Ainv` construction rather than dense `A` inversion.
- Single-step GBLUP combines pedigree and genomic relationships; this belongs
  in Phase 5, after the simple animal model is validated.
- APY-style genomic inverse methods are the scale path for very large genomic
  evaluations.
- Kirkpatrick/Meyer-style reduced-rank and factor-analytic genetic covariance
  matrices anchor the Phase 4 high-dimensional G-matrix plan.
- JWAS.jl shows that Julia is already credible for Bayesian genomic prediction
  and GWAS; `hsquared` should not duplicate it blindly, but should learn from
  its genomic workflow vocabulary.
- XSim.jl is a natural simulation partner for genomic, QTL, selection, and
  breeding-program validation.
- AGHmatrix is the warning and opportunity for plant and polyploid users: A, G,
  and H matrices need diploid/autopolyploid design, not just animal-breeding
  defaults.
- nadiv is the benchmark for additive, dominance, and epistatic inverse
  relationship-matrix workflows in ecological/evolutionary animal models.

Useful public references checked:

- Henderson Ainv paper listing:
  <https://www.jstor.org/stable/2529339>
- Single-step genomic BLUP overview:
  <https://guidelines.beefimprovement.org/index.php/Single-step_Genomic_BLUP>
- APY/genomic inverse example:
  <https://pmc.ncbi.nlm.nih.gov/articles/PMC10820638/>
- Factor-analytic genetic covariance example:
  <https://link.springer.com/article/10.1186/1297-9686-41-21>
- JWAS.jl documentation:
  <https://reworkhow.github.io/JWAS.jl/latest/>
- XSim.jl documentation:
  <https://reworkhow.github.io/XSim.jl/>
- AGHmatrix CRAN page:
  <https://cran.r-project.org/package=AGHmatrix>
- nadiv CRAN reference:
  <https://cran.r-project.org/web/packages/nadiv/refman/nadiv.html>

## hsquared Actions

1. Keep the v0.1 API easy:
   `hsquared(y ~ fixed + animal(1 | id, pedigree = ped), data = dat)`.
2. Keep R and Julia grammar transferable where concepts match. The R package
   should parse and validate; Julia should own sparse computation.
3. Treat genomic, QTL, selfing, clonal, haplodiploid, polyploid,
   cytoplasmic, dominance, epistasis, GLLVM, and GPU ideas as roadmap-visible
   lanes, not current features.
4. Before each substantial Phase 1+ slice, do a local sibling scout and update
   this folder or the relevant design file.
5. Public claims may say "planned", "target", "parser", or "validation canon";
   they may not say "fits", "supports", or "ASReml-level" until tests and
   comparator evidence exist.

## Claim Risk

The biggest risk is exciting roadmap language sounding implemented. Rose blocks
that by requiring capability-status and public-claims rows for every widened
claim.
