hs_tiny_animal_validation_fixture <- function() {
  pedigree <- data.frame(
    id = c("calf", "sire", "dam"),
    sire = c("sire", NA, NA),
    dam = c("dam", NA, NA),
    stringsAsFactors = FALSE
  )
  data <- data.frame(
    y = c(1.2, 1.8, 2.6),
    age = c(0, 1, 2),
    id = c("sire", "dam", "calf"),
    stringsAsFactors = FALSE
  )

  formula <- y ~ age + animal(1 | id, pedigree = pedigree)
  ids <- c("sire", "dam", "calf")
  Ainv <- matrix(
    c(
      1.5,
      0.5,
      -1,
      0.5,
      1.5,
      -1,
      -1,
      -1,
      2
    ),
    nrow = 3,
    byrow = TRUE,
    dimnames = list(ids, ids)
  )

  list(
    name = "tiny_henderson_calf",
    description = paste(
      "Three-animal Henderson-style pedigree fixture for parser, bridge,",
      "and sparse Ainv validation."
    ),
    formula = formula,
    data = data,
    pedigree = pedigree,
    expected = list(
      ids = ids,
      sire_index = c(0L, 0L, 1L),
      dam_index = c(0L, 0L, 2L),
      Z = diag(3),
      Ainv = Ainv
    )
  )
}

hs_mrode9_pedigree_validation_fixture <- function() {
  if (!requireNamespace("nadiv", quietly = TRUE)) {
    stop(
      "The optional `nadiv` package is required for the Mrode9 validation ",
      "fixture.",
      call. = FALSE
    )
  }

  env <- new.env(parent = emptyenv())
  utils::data("Mrode9", package = "nadiv", envir = env)
  pedigree <- env$Mrode9[, c("pig", "sire", "dam")]
  names(pedigree) <- c("id", "sire", "dam")
  pedigree$id <- as.character(pedigree$id)
  pedigree$sire <- as.character(pedigree$sire)
  pedigree$dam <- as.character(pedigree$dam)
  pedigree$sire[is.na(pedigree$sire)] <- NA_character_
  pedigree$dam[is.na(pedigree$dam)] <- NA_character_

  ainv <- nadiv::makeAinv(pedigree)$Ainv
  colnames(ainv) <- rownames(ainv)

  list(
    name = "mrode9_nadiv_pedigree",
    description = paste(
      "Pedigree adapted from Mrode example 9.1 as shipped by nadiv; used",
      "for optional sparse Ainv comparator validation."
    ),
    source = paste(
      "nadiv::Mrode9, documented as adapted from example 9.1 of Mrode",
      "(2005), Linear Models for the Prediction of Animal Breeding Values."
    ),
    pedigree = pedigree,
    expected = list(Ainv = ainv)
  )
}

hs_henderson_mme_validation_fixture <- function() {
  ids <- c("founder_a", "founder_b", "animal_1", "animal_2", "animal_3")
  pedigree <- data.frame(
    id = ids,
    sire = c(NA, NA, "founder_a", "founder_a", "animal_1"),
    dam = c(NA, NA, "founder_b", "founder_b", "animal_2"),
    stringsAsFactors = FALSE
  )
  data <- data.frame(
    y = c(3.2, 4.1, 5.4, 5.9),
    x = c(0, 1, 0, 1),
    id = c("animal_1", "animal_2", "animal_3", "animal_3"),
    stringsAsFactors = FALSE
  )
  Ainv <- matrix(
    c(
      2,
      1,
      -1,
      -1,
      0,
      1,
      2,
      -1,
      -1,
      0,
      -1,
      -1,
      2.5,
      0.5,
      -1,
      -1,
      -1,
      0.5,
      2.5,
      -1,
      0,
      0,
      -1,
      -1,
      2
    ),
    nrow = 5,
    byrow = TRUE,
    dimnames = list(ids, ids)
  )

  list(
    name = "henderson_supplied_variance_mme",
    description = paste(
      "Five-animal supplied-variance Henderson mixed-model-equation",
      "fixture for fixed effects, EBVs, fitted values, and heritability."
    ),
    formula = y ~ x + animal(1 | id, pedigree = pedigree),
    data = data,
    pedigree = pedigree,
    sigma_a2 = 1.2,
    sigma_e2 = 0.8,
    expected = list(
      ids = ids,
      Ainv = Ainv,
      fixed_effects = c(
        "(Intercept)" = 3.898701298701298,
        x = 0.6454545454545471
      ),
      breeding_values = data.frame(
        id = ids,
        value = c(
          0,
          0,
          -0.054545454545454695,
          0.05454545454545385,
          0.8571428571428561
        ),
        stringsAsFactors = FALSE
      ),
      fitted = data.frame(
        .fitted = c(
          3.844155844155843,
          4.5987012987012985,
          4.755844155844154,
          5.401298701298701
        )
      ),
      heritability = 0.6
    )
  )
}

