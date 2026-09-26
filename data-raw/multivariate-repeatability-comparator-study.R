# External-comparator confrontation for cbind() + permanent() (hsquared #237)
# against sommer::mmer animal + identity PE + unstructured residual.
#
# Companion to data-raw/multivariate-repeatability-recovery-study.R and to
# data-raw/multivariate-comparator-study.R (animal-only, no PE).
# Experimental 0.9.0; public_covered_count stays 7; not a covered flip.
#
# MODEL. trait_k ~ 1 + animal_k + pe_k + residual_k, k = 1,2
#   vec(animal) ~ N(0, A (x) G0), vec(PE) ~ N(0, I (x) P0),
#   vec(residual) ~ N(0, I_record (x) R0).
#
# COMPARATOR. sommer::mmer AI-REML (sommer 4.4.5 has no exported ide()):
#   vsr(animal, Gu = A, Gtc = unsm(2)) +
#   vsr(pe, Gtc = unsm(2)) where pe copies id +
#   rcov vsr(units, Gtc = unsm(2)).
#
# CLAIM BOUNDARY. Agreement is external-comparator evidence only. The engine
# must stay on multivariate_repeatability; never fit_multivariate_reml.
#
# To run:  Rscript data-raw/multivariate-repeatability-comparator-study.R

suppressWarnings(suppressMessages({
  library(hsquared)
  library(sommer)
  library(nadiv)
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
  stop("Need JuliaCall + julia + HSquared.jl.", call. = FALSE)
}
hsquared:::hs_julia_setup(hsquared:::hs_default_julia_project())
if (!isTRUE(JuliaCall::julia_eval(
  "isdefined(HSquared, :fit_multivariate_repeatability_reml)"
))) {
  stop("Need fit_multivariate_repeatability_reml (HSquared.jl#398).", call. = FALSE)
}

fx <- hs_237_simulate_mvpe(seed = 20260926L)
engine <- suppressWarnings(hs_237_fit_mvpe(fx))
stopifnot(identical(engine$spec$target, "multivariate_repeatability"))
stopifnot(!identical(engine$result$diagnostics$target, "multivariate_reml"))

sm <- hs_237_sommer_mvpe(fx)
G_s <- sm$G0
P_s <- sm$P0
R_s <- sm$R0
stopifnot(!is.null(G_s), !is.null(P_s), !is.null(R_s))
G_e <- engine$result$genetic_covariance
P_e <- engine$result$permanent_covariance
R_e <- engine$result$residual_covariance

dG <- max(abs(G_s - G_e))
dP <- max(abs(P_s - P_e))
dR <- max(abs(R_s - R_e))
cat("R_LIVE_MVPE_COMPARATOR\n")
cat(sprintf("engine_target=%s\n", engine$result$diagnostics$target))
cat(sprintf("max_|dG0|=%.4f\n", dG))
cat(sprintf("max_|dP0|=%.4f\n", dP))
cat(sprintf("max_|dR0|=%.4f\n", dR))
cat(sprintf(
  "G11 engine=%.4f sommer=%.4f\n",
  G_e[1, 1],
  G_s[1, 1]
))
cat(sprintf(
  "P11 engine=%.4f sommer=%.4f\n",
  P_e[1, 1],
  P_s[1, 1]
))
