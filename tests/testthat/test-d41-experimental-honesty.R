# D-41 honesty channels (A17 bounded slice): package load + .onAttach message.
# No Julia required.

test_that("hsquared namespace is loaded", {
  expect_true("hsquared" %in% loadedNamespaces())
})

test_that(".onAttach emits experimental honesty message", {
  on_attach <- get(".onAttach", envir = asNamespace("hsquared"))
  msg <- capture_messages(on_attach("hsquared", "hsquared"))
  text <- paste(msg, collapse = " ")

  expect_match(text, "experimental", ignore.case = TRUE)
  expect_match(text, "0\\.5\\.0")
  expect_match(text, "Julia")
  expect_match(text, "validate")
  expect_match(text, "validation_status")
  expect_match(text, "coverage-calibrated", fixed = TRUE)
})

# A31: `public_covered_count` is 5, but `validation_status()` has no row for
# random_regression (k = 2) or direct_maternal. The attach message must not
# imply that the table alone enumerates every reportable covered route.
test_that(".onAttach does not imply validation_status() lists every covered route", {
  on_attach <- get(".onAttach", envir = asNamespace("hsquared"))
  text <- paste(
    capture_messages(on_attach("hsquared", "hsquared")),
    collapse = " "
  )

  expect_match(text, "not a complete list", fixed = TRUE)
  expect_match(text, "random_regression", fixed = TRUE)
  expect_match(text, "direct_maternal", fixed = TRUE)

  # the old wording made the table the sole authority
  expect_no_match(
    text,
    "only for covered rows in validation_status",
    fixed = TRUE
  )

  # pointers must resolve: `vignettes/articles` is Rbuildignored, so
  # vignette("model-status") is not installed for users
  expect_no_match(text, "vignette(", fixed = TRUE)
  expect_match(text, "current-limits", fixed = TRUE)
})

test_that("validation_status() print output flags that it is not the full covered list", {
  text <- paste(capture.output(print(validation_status())), collapse = " ")

  expect_match(text, "not the full list of covered routes", fixed = TRUE)
  expect_match(text, "random_regression", fixed = TRUE)
  expect_match(text, "direct_maternal", fixed = TRUE)
})

test_that("DESCRIPTION and README do not make validation_status() the sole authority", {
  desc <- utils::packageDescription("hsquared")$Description
  expect_match(desc, "not\\s+the\\s+full\\s+list\\s+of\\s+covered\\s+routes")
  expect_no_match(
    desc,
    "only\\s+for\\s+rows\\s+marked\\s+covered\\s+in\\s+validation_status"
  )

  readme <- testthat::test_path("..", "..", "README.md")
  skip_if_not(file.exists(readme), "README.md not present in the check copy")
  lines <- readLines(readme, warn = FALSE)
  # unwrap the blockquote so the assertion does not depend on line breaks
  flat <- gsub("\\s+", " ", paste(sub("^>\\s?", "", lines), collapse = " "))

  expect_match(flat, "not the full list of covered routes", fixed = TRUE)
  expect_match(flat, "random_regression", fixed = TRUE)
  expect_match(flat, "direct_maternal", fixed = TRUE)
  expect_no_match(flat, "only for rows marked `covered` by", fixed = TRUE)
})

test_that("README carries the D-41 callout and a validate-first example", {
  readme <- testthat::test_path("..", "..", "README.md")
  skip_if_not(file.exists(readme), "README.md not present in the check copy")
  text <- paste(readLines(readme, warn = FALSE), collapse = "\n")

  # channel 4: lifecycle badge + prominent callout
  expect_match(text, "lifecycle-experimental", fixed = TRUE)
  expect_match(text, "[!WARNING]", fixed = TRUE)
  expect_match(text, "0.5.0", fixed = TRUE)
  expect_match(text, "not coverage-calibrated", fixed = TRUE)

  # I2: the first runnable example must not need Julia
  validate_at <- which(
    strsplit(text, "\n", fixed = TRUE)[[1L]] ==
      "## Quick start — no Julia required"
  )
  fit_at <- which(
    strsplit(text, "\n", fixed = TRUE)[[1L]] ==
      "## Fitting — requires the Julia engine"
  )
  expect_length(validate_at, 1L)
  expect_length(fit_at, 1L)
  expect_lt(validate_at, fit_at)

  expect_match(text, 'engine = "validate"', fixed = TRUE)
})
