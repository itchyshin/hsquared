#' Extract variance components
#'
#' `variance_components()` is part of the planned v0.1 fitted-object contract.
#' It works for internal `hsquared_fit` objects that already contain a Julia
#' result, but ordinary calls to [hsquared()] do not return fitted models yet.
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
    "package does not fit models yet.",
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
#' works for internal `hsquared_fit` objects that already contain a Julia
#' result, but ordinary calls to [hsquared()] do not return fitted models yet.
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
    "does not fit models yet.",
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
#' works for internal `hsquared_fit` objects that already contain a Julia
#' result, but ordinary calls to [hsquared()] do not return fitted models yet.
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
  stop(
    "`breeding_values()` requires an `hsquared_fit` object. The current ",
    "package does not fit models yet.",
    call. = FALSE
  )
}

#' @export
breeding_values.hsquared_fit <- function(object, ...) {
  hs_fit_result(object, "breeding_values", "breeding values")
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
    "not fit models yet.",
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
    "not fit models yet.",
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
