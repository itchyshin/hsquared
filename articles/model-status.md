# Model status

This page separates what exists from what is planned.

## Exists now

The default
[`hsquared()`](https://itchyshin.github.io/hsquared/reference/hsquared.md)
call fits the v0.1 univariate Gaussian animal model
(`y ~ fixed + animal(1 | id, pedigree = ped)`, REML) through the
`HSquared.jl` engine, validated by known-truth recovery, the published
gryphon REML anchor, and sommer agreement (see the [V0.1
contract](https://github.com/itchyshin/hsquared/blob/main/docs/design/01-v0.1-contract.md)).
Fitting requires a local Julia + `HSquared.jl`. The remaining items
below are the surrounding surface — parser, validation atoms, data
container, extractors, and advanced opt-in engine controls.

- Fits the v0.1 univariate Gaussian animal model by default and returns
  variance components, heritability, breeding values, fixed effects,
  fitted values, residuals, and
  [`fit_diagnostics()`](https://itchyshin.github.io/hsquared/reference/fit_diagnostics.md)
  (with an `at_boundary` flag).
- R package scaffold and CI.
- Team operating memory and claim registers.
- [`hs_control()`](https://itchyshin.github.io/hsquared/reference/hs_control.md)
  with default `engine = "fit"`, `engine = "validate"` for a no-fit
  preview, and `engine = "julia"` for advanced engine targets.
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
- [`genomic()`](https://itchyshin.github.io/hsquared/reference/genomic_markers.md)
  (supplied `Ginv` or a `markers` matrix),
  [`single_step()`](https://itchyshin.github.io/hsquared/reference/genomic_markers.md)
  (supplied `Hinv`),
  [`permanent()`](https://itchyshin.github.io/hsquared/reference/qg_effect_markers.md),
  [`common_env()`](https://itchyshin.github.io/hsquared/reference/qg_effect_markers.md),
  and
  [`maternal_genetic()`](https://itchyshin.github.io/hsquared/reference/qg_effect_markers.md)
  parse and fit only opt-in and experimentally (see “Opt-in and
  experimental” below); the default `engine = "fit"` path rejects them.
- [`markers()`](https://itchyshin.github.io/hsquared/reference/genomic_markers.md),
  [`marker_scan()`](https://itchyshin.github.io/hsquared/reference/genomic_markers.md),
  and
  [`qtl_scan()`](https://itchyshin.github.io/hsquared/reference/genomic_markers.md)
  reserve planned genomic/QTL formula vocabulary and currently error as
  not implemented.
- [`maternal_env()`](https://itchyshin.github.io/hsquared/reference/qg_effect_markers.md),
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
- A Mrode-style supplied-variance output fixture that pins Ainv, fixed
  effects, EBVs, fitted values, PEV, reliability, h2, ML log-likelihood,
  and dense/sparse REML log-likelihood against independent R references
  and the sibling Julia engine when available.
- The average-information REML optimizer (`HSquared.fit_ai_reml()`) that
  the default `engine = "fit"` uses to estimate the variance components.
  It is also reachable explicitly via
  `control = hs_control(engine = "julia", engine_control = list(target = "ai_reml"))`,
  records `variance_components_source = "estimated_ai_reml"`, recovers
  known truth in the DGP recovery study (near-unbiased), and recovers
  the published gryphon REML estimate within the maintainer-signed-off
  comparator band.
- The sparse NelderMead REML optimizer (`HSquared.fit_sparse_reml()`),
  reachable via
  `control = hs_control(engine = "julia", engine_control = list(target = "sparse_reml"))`.
  It records `variance_components_source = "estimated_sparse_reml"`,
  agrees with the average-information and dense optimizers, and recovers
  the published gryphon anchor.
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
- Marker/QTL/eQTL extractor names:
  [`marker_effects()`](https://itchyshin.github.io/hsquared/reference/marker_extractors.md),
  [`marker_variance_explained()`](https://itchyshin.github.io/hsquared/reference/marker_extractors.md),
  [`qtl_table()`](https://itchyshin.github.io/hsquared/reference/marker_extractors.md),
  [`gwas_table()`](https://itchyshin.github.io/hsquared/reference/marker_extractors.md),
  [`eqtl_table()`](https://itchyshin.github.io/hsquared/reference/marker_extractors.md),
  and
  [`lod_scores()`](https://itchyshin.github.io/hsquared/reference/marker_extractors.md).
  [`marker_effects()`](https://itchyshin.github.io/hsquared/reference/marker_extractors.md)
  returns the per-marker effects of an opt-in SNP-BLUP fit, and
  [`marker_variance_explained()`](https://itchyshin.github.io/hsquared/reference/marker_extractors.md)
  returns descriptive fitted-marker shares for that same path (see
  above). Scan tables and LOD outputs are still reserved and only return
  values for future `hsquared_fit` objects that contain matching result
  fields.
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

## Opt-in and experimental (not the default)

These models are reachable only through
`control = hs_control(engine = "julia", engine_control = list(target = ...))`,
are REML only, are Julia-owned (R only surfaces them), and are **not**
the default, not production, and not comparator/known-truth-validated.
Each mirrors a `partial` gate in the `HSquared.jl` twin.

- Repeatability / permanent environment —
  `animal(1 | id) + permanent(1 | id)`, `target = "repeatability"`
  (needs repeated records per individual).
- Common environment — `animal(1 | id) + common_env(1 | group)`,
  `target = "two_effect"` (additive + IID common environment).
- Maternal genetic — `animal(1 | id) + maternal_genetic(1 | dam)`,
  `target = "two_effect"` (additive + pedigree maternal effect). The
  correlated direct–maternal (2×2 G) model is still planned.
- Genomic GREML — `genomic(1 | id, Ginv = Ginv)` or
  `genomic(1 | id, markers = M)` (the engine builds the genomic
  relationship from the marker matrix), `target = "genomic"`.
- Single-step — `single_step(1 | id, Hinv = Hinv)` on a supplied
  single-step inverse, `target = "single_step"`. Building `Hinv` from a
  pedigree + G is planned.
- SNP-BLUP / RR-BLUP marker effects — `genomic(1 | id, markers = M)`,
  `target = "snp_blup"`, with supplied
  `variance_components = c(sigma_g2 = ..., sigma_e2 = ...)`. Returns
  per-marker effects via
  [`marker_effects()`](https://itchyshin.github.io/hsquared/reference/marker_extractors.md)
  plus per-individual genomic breeding values at the supplied variances
  (it does not estimate them). Mirrors the twin `V2-SNPBLUP` gate.
- Multivariate Gaussian animal model —
  `cbind(trait1, trait2) ~ animal(1 | id, pedigree = ped)`,
  `target = "multivariate"`. Returns G/R covariance and correlation
  matrices, per-trait h2, and cross-trait EBVs; missing trait cells may
  be `NA`. Dense validation-scale only; t\>=2 recovery and full
  same-estimand external-comparator evidence remain planned. A partial
  optional `sommer` diagonal-residual check exists for G0, diag(R0), and
  diagonal-target h2.

## Current limits

How many of each term can a formula carry today? The grammar is
deliberately narrow; these are the structural limits (not yet
“arbitrary” random effects):

- **Exactly one primary effect.** A formula carries exactly one of
  `animal(1 | id, pedigree = ped)` (a pedigree additive effect) or a
  supplied-relationship primary (`genomic(1 | id, ...)` /
  `single_step(1 | id, Hinv = ...)`). Two primary effects is an error.
- **At most one additional random effect,** and only alongside an
  [`animal()`](https://itchyshin.github.io/hsquared/reference/animal.md)
  primary: one of `permanent(1 | id)`, `common_env(1 | group)`, or
  `maternal_genetic(1 | dam)` (each opt-in/experimental). There is no
  support yet for a third random effect or for several independent
  grouping factors.
- **Random intercepts only.** Only `1 | group` is parsed. Random slopes
  (`x | id`) are rejected as planned-not-implemented, and a bare
  lme4-style `(... | group)` term is rejected with a pointer to the
  named effects above (it is never silently absorbed into the fixed
  effects).
- **One default response, plus opt-in
  [`cbind()`](https://rdrr.io/r/base/cbind.html).** The default path is
  a single numeric response. Multi-trait `cbind(...)` responses fit only
  through the experimental `engine = "julia", target = "multivariate"`
  path.
- **Gaussian identity link only.** Other families are planned, not
  implemented.
- **REML only on the fit path.** `REML = FALSE` (ML) is rejected; the
  supplied-variance paths (`henderson_mme`, `snp_blup`) solve at given
  variances rather than estimating them.
- **Fixed effects are unrestricted** otherwise: any number of ordinary
  fixed-effect terms (`sex + age + ...`) on the right-hand side is fine.

Arbitrary numbers of random effects and slopes, multiple correlated
random terms, and multi-trait responses are on the roadmap; the parser
names each unsupported form rather than guessing.

## Not implemented yet

- General default model fitting beyond the v0.1 univariate Gaussian
  animal model (the reserved inheritance kernels). The multivariate,
  standard two-effect, repeatability, genomic, SNP-BLUP, single-step,
  and non-Gaussian (`poisson`/`binomial`, Laplace or variational REML,
  no heritability) models fit only opt-in and experimentally (see
  above).
- ML estimation on the fit path (`REML = FALSE` is rejected; only REML
  is implemented).
- R-side `Ainv` construction (the engine builds `Ainv` in Julia).
- Estimated variance components, heritability, EBVs, or BLUPs as a
  default for any model other than the v0.1 univariate Gaussian animal
  model (the opt-in experimental models above return them but are not
  validated).
- Log-likelihood or information criteria for supplied-variance Henderson
  MME bridge results.
- Production sparse PEV or reliability.
- Full Mrode animal-model fit-output validation with estimated variance
  components.
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
- QTL, GWAS, or eQTL result generation, and marker-scan /
  marker-imputation results (the opt-in SNP-BLUP path above does return
  marker effects via
  [`marker_effects()`](https://itchyshin.github.io/hsquared/reference/marker_extractors.md)).
- Genomic and single-step models as a default or production path (an
  opt-in experimental path exists; see above).
- Factor-analytic and structured
  [`cov()`](https://rdrr.io/r/stats/cor.html) G matrices (the
  unstructured multivariate G/R path fits opt-in and experimentally; see
  above).
- Paternal, dominance, epistasis, custom relationship/precision,
  QTL-style, selfing, clonal, haplodiploid, polyploid, cytoplasmic,
  imprinting, and GLLVM-style models. (Permanent environment, common
  environment, and maternal genetic effects fit opt-in and
  experimentally; see above.)
- GPU execution.

## Comparator targets

`sommer` and `pedigreemm` are already in use as v0.1 comparators:
`sommer` is the signed-off `V1-COMPARATORS` agreement check on the
gryphon anchor, and `pedigreemm` provides a one-sided
REML-log-likelihood floor. The broader long-term comparator set
additionally includes ASReml, MCMCglmm, BLUPF90, DMU, WOMBAT, JWAS.jl,
XSim.jl, AGHmatrix, nadiv, `drmTMB`, `gllvmTMB`, `DRM.jl`, and
`GLLVM.jl`.

Performance and coverage claims are evidence-gated. Public pages may
call a feature working only after code, tests, documentation, and
validation evidence exist.
