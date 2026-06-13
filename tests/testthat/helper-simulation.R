# Test-only simulation helpers for the known-truth DGP recovery study.
# Not part of the package namespace; testthat auto-loads helper-*.R.

# Clean sexed generational pedigree: each generation is split into males
# (eligible sires) and females (eligible dams), so no individual is ever both a
# sire and a dam, parents always precede offspring, and there are no cycles or
# selfing. This deliberately avoids the data pathologies of real teaching
# pedigrees so the recovery study is not confounded by pedigree-prep choices.
hs_sim_pedigree <- function(
  n_founder = 40,
  n_per_gen = 80,
  n_gen = 2,
  seed = 1
) {
  set.seed(seed)
  half <- n_founder %/% 2
  id <- as.character(seq_len(n_founder))
  males <- id[seq_len(half)]
  females <- id[(half + 1):n_founder]
  sire <- rep(NA_character_, n_founder)
  dam <- rep(NA_character_, n_founder)
  nxt <- n_founder
  for (g in seq_len(n_gen)) {
    sires <- sample(males, n_per_gen, replace = TRUE)
    dams <- sample(females, n_per_gen, replace = TRUE)
    newid <- as.character(nxt + seq_len(n_per_gen))
    id <- c(id, newid)
    sire <- c(sire, sires)
    dam <- c(dam, dams)
    nh <- n_per_gen %/% 2
    males <- newid[seq_len(nh)]
    females <- newid[(nh + 1):n_per_gen]
    nxt <- nxt + n_per_gen
  }
  data.frame(id = id, sire = sire, dam = dam, stringsAsFactors = FALSE)
}

# Draw one univariate Gaussian animal-model dataset from known variance
# components, given the upper-Cholesky factor of the numerator relationship
# matrix A (A = crossprod(chol_A)). Uses the current RNG state; the caller sets
# the seed. Returns the phenotype y and the true breeding values u.
hs_sim_animal_phenotypes <- function(chol_A, sigma_a2, sigma_e2, mu = 0) {
  n <- ncol(chol_A)
  u <- sqrt(sigma_a2) * as.numeric(crossprod(chol_A, stats::rnorm(n)))
  e <- stats::rnorm(n, 0, sqrt(sigma_e2))
  list(y = mu + u + e, u = u)
}

# Henderson BLUP EBVs at supplied variance components for the intercept-only
# animal model (X = 1, Z = I), used to score EBV accuracy against true u.
hs_sim_blup_ebv <- function(y, Ainv, sigma_a2, sigma_e2) {
  n <- length(y)
  lambda <- sigma_e2 / sigma_a2
  X <- matrix(1, n, 1L)
  top <- cbind(crossprod(X), t(X))
  bot <- cbind(X, diag(n) + Ainv * lambda)
  C <- rbind(top, bot)
  rhs <- c(sum(y), y)
  sol <- solve(C, rhs)
  sol[-1L]
}
