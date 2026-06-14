# Package index

## Start here

Current parser entry points and planned fitting controls.

- [`hs_data()`](https://itchyshin.github.io/hsquared/reference/hs_data.md)
  : Create an hsquared data container
- [`data_status()`](https://itchyshin.github.io/hsquared/reference/data_status.md)
  : Inspect hsquared data-container status
- [`hsquared()`](https://itchyshin.github.io/hsquared/reference/hsquared.md)
  : Fit a quantitative-genetic model
- [`hs_control()`](https://itchyshin.github.io/hsquared/reference/hs_control.md)
  : Create hsquared control options
- [`backend_info()`](https://itchyshin.github.io/hsquared/reference/backend_info.md)
  : Inspect planned compute backends
- [`formula_status()`](https://itchyshin.github.io/hsquared/reference/formula_status.md)
  : Inspect formula grammar status
- [`validation_status()`](https://itchyshin.github.io/hsquared/reference/validation_status.md)
  : Inspect validation evidence status
- [`model_spec()`](https://itchyshin.github.io/hsquared/reference/model_spec.md)
  : Inspect a parsed hsquared model specification
- [`animal()`](https://itchyshin.github.io/hsquared/reference/animal.md)
  : Animal-model formula marker
- [`genomic()`](https://itchyshin.github.io/hsquared/reference/genomic_markers.md)
  [`single_step()`](https://itchyshin.github.io/hsquared/reference/genomic_markers.md)
  [`markers()`](https://itchyshin.github.io/hsquared/reference/genomic_markers.md)
  [`marker_scan()`](https://itchyshin.github.io/hsquared/reference/genomic_markers.md)
  [`qtl_scan()`](https://itchyshin.github.io/hsquared/reference/genomic_markers.md)
  : Planned genomic and QTL formula markers
- [`permanent()`](https://itchyshin.github.io/hsquared/reference/qg_effect_markers.md)
  [`common_env()`](https://itchyshin.github.io/hsquared/reference/qg_effect_markers.md)
  [`maternal_genetic()`](https://itchyshin.github.io/hsquared/reference/qg_effect_markers.md)
  [`maternal_env()`](https://itchyshin.github.io/hsquared/reference/qg_effect_markers.md)
  [`paternal_genetic()`](https://itchyshin.github.io/hsquared/reference/qg_effect_markers.md)
  [`paternal_env()`](https://itchyshin.github.io/hsquared/reference/qg_effect_markers.md)
  [`cytoplasmic()`](https://itchyshin.github.io/hsquared/reference/qg_effect_markers.md)
  [`imprinting()`](https://itchyshin.github.io/hsquared/reference/qg_effect_markers.md)
  [`dominance()`](https://itchyshin.github.io/hsquared/reference/qg_effect_markers.md)
  [`epistasis()`](https://itchyshin.github.io/hsquared/reference/qg_effect_markers.md)
  [`relmat()`](https://itchyshin.github.io/hsquared/reference/qg_effect_markers.md)
  [`precision()`](https://itchyshin.github.io/hsquared/reference/qg_effect_markers.md)
  : Planned quantitative-genetic formula markers

## Extractor contract

Extractors for fitted `hsquared_fit` objects. The default
[`hsquared()`](https://itchyshin.github.io/hsquared/reference/hsquared.md)
call fits the v0.1 Gaussian animal model;
[`repeatability()`](https://itchyshin.github.io/hsquared/reference/repeatability.md)/[`permanent_effects()`](https://itchyshin.github.io/hsquared/reference/permanent_effects.md)
and
[`common_env_effects()`](https://itchyshin.github.io/hsquared/reference/common_env_effects.md)
come from the opt-in, experimental two-effect models.

- [`variance_components()`](https://itchyshin.github.io/hsquared/reference/variance_components.md)
  : Extract variance components
- [`heritability()`](https://itchyshin.github.io/hsquared/reference/heritability.md)
  : Extract heritability estimates
- [`breeding_values()`](https://itchyshin.github.io/hsquared/reference/breeding_values.md)
  [`EBV()`](https://itchyshin.github.io/hsquared/reference/breeding_values.md)
  [`BLUP()`](https://itchyshin.github.io/hsquared/reference/breeding_values.md)
  : Extract breeding values
- [`repeatability()`](https://itchyshin.github.io/hsquared/reference/repeatability.md)
  : Extract repeatability estimates
- [`permanent_effects()`](https://itchyshin.github.io/hsquared/reference/permanent_effects.md)
  : Extract permanent-environment effects
- [`common_env_effects()`](https://itchyshin.github.io/hsquared/reference/common_env_effects.md)
  : Extract common-environment effects
- [`maternal_effects()`](https://itchyshin.github.io/hsquared/reference/maternal_effects.md)
  : Extract maternal genetic effects
- [`prediction_error_variance()`](https://itchyshin.github.io/hsquared/reference/prediction_error_variance.md)
  : Extract prediction error variances
- [`reliability()`](https://itchyshin.github.io/hsquared/reference/reliability.md)
  [`accuracy()`](https://itchyshin.github.io/hsquared/reference/reliability.md)
  : Extract reliability and accuracy estimates
- [`fit_diagnostics()`](https://itchyshin.github.io/hsquared/reference/fit_diagnostics.md)
  : Inspect fitted-model diagnostics
- [`marker_effects()`](https://itchyshin.github.io/hsquared/reference/marker_extractors.md)
  [`marker_variance_explained()`](https://itchyshin.github.io/hsquared/reference/marker_extractors.md)
  [`qtl_table()`](https://itchyshin.github.io/hsquared/reference/marker_extractors.md)
  [`gwas_table()`](https://itchyshin.github.io/hsquared/reference/marker_extractors.md)
  [`eqtl_table()`](https://itchyshin.github.io/hsquared/reference/marker_extractors.md)
  [`lod_scores()`](https://itchyshin.github.io/hsquared/reference/marker_extractors.md)
  : Extract planned marker, QTL, GWAS, and eQTL results
- [`fixef()`](https://itchyshin.github.io/hsquared/reference/fixef.md) :
  Extract fixed effects
- [`ranef()`](https://itchyshin.github.io/hsquared/reference/ranef.md) :
  Extract random effects

## Package

- [`hsquared-package`](https://itchyshin.github.io/hsquared/reference/hsquared-package.md)
  : hsquared: R Interface for Julia-Backed Quantitative-Genetic Models
