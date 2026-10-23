# Known-truth G0 and P0 recovery for cbind() + permanent() (hsquared #237).
# Live Julia; never falls back to animal-only fit_multivariate_reml.
# Experimental 0.9.0; public_covered_count stays 7.
# Official 8-seed |bias|<=2*MCSE screen:
#   HSquared.jl sim/phase4_multivariate_repeatability_recovery.jl

test_that("cbind + permanent recovers known G0 and P0 on a pinned seed", {
  hs_skip_live_julia()
  hs_237_point_julia_recovery()
  skip_if_not(
    hsquared:::hs_julia_bridge_available(),
    "JuliaCall, Julia, and local HSquared.jl are required."
  )
  hsquared:::hs_julia_setup(hsquared:::hs_default_julia_project())
  skip_if_not(
    isTRUE(JuliaCall::julia_eval(
      "isdefined(HSquared, :fit_multivariate_repeatability_reml)"
    )),
    "Need fit_multivariate_repeatability_reml (HSquared.jl#398)."
  )

  fx <- hs_237_simulate_mvpe(seed = 20260926L)
  truth <- fx$truth
  fit <- suppressWarnings(hs_237_fit_mvpe(fx))
  expect_equal(fit$spec$target, "multivariate_repeatability")
  expect_equal(
    fit$result$diagnostics$target,
    "multivariate_repeatability_reml"
  )
  expect_false(identical(
    fit$result$diagnostics$target,
    "multivariate_reml"
  ))
  vc <- variance_components(fit)
  expect_true(all(c("animal", "permanent", "residual") %in% vc$component))
  g11 <- hs_237_vc_diag(fit, "animal", "y1")
  p11 <- hs_237_vc_diag(fit, "permanent", "y1")
  r11 <- hs_237_vc_diag(fit, "residual", "y1")
  expect_true(is.finite(g11))
  expect_true(is.finite(p11))
  expect_lt(abs(g11 - truth$G0[1, 1]), 0.8)
  expect_lt(abs(p11 - truth$P0[1, 1]), 0.8)
  expect_lt(abs(r11 - truth$R0[1, 1]), 0.5)
  expect_equal(fit$result$genetic_covariance[1, 1], g11)
  expect_equal(fit$result$permanent_covariance[1, 1], p11)
})
