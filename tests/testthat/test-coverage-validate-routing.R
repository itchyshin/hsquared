# Live `engine = "validate"` success paths (no Julia). `test-coverage-hsquared-dispatch.R`
# mocks fitters and guards errors; it does not assign the validated spec or name
# repeatability targets on the validate engine.

hs_cov_ped <- function() {
  data.frame(
    id = c("a", "b", "c", "d"),
    sire = c(NA, NA, "a", "a"),
    dam = c(NA, NA, "b", "b"),
    stringsAsFactors = FALSE
  )
}

hs_cov_dat <- function() {
  data.frame(
    y = c(1.1, 2.2, 2.8, 3.5),
    sex = c("f", "m", "m", "f"),
    id = c("a", "b", "c", "d"),
    stringsAsFactors = FALSE
  )
}

test_that("validate names the univariate bridge target in the message and returns the spec", {
  ped <- hs_cov_ped()
  dat <- hs_cov_dat()
  expect_message(
    spec <- hsquared(
      y ~ sex + animal(1 | id, pedigree = ped),
      data = dat,
      control = hs_control(engine = "validate")
    ),
    "HSquared.fit_animal_model",
    fixed = TRUE
  )
  expect_type(spec, "list")
  expect_match(spec$bridge$target, "^fit_animal_model\\(", perl = TRUE)
})

test_that("validate accepts a repeatability formula and records the repeatability bridge target", {
  ped <- hs_cov_ped()
  dat <- data.frame(
    y = c(1, 2, 2.5, 3, 1.5, 2.8),
    id = rep(c("a", "b", "c"), each = 2),
    stringsAsFactors = FALSE
  )
  expect_message(
    spec <- hsquared(
      y ~ animal(1 | id, pedigree = ped) + permanent(1 | id),
      data = dat,
      control = hs_control(engine = "validate")
    ),
    "Validated the v0.1 animal-model contract",
    fixed = TRUE
  )
  expect_match(spec$bridge$target, "repeatability", fixed = TRUE)
})
