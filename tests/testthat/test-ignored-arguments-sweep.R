# hsquared#267, #303, #321, #323. These checks do not fit a model.
# #321 also covers metafounder(): the same silent drop of a repeated
# named argument, and formula= rejected as "planned".

test_that("unknown engine_control names error instead of falling back", {
  expect_error(
    hs_control(engine_control = list(targt = "ai_reml")),
    "targt",
    fixed = TRUE
  )
  expect_error(
    hs_control(engine_control = list(iteratons = 10)),
    "iteratons",
    fixed = TRUE
  )
})

test_that("hsquared() rejects arguments in ... on the default engine", {
  ped <- data.frame(
    id = c("a", "b"),
    sire = c(NA, NA),
    dam = c(NA, NA)
  )
  dat <- data.frame(y = c(1, 2), id = c("a", "b"))
  expect_error(
    hsquared(
      y ~ animal(1 | id, pedigree = ped),
      data = dat,
      weights = 1,
      control = hs_control(engine = "validate")
    ),
    "`weights`",
    fixed = TRUE
  )
})

test_that("engine = fit rejects target and variance_components", {
  ped <- data.frame(
    id = c("a", "b"),
    sire = c(NA, NA),
    dam = c(NA, NA)
  )
  dat <- data.frame(y = c(1, 2), id = c("a", "b"))
  expect_error(
    hsquared(
      y ~ animal(1 | id, pedigree = ped),
      data = dat,
      control = hs_control(
        engine = "fit",
        engine_control = list(target = "ai_reml")
      )
    ),
    "target",
    fixed = TRUE
  )
  expect_error(
    hsquared(
      y ~ animal(1 | id, pedigree = ped),
      data = dat,
      control = hs_control(
        engine = "fit",
        engine_control = list(variance_components = c(1, 1))
      )
    ),
    "variance_components",
    fixed = TRUE
  )
})

test_that("a repeated pedigree= argument is an error", {
  ped <- data.frame(
    id = c("a", "b"),
    sire = c(NA, NA),
    dam = c(NA, NA)
  )
  ped2 <- ped
  dat <- data.frame(y = c(1, 2), id = c("a", "b"))
  expect_error(
    hsquared:::hs_build_model_spec(
      y ~ animal(1 | id, pedigree = ped, pedigree = ped2),
      data = dat,
      family = stats::gaussian(),
      REML = TRUE
    ),
    "supplied more than once",
    fixed = TRUE
  )
})

test_that("formula= is rejected and is not described as planned", {
  ped <- data.frame(
    id = c("a", "b"),
    sire = c(NA, NA),
    dam = c(NA, NA)
  )
  dat <- data.frame(y = c(1, 2), id = c("a", "b"))
  expect_error(
    hsquared:::hs_build_model_spec(
      y ~ animal(formula = 1 | id, pedigree = ped),
      data = dat,
      family = stats::gaussian(),
      REML = TRUE
    ),
    "does not accept `formula =`",
    fixed = TRUE
  )
})

test_that("a repeated metafounder argument is an error", {
  ped <- data.frame(
    id = c("sire", "dam", "calf"),
    sire = c(NA, NA, "sire"),
    dam = c(NA, NA, "dam")
  )
  ped2 <- ped
  dat <- data.frame(y = c(1, 2.5, 4), id = c("sire", "dam", "calf"))
  mf_group <- c(sire = "base", dam = "base", calf = "")
  Gamma <- matrix(0.25, nrow = 1, dimnames = list("base", "base"))
  expect_error(
    hsquared:::hs_build_model_spec(
      y ~
        metafounder(
          1 | id,
          pedigree = ped,
          pedigree = ped2,
          group = mf_group,
          Gamma = Gamma
        ),
      data = dat,
      family = stats::gaussian(),
      REML = TRUE
    ),
    "supplied more than once",
    fixed = TRUE
  )
  expect_error(
    hsquared:::hs_build_model_spec(
      y ~
        metafounder(
          1 | id,
          pedigree = ped,
          group = mf_group,
          group = mf_group,
          Gamma = Gamma
        ),
      data = dat,
      family = stats::gaussian(),
      REML = TRUE
    ),
    "supplied more than once",
    fixed = TRUE
  )
})

test_that("metafounder formula= is rejected and is not described as planned", {
  ped <- data.frame(
    id = c("sire", "dam", "calf"),
    sire = c(NA, NA, "sire"),
    dam = c(NA, NA, "dam")
  )
  dat <- data.frame(y = c(1, 2.5, 4), id = c("sire", "dam", "calf"))
  mf_group <- c(sire = "base", dam = "base", calf = "")
  Gamma <- matrix(0.25, nrow = 1, dimnames = list("base", "base"))
  err <- tryCatch(
    hsquared:::hs_build_model_spec(
      y ~
        metafounder(
          formula = 1 | id,
          pedigree = ped,
          group = mf_group,
          Gamma = Gamma
        ),
      data = dat,
      family = stats::gaussian(),
      REML = TRUE
    ),
    error = function(e) conditionMessage(e)
  )
  expect_match(err, "does not accept `formula =`", fixed = TRUE)
  expect_false(grepl("planned, not implemented", err, fixed = TRUE))
})

test_that("bivariate cbind reports the dense-cell refusal", {
  skip_if_not(
    hsquared:::hs_julia_bridge_available(
      "/Users/z3437171/local-scratch/hsqjl-sweep-cleanup-20261004"
    ),
    "Julia bridge is not available for the dense-cell refusal"
  )
  ped <- data.frame(
    id = c("a", "b"),
    sire = c(NA, NA),
    dam = c(NA, NA)
  )
  dat <- data.frame(
    y1 = c(1, 2),
    y2 = c(3, 4),
    id = c("a", "b")
  )
  expect_error(
    hsquared(
      cbind(y1, y2) ~ animal(1 | id, pedigree = ped),
      data = dat,
      control = hs_control(
        engine = "fit",
        engine_control = list(
          max_dense_cells = 1,
          julia_project = "/Users/z3437171/local-scratch/hsqjl-sweep-cleanup-20261004"
        )
      )
    ),
    "max_dense_cells"
  )
})
