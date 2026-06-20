#' Extract variance components
#'
#' `variance_components()` is part of the planned v0.1 fitted-object contract.
#' It works for `hsquared_fit` objects that contain a Julia result.
#'
#' @param object A fitted model object.
#' @param ... Reserved for future arguments.
#'
#' @return Variance component results for `hsquared_fit` objects.
#' @export
variance_components <- function(object, ...) {
  UseMethod("variance_components")
}

#' @export
variance_components.default <- function(object, ...) {
  stop(
    "`variance_components()` requires an `hsquared_fit` object. The current ",
    "package only returns these from fitted `hsquared_fit` results.",
    call. = FALSE
  )
}

#' @export
variance_components.hsquared_fit <- function(object, ...) {
  hs_fit_result(object, "variance_components", "variance components")
}

#' Extract heritability estimates
#'
#' `heritability()` is part of the planned v0.1 fitted-object contract. It
#' works for `hsquared_fit` objects that contain a Julia result.
#'
#' @inheritParams variance_components
#'
#' @return Heritability results for `hsquared_fit` objects.
#' @export
heritability <- function(object, ...) {
  UseMethod("heritability")
}

#' @export
heritability.default <- function(object, ...) {
  stop(
    "`heritability()` requires an `hsquared_fit` object. The current package ",
    "only returns these from fitted `hsquared_fit` results.",
    call. = FALSE
  )
}

#' @export
heritability.hsquared_fit <- function(object, ...) {
  hs_fit_result(object, "heritability", "heritability estimates")
}

#' Extract multivariate covariance and correlation matrices
#'
#' These extractors return the genetic (`G`) and residual (`R`) covariance or
#' correlation matrices from opt-in multivariate `hsquared_fit` objects
#' (`target = "multivariate"`). `G_matrix()` is an applied-workflow alias for
#' `genetic_covariance()`, and `R_matrix()` is an alias for
#' `residual_covariance()`. Use them after checking [fit_diagnostics()] because
#' likelihood-based summaries are intentionally blocked when a multivariate fit
#' has not converged.
#'
#' @inheritParams variance_components
#'
#' @return A numeric matrix for `hsquared_fit` objects that contain the
#'   requested multivariate result field.
#'
#' @examplesIf FALSE
#' fit_mv <- hsquared(
#'   cbind(weight, length) ~ sex + age + animal(1 | id, pedigree = ped),
#'   data = dat,
#'   family = gaussian(),
#'   REML = TRUE,
#'   control = hs_control(
#'     engine = "julia",
#'     engine_control = list(target = "multivariate")
#'   )
#' )
#'
#' fit_diagnostics(fit_mv)
#'
#' genetic_covariance(fit_mv)
#' G_matrix(fit_mv)
#' residual_covariance(fit_mv)
#' R_matrix(fit_mv)
#' genetic_correlation(fit_mv)
#' residual_correlation(fit_mv)
#' heritability(fit_mv)
#' @name multivariate_extractors
NULL

#' @rdname multivariate_extractors
#' @export
genetic_covariance <- function(object, ...) {
  UseMethod("genetic_covariance")
}

#' @export
genetic_covariance.default <- function(object, ...) {
  hs_multivariate_extractor_default("genetic_covariance")
}

#' @export
genetic_covariance.hsquared_fit <- function(object, ...) {
  hs_fit_result(object, "genetic_covariance", "genetic covariance matrix")
}

#' @rdname multivariate_extractors
#' @export
G_matrix <- function(object, ...) {
  UseMethod("G_matrix")
}

#' @export
G_matrix.default <- function(object, ...) {
  hs_multivariate_extractor_default("G_matrix")
}

#' @export
G_matrix.hsquared_fit <- function(object, ...) {
  genetic_covariance(object, ...)
}

#' @rdname multivariate_extractors
#' @export
residual_covariance <- function(object, ...) {
  UseMethod("residual_covariance")
}

#' @export
residual_covariance.default <- function(object, ...) {
  hs_multivariate_extractor_default("residual_covariance")
}

#' @export
residual_covariance.hsquared_fit <- function(object, ...) {
  hs_fit_result(object, "residual_covariance", "residual covariance matrix")
}

#' @rdname multivariate_extractors
#' @export
R_matrix <- function(object, ...) {
  UseMethod("R_matrix")
}

#' @export
R_matrix.default <- function(object, ...) {
  hs_multivariate_extractor_default("R_matrix")
}

#' @export
R_matrix.hsquared_fit <- function(object, ...) {
  residual_covariance(object, ...)
}

#' @rdname multivariate_extractors
#' @export
genetic_correlation <- function(object, ...) {
  UseMethod("genetic_correlation")
}

#' @export
genetic_correlation.default <- function(object, ...) {
  hs_multivariate_extractor_default("genetic_correlation")
}

#' @export
genetic_correlation.hsquared_fit <- function(object, ...) {
  hs_fit_result(object, "genetic_correlation", "genetic correlation matrix")
}

#' @rdname multivariate_extractors
#' @export
residual_correlation <- function(object, ...) {
  UseMethod("residual_correlation")
}

#' @export
residual_correlation.default <- function(object, ...) {
  hs_multivariate_extractor_default("residual_correlation")
}

#' @export
residual_correlation.hsquared_fit <- function(object, ...) {
  hs_fit_result(object, "residual_correlation", "residual correlation matrix")
}

hs_multivariate_extractor_default <- function(name) {
  stop(
    "`",
    name,
    "()` requires an `hsquared_fit` object from the opt-in multivariate model ",
    "(`target = \"multivariate\"`).",
    call. = FALSE
  )
}

#' Reserved factor-analytic and G-matrix extractors
#'
#' These extractor names are reserved for future factor-analytic G-matrix
#' results. The current package can report invariant covariance and correlation
#' matrices from opt-in multivariate fits, but it does not yet expose
#' interpreted loadings, uniqueness/specific variance, or latent breeding
#' values. Loading columns are rotation-nonunique until a rotation or
#' constraint policy is validated. Future `hsquared_fit` methods reserve
#' `effect` and rotation controls, but these controls currently error rather
#' than implying that loading axes are interpretable. The **rotation-invariant**
#' genetic eigenstructure and evolvability geometry are available now via
#' [eigen_G()] and the [g_matrix_geometry] family.
#'
#' @inheritParams variance_components
#'
#' @return These reserved extractors currently error for `hsquared_fit` objects.
#' @name factor_g_extractors
NULL

#' @rdname factor_g_extractors
#' @export
genetic_loadings <- function(object, ...) {
  UseMethod("genetic_loadings")
}

#' @export
genetic_loadings.default <- function(object, ...) {
  hs_factor_g_extractor_default("genetic_loadings")
}

#' @export
genetic_loadings.hsquared_fit <- function(
  object,
  effect = "animal",
  rotate = NULL,
  ...
) {
  hs_factor_g_extractor_planned(
    "genetic_loadings",
    "factor-analytic G-matrix loadings",
    effect = effect,
    rotate = rotate
  )
}

#' @rdname factor_g_extractors
#' @export
specific_variance <- function(object, ...) {
  UseMethod("specific_variance")
}

