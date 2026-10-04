# hsquared#317: missing group values must not become a silent "NA" level.

test_that("common_env() rejects missing group values", {
  ped <- data.frame(
    id = 1:12,
    sire = c(NA, NA, NA, NA, 1, 1, 3, 3, 5, 5, 7, 7),
    dam = c(NA, NA, NA, NA, 2, 2, 4, 4, 6, 6, 8, 8)
  )
  set.seed(1)
  dat <- data.frame(
    id = rep(5:12, each = 2),
    y = rnorm(16),
    x = rnorm(16),
    litter = rep(c("a", "b", "c", "d"), each = 4)
  )
  dat$litter[c(2, 5)] <- NA

  expect_error(
    hsquared:::hs_build_model_spec(
      y ~ x + animal(1 | id, pedigree = ped) + common_env(1 | litter),
      data = dat,
      family = stats::gaussian(),
      REML = TRUE
    ),
    "`common_env()` grouping variable `litter` cannot contain missing values.",
    fixed = TRUE
  )
})

test_that("bare (1 | group) rejects missing group values", {
  ped <- data.frame(
    id = 1:12,
    sire = c(NA, NA, NA, NA, 1, 1, 3, 3, 5, 5, 7, 7),
    dam = c(NA, NA, NA, NA, 2, 2, 4, 4, 6, 6, 8, 8)
  )
  set.seed(1)
  dat <- data.frame(
    id = rep(5:12, each = 2),
    y = rnorm(16),
    x = rnorm(16),
    litter = rep(c("a", "b", "c", "d"), each = 4)
  )
  dat$litter[c(2, 5)] <- NA

  expect_error(
    hsquared:::hs_build_model_spec(
      y ~ x + animal(1 | id, pedigree = ped) + (1 | litter),
      data = dat,
      family = stats::gaussian(),
      REML = TRUE
    ),
    "The `(1 | litter)` grouping variable `litter` cannot contain missing values.",
    fixed = TRUE
  )
})
