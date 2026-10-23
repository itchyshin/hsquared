# Same-estimand sommer comparator for cbind() + permanent() (hsquared #237).
# Engine vs sommer animal + identity PE on one generated dataset. Not a covered flip.

test_that("sommer animal + identity PE agrees with multivariate_repeatability", {
  testthat::skip_on_cran()
  hs_skip_live_julia()
  hs_require_suggests("sommer", gate = "MV-PE-1")
  hs_require_suggests("nadiv", gate = "MV-PE-1")
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
  engine <- suppressWarnings(hs_237_fit_mvpe(fx))
  expect_equal(engine$spec$target, "multivariate_repeatability")
  expect_false(identical(
    engine$result$diagnostics$target,
    "multivariate_reml"
  ))

  sm <- tryCatch(
    hs_237_sommer_mvpe(fx),
    error = function(e) e
  )
  if (inherits(sm, "error")) {
    testthat::skip(paste(
      "sommer mmer animal+PE did not fit:",
      conditionMessage(sm)
    ))
  }
  if (is.null(sm$G0) || is.null(sm$P0)) {
    testthat::skip(
      paste(
        "sommer sigma layout changed; names were",
        paste(names(sm$fit$sigma), collapse = ", ")
      )
    )
  }
  g_engine <- hs_237_vc_diag(engine, "animal", "y1")
  p_engine <- hs_237_vc_diag(engine, "permanent", "y1")
  expect_lt(abs(sm$G0[1, 1] - g_engine), 0.35)
  expect_lt(abs(sm$P0[1, 1] - p_engine), 0.35)
})
