# hsquared#320. predict/fitted/residuals must not silently ignore newdata.

hs_prediction_fit <- function() {
  set.seed(1)
  y <- rnorm(5)
  hsquared:::hs_new_fit(
    spec = list(target = "animal"),
    payload = list(y = y),
    result = list(predictions = data.frame(.fitted = y + 0.1)),
    version = "0"
  )
}

test_that("predict() errors on newdata instead of returning in-sample rows", {
  fit <- hs_prediction_fit()
  nd <- data.frame(id = c("z1", "z2"))
  expect_error(predict(fit, newdata = nd), "`newdata`", fixed = TRUE)
  expect_equal(nrow(predict(fit)), 5L)
})

test_that("fitted() errors on newdata instead of returning in-sample values", {
  fit <- hs_prediction_fit()
  nd <- data.frame(id = c("z1", "z2"))
  expect_error(fitted(fit, newdata = nd), "`newdata`", fixed = TRUE)
  expect_equal(length(fitted(fit)), 5L)
})

test_that("residuals() errors on newdata instead of returning in-sample values", {
  fit <- hs_prediction_fit()
  nd <- data.frame(id = c("z1", "z2"))
  expect_error(residuals(fit, newdata = nd), "`newdata`", fixed = TRUE)
  expect_equal(length(residuals(fit)), 5L)
})
