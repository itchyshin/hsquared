# Model status

This page separates what exists from what is planned.

## Exists now

- R package scaffold and CI.
- Team operating memory and claim registers.
- [`hs_control()`](https://itchyshin.github.io/hsquared/reference/hs_control.md)
  with default validation-only behavior and an experimental
  `engine = "julia"` option for tiny local bridge examples.
- [`animal()`](https://itchyshin.github.io/hsquared/reference/animal.md)
  as an inert formula marker.
- A v0.1 parser for `animal(1 | id, pedigree = ped)`.
- A tested internal R-to-Julia payload shape with `y`, `X`, sparse `Z`,
  method, family, encoded IDs, normalized pedigree metadata, and Julia
  target metadata.
- An experimental opt-in `control = hs_control(engine = "julia")` path
  that can send the tiny payload into a sibling `HSquared.jl` checkout
  and normalize the returned Julia result into the internal
  `hsquared_fit` contract.
- The first fitted-object/extractor contract over internal
  `hsquared_fit` objects and mocked Julia result fields, including
  variance components, heritability, EBVs, PEV, reliability, fixed
  effects, random effects, log-likelihood, AIC, prediction, and
  summaries.
- [`hs_data()`](https://itchyshin.github.io/hsquared/reference/hs_data.md)
  as a lightweight input container with ID maps for phenotype, pedigree,
  genotype, expression, marker, annotation, and environment inputs.
- Local tests for accepted syntax, rejected future syntax, and
  pedigree/data ID checks.

## Not implemented yet

- General model fitting.
- Default R-to-Julia bridge execution through
  [`hsquared()`](https://itchyshin.github.io/hsquared/reference/hsquared.md).
- R-side `Ainv` construction.
- Real variance components, heritability, EBVs, or BLUPs from fitted
  models.
- PEV or reliability through the current live Julia result payload.
- File-backed genotype/omics loading or streaming computation.
- Genomic and single-step models.
- Multivariate and factor-analytic G matrices.
- QTL-style effects, selfing, clonal inheritance, haplodiploidy,
  polyploidy, cytoplasmic inheritance, dominance, epistasis, and
  GLLVM-style models.
- GPU execution.

## Comparator targets

The long-term comparator set includes ASReml, MCMCglmm, sommer, BLUPF90,
DMU, WOMBAT, JWAS.jl, XSim.jl, AGHmatrix, nadiv, `drmTMB`, `gllvmTMB`,
`DRM.jl`, and `GLLVM.jl`.

Performance and coverage claims are evidence-gated. Public pages may
call a feature working only after code, tests, documentation, and
validation evidence exist.
