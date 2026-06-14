# Opt-in, experimental common-environment model (animal additive genetic + an
# IID environmental effect). Surfaces the twin's fit_two_effect_reml behind the
# explicit `engine = "julia", target = "two_effect"` path. REML only.

test_that("the parser accepts common_env() alongside animal()", {
  ped <- data.frame(
    id = c("a", "b", "c", "d"),
    sire = c(NA, NA, "a", "a"),
    dam = c(NA, NA, "b", "b")
  )
  dat <- data.frame(
    y = c(1, 2, 3, 4),
    id = c("a", "b", "c", "d"),
    litter = c("l1", "l1", "l2", "l2")
  )

  spec <- hsquared:::hs_build_model_spec(
    y ~ animal(1 | id, pedigree = ped) + common_env(1 | litter),
    data = dat,
    family = stats::gaussian(),
    REML = TRUE
  )

  expect_named(spec$random, c("animal", "common_env"))
  expect_equal(spec$random$common_env$type, "common_env")
  expect_equal(spec$random$common_env$group, "litter")
  expect_equal(spec$random$common_env$design, "intercept")
  expect_equal(spec$random$common_env$relationship, "identity")
  expect_equal(spec$random$common_env$levels, c("l1", "l2"))
  expect_match(spec$bridge$target, "two_effect", fixed = TRUE)
})

test_that("at most one second random effect is allowed", {
  ped <- data.frame(id = c("a", "b"), sire = c(NA, NA), dam = c(NA, NA))
  dat <- data.frame(
    y = c(1, 2, 1.5, 2.5),
    id = c("a", "b", "a", "b"),
    litter = c("l1", "l1", "l2", "l2")
  )
  expect_error(
    hsquared:::hs_build_model_spec(
      y ~ animal(1 | id, pedigree = ped) +
        permanent(1 | id) +
        common_env(1 | litter),
      data = dat,
      family = stats::gaussian(),
      REML = TRUE
    ),
    "at most one additional random effect",
    fixed = TRUE
  )
})

test_that("common_env() must be intercept-only and a known column", {
  ped <- data.frame(id = c("a", "b"), sire = c(NA, NA), dam = c(NA, NA))
  dat <- data.frame(y = c(1, 2), id = c("a", "b"), litter = c("l1", "l2"))
  expect_error(
    hsquared:::hs_build_model_spec(
      y ~ animal(1 | id, pedigree = ped) + common_env(age | litter),
      data = dat,
      family = stats::gaussian(),
      REML = TRUE
    ),
    "random-intercept",
    fixed = TRUE
  )
  expect_error(
    hsquared:::hs_build_model_spec(
      y ~ animal(1 | id, pedigree = ped) + common_env(1 | nope),
      data = dat,
      family = stats::gaussian(),
      REML = TRUE
    ),
    "was not found in `data`",
    fixed = TRUE
  )
})

test_that("two_effect is a valid opt-in julia target", {
  expect_equal(
    hsquared:::hs_validate_julia_target("two_effect"),
    "two_effect"
  )
})

test_that("the default engine = \"fit\" rejects a common_env() formula", {
  ped <- data.frame(id = c("a", "b"), sire = c(NA, NA), dam = c(NA, NA))
  dat <- data.frame(
    y = c(1, 2, 3, 4),
    id = c("a", "b", "a", "b"),
    litter = c("l1", "l1", "l2", "l2")
  )
  expect_error(
    hsquared(
      y ~ animal(1 | id, pedigree = ped) + common_env(1 | litter),
      data = dat,
      family = stats::gaussian()
    ),
    "experimental and opt-in",
    fixed = TRUE
  )
})

test_that("target = \"two_effect\" requires a common_env() term", {
  ped <- data.frame(id = c("a", "b"), sire = c(NA, NA), dam = c(NA, NA))
  dat <- data.frame(y = c(1, 2), id = c("a", "b"))
  expect_error(
    hsquared(
      y ~ animal(1 | id, pedigree = ped),
      data = dat,
      family = stats::gaussian(),
      control = hs_control(
        engine = "julia",
        engine_control = list(target = "two_effect")
      )
    ),
    "requires a `common_env(1 | group)` term",
    fixed = TRUE
  )
})

test_that("the two-effect bridge requires an internal payload", {
  expect_error(
    hsquared:::hs_fit_julia_two_effect_payload(list()),
    "`payload` must be an internal `hs_bridge_payload`.",
    fixed = TRUE
  )
})

test_that("common_env_effects extractor requires a fitted object", {
  expect_error(
    common_env_effects(1),
    "requires an `hsquared_fit`",
    fixed = TRUE
  )
})

test_that("hsquared fits the opt-in common-environment model", {
  testthat::skip_on_cran()
  testthat::skip_if_not(
    hsquared:::hs_julia_bridge_available(),
    "JuliaCall, Julia, and local HSquared.jl are required for live two-effect."
  )

  # Founders a-d plus offspring e-h, grouped into litters; the common-environment
  # effect (litter) is shared by litter-mates and independent across litters.
  ped <- data.frame(
    id = c("a", "b", "c", "d", "e", "f", "g", "h"),
    sire = c(NA, NA, NA, NA, "a", "a", "c", "c"),
    dam = c(NA, NA, NA, NA, "b", "b", "d", "d")
  )
  set.seed(7)
  ids <- ped$id
  litter <- c("l1", "l1", "l2", "l2", "l3", "l3", "l4", "l4")
  ce <- stats::setNames(stats::rnorm(4, 0, 0.8), c("l1", "l2", "l3", "l4"))
  dat <- data.frame(
    y = 3 + ce[litter] + stats::rnorm(8, 0, 0.7),
    id = ids,
    litter = litter
  )

  fit <- hsquared(
    y ~ animal(1 | id, pedigree = ped) + common_env(1 | litter),
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
  expect_equal(vc$component, c("animal", "common_env", "residual"))
  expect_true(all(is.finite(vc$estimate)) && all(vc$estimate > 0))
  h2 <- heritability(fit)$estimate
  expect_true(is.finite(h2) && h2 >= 0 && h2 < 1)
  expect_equal(nrow(common_env_effects(fit)), 4L)
  expect_equal(
    fit_diagnostics(fit)$value[
      fit_diagnostics(fit)$metric == "variance_components_source"
    ],
    "estimated_two_effect_reml"
  )
})
