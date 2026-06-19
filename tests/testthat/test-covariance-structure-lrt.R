# Experimental covariance-structure LRT (diagonal vs unstructured genetic
# covariance). Computed R-side from two multivariate fits' stored `loglik` +
# `n_genetic_params` (the twin's #61 contract), so it is fully fixture-testable
# without a live engine. Engine row V4-MV-REML (partial).

make_mv_fit <- function(loglik, n_genetic_params, genetic_structure) {
  hsquared:::hs_new_fit(
    call = quote(hsquared(
      cbind(t1, t2) ~ animal(1 | id, pedigree = ped),
      data = dat
    )),
    spec = list(method = "REML", family = list(family = "gaussian")),
    payload = list(Y = matrix(0, 4, 2)),
    result = list(
      loglik = loglik,
      n_genetic_params = n_genetic_params,
      genetic_structure = genetic_structure
    )
  )
}

test_that("covariance_structure_lrt computes the diagonal-vs-unstructured test", {
  diag_fit <- make_mv_fit(-110, 2L, "diagonal")
  full_fit <- make_mv_fit(-108, 3L, "unstructured")
  lrt <- covariance_structure_lrt(diag_fit, full_fit)

  expect_equal(lrt$df, 1L) # t(t-1)/2 = 1 off-diagonal genetic covariance for t=2
  expect_equal(lrt$statistic, 2 * (-108 - -110)) # 2*(ll_full - ll_diag) = 4
  expect_false(lrt$boundary) # diagonal-in-unstructured is an interior null
  expect_equal(lrt$pvalue, stats::pchisq(4, 1, lower.tail = FALSE))
  expect_equal(lrt$constrained, "diagonal")
  expect_equal(lrt$full, "unstructured")
})

test_that("covariance_structure_lrt guards order, object class, and missing fields", {
  diag_fit <- make_mv_fit(-110, 2L, "diagonal")
  full_fit <- make_mv_fit(-108, 3L, "unstructured")

  # Wrong order (df <= 0).
  expect_error(
    covariance_structure_lrt(full_fit, diag_fit),
    "more genetic covariance parameters"
  )
  # Not hsquared_fit objects.
  expect_error(
    covariance_structure_lrt(seq_len(3), full_fit),
    "must both be"
  )
  # Missing loglik (e.g. a non-converged fit).
  no_ll <- hsquared:::hs_new_fit(
    call = quote(hsquared(
      cbind(t1, t2) ~ animal(1 | id, pedigree = ped),
      data = dat
    )),
    spec = list(method = "REML", family = list(family = "gaussian")),
    payload = list(Y = matrix(0, 4, 2)),
    result = list(n_genetic_params = 2L, genetic_structure = "diagonal")
  )
  expect_error(covariance_structure_lrt(no_ll, full_fit), "loglik")
})
