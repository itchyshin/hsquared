#' Create hsquared control options
#'
#' `hs_control()` records execution and storage controls for hsquared model
#' calls. The default `engine = "validate"` parses and validates the v0.1
#' contract before stopping. The experimental `engine = "julia"` path attempts
#' the current local Julia bridge for tiny v0.1 animal-model payloads.
#'
#' @param engine Execution engine. `"validate"` stops after parser and bridge
#'   payload validation. `"julia"` uses the experimental local JuliaCall bridge.
#' @param backend Planned compute backend. One of `"auto"`, `"cpu"`,
#'   `"threads"`, `"cuda"`, `"amdgpu"`, `"metal"`, or `"oneapi"`.
#' @param accelerator Planned accelerator preference. One of `"auto"`,
#'   `"none"`, `"gpu"`, `"cuda"`, `"amdgpu"`, `"metal"`, or `"oneapi"`.
#' @param precision Planned numeric precision. One of `"float64"` or
#'   `"float32"`.
#' @param save Planned fitted-object storage mode. One of `"minimal"`,
#'   `"full"`, or `"tiny"`.
#' @param engine_control A named list for engine-specific controls. The current
#'   experimental Julia bridge recognizes `julia_project`, `initial`,
#'   `iterations`, `target`, and `variance_components`.
#'   `target = "henderson_mme"` is a supplied-variance validation path and
#'   requires `variance_components` with named `sigma_a2` and `sigma_e2` values.
#'   `target = "sparse_reml"` is an experimental, opt-in validation path that
#'   surfaces the Julia-owned `HSquared.fit_sparse_reml()` REML-only sparse
#'   optimizer; it accepts `initial` (named `sigma_a2`/`sigma_e2`) and
#'   `iterations`. It is not the default, not production fitting, and not a
#'   variance-component estimation claim for the public R interface.
#'   `target = "ai_reml"` is an experimental, opt-in validation path that
#'   surfaces the Julia-owned `HSquared.fit_ai_reml()` average-information REML
#'   optimizer; like `sparse_reml` it accepts `initial` and `iterations`, is not
#'   the default, and is not a variance-component estimation claim for the
#'   public R interface.
#'
#' @return An object of class `"hs_control"`.
#' @export
hs_control <- function(
  engine = c("validate", "julia"),
  backend = c("auto", "cpu", "threads", "cuda", "amdgpu", "metal", "oneapi"),
  accelerator = c("auto", "none", "gpu", "cuda", "amdgpu", "metal", "oneapi"),
  precision = c("float64", "float32"),
  save = c("minimal", "full", "tiny"),
  engine_control = list()
) {
  engine <- match.arg(engine)
  backend <- match.arg(backend)
  accelerator <- match.arg(accelerator)
  precision <- match.arg(precision)
  save <- match.arg(save)

  if (!is.list(engine_control)) {
    stop("`engine_control` must be a list.", call. = FALSE)
  }
  if (length(engine_control) > 0L) {
    names_ok <- !is.null(names(engine_control)) &&
      all(nzchar(names(engine_control)))
    if (!names_ok) {
      stop("`engine_control` must be a named list.", call. = FALSE)
    }
  }

  structure(
    list(
      engine = engine,
      backend = backend,
      accelerator = accelerator,
      precision = precision,
      save = save,
      engine_control = engine_control
    ),
    class = "hs_control"
  )
}

hs_engine_control_value <- function(control, name, default) {
  if (!name %in% names(control$engine_control)) {
    return(default)
  }
  control$engine_control[[name]]
}
