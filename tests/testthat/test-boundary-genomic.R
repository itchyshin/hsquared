test_that("fit_diagnostics flags a near-zero genomic variance component", {
  boundary <- hsquared:::hs_new_fit(
    spec = list(
      method = "REML",
      family = list(family = "gaussian"),
      target = "genomic"
    ),
    payload = list(y = 1:3),
    result = list(
      variance_components = data.frame(
        component = c("genomic", "residual"),
        estimate = c(1e-8, 1.2)
      ),
      converged = TRUE
    )
  )
  diag <- fit_diagnostics(boundary)
  expect_equal(diag$value[diag$metric == "at_boundary"], "TRUE")
})

test_that("fit_diagnostics flags a near-zero single-step variance component", {
  boundary <- hsquared:::hs_new_fit(
    spec = list(
      method = "REML",
      family = list(family = "gaussian"),
      target = "single_step"
    ),
    payload = list(y = 1:3),
    result = list(
      variance_components = data.frame(
        component = c("single_step", "residual"),
        estimate = c(0, 0.8)
      ),
      converged = TRUE
    )
  )
  diag <- fit_diagnostics(boundary)
  expect_equal(diag$value[diag$metric == "at_boundary"], "TRUE")
})

test_that("fit_diagnostics does not flag an interior genomic fit", {
  interior <- hsquared:::hs_new_fit(
    spec = list(
      method = "REML",
      family = list(family = "gaussian"),
      target = "genomic"
    ),
    payload = list(y = 1:3),
    result = list(
      variance_components = data.frame(
        component = c("genomic", "residual"),
        estimate = c(0.5, 0.5)
      ),
      converged = TRUE
    )
  )
  diag <- fit_diagnostics(interior)
  expect_equal(diag$value[diag$metric == "at_boundary"], "FALSE")
})
