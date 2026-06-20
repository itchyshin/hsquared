#' Genomic and QTL formula markers
#'
#' These functions provide readable formula vocabulary for genomic, single-step,
#' marker-effect, GWAS, and QTL/eQTL models. Called directly they are inert (they
#' return `NULL`); they take meaning only inside an [hsquared()] formula.
#' `genomic()` and `single_step()` now fit through an opt-in, experimental
#' engine path (`engine = "julia"`, REML-only or supplied-variance, not the
#' default, mirroring a `partial` validation gate): `genomic(1 | id, Ginv = Ginv)`
#' or `genomic(1 | id, markers = M)` (GREML, or SNP-BLUP via
#' `target = "snp_blup"`), and `single_step(1 | id, Hinv = Hinv)` (a precomputed
#' inverse) or `single_step(1 | id, pedigree = ped, markers = M)` (the engine
#' constructs `H^-1` from the pedigree + genotyped-subset markers via
#' `target = "single_step_construct"`; an explicit `pedigree =` is required). The
#' remaining
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
#' @param pedigree A pedigree data frame (`id`, `sire`, `dam`) for the
#'   single-step `H^-1` *construction* path
#'   (`single_step(1 | id, pedigree = ped, markers = M)`), in place of a
#'   precomputed `Hinv`.
#' @param markers A genotyped-subset marker matrix (rows named by genotyped id)
#'   for the single-step construction path; the engine builds the genomic
#'   relationship from it.
#' @param tau,omega,blend_weight,ridge Single-step construction tuning knobs
#'   (Aguilar et al. 2010); defaults `tau = omega = 1`, `blend_weight = ridge = 0`.
#' @export
single_step <- function(
  formula,
  H = NULL,
  Hinv = NULL,
  pedigree = NULL,
  markers = NULL,
  tau = 1,
  omega = 1,
  blend_weight = 0,
  ridge = 0,
  ...
) {
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
