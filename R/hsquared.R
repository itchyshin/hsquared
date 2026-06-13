#' Fit a quantitative-genetic model
#'
#' `hsquared()` is the planned R entry point for heritability, breeding-value,
#' G-matrix, and inheritance-structured mixed models. The current parser
#' validates the narrow v0.1 animal-model contract and stops before fitting.
#'
#' @param formula A model formula. The first planned v0.1 syntax is
#'   `y ~ fixed + animal(1 | id, pedigree = ped)`.
#' @param data A data frame containing model variables.
#' @param family A response family. The v0.1 parser accepts only
#'   `gaussian()`.
#' @param REML Logical; whether the planned Gaussian animal model should use
#'   REML. This is recorded for the future v0.1 contract only.
#' @param control An object created by [hs_control()].
#' @param ... Reserved for future arguments.
#'
#' @return The current scaffold always errors before returning a fit.
#' @export
hsquared <- function(
  formula,
  data,
  family = stats::gaussian(),
  REML = TRUE,
  control = hs_control(),
  ...
) {
  if (missing(formula)) {
    stop("`formula` is required.", call. = FALSE)
  }
  if (missing(data)) {
    stop("`data` is required.", call. = FALSE)
  }
  if (!inherits(control, "hs_control")) {
    stop("`control` must be created by `hs_control()`.", call. = FALSE)
  }
  dots <- list(...)
  force(dots)

  spec <- hs_build_model_spec(
    formula = formula,
    data = data,
    family = family,
    REML = REML
  )
  payload <- hs_build_bridge_payload(spec)
  force(payload)

  stop(
    "`hsquared()` parsed the v0.1 animal-model contract, but model ",
    "fitting is not implemented yet. The next bridge target is to build ",
    "`Ainv` in HSquared.jl, validate ",
    "`HSquared.animal_model_spec(y, X, Z, Ainv; ids = ids, method = :",
    payload$method,
    ")`, and then call `HSquared.fit_animal_model(spec)`.",
    call. = FALSE
  )
}
