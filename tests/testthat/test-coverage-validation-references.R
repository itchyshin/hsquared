# Coverage lane for R/validation-fixtures.R: the input-coercion and failure
# branches of the pure-R reference solvers. Coercion is checked by invariance
# (a data.frame or Matrix input must give exactly the base-matrix answer), and
# the failure path by the documented non-convergence signal.

hs_cov_sire_inputs <- function() {
  fixture <- hsquared:::hs_mrode_example_3_2_sire_fixture()
  d <- fixture$data
  sire_ids <- rownames(fixture$expected$Ainv)
  X <- stats::model.matrix(~ sex - 1, data = d)
  Z <- matrix(0, nrow(d), length(sire_ids))
  Z[cbind(seq_len(nrow(d)), match(d$sire, sire_ids))] <- 1
  list(fixture = fixture, d = d, X = X, Z = Z, ids = sire_ids)
}

test_that("the univariate Henderson reference gives the same answer for data.frame X and Matrix Ainv", {
  s <- hs_cov_sire_inputs()
  solve_with <- function(X, Ainv) {
    hsquared:::hs_solve_henderson_mme_reference(
      y = s$d$WWG,
      X = X,
      Z = s$Z,
      Ainv = Ainv,
      sigma_a2 = s$fixture$sigma_s2,
      sigma_e2 = s$fixture$sigma_e2,
      ids = s$ids
    )
  }
  base <- solve_with(s$X, s$fixture$expected$Ainv)
  framed <- solve_with(as.data.frame(s$X), methods::as(s$fixture$expected$Ainv, "Matrix"))
  expect_equal(framed$breeding_values, base$breeding_values)
  expect_equal(framed$fixed_effects, base$fixed_effects)
})

test_that("the univariate Henderson reference refuses a non-numeric response and non-positive variances", {
  s <- hs_cov_sire_inputs()
  args <- list(
    y = s$d$WWG, X = s$X, Z = s$Z, Ainv = s$fixture$expected$Ainv,
    sigma_a2 = 5, sigma_e2 = 55, ids = s$ids
  )
  call_with <- function(...) {
    do.call(hsquared:::hs_solve_henderson_mme_reference, utils::modifyList(args, list(...)))
  }
  expect_error(call_with(y = as.character(s$d$WWG)), "`y` must be numeric.", fixed = TRUE)
  expect_error(call_with(sigma_a2 = 0), "`sigma_a2` must be a positive number.", fixed = TRUE)
  expect_error(call_with(sigma_e2 = c(1, 2)), "`sigma_e2` must be a positive number.", fixed = TRUE)
})

test_that("the multivariate Henderson reference is invariant to data.frame G0/R0 and Matrix Ainv", {
  fixture <- hsquared:::hs_mrode_example_5_1_multitrait_fixture()
  solve_with <- function(Ainv, G0, R0) {
    hsquared:::hs_solve_multivariate_henderson_mme_reference(
      Y = as.matrix(fixture$data[, fixture$traits]),
      sex = fixture$data$sex,
      animal = fixture$data$animal,
      ids = fixture$ids,
      Ainv = Ainv,
      G0 = G0,
      R0 = R0,
      traits = fixture$traits
    )
  }
  base <- solve_with(fixture$expected$Ainv, fixture$G0, fixture$R0)
  alt <- solve_with(
    methods::as(fixture$expected$Ainv, "Matrix"),
    as.data.frame(fixture$G0),
    as.data.frame(fixture$R0)
  )
  expect_equal(alt$breeding_values, base$breeding_values)
  expect_equal(alt$fixed_effects, base$fixed_effects)
})

test_that("the REML reference reports non-convergence, not an error, when the likelihood cannot be evaluated", {
  s <- hs_cov_sire_inputs()
  y <- s$d$WWG
  y[[2L]] <- NA_real_
  fit <- hsquared:::hs_reml_estimate_reference(
    y = y,
    X = s$X,
    Z = s$Z,
    Ainv = s$fixture$expected$Ainv
  )
  expect_identical(fit$convergence, 99L)
  expect_true(all(is.na(fit$estimate)))
  expect_identical(names(fit$estimate), c("sigma_a2", "sigma_e2"))
  expect_false(is.finite(fit$loglik))
})
