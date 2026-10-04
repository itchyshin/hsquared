# Package-help honesty: ?hsquared-package must not keep Phase-0 "planned
# interface" or "fitting waits" language. Non-Gaussian is opt-in
# experimental, not planned. DESCRIPTION wording is pinned by
# test-hs-control-targets.R (hs_control sibling).

test_that("package Rd does not keep Phase-0 planned-interface or fitting-waits copy", {
  rd <- testthat::test_path("..", "..", "man", "hsquared-package.Rd")
  skip_if_not(
    file.exists(rd),
    "man/hsquared-package.Rd not present in the check copy"
  )
  text <- paste(readLines(rd, warn = FALSE), collapse = "\n")

  expect_no_match(text, "planned R-facing")
  expect_no_match(text, "waits for")
  expect_no_match(text, "Phase 0")
  expect_no_match(text, "Phase-0")
  expect_no_match(text, "non-Gaussian models are planned")
  expect_no_match(text, "non-Gaussian models remain planned")

  expect_match(text, "R-facing interface")
  expect_match(text, "non-Gaussian")
  expect_match(text, "opt-in")
  expect_match(text, "formula grammar stays planned")
  expect_no_match(text, "factor-analytic models remain planned")
})

test_that("twin-boundary Getting started link stays inside articles/", {
  article <- testthat::test_path(
    "..",
    "..",
    "vignettes",
    "articles",
    "twin-boundary.Rmd"
  )
  skip_if_not(file.exists(article), "twin-boundary article not present")
  text <- paste(readLines(article, warn = FALSE), collapse = "\n")
  expect_match(text, "[Getting started](hsquared.html)", fixed = TRUE)
  expect_no_match(text, "../hsquared.html", fixed = TRUE)
})

test_that("install docs tell the reader to Pkg.instantiate() the Julia checkout", {
  pages <- c(
    testthat::test_path("..", "..", "README.md"),
    testthat::test_path("..", "..", "vignettes", "hsquared.Rmd"),
    testthat::test_path(
      "..",
      "..",
      "vignettes",
      "articles",
      "fitting-models.Rmd"
    )
  )
  for (page in pages) {
    skip_if_not(file.exists(page), paste(basename(page), "not present"))
    text <- paste(readLines(page, warn = FALSE), collapse = "\n")
    expect_match(text, "Pkg.instantiate()", fixed = TRUE, info = page)
    expect_match(text, "git clone", fixed = TRUE, info = page)
  }
})

test_that("non-Gaussian vignette does not call its marginal fit REML", {
  vignette <- testthat::test_path(
    "..",
    "..",
    "vignettes",
    "articles",
    "fitting-models.Rmd"
  )
  skip_if_not(
    file.exists(vignette),
    "source vignette not present in the check copy"
  )
  text <- paste(readLines(vignette, warn = FALSE), collapse = "\n")

  expect_no_match(text, "All fits are by REML", fixed = TRUE)
  expect_match(
    text,
    "does \\*\\*not\\*\\* make this non-Gaussian fit a REML fit"
  )
  expect_match(text, "Laplace marginal likelihood")
})
