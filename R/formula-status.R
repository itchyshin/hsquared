#' Inspect formula grammar status
#'
#' `formula_status()` reports which pieces of the planned `hsquared()` formula
#' language are parsed today, reserved as syntax markers, or still roadmap-only.
#' It is a status table, not a model-fitting helper.
#'
#' @return A data frame of formula grammar records with class
#'   `"hs_formula_status"`.
#' @examples
#' formula_status()
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
  cat(
    "permanent/common_env/maternal_genetic/genomic/multivariate fit opt-in\n"
  )
  cat(
    "  planned grammar: rows marked planned/reserved error before fitting\n"
  )
  out <- x
  class(out) <- setdiff(class(out), "hs_formula_status")
  display_cols <- intersect(
    c("term", "phase", "syntax_status", "fitting_status"),
    names(out)
  )
  if (length(display_cols) == 0L) {
    display_cols <- names(out)
  }
  print.data.frame(
    out[display_cols],
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
    "maternal_genetic(1 | dam)",
    "animal(rr(covariate, order = 2) | id, pedigree = ped)",
    "maternal_env(1 | dam)",
    "paternal_genetic(1 | sire, pedigree = ped)",
    "paternal_env(1 | sire)",
    "group(1 | genetic_group)",
    "unknown_parent_group(1 | upg)",
    "metafounder(1 | id, pedigree = ped, group = group, Gamma = Gamma)",
    "inbreeding(1 | id)",
    "cytoplasmic(1 | maternal_line)",
    "imprinting(1 | id, pedigree = ped, parent = \"maternal\")",
    "dominance(1 | id, pedigree = ped)",
    "epistasis(1 | id, pedigree = ped)",
    "relmat(1 | id, K = K)",
    "precision(1 | id, Q = Q)",
    "genomic(1 | id, Ginv = Ginv)",
    "genomic(1 | id, markers = M)",
    "single_step(1 | id, Hinv = Hinv)",
    "single_step(1 | id, pedigree = ped, markers = M)",
    paste0(
      "single_step(1 | id, pedigree = ped, markers = M, group = group, ",
      "Gamma = Gamma)"
    ),
    "markers(M, model = \"random\")",
    "marker_scan(M, map = marker_map)",
    "qtl_scan(position, genotype_probs = probs)",
    "cbind(trait1, trait2) ~ animal(1 | id, pedigree = ped)",
    "animal(trait | id, pedigree = ped, cov = us())",
    "animal(trait | id, pedigree = ped, cov = diag())",
    "animal(trait | id, pedigree = ped, cov = lowrank(K = 2))",
    "animal(trait | id, pedigree = ped, cov = fa(K = 2))"
  )
}

hs_formula_status_categories <- function() {
  c(
    rep("v0.1 animal model", 2L),
    rep("standard quantitative genetics", 11L),
    rep("inheritance and relationship kernels", 6L),
    rep("genomic and marker models", 8L),
    rep("multivariate and factor analytic", 5L)
  )
}

hs_formula_status_phases <- function() {
  c(
    rep("Phase 1", 2L),
    rep("Phase 2", 11L),
    rep("Phase 3+", 6L),
    rep("Phase 5", 8L),
    rep("Phase 3-4", 5L)
  )
}

hs_formula_status_syntax <- function() {
  c(
    rep("parsed", 6L),
    rep("reserved", 5L),
    "parsed",
    rep("reserved", 7L),
    rep("parsed", 5L),
    rep("reserved", 3L),
    "parsed",
    rep("planned", 4L)
  )
}

hs_formula_status_fitting <- function() {
  c(
    rep("fitted (v0.1 default)", 2L),
    "fitted (opt-in repeatability)",
    "fitted (opt-in common-environment)",
    "fitted (opt-in maternal)",
    "fitted (opt-in random-regression)",
    rep("not available", 5L),
    "fitted (opt-in supplied-Gamma metafounder)",
    rep("not available", 7L),
    "fitted (opt-in genomic)",
    "fitted (opt-in genomic / SNP-BLUP)",
    "fitted (opt-in single-step)",
    "fitted (opt-in single-step construction)",
    "fitted (opt-in supplied-Gamma H^Gamma)",
    rep("not available", 3L),
    "fitted (opt-in multivariate)",
    rep("not available", 4L)
  )
}

