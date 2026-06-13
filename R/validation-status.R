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
    "Mrode-style supplied-variance outputs",
    "experimental sparse REML estimator (opt-in)",
    "experimental AI-REML estimator (opt-in)",
    "external published-REML recovery (gryphon, R reference)",
    "known-truth DGP variance-component recovery (R reference)",
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
    rep("Phase 1", 12L),
    rep("Phase 5+", 2L),
    "Phase 6",
    "Phase 7+"
  )
}

hs_validation_status_status <- function() {
  c(
    rep("partial", 9L),
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
    paste(
      "Local R reference tests and optional live Julia tests pin a",
      "Mrode-style supplied-variance fixture for Ainv, fixed effects, EBVs,",
      "fitted values, PEV, reliability, h2, ML logLik, and REML logLik."
    ),
    paste(
      "Pure-R control/validator tests plus a skip-guarded live test running",
      "Julia fit_sparse_reml() through the opt-in target = \"sparse_reml\"",
      "bridge; checks positive estimated variances, finite REML logLik, and",
      "h2 in (0, 1) on the Mrode fixture; fit provenance tagged",
      "variance_components_source = \"estimated_sparse_reml\". Cross-checked",
      "against the dense REML optimizer, an independent pure-R REML optimizer,",
      "and the external pedigreemm package (at least as good by REML logLik)."
    ),
    paste(
      "Pure-R control/validator tests plus a skip-guarded live test running",
      "Julia fit_ai_reml() through the opt-in target = \"ai_reml\" bridge;",
      "checks positive estimated variances, finite REML logLik, and h2 in",
      "(0, 1) on the Mrode fixture; fit provenance tagged",
      "variance_components_source = \"estimated_ai_reml\". Cross-checked to reach",
      "the same REML optimum as the sparse REML optimizer."
    ),
    paste(
      "A skip-guarded test recovers the published gryphon birth-weight REML",
      "variance components and h2 (Wilson et al. 2010) with hsquared's",
      "independent pure-R REML reference, and optionally agrees with the external",
      "sommer package, on the gryphon dataset (CRAN package enhancer)."
    ),
    paste(
      "An ADEMP recovery study (data-raw/dgp-recovery-study.R) simulates from",
      "known variance components over a clean pedigree; the engine (ai_reml) is",
      "near-unbiased (0 within bias +/- 2*MCSE for sigma_a2, sigma_e2, h2 over",
      "120 reps, 100% converged), EBVs track true breeding values (acc ~0.74),",
      "and the engine matches the independent pure-R reference to machine",
      "precision. Recovery is near-unbiased across an h2 grid (0.2/0.4/0.6); the",
      "near-boundary cell (h2 = 0.1) shows mild upward bias, 94% convergence, and",
      "5% boundary pinning. Recovery also holds for the contract model with a",
      "fixed effect (y ~ x + animal): h2 near-unbiased and the fixed effect",
      "recovered (b_x 0.99 vs 1.0). A skip-guarded pure-R regression test guards",
      "a small-N case."
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
    paste(
      "Supplied-variance validation fixture only; not variance-component",
      "estimation, ASReml parity, or general fitted Mrode output coverage."
    ),
    paste(
      "Experimental opt-in path only; Julia-owned estimator that R surfaces;",
      "gated on twin validation_status; not the default, not production sparse",
      "fitting, AI-REML, or ASReml parity."
    ),
    paste(
      "Experimental opt-in path only; Julia-owned average-information REML",
      "estimator that R surfaces; gated on twin validation_status; not the",
      "default, not production sparse fitting, or ASReml parity."
    ),
    paste(
      "External-anchor cross-check of the pure-R REML reference only; not the",
      "production fit path and does not satisfy the twin-owned V1-MRODE-FIT gate;",
      "gryphon is teaching/simulated data, confirm headline numbers before any",
      "promotion."
    ),
    paste(
      "Known-truth recovery evidence for the estimator; R-lane study via the",
      "read-only bridge. Does not itself flip the twin-owned estimator gate row",
      "(V1-SPARSE-REML-OPT / V1-AI-REML); single h2 = 0.4 setting; no boundary,",
      "interval, or production-robustness claim."
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
