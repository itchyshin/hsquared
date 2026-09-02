#' hsquared: R Interface for Julia-Backed Quantitative-Genetic Models
#'
#' The hsquared package is the planned R-facing interface for heritability,
#' breeding-value, G-matrix, and inheritance-structured quantitative-genetic
#' models backed by the HSquared.jl Julia engine.
#'
#' v0.1 fits the univariate Gaussian animal model
#' `y ~ fixed + animal(1 | id, pedigree = ped)` by REML (average-information)
#' through the HSquared.jl engine: the default `hsquared()` call fits when a
#' local Julia and `HSquared.jl` are available, and otherwise errors with
#' install guidance. A `cbind()` multivariate Gaussian response also routes on
#' that default path, though the multivariate capability stays experimental.
#' Genomic, single-step, repeatability, two-effect, and non-Gaussian
#' (`poisson`/`binomial`, Laplace or variational REML) models fit through
#' opt-in, experimental engine paths; factor-analytic models remain planned.
#'
#' @section Current limitations:
#' This package is **experimental**; the first CRAN release targets 0.5.0,
#' not 1.0.0. Default [hsquared()] fitting requires a local Julia installation
#' and HSquared.jl; use [hs_control()] with `engine = "validate"` to check the
#' model contract without fitting. Report point estimates only for rows marked
#' `covered` in [validation_status()]; uncertainty intervals are experimental
#' and not coverage-calibrated. See `vignette("model-status", package =
#' "hsquared")` and `vignette("validation-evidence", package = "hsquared")`.
#'
#' @keywords internal
## usethis namespace: start
#' @importFrom lifecycle deprecated
## usethis namespace: end
"_PACKAGE"
