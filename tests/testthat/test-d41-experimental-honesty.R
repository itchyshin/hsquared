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
  expect_match(text, "0\\.8\\.0")
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
  expect_match(text, "0.8.0", fixed = TRUE)
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


test_that("README and pkgdown lock 0.9-prep public honesty fences", {
  readme <- testthat::test_path("..", "..", "README.md")
  skip_if_not(file.exists(readme), "README.md not present in the check copy")
  text <- gsub("\\s+", " ", paste(readLines(readme, warn = FALSE), collapse = " "))

  expect_match(text, "Experimental 0.8.0", fixed = TRUE)
  expect_match(text, "0.9 is not released", fixed = TRUE)
  expect_match(text, "`public_covered_count` is **7**", fixed = TRUE)
  expect_match(text, "factor-analytic", ignore.case = TRUE)
  expect_match(text, "planned", ignore.case = TRUE)
  expect_match(text, "opt-in partial", fixed = TRUE)
  expect_match(text, "engine-covered", ignore.case = TRUE)
  expect_true(any(grepl("not R-public covered", text, fixed = TRUE),
                  grepl("not R covered", text, fixed = TRUE)))
  expect_match(text, "do **not** flip R coverage", fixed = TRUE)
  expect_match(text, "cov = fa(K)", fixed = TRUE)

  pkgdown <- testthat::test_path("..", "..", "_pkgdown.yml")
  skip_if_not(file.exists(pkgdown), "_pkgdown.yml not present in the check copy")
  ptext <- gsub("\\s+", " ", paste(readLines(pkgdown, warn = FALSE), collapse = " "))
  expect_match(ptext, "0.9 is not", fixed = TRUE)
  expect_match(ptext, "public_covered_count", fixed = TRUE)
  expect_match(ptext, "**7**", fixed = TRUE)
  expect_match(ptext, "planned", ignore.case = TRUE)
  expect_match(ptext, "opt-in partial", fixed = TRUE)
  expect_match(ptext, "engine-covered", ignore.case = TRUE)
})

test_that("model-status article keeps FA planned / SS opt-in partial / count 7", {
  article <- testthat::test_path(
    "..", "..", "vignettes", "articles", "model-status.Rmd"
  )
  skip_if_not(file.exists(article), "model-status.Rmd not present in the check copy")
  text <- gsub("\\s+", " ", paste(readLines(article, warn = FALSE), collapse = " "))

  expect_match(text, "experimental 0.8.0", fixed = TRUE)
  expect_no_match(text, "experimental 0.7.0", fixed = TRUE)
  expect_match(text, "public_covered_count", fixed = TRUE)
  expect_match(text, "0.9 is not released", fixed = TRUE)
  expect_match(text, "opt-in partial", fixed = TRUE)
  expect_match(text, "factor-analytic", ignore.case = TRUE)
  expect_match(text, "planned", ignore.case = TRUE)
  expect_match(text, "engine-covered", ignore.case = TRUE)
  expect_match(text, "cov = fa(K)", fixed = TRUE)
})

test_that("DESCRIPTION keeps count 7 and FA planned without claiming 0.9", {
  desc <- gsub(
    "\\s+",
    " ",
    utils::packageDescription("hsquared")$Description
  )
  expect_match(desc, "0\\.8\\.0")
  expect_match(desc, "public covered count is 7|public covered count stays 7")
  expect_match(desc, "factor-analytic models remain planned", fixed = TRUE)
  expect_match(desc, "opt-in partial", fixed = TRUE)
  expect_match(desc, "0.9 is not released", fixed = TRUE)
  expect_match(desc, "engine-covered is not R covered", fixed = TRUE)
  expect_no_match(desc, "Version 0\\.9")
})
