# ?rr must state that order is the number of Legendre coefficients
# (order = 2 is intercept + slope) and that the covariate is mapped
# to [-1, 1]. hsquared#300 documentation half.

test_that("rr is an inert formula marker", {
  expect_null(rr(age, order = 2))
  expect_null(rr(dim))
})

test_that("?rr states order is the number of Legendre coefficients", {
  rd <- testthat::test_path("..", "..", "man", "rr.Rd")
  skip_if_not(file.exists(rd), "man/rr.Rd not present in the check copy")
  text <- paste(readLines(rd, warn = FALSE), collapse = "\n")

  expect_match(text, "number of normalized-Legendre coefficients", fixed = TRUE)
  expect_match(text, "intercept + slope", fixed = TRUE)
  expect_match(text, "[-1, 1]", fixed = TRUE)
})

test_that("?rr and ?rr_covariance say standard errors are refused", {
  for (f in c("rr.Rd", "random_regression_extractors.Rd")) {
    rd <- testthat::test_path("..", "..", "man", f)
    skip_if_not(file.exists(rd), paste0("man/", f, " not present in the check copy"))
    text <- paste(readLines(rd, warn = FALSE), collapse = "\n")
    text <- gsub("\\s+", " ", text)

    expect_match(text, "variance_component_standard_errors", fixed = TRUE, info = f)
    expect_match(text, "covariance_standard_errors", fixed = TRUE, info = f)
    expect_match(text, "no standard errors", fixed = TRUE, info = f)
  }
})
