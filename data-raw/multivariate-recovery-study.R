# Known-truth DGP recovery study for the hsquared / HSquared.jl MULTIVARIATE
# (t = 2) REML estimator. Companion to data-raw/dgp-recovery-study.R (univariate).
#
# Design follows ADEMP (Morris, White & Crowther 2019). This script is
# reproducible evidence; it is NOT part of the package build (.Rbuildignore'd).
# Run from the package root with a local HSquared.jl checkout + julia on PATH for
# the engine leg. It is the R-side harness the twin needs to move
# V4-MULTIVARIATE / V4-MV-REML from `partial` toward `covered` (issue #34 /
# HSquared.jl#41). The RECORDED RESULT block below is intentionally left PENDING
# until the harness is run with an engine — no recovery numbers are claimed here.
#
# A - AIMS
#   Does the multivariate REML estimator recover a known 2-trait genetic and
#   residual covariance (G0, R0), the genetic correlation, and per-trait h2, on
#   data simulated from a 2-trait Gaussian animal model over a pedigree?
#
# D - DATA-GENERATING MECHANISM
#   Pedigree: a clean sexed generational pedigree (founders unrelated; each
#   generation split into sires/dams; no selfing, no cycles). A = numerator
#   relationship matrix (nadiv::makeA); U = chol(A) so A = U'U.
#   Breeding values B (n x 2): B = U' Zg L_G', Zg ~ N(0, 1) n x 2, L_G = chol(G0)
#   => Cov(vec B) = G0 (x) A. Residuals E = Ze L_R', Ze ~ N(0,1), L_R = chol(R0)
#   => Cov(vec E) = R0 (x) I. Phenotypes Y = mu + B + E (one record per animal).
#   Truth: G0 = [[1.0, 0.3], [0.3, 0.8]], R0 = [[1.0, -0.1], [-0.1, 1.2]]
#   => h2 = c(1/2, 0.8/2) = c(0.5, 0.4); genetic correlation rg = 0.3/sqrt(0.8).
#
# E - ESTIMANDS / TARGETS
#   True G0, R0, rg, and per-trait h2 (above); estimator outputs the REML hats.
#
# M - METHODS
#   Engine: HSquared.fit_multivariate_reml via
#   hsquared(cbind(y1, y2) ~ 1 + animal(1 | id, pedigree = ped),
#            engine_control = list(target = "multivariate",
#                                  initial = list(G0 = diag(2), R0 = diag(2)))).
#   Recovery only -- no external comparator here.
#
# P - PERFORMANCE MEASURES
#   Absolute bias of each unique G0/R0 element, rg, and per-trait h2:
#   mean(hat) - true, with MCSE = sd(hat)/sqrt(n_rep). EBV accuracy: per-trait
#   mean cor(EBV_hat, true BV). Convergence rate.
#
# RECORDED RESULT: PENDING (run with a local engine; do not fabricate). When run,
# record truth vs mean(hat), bias +/- 2*MCSE per target, rg/h2 recovery, and the
# convergence rate here, mirroring the univariate study's recorded block.

suppressWarnings(suppressMessages({
  library(hsquared)
}))

make_pedigree <- function(n_founder = 60L, n_per_gen = 120L, n_gen = 3L,
                          seed = 20240613L) {
  set.seed(seed)
  ids <- as.character(seq_len(n_founder))
  sire <- rep(NA_character_, n_founder)
  dam <- rep(NA_character_, n_founder)
  prev <- ids
  next_id <- n_founder + 1L
  for (g in seq_len(n_gen)) {
    sires <- prev[seq_len(length(prev) %/% 2L)]
    dams <- prev[(length(prev) %/% 2L + 1L):length(prev)]
    new_ids <- as.character(next_id:(next_id + n_per_gen - 1L))
    new_sire <- sample(sires, n_per_gen, replace = TRUE)
    new_dam <- sample(dams, n_per_gen, replace = TRUE)
    ids <- c(ids, new_ids)
    sire <- c(sire, new_sire)
    dam <- c(dam, new_dam)
    prev <- new_ids
    next_id <- next_id + n_per_gen
  }
  data.frame(id = ids, sire = sire, dam = dam, stringsAsFactors = FALSE)
}

