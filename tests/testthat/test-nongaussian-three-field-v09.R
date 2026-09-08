# The 0.9 three-field non-Gaussian contract is deliberately tested without a
# Julia session.  It is a private wire-normalization and admission boundary;
# the legacy `nongaussian_result_payload` path remains a separate compatibility
# surface.

ng09_payload <- function(n = 4L, trials = NULL, predictors = FALSE) {
  X <- matrix(1, nrow = n, ncol = if (predictors) 2L else 1L)
  colnames(X) <- if (predictors) c("(Intercept)", "x") else "(Intercept)"
  structure(
    list(
      y = c(0, 1, 1, 0)[seq_len(n)],
      X = X,
      n_trials = trials,
      metadata = list(fixed_colnames = colnames(X))
    ),
    class = c("hs_bridge_payload", "list")
  )
}

ng09_raw <- function(family = "poisson", method = "laplace", n_trials = NULL) {
  components <- c(V_A = 0.4, V_RE = 0, V_O = 0)
  v_eta <- sum(components)
  mu <- 0.3
  list(
    schema = "nongaussian_three_field_v09",
    family = family,
    method = method,
    loglik = -12.5,
    converged = TRUE,
    breeding_ids = c("a", "b"),
    breeding_values = c(0.1, -0.1),
    components = components,
    fixed_effects = c("(Intercept)" = mu),
    h2_latent = components[["V_A"]] / v_eta,
    h2_liability = if (identical(family, "poisson")) {
      NULL
    } else {
      components[["V_A"]] / (v_eta + pi^2 / 3)
    },
    h2_observation = if (identical(family, "poisson")) {
      components[["V_A"]] / (expm1(v_eta) + exp(-(mu + v_eta / 2)))
    } else {
      NaN
    },
    h2_observation_undefined_reason = if (identical(family, "poisson")) {
      NULL
    } else {
      "not_yet_ratified"
    },
    n_trials = n_trials
  )
}

ng09_julia_raw <- function(family = "poisson", method = "laplace", n_trials = NULL) {
  raw <- ng09_raw(family = family, method = method, n_trials = n_trials)
  raw$components <- list(
    names = names(raw$components), values = unname(raw$components)
  )
  raw$fixed_effects <- list(
    names = names(raw$fixed_effects), values = unname(raw$fixed_effects)
  )
  raw
}

test_that("the v0.9 normalizer retains the three ratified Poisson fields", {
  raw <- ng09_raw()
  result <- hsquared:::hs_normalize_nongaussian_three_field_v09(
    raw,
    ng09_payload()
  )

  expect_equal(result$family, "poisson")
  expect_equal(result$marginal_method, "laplace")
  expect_equal(result$loglik_kind, "laplace marginal loglik")
  expect_identical(result$h2_latent, raw$h2_latent)
  expect_identical(result$h2_observation, raw$h2_observation)
  expect_identical(
    result$h2_observation_label,
    "count-scale observation h2 (conditional)"
  )
  expect_false("h2_liability" %in% names(result))
  expect_false("h2_observation_undefined_reason" %in% names(result))
  expect_false("n_trials" %in% names(result))
  expect_identical(result$breeding_values$id, c("a", "b"))
  expect_identical(result$breeding_values$value, c(0.1, -0.1))
  expect_identical(result$random_effects$animal, result$breeding_values)
})

test_that("the v0.9 normalizer consumes Julia names-values containers", {
  raw <- ng09_julia_raw()
  result <- hsquared:::hs_normalize_nongaussian_three_field_v09(
    raw,
    ng09_payload()
  )

  expect_identical(result$variance_components$component, c("V_A", "V_RE", "V_O"))
  expect_identical(result$fixed_effects, c("(Intercept)" = 0.3))

  reordered <- ng09_julia_raw()
  reordered$components <- reordered$components[c("values", "names")]
  reordered$fixed_effects <- reordered$fixed_effects[c("values", "names")]
  expect_silent(hsquared:::hs_normalize_nongaussian_three_field_v09(
    reordered,
    ng09_payload()
  ))
})

