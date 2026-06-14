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
    at_boundary = hs_fit_boundary_flag(object)
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

# Flag whether the fit sits at a variance-component boundary (sigma_a2 ~ 0 or
# sigma_e2 ~ 0, i.e. h2 at 0 or 1), so a boundary estimate is not silently read
# as an ordinary interior one. Computed from the returned variance components;
# returns NULL (row dropped) when they are unavailable. This is the surfacing
# half of the v0.1 promotion predicate item 4; the engine (HSquared.jl) owns
# boundary-stable optimization.
hs_fit_boundary_flag <- function(object, tol = 1e-4) {
  vc <- object$result$variance_components
  if (is.null(vc) || is.null(vc$estimate) || is.null(vc$component)) {
    return(NULL)
  }
  est <- as.numeric(vc$estimate)
  total <- sum(est)
  if (!is.finite(total) || total <= 0) {
    return(NULL)
  }
  animal <- est[vc$component == "animal"]
  if (length(animal) != 1L) {
    return(NULL)
  }
  h2 <- animal / total
  isTRUE(h2 <= tol) || isTRUE(h2 >= 1 - tol)
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