#' @export
specific_variance.default <- function(object, ...) {
  hs_factor_g_extractor_default("specific_variance")
}

#' @export
specific_variance.hsquared_fit <- function(object, effect = "animal", ...) {
  hs_factor_g_extractor_planned(
    "specific_variance",
    "factor-analytic G-matrix uniqueness / specific variance",
    effect = effect
  )
}

#' @rdname factor_g_extractors
#' @export
latent_breeding_values <- function(object, ...) {
  UseMethod("latent_breeding_values")
}

#' @export
latent_breeding_values.default <- function(object, ...) {
  hs_factor_g_extractor_default("latent_breeding_values")
}

#' @export
latent_breeding_values.hsquared_fit <- function(
  object,
  effect = "animal",
  ...
) {
  hs_factor_g_extractor_planned(
    "latent_breeding_values",
    "latent breeding values from a factor-analytic G matrix",
    effect = effect
  )
}

#' @rdname g_matrix_geometry
#' @export
eigen_G <- function(object, ...) {
  UseMethod("eigen_G")
}

#' @export
eigen_G.default <- function(object, ...) {
  stop("`eigen_G()` requires an `hsquared_fit` object.", call. = FALSE)
}

#' @export
eigen_G.hsquared_fit <- function(object, ...) {
  hs_g_eigen(hs_fit_genetic_G(object))
}

hs_factor_g_extractor_default <- function(name) {
  stop(
    "`",
    name,
    "()` requires an `hsquared_fit` object from a future validated ",
    "factor-analytic or G-matrix result. The current package reserves this ",
    "extractor name but does not expose interpreted factor-analytic G-matrix ",
    "outputs yet.",
    call. = FALSE
  )
}

hs_factor_g_extractor_planned <- function(
  name,
  quantity,
  effect,
  rotate = NULL
) {
  if (!identical(effect, "animal")) {
    stop(
      "`",
      name,
      "()` currently reserves only `effect = \"animal\"`; other effects are ",
      "planned, not implemented.",
      call. = FALSE
    )
  }
  if (!is.null(rotate)) {
    stop(
      "`",
      name,
      "()` rotation controls are planned, not implemented. Loading axes need ",
      "a validated rotation or constraint policy before interpretation.",
      call. = FALSE
    )
  }
  stop(
    "`",
    name,
    "()` for ",
    quantity,
    " is planned, not implemented for `hsquared_fit` objects. Current ",
    "multivariate fits report invariant `genetic_covariance()` and ",
    "`genetic_correlation()`; loading axes remain rotation-nonunique until ",
    "validated.",
    call. = FALSE
  )
}

#' Extract repeatability estimates
#'
#' `repeatability()` reports the repeatability `R = (Va + Vpe) / Vp` of the
#' opt-in, experimental repeatability (permanent-environment) model. It works
#' for `hsquared_fit` objects fitted with
#' `engine_control = list(target = "repeatability")`.
#'
#' @inheritParams variance_components
#'
#' @return Repeatability results for repeatability `hsquared_fit` objects.
#' @export
repeatability <- function(object, ...) {
  UseMethod("repeatability")
}

#' @export
repeatability.default <- function(object, ...) {
  stop(
    "`repeatability()` requires an `hsquared_fit` object from the opt-in ",
    "repeatability model (`target = \"repeatability\"`).",
    call. = FALSE
  )
}

#' @export
repeatability.hsquared_fit <- function(object, ...) {
  hs_fit_result(object, "repeatability", "repeatability estimates")
}

#' Extract permanent-environment effects
#'
#' `permanent_effects()` returns the predicted permanent-environment effects of
#' the opt-in, experimental repeatability model.
#'
#' @inheritParams variance_components
#'
#' @return Permanent-environment effect results for repeatability
#'   `hsquared_fit` objects.
#' @export
permanent_effects <- function(object, ...) {
  UseMethod("permanent_effects")
}

#' @export
permanent_effects.default <- function(object, ...) {
  stop(
    "`permanent_effects()` requires an `hsquared_fit` object from the opt-in ",
    "repeatability model (`target = \"repeatability\"`).",
    call. = FALSE
  )
}

#' @export
permanent_effects.hsquared_fit <- function(object, ...) {
  hs_fit_result(object, "permanent_effects", "permanent-environment effects")
}

#' Extract common-environment effects
#'
#' `common_env_effects()` returns the predicted common-environment effects of
#' the opt-in, experimental two-effect model (`target = "two_effect"`).
#'
#' @inheritParams variance_components
#'
#' @return Common-environment effect results for two-effect `hsquared_fit`
#'   objects.
#' @export
common_env_effects <- function(object, ...) {
  UseMethod("common_env_effects")
}

#' @export
common_env_effects.default <- function(object, ...) {
  stop(
    "`common_env_effects()` requires an `hsquared_fit` object from the opt-in ",
    "two-effect (common-environment) model (`target = \"two_effect\"`).",
    call. = FALSE
  )
}

#' @export
common_env_effects.hsquared_fit <- function(object, ...) {
  hs_fit_result(object, "common_env_effects", "common-environment effects")
}

#' Extract maternal genetic effects
#'
#' `maternal_effects()` returns the predicted maternal genetic effects of the
#' opt-in, experimental maternal two-effect model
#' (`target = "two_effect"` with a `maternal_genetic()` term).
#'
#' @inheritParams variance_components
#'
#' @return Maternal genetic effect results for maternal `hsquared_fit` objects.
#' @export
maternal_effects <- function(object, ...) {
  UseMethod("maternal_effects")
}

#' @export
maternal_effects.default <- function(object, ...) {
  stop(
    "`maternal_effects()` requires an `hsquared_fit` object from the opt-in ",
    "maternal two-effect model (`target = \"two_effect\"` with a ",
    "`maternal_genetic()` term).",
    call. = FALSE
  )
}

#' @export
maternal_effects.hsquared_fit <- function(object, ...) {
  hs_fit_result(object, "maternal_effects", "maternal genetic effects")
}

#' Extract breeding values
#'
#' `breeding_values()` is part of the planned v0.1 fitted-object contract. It
#' works for `hsquared_fit` objects that contain a Julia result. `EBV()` and
#' `BLUP()` are aliases for applied quantitative-genetic workflows.
#'
#' @inheritParams variance_components
#'
#' @return Breeding value results for `hsquared_fit` objects.
#' @export
breeding_values <- function(object, ...) {
  UseMethod("breeding_values")
}

#' @export
breeding_values.default <- function(object, ...) {
  hs_breeding_values_default("breeding_values")
}

#' @export
breeding_values.hsquared_fit <- function(object, ...) {
  hs_fit_result(object, "breeding_values", "breeding values")
}

#' @rdname breeding_values
#' @export
EBV <- function(object, ...) {
  UseMethod("EBV")
}

#' @export
EBV.default <- function(object, ...) {
  hs_breeding_values_default("EBV")
}

#' @export
EBV.hsquared_fit <- function(object, ...) {
  breeding_values(object, ...)
}

#' @rdname breeding_values
#' @export
BLUP <- function(object, ...) {
  UseMethod("BLUP")
}

