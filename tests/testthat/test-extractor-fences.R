# Guard branches of the exported extractors that need no Julia engine. Each
# fixture is a hand-built `hsquared_fit`, as in test-fit-object.R.

hs_fence_fit <- function(spec = list(), payload = list(), result = list()) {
  hsquared:::hs_new_fit(
    call = quote(hsquared(y ~ animal(1 | id, pedigree = ped), data = dat)),
    spec = c(list(method = "REML", family = list(family = "gaussian")), spec),
    payload = payload,
    result = c(list(converged = TRUE), result)
  )
}

test_that("heritability() refuses the genetic GLLVM route", {
  fit <- hs_fence_fit(spec = list(target = "genetic_gllvm"))
  expect_error(
    heritability(fit),
    "Heritability is not defined by this genetic GLLVM route",
    fixed = TRUE
  )
})

test_that("heritability() refuses a random-regression fit and names rr_heritability()", {
  by_target <- hs_fence_fit(spec = list(target = "random_regression"))
  expect_true(hsquared:::hs_fit_is_random_regression(by_target))
  expect_error(
    heritability(by_target),
    "TRAJECTORY h2(t)",
    fixed = TRUE
  )
  expect_error(
    heritability(by_target),
    "`rr_heritability()`",
    fixed = TRUE
  )

  # The second detection route: a coefficient covariance in the result.
  by_result <- hs_fence_fit(
    result = list(coefficient_covariance = diag(2))
  )
  expect_true(hsquared:::hs_fit_is_random_regression(by_result))
  expect_error(
    heritability(by_result),
    "TRAJECTORY h2(t)",
    fixed = TRUE
  )
})

test_that("metafounder_groups() checks that ids and groups align", {
  group_of <- c(a = "M1", b = "", c = "M2")

  expect_error(
    metafounder_groups(hs_fence_fit(
      payload = list(group_of = group_of, ids = c("a", "b"))
    )),
    "malformed metafounder group metadata",
    fixed = TRUE
  )

  # Aligned `ids` are returned in order, with "" groups as non-metafounders.
  fit <- hs_fence_fit(
    payload = list(group_of = unname(group_of), ids = c("a", "b", "c"))
  )
  out <- metafounder_groups(fit)
  expect_identical(out$id, c("a", "b", "c"))
  expect_identical(out$metafounder_group, c("M1", NA, "M2"))
  expect_identical(out$is_metafounder, c(TRUE, FALSE, TRUE))

  # No `ids` and no names to fall back on cannot be aligned.
  expect_error(
    metafounder_groups(hs_fence_fit(
      payload = list(group_of = unname(group_of))
    )),
    "malformed metafounder group metadata",
    fixed = TRUE
  )
})

test_that("gamma_matrix() applies labels only when they match both dimensions", {
  gamma <- matrix(1:4, 2, 2)

  labelled <- gamma_matrix(hs_fence_fit(
    payload = list(Gamma = gamma, gamma_labels = c("M1", "M2"))
  ))
  expect_identical(dimnames(labelled), list(c("M1", "M2"), c("M1", "M2")))
  expect_identical(storage.mode(labelled), "double")

  for (bad in list(c("M1", "M2", "M3"), "M1")) {
    unlabelled <- gamma_matrix(hs_fence_fit(
      payload = list(Gamma = gamma, gamma_labels = bad)
    ))
    expect_null(dimnames(unlabelled))
    expect_identical(storage.mode(unlabelled), "double")
    expect_equal(unlabelled, matrix(c(1, 2, 3, 4), 2, 2))
  }

  # A non-square Gamma never takes labels, even when one dimension matches.
  for (labels in list(c("M1", "M2"), c("M1", "M2", "M3"))) {
    rect <- gamma_matrix(hs_fence_fit(
      payload = list(Gamma = matrix(1:6, 2, 3), gamma_labels = labels)
    ))
    expect_null(dimnames(rect))
  }
})

test_that("random-regression and evolvability extractors need an hsquared_fit", {
  expect_error(
    rr_correlation(list()),
    "requires an `hsquared_fit` object",
    fixed = TRUE
  )
  expect_error(
    rr_covariance(list()),
    "requires an `hsquared_fit` object",
    fixed = TRUE
  )
  expect_error(
    random_coefficients(list()),
    "requires an `hsquared_fit` object",
    fixed = TRUE
  )
  expect_error(
    variance_along_gradient(list(), direction = c(1, 0)),
    "requires an `hsquared_fit` object",
    fixed = TRUE
  )
  expect_error(
    g_max(list()),
    "requires an `hsquared_fit` object",
    fixed = TRUE
  )
})
