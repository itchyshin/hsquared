# PARITY-MAP row 8: the opt-in sparse_reml bridge must return the same variance
# components and REML logLik as a direct HSquared.jl fit_sparse_reml() call, and
# the same REML logLik as the pinned fit_ai_reml() engine-parity fixture
# (written by HSquared.jl with no R and no bridge). Live Julia only.
#
# Data: the 30-animal engine-parity fixture (pedigree.csv, phenotypes.csv).
# Not the Mrode Ch.3 data: fit_sparse_reml does not converge there
# (HSquared.jl#497).

test_that("sparse_reml bridge variance components and logLik match a direct HSquared.jl fit, and logLik matches the ai_reml fixture [live]", {
  hs_skip_live_julia()
  testthat::skip_if_not(
    hsquared:::hs_julia_bridge_available(),
    "JuliaCall, Julia, and local HSquared.jl are required for the live sparse_reml parity pin."
  )

  fx <- function(file) {
    utils::read.csv(
      testthat::test_path("fixtures", "animal_model_engine_parity", file),
      stringsAsFactors = FALSE,
      na.strings = ""
    )
  }
  ped <- fx("pedigree.csv")
  ph <- fx("phenotypes.csv")
  fixture_meta <- fx("expected_metadata.csv")
  fixture_loglik <- as.numeric(
    fixture_meta$value[fixture_meta$key == "loglik"]
  )

  fit <- hsquared(
    y ~ sex + animal(1 | id, pedigree = ped),
    data = ph,
    family = stats::gaussian(),
    REML = TRUE,
    control = hs_control(
      engine = "julia",
      engine_control = list(target = "sparse_reml")
    )
  )
  expect_equal(fit$spec$target, "sparse_reml")

  hs_pin_julia_assign(ped, ph)
  # Same start as the bridge default (both variances 1).
  JuliaCall::julia_command(paste(
    "hsq_pin_spec = HSquared.animal_model_spec(",
    "hsq_pin_y, hsq_pin_X, hsq_pin_Z, hsq_pin_Ainv;",
    "ids = hsq_pin_ped.ids, method = :REML);",
    "hsq_pin_fit = HSquared.fit_sparse_reml(hsq_pin_spec;",
    "initial = (sigma_a2 = 1.0, sigma_e2 = 1.0), iterations = 1000);"
  ))
  direct <- JuliaCall::julia_eval(paste(
    "Float64[hsq_pin_fit.variance_components.sigma_a2,",
    "hsq_pin_fit.variance_components.sigma_e2, hsq_pin_fit.likelihood.loglik]"
  ))
  expect_true(JuliaCall::julia_eval("hsq_pin_fit.converged"))

  vc <- variance_components(fit)
  expect_equal(vc$component, c("animal", "residual"))
  hs_pin_expect_rel(vc$estimate[1], direct[[1]], "sigma_a2 vs direct")
  hs_pin_expect_rel(vc$estimate[2], direct[[2]], "sigma_e2 vs direct")
  hs_pin_expect_rel(
    as.numeric(stats::logLik(fit)),
    direct[[3]],
    "logLik vs direct"
  )

  # The REML logLik also matches the independent fit_ai_reml fixture. The
  # variance components do NOT agree to 1e-6 with that fixture (sparse_reml:
  # 1.144532, 0.833295; ai_reml: 1.144465, 0.833353; relative 6e-5 / 7e-5, a
  # different optimizer on a flat surface), so they are deliberately not pinned
  # to it here.
  hs_pin_expect_rel(
    as.numeric(stats::logLik(fit)),
    fixture_loglik,
    "logLik vs ai_reml fixture"
  )
})