#' @export
BLUP.default <- function(object, ...) {
  hs_breeding_values_default("BLUP")
}

#' @export
BLUP.hsquared_fit <- function(object, ...) {
  breeding_values(object, ...)
}

hs_breeding_values_default <- function(name) {
  stop(
    "`",
    name,
    "()` requires an `hsquared_fit` object. The current package only returns ",
    "these from fitted `hsquared_fit` results.",
    call. = FALSE
  )
}

#' Extract prediction error variances
#'
#' `prediction_error_variance()` is part of the planned v0.1 fitted-object
#' contract. It returns values only when an `hsquared_fit` object contains a
#' Julia result field for prediction error variances.
#'
#' @inheritParams variance_components
#'
#' @return Prediction error variances for `hsquared_fit` objects.
#' @export
prediction_error_variance <- function(object, ...) {
  UseMethod("prediction_error_variance")
}

#' @export
prediction_error_variance.default <- function(object, ...) {
  stop(
    "`prediction_error_variance()` requires an `hsquared_fit` object. The ",
    "current package only returns these from fitted `hsquared_fit` results.",
    call. = FALSE
  )
}

#' @export
prediction_error_variance.hsquared_fit <- function(object, ...) {
  hs_fit_result(
    object,
    "prediction_error_variance",
    "prediction error variances"
  )
}

#' Extract reliability and accuracy estimates
#'
#' `reliability()` is part of the planned v0.1 fitted-object contract. It
#' returns values only when an `hsquared_fit` object contains a Julia result
#' field for reliability estimates. `accuracy()` returns the square root of
#' reliability for `hsquared_fit` objects.
#'
#' @inheritParams variance_components
#'
#' @return Reliability estimates for `hsquared_fit` objects.
#' @export
reliability <- function(object, ...) {
  UseMethod("reliability")
}

#' @export
reliability.default <- function(object, ...) {
  stop(
    "`reliability()` requires an `hsquared_fit` object. The current package ",
    "only returns these from fitted `hsquared_fit` results.",
    call. = FALSE
  )
}

#' @export
reliability.hsquared_fit <- function(object, ...) {
  hs_fit_result(object, "reliability", "reliability estimates")
}

#' @rdname reliability
#' @export
accuracy <- function(object, ...) {
  UseMethod("accuracy")
}

#' @export
accuracy.default <- function(object, ...) {
  stop(
    "`accuracy()` requires an `hsquared_fit` object with reliability ",
    "estimates.",
    call. = FALSE
  )
}

#' @export
accuracy.hsquared_fit <- function(object, ...) {
  rel <- reliability(object, ...)
  if (!is.data.frame(rel) || !"value" %in% names(rel)) {
    stop(
      "Reliability results must be a data frame with a `value` column to ",
      "compute accuracy.",
      call. = FALSE
    )
  }
  if (any(is.na(rel$value)) || any(rel$value < 0) || any(rel$value > 1)) {
    stop(
      "Reliability values must be between 0 and 1 to compute accuracy.",
      call. = FALSE
    )
  }
  out <- rel
  out$value <- sqrt(out$value)
  out
}

#' Extract an experimental heritability confidence interval
#'
#' `heritability_interval()` returns an **experimental** large-sample confidence
#' interval for `h^2`. It is available only when an `hsquared_fit` object
#' contains the interval field, which the default Gaussian animal-model fit
#' (`engine = "fit"`) populates from the engine's
#' `HSquared.heritability_interval()` when a local Julia engine is present and
#' the estimate is interior to `(0, 1)`.
#'
#' This mirrors the engine row `V1-HERIT-CI`, which is `partial`: the interval is
#' a REML-only, asymptotic (logit delta-method) approximation, not a
#' coverage-calibrated interval, and is unreliable at small `n`. It is reported
#' as a point estimate plus bounds, not a validated capability.
#'
#' @inheritParams variance_components
#'
#' @return A one-row data frame with `estimate`, `lower`, `upper`, `level`, `se`
#'   (`NA` for the profile method), and `method`, for `hsquared_fit` objects that
#'   contain it.
#' @export
heritability_interval <- function(object, ...) {
  UseMethod("heritability_interval")
}

#' @export
heritability_interval.default <- function(object, ...) {
  stop(
    "`heritability_interval()` requires an `hsquared_fit` object. The current ",
    "package only returns these from fitted `hsquared_fit` results.",
    call. = FALSE
  )
}

#' @export
heritability_interval.hsquared_fit <- function(object, ...) {
  hs_fit_result(
    object,
    "heritability_interval",
    "an experimental heritability confidence interval"
  )
}

#' Extract experimental variance-component and heritability standard errors
#'
#' `variance_component_standard_errors()` and `heritability_standard_error()`
#' return **experimental** large-sample (delta-method) standard errors derived
#' from the REML average-information matrix. They are available only when an
#' `hsquared_fit` object contains them; the default Gaussian animal-model fit
#' populates them from the engine when a local Julia engine is present and the
#' AI matrix is invertible.
#'
#' These mirror the engine row `V1-HERIT-CI` (`partial`): asymptotic, REML-only,
#' and unreliable at small `n` or near a variance-component boundary (where the
#' AI matrix is ill-conditioned and the fields are omitted). They are not
#' coverage-calibrated and not a validated capability.
#'
#' @inheritParams variance_components
#'
#' @return `variance_component_standard_errors()` returns a data frame with
#'   `component` and `se`; `heritability_standard_error()` returns a single
#'   numeric. Only for `hsquared_fit` objects that contain them.
#' @export
variance_component_standard_errors <- function(object, ...) {
  UseMethod("variance_component_standard_errors")
}

#' @export
variance_component_standard_errors.default <- function(object, ...) {
  stop(
    "`variance_component_standard_errors()` requires an `hsquared_fit` object. ",
    "The current package only returns these from fitted `hsquared_fit` results.",
    call. = FALSE
  )
}

#' @export
variance_component_standard_errors.hsquared_fit <- function(object, ...) {
  hs_fit_result(
    object,
    "variance_component_se",
    "experimental variance-component standard errors"
  )
}

#' @rdname variance_component_standard_errors
#' @export
heritability_standard_error <- function(object, ...) {
  UseMethod("heritability_standard_error")
}

#' @export
heritability_standard_error.default <- function(object, ...) {
  stop(
    "`heritability_standard_error()` requires an `hsquared_fit` object. The ",
    "current package only returns these from fitted `hsquared_fit` results.",
    call. = FALSE
  )
}

#' @export
heritability_standard_error.hsquared_fit <- function(object, ...) {
  hs_fit_result(
    object,
    "heritability_se",
    "an experimental heritability standard error"
  )
}

