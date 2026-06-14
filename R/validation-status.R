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
    "experimental repeatability estimator (opt-in)",
    "experimental two-effect estimator (opt-in: common-env, maternal)",
    "experimental supplied-relationship estimator (opt-in: genomic, single-step)",
    "univariate Gaussian animal-model fit (default path, AI-REML)",
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
    rep("Phase 1", 6L),
    rep("Phase 2", 2L),
    "Phase 5",
    rep("Phase 1", 6L),
    rep("Phase 5+", 2L),
    "Phase 6",
    "Phase 7+"
  )
}

hs_validation_status_status <- function() {
  c(
    rep("partial", 9L),
    rep("covered", 3L),
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
      "Julia fit_repeatability_reml() through the opt-in target =",
      "\"repeatability\" bridge on a repeated-records fixture; checks three",
      "positive estimated variance components (animal, permanent, residual),",
      "repeatability in (0, 1), heritability in [0, 1), permanent-environment",
      "effects, and finite REML logLik; fit provenance tagged",
      "variance_components_source = \"estimated_repeatability_reml\". The",
      "permanent-environment effect shares the animal incidence (A2 = I)."
    ),
    paste(
      "Pure-R control/validator tests plus skip-guarded live tests running Julia",
      "fit_two_effect_reml() through the opt-in target = \"two_effect\" bridge on",
      "`animal(1 | id) + common_env(1 | group)` (IID environment, A2 = I) and on",
      "`animal(1 | id) + maternal_genetic(1 | dam)` (maternal genetic effect, A2 =",
      "pedigree A); each checks three positive estimated variance components",
      "(animal, second effect, residual), heritability in [0, 1), the second-effect",
      "predictions, and finite REML logLik; fit provenance tagged",
      "variance_components_source = \"estimated_two_effect_reml\"."
    ),
    paste(
      "Pure-R control/validator tests plus skip-guarded live tests running Julia",
      "fit_ai_reml() on a user-supplied relationship inverse through the opt-in",
      "bridge: target = \"genomic\" on `genomic(1 | id, Ginv = Ginv)` (a genomic",
      "relationship inverse) and target = \"single_step\" on",
      "`single_step(1 | id, Hinv = Hinv)` (a single-step relationship inverse);",
      "each checks two positive estimated variance components (effect, residual),",
      "heritability in (0, 1), breeding values, and finite REML logLik; fit",
      "provenance tagged variance_components_source =",
      "\"estimated_<genomic|single_step>_ai_reml\". The user supplies the inverse;",
      "building it from markers/pedigree is planned."
    ),
    paste(
      "The default `hsquared()` control fits the v0.1 Gaussian animal model by",
      "average-information REML (`fit_ai_reml`) on the sparse MME through the",
      "bridge. A skip-guarded live test fits the contract through the default",
      "control and checks positive estimated variances, finite REML logLik, and",
      "h2 in (0, 1) on the Mrode fixture; fit provenance tagged",
      "variance_components_source = \"estimated_ai_reml\". The estimator reaches",
      "the same REML optimum as the sparse REML optimizer, and its known-truth",
      "and external-anchor recovery are evidenced in the two rows below. Mirrors",
      "the twin V1-AI-REML gate (covered)."
    ),
    paste(
      "A skip-guarded test recovers the published gryphon birth-weight REML",
      "variance components and h2 (Wilson et al. 2010) with hsquared's",
      "independent pure-R REML reference, and agrees with the external sommer",
      "package within the signed-off band (VC ~1-2%, h2 ~0.01-0.02), on the",
      "gryphon dataset (CRAN package enhancer). The Julia engine (fit_sparse_reml",
      "and fit_ai_reml) also recovers the published estimates within the",
      "signed-off band via supplied A_gryphon (the engine correctly rejects the",
      "pathological raw pedigree); engine-vs-pure-R agreement is to machine",
      "precision. Gryphon is the maintainer (2026-06-13) signed-off V1-MRODE-FIT",
      "anchor and sommer the V1-COMPARATORS comparator."
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
      "recovered (b_x 0.99 vs 1.0). Meets the maintainer-signed-off item-3",
      "thresholds (>= 100 reps, 0 within bias +/- 2*MCSE, mean cor(EBV, true) >=",
      "0.5). A skip-guarded pure-R regression test guards a small-N case."
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
      "Experimental opt-in path only; Julia-owned REML-only repeatability",
      "optimizer that R surfaces; mirrors the twin V3-REPEAT-REML gate",
      "(partial). Not the default, not ML, not production fitting, and not a",
      "comparator-validated or known-truth-recovery claim. The additive (Va) and",
      "permanent-environment (Vpe) variances are only identifiable with repeated",
      "records per individual."
    ),
    paste(
      "Experimental opt-in path only; Julia-owned REML-only two-effect optimizer",
      "that R surfaces; mirrors the twin V3-TWOEFFECT-REML gate (partial). Not",
      "the default, not ML, not production fitting, and not a comparator-validated",
      "or known-truth-recovery claim. Two INDEPENDENT random effects (additive +",
      "either an IID common-environment effect via common_env() or a pedigree",
      "maternal genetic effect via maternal_genetic()); the correlated",
      "direct-maternal (2x2 G) model is planned."
    ),
    paste(
      "Experimental opt-in path only; Julia-owned REML estimator (fit_ai_reml on",
      "a relationship-inverse spec) that R surfaces; mirrors the twin V2-GREML",
      "(genomic) and V2-SSHINV (single-step) gates (partial). The user supplies",
      "the genomic Ginv / single-step Hinv; building them from markers/pedigree,",
      "low-rank m>>n solves, and AGHmatrix/sommer/BLUPF90 comparator parity are",
      "planned. Not the default, not ML, not production or comparator-validated."
    ),
    paste(
      "Univariate Gaussian animal model only (single additive genetic effect);",
      "REML only (ML is rejected on the fit path); multivariate, genomic,",
      "repeated-records, and non-Gaussian fitting remain planned. Mirrors the",
      "twin-owned V1-AI-REML gate (covered); not ASReml multi-trait parity."
    ),
    paste(
      "Published-anchor recovery within the maintainer-signed-off band (not",
      "bit-exact); backs the twin-owned V1-MRODE-FIT gate (covered_external).",
      "Gryphon is teaching data; confirm headline numbers before any new",
      "promotion."
    ),
    paste(
      "Known-truth recovery evidence for the default AI-REML estimator; R-lane",
      "ADEMP study via the read-only bridge across an h2 grid (0.2/0.4/0.6) plus",
      "a near-boundary cell (h2 = 0.1) and a fixed-effect model; backs the",
      "twin-owned V1-AI-REML gate (covered). No interval-coverage or",
      "production-robustness claim beyond the studied grid."
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
