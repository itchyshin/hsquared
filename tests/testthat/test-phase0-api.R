test_that("hs_control stores validated defaults", {
  control <- hs_control()

  expect_s3_class(control, "hs_control")
  expect_equal(control$backend, "auto")
  expect_equal(control$accelerator, "auto")
  expect_equal(control$precision, "float64")
  expect_equal(control$save, "minimal")
  expect_equal(control$engine_control, list())
})

test_that("hs_control validates engine_control", {
  expect_snapshot(error = TRUE, {
    hs_control(engine_control = "not-a-list")
  })
})

test_that("hsquared validates basic call shape", {
  expect_snapshot(error = TRUE, {
    hsquared()
  })

  expect_snapshot(error = TRUE, {
    hsquared(y ~ x)
  })

  expect_snapshot(error = TRUE, {
    hsquared(y ~ x, data = data.frame(y = 1, x = 1), control = list())
  })
})

test_that("hsquared errors honestly before fitting", {
  expect_snapshot(error = TRUE, {
    hsquared(y ~ x, data = data.frame(y = 1, x = 1))
  })
})
