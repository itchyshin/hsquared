# Known-truth recovery study for cbind() + permanent() (hsquared #237).
# Companion to HSquared.jl sim/phase4_multivariate_repeatability_recovery.jl.
#
# Design follows ADEMP (Morris, White & Crowther 2019). Not part of the
# package build (.Rbuildignore'd). Experimental 0.9.0; public_covered_count
# stays 7; this script does not flip a covered row.
#
# A - AIMS
#   Does fit_multivariate_repeatability_reml recover known unstructured G0,
#   P0, and R0 plus per-trait repeatability t, without falling back to
#   animal-only fit_multivariate_reml (which absorbs V_PE into G0)?
#
# D - DATA-GENERATING MECHANISM
#   Half-sib pedigree: 8 sires / 16 dams / 48 offspring, 4 records each.
#   ua ~ N(0, G0 (x) A), upe ~ N(0, P0 (x) I), E ~ N(0, R0 (x) I).
#   Truth: G0 = [[1.0, 0.3], [0.3, 0.8]], P0 = [[0.5, 0.1], [0.1, 0.4]],
#   R0 = [[0.8, 0.15], [0.15, 0.7]].
#
# E - ESTIMANDS
#   Unique G0/P0/R0 elements and per-trait t_k = (Gkk+Pkk)/(Gkk+Pkk+Rkk).
#
# M - METHODS
#   Official screen is the Julia harness (8 seeds 20260926:20260933,
#   warm start at truth, |bias| <= 2*MCSE). This R script records one
#   live cbind()+permanent() fit on seed 20260926 so the R surface is
#   exercised. It must call multivariate_repeatability, never
#   multivariate_reml.
#
# P - PERFORMANCE
#   Screening: |mean(hat)-true| <= 2 * sd(hat)/sqrt(m) on converged seeds.
#   One-seed R fit: finite G11/P11 and target label only.
#
# To run:
#   julia --project=/path/to/HSquared.jl \
#     /path/to/HSquared.jl/sim/phase4_multivariate_repeatability_recovery.jl
#   Rscript data-raw/multivariate-repeatability-recovery-study.R

suppressWarnings(suppressMessages({
  library(hsquared)
}))

jl_wt <- Sys.getenv(
  "HSQUARED_JULIA_PROJECT",
  unset = path.expand("~/local-scratch/lanes/HSquared.jl-237-recovery")
)
if (dir.exists(jl_wt)) {
  Sys.setenv(HSQUARED_JULIA_PROJECT = jl_wt)
}

source("tests/testthat/helper-simulation.R")
source("tests/testthat/helper-237-mvpe.R")

if (!isTRUE(hsquared:::hs_julia_bridge_available())) {
  stop(
    "Need JuliaCall + julia + HSquared.jl for this recovery study.",
    call. = FALSE
  )
}
hsquared:::hs_julia_setup(hsquared:::hs_default_julia_project())
if (!isTRUE(JuliaCall::julia_eval(
  "isdefined(HSquared, :fit_multivariate_repeatability_reml)"
))) {
  stop("Need fit_multivariate_repeatability_reml (HSquared.jl#398).", call. = FALSE)
}

fx <- hs_237_simulate_mvpe(seed = 20260926L)
fit <- suppressWarnings(hs_237_fit_mvpe(fx))
stopifnot(identical(fit$spec$target, "multivariate_repeatability"))
stopifnot(identical(
  fit$result$diagnostics$target,
  "multivariate_repeatability_reml"
))
stopifnot(!identical(fit$result$diagnostics$target, "multivariate_reml"))

g11 <- hs_237_vc_diag(fit, "animal", "y1")
p11 <- hs_237_vc_diag(fit, "permanent", "y1")
r11 <- hs_237_vc_diag(fit, "residual", "y1")
cat("R_LIVE_MVPE_RECOVERY\n")
cat(sprintf("target=%s\n", fit$result$diagnostics$target))
cat(sprintf("G11=%.4f (truth 1.00)\n", g11))
cat(sprintf("P11=%.4f (truth 0.50)\n", p11))
cat(sprintf("R11=%.4f (truth 0.80)\n", r11))
cat(
  "Official 8-seed |bias|<=2*MCSE screen is the Julia harness ",
  "sim/phase4_multivariate_repeatability_recovery.jl (GATE_PASS/FAIL is data).\n",
  sep = ""
)