#' Extract an experimental repeatability confidence interval
#'
#' `repeatability_interval()` returns an **experimental** large-sample (logit
#' delta-method) confidence interval for the repeatability coefficient
#' `t = (Va + Vpe) / Vp` of the opt-in repeatability (permanent-environment)
#' model, available only when the fit contains it.
#'
#' It mirrors the engine row `V3-REPEAT-REML` (`partial`): the engine's
#' repeatability REML estimator and this interval are engine-internal
#' self-consistency tested (recovery of `t` and interval bracketing / range /
#' level-nesting / point-estimate match on seeded fixtures), but there is no
#' external comparator, no `h²` interval, and no deep-pedigree validation. It is
#' asymptotic, REML-only, unreliable at small `n` or near the (0, 1) boundary
#' (where the engine throws and the field is omitted), and not a validated
#' capability.
#'
#' @inheritParams variance_components
#'
#' @return A one-row data frame with `estimate` (the repeatability `t`), `lower`,
#'   `upper`, `level`, and `se`, for `hsquared_fit` objects that contain it.
#' @export
repeatability_interval <- function(object, ...) {
  UseMethod("repeatability_interval")
}

#' @export
repeatability_interval.default <- function(object, ...) {
  stop(
    "`repeatability_interval()` requires an `hsquared_fit` object from the ",
    "opt-in repeatability model. The current package only returns these from ",
    "fitted `hsquared_fit` results.",
    call. = FALSE
  )
}

#' @export
repeatability_interval.hsquared_fit <- function(object, ...) {
  hs_fit_result(
    object,
    "repeatability_interval",
    "an experimental repeatability confidence interval"
  )
}

#' Extract experimental multivariate covariance standard errors
#'
#' `covariance_standard_errors()` returns **experimental** large-sample
#' (delta-method) standard errors for the multivariate genetic/residual
#' covariance and correlation matrices and per-trait `h²`, for an opt-in
#' **unstructured** multivariate fit, when the engine returned them.
#'
#' Heavy caveats (engine row `V4-MV-REML`, `partial`): the strict per-seed
#' recovery gate is still a non-pass (7/12 unstructured seeds in the updated
#' study), but a 12-seed bias/MCSE study (twin `HSquared.jl#78`) shows **no
#' detectable bias** — all six covariance parameters have `|bias| ≤ 2·MCSE`
#' (largest 0.84·MCSE), a low-power non-rejection consistent with an unbiased
#' estimator (not a proof), with EBV accuracy ≈ 0.90 in both traits; a cold-start
#' replication (#79) reaches the same optimum on all 12 seeds, so it is not a
#' warm-start artifact. The per-seed gate failures reflect sampling variance of
#' the estimated `G` at this design, not a detected bias. These SEs remain
#' asymptotic, REML-only, **unstructured-only** (the engine refuses structured /
#' factor-analytic fits, whose loadings are rotation-nonidentified), omitted at a
#' flat/boundary optimum, not coverage-calibrated, with no external comparator,
#' and not a validated capability.
#'
#' @inheritParams variance_components
#'
#' @return A named list of standard-error matrices `genetic_covariance`,
#'   `residual_covariance`, `genetic_correlation`, `residual_correlation`, and a
#'   per-trait `heritability` SE vector, for `hsquared_fit` objects that contain
#'   them.
#' @export
covariance_standard_errors <- function(object, ...) {
  UseMethod("covariance_standard_errors")
}

#' @export
covariance_standard_errors.default <- function(object, ...) {
  stop(
    "`covariance_standard_errors()` requires an `hsquared_fit` object from the ",
    "opt-in unstructured multivariate model. The current package only returns ",
    "these from fitted `hsquared_fit` results.",
    call. = FALSE
  )
}

#' @export
covariance_standard_errors.hsquared_fit <- function(object, ...) {
  hs_fit_result(
    object,
    "covariance_standard_errors",
    "experimental multivariate covariance standard errors"
  )
}

#' Likelihood-ratio test for genetic covariance structure
#'
#' `covariance_structure_lrt(constrained, full)` is an **experimental** nested
#' likelihood-ratio test comparing two opt-in multivariate fits **on the same
#' data**: a `constrained` genetic structure (currently `genetic_structure =
#' "diagonal"`) against the `full` `"unstructured"` fit. The statistic is
#' `2 * (logLik(full) - logLik(constrained))` on
#' `df = n_genetic_params(full) - n_genetic_params(constrained)`.
#'
#' For diagonal-vs-unstructured the null (off-diagonal genetic covariances = 0)
#' is interior, so the χ² reference is exact (`boundary = FALSE`). Structures
#' whose null lies on a rank/PSD boundary (low-rank / factor-analytic) would need
#' a χ²-mixture correction and are gated out of the R bridge for now.
#'
#' It mirrors the engine row `V4-MV-REML` (`partial`): asymptotic, REML-only,
#' dense validation-scale, with the multivariate recovery calibration not yet
#' passed — a reported test, not a validated one. Both fits must be on the same
#' response, fixed effects, and pedigree.
#'
#' @param constrained,full Two `hsquared_fit` objects from the opt-in
#'   multivariate target; `full` must nest `constrained` (more genetic
#'   covariance parameters).
#' @param ... Unused.
#'
#' @return A one-row data frame with `statistic`, `df`, `pvalue`, `boundary`, and
#'   the `constrained` / `full` genetic-structure labels.
#' @export
covariance_structure_lrt <- function(constrained, full, ...) {
  if (
    !inherits(constrained, "hsquared_fit") || !inherits(full, "hsquared_fit")
  ) {
    stop(
      "`constrained` and `full` must both be `hsquared_fit` objects from the ",
      "opt-in multivariate target.",
      call. = FALSE
    )
  }
  field <- function(fit, nm) {
    v <- fit$result[[nm]]
    if (is.null(v)) {
      stop(
        "This `hsquared_fit` does not carry `",
        nm,
        "`. The covariance-structure LRT needs converged multivariate fits ",
        "that report `loglik` and `n_genetic_params`.",
        call. = FALSE
      )
    }
    v
  }
  ll_c <- as.numeric(field(constrained, "loglik"))
  ll_f <- as.numeric(field(full, "loglik"))
  np_c <- as.integer(field(constrained, "n_genetic_params"))
  np_f <- as.integer(field(full, "n_genetic_params"))
  df <- np_f - np_c
  if (df <= 0L) {
    stop(
      "`full` must have more genetic covariance parameters than `constrained` ",
      "(df = ",
      df,
      "); call as `covariance_structure_lrt(constrained, full)`.",
      call. = FALSE
    )
  }
  sc <- constrained$result$genetic_structure %||% NA_character_
  sf <- full$result$genetic_structure %||% NA_character_
  stat <- 2 * (ll_f - ll_c)
  boundary <- !(identical(sc, "diagonal") && identical(sf, "unstructured"))
  data.frame(
    statistic = stat,
    df = df,
    pvalue = stats::pchisq(max(stat, 0), df = df, lower.tail = FALSE),
    boundary = boundary,
    constrained = sc,
    full = sf,
    stringsAsFactors = FALSE
  )
}

#' Inspect fitted-model diagnostics
#'
#' `fit_diagnostics()` returns a compact diagnostics table for an
#' `hsquared_fit` object. It is an inspection helper over the current result
#' payload: it does not refit the model, rerun validation checks, or promote an
#' experimental bridge target to production support.
#'
#' @inheritParams variance_components
#'
#' @return A data frame with `metric` and `value` columns and class
#'   `"hs_fit_diagnostics"`.
#' @export
fit_diagnostics <- function(object, ...) {
  UseMethod("fit_diagnostics")
}