test_that("the v0.9 normalizer requires a truthful converged wire field", {
  raw <- ng09_julia_raw()
  result <- hsquared:::hs_normalize_nongaussian_three_field_v09(
    raw,
    ng09_payload()
  )
  expect_true(result$converged)

  bad <- raw
  bad$converged <- FALSE
  expect_error(
    hsquared:::hs_normalize_nongaussian_three_field_v09(bad, ng09_payload()),
    "converged"
  )
  bad <- raw
  bad$converged <- NULL
  expect_error(
    hsquared:::hs_normalize_nongaussian_three_field_v09(bad, ng09_payload()),
    "missing required `converged`"
  )
  bad <- raw
  bad$converged <- "yes"
  expect_error(
    hsquared:::hs_normalize_nongaussian_three_field_v09(bad, ng09_payload()),
    "converged"
  )
})

test_that("the v0.9 normalizer preserves scalar and varying Binomial trials", {
  scalar <- hsquared:::hs_normalize_nongaussian_three_field_v09(
    ng09_julia_raw("binomial", n_trials = 3L),
    ng09_payload()
  )
  expect_identical(scalar$n_trials, 3L)
  expect_true(is.nan(scalar$h2_observation))
  expect_identical(
    scalar$h2_observation_undefined_reason,
    "not_yet_ratified"
  )

  varying_trials <- c(2L, 3L, 4L, 5L)
  varying <- hsquared:::hs_normalize_nongaussian_three_field_v09(
    ng09_julia_raw("binomial", n_trials = varying_trials),
    ng09_payload()
  )
  expect_identical(varying$n_trials, varying_trials)
  expect_true(is.nan(varying$h2_observation))
  expect_identical(
    varying$h2_observation_undefined_reason,
    "not_yet_ratified"
  )
})

test_that("the v0.9 normalizer exposes only ratified labelled scale rows", {
  poisson <- hsquared:::hs_normalize_nongaussian_three_field_v09(
    ng09_julia_raw(), ng09_payload()
  )
  expect_identical(
    poisson$heritability$label,
    c("latent-scale h2 (conditional)", "count-scale observation h2 (conditional)")
  )

  logit <- hsquared:::hs_normalize_nongaussian_three_field_v09(
    ng09_julia_raw("bernoulli"), ng09_payload()
  )
  expect_identical(
    logit$heritability$label,
    c(
      "latent-scale h2 (conditional)",
      "liability-scale h2 (conditional)",
      "observation-scale h2 (not yet ratified)"
    )
  )
  expect_true(is.nan(logit$heritability$estimate[[3L]]))
  expect_identical(
    logit$heritability$undefined_reason[[3L]],
    "not_yet_ratified"
  )
})

test_that("the existing non-Gaussian target validates before Julia setup", {
  payload <- ng09_payload()
  payload$pedigree <- list(id = character(), sire = character(), dam = character())
  expect_error(
    hsquared:::hs_fit_julia_nongaussian_payload(
      payload,
      project = tempfile(),
      family = stats::Gamma()
    ),
    "admits only poisson\\(log\\) and binomial\\(logit\\)"
  )
})

test_that("the public non-Gaussian target rejects weights and dots before Julia", {
  ped <- data.frame(
    id = c("s", "d", "a", "b"),
    sire = c(NA, NA, "s", "s"),
    dam = c(NA, NA, "d", "d")
  )
  dat <- data.frame(y = c(0, 1, 2, 3), id = ped$id)
  control <- hs_control(
    engine = "julia",
    engine_control = list(target = "nongaussian", julia_project = tempfile())
  )
  expect_error(
    hsquared(
      y ~ animal(1 | id, pedigree = ped),
      data = dat,
      family = stats::poisson(),
      control = control,
      weights = rep(1, nrow(dat))
    ),
    "weights"
  )
  expect_error(
    hsquared(
      y ~ animal(1 | id, pedigree = ped),
      data = dat,
      family = stats::poisson(),
      control = control,
      offset = 0
    ),
    "does not accept"
  )
})

test_that("the v0.9 Julia command builds a complete explicit envelope", {
  command <- hsquared:::hs_nongaussian_three_field_julia_command(
    family_symbol = "binomial",
    marginal = "variational",
    n_trials = c(2L, 3L, 4L, 5L)
  )

  expect_match(command, "HSquared\\.nongaussian_three_field_payload")
  expect_match(command, "predictor_variance = 0\\.0")
  expect_match(command, "response_length = length\\(hsq_y\\)")
  expect_match(command, "n_trials = Vector\\{Int\\}\\(hsq_n_trials\\)")
  for (key in c(
    "schema", "family", "method", "loglik", "components", "fixed_effects",
    "h2_latent", "h2_liability", "h2_observation",
    "h2_observation_undefined_reason", "n_trials", "breeding_ids",
    "breeding_values", "converged"
  )) {
    expect_match(command, paste0("\\\"", key, "\\\" =>"), fixed = FALSE)
  }
  expect_match(command, "\\\"converged\\\" => hsq_fit\\.converged")
})

