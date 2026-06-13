test_that("hs_control stores validated defaults", {
  control <- hs_control()

  expect_s3_class(control, "hs_control")
  expect_equal(control$engine, "validate")
  expect_equal(control$backend, "auto")
  expect_equal(control$accelerator, "auto")
  expect_equal(control$precision, "float64")
  expect_equal(control$save, "minimal")
  expect_equal(control$engine_control, list())
})

test_that("hs_control validates engine selection", {
  control <- hs_control(
    engine = "julia",
    engine_control = list(max_dense_cells = 10L)
  )

  expect_equal(control$engine, "julia")
  expect_equal(control$engine_control$max_dense_cells, 10L)

  expect_error(
    hs_control(engine = "not-an-engine"),
    "'arg' should be one of",
    fixed = TRUE
  )
})

test_that("hs_control validates engine_control", {
  expect_error(
    hs_control(engine_control = "not-a-list"),
    "`engine_control` must be a list.",
    fixed = TRUE
  )

  expect_error(
    hs_control(engine_control = list(1)),
    "`engine_control` must be a named list.",
    fixed = TRUE
  )
})

test_that("hsquared validates basic call shape", {
  expect_error(hsquared(), "`formula` is required.", fixed = TRUE)

  expect_error(hsquared(y ~ x), "`data` is required.", fixed = TRUE)

  expect_error(
    hsquared(y ~ x, data = data.frame(y = 1, x = 1), control = list()),
    "`control` must be created by `hs_control()`.",
    fixed = TRUE
  )
})

test_that("hsquared errors honestly before fitting", {
  ped <- data.frame(
    id = c("a", "b", "c", "d"),
    sire = c(NA, NA, "a", "a"),
    dam = c(NA, NA, "b", "c")
  )
  dat <- data.frame(
    y = c(1, 2, 3),
    sex = c("f", "m", "f"),
    age = c(1, 2, 3),
    id = c("a", "c", "d")
  )

  expect_error(
    hsquared(y ~ sex + age + animal(1 | id, pedigree = ped), data = dat),
    "parsed the v0.1 animal-model contract",
    fixed = TRUE
  )
})
