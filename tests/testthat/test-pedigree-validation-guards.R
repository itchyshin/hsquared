# Message-pinning tests for the pedigree-validation guard branches in
# R/model-spec.R (hs_resolve_animal_pedigree, hs_eval_pedigree,
# hs_validate_pedigree). Each guard is reached through the public parser entry
# point hs_build_model_spec(); the cycle guard is covered elsewhere
# (test-parser-robustness.R, test-bridge-payload.R) and is not repeated here.

hs_pvg_pedigree <- function() {
  data.frame(
    id = c("a", "b", "c", "d"),
    sire = c(NA, NA, "a", "a"),
    dam = c(NA, NA, "b", "b"),
    stringsAsFactors = FALSE
  )
}

hs_pvg_data <- function() {
  data.frame(
    y = c(1, 2, 3, 4),
    sex = c("M", "F", "M", "F"),
    id = c("a", "b", "c", "d"),
    stringsAsFactors = FALSE
  )
}

hs_pvg_spec <- function(ped, formula = y ~ sex + animal(1 | id, pedigree = ped)) {
  hsquared:::hs_build_model_spec(
    formula,
    data = hs_pvg_data(),
    family = stats::gaussian(),
    REML = TRUE
  )
}

test_that("a clean pedigree builds, so the guards below are the cause", {
  ped <- hs_pvg_pedigree()
  expect_no_error(hs_pvg_spec(ped))
})

test_that("animal() without pedigree= or an hs_data pedigree is rejected", {
  expect_error(
    hs_pvg_spec(NULL, y ~ sex + animal(1 | id)),
    "in the v0.1 parser, unless",
    fixed = TRUE
  )
})

test_that("an unevaluable pedigree expression is reported by name", {
  expect_error(
    hs_pvg_spec(NULL, y ~ sex + animal(1 | id, pedigree = no_such_pedigree)),
    "Could not evaluate `pedigree = no_such_pedigree`",
    fixed = TRUE
  )
})

test_that("a non-data-frame pedigree is rejected", {
  ped <- c("a", "b", "c", "d")
  expect_error(
    hs_pvg_spec(ped),
    "must be a data frame with at least three columns",
    fixed = TRUE
  )
})

test_that("a pedigree with fewer than three columns is rejected", {
  ped <- hs_pvg_pedigree()[, 1:2]
  expect_error(
    hs_pvg_spec(ped),
    "must be a data frame with at least three columns",
    fixed = TRUE
  )
})

test_that("missing, empty, or 0 individual IDs are rejected", {
  for (bad in list(NA_character_, "", "0")) {
    ped <- hs_pvg_pedigree()
    ped$id[[4L]] <- bad
    expect_error(
      hs_pvg_spec(ped),
      "individual IDs cannot be missing, empty, or `0`",
      fixed = TRUE
    )
  }
})

test_that("duplicate individual IDs are rejected", {
  ped <- hs_pvg_pedigree()
  ped$id[[4L]] <- "c"
  expect_error(
    hs_pvg_spec(ped),
    "contains duplicate individual IDs",
    fixed = TRUE
  )
})

test_that("a known parent that is not an individual row is rejected", {
  ped <- hs_pvg_pedigree()
  ped$sire[[4L]] <- "z"
  expect_error(
    hs_pvg_spec(ped),
    "contains known parent ID not present as individual IDs: z",
    fixed = TRUE
  )

  ped$dam[[4L]] <- "y"
  expect_error(
    hs_pvg_spec(ped),
    "contains known parent IDs not present as individual IDs",
    fixed = TRUE
  )
})

test_that("an individual listed as its own parent is rejected", {
  ped <- hs_pvg_pedigree()
  ped$sire[[3L]] <- "c"
  expect_error(
    hs_pvg_spec(ped),
    "cannot list an individual as its own parent",
    fixed = TRUE
  )

  ped <- hs_pvg_pedigree()
  ped$dam[[4L]] <- "d"
  expect_error(
    hs_pvg_spec(ped),
    "cannot list an individual as its own parent",
    fixed = TRUE
  )
})

test_that("rows with the same known sire and dam are rejected", {
  ped <- hs_pvg_pedigree()
  ped$dam[[3L]] <- "a"
  expect_error(
    hs_pvg_spec(ped),
    "rows with the same known sire and dam are not supported",
    fixed = TRUE
  )
})
