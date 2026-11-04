test_that("profile-v4 accepts its documented repeatability scope", {
  env <- new.env(parent = globalenv())
  for (f in c("conditions.R", "hs_control.R", "arc1-uncertainty.R")) {
    sys.source(file.path("..", "..", "R", f), envir = env)
  }
  control <- list(engine_control = list(uncertainty_method = "arc1_profile_v4"))
  spec <- list(family = list(family = "gaussian"), response = list(multivariate = FALSE), random = list(permanent = 1))
  payload <- list(Z = Matrix::sparseMatrix(i = 1:4, j = c(1, 1, 2, 2), x = 1), pedigree = list())
  expect_identical(env$hs_validate_arc1_uncertainty_control(control, "repeatability", spec, payload), list(method = "arc1_profile_v4"))
  expect_error(env$hs_validate_arc1_uncertainty_control(control, "multivariate", spec, payload), "univariate Gaussian pedigree repeatability")
  non_gaussian <- spec; non_gaussian$family$family <- "poisson"
  expect_error(env$hs_validate_arc1_uncertainty_control(control, "repeatability", non_gaussian, payload), "univariate Gaussian pedigree repeatability")
  multivariate <- spec; multivariate$response$multivariate <- TRUE
  expect_error(env$hs_validate_arc1_uncertainty_control(control, "repeatability", multivariate, payload), "univariate Gaussian pedigree repeatability")
  no_pedigree <- payload; no_pedigree$pedigree <- NULL
  expect_error(env$hs_validate_arc1_uncertainty_control(control, "repeatability", spec, no_pedigree), "univariate Gaussian pedigree repeatability")
  no_permanent <- spec; no_permanent$random$permanent <- NULL
  expect_error(env$hs_validate_arc1_uncertainty_control(control, "repeatability", no_permanent, payload), "univariate Gaussian pedigree repeatability")
  uneven <- payload; uneven$Z <- Matrix::sparseMatrix(i = 1:3, j = c(1, 1, 2), x = 1)
  expect_error(env$hs_validate_arc1_uncertainty_control(control, "repeatability", spec, uneven), "exactly two records")
  for (key in c("initial", "iterations", "max_dense_cells", "scale_method")) {
    bad <- control; bad$engine_control[[key]] <- if (key == "scale_method") "auto" else 1L
    expect_error(env$hs_validate_arc1_uncertainty_control(bad, "repeatability", spec, payload), "scale_method")
  }
})
