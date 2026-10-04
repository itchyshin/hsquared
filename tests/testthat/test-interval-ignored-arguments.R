# hsquared#310. Interval extractors must not silently ignore level= or other dots.

hs_interval_fit <- function(field, value) {
  result <- list()
  result[[field]] <- value
  hsquared:::hs_new_fit(
    spec = list(method = "REML", family = list(family = "gaussian")),
    payload = list(y = seq_len(10)),
    result = result
  )
}

hs_interval_row <- function() {
  data.frame(
    estimate = 0.42,
    lower = 0.30,
    upper = 0.55,
    level = 0.95,
    se = 0.06,
    stringsAsFactors = FALSE
  )
}

test_that("interval extractors error on ignored level=", {
  hi <- cbind(hs_interval_row(), method = "delta")
  ri <- hs_interval_row()
  ci <- cbind(
    hs_interval_row(),
    lower_clamped = FALSE,
    upper_clamped = FALSE,
    boundary = FALSE
  )

  expect_error(
    heritability_interval(
      hs_interval_fit("heritability_interval", hi),
      level = 0.9
    ),
    "`level`",
    fixed = TRUE
  )
  expect_error(
    repeatability_interval(
      hs_interval_fit("repeatability_interval", ri),
      level = 0.9
    ),
    "`level`",
    fixed = TRUE
  )
  expect_error(
    common_env_proportion_interval(
      hs_interval_fit("common_env_proportion_interval", ci),
      level = 0.9
    ),
    "`level`",
    fixed = TRUE
  )
  expect_error(
    maternal_proportion_interval(
      hs_interval_fit("maternal_proportion_interval", ci),
      level = 0.9
    ),
    "`level`",
    fixed = TRUE
  )
})

test_that("interval extractors error on other unused arguments", {
  hi <- cbind(hs_interval_row(), method = "delta")
  fit <- hs_interval_fit("heritability_interval", hi)
  expect_error(
    heritability_interval(fit, bogus = TRUE),
    "`bogus`",
    fixed = TRUE
  )
  expect_error(
    heritability_interval(fit, 0.9),
    "an unnamed argument",
    fixed = TRUE
  )
})
