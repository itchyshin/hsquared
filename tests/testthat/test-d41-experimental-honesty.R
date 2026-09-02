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
  expect_match(text, "0\\.6\\.0")
  expect_match(text, "Julia")
  expect_match(text, "validate")
  expect_match(text, "validation_status")
  expect_match(text, "coverage-calibrated", fixed = TRUE)
})

# Pat UX item 3: attach points first at the limits article, not at
# validation_status() as the user-facing list. The RR/DM row-gap apology
# belongs on the article, not in the startup paragraph.
test_that(".onAttach points at Can I fit and report this?, not validation_status() as the user list", {
  on_attach <- get(".onAttach", envir = asNamespace("hsquared"))
  text <- paste(
    capture_messages(on_attach("hsquared", "hsquared")),
    collapse = " "
  )

  expect_match(text, "Can I fit and report this", fixed = TRUE)
  expect_match(text, "not", fixed = TRUE)
  expect_match(text, "validation_status", fixed = TRUE)
  expect_match(text, "current-limits", fixed = TRUE)

  # the old wording made the table the sole authority
  expect_no_match(
    text,
    "only for covered rows in validation_status",
    fixed = TRUE
  )

  # pointers must resolve: `vignettes/articles` is Rbuildignored, so
  # vignette("model-status") is not installed for users
  expect_no_match(text, "vignette(", fixed = TRUE)

  # the incomplete-table apology is off the attach message
  expect_no_match(text, "not a complete list", fixed = TRUE)
  expect_no_match(text, "random_regression", fixed = TRUE)

  # Pat leftover: two short lines + URL, not a ledger paragraph
  collapsed <- gsub("\\s+", " ", paste(text, collapse = " "))
  expect_lt(nchar(collapsed), 400L)
})

test_that("validation_status() print output flags that it is not the full covered list", {
  text <- paste(capture.output(print(validation_status())), collapse = " ")

  expect_match(text, "not the full list of covered routes", fixed = TRUE)
  expect_match(text, "random_regression", fixed = TRUE)
  expect_match(text, "direct_maternal", fixed = TRUE)
})

test_that("DESCRIPTION and README point at Can I fit and report this?, not validation_status()", {
  desc <- utils::packageDescription("hsquared")$Description
  expect_match(desc, "Can I fit and report this")
  expect_match(desc, "developer evidence table")
  expect_no_match(
    desc,
    "only\\s+for\\s+rows\\s+marked\\s+covered\\s+in\\s+validation_status"
  )
  expect_no_match(desc, "live source of truth")

  readme <- testthat::test_path("..", "..", "README.md")
  skip_if_not(file.exists(readme), "README.md not present in the check copy")
  lines <- readLines(readme, warn = FALSE)
  # unwrap the blockquote so the assertion does not depend on line breaks
  flat <- gsub("\\s+", " ", paste(sub("^>\\s?", "", lines), collapse = " "))

  expect_match(flat, "Can I fit and report this", fixed = TRUE)
  expect_match(flat, "developer evidence table", fixed = TRUE)
  expect_no_match(flat, "live source of truth", fixed = TRUE)
  expect_no_match(flat, "only for rows marked `covered` by", fixed = TRUE)
})

test_that("README carries the D-41 callout and a validate-first example", {
  readme <- testthat::test_path("..", "..", "README.md")
  skip_if_not(file.exists(readme), "README.md not present in the check copy")
  text <- paste(readLines(readme, warn = FALSE), collapse = "\n")

  # channel 4: lifecycle badge + prominent callout
  expect_match(text, "lifecycle-experimental", fixed = TRUE)
  expect_match(text, "[!WARNING]", fixed = TRUE)
  expect_match(text, "0.6.0", fixed = TRUE)
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