simulate_multitrait <- function(ped, A, G0, R0, mu = c(5, 3), seed = 1L) {
  set.seed(seed)
  n <- nrow(ped)
  U <- chol(A) # A = U'U
  LG <- t(chol(G0))
  LR <- t(chol(R0))
  Zg <- matrix(stats::rnorm(n * 2L), n, 2L)
  Ze <- matrix(stats::rnorm(n * 2L), n, 2L)
  B <- crossprod(U, Zg) %*% t(LG) # Cov(vec B) = G0 (x) A
  E <- Ze %*% t(LR) # Cov(vec E) = R0 (x) I
  Y <- sweep(B + E, 2L, mu, "+")
  # Return the phenotypes AND the true breeding values B (rows aligned to
  # ped$id), so recovery can score EBV accuracy = cor(EBV_hat, true BV) per trait.
  list(
    data = data.frame(
      id = ped$id, y1 = Y[, 1L], y2 = Y[, 2L], stringsAsFactors = FALSE
    ),
    bv = B
  )
}

# -- Configuration (truth) --
G0_true <- matrix(c(1.0, 0.3, 0.3, 0.8), 2L, 2L)
R0_true <- matrix(c(1.0, -0.1, -0.1, 1.2), 2L, 2L)
h2_true <- diag(G0_true) / (diag(G0_true) + diag(R0_true)) # c(0.5, 0.4)
rg_true <- G0_true[1L, 2L] / sqrt(G0_true[1L, 1L] * G0_true[2L, 2L])
n_rep <- 100L
master_seed <- 20240613L

run_study <- function(n_rep = 100L) {
  if (!requireNamespace("nadiv", quietly = TRUE)) {
    stop("nadiv is required to build A for the recovery study.")
  }
  ped <- make_pedigree()
  A <- as.matrix(nadiv::makeA(ped))
  A <- A[ped$id, ped$id]
  set.seed(master_seed)
  seeds <- sample.int(.Machine$integer.max, n_rep)
  traits <- c("y1", "y2")
  hats <- vector("list", n_rep)
  for (r in seq_len(n_rep)) {
    sim <- simulate_multitrait(ped, A, G0_true, R0_true, seed = seeds[r])
    dat <- merge(sim$data, ped, by = "id", all.x = TRUE)
    fit <- tryCatch(
      hsquared(
        cbind(y1, y2) ~ 1 + animal(1 | id, pedigree = ped),
        data = dat,
        engine_control = list(
          target = "multivariate",
          initial = list(G0 = diag(2), R0 = diag(2))
        )
      ),
      error = function(e) NULL
    )
    if (is.null(fit)) next
    # EBV accuracy: pivot the long (id, trait, value) EBVs to wide, align to
    # ped$id, and correlate each trait with the true breeding value.
    ebv <- breeding_values(fit)
    ebv_mat <- vapply(traits, function(tn) {
      s <- ebv[ebv$trait == tn, , drop = FALSE]
      s$value[match(ped$id, s$id)]
    }, numeric(nrow(ped)))
    acc <- vapply(seq_along(traits), function(k) {
      stats::cor(ebv_mat[, k], sim$bv[, k], use = "complete.obs")
    }, numeric(1))
    hats[[r]] <- list(
      G0 = genetic_covariance(fit),
      R0 = residual_covariance(fit),
      rg = genetic_correlation(fit)[1L, 2L],
      h2 = heritability(fit)$estimate,
      ebv_accuracy = stats::setNames(acc, traits)
    )
  }
  hats <- Filter(Negate(is.null), hats)
  message(sprintf("converged %d / %d", length(hats), n_rep))
  hats
}

# The engine leg is intentionally not invoked at source() time. To run:
#   res <- run_study(100L)
# then summarise bias +/- 2*MCSE per target and record above.
if (identical(Sys.getenv("HSQUARED_RUN_MV_RECOVERY"), "true")) {
  res <- run_study(n_rep)
  str(utils::head(res, 1L))
}
