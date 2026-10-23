# hsquared#307. Estimate and uncertainty extractors must not silently return
# numbers from a non-converged fit. They use the same warning bar as
# heritability(): keep the engine number so it can be inspected, and shout.

hs_nonconverged_extractor_fit <- function(converged = FALSE) {
  # The non-converged path keeps a near-zero animal share so the warning
  # bar still sees a failed-fit artefact. The quiet-path control must be
  # interior: the same 1e-16 share is a variance-component boundary, and
  # extractors warn on that even when the optimizer reports converged.
  animal_vc <- if (converged) 0.48 else 1e-16
  residual_vc <- if (converged) 0.72 else 1.2
  h2 <- if (converged) 0.4 else 9.48e-17
  hsquared:::hs_new_fit(
    spec = list(
      method = "REML",
      family = list(family = "gaussian"),
      target = "ai_reml"
    ),
    payload = list(y = 1:4),
    result = list(
      variance_components = data.frame(
        component = c("animal", "residual"),
        estimate = c(animal_vc, residual_vc),
        stringsAsFactors = FALSE
      ),
      heritability = data.frame(
        term = "animal",
        estimate = h2,
        stringsAsFactors = FALSE
      ),
      heritability_interval = data.frame(
        estimate = h2,
        lower = if (converged) 0.18 else 0,
        upper = if (converged) 0.62 else 1,
        level = 0.95,
        se = if (converged) 0.11 else 0.4,
        method = "delta",
        stringsAsFactors = FALSE
      ),
      variance_component_se = data.frame(
        component = c("animal", "residual"),
        se = c(0.12, 0.18),
        stringsAsFactors = FALSE
      ),
      heritability_se = 0.07,
      repeatability = data.frame(
        term = "permanent",
        estimate = 0.55,
        stringsAsFactors = FALSE
      ),
      repeatability_interval = data.frame(
        estimate = 0.55,
        lower = 0.34,
        upper = 0.74,
        level = 0.95,
        se = 0.10,
        stringsAsFactors = FALSE
      ),
      breeding_values = data.frame(
        id = c("a", "b"),
        value = c(0.1, -0.1),
        stringsAsFactors = FALSE
      ),
      reliability = data.frame(
        id = c("a", "b"),
        value = c(0.8, 0.75),
        stringsAsFactors = FALSE
      ),
      diagnostics = list(
        optimizer_status = if (converged) "converged" else "not_converged",
        iterations = 27L
      ),
      converged = converged
    )
  )
}

hs_expect_unusable_warning <- function(expr, what) {
  expect_warning(
    expr,
    paste0(
      "This `hsquared_fit` object did not converge. The ",
      what,
      " number is not an estimate; do not report it."
    ),
    fixed = TRUE
  )
}

test_that("estimate extractors warn on a non-converged fit instead of staying silent", {
  failed <- hs_nonconverged_extractor_fit()

  hs_expect_unusable_warning(
    vc <- variance_components(failed),
    "variance-component"
  )
  expect_equal(vc$estimate, c(1e-16, 1.2))

  hs_expect_unusable_warning(
    hi <- heritability_interval(failed),
    "heritability-interval"
  )
  expect_equal(hi$estimate, 9.48e-17)

  hs_expect_unusable_warning(
    vcse <- variance_component_standard_errors(failed),
    "variance-component standard-error"
  )
  expect_equal(vcse$se, c(0.12, 0.18))

  hs_expect_unusable_warning(
    h2se <- heritability_standard_error(failed),
    "heritability standard-error"
  )
  expect_equal(h2se$se, 0.07)

  hs_expect_unusable_warning(
    r <- repeatability(failed),
    "repeatability"
  )
  expect_equal(r$estimate, 0.55)

  hs_expect_unusable_warning(
    ri <- repeatability_interval(failed),
    "repeatability-interval"
  )
  expect_equal(ri$estimate, 0.55)

  hs_expect_unusable_warning(
    bv <- breeding_values(failed),
    "breeding-value"
  )
  expect_equal(bv$value, c(0.1, -0.1))

  hs_expect_unusable_warning(
    acc <- accuracy(failed),
    "accuracy"
  )
  expect_equal(acc$value, sqrt(c(0.8, 0.75)))
})

test_that("those extractors stay quiet on a converged interior fit", {
  ok <- hs_nonconverged_extractor_fit(converged = TRUE)
  expect_silent(variance_components(ok))
  expect_silent(heritability_interval(ok))
  expect_silent(variance_component_standard_errors(ok))
  expect_silent(heritability_standard_error(ok))
  expect_silent(repeatability(ok))
  expect_silent(repeatability_interval(ok))
  expect_silent(breeding_values(ok))
  expect_silent(accuracy(ok))
})

test_that("interval unused-argument errors still beat a non-converged warning", {
  failed <- hs_nonconverged_extractor_fit()
  expect_error(
    heritability_interval(failed, level = 0.9),
    "`level`",
    fixed = TRUE
  )
  expect_error(
    repeatability_interval(failed, level = 0.9),
    "`level`",
    fixed = TRUE
  )
})