#' @export
fit_diagnostics.default <- function(object, ...) {
  stop(
    "`fit_diagnostics()` requires an `hsquared_fit` object.",
    call. = FALSE
  )
}

#' @export
fit_diagnostics.hsquared_fit <- function(object, ...) {
  diagnostics <- object$result$diagnostics %||% list()
  if (!is.list(diagnostics)) {
    diagnostics <- list(diagnostics = diagnostics)
  }
  base <- list(
    engine = object$engine,
    method = object$spec$method %||% diagnostics$method,
    family = object$spec$family$family,
    target = object$spec$target %||%
      diagnostics$target %||%
      "variance_components",
    converged = object$result$converged %||% diagnostics$converged,
    optimizer_status = diagnostics$optimizer_status,
    iterations = diagnostics$iterations,
    loglik = object$result$loglik,
    df = object$result$df,
    nobs = object$result$nobs %||%
      if (!is.null(object$payload$y)) length(object$payload$y) else NULL,
    dense_validation_path = diagnostics$dense_validation_path,
    variance_components_source = diagnostics$variance_components,
    at_boundary = hs_fit_boundary_flag(object),
    at_boundary_condition = hs_fit_boundary_condition_label(
      hs_fit_boundary_class(object)
    )
  )

  diagnostic_names <- names(diagnostics)
  already_reported <- c(
    "method",
    "target",
    "converged",
    "optimizer_status",
    "iterations",
    "dense_validation_path",
    "variance_components"
  )
  extras <- diagnostics[setdiff(diagnostic_names, already_reported)]
  rows <- c(base, extras)
  rows <- rows[!vapply(rows, is.null, logical(1))]

  out <- data.frame(
    metric = names(rows),
    value = vapply(rows, hs_diagnostic_value, character(1)),
    stringsAsFactors = FALSE
  )
  class(out) <- c("hs_fit_diagnostics", class(out))
  out
}

#' @export
print.hs_fit_diagnostics <- function(x, ...) {
  cat("<hs_fit_diagnostics>\n")
  out <- x
  class(out) <- setdiff(class(out), "hs_fit_diagnostics")
  print.data.frame(out, row.names = FALSE)
  invisible(x)
}

# Classify the variance-component boundary condition, distinguishing a benign
# near-zero boundary from an inadmissible NEGATIVE variance estimate. Returns
# one of "zero" (0 <= min share <= tol), "negative" (min share < 0, an
# inadmissible fit, not a clean boundary), FALSE (interior), or NULL when the
# components are unavailable or the layout is not a single-primary one. A NULL is
# also returned when the variance shape is not a list (e.g. an atomic vector or
# matrix), so a malformed payload drops the row rather than crashing the caller
# with "$ operator is invalid for atomic vectors" (a data.frame IS a list, so
# the normal path proceeds). The negative case is surfaced separately because a
# negative variance is inadmissible: it must not be read as the at/near-zero
# boundary that the v0.1 contract (item 4) treats as a clean h2 -> 0 / 1 edge.
hs_fit_boundary_class <- function(object, tol = 1e-4) {
  vc <- object$result$variance_components
  if (!is.list(vc)) {
    return(NULL)
  }
  if (is.null(vc$estimate) || is.null(vc$component)) {
    return(NULL)
  }
  est <- as.numeric(vc$estimate)
  primary_names <- c("animal", "genomic", "single_step")
  primary <- est[vc$component %in% primary_names]
  if (length(primary) != 1L) {
    return(NULL)
  }
  if (any(!is.finite(est))) {
    return(NULL)
  }
  # A negative component is inadmissible regardless of the total scale, so check
  # the raw sign before normalizing (a negative estimate can drive the total
  # non-positive, which would otherwise drop the row).
  if (min(est) < 0) {
    return("negative")
  }
  total <- sum(est)
  if (total <= 0) {
    return(NULL)
  }
  shares <- est / total
  if (min(shares) <= tol) {
    "zero"
  } else {
    FALSE
  }
}

# Logical boundary flag for the `at_boundary` diagnostics row: TRUE when the fit
# sits at a variance-component boundary. A near-zero ("zero") component and an
# inadmissible negative ("negative") estimate both count as not-interior here;
# the distinct wording for the negative case is carried by
# hs_fit_boundary_class() / the `at_boundary_condition` row. Returns NULL when
# the class is unavailable (row dropped), preserving the unavailable -> NULL
# contract.
#
# A fit is at the boundary when ANY variance component it reports is at/near zero
# relative to the variance total: the primary genetic / effect component
# (h2 -> 0), the residual (sigma_e2 -> 0, i.e. h2 -> 1), or a second effect such
# as permanent, common-environment, or maternal (-> 0). The primary genetic /
# effect component is named differently across targets ("animal" for the
# pedigree animal model, "genomic" for genomic and SNP-BLUP fits, "single_step"
# for single-step fits), so the check first confirms exactly one primary
# component is present. This restricts the flag to the univariate,
# repeatability, two-effect, genomic, and single-step layouts (each has one
# primary component) and leaves multivariate fits unflagged (NULL), since they
# report per-trait "genetic"/"residual" diagonals rather than a single primary
# share. This is the surfacing half of the v0.1 promotion predicate item 4; the
# engine (HSquared.jl) owns boundary-stable optimization.
hs_fit_boundary_flag <- function(object, tol = 1e-4) {
  cls <- hs_fit_boundary_class(object, tol = tol)
  if (is.null(cls)) {
    return(NULL)
  }
  cls %in% c("zero", "negative")
}

# Map a boundary class to the `at_boundary_condition` diagnostics value. Only the
# at/near-zero and inadmissible-negative cases get a row (NULL is dropped by the
# caller), so the condition row appears exactly when it carries information the
# logical `at_boundary` flag cannot: which kind of boundary the fit hit.
hs_fit_boundary_condition_label <- function(cls) {
  if (is.null(cls) || isFALSE(cls)) {
    return(NULL)
  }
  switch(
    cls,
    zero = "at/near zero (clean boundary)",
    negative = "negative (inadmissible variance)",
    NULL
  )
}

hs_diagnostic_value <- function(x) {
  if (length(x) == 0L) {
    return(NA_character_)
  }
  if (is.logical(x)) {
    return(paste(ifelse(x, "TRUE", "FALSE"), collapse = ", "))
  }
  if (is.numeric(x)) {
    return(paste(format(x, digits = 8, trim = TRUE), collapse = ", "))
  }
  if (is.character(x)) {
    return(paste(x, collapse = ", "))
  }
  if (is.factor(x)) {
    return(paste(as.character(x), collapse = ", "))
  }
  if (is.atomic(x)) {
    return(paste(as.character(x), collapse = ", "))
  }
  "<list>"
}