hs_formula_status_behavior <- function() {
  inert_marker_text <- paste(
    "Exported as an inert marker; hsquared() errors as planned, not",
    "implemented."
  )
  c(
    paste(
      "Parsed and fitted by the default v0.1 path (Gaussian animal model,",
      "REML through the HSquared.jl engine)."
    ),
    paste(
      "Fitted by the default v0.1 path when data is an hs_data() bundle with a",
      "pedigree component (Gaussian animal model, REML)."
    ),
    paste(
      "Permanent-environment effect of the opt-in, experimental repeatability",
      "model; requires an animal() term, repeated records, and",
      "engine = \"julia\", target = \"repeatability\"."
    ),
    paste(
      "Common-environment effect of the opt-in, experimental two-effect model;",
      "requires an animal() term and engine = \"julia\", target = \"two_effect\"."
    ),
    paste(
      "Maternal genetic effect of the opt-in, experimental two-effect model (A2 =",
      "pedigree A via the dam); requires an animal() term and engine = \"julia\",",
      "target = \"two_effect\"."
    ),
    paste(
      "Opt-in, experimental random-regression (reaction-norm) model: rr(covariate,",
      "order = k) on the animal() left-hand side fits a k-coefficient normalized-",
      "Legendre polynomial of a within-individual covariate; requires repeated",
      "records and engine = \"julia\", target = \"random_regression\". PROVISIONAL",
      "grammar (HSquared.jl#61); homogeneous residual, no permanent-environment",
      "term yet."
    ),
    rep(inert_marker_text, 5L),
    paste(
      "Primary metafounder effect of the opt-in, experimental supplied-variance",
      "model; requires `group`, supplied `Gamma`, engine = \"julia\",",
      "target = \"metafounder\", and supplied variance components.",
      "`Gamma` and the variance components are supplied, not estimated."
    ),
    paste(
      "Exported as an inert marker; hsquared() errors as planned, not",
      "implemented. Inbreeding coefficients F are already computed internally",
      "for Ainv construction in the engine; this reserved term is the future",
      "user-facing F-as-effect surface, not yet fittable."
    ),
    rep(inert_marker_text, 6L),
    paste(
      "Primary genomic effect of the opt-in, experimental GREML model; requires",
      "a user-supplied `Ginv` and engine = \"julia\", target = \"genomic\"."
    ),
    paste(
      "Primary genomic effect of the opt-in, experimental SNP-BLUP model;",
      "requires a user-supplied marker matrix `markers` and engine = \"julia\",",
      "target = \"genomic\"."
    ),
    paste(
      "Primary single-step effect of the opt-in, experimental model; requires a",
      "user-supplied `Hinv` and engine = \"julia\", target = \"single_step\"."
    ),
    paste(
      "Primary single-step effect of the opt-in, experimental construction path;",
      "requires `pedigree` + `markers` or an hs_data() bundle carrying both, and",
      "engine = \"julia\", target = \"single_step_construct\". The engine builds",
      "H^-1 from pedigree and genotyped-subset markers at validation scale."
    ),
    paste(
      "Primary single-step effect of the opt-in, experimental supplied-Gamma",
      "H^Gamma path; validates ID-keyed metafounder `group`, supplied",
      "symmetric positive-semidefinite `Gamma`, marker ordering, and",
      "`genotyped_rows`, then fits with engine = \"julia\", target =",
      "\"metafounder_single_step\". `Gamma` is supplied, not estimated."
    ),
    rep(inert_marker_text, 3L),
    paste(
      "Experimental multivariate Gaussian animal model; requires a `cbind()`",
      "response, an `animal()` term, and engine = \"julia\", target =",
      "\"multivariate\". Missing trait cells are allowed as `NA`. Under",
      "`family = binomial()`, `cbind(successes, failures)` is instead a",
      "binomial-counts GLMM via target = \"nongaussian\" (equal row totals",
      "required), not a multivariate Gaussian."
    ),
    rep(
      paste(
        "Roadmap syntax for long-format structured covariance; the current",
        "parser rejects trait and `cov` arguments and points users to the",
        "opt-in `cbind()` multivariate path."
      ),
      4L
    )
  )
}
