#' Planned quantitative-genetic formula markers
#'
#' These functions reserve readable formula vocabulary for later standard
#' quantitative-genetic, parental, inheritance, and custom-kernel models. They
#' are inert syntax markers today. The current parser rejects them with a
#' planned-not-implemented message instead of treating them as ordinary fixed
#' effects.
#'
#' @param formula A random-effect expression such as `1 | id`.
#' @param pedigree A pedigree data frame for future parental and relationship
#'   effects.
#' @param D,Dinv Dominance relationship or precision matrices.
#' @param E,Einv Epistatic relationship or precision matrices.
#' @param K,Kinv,Q User-supplied relationship or precision matrices.
#' @param parent Planned parent-of-origin side for imprinting effects.
#' @param ... Reserved for future syntax.
#'
#' @return `NULL`, invisibly. Calls are interpreted by [hsquared()] when they
#'   appear inside model formulas.
#' @name qg_effect_markers
NULL

#' @rdname qg_effect_markers
#' @export
permanent <- function(formula, ...) {
  invisible(NULL)
}

#' @rdname qg_effect_markers
#' @export
common_env <- function(formula, ...) {
  invisible(NULL)
}

#' @rdname qg_effect_markers
#' @export
maternal_genetic <- function(formula, pedigree = NULL, ...) {
  invisible(NULL)
}

#' @rdname qg_effect_markers
#' @export
maternal_env <- function(formula, ...) {
  invisible(NULL)
}

#' @rdname qg_effect_markers
#' @export
paternal_genetic <- function(formula, pedigree = NULL, ...) {
  invisible(NULL)
}

#' @rdname qg_effect_markers
#' @export
paternal_env <- function(formula, ...) {
  invisible(NULL)
}

#' @rdname qg_effect_markers
#' @export
cytoplasmic <- function(formula, ...) {
  invisible(NULL)
}

#' @rdname qg_effect_markers
#' @export
imprinting <- function(
  formula,
  pedigree = NULL,
  parent = c("maternal", "paternal"),
  ...
) {
  invisible(NULL)
}

#' @rdname qg_effect_markers
#' @export
dominance <- function(formula, pedigree = NULL, D = NULL, Dinv = NULL, ...) {
  invisible(NULL)
}

#' @rdname qg_effect_markers
#' @export
epistasis <- function(formula, pedigree = NULL, E = NULL, Einv = NULL, ...) {
  invisible(NULL)
}

#' @rdname qg_effect_markers
#' @export
relmat <- function(formula, K = NULL, Kinv = NULL, Q = NULL, ...) {
  invisible(NULL)
}

#' @rdname qg_effect_markers
#' @export
precision <- function(formula, Q = NULL, ...) {
  invisible(NULL)
}
