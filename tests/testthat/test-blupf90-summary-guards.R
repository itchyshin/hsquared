# Input guards of the BLUPF90 multivariate summary reader and validator.

hs_write_summary <- function(df, env = parent.frame()) {
  path <- withr::local_tempfile(fileext = ".csv", .local_envir = env)
  utils::write.csv(df, path, row.names = FALSE)
  path
}

hs_good_summary <- function() {
  data.frame(
    quantity = c("G[1,1]", "G[1,2]"),
    target = c(1, 0.5),
    estimate = c(1, 0.5),
    difference = c(0, 0),
    tolerance = c(0.001, 0.001),
    verdict = c("pass", "pass")
  )
}

test_that("BLUPF90 summary reader rejects bad paths", {
  reader <- hsquared:::hs_read_blupf90_multivariate_summary
  for (bad in list(NULL, NA_character_, "", c("a", "b"), 1)) {
    expect_error(reader(bad), "single non-empty file path")
  }
  missing_path <- file.path(withr::local_tempdir(), "absent.csv")
  expect_error(reader(missing_path), "BLUPF90 summary file does not exist")
})

test_that("BLUPF90 summary reader names which columns are missing", {
  df <- hs_good_summary()
  df$tolerance <- NULL
  df$verdict <- NULL
  path <- hs_write_summary(df)
  expect_error(
    hsquared:::hs_read_blupf90_multivariate_summary(path),
    "missing required columns: tolerance, verdict"
  )
})

test_that("BLUPF90 summary reader rejects blank quantity and verdict values", {
  reader <- hsquared:::hs_read_blupf90_multivariate_summary

  blank_quantity <- hs_good_summary()
  blank_quantity$quantity[2] <- ""
  expect_error(
    reader(hs_write_summary(blank_quantity)),
    "blank `quantity` values"
  )

  blank_verdict <- hs_good_summary()
  blank_verdict$verdict[1] <- ""
  expect_error(
    reader(hs_write_summary(blank_verdict)),
    "blank `verdict` values"
  )
})

test_that("BLUPF90 summary validator rejects unread input and empty labels", {
  parsed <- hsquared:::hs_read_blupf90_multivariate_summary(
    hs_write_summary(hs_good_summary())
  )
  validator <- hsquared:::hs_validate_blupf90_multivariate_summary
  expect_error(validator(hs_good_summary()), "must be read by")
  expect_error(
    validator(parsed, required_quantities = c("G[1,1]", "")),
    "non-empty quantity labels"
  )
  expect_error(
    validator(parsed, required_quantities = 1),
    "non-empty quantity labels"
  )
})
