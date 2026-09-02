# A17 phase 3: the capability-ledger generator is a drift guard, so test the
# guard, not just the happy path. No Julia required.

ledger_script <- function() {
  path <- testthat::test_path(
    "..",
    "..",
    "tools",
    "write-capability-ledger-summary.R"
  )
  normalizePath(path, mustWork = FALSE)
}

skip_without_generator <- function() {
  testthat::skip_if_not(
    file.exists(ledger_script()),
    "generator script not present in the installed package"
  )
}

load_generator <- function() {
  env <- new.env(parent = globalenv())
  sys.source(ledger_script(), envir = env)
  env
}

test_that("every route key is a real validation_status() row", {
  skip_without_generator()
  gen <- load_generator()

  status_tbl <- as.data.frame(validation_status())
  routes <- gen$hs_route_table()

  expect_gt(length(routes), 0L)
  for (route in routes) {
    expect_length(status_tbl$status[status_tbl$capability == route$key], 1L)
  }
})

test_that("declared route status matches the live ledger", {
  skip_without_generator()
  gen <- load_generator()

  status_tbl <- as.data.frame(validation_status())
  expect_true(gen$hs_check_routes(gen$hs_route_table(), status_tbl))
})

test_that("a missing capability row aborts generation", {
  skip_without_generator()
  gen <- load_generator()

  status_tbl <- as.data.frame(validation_status())
  routes <- gen$hs_route_table()
  routes[[1L]]$key <- "a capability that does not exist"

  expect_error(
    gen$hs_check_routes(routes, status_tbl),
    "capability-ledger drift"
  )
})

test_that("a demoted capability row aborts generation", {
  skip_without_generator()
  gen <- load_generator()

  status_tbl <- as.data.frame(validation_status())
  routes <- gen$hs_route_table()
  demoted <- status_tbl$capability == routes[[1L]]$key
  status_tbl$status[demoted] <- "partial"

  expect_error(
    gen$hs_check_routes(routes, status_tbl),
    "expects status 'covered'"
  )
})

test_that("no route claims an interval-reporting permission", {
  skip_without_generator()
  gen <- load_generator()

  intervals <- vapply(
    gen$hs_route_table(),
    function(x) x$interval,
    character(1)
  )
  expect_true(all(intervals == "no"))
})

test_that("generated summary states covered/partial/planned honestly", {
  skip_without_generator()
  gen <- load_generator()

  text <- paste(
    gen$hs_build_summary(as.data.frame(validation_status())),
    collapse = "\n"
  )

  expect_match(text, "do not edit by hand", fixed = TRUE)
  expect_match(text, "validation_status()", fixed = TRUE)
  expect_match(text, "NOT coverage-calibrated", fixed = TRUE)
  expect_match(text, "## Reader routes", fixed = TRUE)
  expect_match(text, "## Before you report", fixed = TRUE)

  # the words that would hide the runs-versus-validated distinction
  expect_no_match(text, "fully supported", ignore.case = TRUE)
  expect_no_match(text, "production-ready", ignore.case = TRUE)
})

test_that("the committed include is in sync with validation_status()", {
  skip_without_generator()
  gen <- load_generator()

  include <- testthat::test_path(
    "..",
    "..",
    "vignettes",
    "articles",
    "includes",
    "capability-ledger-summary.md"
  )
  skip_if_not(
    file.exists(include),
    "generated include not present (pkgdown-only path)"
  )

  expect_identical(
    readLines(include, warn = FALSE),
    gen$hs_build_summary(as.data.frame(validation_status()))
  )
})
