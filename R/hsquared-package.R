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
#' install guidance. Multivariate, genomic, and non-Gaussian models remain
#' planned.
#'
#' @keywords internal
"_PACKAGE"