#' Extract planned marker, QTL, GWAS, and eQTL results
#'
#' These extractor names cover genomic, QTL, GWAS, and eQTL fitted results.
#' They return values only when an `hsquared_fit` object contains the
#' corresponding result field. `marker_effects()` and
#' `marker_variance_explained()` are populated by the opt-in SNP-BLUP path
#' (`target = "snp_blup"`). The variance-explained table is a descriptive
#' fitted-marker share, computed as effect squared times centered marker
#' variance and normalized across markers; it is not a marker-scan p-value,
#' QTL statistic, or causal decomposition under linkage disequilibrium. The
#' remaining names are reserved for future results. The current package does
#' not fit marker-scan, QTL, GWAS, or eQTL models.
#'
#' @inheritParams variance_components
#'
#' @return The requested marker or scan result for `hsquared_fit` objects that
#'   contain the corresponding field.
#' @name marker_extractors
NULL

#' @rdname marker_extractors
#' @export
marker_effects <- function(object, ...) {
  UseMethod("marker_effects")
}

#' @export
marker_effects.default <- function(object, ...) {
  hs_marker_extractor_default("marker_effects")
}

#' @export
marker_effects.hsquared_fit <- function(object, ...) {
  hs_fit_result(object, "marker_effects", "marker effects")
}

#' @rdname marker_extractors
#' @export
marker_variance_explained <- function(object, ...) {
  UseMethod("marker_variance_explained")
}

#' @export
marker_variance_explained.default <- function(object, ...) {
  hs_marker_extractor_default("marker_variance_explained")
}

#' @export
marker_variance_explained.hsquared_fit <- function(object, ...) {
  if (!is.null(object$result$marker_variance_explained)) {
    return(object$result$marker_variance_explained)
  }
  if (
    identical(object$spec$target, "snp_blup") &&
      !is.null(object$result$marker_effects) &&
      !is.null(object$payload$markers)
  ) {
    marker_design <- if (!is.null(object$payload$Z)) {
      as.matrix(object$payload$Z %*% object$payload$markers)
    } else {
      object$payload$markers
    }
    allele_frequencies <- object$result$marker_allele_frequencies
    if (length(allele_frequencies) == 0L) {
      allele_frequencies <- NULL
    }
    return(hs_marker_variance_explained_from_snp_blup(
      effects = object$result$marker_effects$effect,
      markers = marker_design,
      marker_labels = object$result$marker_effects$marker,
      allele_frequencies = allele_frequencies
    ))
  }
  hs_fit_result(
    object,
    "marker_variance_explained",
    "marker variance explained"
  )
}

#' @rdname marker_extractors
#' @export
qtl_table <- function(object, ...) {
  UseMethod("qtl_table")
}

#' @export
qtl_table.default <- function(object, ...) {
  hs_marker_extractor_default("qtl_table")
}

#' @export
qtl_table.hsquared_fit <- function(object, ...) {
  hs_fit_result(object, "qtl_table", "QTL table")
}

#' @rdname marker_extractors
#' @export
gwas_table <- function(object, ...) {
  UseMethod("gwas_table")
}

#' @export
gwas_table.default <- function(object, ...) {
  hs_marker_extractor_default("gwas_table")
}

#' @export
gwas_table.hsquared_fit <- function(object, ...) {
  hs_fit_result(object, "gwas_table", "GWAS table")
}

#' @rdname marker_extractors
#' @export
eqtl_table <- function(object, ...) {
  UseMethod("eqtl_table")
}

#' @export
eqtl_table.default <- function(object, ...) {
  hs_marker_extractor_default("eqtl_table")
}

#' @export
eqtl_table.hsquared_fit <- function(object, ...) {
  hs_fit_result(object, "eqtl_table", "eQTL table")
}

#' @rdname marker_extractors
#' @export
lod_scores <- function(object, ...) {
  UseMethod("lod_scores")
}

#' @export
lod_scores.default <- function(object, ...) {
  hs_marker_extractor_default("lod_scores")
}

#' @export
lod_scores.hsquared_fit <- function(object, ...) {
  hs_fit_result(object, "lod_scores", "LOD scores")
}

hs_marker_extractor_default <- function(name) {
  stop(
    "`",
    name,
    "()` requires an `hsquared_fit` object with marker/QTL/eQTL results. ",
    "`marker_effects()` and `marker_variance_explained()` are populated only ",
    "by opt-in SNP-BLUP fits. For a relatedness-corrected post-fit marker scan, ",
    "use `gwas(fit, markers)` (experimental; nominal / Bonferroni / BH ",
    "p-values, NOT genome-wide calibrated). These tabular `gwas_table()` / ",
    "`qtl_table()` / `eqtl_table()` / `lod_scores()` extractors remain reserved ",
    "for the planned map-annotated scan API (gated on calibrated thresholds, ",
    "HSquared.jl#48).",
    call. = FALSE
  )
}

#' Extract fixed effects
#'
#' `fixef()` is part of the planned v0.1 fitted-object contract for
#' `hsquared_fit` objects.
#'
#' @inheritParams variance_components
#'
#' @return Fixed-effect estimates for `hsquared_fit` objects.
#' @export
fixef <- function(object, ...) {
  UseMethod("fixef")
}

#' @export
fixef.default <- function(object, ...) {
  stop(
    "`fixef()` requires an `hsquared_fit` object. The current package does ",
    "not provide fixed effects for this object.",
    call. = FALSE
  )
}

#' @export
fixef.hsquared_fit <- function(object, ...) {
  hs_fit_result(object, "fixed_effects", "fixed-effect estimates")
}

#' @export
coef.hsquared_fit <- function(object, ...) {
  fixef(object, ...)
}

#' Extract random effects
#'
#' `ranef()` is part of the planned v0.1 fitted-object contract for
#' `hsquared_fit` objects.
#'
#' @inheritParams variance_components
#'
#' @return Random-effect estimates for `hsquared_fit` objects.
#' @export
ranef <- function(object, ...) {
  UseMethod("ranef")
}

#' @export
ranef.default <- function(object, ...) {
  stop(
    "`ranef()` requires an `hsquared_fit` object. The current package does ",
    "not provide random effects for this object.",
    call. = FALSE
  )
}

#' @export
ranef.hsquared_fit <- function(object, ...) {
  hs_fit_result(object, "random_effects", "random-effect estimates")
}

#' @export
logLik.hsquared_fit <- function(object, ...) {
  if (identical(object$result$converged, FALSE)) {
    stop(
      "Log-likelihood is unavailable because this `hsquared_fit` object did ",
      "not converge.",
      call. = FALSE
    )
  }
  value <- hs_fit_result(object, "loglik", "log-likelihood")
  out <- value
  class(out) <- "logLik"
  attr(out, "df") <- object$result$df %||% NA_integer_
  attr(out, "nobs") <- object$result$nobs %||% length(object$payload$y)
  out
}

#' @export
AIC.hsquared_fit <- function(object, ..., k = 2) {
  stats::AIC(stats::logLik(object), ..., k = k)
}

#' Block unsupported likelihood-inference helpers
#'
#' These methods intentionally fail with explicit scope messages. v0.1 reports
#' point estimates, likelihood summaries for converged fits, and diagnostics,
#' but validated standard errors, confidence intervals, profile likelihoods, and
#' likelihood-ratio tests are deferred until they have validation evidence.
#'
#' @param object An `hsquared_fit` object.
#' @param fitted An `hsquared_fit` object for [stats::profile()].
#' @param ... Reserved for future arguments.
#' @param parm,level Included for compatibility with [stats::confint()].
#'
#' @return These functions always error.
#' @name inference_blocks
NULL

