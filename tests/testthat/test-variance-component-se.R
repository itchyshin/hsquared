# Experimental variance-component / heritability standard errors (engine row
# V1-HERIT-CI, partial). R-side extractor + normalizer tested with fixtures; the
# live engine path is exercised opportunistically by the bridge when Julia is
# present.

test_that("SE extractors return the fields when present", {
  result <- list(
    variance_component_se = data.frame(
      component = c("animal", "residual"),
      se = c(0.12, 0.18),
      stringsAsFactors = FALSE
    ),
    heritability_se = 0.07
  )
  fit <- hsquared:::hs_new_fit(
    call = quote(hsquared(y ~ animal(1 | id, pedigree = ped), data = dat)),
    spec = list(method = "REML", family = list(family = "gaussian")),
    payload = list(y = seq_len(10)),
    result = result
  )

  expect_s3_class(fit, "hsquared_fit")
  expect_equal(
    variance_component_standard_errors(fit),
    result$variance_component_se
  )
  expect_equal(heritability_standard_error(fit), 0.07)
})

test_that("SE extractors error clearly without the field or object", {
  expect_error(
    variance_component_standard_errors(seq_len(10)),
    "requires an `hsquared_fit` object"
  )
  expect_error(
    heritability_standard_error(seq_len(10)),
    "requires an `hsquared_fit` object"
  )

  fit_no_se <- hsquared:::hs_new_fit(
    call = quote(hsquared(y ~ animal(1 | id, pedigree = ped), data = dat)),
    spec = list(method = "REML", family = list(family = "gaussian")),
    payload = list(y = seq_len(10)),
    result = list(heritability = data.frame(term = "animal", estimate = 0.4))
  )
  expect_error(
    variance_component_standard_errors(fit_no_se),
    "variance-component standard errors"
  )
  expect_error(
    heritability_standard_error(fit_no_se),
    "heritability standard error"
  )
})

test_that("hs_normalize_variance_component_se() builds a component/se data frame", {
  out <- hsquared:::hs_normalize_variance_component_se(
    list(sigma_a2 = 0.12, sigma_e2 = 0.18)
  )
  expect_equal(out$component, c("animal", "residual"))
  expect_equal(out$se, c(0.12, 0.18))
})
