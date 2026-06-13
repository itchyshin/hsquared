test_that("Julia bridge availability check is conservative", {
  expect_false(hsquared:::hs_julia_bridge_available(project = tempfile()))
})

test_that("experimental Julia bridge smoke fits the tiny payload", {
  testthat::skip_on_cran()
  testthat::skip_if_not(
    hsquared:::hs_julia_bridge_available(),
    "JuliaCall, Julia, and local HSquared.jl are required for live bridge smoke."
  )

  ped <- data.frame(
    id = c("sire", "dam", "calf"),
    sire = c(NA, NA, "sire"),
    dam = c(NA, NA, "dam")
  )
  dat <- data.frame(
    y = c(1, 2.5, 4),
    id = c("sire", "dam", "calf")
  )
  spec <- hsquared:::hs_build_model_spec(
    y ~ animal(1 | id, pedigree = ped),
    data = dat,
    family = stats::gaussian(),
    REML = FALSE
  )
  payload <- hsquared:::hs_build_bridge_payload(spec)

  fit <- hsquared:::hs_fit_julia_payload(
    payload,
    initial = c(sigma_a2 = 0.8, sigma_e2 = 0.4)
  )

  expect_s3_class(fit, "hsquared_fit")
  expect_true(fit$result$converged)
  expect_equal(fit$result$nobs, 3L)
  expect_true(is.finite(fit$result$loglik))
  expect_equal(
    fit$result$variance_components$component,
    c("animal", "residual")
  )
  expect_true(all(fit$result$variance_components$estimate >= 0))
  expect_equal(breeding_values(fit)$id, c("sire", "dam", "calf"))
  expect_equal(names(fixef(fit)), "(Intercept)")
  expect_true(is.finite(heritability(fit)$estimate))
  expect_s3_class(stats::logLik(fit), "logLik")
})

test_that("experimental Julia bridge refuses large dense validation payloads", {
  ped <- data.frame(
    id = c("sire", "dam", "calf"),
    sire = c(NA, NA, "sire"),
    dam = c(NA, NA, "dam")
  )
  dat <- data.frame(y = c(1, 2.5, 4), id = c("sire", "dam", "calf"))
  spec <- hsquared:::hs_build_model_spec(
    y ~ animal(1 | id, pedigree = ped),
    data = dat,
    family = stats::gaussian(),
    REML = FALSE
  )
  payload <- hsquared:::hs_build_bridge_payload(spec)

  testthat::skip_if_not(
    hsquared:::hs_julia_bridge_available(),
    "Julia availability is checked before dense-size guard."
  )
  expect_error(
    hsquared:::hs_fit_julia_payload(payload, max_dense_cells = 1L),
    "densifies `Z`",
    fixed = TRUE
  )
})