#' @rdname inference_blocks
#' @export
confint.hsquared_fit <- function(object, parm, level = 0.95, ...) {
  stop(
    "Validated confidence intervals for variance components, h2, and other ",
    "`hsquared_fit` quantities are planned, not implemented. v0.1 reports ",
    "point estimates only; use `variance_components()`, `heritability()`, and ",
    "`fit_diagnostics()`.",
    call. = FALSE
  )
}

#' @rdname inference_blocks
#' @export
vcov.hsquared_fit <- function(object, ...) {
  stop(
    "A validated estimator variance-covariance matrix / standard-error surface ",
    "is planned, not implemented for `hsquared_fit` objects. v0.1 reports ",
    "point estimates only.",
    call. = FALSE
  )
}

#' @rdname inference_blocks
#' @export
profile.hsquared_fit <- function(fitted, ...) {
  stop(
    "Profile-likelihood intervals for `hsquared_fit` objects are planned, not ",
    "implemented. v0.1 reports point estimates and convergence diagnostics ",
    "only.",
    call. = FALSE
  )
}

#' @rdname inference_blocks
#' @export
anova.hsquared_fit <- function(object, ...) {
  stop(
    "Likelihood-ratio / ANOVA comparison for `hsquared_fit` objects is planned, ",
    "not implemented. v0.1 exposes `logLik()` and `AIC()` for converged fits, ",
    "but does not yet validate LRT guidance.",
    call. = FALSE
  )
}

#' @importFrom stats nobs
#' @export
nobs.hsquared_fit <- function(object, ...) {
  n <- object$result$nobs %||%
    if (!is.null(object$payload$y)) length(object$payload$y) else NULL
  if (is.null(n)) {
    stop(
      "This `hsquared_fit` object does not contain number-of-observations ",
      "metadata.",
      call. = FALSE
    )
  }
  as.integer(n)
}

# Detect the opt-in multivariate target, whose fitted object stores `Y`
# (a multi-trait matrix) and emits no single-vector predictions. The response-
# scale `predict()`/`fitted()`/`residuals()` contract is univariate-only in
# v0.1, so these block on that target with a target-named scope message rather
# than the generic "planned v0.1 contract" miss from `hs_fit_result()`.
hs_fit_is_multivariate <- function(object) {
  identical(object$spec$target, "multivariate") || !is.null(object$payload$Y)
}

hs_block_multivariate_response_scale <- function(name) {
  stop(
    "`",
    name,
    "()` on the response scale is univariate-only in v0.1 and is not defined ",
    "for the opt-in multivariate target (`target = \"multivariate\"`), which ",
    "fits multiple traits jointly. Use `breeding_values()`, ",
    "`genetic_covariance()`, and `residual_covariance()` for multivariate ",
    "results.",
    call. = FALSE
  )
}

#' Response-scale prediction helpers
#'
#' `predict()`, `fitted()`, and `residuals()` are part of the planned v0.1
#' fitted-object contract for univariate `hsquared_fit` objects. They are
#' univariate-only: the opt-in multivariate target (`target = "multivariate"`)
#' fits multiple traits jointly and is intentionally out of v0.1 response-scale
#' scope, so these methods stop with a scope message pointing to
#' `breeding_values()`, `genetic_covariance()`, and `residual_covariance()`.
#'
#' @inheritParams variance_components
#'
#' @return Response-scale predictions, fitted values, or residuals for
#'   univariate `hsquared_fit` objects.
#' @name response_scale_methods
NULL

#' @rdname response_scale_methods
#' @export
predict.hsquared_fit <- function(object, ...) {
  if (hs_fit_is_multivariate(object)) {
    hs_block_multivariate_response_scale("predict")
  }
  hs_fit_result(object, "predictions", "predictions")
}

#' @rdname response_scale_methods
#' @export
fitted.hsquared_fit <- function(object, ...) {
  if (hs_fit_is_multivariate(object)) {
    hs_block_multivariate_response_scale("fitted")
  }
  predictions <- stats::predict(object, ...)
  if (is.data.frame(predictions) && ".fitted" %in% names(predictions)) {
    return(predictions$.fitted)
  }
  predictions
}

#' @rdname response_scale_methods
#' @export
residuals.hsquared_fit <- function(object, ...) {
  if (hs_fit_is_multivariate(object)) {
    hs_block_multivariate_response_scale("residuals")
  }
  response <- object$payload$y
  if (is.null(response)) {
    stop(
      "This `hsquared_fit` object does not contain response values.",
      call. = FALSE
    )
  }
  fitted_values <- as.numeric(stats::fitted(object, ...))
  response <- as.numeric(response)
  if (length(response) != length(fitted_values)) {
    stop(
      "Response and fitted values must have the same length to compute ",
      "residuals.",
      call. = FALSE
    )
  }
  response - fitted_values
}

# ---------------------------------------------------------------------------
# Random-regression (reaction-norm) extractors
# ---------------------------------------------------------------------------

# Detect the opt-in random-regression target and fetch its result block. The
# trajectory extractors compute v_g(t)/h^2(t)/correlation in R from the supplied
# K_g and the recorded standardization bounds, so they need no live Julia.
hs_fit_is_random_regression <- function(object) {
  identical(object$spec$target, "random_regression") ||
    !is.null(object$result$coefficient_covariance)
}

hs_require_random_regression <- function(object, name) {
  if (!inherits(object, "hsquared_fit")) {
    stop(
      "`",
      name,
      "()` requires an `hsquared_fit` object from the opt-in random-regression ",
      "model (`target = \"random_regression\"`).",
      call. = FALSE
    )
  }
  if (!hs_fit_is_random_regression(object)) {
    stop(
      "`",
      name,
      "()` requires a fit from the opt-in random-regression model ",
      "(`target = \"random_regression\"`), fitted with an ",
      "`animal(rr(covariate, order = k) | id, pedigree = ped)` term.",
      call. = FALSE
    )
  }
  invisible(object)
}

# Resolve the covariate points the trajectory is evaluated at. `at = NULL`
# (the default) builds an evenly spaced grid of `n` points spanning the recorded
# covariate range; otherwise `at` is taken on the ORIGINAL covariate scale.
# Returns the original-scale points and the matching standardized t in [-1, 1].
hs_rr_eval_points <- function(object, at, n = 25L) {
  rr <- object$result$random_regression
  if (is.null(rr)) {
    stop(
      "This random-regression `hsquared_fit` is missing its covariate ",
      "standardization metadata.",
      call. = FALSE
    )
  }
  if (is.null(at)) {
    at <- seq(rr$lower, rr$upper, length.out = n)
  } else {
    at <- as.numeric(at)
    if (length(at) == 0L || anyNA(at) || any(!is.finite(at))) {
      stop("`at` must be finite covariate values.", call. = FALSE)
    }
  }
  t_std <- hs_standardize_covariate(at, rr$lower, rr$upper)
  list(at = at, t = t_std, covariate = rr$covariate, order = rr$order)
}

