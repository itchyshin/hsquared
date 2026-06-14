local_comparator_script <- function(...) {
  candidates <- c(
    testthat::test_path(
      "..", "..", "inst", "comparator-scripts", ...
    ),
    system.file("comparator-scripts", ..., package = "hsquared")
  )
  candidates <- candidates[nzchar(candidates) & file.exists(candidates)]
  testthat::skip_if(
    length(candidates) == 0L,
    paste("Comparator script is not available:", file.path(...))
  )
  normalizePath(candidates[[1]], mustWork = TRUE)
}

local_package_root <- function() {
  normalizePath(testthat::test_path("..", ".."), mustWork = FALSE)
}

run_comparator_script <- function(script, args = character()) {
  rscript <- file.path(R.home("bin"), "Rscript")
  testthat::skip_if_not(
    file.exists(rscript),
    "Rscript executable is not available."
  )

  output <- system2(
    rscript,
    args = shQuote(c(script, args)),
    stdout = TRUE,
    stderr = TRUE,
    env = paste0("HSQUARED_REPO=", shQuote(local_package_root()))
  )
  status <- attr(output, "status")
  if (is.null(status)) {
    status <- 0L
  }
  list(status = status, output = paste(output, collapse = "\n"))
}

test_that("manual ASReml comparator script has a dry-run mode", {
  script <- local_comparator_script("asreml", "multivariate-animal.R")

  run <- run_comparator_script(script)

  expect_identical(run$status, 0L)
  expect_match(run$output, "Prepared ASReml-R candidate fixture", fixed = TRUE)
  expect_match(run$output, "records: 160", fixed = TRUE)
  expect_match(run$output, "traits: trait1, trait2", fixed = TRUE)
  expect_match(run$output, "Dry run only", fixed = TRUE)
})

test_that("manual BLUPF90 comparator script has dry-run and write modes", {
  skip_if_not_installed("withr")
  script <- local_comparator_script("blupf90", "prepare-multivariate-animal.R")

  dry_run <- run_comparator_script(script)
  expect_identical(dry_run$status, 0L)
  expect_match(
    dry_run$output,
    "Prepared BLUPF90-family candidate fixture",
    fixed = TRUE
  )
  expect_match(dry_run$output, "data rows: 80", fixed = TRUE)
  expect_match(dry_run$output, "pedigree rows: 20", fixed = TRUE)
  expect_match(dry_run$output, "Dry run only", fixed = TRUE)

  write_dir <- withr::local_tempdir(pattern = "hsquared-blupf90-")
  write_run <- run_comparator_script(
    script,
    paste0("--write=", write_dir)
  )
  expect_identical(write_run$status, 0L)
  expect_match(write_run$output, "Wrote BLUPF90-family comparator files", fixed = TRUE)

  data_file <- file.path(write_dir, "multivariate-animal.dat")
  ped_file <- file.path(write_dir, "multivariate-animal.ped")
  renf90_file <- file.path(write_dir, "multivariate-animal.renf90")
  par_file <- file.path(write_dir, "multivariate-animal.par")
  readme_file <- file.path(write_dir, "README.txt")

  expect_true(file.exists(data_file))
  expect_true(file.exists(ped_file))
  expect_true(file.exists(renf90_file))
  expect_true(file.exists(par_file))
  expect_true(file.exists(readme_file))

  dat <- utils::read.table(data_file)
  ped <- utils::read.table(ped_file)
  expect_equal(nrow(dat), 80L)
  expect_equal(ncol(dat), 5L)
  expect_equal(nrow(ped), 20L)
  expect_equal(ncol(ped), 3L)

  renf90 <- readLines(renf90_file, warn = FALSE)
  par <- readLines(par_file, warn = FALSE)
  expect_false(any(grepl("__DATAFILE__", renf90, fixed = TRUE)))
  expect_false(any(grepl("__PEDFILE__", renf90, fixed = TRUE)))
  expect_false(any(grepl("__DATAFILE__", par, fixed = TRUE)))
  expect_false(any(grepl("__PEDFILE__", par, fixed = TRUE)))
  expect_true(any(grepl("multivariate-animal.dat", renf90, fixed = TRUE)))
  expect_true(any(grepl("multivariate-animal.ped", par, fixed = TRUE)))
})
