# Changelog

## hsquared 0.0.0.9000

### New features

- [`animal()`](https://itchyshin.github.io/hsquared/reference/animal.md)
  is now exported as an inert formula marker, and
  [`hsquared()`](https://itchyshin.github.io/hsquared/reference/hsquared.md)
  now parses the narrow v0.1 formula contract
  `animal(1 | id, pedigree = ped)` before stopping at the planned Julia
  bridge boundary
  ([\#4](https://github.com/itchyshin/hsquared/issues/4),
  [\#6](https://github.com/itchyshin/hsquared/issues/6)).
- [`hs_control()`](https://itchyshin.github.io/hsquared/reference/hs_control.md)
  now has an experimental `engine = "julia"` option that lets local
  developers run the tiny v0.1 animal-model payload through a sibling
  `HSquared.jl` checkout via JuliaCall. The default engine remains
  validation-only, and general fitted animal-model support is still
  planned ([\#6](https://github.com/itchyshin/hsquared/issues/6)).
- [`prediction_error_variance()`](https://itchyshin.github.io/hsquared/reference/prediction_error_variance.md)
  and
  [`reliability()`](https://itchyshin.github.io/hsquared/reference/reliability.md)
  are now part of the R fitted-object extractor contract. They work for
  `hsquared_fit` objects containing those result fields
  ([\#5](https://github.com/itchyshin/hsquared/issues/5),
  [\#6](https://github.com/itchyshin/hsquared/issues/6)).
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
