# Guard messages of the v0.9 non-Gaussian three-field bridge helpers that no
# other test asserts.  All helpers are private and need no Julia session.

ng09_guard_payload <- function(n = 4L) {
  X <- matrix(1, nrow = n, ncol = 1L, dimnames = list(NULL, "(Intercept)"))
  structure(
    list(
      y = rep(c(0, 1), length.out = n),
      X = X,
      metadata = list(fixed_colnames = "(Intercept)")
    ),
    class = c("hs_bridge_payload", "list")
  )
}

ng09_guard_raw <- function(family = "poisson", n_trials = NULL) {
  components <- c(V_A = 0.4, V_RE = 0, V_O = 0)
  list(
    schema = "nongaussian_three_field_v09",
    family = family,
    method = "laplace",
    loglik = -12.5,
    converged = TRUE,
    boundary = FALSE,
    breeding_ids = c("a", "b"),
    breeding_values = c(0.1, -0.1),
    components = components,
    fixed_effects = c("(Intercept)" = 0.3),
    h2_latent = 1,
    h2_liability = 0.4 / (0.4 + pi^2 / 3),
    h2_observation = 0.125,
    h2_observation_undefined_reason = NULL,
    n_trials = n_trials
  )
}

ng09_guard_normalize <- function(raw, payload = ng09_guard_payload()) {
  hsquared:::hs_normalize_nongaussian_three_field_v09(raw, payload)
}

test_that("hs_ng09_converged() rejects a non-logical converged flag", {
  expect_error(
    hsquared:::hs_ng09_converged(list(converged = "yes")),
    "`converged` must be one non-missing logical value.",
    fixed = TRUE
  )
  expect_error(
    hsquared:::hs_ng09_converged(list(converged = NA)),
    "`converged` must be one non-missing logical value.",
    fixed = TRUE
  )
})

test_that("hs_ng09_boundary() rejects a non-logical boundary flag", {
  expect_error(
    hsquared:::hs_ng09_boundary(list(boundary = 1)),
    "`boundary` must be one non-missing logical value.",
    fixed = TRUE
  )
})

test_that("the Julia command builder rejects an unknown family symbol", {
  expect_error(
    hsquared:::hs_nongaussian_three_field_julia_command("gamma", "laplace"),
    "Invalid v0.9 non-Gaussian engine family.",
    fixed = TRUE
  )
})

test_that("the normalizer rejects a wrong schema name", {
  raw <- ng09_guard_raw()
  raw$schema <- "something_else"
  expect_error(
    ng09_guard_normalize(raw),
    "`schema` must equal `nongaussian_three_field_v09`.",
    fixed = TRUE
  )
})

test_that("the normalizer requires a payload carrying the response", {
  expect_error(
    ng09_guard_normalize(ng09_guard_raw(), payload = list(X = 1)),
    "a payload with response `y` is required for normalization.",
    fixed = TRUE
  )
})

test_that("the normalizer rejects an unsupported family", {
  expect_error(
    ng09_guard_normalize(ng09_guard_raw(family = "gamma")),
    "`family` must be one of poisson, bernoulli, or binomial.",
    fixed = TRUE
  )
})

test_that("the normalizer rejects n_trials on a Bernoulli envelope", {
  expect_error(
    ng09_guard_normalize(ng09_guard_raw(family = "bernoulli", n_trials = 5L)),
    "Bernoulli requires present `nothing` for n_trials.",
    fixed = TRUE
  )
})

test_that("the normalizer rejects a logit observation h2 above one", {
  raw <- ng09_guard_raw(family = "binomial", n_trials = 5L)
  raw$h2_observation <- 1.5
  expect_error(
    ng09_guard_normalize(raw),
    "logit `h2_observation` must lie in [0, 1].",
    fixed = TRUE
  )
})

test_that("hs_ng09_validate_trials() rejects a scalar n_trials of one", {
  expect_error(
    hsquared:::hs_ng09_validate_trials(1L, 4L),
    "Binomial scalar `n_trials` must be greater than one.",
    fixed = TRUE
  )
})

test_that("hs_ng09_validate_trials() rejects a vector of the wrong length", {
  expect_error(
    hsquared:::hs_ng09_validate_trials(c(2L, 3L), 4L),
    "Binomial `n_trials` vector must have response length.",
    fixed = TRUE
  )
})

test_that("hs_ng09_validate_trials() rejects an all-one trials vector", {
  expect_error(
    hsquared:::hs_ng09_validate_trials(c(1L, 1L, 1L, 1L), 4L),
    "All-one trials are Bernoulli and must not carry n_trials.",
    fixed = TRUE
  )
})

test_that("the admission helper requires an R family object", {
  expect_error(
    hsquared:::hs_validate_nongaussian_three_field_v09_admission(
      ng09_guard_payload(),
      family = "poisson"
    ),
    "`family` must be an R family object.",
    fixed = TRUE
  )
})
