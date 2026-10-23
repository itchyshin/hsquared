# hsquared#281: target = "sparse_reml" already has Julia SEs/CIs; the bridge
# must pass those existing AnimalModelFit fields through, the same way
# target = "ai_reml" does. This is not a new estimator.

test_that("sparse REML forwards the engine SE and interval slots", {
  hs_skip_live_julia()
  testthat::skip_if_not(
    hsquared:::hs_julia_bridge_available(),
    "JuliaCall, Julia, and local HSquared.jl are required for live sparse REML SE forwarding."
  )

  fixture <- hsquared:::hs_mrode_supplied_variance_validation_fixture()
  fit_target <- function(target) {
    hsquared(
      fixture$formula,
      data = fixture$data,
      family = stats::gaussian(),
      REML = TRUE,
      control = hs_control(
        engine = "julia",
        engine_control = list(
          target = target,
          initial = c(sigma_a2 = 1, sigma_e2 = 1),
          iterations = 1000L
        )
      )
    )
  }

  sparse <- fit_target("sparse_reml")
  ai <- fit_target("ai_reml")

  sparse_se <- variance_component_standard_errors(sparse)
  ai_se <- variance_component_standard_errors(ai)
  expect_equal(sparse_se$component, ai_se$component)
  expect_equal(sparse_se$se, ai_se$se, tolerance = 1e-4)

  # The 12-animal Mrode fixture reaches the same interior optimum only to
  # ~1e-3, so derived h2 SE/CI are compared a little more loosely than the
  # variance-component SEs the issue asked for.
  expect_equal(
    heritability_standard_error(sparse)$se,
    heritability_standard_error(ai)$se,
    tolerance = 1e-3
  )
  expect_equal(
    heritability_interval(sparse)[, c("lower", "upper")],
    heritability_interval(ai)[, c("lower", "upper")],
    tolerance = 1e-3
  )
})
