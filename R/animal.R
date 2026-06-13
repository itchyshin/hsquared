#' Animal-model formula marker
#'
#' `animal()` marks an additive-genetic random effect in an `hsquared()`
#' formula. The first implemented parser contract accepts only
#' `animal(1 | id, pedigree = ped)`. Fitting still waits for the Julia engine
#' bridge, so this function is a syntax marker rather than a standalone
#' modelling helper.
#'
#' @param formula A random-effect expression. The v0.1 parser accepts
#'   `1 | id`.
#' @param pedigree A pedigree data frame with individual, sire, and dam columns.
#' @param ... Reserved for future syntax such as `cov =`.
#'
#' @return `NULL`, invisibly. The call is interpreted by [hsquared()] when it
#'   appears inside a model formula.
#' @export
animal <- function(formula, pedigree, ...) {
  invisible(NULL)
}
