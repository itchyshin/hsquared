# Opt-in, experimental non-Gaussian (GLMM) animal model bridge. The R unpack is
# shape-verified without a live engine; the live leg actually fits a
# Poisson/Bernoulli model through `HSquared.fit_laplace_reml()` and is skipped
# unless a local Julia + HSquared.jl is available. There is no residual-variance
# scale for these families, so NO heritability is reported (engine row
# V6-LAPLACE, partial).

test_that("the non-Gaussian normalizer shapes a Laplace-REML result without heritability", {
  ped <- data.frame(
    id = c("s", "d", "a", "b"),
    sire = c(NA, NA, "s", "s"),
    dam = c(NA, NA, "d", "d")
  )
  dat <- data.frame(
    y = c(0, 1, 1, 0),
    id = c("s", "d", "a", "b"),
    x = c(0.1, 0.2, 0.3, 0.4)
  )
  spec <- hsquared:::hs_build_model_spec(
    y ~ x + animal(1 | id, pedigree = ped),
    data = dat,
    family = stats::binomial(),
    REML = TRUE,
    allow_families = c("gaussian", "poisson", "binomial")
  )
  payload <- hsquared:::hs_build_bridge_payload(spec)

  raw <- list(
    family = "bernoulli",
    method = "laplace",
    sigma_a2 = 0.42,
    beta = c(0.5, -0.3),
    breeding_ids = c("s", "d", "a", "b"),
    breeding_values = c(0.1, -0.1, 0.2, -0.2),
    loglik = -3.21,
    converged = TRUE
  )
  result <- hsquared:::hs_normalize_nongaussian_result(raw, payload)
  fit <- hsquared:::hs_new_fit(
    spec = list(
      method = "Laplace-REML",
      family = list(family = "binomial", link = "logit"),
      target = "nongaussian"
    ),
    payload = payload,
    result = result
  )

  vc <- variance_components(fit)
  expect_equal(vc$component, "animal")
  expect_equal(vc$estimate, 0.42)
  expect_equal(nrow(breeding_values(fit)), 4L)
  expect_equal(as.numeric(stats::logLik(fit)), -3.21)
  expect_equal(fit$result$family, "bernoulli")
  expect_equal(fit$result$marginal_method, "laplace")
  # No heritability is defined on the latent scale for a non-Gaussian family.
  expect_error(heritability(fit), "heritability")
  expect_equal(
    fit_diagnostics(fit)$value[
      fit_diagnostics(fit)$metric == "engine_family"
    ],
    "bernoulli"
  )
})

test_that("the live Julia bridge fits a non-Gaussian (Poisson + Bernoulli) animal model", {
  testthat::skip_on_cran()
  testthat::skip_if_not(
    hsquared:::hs_julia_bridge_available(),
    "JuliaCall, Julia, and local HSquared.jl are required for the live non-Gaussian bridge."
  )

  set.seed(1)
  ped <- data.frame(
    id = c("s1", "s2", "d1", "d2", paste0("a", 1:16)),
    sire = c(NA, NA, NA, NA, rep(c("s1", "s2"), 8)),
    dam = c(NA, NA, NA, NA, rep(c("d1", "d2"), 8))
  )
  n <- nrow(ped)
  ng_control <- hs_control(
    engine = "julia",
    engine_control = list(target = "nongaussian", iterations = 200L)
  )

  datp <- data.frame(y = rpois(n, lambda = 2), id = ped$id, x = rnorm(n))
  fp <- hsquared(
    y ~ x + animal(1 | id, pedigree = ped),
    data = datp,
    family = stats::poisson(),
    REML = TRUE,
    control = ng_control
  )
  expect_s3_class(fp, "hsquared_fit")
  expect_equal(fp$spec$target, "nongaussian")
  expect_equal(fp$result$family, "poisson")
  expect_equal(fp$result$marginal_method, "laplace")
  vcp <- variance_components(fp)
  expect_equal(vcp$component, "animal")
  expect_true(is.finite(vcp$estimate) && vcp$estimate >= 0)
  expect_equal(nrow(breeding_values(fp)), n)
  expect_error(heritability(fp), "heritability") # no h2 for non-Gaussian

  datb <- data.frame(y = rbinom(n, 1, 0.5), id = ped$id, x = rnorm(n))
  fb <- hsquared(
    y ~ x + animal(1 | id, pedigree = ped),
    data = datb,
    family = stats::binomial(),
    REML = TRUE,
    control = ng_control
  )
  expect_equal(fb$result$family, "bernoulli")
  expect_true(is.finite(variance_components(fb)$estimate))
  expect_equal(nrow(breeding_values(fb)), n)
})

test_that("the non-Gaussian target rejects gaussian and unimplemented families", {
  ped <- data.frame(id = c("a", "b"), sire = c(NA, NA), dam = c(NA, NA))
  dat <- data.frame(y = c(1, 2), id = c("a", "b"))

  # gaussian() through the non-Gaussian target points back to the default path.
  expect_error(
    hsquared(
      y ~ animal(1 | id, pedigree = ped),
      data = dat,
      family = stats::gaussian(),
      REML = TRUE,
      control = hs_control(
        engine = "julia",
        engine_control = list(target = "nongaussian")
      )
    ),
    "non-Gaussian families",
    fixed = TRUE
  )

  # An unimplemented family/link is rejected by the engine-symbol mapping.
  expect_error(
    hsquared:::hs_nongaussian_family_symbol(stats::Gamma()),
    "not implemented",
    fixed = TRUE
  )
  # Only laplace is wired today.
  expect_error(
    hsquared:::hs_validate_marginal_method("variational"),
    "laplace",
    fixed = TRUE
  )
})