hs_reml_likelihood_validation_fixture <- function() {
  ids <- c("a", "b", "c")
  pedigree <- data.frame(
    id = ids,
    sire = c(NA, NA, NA),
    dam = c(NA, NA, NA),
    stringsAsFactors = FALSE
  )
  data <- data.frame(
    y = c(1, 2, 3),
    id = ids,
    stringsAsFactors = FALSE
  )

  list(
    name = "tiny_sparse_reml_likelihood_identity",
    description = paste(
      "Three-founder supplied-variance Gaussian likelihood fixture for",
      "dense REML, sparse REML, and ML identity checks."
    ),
    formula = y ~ animal(1 | id, pedigree = pedigree),
    data = data,
    pedigree = pedigree,
    sigma_a2 = 1,
    sigma_e2 = 1,
    expected = list(
      ids = ids,
      sire_index = c(0L, 0L, 0L),
      dam_index = c(0L, 0L, 0L),
      Z = diag(3),
      Ainv = diag(3),
      fixed_effects = c("(Intercept)" = 2),
      ml_loglik = -0.5 * (3 * log(2 * pi) + 3 * log(2) + 1),
      reml_loglik = -0.5 * (2 * log(2 * pi) + 3 * log(2) + log(1.5) + 1)
    )
  )
}

hs_solve_henderson_mme_reference <- function(
  y,
  X,
  Z,
  Ainv,
  sigma_a2,
  sigma_e2,
  ids
) {
  if (!is.numeric(y)) {
    stop("`y` must be numeric.", call. = FALSE)
  }
  if (!is.matrix(X)) {
    X <- as.matrix(X)
  }
  if (!inherits(Z, "Matrix")) {
    Z <- Matrix::Matrix(Z, sparse = TRUE)
  }
  if (!is.matrix(Ainv)) {
    Ainv <- as.matrix(Ainv)
  }
  if (!is.numeric(sigma_a2) || length(sigma_a2) != 1L || sigma_a2 <= 0) {
    stop("`sigma_a2` must be a positive number.", call. = FALSE)
  }
  if (!is.numeric(sigma_e2) || length(sigma_e2) != 1L || sigma_e2 <= 0) {
    stop("`sigma_e2` must be a positive number.", call. = FALSE)
  }

  residual_precision <- 1 / sigma_e2
  relationship_precision <- 1 / sigma_a2
  X <- Matrix::Matrix(X, sparse = TRUE)
  Ainv <- Matrix::Matrix(Ainv, sparse = TRUE)
  lhs <- rbind(
    cbind(
      residual_precision * Matrix::crossprod(X),
      residual_precision * Matrix::crossprod(X, Z)
    ),
    cbind(
      residual_precision * Matrix::crossprod(Z, X),
      residual_precision * Matrix::crossprod(Z) + relationship_precision * Ainv
    )
  )
  rhs <- c(
    as.numeric(residual_precision * Matrix::crossprod(X, y)),
    as.numeric(residual_precision * Matrix::crossprod(Z, y))
  )
  solution <- as.numeric(solve(as.matrix(lhs), rhs))
  nfixed <- ncol(X)
  fixed <- solution[seq_len(nfixed)]
  names(fixed) <- colnames(X)
  animal <- solution[-seq_len(nfixed)]

  list(
    fixed_effects = fixed,
    breeding_values = data.frame(
      id = ids,
      value = animal,
      stringsAsFactors = FALSE
    ),
    fitted = data.frame(
      .fitted = as.numeric(as.matrix(X) %*% fixed + as.matrix(Z) %*% animal)
    ),
    heritability = sigma_a2 / (sigma_a2 + sigma_e2)
  )
}
