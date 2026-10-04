test_that("structured v2 metadata preserves a valid result contract", {
  payload <- list(y = c(1, 2, 3), X = matrix(1, 3, 1))
  raw <- list(
    df = 5L, nobs = 3L, method = "REML", optimizer_status = "converged",
    loglik_convention = "reml_omit_2pi",
    loglik_full_constant_offset = -log(2 * pi),
    loglik_comparable_across_routes = FALSE,
    loglik_stochastic = FALSE, converged = TRUE
  )
  metadata <- hsquared:::hs_validate_v2_result_metadata(
    raw, payload, expected_df = 5L, target = "multi_effect"
  )
  expect_identical(metadata$df, 5L)
  expect_identical(metadata$nobs, 3L)
  expect_identical(metadata$diagnostics$method, "REML")
  expect_identical(metadata$diagnostics$loglik_convention, "reml_omit_2pi")
  expect_false(metadata$diagnostics$loglik_comparable_across_routes)
  expect_false(metadata$diagnostics$loglik_stochastic)

  expect_error(hsquared:::hs_validate_v2_result_metadata(
    within(raw, rm(df)), payload, 5L, "multi_effect"), "df"
  )
  expect_error(hsquared:::hs_validate_v2_result_metadata(
    modifyList(raw, list(df = NA_integer_)), payload, 5L, "multi_effect"), "df"
  )
  expect_error(hsquared:::hs_validate_v2_result_metadata(
    modifyList(raw, list(df = 6L)), payload, 5L, "multi_effect"), "df"
  )
  expect_error(hsquared:::hs_validate_v2_result_metadata(
    modifyList(raw, list(nobs = 2L)), payload, 5L, "multi_effect"), "nobs"
  )
  expect_error(hsquared:::hs_validate_v2_result_metadata(
    within(raw, rm(loglik_convention)), payload, 5L, "multi_effect"),
    "loglik_convention"
  )
  expect_error(hsquared:::hs_validate_v2_result_metadata(
    modifyList(raw, list(method = "ML")), payload, 5L, "multi_effect"),
    "method"
  )
  expect_error(hsquared:::hs_validate_v2_result_metadata(
    modifyList(raw, list(loglik_full_constant_offset = 0)), payload, 5L,
    "multi_effect"), "loglik_full_constant_offset"
  )
  expect_error(hsquared:::hs_validate_v2_result_metadata(
    modifyList(raw, list(loglik_stochastic = NA)), payload, 5L,
    "multi_effect"), "loglik_stochastic"
  )
  expect_error(hsquared:::hs_validate_v2_result_metadata(
    modifyList(raw, list(loglik_comparable_across_routes = FALSE,
                         loglik_stochastic = TRUE)), payload, 5L,
    "multi_effect"), "loglik_mcse"
  )
})

