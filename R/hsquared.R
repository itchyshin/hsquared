#' Fit a quantitative-genetic model
#'
#' `hsquared()` is the planned R entry point for heritability, breeding-value,
#' G-matrix, and inheritance-structured mixed models. The current parser
#' validates the narrow v0.1 animal-model contract. The default control path
#' stops after validation; the experimental Julia engine can fit tiny local
#' bridge examples when a sibling `HSquared.jl` checkout is available.
#'
#' @param formula A model formula. The first planned v0.1 syntax is
#'   `y ~ fixed + animal(1 | id, pedigree = ped)`.
#' @param data A data frame containing model variables.
#' @param family A response family. The v0.1 parser accepts only
#'   `gaussian()`.
#' @param REML Logical; whether the Gaussian animal model should use REML when
#'   the experimental Julia engine is selected.
#' @param control An object created by [hs_control()].
#' @param ... Reserved for future arguments.
#'
#' @return A `"hsquared_fit"` object for the experimental Julia engine, or an
#'   informative error for the default validation-only path.
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
  if (identical(control$engine, "julia")) {
    return(hs_fit_julia_payload(
      payload,
      project = hs_engine_control_value(
        control,
        "julia_project",
        hs_default_julia_project()
      ),
      initial = hs_engine_control_value(
        control,
        "initial",
        c(sigma_a2 = 1, sigma_e2 = 1)
      )
    ))
  }

  stop(
    "`hsquared()` parsed the v0.1 animal-model contract, but model ",
    "fitting is not enabled by default. Use ",
    "`control = hs_control(engine = \"julia\")` for the experimental local ",
    "Julia bridge. Sparse marshalling, validation evidence, and a stable ",
    "production bridge are still required before general fitted animal-model ",
    "support is claimed. The current Julia target is ",
    "`HSquared.fit_animal_model(y, X, Z, Ainv; ids = ids, method = :",
    payload$method,
    ")`.",
    call. = FALSE
  )
}
