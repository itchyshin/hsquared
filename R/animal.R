#' Animal-model formula marker
#'
#' `animal()` marks an additive-genetic random effect in an `hsquared()`
#' formula. The first implemented parser contract accepts
#' `animal(1 | id, pedigree = ped)`, or `animal(1 | id)` when `data` is an
#' [hs_data()] object with a pedigree component. General fitting still waits
#' for the production Julia engine bridge, so this function is a syntax marker
#' rather than a standalone modelling helper.
#'
#' @param formula A random-effect expression. The v0.1 parser accepts
#'   `1 | id`.
#' @param pedigree A pedigree data frame with individual, sire, and dam columns.
#'   Optional only when the enclosing [hsquared()] or [model_spec()] call uses
#'   `data = hs_data(..., pedigree = ...)`.
#' @param ... Reserved for future syntax such as `cov =`.
#'
#' @return `NULL`, invisibly. The call is interpreted by [hsquared()] when it
#'   appears inside a model formula.
#' @export
animal <- function(formula, pedigree = NULL, ...) {
  invisible(NULL)
}
