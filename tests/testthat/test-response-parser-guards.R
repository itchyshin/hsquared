# Response and missing-value guards in hs_parse_response() / hs_build_model_spec().
# Pure R: a 6-animal pedigree and a tiny data frame, no Julia.

guard_ped <- function() {
  data.frame(
    animal = c("a", "b", "c", "d", "e", "f"),
    father = c(NA, NA, "a", "a", "c", "c"),
    mother = c(NA, NA, "b", "b", "d", "b")
  )
}

guard_dat <- function() {
  data.frame(
    y = c(1.1, 2.3, 3.2, 2.8, 4.1, 3.9),
    y2 = c(0.4, 1.0, 1.7, 1.2, 2.2, 1.9),
    sex = c("f", "m", "f", "m", "f", "m"),
    id = c("a", "b", "c", "d", "e", "f")
  )
}

guard_spec <- function(formula, dat) {
  hsquared:::hs_build_model_spec(
    formula,
    data = dat,
    family = stats::gaussian(),
    REML = TRUE
  )
}

test_that("character or factor responses are rejected", {
  ped <- guard_ped()
  dat <- guard_dat()
  dat$y <- c("lo", "hi", "lo", "hi", "lo", "hi")
  expect_error(
    guard_spec(y ~ sex + animal(1 | id, pedigree = ped), dat),
    "The v0.1 parser supports numeric Gaussian responses only",
    fixed = TRUE
  )
  dat$y <- factor(dat$y)
  expect_error(
    guard_spec(y ~ sex + animal(1 | id, pedigree = ped), dat),
    "The v0.1 parser supports numeric Gaussian responses only",
    fixed = TRUE
  )
})

test_that("NA in a univariate response is rejected", {
  ped <- guard_ped()
  dat <- guard_dat()
  dat$y[3] <- NA
  expect_error(
    guard_spec(y ~ sex + animal(1 | id, pedigree = ped), dat),
    "Missing values in the response are not implemented for univariate models",
    fixed = TRUE
  )
})

test_that("Inf in a univariate response is rejected", {
  ped <- guard_ped()
  dat <- guard_dat()
  dat$y[2] <- Inf
  expect_error(
    guard_spec(y ~ sex + animal(1 | id, pedigree = ped), dat),
    "Response values must be finite.",
    fixed = TRUE
  )
  dat$y[2] <- -Inf
  expect_error(
    guard_spec(y ~ sex + animal(1 | id, pedigree = ped), dat),
    "Response values must be finite.",
    fixed = TRUE
  )
})

test_that("a matrix-valued response not written with cbind() is rejected", {
  ped <- guard_ped()
  dat <- guard_dat()
  dat$y <- cbind(dat$y, dat$y2)
  expect_error(
    guard_spec(y ~ sex + animal(1 | id, pedigree = ped), dat),
    "Multivariate responses must use `cbind(trait1, trait2, ...)`",
    fixed = TRUE
  )
})

test_that("cbind() of a character column is rejected as non-numeric", {
  ped <- guard_ped()
  dat <- guard_dat()
  dat$y2 <- c("a", "b", "a", "b", "a", "b")
  expect_error(
    guard_spec(cbind(y, y2) ~ sex + animal(1 | id, pedigree = ped), dat),
    "Multivariate `cbind()` responses must be numeric.",
    fixed = TRUE
  )
})

test_that("Inf inside cbind() is rejected even though NA is allowed", {
  ped <- guard_ped()
  dat <- guard_dat()
  dat$y2[4] <- Inf
  expect_error(
    guard_spec(cbind(y, y2) ~ sex + animal(1 | id, pedigree = ped), dat),
    "Observed multivariate response values must be finite",
    fixed = TRUE
  )
})

test_that("an all-NA trait column in cbind() is rejected", {
  ped <- guard_ped()
  dat <- guard_dat()
  dat$y2 <- NA_real_
  expect_error(
    guard_spec(cbind(y, y2) ~ sex + animal(1 | id, pedigree = ped), dat),
    "Each trait in a multivariate `cbind()` response must have at least one observed value",
    fixed = TRUE
  )
})

# The "at least two trait columns" guard is unreachable through the formula
# path: model.response() drops a one-column cbind() matrix to a plain vector,
# so `cbind(y)` is parsed as an ordinary univariate response.
test_that("a one-column cbind() collapses to a univariate response", {
  ped <- guard_ped()
  dat <- guard_dat()
  spec <- guard_spec(cbind(y) ~ sex + animal(1 | id, pedigree = ped), dat)
  expect_false(spec$response$multivariate)
  expect_null(spec$response$trait_names)
  expect_equal(spec$response$values, dat$y)
})

test_that("NA inside cbind() is allowed and trait names are retained", {
  ped <- guard_ped()
  dat <- guard_dat()
  dat$y2[c(2, 5)] <- NA
  spec <- guard_spec(
    cbind(y, y2) ~ sex + animal(1 | id, pedigree = ped),
    dat
  )
  expect_true(spec$response$multivariate)
  expect_equal(spec$response$trait_names, c("y", "y2"))
  expect_equal(dim(spec$response$values), c(6L, 2L))
  expect_equal(colnames(spec$response$values), c("y", "y2"))
  expect_equal(sum(is.na(spec$response$values)), 2L)
})

test_that("NA in a fixed-effect variable still stops", {
  ped <- guard_ped()
  dat <- guard_dat()
  dat$sex[2] <- NA
  expect_error(
    guard_spec(y ~ sex + animal(1 | id, pedigree = ped), dat),
    "Missing values in fixed-effect variables are not implemented",
    fixed = TRUE
  )
})
