# `hs_validate_gwas_genome_wide_design()` — intercept-only contract (R/gwas.R:397-412).
# Not covered by `test-coverage-gwas-result.R`, which exercises scan normalisation.

test_that("hs_validate_gwas_genome_wide_design accepts intercept-only X", {
  expect_identical(
    hsquared:::hs_validate_gwas_genome_wide_design(matrix(1, 4, 1)),
    TRUE
  )
})

test_that("hs_validate_gwas_genome_wide_design rejects non-intercept-only X", {
  gw_stop <- paste(
    "`genome_wide = TRUE` is validated for an intercept-only design",
    ".*experimental residual-permutation utility",
    sep = ".*"
  )
  expect_error(
    hsquared:::hs_validate_gwas_genome_wide_design(cbind(1, rnorm(4))),
    gw_stop
  )
  expect_error(
    hsquared:::hs_validate_gwas_genome_wide_design(matrix(2, 4, 1)),
    gw_stop
  )
  expect_error(
    hsquared:::hs_validate_gwas_genome_wide_design(matrix(c(1, 1, NA, 1), ncol = 1)),
    gw_stop
  )
  expect_error(
    hsquared:::hs_validate_gwas_genome_wide_design(matrix(c(1, 1, Inf, 1), ncol = 1)),
    gw_stop
  )
})
