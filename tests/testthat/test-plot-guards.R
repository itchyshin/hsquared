# Error guards of the plotting layer: base plot.hsquared_fit and autoplot().
# All run without Julia.

guard_fit <- function(result = list(), y = seq_len(6)) {
  hsquared:::hs_new_fit(
    call = quote(hsquared(y ~ animal(1 | id, pedigree = ped), data = dat)),
    spec = list(method = "REML", family = list(family = "gaussian")),
    payload = list(y = y),
    result = result
  )
}

with_null_device <- function(code) {
  grDevices::pdf(NULL)
  on.exit(grDevices::dev.off(), add = TRUE)
  force(code)
}

test_that("plot(type = 'residuals') errors when fitted and y differ in length", {
  fit <- guard_fit(
    result = list(predictions = data.frame(.fitted = c(1, 2, 3))),
    y = seq_len(6)
  )
  with_null_device(
    expect_error(
      plot(fit, type = "residuals"),
      "has no fitted values and response to plot residuals from"
    )
  )
})

test_that("plot(type = 'variance') errors when the table lacks an `estimate` column", {
  fit <- guard_fit(
    result = list(
      variance_components = data.frame(
        component = c("animal", "residual"),
        value = c(0.4, 0.6)
      )
    )
  )
  with_null_device(
    expect_error(
      plot(fit, type = "variance"),
      "no variance-component estimates to plot"
    )
  )
})

test_that("autoplot(fit, 'breeding_values') errors when the table lacks id/value", {
  skip_if_not_installed("ggplot2")
  # A fit with no breeding_values field at all is stopped earlier by the
  # `breeding_values()` extractor ("does not contain breeding values"), so the
  # plot guard is reached only by a table without `id` and `value` columns.
  fit <- guard_fit(
    result = list(
      breeding_values = data.frame(animal = letters[1:3], ebv = c(0.1, 0, -0.1))
    )
  )
  expect_error(
    ggplot2::autoplot(fit, "breeding_values"),
    "has no breeding values to plot"
  )
  none <- guard_fit(result = list())
  expect_error(
    ggplot2::autoplot(none, "breeding_values"),
    "does not contain breeding values"
  )
})

test_that("autoplot() of an hs_gwas object without p_value errors", {
  skip_if_not_installed("ggplot2")
  gw <- structure(
    data.frame(
      marker = paste0("m", 1:5),
      effect = c(0.1, -0.2, 0.3, 0, 0.5),
      se = rep(0.1, 5)
    ),
    class = c("hs_gwas", "data.frame")
  )
  expect_error(
    ggplot2::autoplot(gw),
    "has no `p_value` column to plot",
    fixed = TRUE
  )
})

test_that("hs_require_ggplot2() errors when ggplot2 is not installed", {
  # `hs_require_ggplot2()` calls `requireNamespace()` unqualified, so the base
  # binding is the seam.
  testthat::local_mocked_bindings(
    requireNamespace = function(...) FALSE,
    .package = "base"
  )
  expect_error(
    hsquared:::hs_require_ggplot2(),
    "The hsquared plotting layer requires the `ggplot2` package",
    fixed = TRUE
  )
})
