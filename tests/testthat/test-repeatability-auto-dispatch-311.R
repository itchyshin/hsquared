# hsquared#311. scale_method = "auto" must label the estimator that actually
# ran. fit_multi_effect(:auto) can silently switch to matrix-free Monte-Carlo
# EM-REML; the dropped dispatch / trace_mcse fields must stay on the fit.

hs_repeatability_auto_raw <- function(...) {
  dots <- list(...)
  raw <- list(
    sigma_a2 = 1,
    sigma_pe2 = 0.6,
    sigma_e2 = 0.8,
    heritability = 1 / 2.4,
    repeatability = 1.6 / 2.4,
    beta = 0,
    animal_ids = c("a", "b"),
    animal_values = c(0.1, -0.1),
    pe_ids = c("a", "b"),
    pe_values = c(0.2, -0.2),
    loglik = -10,
    converged = TRUE
  )
  modifyList(raw, dots)
}

hs_repeatability_auto_payload <- function() {
  list(
    y = 1:4,
    metadata = list(fixed_colnames = "(Intercept)")
  )
}

hs_repeatability_auto_fit <- function(raw) {
  result <- hsquared:::hs_normalize_repeatability_result(
    raw,
    hs_repeatability_auto_payload(),
    scale_method = "auto"
  )
  hsquared:::hs_new_fit(
    spec = list(
      method = "REML",
      family = list(family = "gaussian"),
      target = "repeatability"
    ),
    payload = hs_repeatability_auto_payload(),
    result = result
  )
}

test_that("auto exact dispatch keeps the sparse AI-REML provenance label", {
  out <- hsquared:::hs_normalize_repeatability_result(
    hs_repeatability_auto_raw(
      dispatch = "exact",
      estimator = "sparse_multi_effect_aireml"
    ),
    hs_repeatability_auto_payload(),
    scale_method = "auto"
  )
  expect_identical(
    out$diagnostics$variance_components,
    "estimated_repeatability_sparse_multi_effect_aireml"
  )
  expect_identical(out$diagnostics$dispatch, "exact")
  expect_identical(out$diagnostics$estimator, "sparse_multi_effect_aireml")
  expect_false(isTRUE(out$diagnostics$loglik_stochastic))
  expect_null(out$diagnostics$trace_mcse)
})

test_that("auto matrix-free dispatch labels MC-REML and keeps the dropped fields", {
  raw <- hs_repeatability_auto_raw(
    dispatch = "matrix_free",
    estimator = "matrix_free_mc_em_reml",
    loglik = NaN,
    loglik_mcse = NaN,
    trace_mcse = c(0.04, 0.03)
  )
  expect_warning(
    out <- hsquared:::hs_normalize_repeatability_result(
      raw,
      hs_repeatability_auto_payload(),
      scale_method = "auto"
    ),
    "matrix-free Monte-Carlo EM-REML"
  )
  expect_identical(
    out$diagnostics$variance_components,
    "estimated_repeatability_matrix_free_mc_em_reml"
  )
  expect_identical(out$diagnostics$dispatch, "matrix_free")
  expect_identical(out$diagnostics$estimator, "matrix_free_mc_em_reml")
  expect_equal(out$diagnostics$trace_mcse, c(0.04, 0.03))
  expect_true(out$diagnostics$loglik_stochastic)
})

test_that("auto matrix-free dispatch refuses logLik() instead of returning NaN", {
  expect_warning(
    fit <- hs_repeatability_auto_fit(hs_repeatability_auto_raw(
      dispatch = "matrix_free",
      estimator = "matrix_free_mc_em_reml",
      loglik = NaN,
      trace_mcse = c(0.02, 0.01)
    )),
    "matrix-free Monte-Carlo EM-REML"
  )
  expect_error(stats::logLik(fit), "stochastic")
})

test_that("auto route warns when the engine drops dispatch", {
  expect_warning(
    out <- hsquared:::hs_normalize_repeatability_result(
      hs_repeatability_auto_raw(),
      hs_repeatability_auto_payload(),
      scale_method = "auto"
    ),
    "`dispatch`"
  )
  expect_null(out$diagnostics$dispatch)
})

test_that("auto matrix-free route warns when trace_mcse vanishes", {
  expect_warning(
    expect_warning(
      out <- hsquared:::hs_normalize_repeatability_result(
        hs_repeatability_auto_raw(
          dispatch = "matrix_free",
          estimator = "matrix_free_mc_em_reml",
          loglik = NaN
        ),
        hs_repeatability_auto_payload(),
        scale_method = "auto"
      ),
      "`trace_mcse`"
    ),
    "matrix-free Monte-Carlo EM-REML"
  )
  expect_identical(out$diagnostics$dispatch, "matrix_free")
  expect_null(out$diagnostics$trace_mcse)
  expect_true(out$diagnostics$loglik_stochastic)
})

test_that("dense repeatability provenance is unchanged", {
  out <- hsquared:::hs_normalize_repeatability_result(
    hs_repeatability_auto_raw(),
    hs_repeatability_auto_payload(),
    scale_method = "dense"
  )
  expect_identical(
    out$diagnostics$variance_components,
    "estimated_repeatability_reml"
  )
  expect_null(out$diagnostics$dispatch)
  expect_false(isTRUE(out$diagnostics$loglik_stochastic))
})
