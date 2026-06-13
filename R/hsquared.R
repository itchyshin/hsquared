#' Fit a quantitative-genetic model
#'
#' `hsquared()` is the planned R entry point for heritability, breeding-value,
#' G-matrix, and inheritance-structured mixed models. The Phase 0 scaffold
#' validates the call shape and stops before fitting.
#'
#' @param formula A model formula. The first planned v0.1 syntax is
#'   `y ~ fixed + animal(1 | id, pedigree = ped)`.
#' @param data A data frame containing model variables.
#' @param family A response family. Phase 0 accepts the argument but does not
#'   fit any family.
#' @param REML Logical; whether the planned Gaussian animal model should use
#'   REML. This is recorded for the future v0.1 contract only.
#' @param control An object created by [hs_control()].
#' @param ... Reserved for future arguments.
#'
#' @return This Phase 0 scaffold always errors before returning a fit.
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
  if (!is.logical(REML) || length(REML) != 1L || is.na(REML)) {
    stop("`REML` must be `TRUE` or `FALSE`.", call. = FALSE)
  }

  dots <- list(...)
  force(formula)
  force(data)
  force(family)
  force(dots)

  stop(
    "`hsquared()` is a Phase 0 scaffold. Model fitting is not implemented ",
    "yet. The first planned model is a Gaussian animal model with ",
    "`animal(1 | id, pedigree = ped)`; see `docs/design/01-v0.1-contract.md`.",
    call. = FALSE
  )
}
