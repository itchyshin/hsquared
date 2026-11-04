test_that("documented bootstrap methods agree with the recovered validator", {
  control <- paste(readLines(file.path("..", "..", "R", "hs_control.R"), warn = FALSE), collapse = "\n")
  rd <- paste(readLines(file.path("..", "..", "man", "hs_control.Rd"), warn = FALSE), collapse = "\n")
  expect_false(grepl("arc1_bootstrap_v2", control, fixed = TRUE))
  expect_false(grepl("arc1_bootstrap_v2", rd, fixed = TRUE))
  expect_true(grepl("arc1_bootstrap_v1", control, fixed = TRUE))
})
test_that("bootstrap v2 is rejected by the recovered validation code", {
  env <- new.env(parent = globalenv())
  for (f in c("conditions.R", "hs_control.R", "arc1-uncertainty.R")) {
    sys.source(file.path("..", "..", "R", f), envir = env)
  }
  control <- list(engine_control = list(uncertainty_method = "arc1_bootstrap_v2", bootstrap_B = 10L))
  expect_error(env$hs_validate_arc1_uncertainty_control(control, "multivariate", list(), list()), "arc1_bootstrap_v1")
})
