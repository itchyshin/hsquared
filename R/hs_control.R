#' Create hsquared control options
#'
#' `hs_control()` records the planned execution and storage controls for future
#' hsquared model calls. In Phase 0 these options are validated and stored, but no
#' model fitting is performed.
#'
#' @param backend Planned compute backend. One of `"auto"`, `"cpu"`, or
#'   `"cuda"`.
#' @param accelerator Planned accelerator preference. One of `"auto"`,
#'   `"none"`, or `"cuda"`.
#' @param precision Planned numeric precision. One of `"float64"` or
#'   `"float32"`.
#' @param save Planned fitted-object storage mode. One of `"minimal"`,
#'   `"full"`, or `"tiny"`.
#' @param engine_control A named list reserved for future HSquared.jl engine
#'   controls.
#'
#' @return An object of class `"hs_control"`.
#' @export
hs_control <- function(
  backend = c("auto", "cpu", "cuda"),
  accelerator = c("auto", "none", "cuda"),
  precision = c("float64", "float32"),
  save = c("minimal", "full", "tiny"),
  engine_control = list()
) {
  backend <- match.arg(backend)
  accelerator <- match.arg(accelerator)
  precision <- match.arg(precision)
  save <- match.arg(save)

  if (!is.list(engine_control)) {
    stop("`engine_control` must be a list.", call. = FALSE)
  }

  structure(
    list(
      backend = backend,
      accelerator = accelerator,
      precision = precision,
      save = save,
      engine_control = engine_control
    ),
    class = "hs_control"
  )
}
