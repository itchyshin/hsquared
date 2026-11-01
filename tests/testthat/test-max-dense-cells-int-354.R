# hsquared#354: `hs_validate_max_dense_cells()` returns a double (default 1e6),
# but HSquared.jl#494 types the multivariate entry points' `max_dense_cells`
# keyword as `Integer`. Every bridge route must therefore hand the engine
# `Int(...)`, as the animal-model and repeatability routes already do.

hs_354_tiny <- function() {
  ped <- data.frame(
    id = c("a", "b", "c"),
    sire = c(NA, NA, "a"),
    dam = c(NA, NA, "b"),
    stringsAsFactors = FALSE
  )
  dat <- data.frame(
    y1 = c(1, 2, 3, 1.5, 2.5),
    y2 = c(2, 1, 2.5, 1.2, 2.2),
    sex = factor(c("F", "M", "F", "M", "F")),
    id = c("a", "b", "c", "a", "b"),
    stringsAsFactors = FALSE
  )
  list(ped = ped, dat = dat)
}

# Run `hsquared()` with the Julia bridge mocked out. Returns every
# `julia_command()` string the bridge sent; the multivariate fit command is
# made to throw so nothing downstream of the engine is needed.
hs_354_capture_commands <- function(formula, fx) {
  cmds <- character()
  testthat::local_mocked_bindings(
    hs_julia_bridge_available = function(...) TRUE,
    hs_julia_setup = function(...) invisible(TRUE),
    .package = "hsquared"
  )
  testthat::local_mocked_bindings(
    julia_assign = function(...) invisible(NULL),
    julia_eval = function(...) TRUE,
    julia_command = function(cmd, ...) {
      cmds <<- c(cmds, cmd)
      if (grepl("HSquared.fit_multivariate", cmd, fixed = TRUE)) {
        stop("stop after capture (354)")
      }
      invisible(NULL)
    },
    .package = "JuliaCall"
  )
  try(
    suppressWarnings(hsquared(
      formula,
      data = fx$dat,
      family = stats::gaussian(),
      REML = TRUE
    )),
    silent = TRUE
  )
  cmds
}

test_that("the multivariate fit command casts max_dense_cells with Int() (hsquared#354)", {
  fx <- hs_354_tiny()
  cmds <- hs_354_capture_commands(
    cbind(y1, y2) ~ sex + animal(1 | id, pedigree = fx$ped),
    fx
  )
  fit_cmd <- grep("fit_multivariate_reml", cmds, value = TRUE, fixed = TRUE)
  expect_length(fit_cmd, 1L)
  expect_match(
    fit_cmd,
    "max_dense_cells = Int(hsq_max_dense_cells)",
    fixed = TRUE
  )
})

test_that("the multivariate-repeatability fit command casts max_dense_cells with Int() (hsquared#354)", {
  fx <- hs_354_tiny()
  cmds <- hs_354_capture_commands(
    cbind(y1, y2) ~ sex + animal(1 | id, pedigree = fx$ped) + permanent(1 | id),
    fx
  )
  fit_cmd <- grep(
    "fit_multivariate_repeatability_reml",
    cmds,
    value = TRUE,
    fixed = TRUE
  )
  expect_length(fit_cmd, 1L)
  expect_match(
    fit_cmd,
    "max_dense_cells = Int(hsq_max_dense_cells)",
    fixed = TRUE
  )
})

# Source-level guard so a future route cannot reintroduce the bug: every
# `max_dense_cells = <expr>` keyword written into a Julia command in the bridge
# must be wrapped in `Int(...)`.
test_that("no bridge route passes max_dense_cells to Julia without Int() (hsquared#354)", {
  src <- testthat::test_path("..", "..", "R", "julia-bridge.R")
  testthat::skip_if_not(
    file.exists(src),
    "R sources are not available in an installed-package test run."
  )
  lines <- readLines(src, warn = FALSE)
  # Julia-command text only: quoted strings carrying the keyword.
  kw <- grep('"[^"]*max_dense_cells = [^"]*"', lines, value = TRUE)
  expect_gt(length(kw), 0L)
  bare <- kw[!grepl("max_dense_cells = Int\\(", kw)]
  # The bare `hsq_max_dense_cells,` in the two multivariate commands was the
  # bug; assignments (`max_dense_cells = hs_validate...`) are R, not quoted.
  expect_identical(bare, character(0))
})

test_that("a live multivariate fit accepts the default max_dense_cells (hsquared#354)", {
  hs_skip_live_julia()
  skip_if_not(
    hsquared:::hs_julia_bridge_available(),
    "JuliaCall, Julia, and local HSquared.jl are required."
  )
  fx <- hs_354_tiny()
  fit <- suppressWarnings(hsquared(
    cbind(y1, y2) ~ sex + animal(1 | id, pedigree = fx$ped),
    data = fx$dat,
    family = stats::gaussian(),
    REML = TRUE
  ))
  expect_s3_class(fit, "hsquared_fit")
  expect_equal(fit$spec$target, "multivariate")
})
