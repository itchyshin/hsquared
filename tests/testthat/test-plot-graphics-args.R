# hsquared#315. plot.hsquared_fit() documents ... as passed to the base plot.
# The inner call used to hard-code main/xlab/ylim/pch and also forward ...,
# so those arguments were matched twice.

hs_plot_fit <- function() {
  hsquared:::hs_new_fit(
    spec = list(method = "REML", family = list(family = "gaussian")),
    payload = list(y = 1:3),
    result = list(
      variance_components = data.frame(
        component = c("sigma2_a", "sigma2_e"),
        estimate = c(0.5, 0.7)
      ),
      variance_component_se = data.frame(
        component = c("sigma2_a", "sigma2_e"),
        se = c(0.1, 0.1)
      ),
      predictions = data.frame(.fitted = 1:3)
    )
  )
}

with_null_device <- function(code) {
  grDevices::pdf(NULL)
  on.exit(grDevices::dev.off(), add = TRUE)
  force(code)
}

test_that("plot() accepts documented graphics arguments without double-matching", {
  fit <- hs_plot_fit()
  with_null_device({
    expect_no_error(plot(fit, main = "mine"))
    expect_no_error(plot(fit, xlab = "q"))
    expect_no_error(plot(fit, ylab = "v"))
    expect_no_error(plot(fit, ylim = c(0, 2)))
    expect_no_error(plot(fit, xlim = c(0, 3)))
    expect_no_error(plot(fit, pch = 1))
    expect_no_error(plot(
      fit,
      type = "residuals",
      main = "mine",
      xlab = "q",
      ylab = "v",
      pch = 1
    ))
  })
})
