# Input guards in R/gwas.R that are reached before any engine call. These pin
# the exact message text so a reworded or deleted guard fails the suite.

gwas_guard_payload <- function() {
  list(pedigree = list(id = c("a", "b", "c", "d")))
}

gwas_guard_markers <- function() {
  matrix(
    c(0, 1, 2, 1, 2, 1, 0, 1),
    nrow = 4,
    dimnames = list(c("a", "b", "c", "d"), c("m1", "m2"))
  )
}

gwas_guard_calibration <- function() {
  list(
    calibration_method = "permutation",
    threshold_scale = "p_value",
    threshold = 0.01,
    alpha = 0.05,
    empirical_type1 = 0.048,
    marker_panel_mode = "realistic_ld",
    scan_method = "mixed",
    n_replicates = 1000,
    seed = c(1L, 2L, 3L),
    engine = "HSquared.mixed_model_marker_scan",
    package_version = "0.1.0"
  )
}

gwas_guard_calibration_error <- function(calibration, ...) {
  hsquared:::hs_validate_gwas_calibration_metadata(calibration, ...)
}

test_that("a valid marker matrix and calibration pass the guards", {
  aligned <- hsquared:::hs_validate_gwas_markers(
    gwas_guard_markers(),
    gwas_guard_payload()
  )
  expect_identical(dim(aligned), c(4L, 2L))
  expect_type(
    gwas_guard_calibration_error(gwas_guard_calibration()),
    "list"
  )
})

test_that("hs_validate_gwas_markers requires markers", {
  expect_error(
    hsquared:::hs_validate_gwas_markers(NULL, gwas_guard_payload()),
    "`markers` is required.",
    fixed = TRUE
  )
})

test_that("hs_validate_gwas_markers rejects non-numeric markers", {
  chr <- matrix(
    c("0", "1", "2", "1"),
    nrow = 4,
    dimnames = list(c("a", "b", "c", "d"), "m1")
  )
  expect_error(
    hsquared:::hs_validate_gwas_markers(chr, gwas_guard_payload()),
    "`markers` must be a numeric matrix.",
    fixed = TRUE
  )
})

test_that("hs_validate_gwas_markers rejects bad row names", {
  dup <- gwas_guard_markers()
  rownames(dup)[2] <- "a"
  expect_error(
    hsquared:::hs_validate_gwas_markers(dup, gwas_guard_payload()),
    "`markers` row names must be unique, non-missing, and nonempty.",
    fixed = TRUE
  )

  blank <- gwas_guard_markers()
  rownames(blank)[2] <- ""
  expect_error(
    hsquared:::hs_validate_gwas_markers(blank, gwas_guard_payload()),
    "`markers` row names must be unique, non-missing, and nonempty.",
    fixed = TRUE
  )
})

test_that("hs_validate_gwas_markers needs at least one marker column", {
  empty <- matrix(
    numeric(0),
    nrow = 4,
    ncol = 0,
    dimnames = list(c("a", "b", "c", "d"), NULL)
  )
  expect_error(
    hsquared:::hs_validate_gwas_markers(empty, gwas_guard_payload()),
    "`markers` must have at least one marker column.",
    fixed = TRUE
  )
})

test_that("hs_validate_gwas_markers rejects non-finite dosages", {
  for (bad in c(NA_real_, Inf, -Inf, NaN)) {
    m <- gwas_guard_markers()
    m[2, 1] <- bad
    expect_error(
      hsquared:::hs_validate_gwas_markers(m, gwas_guard_payload()),
      "`markers` must contain only finite dosages.",
      fixed = TRUE
    )
  }
})

test_that("hs_gwas_marker_ids rejects a marker_ids length mismatch", {
  expect_error(
    hsquared:::hs_gwas_marker_ids("m1", gwas_guard_markers()),
    "`marker_ids` must have one entry per marker column (2).",
    fixed = TRUE
  )
})

test_that("hs_gwas_marker_groups rejects missing labels", {
  expect_error(
    hsquared:::hs_gwas_marker_groups(
      c("chr1", NA),
      gwas_guard_markers(),
      "loco"
    ),
    "`marker_groups` must not contain missing labels.",
    fixed = TRUE
  )
})

test_that("hs_gwas_marker_groups rejects empty labels", {
  expect_error(
    hsquared:::hs_gwas_marker_groups(
      c("chr1", ""),
      gwas_guard_markers(),
      "loco"
    ),
    "`marker_groups` must not contain empty labels.",
    fixed = TRUE
  )
})

test_that("hs_gwas_marker_groups rejects a group map of the wrong length", {
  expect_error(
    hsquared:::hs_gwas_marker_groups(
      c("chr1", "chr1", "chr2"),
      gwas_guard_markers(),
      "loco"
    ),
    "`marker_groups` must have one entry per marker column (2); got 3.",
    fixed = TRUE
  )
})

