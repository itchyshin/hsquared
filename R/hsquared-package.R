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
#' install guidance. Genomic, single-step, repeatability, two-effect,
#' multivariate Gaussian, and non-Gaussian (`poisson`/`binomial`, Laplace or
#' variational REML) models also fit through opt-in, experimental engine paths;
#' factor-analytic models remain planned.
#'
#' @keywords internal
"_PACKAGE"
