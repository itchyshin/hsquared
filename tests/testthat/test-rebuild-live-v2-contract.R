test_that("live reference respects the v1-only bootstrap validator", {
  live <- paste(readLines("test-arc1-uncertainty-live.R", warn = FALSE), collapse = "\n")
  expect_false(grepl("boot_v2 <- hsquared(", live, fixed = TRUE))
  env <- new.env(parent = globalenv())
  for (f in c("conditions.R", "hs_control.R", "arc1-uncertainty.R")) {
    sys.source(file.path("..", "..", "R", f), envir = env)
  }
  control <- list(engine_control = list(uncertainty_method = "arc1_bootstrap_v2", bootstrap_B = 1L))
  expect_error(env$hs_validate_arc1_uncertainty_control(control, "multivariate", list(), list()), "arc1_bootstrap_v1")
})
