# Opt-in, experimental maternal-genetic two-effect model: direct additive
# genetic effect + maternal additive genetic effect (both pedigree A, the
# maternal effect expressed through the dam). Surfaces fit_two_effect_reml with
# a pedigree relationship for the second effect. REML only.

test_that("the parser accepts maternal_genetic() as a pedigree second effect", {
  ped <- data.frame(
    id = c("a", "b", "c", "d", "e"),
    sire = c(NA, NA, NA, "a", "a"),
    dam = c(NA, NA, NA, "b", "c")
  )
  dat <- data.frame(
    y = c(1, 2, 3, 4),
    id = c("b", "c", "d", "e"),
    mum = c("a", "a", "b", "c")
  )

  spec <- hsquared:::hs_build_model_spec(
    y ~ animal(1 | id, pedigree = ped) + maternal_genetic(1 | mum),
    data = dat,
    family = stats::gaussian(),
    REML = TRUE
  )

  expect_named(spec$random, c("animal", "maternal_genetic"))
  expect_equal(spec$random$maternal_genetic$type, "maternal_genetic")
  expect_equal(spec$random$maternal_genetic$group, "mum")
  expect_equal(spec$random$maternal_genetic$relationship, "pedigree")
  expect_match(spec$bridge$target, "two_effect", fixed = TRUE)
})

test_that("maternal_genetic() dams must be in the pedigree", {
  ped <- data.frame(id = c("a", "b"), sire = c(NA, NA), dam = c(NA, NA))
  dat <- data.frame(y = c(1, 2), id = c("a", "b"), mum = c("a", "ghost"))
  expect_error(
    hsquared:::hs_build_model_spec(
      y ~ animal(1 | id, pedigree = ped) + maternal_genetic(1 | mum),
      data = dat,
      family = stats::gaussian(),
      REML = TRUE
    ),
    "not in the pedigree",
    fixed = TRUE
  )
})

test_that("maternal_genetic() must be intercept-only", {
  ped <- data.frame(id = c("a", "b"), sire = c(NA, NA), dam = c(NA, NA))
  dat <- data.frame(y = c(1, 2), id = c("a", "b"), mum = c("a", "b"))
  expect_error(
    hsquared:::hs_build_model_spec(
      y ~ animal(1 | id, pedigree = ped) + maternal_genetic(age | mum),
      data = dat,
      family = stats::gaussian(),
      REML = TRUE
    ),
    "random-intercept",
    fixed = TRUE
  )
})

test_that("a maternal_genetic() formula needs the two_effect target", {
  ped <- data.frame(id = c("a", "b"), sire = c(NA, NA), dam = c(NA, NA))
  dat <- data.frame(y = c(1, 2), id = c("a", "b"), mum = c("a", "b"))
  expect_error(
    hsquared(
      y ~ animal(1 | id, pedigree = ped) + maternal_genetic(1 | mum),
      data = dat,
      family = stats::gaussian(),
      control = hs_control(
        engine = "julia",
        engine_control = list(target = "ai_reml")
      )
    ),
    "needs `target = \"two_effect\"`",
    fixed = TRUE
  )
})

test_that("hsquared fits the opt-in maternal-genetic model", {
  testthat::skip_on_cran()
  testthat::skip_if_not(
    hsquared:::hs_julia_bridge_available(),
    "JuliaCall, Julia, and local HSquared.jl are required for live maternal fit."
  )

  # Founders a-f; offspring g-n each with a dam among the founders/earlier
  # animals. The maternal effect is expressed through the dam (pedigree A2).
  ped <- data.frame(
    id = c("a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l"),
    sire = c(NA, NA, NA, NA, NA, NA, "a", "a", "c", "c", "e", "e"),
    dam = c(NA, NA, NA, NA, NA, NA, "b", "b", "d", "d", "f", "f")
  )
  set.seed(3)
  rec_id <- c("g", "h", "i", "j", "k", "l")
  rec_mum <- c("b", "b", "d", "d", "f", "f")
  mat <- stats::setNames(
    stats::rnorm(6, 0, 0.8),
    c("a", "b", "c", "d", "e", "f")
  )
  dat <- data.frame(
    y = 4 + mat[rec_mum] + stats::rnorm(6, 0, 0.7),
    id = rec_id,
    mum = rec_mum
  )

  fit <- hsquared(
    y ~ animal(1 | id, pedigree = ped) + maternal_genetic(1 | mum),
    data = dat,
    family = stats::gaussian(),
    control = hs_control(
      engine = "julia",
      engine_control = list(target = "two_effect")
    )
  )

  expect_s3_class(fit, "hsquared_fit")
  expect_equal(fit$spec$target, "two_effect")
  vc <- variance_components(fit)
  expect_equal(vc$component, c("animal", "maternal_genetic", "residual"))
  expect_true(all(is.finite(vc$estimate)) && all(vc$estimate > 0))
  expect_equal(
    fit_diagnostics(fit)$value[
      fit_diagnostics(fit)$metric == "variance_components_source"
    ],
    "estimated_two_effect_reml"
  )
})
