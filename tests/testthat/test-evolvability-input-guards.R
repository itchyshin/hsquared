# Input guards of the G-matrix geometry extractors that the main evolvability
# tests leave unasserted: non-fit objects and non-finite / zero directions.

hs_guard_fit <- function() {
  hsquared:::hs_new_fit(
    spec = list(
      method = "REML",
      family = list(family = "gaussian"),
      target = "multivariate"
    ),
    payload = list(Y = matrix(0, 4, 2)),
    result = list(genetic_covariance = matrix(c(2, 0.5, 0.5, 1), 2, 2))
  )
}

test_that("geometry extractors name themselves when given a non-fit", {
  expect_error(respondability(1, c(1, 0)), "`respondability\\(\\)` requires")
  expect_error(
    conditional_evolvability(list(), c(1, 0)),
    "`conditional_evolvability\\(\\)` requires"
  )
  expect_error(mean_evolvability("x"), "`mean_evolvability\\(\\)` requires")
  expect_error(
    variance_along_gradient(NULL, c(1, 0)),
    "`variance_along_gradient\\(\\)` requires"
  )
})

test_that("direction guards reject non-numeric, non-finite and zero input", {
  fit <- hs_guard_fit()

  expect_error(respondability(fit, c("a", "b")), "numeric vector")
  expect_error(respondability(fit, c(1, NA)), "only finite values")
  expect_error(respondability(fit, c(Inf, 1)), "only finite values")
  expect_error(respondability(fit, c(0, 0)), "nonzero")
  expect_error(
    variance_along_gradient(fit, c(NA, 1)),
    "only finite values"
  )
  expect_error(variance_along_gradient(fit, c(0, 0)), "nonzero")
  expect_error(variance_along_gradient(fit, "a"), "numeric vector")
  expect_error(variance_along_gradient(fit, c(1, 2, 3)), "one entry per trait")

  expect_error(
    variance_along_gradient(fit, c(1, NA), normalize = FALSE),
    "finite numeric vector"
  )
  expect_error(
    variance_along_gradient(fit, c(Inf, 1), normalize = FALSE),
    "finite numeric vector"
  )
  expect_error(
    variance_along_gradient(fit, "a", normalize = FALSE),
    "finite numeric vector"
  )
  expect_error(
    variance_along_gradient(fit, c(1, 2, 3), normalize = FALSE),
    "one entry per trait"
  )
})
