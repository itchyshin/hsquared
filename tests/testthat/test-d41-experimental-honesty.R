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
