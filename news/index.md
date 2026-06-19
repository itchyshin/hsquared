# Changelog

## hsquared (development version)

### New features

- **Experimental:**
  [`heritability_interval()`](https://itchyshin.github.io/hsquared/reference/heritability_interval.md)
  extracts a large-sample confidence interval for `h²` from the default
  Gaussian animal-model fit, when a local Julia engine returns one. It
  is a REML-only, asymptotic (logit delta-method) interval — mirroring
  the engine row `V1-HERIT-CI` (`partial`), so it is not
  coverage-calibrated and is unreliable at small `n`. It is reported as
  a point estimate plus bounds, not a validated capability
  ([\#11](https://github.com/itchyshin/hsquared/issues/11)).
- **Experimental:**
  [`variance_component_standard_errors()`](https://itchyshin.github.io/hsquared/reference/variance_component_standard_errors.md)
  and
  [`heritability_standard_error()`](https://itchyshin.github.io/hsquared/reference/variance_component_standard_errors.md)
  return large-sample (delta-method) standard errors from the REML
  average-information matrix, when the default Gaussian fit’s engine
  provides them. Same `V1-HERIT-CI` (`partial`) caveats: asymptotic,
  REML-only, omitted near a variance-component boundary (ill-conditioned
  AI matrix), not coverage-calibrated, not a validated capability.
- **Experimental:**
  [`repeatability_interval()`](https://itchyshin.github.io/hsquared/reference/repeatability_interval.md)
  returns a logit delta-method confidence interval for the repeatability
  coefficient `t = (Va + Vpe) / Vp` from the opt-in repeatability model,
  when the engine provides one. It mirrors the engine row
  `V3-REPEAT-REML` (`partial`): engine-internal self-consistency tested
  (recovery of `t` + interval bracketing on seeded fixtures) but with no
  external comparator, no `h²` interval, and no deep-pedigree
  validation; reported as a point estimate plus bounds only
  ([\#12](https://github.com/itchyshin/hsquared/issues/12)).
- [`summary()`](https://rdrr.io/r/base/summary.html)/[`print()`](https://rdrr.io/r/base/print.html)
  for `hsquared_fit` now display the experimental heritability
  confidence interval, variance-component and heritability standard
  errors, and repeatability interval when a fit carries them, clearly
  labelled experimental and asymptotic
  ([\#28](https://github.com/itchyshin/hsquared/issues/28)).
- New “Benchmark: hsquared vs sommer and pedigreemm” article documents
  the v0.1 Gaussian animal-model fit agreeing with `sommer` and the
  published gryphon anchor within the signed-off band, with reproducing
  code and the `pedigreemm` one-sided log-likelihood floor
  ([\#31](https://github.com/itchyshin/hsquared/issues/31)).
- Added a base-graphics
  [`plot()`](https://rdrr.io/r/graphics/plot.default.html) method for
  `hsquared_fit`: `type = "variance"` plots the variance components
  (with experimental `+/- 1.96 SE` whiskers when present) and
  `type = "residuals"` plots residuals against fitted values
  ([\#30](https://github.com/itchyshin/hsquared/issues/30)).
- **Experimental:**
  [`covariance_standard_errors()`](https://itchyshin.github.io/hsquared/reference/covariance_standard_errors.md)
  returns delta-method standard errors for the multivariate
  genetic/residual covariance and correlation matrices and per-trait
  `h²`, for an opt-in **unstructured** multivariate fit when the engine
  provides them. Mirrors `V4-MV-REML` (`partial`): asymptotic,
  REML-only, unstructured-only, and reported while the multivariate
  recovery calibration has not passed — not a validated capability
  ([\#26](https://github.com/itchyshin/hsquared/issues/26)).

## hsquared 0.1.0

### New features

- **The default
  [`hsquared()`](https://itchyshin.github.io/hsquared/reference/hsquared.md)
  call now fits the v0.1 univariate Gaussian animal model**
  `y ~ fixed + animal(1 | id, pedigree = ped)` by REML
  (average-information) through the `HSquared.jl` engine, returning
  heritability, variance components, breeding values, fixed effects,
  fitted values, residuals, and diagnostics. Fitting requires a local
  Julia, the `JuliaCall` package, and an `HSquared.jl` checkout; without
  them the default call errors with install guidance, and
  `hs_control(engine = "validate")` validates the contract without
  fitting. ML is not implemented — `REML = FALSE` is rejected on the fit
  path. The fit is validated by known-truth recovery, the published
  gryphon REML anchor (within the signed-off comparator band), and
  `sommer` agreement
  ([\#6](https://github.com/itchyshin/hsquared/issues/6),
  [\#7](https://github.com/itchyshin/hsquared/issues/7)). These
  engine-recovery checks run locally through the R-to-Julia bridge (a
  local Julia and `HSquared.jl` checkout are required); public CI
  exercises the equivalent pure-R REML reference and skip-guards the
  live-engine tests.
- [`animal()`](https://itchyshin.github.io/hsquared/reference/animal.md)
  is now exported as an inert formula marker, and
  [`hsquared()`](https://itchyshin.github.io/hsquared/reference/hsquared.md)
  parses the narrow v0.1 formula contract
  `animal(1 | id, pedigree = ped)`
  ([\#4](https://github.com/itchyshin/hsquared/issues/4),
  [\#6](https://github.com/itchyshin/hsquared/issues/6)).
- [`EBV()`](https://itchyshin.github.io/hsquared/reference/breeding_values.md)
  and
  [`BLUP()`](https://itchyshin.github.io/hsquared/reference/breeding_values.md)
  now alias
  [`breeding_values()`](https://itchyshin.github.io/hsquared/reference/breeding_values.md)
  for `hsquared_fit` objects, and
  [`accuracy()`](https://itchyshin.github.io/hsquared/reference/reliability.md)
  derives square-root reliability when reliability estimates are present
  ([\#5](https://github.com/itchyshin/hsquared/issues/5)).
- [`fitted()`](https://rdrr.io/r/stats/fitted.values.html) and
  [`residuals()`](https://rdrr.io/r/stats/residuals.html) now work for
  `hsquared_fit` objects that contain fitted-value predictions and
  response values
  ([\#5](https://github.com/itchyshin/hsquared/issues/5)).
- Added
  [`fit_diagnostics()`](https://itchyshin.github.io/hsquared/reference/fit_diagnostics.md)
  for `hsquared_fit` objects so users and developers can inspect engine,
  method, target, convergence, optimizer status, iterations,
  log-likelihood, and dense-validation-path metadata without refitting
  or implying production support
  ([\#5](https://github.com/itchyshin/hsquared/issues/5),
  [\#6](https://github.com/itchyshin/hsquared/issues/6)).
- [`coef()`](https://rdrr.io/r/stats/coef.html) now aliases fixed-effect
  extraction for `hsquared_fit` objects, and
  [`nobs()`](https://rdrr.io/r/stats/nobs.html) reports the result
  observation count or response-payload fallback when available
  ([\#5](https://github.com/itchyshin/hsquared/issues/5)).
- [`hs_control()`](https://itchyshin.github.io/hsquared/reference/hs_control.md)
  has an `engine = "julia"` option that exposes advanced engine targets
  (supplied-variance Henderson MME, the opt-in sparse REML optimizer,
  explicit `ai_reml` control, repeatability/two-effect/genomic/SNP-BLUP
  targets, and the opt-in multivariate target) through a sibling
  `HSquared.jl` checkout via JuliaCall. The default `engine = "fit"`
  already fits the v0.1 model via `ai_reml`; non-Gaussian fitted-model
  support is still planned
  ([\#6](https://github.com/itchyshin/hsquared/issues/6)).
- [`hs_control()`](https://itchyshin.github.io/hsquared/reference/hs_control.md)
  now recognizes an experimental, opt-in
  `engine_control = list(target = "sparse_reml", initial = ..., iterations = ...)`
  path that surfaces the Julia-owned `HSquared.fit_sparse_reml()`
  REML-only sparse optimizer through the local bridge. It is not the
  default
  [`hsquared()`](https://itchyshin.github.io/hsquared/reference/hsquared.md)
  behaviour, not variance-component estimation in the public R
  interface, and not a production sparse fitting, AI-REML, or
  ASReml-parity claim
  ([\#6](https://github.com/itchyshin/hsquared/issues/6),
  [\#7](https://github.com/itchyshin/hsquared/issues/7)).
- **Experimental, opt-in repeatability (permanent-environment) model.**
  [`hsquared()`](https://itchyshin.github.io/hsquared/reference/hsquared.md)
  now parses `animal(1 | id, pedigree = ped) + permanent(1 | id)` and
  fits it through `engine_control = list(target = "repeatability")`,
  surfacing the Julia-owned `HSquared.fit_repeatability_reml()`
  REML-only optimizer. It returns three variance components (animal,
  permanent, residual),
  [`repeatability()`](https://itchyshin.github.io/hsquared/reference/repeatability.md),
  [`heritability()`](https://itchyshin.github.io/hsquared/reference/heritability.md),
  breeding values, and
  [`permanent_effects()`](https://itchyshin.github.io/hsquared/reference/permanent_effects.md).
  The default `engine = "fit"` path stays single-effect and rejects
  [`permanent()`](https://itchyshin.github.io/hsquared/reference/qg_effect_markers.md)
  with a pointer to the opt-in target. This is experimental and
  REML-only; the additive (σ²a) and permanent-environment (σ²pe)
  variances are identifiable only with repeated records per individual.
  It is not the default, not ML, and not yet a production or
  comparator-validated claim.
- **Experimental, opt-in common-environment (two-effect) model.**
  [`hsquared()`](https://itchyshin.github.io/hsquared/reference/hsquared.md)
  now parses `animal(1 | id, pedigree = ped) + common_env(1 | group)`
  and fits it through `engine_control = list(target = "two_effect")`,
  surfacing the Julia-owned `HSquared.fit_two_effect_reml()` REML-only
  optimizer (additive genetic effect + an IID common-environment effect,
  e.g. litter or cage). It returns three variance components (animal,
  common_env, residual),
  [`heritability()`](https://itchyshin.github.io/hsquared/reference/heritability.md),
  breeding values, and
  [`common_env_effects()`](https://itchyshin.github.io/hsquared/reference/common_env_effects.md).
  The default `engine = "fit"` path stays single-effect. This is
  experimental and REML-only; not the default, not production or
  comparator-validated; correlated direct–maternal (2×2 G) effects
  remain planned.
- **Experimental, opt-in maternal-genetic two-effect model.**
  [`hsquared()`](https://itchyshin.github.io/hsquared/reference/hsquared.md)
  now parses
  `animal(1 | id, pedigree = ped) + maternal_genetic(1 | dam)` and fits
  it through `engine_control = list(target = "two_effect")`: a direct
  additive genetic effect plus a maternal genetic effect expressed
  through the dam, both carrying the pedigree relationship (A₂ =
  pedigree A). It returns three variance components (animal,
  maternal_genetic, residual),
  [`heritability()`](https://itchyshin.github.io/hsquared/reference/heritability.md),
  breeding values, and
  [`maternal_effects()`](https://itchyshin.github.io/hsquared/reference/maternal_effects.md);
  the dams must be animals in the
  [`animal()`](https://itchyshin.github.io/hsquared/reference/animal.md)
  pedigree. Experimental and REML-only; the correlated direct–maternal
  (2×2 G) model remains planned.
- **Experimental, opt-in genomic GREML model.**
  [`hsquared()`](https://itchyshin.github.io/hsquared/reference/hsquared.md)
  now parses `genomic(1 | id, Ginv = Ginv)` — a primary genomic effect
  with a user-supplied genomic relationship inverse — and fits it
  through `engine_control = list(target = "genomic")`, surfacing
  `HSquared.fit_ai_reml()` on a Ginv-based spec (genomic REML). It
  returns the genomic and residual variance components, genomic
  [`heritability()`](https://itchyshin.github.io/hsquared/reference/heritability.md),
  and genomic breeding values (GEBVs). You can either supply a
  precomputed `Ginv`, or pass a raw marker matrix
  (`genomic(1 | id, markers = M)`) and let the engine build the genomic
  relationship and its inverse. The default `engine = "fit"` path is the
  pedigree animal model;
  [`genomic()`](https://itchyshin.github.io/hsquared/reference/genomic_markers.md)
  is opt-in. Experimental and REML-only; comparator validation and
  weighted/standardized-marker variants remain planned.
- **Experimental, opt-in single-step model.**
  [`hsquared()`](https://itchyshin.github.io/hsquared/reference/hsquared.md)
  now parses `single_step(1 | id, Hinv = Hinv)` — a primary effect with
  a user-supplied single-step relationship inverse — and fits it through
  `engine_control = list(target = "single_step")`, reusing the same
  `fit_ai_reml`-on-a-supplied-inverse path as
  [`genomic()`](https://itchyshin.github.io/hsquared/reference/genomic_markers.md).
  Experimental and REML-only; building `Hinv` from a pedigree and
  genomic relationship (single-step HBLUP construction) and comparator
  validation remain planned.
- **Experimental, opt-in SNP-BLUP / RR-BLUP marker-effect model.**
  [`hsquared()`](https://itchyshin.github.io/hsquared/reference/hsquared.md)
  now fits `genomic(1 | id, markers = M)` through
  `engine_control = list(target = "snp_blup", variance_components = c(sigma_g2 = ..., sigma_e2 = ...))`,
  surfacing the Julia-owned `HSquared.fit_snp_blup()`. At the supplied
  genomic/residual variances it estimates per-marker effects —
  extractable with
  [`marker_effects()`](https://itchyshin.github.io/hsquared/reference/marker_extractors.md)
  — together with per-individual genomic breeding values and fixed
  effects (the engine centres the markers, VanRaden method 1).
  [`marker_variance_explained()`](https://itchyshin.github.io/hsquared/reference/marker_extractors.md)
  reports a descriptive fitted-marker contribution table for this path,
  computed from effect squared times centered marker variance and
  normalized across markers; it is not a marker-scan, p-value, or QTL
  claim. This is a supplied-variance solve (it does not estimate the
  variance components), opt-in, and not the default; it mirrors the twin
  `V2-SNPBLUP` gate (the GBLUP↔︎SNP-BLUP genomic-breeding-value
  equivalence). REML estimation of the marker variance,
  weighted/Bayesian marker priors, and comparator parity remain planned.
- **Experimental, opt-in multivariate Gaussian animal model.**
  [`hsquared()`](https://itchyshin.github.io/hsquared/reference/hsquared.md)
  now parses
  `cbind(trait1, trait2, ...) ~ fixed + animal(1 | id, pedigree = ped)`
  and fits it through `engine_control = list(target = "multivariate")`,
  surfacing the Julia-owned `HSquared.fit_multivariate_reml()` REML-only
  dense estimator. It returns G/R covariance matrices, genetic and
  residual correlations, per-trait heritability, and cross-trait EBVs
  through
  [`genetic_covariance()`](https://itchyshin.github.io/hsquared/reference/multivariate_extractors.md),
  [`residual_covariance()`](https://itchyshin.github.io/hsquared/reference/multivariate_extractors.md),
  [`genetic_correlation()`](https://itchyshin.github.io/hsquared/reference/multivariate_extractors.md),
  [`residual_correlation()`](https://itchyshin.github.io/hsquared/reference/multivariate_extractors.md),
  [`heritability()`](https://itchyshin.github.io/hsquared/reference/heritability.md),
  and
  [`breeding_values()`](https://itchyshin.github.io/hsquared/reference/breeding_values.md).
  Missing trait cells are accepted as `NA` and marshal to Julia `NaN`;
  rank-deficient fixed-effect designs are rejected up front;
  non-converged fits do not expose
  [`logLik()`](https://rdrr.io/r/stats/logLik.html)/[`AIC()`](https://rdrr.io/r/stats/AIC.html).
  This is opt-in, dense validation-scale, and partial; t\>=2 known-truth
  recovery, external comparator parity, and long-format/structured
  covariance grammar remain planned.
- [`hsquared()`](https://itchyshin.github.io/hsquared/reference/hsquared.md)
  now fences the reserved multivariate
  `engine_control$genetic_structure` and `engine_control$rank` fields:
  `"unstructured"` is accepted for the current opt-in multivariate
  bridge, while `"diagonal"`, `"lowrank"`, `"factor_analytic"`, and
  `rank` error as planned rather than being silently ignored.
- [`formula_status()`](https://itchyshin.github.io/hsquared/reference/formula_status.md)
  and structured-covariance error messages now list the full planned
  covariance vocabulary (`cov = us()`, `cov = diag()`,
  `cov = lowrank(K)`, and `cov = fa(K)`) while keeping it planned, not
  fitted.
- Multivariate [`cbind()`](https://rdrr.io/r/base/cbind.html) responses
  now require unique, non-empty trait names before fitting, so G/R
  matrices, per-trait h², EBVs, comparator files, and future wide/long
  response paths share an unambiguous trait-order contract
  ([\#10](https://github.com/itchyshin/hsquared/issues/10)).
- [`G_matrix()`](https://itchyshin.github.io/hsquared/reference/multivariate_extractors.md)
  and
  [`R_matrix()`](https://itchyshin.github.io/hsquared/reference/multivariate_extractors.md)
  now alias
  [`genetic_covariance()`](https://itchyshin.github.io/hsquared/reference/multivariate_extractors.md)
  and
  [`residual_covariance()`](https://itchyshin.github.io/hsquared/reference/multivariate_extractors.md)
  for `hsquared_fit` objects, giving multivariate users the familiar G/R
  matrix names without changing the underlying extractor contract.
- Added a “Reading G matrices” pkgdown article that explains the current
  G/R matrix extractors, genetic and residual correlations, per-trait
  h2, cross-trait EBVs, and the boundaries around `P_matrix()`,
  factor-analytic loadings, and selection-response claims.
- Added a “Genomic prediction” pkgdown article that separates the
  current opt-in supplied-`Ginv`, marker-built GREML, SNP-BLUP, and
  supplied-`Hinv` single-step paths from planned genomic construction,
  APY, GWAS/QTL/eQTL, and production-comparator work.
- Added a “QTL, GWAS, and eQTL status” pkgdown article that explains the
  current reserved scan vocabulary, live SNP-BLUP marker effects /
  descriptive marker variance shares, scale caveats, and validation
  gates before marker-scan, QTL, GWAS, or eQTL output can be claimed.
- Added an “Inheritance systems roadmap” pkgdown article that gives
  selfing, clonal, haplodiploid, polyploid, cytoplasmic, imprinting,
  dominance, epistasis, and custom-kernel examples as planned
  relationship/precision-kernel work, while keeping current support
  limited to the v0.1 additive animal model and opt-in standard
  two-effect slices.
- [`prediction_error_variance()`](https://itchyshin.github.io/hsquared/reference/prediction_error_variance.md)
  and
  [`reliability()`](https://itchyshin.github.io/hsquared/reference/reliability.md)
  are now part of the R fitted-object extractor contract. They work for
  `hsquared_fit` objects containing those result fields
  ([\#5](https://github.com/itchyshin/hsquared/issues/5),
  [\#6](https://github.com/itchyshin/hsquared/issues/6)).
- Added marker/QTL/eQTL extractor names:
  [`marker_effects()`](https://itchyshin.github.io/hsquared/reference/marker_extractors.md),
  [`marker_variance_explained()`](https://itchyshin.github.io/hsquared/reference/marker_extractors.md),
  [`qtl_table()`](https://itchyshin.github.io/hsquared/reference/marker_extractors.md),
  [`gwas_table()`](https://itchyshin.github.io/hsquared/reference/marker_extractors.md),
  [`eqtl_table()`](https://itchyshin.github.io/hsquared/reference/marker_extractors.md),
  and
  [`lod_scores()`](https://itchyshin.github.io/hsquared/reference/marker_extractors.md).
  [`marker_effects()`](https://itchyshin.github.io/hsquared/reference/marker_extractors.md)
  now returns the per-marker effects of an opt-in SNP-BLUP fit, and
  [`marker_variance_explained()`](https://itchyshin.github.io/hsquared/reference/marker_extractors.md)
  reports descriptive fitted-marker shares for the same path; scan
  tables and LOD outputs remain output-vocabulary placeholders, with
  marker-scan, QTL, GWAS, and eQTL fitting still planned
  ([\#5](https://github.com/itchyshin/hsquared/issues/5),
  [\#9](https://github.com/itchyshin/hsquared/issues/9)).
- Added an explicit supplied-variance Julia bridge target for Henderson
  MME validation.
  `hs_control(engine = "julia", engine_control = list(target = "henderson_mme", variance_components = c(sigma_a2 = ..., sigma_e2 = ...)))`
  calls Julia `henderson_mme()` for tiny validation examples, returning
  fixed effects, EBVs, fitted values, variance components, and h²
  without claiming variance-component estimation or production fitting
  ([\#6](https://github.com/itchyshin/hsquared/issues/6),
  [\#7](https://github.com/itchyshin/hsquared/issues/7)).
- The supplied-variance Henderson MME bridge target now attaches dense
  validation-path PEV and reliability fields when the sibling
  `HSquared.jl` checkout exposes applicable
  [`prediction_error_variance()`](https://itchyshin.github.io/hsquared/reference/prediction_error_variance.md)
  and
  [`reliability()`](https://itchyshin.github.io/hsquared/reference/reliability.md)
  methods for `HendersonMMEResult`
  ([\#6](https://github.com/itchyshin/hsquared/issues/6),
  [\#7](https://github.com/itchyshin/hsquared/issues/7)).
- The experimental local Julia bridge now enriches tiny `hsquared_fit`
  results with dense validation-path PEV and reliability fields when the
  sibling `HSquared.jl` checkout exposes
  [`prediction_error_variance()`](https://itchyshin.github.io/hsquared/reference/prediction_error_variance.md)
  and
  [`reliability()`](https://itchyshin.github.io/hsquared/reference/reliability.md)
  ([\#5](https://github.com/itchyshin/hsquared/issues/5),
  [\#6](https://github.com/itchyshin/hsquared/issues/6)).
- The experimental Julia bridge now sends sparse `Matrix::dgCMatrix`
  random-effect designs through Julia CSC slots instead of densifying
  `Z` ([\#6](https://github.com/itchyshin/hsquared/issues/6)).
- Added an internal tiny animal-model validation fixture that pins R
  payload ordering, sparse `Z` construction, and live Julia
  `pedigree_inverse()` agreement for a three-animal Henderson-style
  pedigree when a sibling `HSquared.jl` checkout is available
  ([\#7](https://github.com/itchyshin/hsquared/issues/7)).
- Added an optional Mrode9/nadiv pedigree-Ainv comparator fixture. When
  `nadiv` and a sibling `HSquared.jl` checkout are available, local
  tests compare Julia `pedigree_inverse()` with
  [`nadiv::makeAinv()`](https://rdrr.io/pkg/nadiv/man/makeAinv.html) for
  the Mrode9 pedigree
  ([\#7](https://github.com/itchyshin/hsquared/issues/7)).
- Added a Mrode-style supplied-variance validation fixture that pins
  Ainv, fixed effects, EBVs, fitted values, PEV, reliability, h², ML
  log-likelihood, and dense/sparse REML log-likelihood against R
  reference calculations and the sibling `HSquared.jl` checkout when
  available, without claiming variance-component estimation or full
  fitted Mrode validation
  ([\#7](https://github.com/itchyshin/hsquared/issues/7)).
- Added an internal supplied-variance Henderson mixed-model-equation
  validation fixture that compares R reference fixed effects, EBVs,
  fitted values, and h2 with Julia `henderson_mme()` when a sibling
  `HSquared.jl` checkout is available
  ([\#7](https://github.com/itchyshin/hsquared/issues/7)).
- Added a tiny supplied-variance REML likelihood validation fixture.
  When a sibling `HSquared.jl` checkout is available, optional local
  tests compare Julia dense REML, sparse REML, and ML hand-check targets
  without claiming sparse optimization or fitted Mrode output validation
  ([\#7](https://github.com/itchyshin/hsquared/issues/7)).
- Expanded
  [`hs_control()`](https://itchyshin.github.io/hsquared/reference/hs_control.md)
  to preserve planned backend and accelerator vocabulary for CPU
  threads, CUDA, AMDGPU, Metal, and oneAPI. These are control-surface
  placeholders only; GPU execution remains planned
  ([\#3](https://github.com/itchyshin/hsquared/issues/3)).
- Added
  [`backend_info()`](https://itchyshin.github.io/hsquared/reference/backend_info.md)
  so users and developers can inspect planned backend names while seeing
  that backend execution is not available yet.
- Added
  [`validation_status()`](https://itchyshin.github.io/hsquared/reference/validation_status.md)
  so users and developers can inspect current validation atoms, planned
  comparator lanes, and claim boundaries from R.
- [`data_status()`](https://itchyshin.github.io/hsquared/reference/data_status.md)
  now gives users a direct diagnostic view of
  [`hs_data()`](https://itchyshin.github.io/hsquared/reference/hs_data.md)
  component presence, ID overlap, pedigree coverage, and
  marker-map/genotype-marker alignment status. It is a status helper
  only and does not fit models
  ([\#8](https://github.com/itchyshin/hsquared/issues/8)).
- Added
  [`formula_status()`](https://itchyshin.github.io/hsquared/reference/formula_status.md)
  so users and developers can inspect parsed, reserved, and planned
  formula grammar without reading the full roadmap.
- Added
  [`model_spec()`](https://itchyshin.github.io/hsquared/reference/model_spec.md)
  so users and developers can preview the parsed v0.1 animal-model
  contract, fixed-effect design columns, sparse animal-effect design
  dimensions, normalized pedigree ordering, and Julia targets without
  fitting a model.
- Added inert planned formula markers for
  [`genomic()`](https://itchyshin.github.io/hsquared/reference/genomic_markers.md),
  [`single_step()`](https://itchyshin.github.io/hsquared/reference/genomic_markers.md),
  [`markers()`](https://itchyshin.github.io/hsquared/reference/genomic_markers.md),
  [`marker_scan()`](https://itchyshin.github.io/hsquared/reference/genomic_markers.md),
  and
  [`qtl_scan()`](https://itchyshin.github.io/hsquared/reference/genomic_markers.md).
  The parser now rejects these terms with explicit
  planned-not-implemented errors instead of treating them as fixed
  effects.
- Added inert planned formula markers for
  [`permanent()`](https://itchyshin.github.io/hsquared/reference/qg_effect_markers.md),
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
  [`precision()`](https://itchyshin.github.io/hsquared/reference/qg_effect_markers.md).
  They reserve Phase 2+ vocabulary only and currently abort as planned,
  not implemented.
- Added a pkgdown formula grammar roadmap article that separates parsed
  v0.1 syntax from planned quantitative-genetic, genomic, multivariate,
  and inheritance syntax.
- Expanded the genomics/QTL/GLLVM/accelerator design plan and pkgdown
  roadmap with a source-backed CPU/GPU strategy, QTL/eQTL path,
  sibling-package lessons, and explicit evidence gates.
- Added an internal R-to-Julia bridge payload builder for the v0.1
  animal-model contract. It creates `y`, `X`, sparse `Z`, normalized
  pedigree metadata, and the validated Julia `animal_model_spec()`
  target used by the experimental Julia engine
  ([\#6](https://github.com/itchyshin/hsquared/issues/6)).
- Added a local-only experimental JuliaCall smoke path for the tiny v0.1
  payload when a sibling `HSquared.jl` checkout is available. This
  validates bridge shape against Julia `pedigree_inverse()` and
  `fit_animal_model()` but is not yet the public
  [`hsquared()`](https://itchyshin.github.io/hsquared/reference/hsquared.md)
  fitting path ([\#6](https://github.com/itchyshin/hsquared/issues/6)).
- Added the first `hsquared_fit` object and extractor contract,
  including
  [`variance_components()`](https://itchyshin.github.io/hsquared/reference/variance_components.md),
  [`heritability()`](https://itchyshin.github.io/hsquared/reference/heritability.md),
  [`breeding_values()`](https://itchyshin.github.io/hsquared/reference/breeding_values.md),
  [`fixef()`](https://itchyshin.github.io/hsquared/reference/fixef.md),
  [`ranef()`](https://itchyshin.github.io/hsquared/reference/ranef.md),
  [`logLik()`](https://rdrr.io/r/stats/logLik.html),
  [`AIC()`](https://rdrr.io/r/stats/AIC.html),
  [`predict()`](https://rdrr.io/r/stats/predict.html), and
  [`summary()`](https://rdrr.io/r/base/summary.html) methods over
  internal fit objects. These are contract plumbing only until the Julia
  engine returns real fits
  ([\#5](https://github.com/itchyshin/hsquared/issues/5)).
- Added
  [`hs_data()`](https://itchyshin.github.io/hsquared/reference/hs_data.md)
  as a lightweight R data container for phenotype, pedigree, genotype,
  marker, expression, annotation, and environment inputs. It records ID
  maps for future integrated genomic/QTL/eQTL workflows, but does not
  fit models ([\#8](https://github.com/itchyshin/hsquared/issues/8)).
- [`hs_data()`](https://itchyshin.github.io/hsquared/reference/hs_data.md)
  now accepts `annotation_id` to check expression feature columns
  against annotation rows, and
  [`summary()`](https://rdrr.io/r/base/summary.html)/[`data_status()`](https://itchyshin.github.io/hsquared/reference/data_status.md)
  report annotation-feature diagnostics without fitting eQTL or omics
  models ([\#8](https://github.com/itchyshin/hsquared/issues/8)).
- [`hs_data()`](https://itchyshin.github.io/hsquared/reference/hs_data.md)
  now accepts `environment_id` to check environment/covariate metadata
  coverage against phenotype records, and
  [`summary()`](https://rdrr.io/r/base/summary.html)/[`data_status()`](https://itchyshin.github.io/hsquared/reference/data_status.md)
  report environment-key diagnostics without constructing environmental
  model terms ([\#8](https://github.com/itchyshin/hsquared/issues/8)).
- `summary(hs_data(...))` and
  [`data_status()`](https://itchyshin.github.io/hsquared/reference/data_status.md)
  now report expression row counts, expression ID counts, feature
  counts, unnamed feature columns, duplicate feature IDs, and expression
  component type without fitting eQTL or omics models
  ([\#8](https://github.com/itchyshin/hsquared/issues/8)).
- `summary(hs_data(...))` and
  [`data_status()`](https://itchyshin.github.io/hsquared/reference/data_status.md)
  now report genotype row counts, genotype ID counts, marker-column
  counts, unnamed marker columns, duplicate marker columns, missing
  genotype value counts, and genotype component type without fitting
  genomic, marker-scan, or QTL models
  ([\#8](https://github.com/itchyshin/hsquared/issues/8)).
- `summary(hs_data(...))` now includes pedigree coverage and parent-link
  diagnostics when a pedigree component is supplied
  ([\#8](https://github.com/itchyshin/hsquared/issues/8)).
- `summary(hs_data(...))` now includes an ID overlap table with
  phenotype, pedigree, genotype, expression, and mismatch counts
  ([\#8](https://github.com/itchyshin/hsquared/issues/8)).
- `summary(hs_data(...))` now includes marker-map and genotype-marker
  alignment diagnostics when marker or genotype components are supplied
  ([\#8](https://github.com/itchyshin/hsquared/issues/8)).
- [`hs_data()`](https://itchyshin.github.io/hsquared/reference/hs_data.md)
  now validates supplied marker maps for marker ID, chromosome, and
  non-negative numeric position columns. This is metadata validation
  only; genomic and QTL/eQTL fitting remain planned
  ([\#8](https://github.com/itchyshin/hsquared/issues/8)).
- [`hs_data()`](https://itchyshin.github.io/hsquared/reference/hs_data.md)
  now checks that genotype marker column names match marker-map IDs
  exactly when both `genotypes` and `markers` are supplied
  ([\#8](https://github.com/itchyshin/hsquared/issues/8)).
- [`model_spec()`](https://itchyshin.github.io/hsquared/reference/model_spec.md)
  and
  [`hsquared()`](https://itchyshin.github.io/hsquared/reference/hsquared.md)
  can now use an
  [`hs_data()`](https://itchyshin.github.io/hsquared/reference/hs_data.md)
  object directly for the v0.1 parser, reading model variables from
  `phenotypes` and resolving formula components such as
  `pedigree = pedigree` from the bundle
  ([\#8](https://github.com/itchyshin/hsquared/issues/8)).
- [`model_spec()`](https://itchyshin.github.io/hsquared/reference/model_spec.md)
  and
  [`hsquared()`](https://itchyshin.github.io/hsquared/reference/hsquared.md)
  now allow `animal(1 | id)` to use the pedigree stored in
  `data = hs_data(..., pedigree = ped)`, while ordinary data frames
  still require explicit `pedigree = ped`
  ([\#4](https://github.com/itchyshin/hsquared/issues/4),
  [\#8](https://github.com/itchyshin/hsquared/issues/8)).
- Added Phase 0 project operating documentation, an honest placeholder
  [`hsquared()`](https://itchyshin.github.io/hsquared/reference/hsquared.md)
  entry point, and
  [`hs_control()`](https://itchyshin.github.io/hsquared/reference/hs_control.md)
  for planned engine controls.
