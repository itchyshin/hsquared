launcher_path <- normalizePath(
  testthat::test_path("..", "..", "tools", "run-v07-genomic-recovery-v3.sh"),
  winslash = "/", mustWork = TRUE
)

launcher_text <- paste(readLines(launcher_path, warn = FALSE), collapse = "\n")

test_that("recovery-v3 launcher is executable shell with the full phase surface", {
  expect_true(file.access(launcher_path, 1L) == 0L)
  expect_identical(
    system2("bash", c("-n", shQuote(launcher_path)), stdout = FALSE, stderr = FALSE),
    0L
  )
  for (mode in c(
    "selftest", "guard-selftest", "write-review", "prepare", "preseal", "smoke-n-ladder",
    "smoke-16", "verify-official", "recommend-workers", "run-official",
    "lock-corpus", "recompute-base-r", "summarize-r", "replay-julia",
    "verify-replay", "summarize-julia", "write-postrun-review",
    "adjudicate", "validate-final"
  )) {
    expect_match(launcher_text, mode, fixed = TRUE)
  }
})

test_that("launcher compute guard is executable and fail-closed", {
  output <- system2(
    "bash", c(shQuote(launcher_path), "guard-selftest"),
    stdout = TRUE, stderr = TRUE
  )
  expect_identical(attr(output, "status"), NULL)
  expect_match(paste(output, collapse = "\n"), "guard selftest: PASS", fixed = TRUE)
})

test_that("launcher freezes thread and process safety", {
  for (name in c(
    "OPENBLAS_NUM_THREADS", "OMP_NUM_THREADS", "MKL_NUM_THREADS",
    "VECLIB_MAXIMUM_THREADS", "NUMEXPR_NUM_THREADS", "JULIA_NUM_THREADS"
  )) {
    expect_match(launcher_text, paste0("export ", name, "=1"), fixed = TRUE)
  }
  expect_match(launcher_text, "workers must be 1..96", fixed = TRUE)
  expect_match(launcher_text, "xargs -r -P", fixed = TRUE)
  expect_false(grepl("mclapply", launcher_text, fixed = TRUE))
  expect_match(launcher_text, "0.7 * available_mb / max(rss)", fixed = TRUE)
  expect_match(launcher_text, "preseal_cap", fixed = TRUE)
})

test_that("launcher requires both smoke denominator and n-ladder coverage", {
  expect_match(launcher_text, "fewer than 16 completed smoke attempts", fixed = TRUE)
  expect_match(launcher_text, "smoke attempts do not cover every preregistered n", fixed = TRUE)
  expect_match(launcher_text, "manifest_missing_pairs", fixed = TRUE)
  expect_match(launcher_text, "manifest_missing_recompute_pairs", fixed = TRUE)
  expect_match(launcher_text, "smoke-16 requires exactly 16 previously missing rows", fixed = TRUE)
  expect_match(launcher_text, "workers=$workers exceeds smoke/RAM recommendation", fixed = TRUE)
  expect_match(launcher_text, "workers=$1 exceeds smoke/RAM recommendation", fixed = TRUE)
})

test_that("launcher keeps official, base-R, and Julia stages distinct", {
  expect_match(launcher_text, "--mode=run-one", fixed = TRUE)
  expect_match(launcher_text, "--mode=recompute-one", fixed = TRUE)
  expect_match(launcher_text, "--mode=replay", fixed = TRUE)
  expect_match(launcher_text, "--mode=verify-replay", fixed = TRUE)
  expect_match(launcher_text, "--mode=validate-final", fixed = TRUE)
  expect_match(launcher_text, "group_flag=design", fixed = TRUE)
  expect_match(launcher_text, "group_flag=cell", fixed = TRUE)
  expect_match(launcher_text, "V3_GROUP_FLAG", fixed = TRUE)
})
