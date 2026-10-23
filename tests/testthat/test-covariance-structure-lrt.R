# Experimental covariance-structure LRT (diagonal vs unstructured genetic
# covariance). Computed R-side from two multivariate fits' stored `loglik` +
# `n_genetic_params` (the twin's #61 contract), so it is fully fixture-testable
# without a live engine. Engine row V4-MV-REML (partial).

make_mv_fit <- function(
  loglik,
  n_genetic_params,
  genetic_structure,
  converged = TRUE
) {
  hsquared:::hs_new_fit(
    call = quote(hsquared(
      cbind(t1, t2) ~ animal(1 | id, pedigree = ped),
      data = dat
    )),
    spec = list(method = "REML", family = list(family = "gaussian")),
    payload = list(
      Y = matrix(0, 4, 2),
      X = matrix(1, 4, 1),
      pedigree = list(
        id = letters[1:4],
        sire = rep(NA_character_, 4),
        dam = rep(NA_character_, 4)
      ),
      metadata = list(
        trait_names = c("t1", "t2"),
        fixed_colnames = "(Intercept)"
      )
    ),
    result = list(
      loglik = loglik,
      n_genetic_params = n_genetic_params,
      genetic_structure = genetic_structure,
      converged = converged,
      nobs = 8L
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
  no_ll <- diag_fit
  no_ll$result$loglik <- NULL
  expect_error(covariance_structure_lrt(no_ll, full_fit), "loglik")
})

test_that("covariance_structure_lrt requires converged comparable fits", {
  diag_fit <- make_mv_fit(-110, 2L, "diagonal")
  full_fit <- make_mv_fit(-108, 3L, "unstructured")

  not_converged <- make_mv_fit(-110, 2L, "diagonal", converged = FALSE)
  expect_error(
    covariance_structure_lrt(not_converged, full_fit),
    "must both have converged"
  )

  different_nobs <- full_fit
  different_nobs$result$nobs <- 6L
  expect_error(
    covariance_structure_lrt(diag_fit, different_nobs),
    "same number of observations"
  )

  different_response <- full_fit
  different_response$payload$Y[1, 1] <- 1
  expect_error(
    covariance_structure_lrt(diag_fit, different_response),
    "same response data"
  )

  different_fixed <- full_fit
  different_fixed$payload$X[, 1] <- 2
  expect_error(
    covariance_structure_lrt(diag_fit, different_fixed),
    "same fixed-effect design"
  )

  different_pedigree <- full_fit
  different_pedigree$payload$pedigree$id[[1L]] <- "different"
  expect_error(
    covariance_structure_lrt(diag_fit, different_pedigree),
    "same pedigree"
  )

  ml_fit <- full_fit
  ml_fit$spec$method <- "ML"
  expect_error(
    covariance_structure_lrt(diag_fit, ml_fit),
    "REML fits"
  )
})

hs_lrt_fixture_meta <- function(dir, key) {
  meta <- utils::read.csv(
    testthat::test_path("fixtures", dir, "expected_metadata.csv"),
    stringsAsFactors = FALSE
  )
  stats::setNames(meta$value, meta$key)[[key]]
}

test_that("covariance_structure_lrt runs end-to-end on the shared fixtures", {
  # The diagonal and unstructured targets are fitted on IDENTICAL inputs (the
  # `structured_covariance_parity` and `phase4_multitrait_parity` fixtures share
  # the same pedigree + phenotypes), so the two REML log-likelihoods form a
  # valid nested diagonal-vs-unstructured structure test.
  ll_diag <- as.numeric(
    hs_lrt_fixture_meta("structured_covariance_parity", "loglik")
  )
  ll_full <- as.numeric(
    hs_lrt_fixture_meta("phase4_multitrait_parity", "loglik")
  )
  # The diagonal genetic-parameter count is read from the fixture (it records
  # n_genetic_params = t); the unstructured count is the derived t(t+1)/2 = 3
  # for t = 2 (the phase4 fixture predates the n_genetic_params field).
  np_diag <- as.integer(
    hs_lrt_fixture_meta("structured_covariance_parity", "n_genetic_params")
  )
  expect_equal(np_diag, 2L)

  diag_fit <- make_mv_fit(ll_diag, np_diag, "diagonal")
  full_fit <- make_mv_fit(ll_full, 3L, "unstructured")
  lrt <- covariance_structure_lrt(diag_fit, full_fit)

  expect_equal(lrt$df, 1L) # t(t-1)/2 off-diagonal genetic covariances, t = 2
  expect_false(lrt$boundary) # interior null
  expect_equal(lrt$statistic, 2 * (ll_full - ll_diag))
  expect_gt(lrt$statistic, 0) # the unstructured fit cannot do worse
  expect_equal(
    lrt$pvalue,
    stats::pchisq(2 * (ll_full - ll_diag), df = 1, lower.tail = FALSE)
  )
  expect_equal(lrt$constrained, "diagonal")
  expect_equal(lrt$full, "unstructured")
})

test_that("covariance_structure_lrt flags invalid reference cases", {
  # Any pairing other than diagonal-in-unstructured is boundary-conservative
  # (the naive chi-square is not valid at a variance boundary).
  diag_fit <- make_mv_fit(-110, 2L, "diagonal")
  lowrank_fit <- make_mv_fit(-108, 3L, "lowrank")
  expect_warning(
    boundary_lrt <- covariance_structure_lrt(diag_fit, lowrank_fit),
    "chi-square reference is not valid"
  )
  expect_true(boundary_lrt$boundary)
  expect_true(is.na(boundary_lrt$pvalue))

  # A negative 2*Delta-loglik is reported, not silently clamped to zero.
  worse_full <- make_mv_fit(-110.0001, 3L, "unstructured")
  expect_warning(
    noisy <- covariance_structure_lrt(diag_fit, worse_full),
    "negative likelihood-ratio statistic"
  )
  expect_lt(noisy$statistic, 0)
  expect_true(is.na(noisy$pvalue))
})
