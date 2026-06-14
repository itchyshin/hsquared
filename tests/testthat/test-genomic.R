# Opt-in, experimental genomic GREML model: a single genomic random effect with
# a user-supplied genomic relationship inverse (Ginv) instead of a pedigree.
# Surfaces fit_ai_reml on a Ginv-based animal_model_spec. REML only.

hs_test_ginv <- function(ids) {
  n <- length(ids)
  g <- diag(n)
  for (i in seq_len(n - 1L)) {
    g[i, i + 1L] <- g[i + 1L, i] <- 0.2
  }
  ginv <- solve(g)
  dimnames(ginv) <- list(ids, ids)
  ginv
}

test_that("the parser accepts genomic(1 | id, Ginv = Ginv) as a primary effect", {
  ids <- paste0("g", 1:4)
  Ginv <- hs_test_ginv(ids)
  dat <- data.frame(y = c(1, 2, 3, 4), id = ids)

  spec <- hsquared:::hs_build_model_spec(
    y ~ genomic(1 | id, Ginv = Ginv),
    data = dat,
    family = stats::gaussian(),
    REML = TRUE
  )

  expect_named(spec$random, "genomic")
  expect_equal(spec$random$genomic$type, "genomic")
  expect_equal(spec$random$genomic$group, "id")
  expect_equal(spec$random$genomic$relationship, "genomic")
  expect_equal(spec$random$genomic$ids, ids)
  expect_match(spec$bridge$target, "Ginv", fixed = TRUE)
})

test_that("a formula must contain exactly one primary effect", {
  ids <- paste0("g", 1:2)
  Ginv <- hs_test_ginv(ids)
  ped <- data.frame(id = ids, sire = c(NA, NA), dam = c(NA, NA))
  dat <- data.frame(y = c(1, 2), id = ids)
  # animal() AND genomic() together is rejected (one primary effect only)
  expect_error(
    hsquared:::hs_build_model_spec(
      y ~ animal(1 | id, pedigree = ped) + genomic(1 | id, Ginv = Ginv),
      data = dat,
      family = stats::gaussian(),
      REML = TRUE
    ),
    "one primary",
    fixed = TRUE
  )
})

test_that("genomic() requires a Ginv argument", {
  ids <- paste0("g", 1:2)
  dat <- data.frame(y = c(1, 2), id = ids)
  expect_error(
    hsquared:::hs_build_model_spec(
      y ~ genomic(1 | id),
      data = dat,
      family = stats::gaussian(),
      REML = TRUE
    ),
    "requires a `Ginv`",
    fixed = TRUE
  )
})

test_that("genomic() ids must be in the Ginv dimnames", {
  ids <- paste0("g", 1:3)
  Ginv <- hs_test_ginv(ids)
  dat <- data.frame(y = c(1, 2), id = c("g1", "ghost"))
  expect_error(
    hsquared:::hs_build_model_spec(
      y ~ genomic(1 | id, Ginv = Ginv),
      data = dat,
      family = stats::gaussian(),
      REML = TRUE
    ),
    "not in the `Ginv`",
    fixed = TRUE
  )
})

test_that("genomic is a valid opt-in julia target", {
  expect_equal(hsquared:::hs_validate_julia_target("genomic"), "genomic")
})

test_that("the default engine = \"fit\" rejects a genomic() formula", {
  ids <- paste0("g", 1:3)
  Ginv <- hs_test_ginv(ids)
  dat <- data.frame(y = c(1, 2, 3), id = ids)
  expect_error(
    hsquared(
      y ~ genomic(1 | id, Ginv = Ginv),
      data = dat,
      family = stats::gaussian()
    ),
    "experimental and opt-in",
    fixed = TRUE
  )
})

test_that("the genomic bridge requires an internal payload", {
  expect_error(
    hsquared:::hs_fit_julia_genomic_payload(list()),
    "`payload` must be an internal `hs_bridge_payload`.",
    fixed = TRUE
  )
})

test_that("hsquared fits the opt-in genomic GREML model", {
  testthat::skip_on_cran()
  testthat::skip_if_not(
    hsquared:::hs_julia_bridge_available(),
    "JuliaCall, Julia, and local HSquared.jl are required for live GREML."
  )

  set.seed(5)
  na <- 8
  ids <- paste0("g", seq_len(na))
  m <- matrix(stats::rbinom(na * 60, 2, 0.3), na, 60)
  mc <- scale(m, scale = FALSE)
  g <- tcrossprod(mc)
  g <- g / mean(diag(g)) + diag(na) * 0.01
  Ginv <- solve(g)
  dimnames(Ginv) <- list(ids, ids)

  n <- 24
  rec <- rep(ids, length.out = n)
  dat <- data.frame(
    y = 3 + stats::rnorm(n, 0, 1),
    id = rec
  )

  fit <- hsquared(
    y ~ genomic(1 | id, Ginv = Ginv),
    data = dat,
    family = stats::gaussian(),
    control = hs_control(
      engine = "julia",
      engine_control = list(target = "genomic")
    )
  )

  expect_s3_class(fit, "hsquared_fit")
  expect_equal(fit$spec$target, "genomic")
  vc <- variance_components(fit)
  expect_equal(vc$component, c("genomic", "residual"))
  expect_true(all(is.finite(vc$estimate)) && all(vc$estimate > 0))
  h2 <- heritability(fit)$estimate
  expect_true(is.finite(h2) && h2 > 0 && h2 < 1)
  expect_equal(nrow(breeding_values(fit)), na)
  expect_equal(
    fit_diagnostics(fit)$value[
      fit_diagnostics(fit)$metric == "variance_components_source"
    ],
    "estimated_genomic_ai_reml"
  )
})
