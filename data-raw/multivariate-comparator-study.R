# External-comparator confrontation for the hsquared / HSquared.jl MULTIVARIATE
# (t = 2) REML estimator, against `sommer::mmer`.
#
# Companion to data-raw/multivariate-recovery-study.R (known-truth recovery) and
# to vignettes/articles/benchmark-comparators.Rmd (univariate sommer/pedigreemm).
# This is reproducible evidence; it is NOT part of the package build
# (.Rbuildignore'd). It is the R-lane half of moving V4-MULTIVARIATE /
# V4-MV-REML from `partial` toward `covered` (hsquared #10/#49, twin
# HSquared.jl#47/#49): the engine half (no detectable bias + EBV accuracy + the
# serialized target) is recorded in the twin; this script confronts an
# independent established REML package against the SAME serialized target.
#
# TARGET. The deterministic two-trait animal-model target serialized by the twin
# at ../HSquared.jl/test/fixtures/phase4_multitrait_parity/ (the Julia REML
# `fit_multivariate_reml` estimate on a fixed dataset: 20 animals, 80 records =
# 4 records/animal, one shared fixed covariate `x`, unstructured G0 and R0). The
# target files (expected_*.csv) are read here; the comparator is run on the SAME
# pedigree + phenotypes and confronted against those targets. Per the fixture
# README, A is rebuilt from pedigree.csv (nadiv), NOT copied from Julia.
#
# MODEL.   trait_k ~ intercept_k + beta_x,k * x + animal_k + residual_k,  k = 1,2
#   vec(animal) ~ N(0, A (x) G0),  vec(residual) ~ N(0, I_record (x) R0).
#
# COMPARATOR. sommer::mmer (REML, average-information), unstructured G0 AND R0
#   via vsr(animal, Gu = A, Gtc = unsm(2)) and rcov = vsr(units, Gtc = unsm(2)).
#   API NOTE: the in-suite comparator (tests/testthat/test-multivariate.R) uses
#   the newer sommer::mmes interface with a DIAGONAL residual (dsm(trait)),
#   because mmes raises an Armadillo "index out of bounds" error on a full
#   UNSTRUCTURED residual in this records-within-animal layout. This study
#   deliberately uses the classic mmer interface, which DOES fit the unstructured
#   residual and so recovers the off-diagonal residual covariance R0[2,1] (engine
#   3.08e-04) that the diagonal in-suite check cannot reach -- that off-diagonal
#   recovery, plus the EBV confrontation, is the new evidence here.
#
# WHAT IS COMPARED. G0, R0, fixed effects (beta), per-trait h2, and EBVs. The
# REML log-likelihood is NOT compared: sommer and HSquared.jl report it on
# different additive-constant scales (fixture README step 5), so an equality
# check would be meaningless; only the estimates above are scale-invariant.
#
# CLAIM BOUNDARY. Agreement here is external-comparator EVIDENCE; it does NOT by
# itself promote V4-MV-REML to covered (the recovery gate is the other half, and
# promotion is twin-gated). No R-facing multivariate-syntax, bridge-payload, SE,
# LRT, or production-fitting claim follows from this script.
#
# RECORDED RESULT (sommer 4.4.5; macOS arm64; R 4.x; 2026-06-20):
#   sommer converged (AI-REML). Agreement with the serialized Julia target:
#     max |dG0|   = 7.53e-05   (largest on G0[1,1]: 0.603559 vs 0.603628)
#     max |dR0|   = 7.63e-06
#     max |dbeta| = 1.80e-06
#     max |dh2|   = 6.82e-05    (h2 = 0.6964/0.7488 both engines)
#     EBV: cor(trait1) = 1.0000, cor(trait2) = 1.0000; max |dEBV| = 4.40e-05
#     REML loglik NOT compared (additive-constant scale): sommer = -7.97 vs
#       engine = -121.70, offset = 113.74 -- a pure constant shift (sommer omits
#       constants the HSquared.jl REML retains), not a fit disagreement.
#   sommer and HSquared.jl agree to <= 7.6e-05 on every covariance/fixed-effect
#   estimate and to <= 4.4e-05 on the 40 EBVs, from an independently rebuilt A
#   and an independent REML optimizer. This is consistent with two correct
#   implementations of the same bivariate Gaussian animal model; the residual
#   ~1e-4 gap is optimizer-tolerance scale (sommer stops at its own AI-REML
#   convergence threshold, the twin at NelderMead). See the printed table below
#   for the exact element-wise differences.
#
# To run:  Rscript data-raw/multivariate-comparator-study.R

suppressWarnings(suppressMessages({
  library(sommer)
  library(nadiv)
}))

fx <- "../HSquared.jl/test/fixtures/phase4_multitrait_parity"
stopifnot(dir.exists(fx))

