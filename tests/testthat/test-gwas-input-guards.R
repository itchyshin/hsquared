# gwas(genome_wide = TRUE, method = "single") input guards on `n_permutations`
# and `seed`. These fire before any engine call, so every test runs without
# Julia (the mock fit below has no engine behind it).

guard_gwas_fit <- function(n = 4) {
  hsquared:::hs_new_fit(
    spec = list(
      method = "REML",
      family = list(family = "gaussian", link = "identity"),
      target = "ai_reml"
    ),
    payload = list(
      y = as.numeric(seq_len(n)),
      X = matrix(1, n, 1),
      Z = methods::as(diag(n), "CsparseMatrix"),
      pedigree = list(
        id = letters[seq_len(n)],
        sire = rep(NA_character_, n),
        dam = rep(NA_character_, n)
      )
    ),
    result = list(
      variance_components = data.frame(
        component = c("animal", "residual"),
        estimate = c(1, 1),
        stringsAsFactors = FALSE
      )
    )
  )
}

guard_scan <- function(...) {
  markers <- matrix(0, 4, 2, dimnames = list(letters[1:4], NULL))
  gwas(
    guard_gwas_fit(),
    markers,
    method = "single",
    genome_wide = TRUE,
    ...
  )
}

# Make the engine unreachable: anything that gets past the input guards stops
# at the bridge check, so the guard messages are provably raised first.
local_no_julia <- function(env = parent.frame()) {
  testthat::local_mocked_bindings(
    hs_julia_bridge_available = function(...) FALSE,
    .package = "hsquared",
    .env = env
  )
}

test_that("genome-wide gwas() rejects a non-positive-whole-number n_permutations", {
  local_no_julia()
  expect_error(
    guard_scan(n_permutations = 0),
    "`n_permutations` must be a positive whole number.",
    fixed = TRUE
  )
  expect_error(guard_scan(n_permutations = -3), "positive whole number")
  expect_error(guard_scan(n_permutations = NA), "positive whole number")
  expect_error(guard_scan(n_permutations = c(10, 20)), "positive whole number")
  expect_error(
    suppressWarnings(guard_scan(n_permutations = "abc")),
    "positive whole number"
  )
})

test_that("genome-wide gwas() rejects a non-scalar or missing seed", {
  local_no_julia()
  expect_error(
    guard_scan(seed = NA),
    "`seed` must be a single integer.",
    fixed = TRUE
  )
  expect_error(guard_scan(seed = c(1, 2)), "single integer")
})

test_that("the guards fire before any engine call", {
  local_no_julia()
  # Valid inputs get past the guards and stop at the (mocked-absent) bridge ...
  expect_error(guard_scan(), "requires Julia")
  # ... whereas invalid inputs never reach it.
  err <- tryCatch(guard_scan(n_permutations = 0), error = conditionMessage)
  expect_false(grepl("requires Julia", err, fixed = TRUE))
})

test_that("a fractional n_permutations or seed is coerced by as.integer (current behaviour)", {
  # Documented current behaviour, not an endorsement: 12.7 becomes 12 and passes
  # the guard, so the error is the bridge check, not the input-validation one.
  local_no_julia()
  expect_error(guard_scan(n_permutations = 12.7), "requires Julia")
  expect_error(guard_scan(seed = 12.7), "requires Julia")
  expect_identical(as.integer(12.7), 12L)
})
