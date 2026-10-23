# Guard messages in R/julia-bridge.R that no other test asserts. Every guard is
# reached without a Julia engine by calling the internal helper directly.

hs_fa_guard_fixture <- function() {
  traits <- paste0("t", 1:4)
  G <- diag(2, 4) + 0.3
  R <- diag(1, 4)
  raw <- list(
    traits = traits,
    genetic_covariance = G,
    residual_covariance = R,
    genetic_correlation = stats::cov2cor(G),
    residual_correlation = R,
    genetic_uniqueness = rep(2, 4),
    genetic_rank = 1L,
    genetic_uniqueness_identification = "not_assessed_by_fit",
    heritability = diag(G) / (diag(G) + 1),
    beta = matrix(0, 1, 4),
    breeding_ids = c("a", "b"),
    breeding_traits = traits,
    breeding_values = matrix(0, 2, 4),
    genetic_structure = "factor_analytic",
    loglik = -30,
    converged = TRUE,
    iterations = 10L,
    fa_start_strategy = "default_and_balanced",
    fa_start_starts_attempted = 2L,
    fa_start_selected_start = "balanced",
    fa_start_objective_range = 0.5,
    fa_start_g_relative_disagreement = 0.02,
    fa_start_r_relative_disagreement = 0.03,
    fa_start_better_nonconverged_start = FALSE,
    fa_start_minimum_uniqueness = 0.1,
    fa_start_uniqueness_floor_distance = 0.0999,
    fa_start_near_uniqueness_floor = FALSE,
    fa_start_names = c("default", "balanced"),
    fa_start_loglik = c(-30.5, -30),
    fa_start_valid = c(TRUE, TRUE),
    fa_start_converged = c(TRUE, TRUE),
    fa_start_iterations = c(10L, 12L),
    fa_start_minimum_uniqueness_by_start = c(0.2, 0.1),
    fa_start_uniqueness_floor_distance_by_start = c(0.1999, 0.0999)
  )
  payload <- list(
    Y = matrix(1:8, 2, 4),
    X = matrix(1, 2, 1),
    ids = c("a", "b"),
    metadata = list(fixed_colnames = "(Intercept)", trait_names = traits)
  )
  list(raw = raw, payload = payload)
}

test_that("the FA fixture normalizes cleanly (the guard tests start from it)", {
  fx <- hs_fa_guard_fixture()
  expect_no_error(
    hsquared:::hs_normalize_multivariate_result(fx$raw, fx$payload)
  )
})

test_that("FA normalization rejects a non-positive start count", {
  fx <- hs_fa_guard_fixture()
  fx$raw$fa_start_starts_attempted <- 0L
  expect_error(
    hsquared:::hs_normalize_multivariate_result(fx$raw, fx$payload),
    "FA start count must be a positive integer",
    fixed = TRUE
  )
})

test_that("FA normalization rejects empty or duplicated start names", {
  fx <- hs_fa_guard_fixture()
  fx$raw$fa_start_names <- c("default", "default")
  expect_error(
    hsquared:::hs_normalize_multivariate_result(fx$raw, fx$payload),
    "FA start names must be non-empty and unique",
    fixed = TRUE
  )
  fx$raw$fa_start_names <- c("default", "")
  expect_error(
    hsquared:::hs_normalize_multivariate_result(fx$raw, fx$payload),
    "FA start names must be non-empty and unique",
    fixed = TRUE
  )
})

test_that("FA normalization rejects a selected start that is not valid", {
  fx <- hs_fa_guard_fixture()
  fx$raw$fa_start_selected_start <- "default"
  fx$raw$fa_start_valid <- c(FALSE, TRUE)
  fx$raw$fa_start_loglik <- c(NA_real_, -30)
  fx$raw$fa_start_minimum_uniqueness_by_start <- c(NA_real_, 0.1)
  fx$raw$fa_start_uniqueness_floor_distance_by_start <- c(NA_real_, 0.0999)
  expect_error(
    hsquared:::hs_normalize_multivariate_result(fx$raw, fx$payload),
    "FA selected start must be valid",
    fixed = TRUE
  )
})

test_that("marker variance explained rejects an empty marker matrix", {
  expect_error(
    hsquared:::hs_marker_variance_explained_from_snp_blup(
      numeric(0),
      matrix(numeric(0), nrow = 0L, ncol = 0L)
    ),
    "Internal bridge error: marker matrix is empty",
    fixed = TRUE
  )
})

test_that("direct-maternal initial G_dm must be a finite 2x2 matrix", {
  expect_error(
    hsquared:::hs_validate_direct_maternal_initial(
      list(G_dm = diag(3), sigma_e2 = 1)
    ),
    "`initial$G_dm` must be a finite 2x2 matrix",
    fixed = TRUE
  )
  expect_error(
    hsquared:::hs_validate_direct_maternal_initial(
      list(G_dm = matrix(c(1, NA, NA, 1), 2L), sigma_e2 = 1)
    ),
    "`initial$G_dm` must be a finite 2x2 matrix",
    fixed = TRUE
  )
})

test_that("hs_effect_targets names the unknown random effect type", {
  expect_error(
    hsquared:::hs_effect_targets("not_an_effect"),
    "Unknown random effect type: not_an_effect",
    fixed = TRUE
  )
})

test_that("hs_second_effect_target names the unknown random effect type", {
  expect_error(
    hsquared:::hs_second_effect_target("not_an_effect"),
    "Unknown random effect type: not_an_effect",
    fixed = TRUE
  )
})
