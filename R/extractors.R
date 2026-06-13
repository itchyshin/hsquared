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

#' Extract planned marker, QTL, GWAS, and eQTL results
#'
#' These extractor names are reserved for future genomic, QTL, GWAS, and eQTL
#' fitted results. They return values only when an `hsquared_fit` object
#' contains the corresponding result field. The current package does not fit
#' marker-scan, QTL, GWAS, or eQTL models.
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
    "()` requires an `hsquared_fit` object with future marker/QTL/eQTL ",
    "results. The current package reserves this extractor name but does not ",
    "fit marker-scan, QTL, GWAS, or eQTL models yet.",
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

#' @export
predict.hsquared_fit <- function(object, ...) {
  hs_fit_result(object, "predictions", "predictions")
}

#' @export
fitted.hsquared_fit <- function(object, ...) {
  predictions <- stats::predict(object, ...)
  if (is.data.frame(predictions) && ".fitted" %in% names(predictions)) {
    return(predictions$.fitted)
  }
  predictions
}

#' @export
residuals.hsquared_fit <- function(object, ...) {
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
