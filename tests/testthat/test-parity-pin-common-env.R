# PARITY-MAP row 10: the opt-in two_effect common-environment bridge must
# return the same variance components and REML logLik as a direct HSquared.jl
# fit_two_effect_reml() call on the same data. The existing live test in
# test-common-env.R only checks positivity; the 1e-6 checks there are internal
# to R. Live Julia only.
#
# Data: the 30-animal engine-parity pedigree, 2 records per animal, 15 litters
# of two consecutive animals each. Seed 1 is the first seed with all three
# variances interior at the optimum; if an engine change moves this fit to a
# boundary, update the test on purpose rather than searching for another seed.

test_that("common_env two-effect bridge variance components and logLik match a direct HSquared.jl fit [live]", {
  hs_skip_live_julia()
  testthat::skip_if_not(
    hsquared:::hs_julia_bridge_available(),
    "JuliaCall, Julia, and local HSquared.jl are required for the live common_env parity pin."
  )

  litter <- sprintf("l%02d", rep(1:15, each = 2))
  sim <- hs_pin_simulate(1, k = 2, var_a = 1, var_env = 0.8, env = litter)
  fit <- hsquared(
    y ~ sex + animal(1 | id, pedigree = sim$ped) + common_env(1 | env),
    data = sim$data,
    family = stats::gaussian(),
    control = hs_control(
      engine = "julia",
      engine_control = list(target = "two_effect")
    )
  )

  hs_pin_julia_assign(sim$ped, sim$data)
  # Same start as the bridge default (all variances 1). The engine's own default
  # start differs and Nelder-Mead then stops ~1e-5 (relative) away on this flat
  # REML surface; with the same start the two fits are identical.
  lv <- sort(unique(sim$data$env))
  Z2 <- Matrix::sparseMatrix(
    i = seq_len(nrow(sim$data)),
    j = match(sim$data$env, lv),
    x = 1,
    dims = c(nrow(sim$data), length(lv))
  )
  hsquared:::hs_julia_assign_sparse_csc("hsq_pin_Z2", Z2)
  JuliaCall::julia_assign("hsq_pin_env_levels", lv)
  JuliaCall::julia_command(paste(
    "hsq_pin_n2 = size(hsq_pin_Z2, 2);",
    "hsq_pin_Ainv2 = sparse(collect(1:hsq_pin_n2), collect(1:hsq_pin_n2),",
    "ones(Float64, hsq_pin_n2), hsq_pin_n2, hsq_pin_n2);",
    "hsq_pin_fit = HSquared.fit_two_effect_reml(",
    "hsq_pin_y, hsq_pin_X, hsq_pin_Z, hsq_pin_Ainv, hsq_pin_Z2, hsq_pin_Ainv2;",
    "initial = (sigma1 = 1.0, sigma2 = 1.0, sigma_e2 = 1.0), ids1 = hsq_pin_ped.ids, ids2 = hsq_pin_env_levels);"
  ))
  direct <- JuliaCall::julia_eval(paste(
    "Float64[hsq_pin_fit.variance_components.sigma1,",
    "hsq_pin_fit.variance_components.sigma2,",
    "hsq_pin_fit.variance_components.sigma_e2, hsq_pin_fit.loglik]"
  ))
  expect_true(JuliaCall::julia_eval("hsq_pin_fit.converged"))
  expect_true(all(direct[1:3] > 1e-6)) # interior optimum, not a boundary fit

  vc <- variance_components(fit)
  expect_equal(vc$component, c("animal", "common_env", "residual"))
  hs_pin_expect_rel(vc$estimate[1], direct[[1]], "sigma_a2")
  hs_pin_expect_rel(vc$estimate[2], direct[[2]], "sigma_c2")
  hs_pin_expect_rel(vc$estimate[3], direct[[3]], "sigma_e2")
  hs_pin_expect_rel(as.numeric(stats::logLik(fit)), direct[[4]], "logLik")
})