test_that("the v0.9 normalizer admits only literal logit NaN observation cells", {
  raw <- ng09_raw("bernoulli", method = "VA")
  result <- hsquared:::hs_normalize_nongaussian_three_field_v09(
    raw,
    ng09_payload()
  )

  expect_equal(result$marginal_method, "variational")
  expect_equal(result$loglik_kind, "elbo (variational lower bound)")
  expect_identical(result$h2_liability, raw$h2_liability)
  expect_true(is.nan(result$h2_observation))
  expect_identical(
    result$h2_observation_undefined_reason,
    "not_yet_ratified"
  )

  bad <- raw
  bad$h2_observation <- NA_real_
  expect_error(
    hsquared:::hs_normalize_nongaussian_three_field_v09(bad, ng09_payload()),
    "literal NaN"
  )
  bad <- raw
  bad$h2_observation_undefined_reason <- "not_defined"
  expect_error(
    hsquared:::hs_normalize_nongaussian_three_field_v09(bad, ng09_payload()),
    "not_yet_ratified"
  )
})

test_that("the v0.9 normalizer rejects schema and estimand mutations exactly", {
  raw <- ng09_raw()
  bad <- raw
  bad$schema <- "nongaussian_result_payload"
  expect_error(
    hsquared:::hs_normalize_nongaussian_three_field_v09(bad, ng09_payload()),
    "nongaussian_three_field_v09"
  )

  bad <- raw
  bad$h2_latent <- bad$h2_latent + 1e-15
  expect_error(
    hsquared:::hs_normalize_nongaussian_three_field_v09(bad, ng09_payload()),
    "h2_latent"
  )
  bad <- raw
  bad$h2_observation <- raw$components[["V_A"]] /
    (expm1(raw$components[["V_A"]]) +
      exp(-raw$fixed_effects[["(Intercept)"]]))
  expect_error(
    hsquared:::hs_normalize_nongaussian_three_field_v09(bad, ng09_payload()),
    "h2_observation"
  )
  bad <- raw
  bad$h2_liability <- 0
  expect_error(
    hsquared:::hs_normalize_nongaussian_three_field_v09(bad, ng09_payload()),
    "Poisson"
  )
})

test_that("the v0.9 normalizer rejects non-structural V_RE and V_O", {
  raw <- ng09_raw()
  raw$components[["V_RE"]] <- 0.01
  raw$h2_latent <- raw$components[["V_A"]] / sum(raw$components)
  raw$h2_observation <- raw$components[["V_A"]] / (
    expm1(sum(raw$components)) +
      exp(-(raw$fixed_effects[["(Intercept)"]] + sum(raw$components) / 2))
  )
  expect_error(
    hsquared:::hs_normalize_nongaussian_three_field_v09(raw, ng09_payload()),
    "structural zero"
  )

  raw <- ng09_raw()
  raw$components[["V_O"]] <- 0.01
  raw$h2_latent <- raw$components[["V_A"]] / sum(raw$components)
  raw$h2_observation <- raw$components[["V_A"]] / (
    expm1(sum(raw$components)) +
      exp(-(raw$fixed_effects[["(Intercept)"]] + sum(raw$components) / 2))
  )
  expect_error(
    hsquared:::hs_normalize_nongaussian_three_field_v09(raw, ng09_payload()),
    "structural zero"
  )
})

