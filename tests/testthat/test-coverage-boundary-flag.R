# H2 / R-15: default `hs_fit_boundary_flag(object, tol = 1e-4)` on constructed fits.
# Complements `test-coverage-extractors.R` (classifier layouts) with the tol=1e-4 contract.

hs_cov_mock_fit <- function(estimate, components = c("animal", "residual")) {
  hsquared:::hs_new_fit(
    spec = list(
      method = "REML",
      family = list(family = "gaussian"),
      target = "univariate"
    ),
    payload = list(y = seq_along(estimate)),
    result = list(
      variance_components = data.frame(
        component = components,
        estimate = estimate,
        stringsAsFactors = FALSE
      ),
      converged = TRUE
    )
  )
}

test_that("tol = 1e-4: a primary share just below flags at_boundary with the clean-boundary condition", {
  fit <- hs_cov_mock_fit(c(animal = 9e-5, residual = 1))
  expect_true(isTRUE(hsquared:::hs_fit_boundary_flag(fit)))
  expect_identical(hsquared:::hs_fit_boundary_class(fit), "zero")
  expect_identical(
    hsquared:::hs_fit_boundary_condition_label(hsquared:::hs_fit_boundary_class(fit)),
    "at/near zero (clean boundary)"
  )
  diag <- fit_diagnostics(fit)
  expect_equal(diag$value[diag$metric == "at_boundary"], "TRUE")
  expect_equal(
    diag$value[diag$metric == "at_boundary_condition"],
    "at/near zero (clean boundary)"
  )
})

test_that("tol = 1e-4: a primary share just above is interior (no condition row)", {
  fit <- hs_cov_mock_fit(c(animal = 2e-4, residual = 1))
  expect_false(isTRUE(hsquared:::hs_fit_boundary_flag(fit)))
  expect_false(hsquared:::hs_fit_boundary_class(fit))
  expect_null(hsquared:::hs_fit_boundary_condition_label(hsquared:::hs_fit_boundary_class(fit)))
  diag <- fit_diagnostics(fit)
  expect_equal(diag$value[diag$metric == "at_boundary"], "FALSE")
  expect_false("at_boundary_condition" %in% diag$metric)
})

test_that("tol = 1e-4: a share exactly at the tolerance still counts as at the boundary", {
  fit <- hs_cov_mock_fit(c(animal = 1e-4, residual = 1 - 1e-4))
  shares <- with(fit$result$variance_components, estimate / sum(estimate))
  expect_lte(min(shares), 1e-4)
  expect_true(isTRUE(hsquared:::hs_fit_boundary_flag(fit, tol = 1e-4)))
})

test_that("a negative primary estimate is inadmissible, not a clean zero boundary", {
  fit <- hs_cov_mock_fit(c(animal = -0.01, residual = 1))
  expect_true(isTRUE(hsquared:::hs_fit_boundary_flag(fit)))
  expect_identical(hsquared:::hs_fit_boundary_class(fit), "negative")
  diag <- fit_diagnostics(fit)
  expect_equal(
    diag$value[diag$metric == "at_boundary_condition"],
    "negative (inadmissible variance)"
  )
})

test_that("a near-zero residual share flags at_boundary (h2 approaching one)", {
  fit <- hs_cov_mock_fit(c(animal = 1.2, residual = 1e-8))
  expect_true(isTRUE(hsquared:::hs_fit_boundary_flag(fit)))
  diag <- fit_diagnostics(fit)
  expect_equal(diag$value[diag$metric == "at_boundary"], "TRUE")
})

test_that("multivariate variance layouts drop the boundary rows (NULL contract)", {
  fit <- hs_cov_mock_fit(
    c(0.5, 0.5),
    components = c("genetic", "residual")
  )
  expect_null(hsquared:::hs_fit_boundary_flag(fit))
  expect_null(hsquared:::hs_fit_boundary_class(fit))
  diag <- fit_diagnostics(fit)
  expect_false("at_boundary" %in% diag$metric)
  expect_false("at_boundary_condition" %in% diag$metric)
})

test_that("non-Gaussian result$boundary = FALSE surfaces search_boundary and interior condition", {
  fit <- hsquared:::hs_new_fit(
    spec = list(method = "laplace", family = list(family = "binomial")),
    payload = list(y = 1:4),
    result = list(converged = TRUE, boundary = FALSE)
  )
  diag <- fit_diagnostics(fit)
  expect_equal(diag$value[diag$metric == "search_boundary"], "FALSE")
  expect_equal(
    diag$value[diag$metric == "search_boundary_condition"],
    "interior"
  )
  expect_identical(
    hsquared:::hs_fit_search_boundary_condition_label(FALSE),
    "interior"
  )
})

test_that("hs_fit_boundary_flag respects a custom tolerance", {
  fit <- hs_cov_mock_fit(c(animal = 5e-4, residual = 1))
  expect_false(isTRUE(hsquared:::hs_fit_boundary_flag(fit, tol = 1e-4)))
  expect_true(isTRUE(hsquared:::hs_fit_boundary_flag(fit, tol = 1e-3)))
})

test_that("summary() and fit_diagnostics() agree for a metafounder near-zero layout", {
  boundary <- hsquared:::hs_new_fit(
    spec = list(method = "REML", family = list(family = "gaussian")),
    payload = list(y = 1:3),
    result = list(
      variance_components = data.frame(
        component = c("metafounder", "residual"),
        estimate = c(1e-8, 1)
      ),
      converged = TRUE
    )
  )
  summ <- summary(boundary)
  expect_identical(summ$at_boundary_class, "zero")
  expect_true(isTRUE(summ$at_boundary))
  diag <- fit_diagnostics(boundary)
  expect_equal(diag$value[diag$metric == "at_boundary"], "TRUE")
})

test_that("hs_fit_search_boundary_flag drops a non-scalar boundary field", {
  fit <- hsquared:::hs_new_fit(
    spec = list(method = "laplace", family = list(family = "poisson")),
    payload = list(y = 1:3),
    result = list(converged = TRUE, boundary = c(TRUE, FALSE))
  )
  expect_null(hsquared:::hs_fit_search_boundary_flag(fit))
  diag <- fit_diagnostics(fit)
  expect_false("search_boundary" %in% diag$metric)
})
