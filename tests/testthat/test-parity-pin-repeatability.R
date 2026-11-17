# PARITY-MAP row 9: the opt-in repeatability (permanent-environment) bridge
# must return the same variance components and REML logLik as a direct
# HSquared.jl fit_repeatability_reml() call on the same data. Live Julia only.
#
# Data: the 30-animal engine-parity pedigree, 3 records per animal, simulated
# with seed 2 (all three variances interior at the optimum; seeds 3 and 8 put
# sigma_a2 on the zero boundary). If an engine change moves this fit to a
# boundary, update the test on purpose; do not search for another seed.

test_that("repeatability bridge variance components and logLik match a direct HSquared.jl fit [live]", {
  hs_skip_live_julia()
  testthat::skip_if_not(
    hsquared:::hs_julia_bridge_available(),
    "JuliaCall, Julia, and local HSquared.jl are required for the live repeatability parity pin."
  )

  sim <- hs_pin_simulate(2, k = 3, var_a = 1, var_pe = 0.7)
  fit <- hsquared(
    y ~ sex + animal(1 | id, pedigree = sim$ped) + permanent(1 | id),
    data = sim$data,
    family = stats::gaussian(),
    control = hs_control(
      engine = "julia",
      engine_control = list(target = "repeatability")
    )
  )

  hs_pin_julia_assign(sim$ped, sim$data)
  # Same start as the bridge default (all variances 1). The engine's own default
  # start differs and Nelder-Mead then stops ~1e-5 (relative) away on this flat
  # REML surface; with the same start the two fits are identical.
  JuliaCall::julia_command(paste(
    "hsq_pin_fit = HSquared.fit_repeatability_reml(",
    "hsq_pin_y, hsq_pin_X, hsq_pin_Z, hsq_pin_Ainv;",
    "initial = (sigma_a2 = 1.0, sigma_pe2 = 1.0, sigma_e2 = 1.0), ids = hsq_pin_ped.ids);"
  ))
  direct <- JuliaCall::julia_eval(paste(
    "Float64[hsq_pin_fit.variance_components.sigma_a2,",
    "hsq_pin_fit.variance_components.sigma_pe2,",
    "hsq_pin_fit.variance_components.sigma_e2, hsq_pin_fit.loglik]"
  ))
  expect_true(JuliaCall::julia_eval("hsq_pin_fit.converged"))
  expect_true(all(direct[1:3] > 1e-6)) # interior optimum, not a boundary fit

  vc <- variance_components(fit)
  expect_equal(vc$component, c("animal", "permanent", "residual"))
  hs_pin_expect_rel(vc$estimate[1], direct[[1]], "sigma_a2")
  hs_pin_expect_rel(vc$estimate[2], direct[[2]], "sigma_pe2")
  hs_pin_expect_rel(vc$estimate[3], direct[[3]], "sigma_e2")
  hs_pin_expect_rel(as.numeric(stats::logLik(fit)), direct[[4]], "logLik")
})
