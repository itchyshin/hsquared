#!/usr/bin/env Rscript
# CI-only: Julia-enabled coverage without covr's test_check() re-isolation
# (see hsquared#374). One testthat::test_dir() pass under instrumentation.

suppressPackageStartupMessages(library(covr))

pkg_root <- normalizePath(Sys.getenv("GITHUB_WORKSPACE", "."), winslash = "/")
setwd(pkg_root)

install_path <- file.path(
  normalizePath(Sys.getenv("RUNNER_TEMP"), winslash = "/"),
  "package"
)
log_path <- file.path(pkg_root, "coverage-testthat.log")
csv_path <- file.path(pkg_root, "coverage-testthat-results.csv")
test_dir_path <- file.path(pkg_root, "tests", "testthat")

cov <- covr::package_coverage(
  path = pkg_root,
  quiet = FALSE,
  clean = FALSE,
  type = "none",
  install_path = install_path,
  code = c(
    "options(crayon.enabled = FALSE)",
    sprintf(
      paste0(
        "res <- testthat::test_dir(%s, ",
        "package = 'hsquared', load_package = 'installed', ",
        "reporter = testthat::SummaryReporter$new(file = %s), ",
        "stop_on_failure = FALSE, stop_on_warning = FALSE)"
      ),
      deparse(test_dir_path, control = "c"),
      deparse(log_path, control = "c")
    ),
    "df <- as.data.frame(res)",
    sprintf(
      "write.csv(df, %s, row.names = FALSE)",
      deparse(csv_path, control = "c")
    ),
    "n_files <- nrow(df)",
    "n_fail <- sum(df$failed, na.rm = TRUE)",
    "n_err <- sum(as.integer(df$error), na.rm = TRUE)",
    "n_pass <- if ('passed' %in% names(df)) sum(df$passed, na.rm = TRUE) else sum(df$nb, na.rm = TRUE)",
    "n_skip <- sum(df$skipped, na.rm = TRUE)",
    "stopifnot(n_files > 0L)",
    "if (n_fail != 0L || n_err != 0L) stop('testthat failures under Julia coverage', call. = FALSE)",
    "if (n_pass < 1L) stop('no testthat passes under Julia coverage', call. = FALSE)",
    sprintf(
      "cat(sprintf('HSQUARED_TESTTHAT_GUARD=files=%%d fail=%%d err=%%d pass=%%d skip=%%d\\\\n', n_files, n_fail, n_err, n_pass, n_skip))"
    )
  )
)

print(cov)
pct <- round(covr::percent_coverage(cov), 2)

df <- read.csv(csv_path, stringsAsFactors = FALSE)
n_files <- nrow(df)
n_fail <- sum(df$failed, na.rm = TRUE)
n_err <- sum(as.integer(df$error), na.rm = TRUE)
n_pass <- if ("passed" %in% names(df)) sum(df$passed, na.rm = TRUE) else sum(df$nb, na.rm = TRUE)
n_skip <- sum(df$skipped, na.rm = TRUE)

if (n_fail != 0L || n_err != 0L) {
  stop("testthat guard failed after coverage (failures or errors)", call. = FALSE)
}
if (n_pass < 1L) {
  stop("testthat guard failed after coverage (no passes)", call. = FALSE)
}
if (n_files < 300L) {
  stop(sprintf("unexpectedly few test files under coverage (%d < 300)", n_files), call. = FALSE)
}

summary_file <- Sys.getenv("GITHUB_STEP_SUMMARY")
if (nzchar(summary_file)) {
  writeLines(
    c(
      "## covr (CI coverage finish, not Codecov acceptance)",
      "",
      paste0("- package coverage: ", pct, "%"),
      "- suite: Julia-enabled testthat (`test_dir`, single process)",
      paste0("- testthat files: ", n_files, "; pass/nb: ", n_pass, "; fail: ", n_fail,
             "; error rows: ", n_err, "; skip: ", n_skip),
      "- this print is CI coverage finish, not upload or dashboard evidence"
    ),
    summary_file
  )
}

cat(sprintf("HSQUARED_COVR_PERCENT=%s\n", pct))
cat(sprintf(
  "HSQUARED_TESTTHAT_GUARD=files=%d fail=%d err=%d pass=%d skip=%d\n",
  n_files, n_fail, n_err, n_pass, n_skip
))
covr::to_cobertura(cov)