test_that("structured normalizers retain engine df and objective provenance", {
  payload <- list(
    y = c(1, 2, 3), X = matrix(1, 3, 1),
    metadata = list(fixed_colnames = "(Intercept)"),
    random_effects = list(
      list(name = "animal", ids = "a"),
      list(name = "env1", ids = "e1"),
      list(name = "env2", ids = "e2")
    )
  )
  metadata <- list(
    df = 5L, nobs = 3L, method = "REML", optimizer_status = "converged",
    loglik_convention = "reml_omit_2pi",
    loglik_full_constant_offset = -log(2 * pi),
    loglik_comparable_across_routes = FALSE,
    loglik_stochastic = FALSE, converged = TRUE
  )
  multi_raw <- c(metadata, list(
    block_names = c("animal", "env1", "env2"),
    block_variances = c(1, 2, 3), residual = 4, beta = 0,
    loglik = -10
  ))
  multi <- hsquared:::hs_normalize_n_effect_result(
    multi_raw, list("a", "e1", "e2"), list(0, 0, 0), payload
  )
  expect_identical(multi$df, 5L)
  expect_identical(multi$nobs, 3L)
  expect_identical(multi$diagnostics$loglik_convention, "reml_omit_2pi")
  expect_false(multi$diagnostics$loglik_comparable_across_routes)
  truncated <- modifyList(multi_raw, list(
    block_names = c("animal", "env1"), block_variances = c(1, 2), df = 4L
  ))
  expect_error(hsquared:::hs_normalize_n_effect_result(
    truncated, list("a", "e1"), list(0, 0), payload
  ), "block names")
  permuted <- modifyList(multi_raw, list(
    block_names = c("env1", "animal", "env2")
  ))
  expect_error(hsquared:::hs_normalize_n_effect_result(
    permuted, list("e1", "a", "e2"), list(0, 0, 0), payload
  ), "block names")
  expect_error(hsquared:::hs_normalize_n_effect_result(
    multi_raw, list("wrong", "e1", "e2"), list(0, 0, 0), payload
  ), "random-effect IDs")

  dm_raw <- c(metadata, list(
    direct_variance = 1, partner_variance = 2, covariance = 0.1,
    correlation = 0.1 / sqrt(2), residual = 3, loglik = -10
  ))
  dm <- hsquared:::hs_normalize_direct_maternal_result(
    dm_raw, "a", 0, "a", 0, 0, payload
  )
  expect_identical(dm$df, 5L)
  expect_identical(dm$nobs, 3L)
  expect_identical(dm$diagnostics$loglik_convention, "reml_omit_2pi")

  fit <- hsquared:::hs_new_fit(
    spec = list(target = "multi_effect"), payload = payload,
    result = multi
  )
  expect_identical(attr(stats::logLik(fit), "df"), 5L)
  expect_identical(
    attr(stats::logLik(fit), "loglik_convention"), "reml_omit_2pi"
  )
  expect_error(stats::AIC(fit), "not comparable")

  full_raw <- modifyList(multi_raw, list(
    loglik_convention = "reml_full_constant",
    loglik_full_constant_offset = 0,
    loglik_comparable_across_routes = TRUE
  ))
  full <- hsquared:::hs_normalize_n_effect_result(
    full_raw, list("a", "e1", "e2"), list(0, 0, 0), payload
  )
  full_fit <- hsquared:::hs_new_fit(
    spec = list(target = "multi_effect"), payload = payload,
    result = full
  )
  expect_identical(attr(stats::logLik(full_fit), "df"), 5L)
  expect_true(is.finite(stats::AIC(full_fit)))
  expect_s3_class(stats::AIC(full_fit, full_fit), "data.frame")
  expect_error(stats::AIC(full_fit, fit), "not comparable")
  expect_error(stats::AIC(fit, full_fit), "not comparable")
  laplace_fit <- full_fit
  laplace_fit$result$marginal_method <- "laplace"
  variational_fit <- full_fit
  variational_fit$result$marginal_method <- "variational"
  expect_error(
    stats::AIC(laplace_fit, variational_fit),
    "marginal method"
  )
  changed_design <- full_fit
  changed_design$payload$X <- cbind(1, c(0, 1, 0))
  expect_error(stats::AIC(full_fit, changed_design), "fixed-effect design")
  expect_error(stats::AIC(full_fit, 1), "requires every model")

  stochastic_raw <- modifyList(full_raw, list(
    loglik_comparable_across_routes = FALSE, loglik_stochastic = TRUE,
    loglik_mcse = 0.15
  ))
  stochastic <- hsquared:::hs_normalize_n_effect_result(
    stochastic_raw, list("a", "e1", "e2"), list(0, 0, 0), payload
  )
  stochastic_fit <- hsquared:::hs_new_fit(
    spec = list(target = "multi_effect"), payload = payload,
    result = stochastic
  )
  expect_equal(stochastic$diagnostics$loglik_mcse, 0.15)
  expect_error(stats::logLik(stochastic_fit), "stochastic")
})

test_that("live direct-maternal bridge keeps engine objective metadata", {
  hs_skip_live_julia()
  testthat::skip_if_not(hsquared:::hs_julia_bridge_available(),
                        "Julia bridge unavailable")
  ped <- data.frame(
    id = paste0("g", 1:6),
    sire = c(NA, NA, "g1", "g1", "g2", "g2"),
    dam = c(NA, NA, "g2", "g2", "g1", "g1")
  )
  dat <- data.frame(
    y = c(1.2, 0.8, 2.1, 1.9, 1.5, 2.3, 1.7, 0.9),
    id = rep(paste0("g", 3:6), 2),
    dam = rep(c("g2", "g2", "g1", "g1"), 2)
  )
  fit <- hsquared(
    y ~ animal(1 | id, pedigree = ped) + maternal_genetic(1 | dam),
    data = dat,
    family = stats::gaussian(),
    control = hs_control(
      engine = "julia",
      engine_control = list(target = "direct_maternal")
    )
  )
  # One fixed intercept plus four covariance parameters.
  expect_identical(fit$result$df, 5L)
  expect_identical(fit$result$nobs, 8L)
  expect_identical(fit$result$diagnostics$method, "REML")
  expect_identical(fit$result$diagnostics$loglik_convention,
                   "reml_omit_2pi")
  expect_false(fit$result$diagnostics$loglik_comparable_across_routes)
  expect_identical(attr(stats::logLik(fit), "df"), 5L)
  expect_error(stats::AIC(fit), "not comparable")
})
