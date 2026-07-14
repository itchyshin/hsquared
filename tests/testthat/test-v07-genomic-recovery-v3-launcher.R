launcher_path <- testthat::test_path(
  "..", "..", "tools", "run-v07-genomic-recovery-v3.sh"
)
testthat::skip_if_not(
  file.exists(launcher_path),
  "repository-only recovery-v3 launcher is unavailable"
)
launcher_path <- normalizePath(launcher_path, winslash = "/", mustWork = TRUE)

launcher_text <- paste(readLines(launcher_path, warn = FALSE), collapse = "\n")
launcher_repo <- normalizePath(
  testthat::test_path("..", ".."), winslash = "/", mustWork = TRUE
)

launcher_test_path <- function(name) {
  file.path(normalizePath(tempdir(), winslash = "/"), name)
}

launcher_run <- function(args) {
  suppressWarnings(system2(
    "bash", c(shQuote(launcher_path), vapply(args, shQuote, character(1L))),
    stdout = TRUE, stderr = TRUE
  ))
}

test_that("recovery-v3 launcher is executable shell with the full phase surface", {
  expect_true(file.access(launcher_path, 1L) == 0L)
  expect_identical(
    system2("bash", c("-n", shQuote(launcher_path)), stdout = FALSE, stderr = FALSE),
    0L
  )
  for (mode in c(
    "selftest", "guard-selftest", "write-review", "prepare-adaptive", "prepare", "preseal", "smoke-n-ladder",
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

test_that("launcher makes fresh-D0F adjudication a D1-only predecessor", {
  expect_match(
    launcher_text, "D1 $phase requires D0F_ADJUDICATION_ROOT", fixed = TRUE
  )
  expect_match(
    launcher_text, "D0F $phase accepts no predecessor root", fixed = TRUE
  )
  expect_match(
    launcher_text, "require_predecessor_arity d1 prepare 2", fixed = TRUE
  )
  expect_match(
    launcher_text, "require_predecessor_arity d1 preseal 2", fixed = TRUE
  )
  expect_match(
    launcher_text, "require_predecessor_arity d0f prepare 2", fixed = TRUE
  )
  expect_match(
    launcher_text, "--d0f-adjudication-root", fixed = TRUE
  )
  expect_match(launcher_text, "validate_d0f_predecessor_once", fixed = TRUE)
  expect_false(grepl(
    "V3D_D0F_PREDECESSOR_VALIDATED_SHA256", launcher_text, fixed = TRUE
  ))
  expect_match(launcher_text, "--mode=validate-final", fixed = TRUE)
})

test_that("launcher exposes canonical D1-to-D2 planning without claiming numerics", {
  expect_match(launcher_text, "prepare-adaptive OUT d2|d3|d4", fixed = TRUE)
  expect_match(launcher_text, "require_adaptive_stage", fixed = TRUE)
  expect_match(launcher_text, "v07_genomic_recovery_v3_admission.R", fixed = TRUE)
  expect_match(launcher_text, "--d1-root", fixed = TRUE)
  expect_false(grepl("--d1-decisions", launcher_text, fixed = TRUE))
  expect_false(grepl("--d2-decisions", launcher_text, fixed = TRUE))
  expect_false(grepl("run-official OUT d2", launcher_text, fixed = TRUE))
  expect_false(grepl("recompute-base-r OUT d2", launcher_text, fixed = TRUE))
  expect_false(grepl("replay-julia OUT d2", launcher_text, fixed = TRUE))
})

test_that("adaptive launcher executes fail-closed path and arity guards", {
  wrong_arity <- launcher_run(c("prepare-adaptive", "only-one-argument"))
  expect_identical(attr(wrong_arity, "status"), 64L)

  base <- launcher_test_path("v3 launcher paths with spaces")
  unlink(base, recursive = TRUE)
  dir.create(base)
  d1 <- file.path(base, "d1 final")
  dir.create(d1)

  d3_out <- file.path(base, "d3 plan")
  dir.create(d3_out)
  d3 <- launcher_run(c("prepare-adaptive", d3_out, "d3", launcher_repo, d1))
  expect_true(!is.null(attr(d3, "status")))
  expect_match(paste(d3, collapse = "\n"), "D3/D4 remain blocked", fixed = TRUE)

  nested <- file.path(d1, "attempts")
  dir.create(nested)
  nested_run <- launcher_run(c(
    "prepare-adaptive", nested, "d2", launcher_repo, d1
  ))
  expect_true(!is.null(attr(nested_run, "status")))
  expect_match(paste(nested_run, collapse = "\n"), "distinct and nonnested")

  nonempty <- file.path(base, "nonempty plan")
  dir.create(nonempty)
  writeLines("unexpected", file.path(nonempty, "member"))
  nonempty_run <- launcher_run(c(
    "prepare-adaptive", nonempty, "d2", launcher_repo, d1
  ))
  expect_true(!is.null(attr(nonempty_run, "status")))
  expect_match(paste(nonempty_run, collapse = "\n"), "must be empty")

  target <- file.path(base, "real plan")
  alias <- file.path(base, "plan alias")
  dir.create(target)
  testthat::skip_if_not(file.symlink(target, alias), "symlinks unavailable")
  alias_run <- launcher_run(c(
    "prepare-adaptive", alias, "d2", launcher_repo, d1
  ))
  expect_true(!is.null(attr(alias_run, "status")))
  expect_match(paste(alias_run, collapse = "\n"), "existing real directory")
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
