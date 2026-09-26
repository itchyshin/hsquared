# hsquared#237: cbind() + permanent() on the default multivariate route.

hs_237_tiny <- function() {
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
    cage = c("L1", "L1", "L2", "L2", "L1"),
    stringsAsFactors = FALSE
  )
  list(ped = ped, dat = dat)
}

test_that("cbind + permanent parses as multivariate PE (hsquared#237)", {
  fx <- hs_237_tiny()
  spec <- hsquared:::hs_build_model_spec(
    cbind(y1, y2) ~ sex + animal(1 | id, pedigree = fx$ped) + permanent(1 | id),
    data = fx$dat,
    family = stats::gaussian(),
    REML = TRUE
  )
  expect_true(spec$response$multivariate)
  expect_named(spec$random, c("animal", "permanent"))
  expect_equal(spec$random$permanent$type, "permanent")
  expect_equal(spec$random$permanent$relationship, "identity")
  expect_match(
    spec$bridge$target,
    "fit_multivariate_repeatability_reml",
    fixed = TRUE
  )
})

test_that("cbind + permanent payload has Y plus pedigree and iid PE blocks", {
  fx <- hs_237_tiny()
  spec <- hsquared:::hs_build_model_spec(
    cbind(y1, y2) ~ sex + animal(1 | id, pedigree = fx$ped) + permanent(1 | id),
    data = fx$dat,
    family = stats::gaussian(),
    REML = TRUE
  )
  payload <- hsquared:::hs_build_bridge_payload(spec)
  expect_true(is.matrix(payload$Y))
  expect_equal(ncol(payload$Y), 2L)
  expect_null(payload$y)
  expect_equal(
    vapply(payload$random_effects, `[[`, "", "name"),
    c("animal", "permanent")
  )
  expect_equal(payload$random_effects[[2L]]$type, "iid")
  expect_equal(payload$random_effects[[2L]]$relmat_status, "identity")
})

test_that("engine = validate accepts cbind + permanent on the default route", {
  fx <- hs_237_tiny()
  out <- hsquared(
    cbind(y1, y2) ~ sex + animal(1 | id, pedigree = fx$ped) + permanent(1 | id),
    data = fx$dat,
    family = stats::gaussian(),
    REML = TRUE,
    control = hs_control(engine = "validate")
  )
  expect_true(out$response$multivariate)
  expect_false(is.null(out$random$permanent))
})

test_that("old cbind + permanent named reject is gone", {
  fx <- hs_237_tiny()
  expect_no_error(
    hsquared:::hs_build_model_spec(
      cbind(y1, y2) ~ animal(1 | id, pedigree = fx$ped) + permanent(1 | id),
      data = fx$dat,
      family = stats::gaussian(),
      REML = TRUE
    )
  )
})

test_that("cbind + common_env remains a named reject", {
  fx <- hs_237_tiny()
  expect_error(
    hsquared:::hs_build_model_spec(
      cbind(y1, y2) ~ animal(1 | id, pedigree = fx$ped) + common_env(1 | cage),
      data = fx$dat,
      family = stats::gaussian(),
      REML = TRUE
    ),
    class = "hsquared_unsupported_syntax"
  )
})

test_that("target = repeatability still refuses cbind", {
  fx <- hs_237_tiny()
  expect_error(
    hsquared(
      cbind(y1, y2) ~ animal(1 | id, pedigree = fx$ped) + permanent(1 | id),
      data = fx$dat,
      family = stats::gaussian(),
      REML = TRUE,
      control = hs_control(
        engine = "julia",
        engine_control = list(target = "repeatability")
      )
    ),
    class = "hsquared_unsupported_syntax"
  )
})

test_that("multivariate_repeatability is a live julia target", {
  expect_identical(
    hsquared:::hs_validate_julia_target("multivariate_repeatability"),
    "multivariate_repeatability"
  )
})

test_that("hs_effect_targets(permanent) includes the MV PE target", {
  expect_identical(
    hsquared:::hs_effect_targets("permanent"),
    c("repeatability", "multivariate_repeatability")
  )
  expect_identical(
    hsquared:::hs_second_effect_target("permanent"),
    "repeatability"
  )
})

test_that("live cbind + permanent fit exposes animal and PE when Julia has the fitter", {
  hs_skip_live_julia()
  jl_wt <- path.expand("~/local-scratch/lanes/HSquared.jl-237-mv-permanent")
  if (
    !nzchar(Sys.getenv("HSQUARED_JULIA_PROJECT", "")) &&
      file.exists(file.path(jl_wt, "Project.toml"))
  ) {
    Sys.setenv(HSQUARED_JULIA_PROJECT = jl_wt)
  }
  fx <- hs_237_tiny()
  skip_if_not(
    hsquared:::hs_julia_bridge_available(),
    "JuliaCall, Julia, and local HSquared.jl are required."
  )
  hsquared:::hs_julia_setup(hsquared:::hs_default_julia_project())
  skip_if_not(
    isTRUE(JuliaCall::julia_eval(
      "isdefined(HSquared, :fit_multivariate_repeatability_reml)"
    )),
    "This HSquared.jl checkout lacks fit_multivariate_repeatability_reml (need #398)."
  )
  fit <- suppressWarnings(hsquared(
    cbind(y1, y2) ~ sex + animal(1 | id, pedigree = fx$ped) + permanent(1 | id),
    data = fx$dat,
    family = stats::gaussian(),
    REML = TRUE
  ))
  expect_equal(fit$spec$target, "multivariate_repeatability")
  expect_equal(
    fit$result$diagnostics$target,
    "multivariate_repeatability_reml"
  )
  expect_equal(fit$result$diagnostics$status, "experimental")
  vc <- variance_components(fit)
  expect_true(all(c("animal", "permanent", "residual") %in% vc$component))
  expect_true(all(vc$estimate[vc$component == "permanent"] >= 0))
  pe <- permanent_effects(fit)
  expect_equal(length(unique(pe$id)), 3L)
  expect_equal(nrow(pe), 6L)
})
