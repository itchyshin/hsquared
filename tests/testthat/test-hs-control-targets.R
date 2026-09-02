# Front-door honesty: ?hs_control lists live Julia targets, including the
# covered opt-in routes. DESCRIPTION must not call non-Gaussian "planned".

test_that("?hs_control lists live targets including covered opt-in routes", {
  rd <- testthat::test_path("..", "..", "man", "hs_control.Rd")
  skip_if_not(
    file.exists(rd),
    "man/hs_control.Rd not present in the check copy"
  )
  text <- paste(readLines(rd, warn = FALSE), collapse = "\n")

  live <- c(
    "fit_animal_model",
    "henderson_mme",
    "metafounder",
    "sparse_reml",
    "ai_reml",
    "repeatability",
    "two_effect",
    "multi_effect",
    "genomic",
    "single_step",
    "single_step_construct",
    "metafounder_single_step",
    "snp_blup",
    "relmat",
    "precision",
    "multivariate",
    "random_regression",
    "nongaussian",
    "direct_maternal"
  )
  for (target in live) {
    expect_true(
      grepl(paste0("\"", target, "\""), text, fixed = TRUE),
      info = paste("?hs_control omitted live target", target)
    )
  }

  expect_match(text, "covered opt-in", ignore.case = TRUE)
  expect_match(text, "validation scale", ignore.case = TRUE)
})

test_that("DESCRIPTION does not call non-Gaussian models planned", {
  desc <- gsub(
    "\\s+",
    " ",
    utils::packageDescription("hsquared")$Description
  )
  expect_no_match(desc, "non-Gaussian models are planned")
  expect_match(desc, "non-Gaussian")
  expect_match(desc, "opt-in")
  expect_match(desc, "experimental")
  expect_match(desc, "factor-analytic models remain planned", fixed = TRUE)
})
