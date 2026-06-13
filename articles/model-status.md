# Model status

This page separates what exists from what is planned.

## Exists now

- R package scaffold and CI.
- Team operating memory and claim registers.
- [`hs_control()`](https://itchyshin.github.io/hsquared/reference/hs_control.md)
  with default validation-only behavior and an experimental
  `engine = "julia"` option for tiny local bridge examples.
- [`hs_control()`](https://itchyshin.github.io/hsquared/reference/hs_control.md)
  stores planned CPU-thread, CUDA, AMDGPU, Metal, and oneAPI backend
  names as control metadata.
- [`backend_info()`](https://itchyshin.github.io/hsquared/reference/backend_info.md)
  reports the planned backend vocabulary and marks backend execution
  unavailable.
- [`formula_status()`](https://itchyshin.github.io/hsquared/reference/formula_status.md)
  reports parsed, reserved, and planned grammar terms without implying
  fitted support.
- [`validation_status()`](https://itchyshin.github.io/hsquared/reference/validation_status.md)
  reports current validation atoms and planned comparator lanes without
  running checks or implying fitted support.
- [`data_status()`](https://itchyshin.github.io/hsquared/reference/data_status.md)
  reports
  [`hs_data()`](https://itchyshin.github.io/hsquared/reference/hs_data.md)
  component presence, ID overlap, and pedigree, expression-feature,
  genotype-column, marker-map/genotype-marker alignment,
  annotation-feature, and environment-key diagnostics without implying
  fitted support.
- [`model_spec()`](https://itchyshin.github.io/hsquared/reference/model_spec.md)
  previews the parsed v0.1 animal-model contract, including fixed-effect
  design columns, sparse animal-effect design dimensions, normalized
  pedigree ordering, and Julia target metadata. It does not fit a model.
- [`genomic()`](https://itchyshin.github.io/hsquared/reference/genomic_markers.md),
  [`single_step()`](https://itchyshin.github.io/hsquared/reference/genomic_markers.md),
  [`markers()`](https://itchyshin.github.io/hsquared/reference/genomic_markers.md),
  [`marker_scan()`](https://itchyshin.github.io/hsquared/reference/genomic_markers.md),
  and
  [`qtl_scan()`](https://itchyshin.github.io/hsquared/reference/genomic_markers.md)
  reserve planned formula vocabulary and currently error as not
  implemented.
- [`permanent()`](https://itchyshin.github.io/hsquared/reference/qg_effect_markers.md),
  [`common_env()`](https://itchyshin.github.io/hsquared/reference/qg_effect_markers.md),
  [`maternal_genetic()`](https://itchyshin.github.io/hsquared/reference/qg_effect_markers.md),
  [`maternal_env()`](https://itchyshin.github.io/hsquared/reference/qg_effect_markers.md),
  [`paternal_genetic()`](https://itchyshin.github.io/hsquared/reference/qg_effect_markers.md),
  [`paternal_env()`](https://itchyshin.github.io/hsquared/reference/qg_effect_markers.md),
  [`cytoplasmic()`](https://itchyshin.github.io/hsquared/reference/qg_effect_markers.md),
  [`imprinting()`](https://itchyshin.github.io/hsquared/reference/qg_effect_markers.md),
  [`dominance()`](https://itchyshin.github.io/hsquared/reference/qg_effect_markers.md),
  [`epistasis()`](https://itchyshin.github.io/hsquared/reference/qg_effect_markers.md),
  [`relmat()`](https://itchyshin.github.io/hsquared/reference/qg_effect_markers.md),
  and
  [`precision()`](https://itchyshin.github.io/hsquared/reference/qg_effect_markers.md)
  reserve standard quantitative-genetic and inheritance-kernel
  vocabulary and currently error as not implemented.
- [`animal()`](https://itchyshin.github.io/hsquared/reference/animal.md)
  as an inert formula marker.
- A v0.1 parser for `animal(1 | id, pedigree = ped)`, and for
  `animal(1 | id)` when `data` is an
  [`hs_data()`](https://itchyshin.github.io/hsquared/reference/hs_data.md)
  bundle with a pedigree component.
- A tested internal R-to-Julia payload shape with `y`, `X`, sparse `Z`,
  method, family, encoded IDs, normalized pedigree metadata, and Julia
  target metadata.
- An experimental opt-in `control = hs_control(engine = "julia")` path
  that can send the tiny payload into a sibling `HSquared.jl` checkout,
  marshal sparse `Z` through CSC slots, and normalize the returned Julia
  result into the internal `hsquared_fit` contract. When the sibling
  Julia package exposes dense validation extractors, this path also
  enriches the result with PEV/reliability fields.
- An explicit supplied-variance bridge target,
  `engine_control = list(target = "henderson_mme", variance_components = ...)`,
  that calls Julia `henderson_mme()` for tiny validation examples. It
  does not estimate variance components and does not provide a
  log-likelihood. When the sibling Julia checkout exposes applicable
  dense validation extractors, it can attach PEV/reliability fields.
- An internal tiny validation fixture that pins R payload ordering,
  sparse `Z`, and live Julia `pedigree_inverse()` agreement for a
  three-animal pedigree when the local Julia bridge is available.
- An optional Mrode9/nadiv pedigree-Ainv comparator test when `nadiv`
  and a sibling `HSquared.jl` checkout are available.
- An internal supplied-variance Henderson MME validation fixture that
  compares an independent R reference solve with Julia `henderson_mme()`
  for fixed effects, EBVs, fitted values, h2, and optional dense
  validation-path PEV/reliability when a sibling `HSquared.jl` checkout
  is available.
- A tiny supplied-variance likelihood fixture that compares Julia dense
  REML and sparse REML evaluators, plus an ML hand-check target, when a
  sibling `HSquared.jl` checkout is available.
- The first fitted-object/extractor contract over internal
  `hsquared_fit` objects and mocked Julia result fields, including
  variance components, heritability, EBV/BLUP aliases, PEV, reliability,
  accuracy, fixed effects, random effects, log-likelihood, AIC,
  prediction, fitted values, residuals, summaries,
  [`coef()`](https://rdrr.io/r/stats/coef.html),
  [`nobs()`](https://rdrr.io/r/stats/nobs.html), and
  [`fit_diagnostics()`](https://itchyshin.github.io/hsquared/reference/fit_diagnostics.md)
  for convergence, optimizer, target, iteration, and
  dense-validation-path metadata.
- Reserved marker/QTL/eQTL extractor names:
  [`marker_effects()`](https://itchyshin.github.io/hsquared/reference/marker_extractors.md),
  [`marker_variance_explained()`](https://itchyshin.github.io/hsquared/reference/marker_extractors.md),
  [`qtl_table()`](https://itchyshin.github.io/hsquared/reference/marker_extractors.md),
  [`gwas_table()`](https://itchyshin.github.io/hsquared/reference/marker_extractors.md),
  [`eqtl_table()`](https://itchyshin.github.io/hsquared/reference/marker_extractors.md),
  and
  [`lod_scores()`](https://itchyshin.github.io/hsquared/reference/marker_extractors.md).
  These only return values for future `hsquared_fit` objects that
  contain matching result fields.
- [`hs_data()`](https://itchyshin.github.io/hsquared/reference/hs_data.md)
  as a lightweight input container with ID maps for phenotype, pedigree,
  genotype, expression, marker, annotation, and environment inputs.
- `summary(hs_data(...))` reports ID overlap and mismatch counts for
  phenotype, pedigree, genotype, and expression components.
- `summary(hs_data(...))` reports pedigree coverage, founder,
  parent-link, and conservative warning counts when a pedigree component
  is supplied.
- `summary(hs_data(...))` reports marker-map and genotype-marker
  alignment diagnostics when marker or genotype components are supplied.
- [`hs_data()`](https://itchyshin.github.io/hsquared/reference/hs_data.md)
  validates supplied marker maps for marker ID, chromosome, and
  non-negative numeric position columns. This is metadata validation
  only.
- When both `genotypes` and `markers` are supplied,
  [`hs_data()`](https://itchyshin.github.io/hsquared/reference/hs_data.md)
  checks that genotype marker columns match marker-map IDs exactly.
- `hs_data(expression = ..., annotation = ..., annotation_id = ...)`
  checks expression feature columns against annotation rows and reports
  duplicate or unmatched annotation keys. This is metadata validation
  only.
- `hs_data(environment = ..., environment_id = ...)` checks environment
  metadata coverage against phenotype records and reports duplicate or
  unmatched environment keys. This is metadata validation only.
- [`model_spec()`](https://itchyshin.github.io/hsquared/reference/model_spec.md)
  and
  [`hsquared()`](https://itchyshin.github.io/hsquared/reference/hsquared.md)
  can use an
  [`hs_data()`](https://itchyshin.github.io/hsquared/reference/hs_data.md)
  object for the v0.1 animal-model parser, reading model variables from
  `phenotypes` and using the bundle pedigree by default when
  `animal(1 | id)` omits `pedigree =`.
- Local tests for accepted syntax, rejected future syntax, and
  pedigree/data ID checks.

## Not implemented yet

- General model fitting.
- Default R-to-Julia bridge execution through
  [`hsquared()`](https://itchyshin.github.io/hsquared/reference/hsquared.md).
- R-side `Ainv` construction.
- General estimated variance components, heritability, EBVs, or BLUPs
  from fitted models.
- Log-likelihood or information criteria for supplied-variance Henderson
  MME bridge results.
- Production sparse PEV or reliability.
- Full Mrode animal-model fit-output validation.
- ASReml, BLUPF90, DMU, or WOMBAT comparator validation.
- File-backed genotype/omics loading or streaming computation.
- Automatic model construction from genotype, marker, expression,
  annotation, or environment components in
  [`hs_data()`](https://itchyshin.github.io/hsquared/reference/hs_data.md).
- Environmental random effects or multi-environment model terms from
  `environment` metadata.
- Automatic feature annotation joins, eQTL scans, or omics models from
  `expression` and `annotation` metadata.
- Allele coding, marker imputation, PLINK/VCF parsing, or marker
  scanning from marker maps.
- Marker, QTL, GWAS, or eQTL result generation.
- Genomic and single-step models.
- Multivariate and factor-analytic G matrices.
- Permanent environment, common environment, maternal/paternal,
  dominance, epistasis, custom relationship/precision, QTL-style,
  selfing, clonal, haplodiploid, polyploid, cytoplasmic, imprinting, and
  GLLVM-style models.
- GPU execution.

## Comparator targets

The long-term comparator set includes ASReml, MCMCglmm, sommer, BLUPF90,
DMU, WOMBAT, JWAS.jl, XSim.jl, AGHmatrix, nadiv, `drmTMB`, `gllvmTMB`,
`DRM.jl`, and `GLLVM.jl`.

Performance and coverage claims are evidence-gated. Public pages may
call a feature working only after code, tests, documentation, and
validation evidence exist.