# --- target (engine) -------------------------------------------------------
read_cov <- function(f) {
  m <- as.matrix(read.csv(file.path(fx, f), row.names = 1L))
  storage.mode(m) <- "double"
  dimnames(m) <- list(c("trait1", "trait2"), c("trait1", "trait2"))
  m
}
G0_target <- read_cov("expected_genetic_covariance.csv")
R0_target <- read_cov("expected_residual_covariance.csv")
beta_target <- read.csv(file.path(fx, "expected_beta.csv"))
h2_target <- read.csv(file.path(fx, "expected_heritability.csv"))
ebv_target <- read.csv(file.path(fx, "expected_ebv.csv"))
meta_target <- read.csv(
  file.path(fx, "expected_metadata.csv"),
  stringsAsFactors = FALSE
)
engine_loglik <- as.numeric(meta_target$value[meta_target$key == "loglik"])

# --- data + relationship matrix -------------------------------------------
ped <- read.csv(file.path(fx, "pedigree.csv"), colClasses = "character")
ped[ped == "0"] <- NA
# Column order id, sire, dam matches the in-suite comparator
# (tests/testthat/test-multivariate.R). nadiv::makeA is invariant to the
# sire/dam column swap because the numerator relationship A is symmetric in the
# two parents (verified max|A - A_swapped| = 0) -- which is also why the benign
# "Dams appearing as Sires" warning (an individual used as both sire and dam
# across matings) does not affect A. Agreement with the independently built
# engine A confirms the rebuild.
pedn <- data.frame(
  id = ped$animal,
  sire = ped$sire,
  dam = ped$dam,
  stringsAsFactors = FALSE
)
A <- suppressWarnings(as.matrix(nadiv::makeA(pedn)))
A <- A[ped$animal, ped$animal]

phe <- read.csv(file.path(fx, "phenotypes.csv"), stringsAsFactors = FALSE)
phe$animal <- factor(phe$animal, levels = rownames(A))

# --- comparator fit --------------------------------------------------------
fit <- sommer::mmer(
  cbind(trait1, trait2) ~ x,
  random = ~ vsr(animal, Gu = A, Gtc = unsm(2)),
  rcov = ~ vsr(units, Gtc = unsm(2)),
  data = phe,
  verbose = FALSE
)

G0_hat <- fit$sigma[["u:animal"]]
R0_hat <- fit$sigma[["u:units"]]
dimnames(G0_hat) <- dimnames(R0_hat) <- dimnames(G0_target)
h2_hat <- diag(G0_hat) / (diag(G0_hat) + diag(R0_hat))
# sommer labels the intercept "(Intercept)"; the fixture uses "Intercept".
beta_eff <- sub("^\\(Intercept\\)$", "Intercept", fit$Beta$Effect)
beta_hat <- setNames(fit$Beta$Estimate, paste(fit$Beta$Trait, beta_eff))

ebv_hat <- fit$U[["u:animal"]]
ebv_hat_mat <- cbind(
  trait1 = ebv_hat$trait1[ebv_target$animal],
  trait2 = ebv_hat$trait2[ebv_target$animal]
)

# --- confrontation ---------------------------------------------------------
beta_t <- setNames(
  c(beta_target$trait1, beta_target$trait2),
  c(paste("trait1", beta_target$effect), paste("trait2", beta_target$effect))
)
beta_t <- beta_t[names(beta_hat)]

results <- list(
  `max|dG0|` = max(abs(G0_hat - G0_target)),
  `max|dR0|` = max(abs(R0_hat - R0_target)),
  `max|dbeta|` = max(abs(beta_hat - beta_t)),
  `max|dh2|` = max(abs(h2_hat - h2_target$h2)),
  `cor_EBV_trait1` = cor(ebv_hat_mat[, 1], ebv_target$trait1),
  `cor_EBV_trait2` = cor(ebv_hat_mat[, 2], ebv_target$trait2),
  `max|dEBV|` = max(abs(
    ebv_hat_mat - as.matrix(ebv_target[, c("trait1", "trait2")])
  ))
)

cat(
  "=== sommer",
  as.character(packageVersion("sommer")),
  "vs HSquared.jl multivariate target ===\n"
)
cat("G0 (sommer):\n")
print(round(G0_hat, 6))
cat("G0 (target):\n")
print(round(G0_target, 6))
cat("R0 (sommer):\n")
print(round(R0_hat, 6))
cat("R0 (target):\n")
print(round(R0_target, 6))
cat(
  "h2 (sommer):",
  round(h2_hat, 6),
  " (target):",
  round(h2_target$h2, 6),
  "\n"
)
# REML loglik is NOT compared (different additive constants; fixture README
# step 5). Report the offset so a reader can confirm it is a pure constant shift
# rather than a fit disagreement.
sommer_loglik <- tryCatch(
  as.numeric(fit$monitor[1L, ncol(fit$monitor)]),
  error = function(e) NA_real_
)
cat(sprintf(
  "\nREML loglik (NOT compared; additive-constant scale): sommer = %.4f  engine = %.4f  offset = %.4f\n",
  sommer_loglik,
  engine_loglik,
  sommer_loglik - engine_loglik
))
cat("\nElement-wise agreement:\n")
for (nm in names(results)) {
  cat(sprintf("  %-16s %.3e\n", nm, results[[nm]]))
}
invisible(results)
