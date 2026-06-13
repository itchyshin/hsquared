#' Inspect formula grammar status
#'
#' `formula_status()` reports which pieces of the planned `hsquared()` formula
#' language are parsed today, reserved as syntax markers, or still roadmap-only.
#' It is a status table, not a model-fitting helper.
#'
#' @return A data frame of formula grammar records with class
#'   `"hs_formula_status"`.
#' @export
formula_status <- function() {
  out <- data.frame(
    term = hs_formula_status_terms(),
    category = hs_formula_status_categories(),
    phase = hs_formula_status_phases(),
    syntax_status = hs_formula_status_syntax(),
    fitting_status = hs_formula_status_fitting(),
    current_behavior = hs_formula_status_behavior(),
    stringsAsFactors = FALSE
  )
  class(out) <- c("hs_formula_status", class(out))
  out
}

#' @export
print.hs_formula_status <- function(x, ...) {
  cat("<hs_formula_status>\n")
  cat("  parsed today: animal(1 | id, pedigree = ped); ")
  cat("animal(1 | id) with an hs_data pedigree\n")
  cat("  fitting: animal(1 | id) fits by default (v0.1 Gaussian REML); ")
  cat("other terms are parse-only and general fitting remains planned\n")
  out <- x
  class(out) <- setdiff(class(out), "hs_formula_status")
  print.data.frame(
    out[c("term", "phase", "syntax_status", "fitting_status")],
    row.names = FALSE
  )
  invisible(x)
}

hs_formula_status_terms <- function() {
  c(
    "animal(1 | id, pedigree = ped)",
    "animal(1 | id) with data = hs_data(..., pedigree = ped)",
    "permanent(1 | id)",
    "common_env(1 | group)",
    "maternal_genetic(1 | dam, pedigree = ped)",
    "maternal_env(1 | dam)",
    "paternal_genetic(1 | sire, pedigree = ped)",
    "paternal_env(1 | sire)",
    "cytoplasmic(1 | maternal_line)",
    "imprinting(1 | id, pedigree = ped, parent = \"maternal\")",
    "dominance(1 | id, pedigree = ped)",
    "epistasis(1 | id, pedigree = ped)",
    "relmat(1 | id, K = K)",
    "precision(1 | id, Q = Q)",
    "genomic(1 | id, Ginv = Ginv)",
    "single_step(1 | id, Hinv = Hinv)",
    "markers(M, model = \"random\")",
    "marker_scan(M, map = marker_map)",
    "qtl_scan(position, genotype_probs = probs)",
    "animal(trait | id, pedigree = ped, cov = us())",
    "animal(trait | id, pedigree = ped, cov = fa(K = 2))"
  )
}

hs_formula_status_categories <- function() {
  c(
    rep("v0.1 animal model", 2L),
    rep("standard quantitative genetics", 6L),
    rep("inheritance and relationship kernels", 6L),
    rep("genomic and marker models", 5L),
    rep("multivariate and factor analytic", 2L)
  )
}

hs_formula_status_phases <- function() {
  c(
    rep("Phase 1", 2L),
    rep("Phase 2", 6L),
    rep("Phase 3+", 6L),
    rep("Phase 5", 5L),
    rep("Phase 3-4", 2L)
  )
}

hs_formula_status_syntax <- function() {
  c(
    rep("parsed", 2L),
    rep("reserved", 17L),
    rep("planned", 2L)
  )
}

hs_formula_status_fitting <- function() {
  c(
    rep("fitted (v0.1 default)", 2L),
    rep("not available", 19L)
  )
}

hs_formula_status_behavior <- function() {
  c(
    paste(
      "Parsed and fitted by the default v0.1 path (Gaussian animal model,",
      "REML through the HSquared.jl engine)."
    ),
    paste(
      "Fitted by the default v0.1 path when data is an hs_data() bundle with a",
      "pedigree component (Gaussian animal model, REML)."
    ),
    rep(
      paste(
        "Exported as an inert marker; hsquared() errors as planned, not",
        "implemented."
      ),
      17L
    ),
    rep(
      paste(
        "Roadmap syntax; the v0.1 animal() parser rejects trait and cov",
        "arguments."
      ),
      2L
    )
  )
}