# Per-point additive genetic variance v_g(t) = phi(t)' K_g phi(t), clamped to >= 0
# (mirrors `HSquared.rr_genetic_variance`).
hs_rr_variance_values <- function(K_g, t_std, order) {
  phi <- hs_legendre_design(t_std, order)
  vapply(
    seq_along(t_std),
    function(i) {
      max(0, drop(phi[i, , drop = FALSE] %*% K_g %*% t(phi[i, , drop = FALSE])))
    },
    numeric(1L)
  )
}

#' Random-regression (reaction-norm) extractors
#'
#' These extractors summarize an opt-in, **experimental** random-regression
#' (reaction-norm) fit (`target = "random_regression"`), fitted with an
#' `animal(rr(covariate, order = k) | id, pedigree = ped)` term. The model
#' estimates a `k x k` genetic covariance matrix `K_g` among an animal's
#' normalized-Legendre random-regression coefficients plus a single homogeneous
#' residual variance.
#'
#' * `rr_covariance()` returns the estimated `k x k` coefficient genetic
#'   covariance matrix `K_g`.
#' * `random_coefficients()` returns the per-animal predicted Legendre
#'   coefficients (long format: `id`, `coefficient`, `value`).
#' * `rr_genetic_variance()` returns the additive genetic variance trajectory
#'   `v_g(t) = phi(t)' K_g phi(t)` across covariate points.
#' * `rr_heritability()` returns the heritability trajectory
#'   `h^2(t) = v_g(t) / (v_g(t) + sigma_e^2)`. Because the residual is
#'   homogeneous and there is no permanent-environment term yet, this can
#'   OVERSTATE `h^2(t)` for repeated-records designs (test-day, growth curves).
#' * `rr_correlation()` returns the genetic correlation surface among the
#'   covariate points.
#'
#' The trajectories are computed in R from the estimated `K_g` and the recorded
#' covariate standardization range; `at` is supplied on the ORIGINAL covariate
#' scale (defaulting to a grid over the fitted range) and re-standardized to
#' `[-1, 1]` internally, matching the Julia engine's basis convention.
#'
#' @param object A random-regression `hsquared_fit` object.
#' @param at Covariate values on the original scale at which to evaluate the
#'   trajectory. `NULL` (the default) uses an evenly spaced grid over the fitted
#'   covariate range.
#' @param n Number of grid points used when `at = NULL`.
#' @param ... Reserved for future arguments.
#'
#' @return `rr_covariance()` returns a numeric matrix; `random_coefficients()`
#'   returns a data frame; the trajectory extractors return a data frame with a
#'   `covariate` column and the evaluated `value`s.
#'
#' @examplesIf FALSE
#' fit_rr <- hsquared(
#'   weight ~ sex + animal(rr(age, order = 2) | id, pedigree = ped),
#'   data = long_records,
#'   family = gaussian(),
#'   REML = TRUE,
#'   control = hs_control(
#'     engine = "julia",
#'     engine_control = list(target = "random_regression")
#'   )
#' )
#'
#' rr_covariance(fit_rr)
#' random_coefficients(fit_rr)
#' rr_genetic_variance(fit_rr)
#' rr_heritability(fit_rr)
#' rr_correlation(fit_rr, at = c(1, 3, 5))
#' @name random_regression_extractors
NULL

#' @rdname random_regression_extractors
#' @export
rr_covariance <- function(object, ...) {
  UseMethod("rr_covariance")
}

#' @export
rr_covariance.default <- function(object, ...) {
  hs_require_random_regression(object, "rr_covariance")
}

#' @export
rr_covariance.hsquared_fit <- function(object, ...) {
  hs_require_random_regression(object, "rr_covariance")
  hs_fit_result(
    object,
    "coefficient_covariance",
    "the random-regression coefficient genetic covariance matrix"
  )
}

#' @rdname random_regression_extractors
#' @export
random_coefficients <- function(object, ...) {
  UseMethod("random_coefficients")
}

#' @export
random_coefficients.default <- function(object, ...) {
  hs_require_random_regression(object, "random_coefficients")
}

#' @export
random_coefficients.hsquared_fit <- function(object, ...) {
  hs_require_random_regression(object, "random_coefficients")
  hs_fit_result(
    object,
    "random_coefficients",
    "the predicted random-regression coefficients"
  )
}

#' @rdname random_regression_extractors
#' @export
rr_genetic_variance <- function(object, at = NULL, n = 25L, ...) {
  UseMethod("rr_genetic_variance")
}

#' @export
rr_genetic_variance.default <- function(object, at = NULL, n = 25L, ...) {
  hs_require_random_regression(object, "rr_genetic_variance")
}

#' @export
rr_genetic_variance.hsquared_fit <- function(object, at = NULL, n = 25L, ...) {
  hs_require_random_regression(object, "rr_genetic_variance")
  K_g <- rr_covariance(object)
  pts <- hs_rr_eval_points(object, at, n)
  data.frame(
    covariate = pts$at,
    value = hs_rr_variance_values(K_g, pts$t, pts$order),
    stringsAsFactors = FALSE
  )
}

#' @rdname random_regression_extractors
#' @export
rr_heritability <- function(object, at = NULL, n = 25L, ...) {
  UseMethod("rr_heritability")
}

#' @export
rr_heritability.default <- function(object, at = NULL, n = 25L, ...) {
  hs_require_random_regression(object, "rr_heritability")
}

#' @export
rr_heritability.hsquared_fit <- function(object, at = NULL, n = 25L, ...) {
  hs_require_random_regression(object, "rr_heritability")
  K_g <- rr_covariance(object)
  sigma_e2 <- hs_fit_result(
    object,
    "residual_variance",
    "the random-regression residual variance"
  )
  pts <- hs_rr_eval_points(object, at, n)
  vg <- hs_rr_variance_values(K_g, pts$t, pts$order)
  data.frame(
    covariate = pts$at,
    value = vg / (vg + as.numeric(sigma_e2)),
    stringsAsFactors = FALSE
  )
}

#' @rdname random_regression_extractors
#' @export
rr_correlation <- function(object, at = NULL, n = 25L, ...) {
  UseMethod("rr_correlation")
}

#' @export
rr_correlation.default <- function(object, at = NULL, n = 25L, ...) {
  hs_require_random_regression(object, "rr_correlation")
}

#' @export
rr_correlation.hsquared_fit <- function(object, at = NULL, n = 25L, ...) {
  hs_require_random_regression(object, "rr_correlation")
  K_g <- rr_covariance(object)
  pts <- hs_rr_eval_points(object, at, n)
  phi <- hs_legendre_design(pts$t, pts$order)
  G <- phi %*% K_g %*% t(phi)
  G <- 0.5 * (G + t(G))
  d <- diag(G)
  if (any(d <= 0)) {
    stop(
      "`rr_correlation()` is undefined: at least one covariate point has ",
      "non-positive genetic variance. Evaluate at points inside the genetic ",
      "variance support, or inspect `rr_genetic_variance()`.",
      call. = FALSE
    )
  }
  corr <- stats::cov2cor(G)
  dimnames(corr) <- list(
    format(pts$at, trim = TRUE),
    format(pts$at, trim = TRUE)
  )
  corr
}
