test_that("internal hsquared_fit object supports v0.1 extractors", {
  result <- list(
    variance_components = data.frame(
      component = c("animal", "residual"),
      estimate = c(0.4, 0.6)
    ),
    heritability = data.frame(term = "animal", estimate = 0.4),
    breeding_values = data.frame(id = c("a", "b"), value = c(0.1, -0.1)),
    fixed_effects = c("(Intercept)" = 1.2, sexm = -0.3),
    random_effects = list(animal = c(a = 0.1, b = -0.1)),
    loglik = -12.5,
    df = 4L,
    nobs = 10L,
    predictions = data.frame(.fitted = c(1.1, 1.2)),
    diagnostics = list(gradient_norm = 0.001),
    converged = TRUE
  )

  fit <- hsquared:::hs_new_fit(
    call = quote(hsquared(y ~ animal(1 | id, pedigree = ped), data = dat)),
    spec = list(method = "REML", family = list(family = "gaussian")),
    payload = list(y = seq_len(10)),
    result = result
  )

  expect_s3_class(fit, "hsquared_fit")
  expect_equal(variance_components(fit), result$variance_components)
  expect_equal(heritability(fit), result$heritability)
  expect_equal(breeding_values(fit), result$breeding_values)
  expect_equal(fixef(fit), result$fixed_effects)
  expect_equal(ranef(fit), result$random_effects)
  expect_equal(predict(fit), result$predictions)
  expect_equal(as.numeric(logLik(fit)), -12.5)
  expect_equal(attr(logLik(fit), "df"), 4L)
  expect_equal(attr(logLik(fit), "nobs"), 10L)
  expect_equal(AIC(fit), 2 * 4 - 2 * -12.5)
  expect_s3_class(summary(fit), "summary_hsquared_fit")
})

test_that("extractor defaults do not imply fitted model support", {
  expect_error(
    variance_components(list()),
    "requires an `hsquared_fit` object",
    fixed = TRUE
  )
  expect_error(
    heritability(list()),
    "requires an `hsquared_fit` object",
    fixed = TRUE
  )
  expect_error(
    breeding_values(list()),
    "requires an `hsquared_fit` object",
    fixed = TRUE
  )
})

test_that("hsquared_fit extractors fail loudly when a result field is absent", {
  fit <- hsquared:::hs_new_fit(
    spec = list(method = "REML", family = list(family = "gaussian")),
    payload = list(y = 1:2),
    result = list(converged = TRUE)
  )

  expect_error(
    variance_components(fit),
    "does not contain variance components",
    fixed = TRUE
  )
})
