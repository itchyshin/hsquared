test_that("internal hsquared_fit object supports v0.1 extractors", {
  result <- list(
    variance_components = data.frame(
      component = c("animal", "residual"),
      estimate = c(0.4, 0.6)
    ),
    heritability = data.frame(term = "animal", estimate = 0.4),
    breeding_values = data.frame(id = c("a", "b"), value = c(0.1, -0.1)),
    prediction_error_variance = data.frame(
      id = c("a", "b"),
      value = c(0.2, 0.25)
    ),
    reliability = data.frame(id = c("a", "b"), value = c(0.8, 0.75)),
    marker_effects = data.frame(marker = c("m1", "m2"), effect = c(0.2, -0.1)),
    marker_variance_explained = data.frame(
      marker = c("m1", "m2"),
      proportion = c(0.05, 0.02)
    ),
    qtl_table = data.frame(marker = "m1", lod = 3.2),
    gwas_table = data.frame(marker = "m1", p_value = 0.01),
    eqtl_table = data.frame(gene = "g1", marker = "m1", p_value = 0.02),
    lod_scores = data.frame(position = c(10, 20), lod = c(2.1, 3.2)),
    fixed_effects = c("(Intercept)" = 1.2, sexm = -0.3),
    random_effects = list(animal = c(a = 0.1, b = -0.1)),
    loglik = -12.5,
    df = 4L,
    nobs = 10L,
    predictions = data.frame(.fitted = seq_len(10) + 0.5),
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
  expect_equal(prediction_error_variance(fit), result$prediction_error_variance)
  expect_equal(reliability(fit), result$reliability)
  expect_equal(marker_effects(fit), result$marker_effects)
  expect_equal(
    marker_variance_explained(fit),
    result$marker_variance_explained
  )
  expect_equal(qtl_table(fit), result$qtl_table)
  expect_equal(gwas_table(fit), result$gwas_table)
  expect_equal(eqtl_table(fit), result$eqtl_table)
  expect_equal(lod_scores(fit), result$lod_scores)
  expect_equal(fixef(fit), result$fixed_effects)
  expect_equal(ranef(fit), result$random_effects)
  expect_equal(predict(fit), result$predictions)
  expect_equal(fitted(fit), result$predictions$.fitted)
  expect_equal(residuals(fit), seq_len(10) - result$predictions$.fitted)
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
  expect_error(
    prediction_error_variance(list()),
    "requires an `hsquared_fit` object",
    fixed = TRUE
  )
  expect_error(
    reliability(list()),
    "requires an `hsquared_fit` object",
    fixed = TRUE
  )
  expect_error(
    marker_effects(list()),
    "does not fit marker-scan, QTL, GWAS, or eQTL models yet",
    fixed = TRUE
  )
  expect_error(
    qtl_table(list()),
    "does not fit marker-scan, QTL, GWAS, or eQTL models yet",
    fixed = TRUE
  )
  expect_error(
    gwas_table(list()),
    "does not fit marker-scan, QTL, GWAS, or eQTL models yet",
    fixed = TRUE
  )
  expect_error(
    eqtl_table(list()),
    "does not fit marker-scan, QTL, GWAS, or eQTL models yet",
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
  expect_error(
    reliability(fit),
    "does not contain reliability estimates",
    fixed = TRUE
  )
  expect_error(
    qtl_table(fit),
    "does not contain QTL table",
    fixed = TRUE
  )
  expect_error(
    fitted(fit),
    "does not contain predictions",
    fixed = TRUE
  )
  expect_error(
    residuals(fit),
    "does not contain predictions",
    fixed = TRUE
  )
})

test_that("hsquared_fit residuals require response values", {
  fit <- hsquared:::hs_new_fit(
    spec = list(method = "REML", family = list(family = "gaussian")),
    payload = list(),
    result = list(predictions = data.frame(.fitted = c(1, 2)))
  )

  expect_equal(fitted(fit), c(1, 2))
  expect_error(
    residuals(fit),
    "does not contain response values",
    fixed = TRUE
  )
})

test_that("hsquared_fit residuals check fitted length", {
  fit <- hsquared:::hs_new_fit(
    spec = list(method = "REML", family = list(family = "gaussian")),
    payload = list(y = c(1, 2, 3)),
    result = list(predictions = data.frame(.fitted = c(1, 2)))
  )

  expect_error(
    residuals(fit),
    "same length",
    fixed = TRUE
  )
})