test_that("hs_validate_gwas_fit requires a fitted pedigree animal model", {
  fit <- list(
    spec = list(family = list(family = "gaussian")),
    payload = list(pedigree = list(id = "a"), Z = NULL, y = 1, X = 1),
    result = list(converged = TRUE)
  )
  expect_error(
    hsquared:::hs_validate_gwas_fit(fit),
    "`gwas()` requires a fitted pedigree animal model (the default `hsquared(y ~ ... + animal(1 | id, pedigree = ped))` path).",
    fixed = TRUE
  )
})

test_that("the single-marker OLS scan needs residual degrees of freedom", {
  # intercept + covariate + marker = rank 3 on 2 records
  X <- cbind(1, c(0, 1))
  expect_error(
    hsquared:::hs_gwas_single_ols_residual_mse(
      y = c(1, 2),
      X = X,
      markers = matrix(c(0, 1), ncol = 1)
    ),
    "The single-marker OLS regression has no residual degrees of freedom.",
    fixed = TRUE
  )
})

test_that("the single-marker OLS scan needs a positive residual mean square", {
  # a constant response is fit exactly by the intercept, so the MSE is 0
  expect_error(
    hsquared:::hs_gwas_single_ols_residual_mse(
      y = c(2, 2, 2, 2),
      X = matrix(1, 4, 1),
      markers = matrix(c(0, 1, 2, 1), ncol = 1)
    ),
    "The single-marker OLS residual mean square must be positive and finite.",
    fixed = TRUE
  )
})

test_that("calibration metadata must be a named list", {
  expect_error(
    gwas_guard_calibration_error("permutation"),
    "GWAS calibration metadata must be a named list.",
    fixed = TRUE
  )
})

test_that("calibration threshold_scale must be p_value or lod", {
  cal <- gwas_guard_calibration()
  cal$threshold_scale <- "z"
  expect_error(
    gwas_guard_calibration_error(cal),
    "GWAS calibration `threshold_scale` must be `p_value` or `lod`.",
    fixed = TRUE
  )
})

test_that("calibration threshold must be positive and finite", {
  for (bad in list(0, -1, NA_real_, Inf)) {
    cal <- gwas_guard_calibration()
    cal$threshold <- bad
    expect_error(
      gwas_guard_calibration_error(cal),
      "GWAS calibration `threshold` must be positive and finite.",
      fixed = TRUE
    )
  }
})

test_that("calibration alpha must be strictly between 0 and 1", {
  for (bad in list(0, 1, -0.1, 1.5, NA_real_)) {
    cal <- gwas_guard_calibration()
    cal$alpha <- bad
    expect_error(
      gwas_guard_calibration_error(cal),
      "GWAS calibration `alpha` must be between 0 and 1.",
      fixed = TRUE
    )
  }
})

test_that("permutation_addone empirical_type1 must be NA or in [0, 1]", {
  cal <- gwas_guard_calibration()
  cal$calibration_method <- "permutation_addone"
  cal$empirical_type1 <- 1.2
  cal$validation_reference <- "external gate"
  expect_error(
    gwas_guard_calibration_error(cal),
    "GWAS calibration `empirical_type1` must be NA or between 0 and 1 for the `permutation_addone` method.",
    fixed = TRUE
  )
})

test_that("other calibration methods need a finite empirical_type1 in [0, 1]", {
  for (bad in list(1.2, -0.1, NA_real_)) {
    cal <- gwas_guard_calibration()
    cal$empirical_type1 <- bad
    expect_error(
      gwas_guard_calibration_error(cal),
      "GWAS calibration `empirical_type1` must be between 0 and 1.",
      fixed = TRUE
    )
  }
})

test_that("calibration marker_panel_mode must be a known mode", {
  cal <- gwas_guard_calibration()
  cal$marker_panel_mode <- "simulated"
  expect_error(
    gwas_guard_calibration_error(cal),
    "GWAS calibration `marker_panel_mode` must be one of `fixed`, `fresh`, `realistic_ld`, or `real_panel`.",
    fixed = TRUE
  )
})

test_that("calibration seed needs at least one non-missing value", {
  for (bad in list(integer(0), c(1L, NA))) {
    cal <- gwas_guard_calibration()
    cal$seed <- bad
    expect_error(
      gwas_guard_calibration_error(cal),
      "GWAS calibration `seed` must contain at least one non-missing value.",
      fixed = TRUE
    )
  }
})

test_that("calibration engine must be a non-empty string", {
  for (bad in list("", c("a", "b"), NA_character_)) {
    cal <- gwas_guard_calibration()
    cal$engine <- bad
    expect_error(
      gwas_guard_calibration_error(cal),
      "GWAS calibration `engine` must be a non-empty string.",
      fixed = TRUE
    )
  }
})

test_that("calibration package_version must be a non-empty string", {
  for (bad in list("", c("0.1", "0.2"), NA_character_)) {
    cal <- gwas_guard_calibration()
    cal$package_version <- bad
    expect_error(
      gwas_guard_calibration_error(cal),
      "GWAS calibration `package_version` must be a non-empty string.",
      fixed = TRUE
    )
  }
})
