#' Inspect validation evidence status
#'
#' `validation_status()` reports the current validation atoms and planned
#' comparator lanes for `hsquared`. It is a status table only: it does not run
#' validation checks, fit models, or promote any capability to working status.
#'
#' @return A data frame of validation status records with class
#'   `"hs_validation_status"`.
#' @export
validation_status <- function() {
  out <- data.frame(
    capability = hs_validation_status_capabilities(),
    phase = hs_validation_status_phases(),
    status = hs_validation_status_status(),
    evidence = hs_validation_status_evidence(),
    claim_boundary = hs_validation_status_boundaries(),
    stringsAsFactors = FALSE
  )
  class(out) <- c("hs_validation_status", class(out))
  out
}

#' @export
print.hs_validation_status <- function(x, ...) {
  cat("<hs_validation_status>\n")
  cat("  validation: status table only; checks are run by tests and CI\n")
  cat("  public claims: only `covered` rows may be advertised as working\n")
  out <- x
  class(out) <- setdiff(class(out), "hs_validation_status")
  print.data.frame(
    out[c("capability", "phase", "status")],
    row.names = FALSE
  )
  invisible(x)
}

hs_validation_status_capabilities <- function() {
  c(
    "tiny deterministic Ainv fixture",
    "Mrode9 pedigree Ainv comparator",
    "supplied-variance Henderson MME fixture",
    "sparse REML likelihood identity",
    "Mrode fitted animal-model outputs",
    "ASReml comparison policy",
    "BLUPF90/DMU/WOMBAT comparison policy",
    "XSim simulation truth",
    "genomic and QTL/eQTL validation",
    "GLLVM-style multivariate validation",
    "CPU/GPU backend comparison"
  )
}

hs_validation_status_phases <- function() {
  c(
    rep("Phase 1", 7L),
    rep("Phase 5+", 2L),
    "Phase 6",
    "Phase 7+"
  )
}

hs_validation_status_status <- function() {
  c(
    rep("partial", 4L),
    rep("planned", 7L)
  )
}

hs_validation_status_evidence <- function() {
  c(
    paste(
      "Local tests pin R payload ordering, sparse Z, and live Julia",
      "pedigree_inverse() agreement when HSquared.jl is available."
    ),
    paste(
      "Optional local tests compare Julia pedigree_inverse() with",
      "nadiv::makeAinv() for nadiv::Mrode9 when optional dependencies are",
      "available."
    ),
    paste(
      "Local R reference solve and optional live Julia henderson_mme()",
      "comparison for fixed effects, EBVs, fitted values, h2, and optional",
      "dense validation-path PEV/reliability."
    ),
    paste(
      "Optional local tests compare Julia gaussian_loglik() dense REML and",
      "sparse_reml_loglik() on a tiny three-founder fixture at supplied",
      "variance components, with ML and REML hand-check targets."
    ),
    "None yet.",
    "None yet.",
    "None yet.",
    "None yet.",
    "None yet.",
    "None yet.",
    "None yet."
  )
}

hs_validation_status_boundaries <- function() {
  c(
    "Internal tiny Ainv atom only; not production fitting or Mrode coverage.",
    "Pedigree inverse comparator only; not fitted Mrode outputs.",
    paste(
      "Supplied-variance BLUP/MME only; not variance-component estimation,",
      "AI-REML, production sparse reliability, or production sparse fitting."
    ),
    paste(
      "Supplied-variance likelihood identity only; not a sparse optimizer,",
      "AI-REML, fitted Mrode output validation, or production sparse fitting."
    ),
    "Planned; no Mrode fitted-output claim.",
    "Planned; no ASReml parity claim.",
    "Planned; no external production-software parity claim.",
    "Planned; no simulation-recovery claim.",
    "Planned; no genomic, QTL, eQTL, or marker-scan claim.",
    "Planned; no GLLVM-style animal-model validation claim.",
    "Planned; no backend execution, benchmark, or speedup claim."
  )
}
