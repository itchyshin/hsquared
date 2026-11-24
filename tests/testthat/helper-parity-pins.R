# Shared helpers for the live R-bridge vs direct-Julia variance-component pins
# (PARITY-MAP rows 8, 9, 10). The "direct Julia" side calls HSquared.jl fit
# functions on inputs built here in base R + Matrix, with no hsquared() payload,
# so a bridge marshalling or relabelling error cannot cancel itself out.

hs_pin_pedigree <- function() {
  utils::read.csv(
    testthat::test_path(
      "fixtures",
      "animal_model_engine_parity",
      "pedigree.csv"
    ),
    stringsAsFactors = FALSE,
    na.strings = ""
  )
}

# Simulate records on the 30-animal fixture pedigree (4 inbred animals), `k`
# records per animal. `env` (optional) is a per-animal group label; when given
# it contributes a group effect with variance `var_env`. Values are rounded so
# the data are identical on every platform.
hs_pin_simulate <- function(
  seed,
  k = 1L,
  var_a = 1,
  var_pe = 0,
  var_env = 0,
  env = NULL
) {
  ped <- hs_pin_pedigree()
  n <- nrow(ped)
  A <- hs_pin_numerator_relationship(ped)
  set.seed(seed)
  a <- as.vector(t(chol(A)) %*% stats::rnorm(n, sd = sqrt(var_a)))
  pe <- stats::rnorm(n, sd = sqrt(var_pe))
  sex <- rep(c("M", "F"), length.out = n)
  y <- 5 + 0.5 * (sex == "M") + rep(a, each = k) + rep(pe, each = k)
  dat <- data.frame(
    id = rep(ped$id, each = k),
    sex = rep(sex, each = k),
    stringsAsFactors = FALSE
  )
  if (!is.null(env)) {
    eff <- stats::rnorm(length(unique(env)), sd = sqrt(var_env))
    y <- y + rep(eff[match(env, unique(env))], each = k)
    dat$env <- rep(env, each = k)
  }
  dat$y <- round(y + stats::rnorm(n * k), 4)
  list(ped = ped, data = dat)
}

# Tabular numerator relationship matrix (parents precede offspring).
hs_pin_numerator_relationship <- function(ped) {
  n <- nrow(ped)
  s <- match(ped$sire, ped$id)
  d <- match(ped$dam, ped$id)
  A <- matrix(0, n, n, dimnames = list(ped$id, ped$id))
  for (i in seq_len(n)) {
    for (j in seq_len(i - 1L)) {
      A[i, j] <- A[j, i] <- 0.5 *
        ((if (is.na(s[i])) 0 else A[j, s[i]]) +
          (if (is.na(d[i])) 0 else A[j, d[i]]))
    }
    A[i, i] <- 1 +
      (if (is.na(s[i]) || is.na(d[i])) 0 else 0.5 * A[s[i], d[i]])
  }
  A
}

# Assign y, X, an animal incidence Z (records x pedigree animals), and the
# pedigree-derived A^-1 into the live Julia session under hsq_pin_* names.
hs_pin_julia_assign <- function(ped, data, formula = ~sex) {
  hsquared:::hs_julia_setup(hsquared:::hs_default_julia_project())
  X <- stats::model.matrix(formula, data)
  attr(X, "assign") <- NULL
  attr(X, "contrasts") <- NULL
  dimnames(X) <- NULL
  Z <- Matrix::sparseMatrix(
    i = seq_len(nrow(data)),
    j = match(data$id, ped$id),
    x = 1,
    dims = c(nrow(data), nrow(ped))
  )
  JuliaCall::julia_assign("hsq_pin_y", data$y)
  JuliaCall::julia_assign("hsq_pin_X", X)
  hsquared:::hs_julia_assign_sparse_csc("hsq_pin_Z", Z)
  JuliaCall::julia_assign("hsq_pin_id", ped$id)
  JuliaCall::julia_assign(
    "hsq_pin_sire",
    hsquared:::hs_parent_for_julia(ped$sire)
  )
  JuliaCall::julia_assign(
    "hsq_pin_dam",
    hsquared:::hs_parent_for_julia(ped$dam)
  )
  JuliaCall::julia_command(paste(
    "hsq_pin_ped = HSquared.normalize_pedigree(hsq_pin_id, hsq_pin_sire, hsq_pin_dam);",
    "hsq_pin_Ainv = HSquared.pedigree_inverse(hsq_pin_ped);"
  ))
  invisible(TRUE)
}

hs_pin_expect_rel <- function(object, expected, label) {
  testthat::expect_lt(
    abs(object - expected) / max(abs(expected), 1e-12),
    1e-6,
    label = label
  )
}