test_that("the v0.9 admission helper classifies all four ratified input cells", {
  poisson <- ng09_payload()
  poisson$y <- c(0, 1, 2, 3)
  expect_identical(
    hsquared:::hs_validate_nongaussian_three_field_v09_admission(
      poisson,
      stats::poisson(),
      marginal = "LA"
    ),
    list(family = "poisson", method = "laplace", n_trials = NULL)
  )

  bernoulli <- ng09_payload()
  expect_identical(
    hsquared:::hs_validate_nongaussian_three_field_v09_admission(
      bernoulli,
      stats::binomial(),
      marginal = "Variational"
    ),
    list(family = "bernoulli", method = "variational", n_trials = NULL)
  )

  common <- ng09_payload(trials = rep(3L, 4L))
  common$y <- c(0, 1, 2, 3)
  expect_identical(
    hsquared:::hs_validate_nongaussian_three_field_v09_admission(
      common,
      stats::binomial()
    ),
    list(family = "binomial", method = "laplace", n_trials = 3L)
  )

  varying <- ng09_payload(trials = c(2L, 3L, 4L, 5L))
  varying$y <- c(0, 1, 2, 3)
  expect_identical(
    hsquared:::hs_validate_nongaussian_three_field_v09_admission(
      varying,
      stats::binomial()
    ),
    list(
      family = "binomial", method = "laplace",
      n_trials = c(2L, 3L, 4L, 5L)
    )
  )
})

test_that("the v0.9 admission helper rejects predictor, trial, weight, and dot shortcuts", {
  expect_error(
    hsquared:::hs_validate_nongaussian_three_field_v09_admission(
      ng09_payload(predictors = TRUE), stats::poisson()
    ),
    "one intercept"
  )
  expect_error(
    hsquared:::hs_validate_nongaussian_three_field_v09_admission(
      ng09_payload(), stats::poisson(), predictor_variance = 0.01
    ),
    "predictor_variance"
  )
  bad_trials <- ng09_payload(trials = c(3L, 3L))
  bad_trials$y <- c(0, 1, 2, 3)
  expect_error(
    hsquared:::hs_validate_nongaussian_three_field_v09_admission(
      bad_trials, stats::binomial()
    ),
    "response length"
  )
  expect_error(
    hsquared:::hs_validate_nongaussian_three_field_v09_admission(
      ng09_payload(), stats::binomial(), weights = rep(1, 4)
    ),
    "weights"
  )
  expect_error(
    hsquared:::hs_validate_nongaussian_three_field_v09_admission(
      ng09_payload(), stats::binomial(), dots = list(offset = 1)
    ),
    "does not accept"
  )
})

test_that("the legacy non-Gaussian normalizer remains a separate compatibility path", {
  expect_true(exists("hs_normalize_nongaussian_result", envir = asNamespace("hsquared")))
  expect_false(identical(
    hsquared:::hs_normalize_nongaussian_result,
    hsquared:::hs_normalize_nongaussian_three_field_v09
  ))
})

test_that("the v0.9 Poisson route carries the three-field result through the live bridge", {
  # This is deliberately a tiny deterministic integration check, not a
  # calibration run.  Keep the candidate Julia worktree explicit so this test
  # cannot silently exercise an unrelated default checkout.
  project <- "/private/tmp/hsq09-a3-julia-plan-7770"
  hs_require_bridge("A3 v0.9 non-Gaussian bridge", project = project)

  pedigree <- data.frame(
    id = c("s", "d", "a", "b"),
    sire = c(NA, NA, "s", "s"),
    dam = c(NA, NA, "d", "d")
  )
  data <- data.frame(y = c(1, 0, 2, 1), id = pedigree$id)
  fit <- hsquared(
    y ~ animal(1 | id, pedigree = pedigree),
    data = data,
    family = stats::poisson(),
    control = hs_control(
      engine = "julia",
      engine_control = list(
        target = "nongaussian",
        julia_project = project,
        iterations = 20L
      )
    )
  )

  expect_s3_class(fit, "hsquared_fit")
  expect_identical(fit$engine, "HSquared.jl")
  expect_identical(fit$spec$target, "nongaussian")
  expect_identical(fit$result$family, "poisson")
  expect_true(isTRUE(fit$result$converged))
  expect_identical(
    fit$result$heritability$field,
    c("h2_latent", "h2_observation")
  )
  expect_identical(
    fit$result$heritability$label,
    c(
      "latent-scale h2 (conditional)",
      "count-scale observation h2 (conditional)"
    )
  )
  expect_true(all(is.finite(fit$result$heritability$estimate)))
  expect_false("h2_liability" %in% names(fit$result))
  expect_false("n_trials" %in% names(fit$result))
  expect_identical(
    heritability(fit)$field,
    fit$result$heritability$field
  )

  # The live route selects only the versioned normalizer; the legacy public
  # compatibility normalizer remains a distinct function.
  expect_false(identical(
    hsquared:::hs_normalize_nongaussian_result,
    hsquared:::hs_normalize_nongaussian_three_field_v09
  ))
})
