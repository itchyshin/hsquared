# Bayesian agreement probe for the hsquared / HSquared.jl MULTIVARIATE (t = 2)
# REML fixture, using MCMCglmm.
#
# Companion to:
#   - data-raw/multivariate-recovery-study.R
#   - data-raw/multivariate-comparator-study.R
#
# TARGET. The deterministic two-trait animal-model target serialized by the
# twin at tests/testthat/fixtures/phase4_multitrait_parity/. That target is a
# Gaussian REML estimate from HSquared.jl on 20 animals, 80 records, one fixed
# covariate x, and full unstructured G0/R0.
#
# COMPARATOR TYPE. MCMCglmm is a Bayesian MCMC animal-model package. This script
# is therefore an AGREEMENT probe only. It is not a same-estimand REML comparator.
# It does not replace the needed ASReml/BLUPF90/DMU/WOMBAT-style REML leg, and it
# must not promote V4-MV-REML beyond partial.
# Boundary tag: not a same-estimand REML comparator.
#
# MODEL.
#   cbind(trait1, trait2) ~ trait - 1 + trait:x
#   random = ~ us(trait):animal
#   rcov   = ~ us(trait):units
#
# RECORDED RESULT (MCMCglmm 2.36; seed 20260621; 2026-06-21):
#   nitt = 50000, burnin = 10000, thin = 40, posterior samples = 1000.
#   Prior: weak inverse-Wishart scale V = diag(2) * 0.02, nu = 3.
#   The HSquared.jl serialized target is inside the 95% HPD interval for all
#   8 covariance elements, all 4 fixed effects, and both per-trait h2 values.
#   Posterior-mean agreement:
#     max |dG0|   = 0.0385
#     max |dR0|   = 0.00647
#     max |dbeta| = 0.00697
#     max |dh2|   = 0.0253
#     EBV correlations: trait1 = 0.9998, trait2 = 0.9997
#     max |dEBV| = 0.0458
#     min effective sample size: VCV = 777, Sol = 867
#   These are MCMC posterior summaries under a weak inverse-Wishart prior, not
#   optimizer tolerance-scale REML parity.
#
# To run:
#   Rscript data-raw/multivariate-mcmcglmm-agreement-study.R

suppressWarnings(suppressMessages({
  library(MCMCglmm)
  library(coda)
}))

fx <- "tests/testthat/fixtures/phase4_multitrait_parity"
if (!dir.exists(fx)) {
  fx <- "../HSquared.jl/test/fixtures/phase4_multitrait_parity"
}
stopifnot(dir.exists(fx))

read_cov <- function(file) {
  mat <- as.matrix(read.csv(file.path(fx, file), row.names = 1L))
  storage.mode(mat) <- "double"
  dimnames(mat) <- list(c("trait1", "trait2"), c("trait1", "trait2"))
  mat
}

G0_target <- read_cov("expected_genetic_covariance.csv")
R0_target <- read_cov("expected_residual_covariance.csv")
beta_target <- read.csv(file.path(fx, "expected_beta.csv"))
h2_target <- read.csv(file.path(fx, "expected_heritability.csv"))
ebv_target <- read.csv(file.path(fx, "expected_ebv.csv"))

ped <- read.csv(file.path(fx, "pedigree.csv"), stringsAsFactors = FALSE)
ped[ped == "0"] <- NA
colnames(ped) <- c("animal", "sire", "dam")
ped[] <- lapply(ped, as.factor)

phe <- read.csv(file.path(fx, "phenotypes.csv"), stringsAsFactors = FALSE)
phe$animal <- factor(phe$animal, levels = as.character(ped$animal))

prior <- list(
  G = list(G1 = list(V = diag(2) * 0.02, nu = 3)),
  R = list(V = diag(2) * 0.02, nu = 3)
)

set.seed(20260621)
fit <- MCMCglmm::MCMCglmm(
  cbind(trait1, trait2) ~ trait - 1 + trait:x,
  random = ~ us(trait):animal,
  rcov = ~ us(trait):units,
  family = c("gaussian", "gaussian"),
  data = phe,
  pedigree = ped,
  prior = prior,
  nitt = 50000,
  burnin = 10000,
  thin = 40,
  verbose = FALSE,
  pr = TRUE
)

vcv_mean <- colMeans(fit$VCV)
vcv_hpd <- coda::HPDinterval(fit$VCV)

cov_matrix <- function(component) {
  matrix(
    c(
      vcv_mean[paste0("traittrait1:traittrait1.", component)],
      vcv_mean[paste0("traittrait2:traittrait1.", component)],
      vcv_mean[paste0("traittrait1:traittrait2.", component)],
      vcv_mean[paste0("traittrait2:traittrait2.", component)]
    ),
    nrow = 2L,
    byrow = TRUE,
    dimnames = list(c("trait1", "trait2"), c("trait1", "trait2"))
  )
}

G0_hat <- cov_matrix("animal")
R0_hat <- cov_matrix("units")
h2_hat <- diag(G0_hat) / (diag(G0_hat) + diag(R0_hat))

