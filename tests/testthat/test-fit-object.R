test_that("internal hsquared_fit object supports v0.1 extractors", {
  result <- list(
    variance_components = data.frame(
      component = c("animal", "residual"),
      estimate = c(0.4, 0.6)
    ),
    heritability = data.frame(term = "animal", estimate = 0.4),
    genetic_covariance = matrix(0.4, 1, 1),
    residual_covariance = matrix(0.6, 1, 1),
    genetic_correlation = matrix(1, 1, 1),
    residual_correlation = matrix(1, 1, 1),
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
    diagnostics = list(
      optimizer_status = "converged",
      iterations = 7L,
      gradient_norm = 0.001
    ),
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
  expect_equal(genetic_covariance(fit), result$genetic_covariance)
  expect_equal(G_matrix(fit), result$genetic_covariance)
  expect_equal(residual_covariance(fit), result$residual_covariance)
  expect_equal(R_matrix(fit), result$residual_covariance)
  expect_equal(genetic_correlation(fit), result$genetic_correlation)
  expect_equal(residual_correlation(fit), result$residual_correlation)
  expect_equal(breeding_values(fit), result$breeding_values)
  expect_equal(EBV(fit), result$breeding_values)
  expect_equal(BLUP(fit), result$breeding_values)
  expect_equal(prediction_error_variance(fit), result$prediction_error_variance)
  expect_equal(reliability(fit), result$reliability)
  expect_equal(
    accuracy(fit),
    transform(result$reliability, value = sqrt(value))
  )
  expect_equal(marker_effects(fit), result$marker_effects)
  expect_equal(
    marker_variance_explained(fit),
    result$marker_variance_explained
  )
  expect_equal(qtl_table(fit), result$qtl_table)
  expect_equal(gwas_table(fit), result$gwas_table)
  expect_equal(eqtl_table(fit), result$eqtl_table)
  expect_equal(lod_scores(fit), result$lod_scores)
  expect_equal(stats::coef(fit), result$fixed_effects)
  expect_equal(fixef(fit), result$fixed_effects)
  expect_equal(ranef(fit), result$random_effects)
  expect_equal(predict(fit), result$predictions)
  expect_equal(fitted(fit), result$predictions$.fitted)
  expect_equal(residuals(fit), seq_len(10) - result$predictions$.fitted)
  expect_equal(stats::nobs(fit), 10L)
  expect_equal(as.numeric(logLik(fit)), -12.5)
  expect_equal(attr(logLik(fit), "df"), 4L)
  expect_equal(attr(logLik(fit), "nobs"), 10L)
  expect_equal(AIC(fit), 2 * 4 - 2 * -12.5)
  diagnostics <- fit_diagnostics(fit)
  expect_s3_class(diagnostics, "hs_fit_diagnostics")
  expect_equal(
    diagnostics$metric,
    c(
      "engine",
      "method",
      "family",
      "target",
      "converged",
      "optimizer_status",
      "iterations",
      "loglik",
      "df",
      "nobs",
      "at_boundary",
      "gradient_norm"
    )
  )
  expect_equal(
    diagnostics$value[diagnostics$metric == "gradient_norm"],
    "0.001"
  )
  # Interior fit (h2 = 0.4) is not flagged at a variance-component boundary.
  expect_equal(
    diagnostics$value[diagnostics$metric == "at_boundary"],
    "FALSE"
  )
  expect_match(capture.output(print(diagnostics))[[1L]], "<hs_fit_diagnostics>")
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
    genetic_covariance(list()),
    "requires an `hsquared_fit` object",
    fixed = TRUE
  )
  expect_error(
    G_matrix(list()),
    "requires an `hsquared_fit` object",
    fixed = TRUE
  )
  expect_error(
    R_matrix(list()),
    "requires an `hsquared_fit` object",
    fixed = TRUE
  )
  expect_error(
    residual_correlation(list()),
    "requires an `hsquared_fit` object",
    fixed = TRUE
  )
  expect_error(
    breeding_values(list()),
    "requires an `hsquared_fit` object",
    fixed = TRUE
  )
  expect_error(
    EBV(list()),
    "requires an `hsquared_fit` object",
    fixed = TRUE
  )
  expect_error(
    BLUP(list()),
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
    accuracy(list()),
    "requires an `hsquared_fit` object",
    fixed = TRUE
  )
  expect_error(
    fit_diagnostics(list()),
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
  expect_error(
    specific_variance(list()),
    "reserves this extractor name",
    fixed = TRUE
  )
  expect_error(
    latent_breeding_values(list()),
    "reserves this extractor name",
    fixed = TRUE
  )
  expect_error(
    eigen_G(list()),
    "reserves this extractor name",
    fixed = TRUE
  )
  expect_null(loadings(list()))
})

test_that("reserved factor-analytic extractors fail with rotation-aware scope", {
  fit <- hsquared:::hs_new_fit(
    call = quote(hsquared(y ~ animal(1 | id, pedigree = ped), data = dat)),
    spec = list(method = "REML", family = list(family = "gaussian")),
    payload = list(y = c(1, 2, 3)),
    result = list(
      genetic_covariance = matrix(c(1, 0.2, 0.2, 1), 2, 2),
      genetic_correlation = matrix(c(1, 0.2, 0.2, 1), 2, 2),
      converged = TRUE
    )
  )

  expect_error(
    loadings(fit),
    "planned, not implemented.*rotation-nonunique",
    perl = TRUE
  )
  expect_error(
    loadings(fit, rotate = "varimax"),
    "rotation controls are planned, not implemented",
    fixed = TRUE
  )
  expect_error(
    specific_variance(fit),
    "planned, not implemented.*rotation-nonunique",
    perl = TRUE
  )
  expect_error(
    latent_breeding_values(fit),
    "planned, not implemented.*rotation-nonunique",
    perl = TRUE
  )
  expect_error(
    eigen_G(fit),
    "planned, not implemented.*rotation-nonunique",
    perl = TRUE
  )
  expect_error(
    eigen_G(fit, effect = "residual"),
    "effect = \"animal\"",
    fixed = TRUE
  )
})

test_that("unsupported inference helpers fail with explicit scope", {
  fit <- hsquared:::hs_new_fit(
    call = quote(hsquared(y ~ animal(1 | id, pedigree = ped), data = dat)),
    spec = list(method = "REML", family = list(family = "gaussian")),
    payload = list(y = c(1, 2, 3)),
    result = list(
      variance_components = data.frame(
        component = c("animal", "residual"),
        estimate = c(0.4, 0.6)
      ),
      heritability = data.frame(term = "animal", estimate = 0.4),
      loglik = -4.2,
      df = 3L,
      nobs = 3L,
      converged = TRUE
    )
  )

  expect_error(
    stats::confint(fit),
    "confidence intervals.*planned, not implemented",
    perl = TRUE
  )
  expect_error(
    stats::vcov(fit),
    "standard-error surface.*planned, not implemented",
    perl = TRUE
  )
  expect_error(
    stats::profile(fit),
    "Profile-likelihood intervals.*planned, not implemented",
    perl = TRUE
  )
  expect_error(
    stats::anova(fit),
    "Likelihood-ratio / ANOVA comparison.*planned, not implemented",
    perl = TRUE
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
    accuracy(fit),
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

test_that("hsquared_fit nobs falls back to response payload", {
  fit <- hsquared:::hs_new_fit(
    spec = list(method = "REML", family = list(family = "gaussian")),
    payload = list(y = 1:4),
    result = list(converged = TRUE)
  )

  expect_equal(stats::nobs(fit), 4L)

  missing <- hsquared:::hs_new_fit(
    spec = list(method = "REML", family = list(family = "gaussian")),
    payload = list(),
    result = list(converged = TRUE)
  )
  expect_error(
    stats::nobs(missing),
    "does not contain number-of-observations metadata",
    fixed = TRUE
  )
})

test_that("fit_diagnostics tolerates scalar diagnostics payloads", {
  fit <- hsquared:::hs_new_fit(
    spec = list(method = "REML", family = list(family = "gaussian")),
    payload = list(y = 1:2),
    result = list(
      diagnostics = "scalar-status",
      converged = FALSE
    )
  )

  diagnostics <- fit_diagnostics(fit)
  expect_equal(
    diagnostics$value[diagnostics$metric == "diagnostics"],
    "scalar-status"
  )
})

test_that("fit_diagnostics flags a variance-component boundary solution", {
  boundary <- hsquared:::hs_new_fit(
    spec = list(method = "REML", family = list(family = "gaussian")),
    payload = list(y = 1:3),
    result = list(
      variance_components = data.frame(
        component = c("animal", "residual"),
        estimate = c(0, 1.2)
      ),
      converged = TRUE
    )
  )
  diag <- fit_diagnostics(boundary)
  expect_equal(diag$value[diag$metric == "at_boundary"], "TRUE")

  interior <- hsquared:::hs_new_fit(
    spec = list(method = "REML", family = list(family = "gaussian")),
    payload = list(y = 1:3),
    result = list(
      variance_components = data.frame(
        component = c("animal", "residual"),
        estimate = c(0.5, 0.5)
      ),
      converged = TRUE
    )
  )
  expect_equal(
    fit_diagnostics(interior)$value[
      fit_diagnostics(interior)$metric == "at_boundary"
    ],
    "FALSE"
  )
})

test_that("accuracy requires reliability values on [0, 1]", {
  fit <- hsquared:::hs_new_fit(
    spec = list(method = "REML", family = list(family = "gaussian")),
    payload = list(y = 1:2),
    result = list(
      reliability = data.frame(id = c("a", "b"), value = c(0.5, 1.2))
    )
  )

  expect_error(
    accuracy(fit),
    "between 0 and 1",
    fixed = TRUE
  )

  malformed <- hsquared:::hs_new_fit(
    spec = list(method = "REML", family = list(family = "gaussian")),
    payload = list(y = 1:2),
    result = list(reliability = data.frame(id = c("a", "b"), se = c(0.1, 0.2)))
  )

  expect_error(
    accuracy(malformed),
    "with a `value` column",
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
