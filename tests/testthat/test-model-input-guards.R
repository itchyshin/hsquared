# Guards in R/model-spec.R whose messages no other test asserts: the top-level
# input checks, the binomial-counts response checks, the trait-name message
# prefix, the no-observed-level fixed effect, and the hs_data phenotypes check.
# Each test builds the smallest input that reaches the guard through
# `hsquared:::hs_build_model_spec()` unless the comment says otherwise.

hs_mig_pedigree <- function() {
  data.frame(
    id = c("a", "b", "c", "d"),
    sire = c(NA, NA, "a", "a"),
    dam = c(NA, NA, "b", "b"),
    stringsAsFactors = FALSE
  )
}

hs_mig_data <- function() {
  data.frame(
    y = c(1, 2, 3, 4),
    s = c(3, 1, 4, 2),
    f = c(1, 3, 0, 2),
    id = c("a", "b", "c", "d"),
    stringsAsFactors = FALSE
  )
}

hs_mig_spec <- function(formula, data, family = stats::gaussian()) {
  hsquared:::hs_build_model_spec(
    formula,
    data = data,
    family = family,
    REML = TRUE,
    allow_families = c("gaussian", "binomial")
  )
}

# ---- hs_validate_model_inputs() ----

test_that("a one-sided formula is rejected as not two-sided", {
  ped <- hs_mig_pedigree()
  expect_error(
    hs_mig_spec(~ animal(1 | id, pedigree = ped), hs_mig_data()),
    "`formula` must be a two-sided formula.",
    fixed = TRUE
  )
})

test_that("a non-data-frame `data` is rejected", {
  ped <- hs_mig_pedigree()
  expect_error(
    hs_mig_spec(y ~ animal(1 | id, pedigree = ped), list(y = 1:4)),
    "`data` must be a data frame.",
    fixed = TRUE
  )
})

test_that("a non-family `family` is rejected", {
  ped <- hs_mig_pedigree()
  expect_error(
    hs_mig_spec(y ~ animal(1 | id, pedigree = ped), hs_mig_data(), "gaussian"),
    "`family` must be an R family object such as `gaussian()`.",
    fixed = TRUE
  )
})

# ---- hs_model_data_context() ----

test_that("an hs_data object with non-data-frame phenotypes is rejected", {
  # Called directly: hs_data() validates `phenotypes` on construction, so only
  # a hand-built object of class "hs_data" reaches this guard.
  bad <- structure(list(phenotypes = 1:4), class = "hs_data")
  expect_error(
    hsquared:::hs_model_data_context(bad, globalenv()),
    "`data` is an `hs_data` object, but `data$phenotypes` is not a data frame.",
    fixed = TRUE
  )
})

# ---- hs_build_binomial_counts_response() ----

test_that("a character cbind binomial response must be numeric", {
  ped <- hs_mig_pedigree()
  dat <- hs_mig_data()
  dat$s <- as.character(dat$s)
  expect_error(
    hs_mig_spec(
      cbind(s, f) ~ animal(1 | id, pedigree = ped),
      dat,
      stats::binomial()
    ),
    "A `cbind(successes, failures)` binomial response must be numeric.",
    fixed = TRUE
  )
})

test_that("an infinite cbind binomial response must be finite", {
  ped <- hs_mig_pedigree()
  dat <- hs_mig_data()
  dat$s[2L] <- Inf
  expect_error(
    hs_mig_spec(
      cbind(s, f) ~ animal(1 | id, pedigree = ped),
      dat,
      stats::binomial()
    ),
    "binomial response must be finite (no NA).",
    fixed = TRUE
  )
})

test_that("negative or fractional binomial counts are rejected", {
  ped <- hs_mig_pedigree()
  neg <- hs_mig_data()
  neg$f[2L] <- -1
  expect_error(
    hs_mig_spec(
      cbind(s, f) ~ animal(1 | id, pedigree = ped),
      neg,
      stats::binomial()
    ),
    "binomial counts must be non-negative integers.",
    fixed = TRUE
  )
  frac <- hs_mig_data()
  frac$s[1L] <- 2.5
  expect_error(
    hs_mig_spec(
      cbind(s, f) ~ animal(1 | id, pedigree = ped),
      frac,
      stats::binomial()
    ),
    "binomial counts must be non-negative integers.",
    fixed = TRUE
  )
})

test_that("a binomial record with zero trials is rejected", {
  ped <- hs_mig_pedigree()
  dat <- hs_mig_data()
  dat$s[3L] <- 0
  dat$f[3L] <- 0
  expect_error(
    hs_mig_spec(
      cbind(s, f) ~ animal(1 | id, pedigree = ped),
      dat,
      stats::binomial()
    ),
    "record must have at least one trial (successes + failures >= 1).",
    fixed = TRUE
  )
})

test_that("a valid binomial-counts response is accepted (contrast)", {
  ped <- hs_mig_pedigree()
  spec <- hs_mig_spec(
    cbind(s, f) ~ animal(1 | id, pedigree = ped),
    hs_mig_data(),
    stats::binomial()
  )
  expect_identical(spec$response$n_trials, c(4L, 4L, 4L, 4L))
})

# ---- hs_validate_multivariate_trait_names() ----

test_that("the trait-name error names the rule and the remedy", {
  # The detail strings ("duplicate names", "empty or missing names") are
  # asserted in test-multivariate.R; these pin the surrounding sentence.
  expect_error(
    hsquared:::hs_validate_multivariate_trait_names(c("y1", "y1")),
    "Multivariate `cbind()` responses require unique, non-empty trait names (duplicate names: y1). Rename or wrap response columns before fitting.",
    fixed = TRUE
  )
  expect_error(
    hsquared:::hs_validate_multivariate_trait_names(c("y1", NA)),
    "require unique, non-empty trait names (empty or missing names).",
    fixed = TRUE
  )
})

# ---- hs_validate_fixed_model_frame() ----

test_that("a fixed-effect factor with no observed levels is rejected", {
  # Called directly: through hs_build_model_spec() an all-NA fixed effect
  # stops earlier at the missing-value guard.
  frame <- data.frame(sex = factor(c(NA, NA, NA)))
  expect_error(
    hsquared:::hs_validate_fixed_model_frame(frame),
    "The fixed-effect term `sex` has no observed levels, so it cannot be coded as a contrast.",
    fixed = TRUE
  )
})
