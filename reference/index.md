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
  : Genomic and QTL formula markers
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
  [`group()`](https://itchyshin.github.io/hsquared/reference/qg_effect_markers.md)
  [`unknown_parent_group()`](https://itchyshin.github.io/hsquared/reference/qg_effect_markers.md)
  [`metafounder()`](https://itchyshin.github.io/hsquared/reference/qg_effect_markers.md)
  [`inbreeding()`](https://itchyshin.github.io/hsquared/reference/qg_effect_markers.md)
  : Quantitative-genetic formula markers

## Extractor contract

Extractors for fitted `hsquared_fit` objects. The default
[`hsquared()`](https://itchyshin.github.io/hsquared/reference/hsquared.md)
call fits the v0.1 Gaussian animal model; repeatability, two-effect,
genomic, SNP-BLUP, multivariate, and random-regression outputs come from
opt-in experimental targets.

- [`variance_components()`](https://itchyshin.github.io/hsquared/reference/variance_components.md)
  : Extract variance components
- [`heritability()`](https://itchyshin.github.io/hsquared/reference/heritability.md)
  : Extract heritability estimates
- [`heritability_interval()`](https://itchyshin.github.io/hsquared/reference/heritability_interval.md)
  : Extract an experimental heritability confidence interval
- [`variance_component_standard_errors()`](https://itchyshin.github.io/hsquared/reference/variance_component_standard_errors.md)
  [`heritability_standard_error()`](https://itchyshin.github.io/hsquared/reference/variance_component_standard_errors.md)
  : Extract experimental variance-component and heritability standard
  errors
- [`genetic_covariance()`](https://itchyshin.github.io/hsquared/reference/multivariate_extractors.md)
  [`G_matrix()`](https://itchyshin.github.io/hsquared/reference/multivariate_extractors.md)
  [`residual_covariance()`](https://itchyshin.github.io/hsquared/reference/multivariate_extractors.md)
  [`R_matrix()`](https://itchyshin.github.io/hsquared/reference/multivariate_extractors.md)
  [`genetic_correlation()`](https://itchyshin.github.io/hsquared/reference/multivariate_extractors.md)
  [`residual_correlation()`](https://itchyshin.github.io/hsquared/reference/multivariate_extractors.md)
  : Extract multivariate covariance and correlation matrices
- [`covariance_standard_errors()`](https://itchyshin.github.io/hsquared/reference/covariance_standard_errors.md)
  : Extract experimental multivariate covariance standard errors
- [`covariance_structure_lrt()`](https://itchyshin.github.io/hsquared/reference/covariance_structure_lrt.md)
  : Likelihood-ratio test for genetic covariance structure
- [`gamma_matrix()`](https://itchyshin.github.io/hsquared/reference/gamma_matrix.md)
  : Extract a supplied metafounder Gamma matrix
- [`metafounder_groups()`](https://itchyshin.github.io/hsquared/reference/metafounder_groups.md)
  : Extract supplied metafounder group assignments
- [`metafounder_effects()`](https://itchyshin.github.io/hsquared/reference/metafounder_effects.md)
  : Reserved metafounder effect extractor
- [`genetic_loadings()`](https://itchyshin.github.io/hsquared/reference/factor_g_extractors.md)
  [`specific_variance()`](https://itchyshin.github.io/hsquared/reference/factor_g_extractors.md)
  [`latent_breeding_values()`](https://itchyshin.github.io/hsquared/reference/factor_g_extractors.md)
  : Reserved factor-analytic and G-matrix extractors
- [`evolvability()`](https://itchyshin.github.io/hsquared/reference/g_matrix_geometry.md)
  [`respondability()`](https://itchyshin.github.io/hsquared/reference/g_matrix_geometry.md)
  [`conditional_evolvability()`](https://itchyshin.github.io/hsquared/reference/g_matrix_geometry.md)
  [`autonomy()`](https://itchyshin.github.io/hsquared/reference/g_matrix_geometry.md)
  [`mean_evolvability()`](https://itchyshin.github.io/hsquared/reference/g_matrix_geometry.md)
  [`g_max()`](https://itchyshin.github.io/hsquared/reference/g_matrix_geometry.md)
  [`variance_along_gradient()`](https://itchyshin.github.io/hsquared/reference/g_matrix_geometry.md)
  [`eigen_G()`](https://itchyshin.github.io/hsquared/reference/g_matrix_geometry.md)
  : G-matrix geometry and evolvability
- [`breeding_values()`](https://itchyshin.github.io/hsquared/reference/breeding_values.md)
  [`EBV()`](https://itchyshin.github.io/hsquared/reference/breeding_values.md)
  [`BLUP()`](https://itchyshin.github.io/hsquared/reference/breeding_values.md)
  : Extract breeding values
- [`repeatability()`](https://itchyshin.github.io/hsquared/reference/repeatability.md)
  : Extract repeatability estimates
- [`repeatability_interval()`](https://itchyshin.github.io/hsquared/reference/repeatability_interval.md)
  : Extract an experimental repeatability confidence interval
- [`permanent_effects()`](https://itchyshin.github.io/hsquared/reference/permanent_effects.md)
  : Extract permanent-environment effects
- [`common_env_effects()`](https://itchyshin.github.io/hsquared/reference/common_env_effects.md)
  : Extract common-environment effects
- [`maternal_effects()`](https://itchyshin.github.io/hsquared/reference/maternal_effects.md)
  : Extract maternal genetic effects
- [`common_env_proportion()`](https://itchyshin.github.io/hsquared/reference/common_env_proportion.md)
  : Extract the common-environment variance ratio (c2)
- [`maternal_proportion()`](https://itchyshin.github.io/hsquared/reference/maternal_proportion.md)
  : Extract the maternal variance ratio (m2)
- [`common_env_proportion_interval()`](https://itchyshin.github.io/hsquared/reference/common_env_proportion_interval.md)
  [`maternal_proportion_interval()`](https://itchyshin.github.io/hsquared/reference/common_env_proportion_interval.md)
  : Extract an experimental common-environment / maternal variance-ratio
  interval
- [`rr_covariance()`](https://itchyshin.github.io/hsquared/reference/random_regression_extractors.md)
  [`random_coefficients()`](https://itchyshin.github.io/hsquared/reference/random_regression_extractors.md)
  [`rr_genetic_variance()`](https://itchyshin.github.io/hsquared/reference/random_regression_extractors.md)
  [`rr_heritability()`](https://itchyshin.github.io/hsquared/reference/random_regression_extractors.md)
  [`rr_correlation()`](https://itchyshin.github.io/hsquared/reference/random_regression_extractors.md)
  [`rr_eigenfunctions()`](https://itchyshin.github.io/hsquared/reference/random_regression_extractors.md)
  : Random-regression (reaction-norm) extractors
- [`prediction_error_variance()`](https://itchyshin.github.io/hsquared/reference/prediction_error_variance.md)
  : Extract prediction error variances
- [`reliability()`](https://itchyshin.github.io/hsquared/reference/reliability.md)
  [`accuracy()`](https://itchyshin.github.io/hsquared/reference/reliability.md)
  : Extract reliability and accuracy estimates
- [`fit_diagnostics()`](https://itchyshin.github.io/hsquared/reference/fit_diagnostics.md)
  : Inspect fitted-model diagnostics
- [`plot(`*`<hsquared_fit>`*`)`](https://itchyshin.github.io/hsquared/reference/plot.hsquared_fit.md)
  : Diagnostic plots for a fitted animal model
- [`confint(`*`<hsquared_fit>`*`)`](https://itchyshin.github.io/hsquared/reference/inference_blocks.md)
  [`vcov(`*`<hsquared_fit>`*`)`](https://itchyshin.github.io/hsquared/reference/inference_blocks.md)
  [`profile(`*`<hsquared_fit>`*`)`](https://itchyshin.github.io/hsquared/reference/inference_blocks.md)
  [`anova(`*`<hsquared_fit>`*`)`](https://itchyshin.github.io/hsquared/reference/inference_blocks.md)
  : Block unsupported likelihood-inference helpers
- [`marker_effects()`](https://itchyshin.github.io/hsquared/reference/marker_extractors.md)
  [`marker_variance_explained()`](https://itchyshin.github.io/hsquared/reference/marker_extractors.md)
  [`qtl_table()`](https://itchyshin.github.io/hsquared/reference/marker_extractors.md)
  [`gwas_table()`](https://itchyshin.github.io/hsquared/reference/marker_extractors.md)
  [`eqtl_table()`](https://itchyshin.github.io/hsquared/reference/marker_extractors.md)
  [`lod_scores()`](https://itchyshin.github.io/hsquared/reference/marker_extractors.md)
  : Extract planned marker, QTL, GWAS, and eQTL results
- [`gwas()`](https://itchyshin.github.io/hsquared/reference/gwas.md) :
  Post-fit relatedness-corrected marker scan (GWAS)
- [`fixef()`](https://itchyshin.github.io/hsquared/reference/fixef.md) :
  Extract fixed effects
- [`ranef()`](https://itchyshin.github.io/hsquared/reference/ranef.md) :
  Extract random effects
- [`predict(`*`<hsquared_fit>`*`)`](https://itchyshin.github.io/hsquared/reference/response_scale_methods.md)
  [`fitted(`*`<hsquared_fit>`*`)`](https://itchyshin.github.io/hsquared/reference/response_scale_methods.md)
  [`residuals(`*`<hsquared_fit>`*`)`](https://itchyshin.github.io/hsquared/reference/response_scale_methods.md)
  : Response-scale prediction helpers

## Visualization

- [`autoplot(`*`<hsquared_fit>`*`)`](https://itchyshin.github.io/hsquared/reference/hsquared-autoplot.md)
  [`autoplot(`*`<hs_gwas>`*`)`](https://itchyshin.github.io/hsquared/reference/hsquared-autoplot.md)
  : ggplot2 visualizations for hsquared results
- [`theme_hsquared()`](https://itchyshin.github.io/hsquared/reference/theme_hsquared.md)
  : hsquared ggplot2 theme
- [`hs_recovery_forest()`](https://itchyshin.github.io/hsquared/reference/hs_recovery_forest.md)
  : Forest plot of a known-truth recovery study

## Package

- [`hsquared-package`](https://itchyshin.github.io/hsquared/reference/hsquared-package.md)
  : hsquared: R Interface for Julia-Backed Quantitative-Genetic Models