sol_mean <- colMeans(fit$Sol)
sol_hpd <- coda::HPDinterval(fit$Sol)
beta_cols <- c(
  trait1_Intercept = "traittrait1",
  trait1_x = "traittrait1:x",
  trait2_Intercept = "traittrait2",
  trait2_x = "traittrait2:x"
)
beta_hat <- c(
  trait1_Intercept = unname(sol_mean[beta_cols[["trait1_Intercept"]]]),
  trait1_x = unname(sol_mean[beta_cols[["trait1_x"]]]),
  trait2_Intercept = unname(sol_mean[beta_cols[["trait2_Intercept"]]]),
  trait2_x = unname(sol_mean[beta_cols[["trait2_x"]]])
)
beta_target_vec <- c(
  trait1_Intercept = beta_target$trait1[beta_target$effect == "Intercept"],
  trait1_x = beta_target$trait1[beta_target$effect == "x"],
  trait2_Intercept = beta_target$trait2[beta_target$effect == "Intercept"],
  trait2_x = beta_target$trait2[beta_target$effect == "x"]
)

animals <- as.character(ped$animal)
ebv_hat <- cbind(
  trait1 = unname(sol_mean[paste0("traittrait1.animal.", animals)]),
  trait2 = unname(sol_mean[paste0("traittrait2.animal.", animals)])
)
rownames(ebv_hat) <- animals
ebv_hat <- ebv_hat[ebv_target$animal, ]

h2_samples <- cbind(
  trait1 = fit$VCV[, "traittrait1:traittrait1.animal"] /
    (fit$VCV[, "traittrait1:traittrait1.animal"] +
      fit$VCV[, "traittrait1:traittrait1.units"]),
  trait2 = fit$VCV[, "traittrait2:traittrait2.animal"] /
    (fit$VCV[, "traittrait2:traittrait2.animal"] +
      fit$VCV[, "traittrait2:traittrait2.units"])
)
h2_hpd <- coda::HPDinterval(coda::as.mcmc(h2_samples))

inside_interval <- function(value, interval) {
  value >= interval[[1L]] && value <= interval[[2L]]
}
row_intervals <- function(mat, rows) {
  lapply(rows, function(row) mat[row, ])
}

target_checks <- c(
  setNames(
    mapply(
      inside_interval,
      as.vector(G0_target),
      row_intervals(
        vcv_hpd,
        c(
          "traittrait1:traittrait1.animal",
          "traittrait2:traittrait1.animal",
          "traittrait1:traittrait2.animal",
          "traittrait2:traittrait2.animal"
        )
      )
    ),
    paste0("G0_", c("11", "21", "12", "22"))
  ),
  setNames(
    mapply(
      inside_interval,
      as.vector(R0_target),
      row_intervals(
        vcv_hpd,
        c(
          "traittrait1:traittrait1.units",
          "traittrait2:traittrait1.units",
          "traittrait1:traittrait2.units",
          "traittrait2:traittrait2.units"
        )
      )
    ),
    paste0("R0_", c("11", "21", "12", "22"))
  ),
  setNames(
    mapply(
      inside_interval,
      beta_target_vec,
      row_intervals(sol_hpd, unname(beta_cols))
    ),
    paste0("beta_", names(beta_hat))
  ),
  setNames(
    mapply(
      inside_interval,
      h2_target$h2,
      row_intervals(h2_hpd, h2_target$trait)
    ),
    paste0("h2_", h2_target$trait)
  )
)

results <- list(
  `max|dG0|` = max(abs(G0_hat - G0_target)),
  `max|dR0|` = max(abs(R0_hat - R0_target)),
  `max|dbeta|` = max(abs(beta_hat - beta_target_vec)),
  `max|dh2|` = max(abs(h2_hat - h2_target$h2)),
  `cor_EBV_trait1` = cor(ebv_hat[, 1], ebv_target$trait1),
  `cor_EBV_trait2` = cor(ebv_hat[, 2], ebv_target$trait2),
  `max|dEBV|` = max(abs(
    ebv_hat - as.matrix(ebv_target[, c("trait1", "trait2")])
  )),
  `min_ESS_VCV` = min(coda::effectiveSize(fit$VCV)),
  `min_ESS_Sol` = min(coda::effectiveSize(fit$Sol)),
  `targets_inside_95_HPD` = all(target_checks)
)

cat(
  "=== MCMCglmm",
  as.character(packageVersion("MCMCglmm")),
  "Bayesian agreement probe vs HSquared.jl multivariate target ===\n"
)
cat("G0 posterior mean:\n")
print(round(G0_hat, 6))
cat("G0 target:\n")
print(round(G0_target, 6))
cat("R0 posterior mean:\n")
print(round(R0_hat, 6))
cat("R0 target:\n")
print(round(R0_target, 6))
cat("h2 posterior mean:", round(h2_hat, 6), "\n")
cat("h2 target:", round(h2_target$h2, 6), "\n")
cat("\nTarget inside 95% HPD checks:\n")
print(target_checks)
cat("\nAgreement summary:\n")
for (nm in names(results)) {
  value <- results[[nm]]
  if (is.logical(value)) {
    cat(sprintf("  %-24s %s\n", nm, value))
  } else {
    cat(sprintf("  %-24s %.4g\n", nm, value))
  }
}

invisible(results)
