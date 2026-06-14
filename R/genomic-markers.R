#' Genomic and QTL formula markers
#'
#' These functions provide readable formula vocabulary for genomic, single-step,
#' marker-effect, GWAS, and QTL/eQTL models. Called directly they are inert (they
#' return `NULL`); they take meaning only inside an [hsquared()] formula.
#' `genomic()` and `single_step()` now fit through an opt-in, experimental
#' engine path (`engine = "julia"`, REML-only or supplied-variance, not the
#' default, mirroring a `partial` validation gate): `genomic(1 | id, Ginv = Ginv)`
#' or `genomic(1 | id, markers = M)` (GREML, or SNP-BLUP via
#' `target = "snp_blup"`) and `single_step(1 | id, Hinv = Hinv)`. The remaining
#' markers (`markers()`, `marker_scan()`, `qtl_scan()`) are still inert syntax
#' reservations that the parser rejects with a planned-not-implemented message.
#'
#' @param formula A random-effect expression such as `1 | id`.
#' @param G,Ginv,H,Hinv Relationship or precision matrices for future genomic
#'   and single-step models.
#' @param M A marker or dosage matrix for future marker-effect and scan models.
#' @param map A marker map for future marker scans.
#' @param model Planned marker-effect mode.
#' @param position A chromosome-position table or variable for future QTL
#'   scans.
#' @param genotype_probs Genotype probabilities for future interval/QTL scans.
#' @param ... Reserved for future syntax.
#'
#' @return `NULL`, invisibly. Calls are interpreted by [hsquared()] when they
#'   appear inside model formulas.
#' @name genomic_markers
NULL

#' @rdname genomic_markers
#' @export
genomic <- function(formula, G = NULL, Ginv = NULL, ...) {
  invisible(NULL)
}

#' @rdname genomic_markers
#' @export
single_step <- function(formula, H = NULL, Hinv = NULL, ...) {
  invisible(NULL)
}

#' @rdname genomic_markers
#' @export
markers <- function(M, model = c("random", "fixed", "scan"), ...) {
  invisible(NULL)
}

#' @rdname genomic_markers
#' @export
marker_scan <- function(M, map = NULL, ...) {
  invisible(NULL)
}

#' @rdname genomic_markers
#' @export
qtl_scan <- function(position, genotype_probs = NULL, ...) {
  invisible(NULL)
}
