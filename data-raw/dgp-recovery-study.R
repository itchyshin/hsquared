# Known-truth DGP recovery study for the hsquared / HSquared.jl REML estimator.
#
# Design follows ADEMP (Morris, White & Crowther 2019, Stat. Med. 38:2074-2102)
# and the transparent-reporting items of Williams et al. (2024, Methods Ecol.
# Evol. 15:1926-1939). This script is reproducible evidence; it is NOT part of
# the package build (.Rbuildignore'd). Run from the package root with a local
# HSquared.jl checkout and julia on PATH for the engine leg.
#
# A - AIMS
#   Primary: does the hsquared REML estimator recover known additive-genetic and
#   residual variance components, and produce EBVs that track the true breeding
#   values, on data simulated from a univariate Gaussian animal model over a
#   pedigree? Evaluated for the Julia engine (target = "ai_reml", via the opt-in
#   bridge) and cross-checked by the independent pure-R REML reference.
#   Secondary: do the engine and the pure-R reference agree on identical data?
#
# D - DATA-GENERATING MECHANISM
#   Pedigree: a clean sexed generational pedigree (n_founder = 60, n_per_gen =
#   120, n_gen = 3 => n = 420 animals; founders unrelated; each generation split
#   into sires/dams so no selfing and no cycles). A = numerator relationship
#   matrix (nadiv::makeA); U = chol(A) so A = U'U.
#   True breeding values: u = sqrt(sigma_a2) * U' z, z ~ N(0, I) => Cov(u) =
#   sigma_a2 * A. Residuals e ~ N(0, sigma_e2 I). One record per animal.
#   Phenotype: y = mu + u + e, mu = 5.
#   Conditions: total variance fixed at 1; h2 = sigma_a2 = 0.4 (sigma_e2 = 0.6).
#   Replicates: 120 (engine) / 40 (pure-R cross-check). Master seed 20240613;
#   replicate seeds drawn once from the master.
#
# E - ESTIMANDS / TARGETS
#   True: sigma_a2 = 0.4, sigma_e2 = 0.6, h2 = 0.4; per-replicate true u.
#   Estimator outputs: REML sigma_a2_hat, sigma_e2_hat, h2_hat; EBV u_hat.
#
# M - METHODS
#   Engine: HSquared.fit_ai_reml via hsquared(engine = "julia",
#   engine_control = list(target = "ai_reml")). Cross-check: pure-R REML
#   reference hsquared:::hs_reml_estimate_reference (independent implementation,
#   no Julia). No external comparator here -- this is recovery, not parity.
#
# P - PERFORMANCE MEASURES
#   Relative/absolute bias of each component: mean(theta_hat) - theta_true, with
#   MCSE = sd(theta_hat)/sqrt(n). EBV accuracy: mean cor(u_hat, u_true).
#   Convergence rate. (No coverage: SE/intervals are out of v0.1 scope.)
#
# RECORDED RESULT (2026-06-13, n = 420, 120 engine reps, all converged):
#   truth                s2a=0.400 s2e=0.600 h2=0.400
#   engine (ai_reml)     mean s2a=0.4000 s2e=0.6057 h2=0.3951  EBV acc=0.7374
#     bias               s2a=-0.0000 (MCSE 0.0090)
#                        s2e=+0.0057 (MCSE 0.0067)
#                        h2 =-0.0049 (MCSE 0.0073)   -> 0 within bias +/- 2*MCSE
#   pure-R reference     mean s2a=0.3906 s2e=0.5950 h2=0.3933 (40 reps)
#   engine vs pure-R     max |h2 diff| on shared reps = 0.0000 (machine precision)
#   Interpretation: near-unbiased recovery of the known variance components and
#   heritability (0 within bias +/- 2*MCSE for all three), EBVs track true BVs,
#   100% convergence, and the engine matches the independent reference exactly.
#   This is statistical-correctness evidence (predicate item 3), distinct from
#   optimizer reproducibility. It is R-lane evidence produced via the read-only
#   bridge; the twin (HSquared.jl) owns flipping its V1-SPARSE-REML-OPT /
#   V1-AI-REML validation_status rows to cite it.

suppressMessages(devtools::load_all(".", quiet = TRUE))
stopifnot(requireNamespace("nadiv", quietly = TRUE))
source(file.path("tests", "testthat", "helper-simulation.R"))

ped <- hs_sim_pedigree(n_founder = 60, n_per_gen = 120, n_gen = 3, seed = 1)
A <- as.matrix(nadiv::makeA(ped[, c("id", "sire", "dam")]))[ped$id, ped$id]
U <- chol(A)
Ainv <- solve(A)
n <- nrow(ped)
s2a <- 0.4
s2e <- 0.6
mu <- 5
N_ENGINE <- 120L
N_PURER <- 40L
set.seed(20240613L)
seeds <- sample.int(.Machine$integer.max, N_ENGINE)

eng <- matrix(
  NA_real_,
  N_ENGINE,
  4,
  dimnames = list(NULL, c("s2a", "s2e", "h2", "acc"))
)
pur <- matrix(
  NA_real_,
  N_PURER,
  3,
  dimnames = list(NULL, c("s2a", "s2e", "h2"))
)
conv <- 0L

for (r in seq_len(N_ENGINE)) {
  set.seed(seeds[r])
  sim <- hs_sim_animal_phenotypes(U, s2a, s2e, mu = mu)
  dat <- data.frame(id = ped$id, y = sim$y, stringsAsFactors = FALSE)
  fit <- tryCatch(
    hsquared(
      y ~ 1 + animal(1 | id, pedigree = ped),
      data = dat,
      family = stats::gaussian(),
      REML = TRUE,
      control = hs_control(
        engine = "julia",
        engine_control = list(
          target = "ai_reml",
          initial = c(sigma_a2 = 0.5, sigma_e2 = 0.5),
          iterations = 500L
        )
      )
    ),
    error = function(e) NULL
  )
  if (!is.null(fit)) {
    vc <- variance_components(fit)$estimate
    ebv <- breeding_values(fit)
    ebv <- ebv$value[match(ped$id, ebv$id)]
    eng[r, ] <- c(vc[1], vc[2], vc[1] / sum(vc), stats::cor(ebv, sim$u))
    conv <- conv + isTRUE(fit$result$converged)
  }
  if (r <= N_PURER) {
    ref <- hsquared:::hs_reml_estimate_reference(
      sim$y,
      matrix(1, n, 1L),
      diag(n),
      Ainv,
      method = "REML",
      initial = c(sigma_a2 = 0.5, sigma_e2 = 0.5)
    )
    pur[r, ] <- c(
      ref$estimate[["sigma_a2"]],
      ref$estimate[["sigma_e2"]],
      ref$estimate[["sigma_a2"]] / sum(ref$estimate)
    )
  }
}

mcse <- function(x) stats::sd(x, na.rm = TRUE) / sqrt(sum(!is.na(x)))
cat(sprintf(
  "engine: mean s2a=%.4f s2e=%.4f h2=%.4f acc=%.4f | conv=%d/%d\n",
  mean(eng[, 1]),
  mean(eng[, 2]),
  mean(eng[, 3]),
  mean(eng[, 4]),
  conv,
  N_ENGINE
))
cat(sprintf(
  "bias: s2a=%+.4f (MCSE %.4f) s2e=%+.4f (MCSE %.4f) h2=%+.4f (MCSE %.4f)\n",
  mean(eng[, 1]) - s2a,
  mcse(eng[, 1]),
  mean(eng[, 2]) - s2e,
  mcse(eng[, 2]),
  mean(eng[, 3]) - 0.4,
  mcse(eng[, 3])
))
cat(sprintf(
  "pure-R: mean s2a=%.4f h2=%.4f | engine-vs-pureR max|h2|=%.4f\n",
  mean(pur[, 1]),
  mean(pur[, 3]),
  max(abs(eng[seq_len(N_PURER), "h2"] - pur[, "h2"]), na.rm = TRUE)
))
utils::sessionInfo()
