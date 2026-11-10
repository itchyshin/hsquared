# Coverage lane for R/autoplot.R: the recompute fallbacks and refusal paths of
# the figure builders. Plot data are checked against closed forms (normal
# bands, eigenvalues, Legendre covariance surfaces), not against drawn pixels.

hs_cov_plot_fit <- function(result) {
  structure(list(result = result, spec = list(), payload = list()), class = "hsquared_fit")
}

hs_cov_rr_plot_fit <- function(K, lower = 0, upper = 4, order = 2L) {
  hs_cov_plot_fit(
    list(
      coefficient_covariance = K,
      random_regression = list(covariate = "age", lower = lower, upper = upper, order = order)
    )
  )
}

test_that("a variance plot without a heritability table has only the variance-component panel", {
  fit <- hs_cov_plot_fit(
    list(
      variance_components = data.frame(
        component = c("animal", "residual"),
        estimate = c(0.6, 0.9)
      )
    )
  )
  p <- ggplot2::autoplot(fit, "variance")
  expect_s3_class(p, "ggplot")
  expect_identical(unique(p$data$panel), "variance components")
  expect_setequal(as.character(p$data$term), c("animal", "residual"))
  expect_equal(
    p$data$estimate[match(c("animal", "residual"), as.character(p$data$term))],
    c(0.6, 0.9)
  )
  expect_true(all(is.na(p$data$lo)))
  expect_true(all(is.na(p$data$hi)))
})

test_that("variance whiskers are estimate +/- 1.96 SE", {
  fit <- hs_cov_plot_fit(
    list(
      variance_components = data.frame(component = c("animal", "residual"), estimate = c(0.6, 0.9)),
      variance_component_se = data.frame(component = c("animal", "residual"), se = c(0.1, 0.2)),
      heritability = data.frame(term = "animal", estimate = 0.4),
      heritability_se = 0.05
    )
  )
  p <- ggplot2::autoplot(fit, "variance")
  vc <- p$data[p$data$panel == "variance components", ]
  expect_equal(vc$lo, c(0.6, 0.9) - 1.96 * c(0.1, 0.2))
  expect_equal(vc$hi, c(0.6, 0.9) + 1.96 * c(0.1, 0.2))
  h2 <- p$data[p$data$panel == "heritability", ]
  expect_equal(h2$lo, 0.4 - 1.96 * 0.05)
  expect_equal(h2$hi, 0.4 + 1.96 * 0.05)
})

test_that("breeding-value plots take PEV from the payload, from the extractor, by trait, or not at all", {
  bv <- data.frame(id = c("a", "b", "c"), value = c(-0.5, 0.1, 0.7))

  no_pev <- hs_cov_plot_fit(list(breeding_values = bv))
  p <- ggplot2::autoplot(no_pev, "breeding_values")
  expect_true(all(is.na(p$data$pev)))
  expect_identical(attr(p, "hsquared_meta")$type, "breeding_values")

  payload_no_pev <- hs_cov_plot_fit(
    list(breeding_values_plot_data = list(id = bv$id, value = bv$value))
  )
  expect_true(all(is.na(ggplot2::autoplot(payload_no_pev, "breeding_values")$data$pev)))

  with_pev <- hs_cov_plot_fit(
    list(
      breeding_values = bv,
      prediction_error_variance = data.frame(id = c("c", "a", "b"), value = c(0.3, 0.1, 0.2))
    )
  )
  p <- ggplot2::autoplot(with_pev, "breeding_values")
  expect_equal(p$data$pev[match(c("a", "b", "c"), p$data$id)], c(0.1, 0.2, 0.3))

  traited <- hs_cov_plot_fit(
    list(
      breeding_values = data.frame(
        id = rep(c("a", "b"), 2),
        trait = rep(c("t1", "t2"), each = 2),
        value = c(-1, 1, -2, 2)
      ),
      prediction_error_variance = data.frame(
        id = rep(c("a", "b"), 2),
        trait = rep(c("t1", "t2"), each = 2),
        value = c(0.1, 0.2, 0.3, 0.4)
      )
    )
  )
  p <- ggplot2::autoplot(traited, "breeding_values")
  key <- paste(p$data$id, p$data$trait)
  expect_equal(p$data$pev[match(c("a t1", "b t1", "a t2", "b t2"), key)], c(0.1, 0.2, 0.3, 0.4))

  traited_no_pev <- traited
  traited_no_pev$result$prediction_error_variance <- NULL
  expect_true(all(is.na(ggplot2::autoplot(traited_no_pev, "breeding_values")$data$pev)))

  traits_in_ebv_only <- traited
  traits_in_ebv_only$result$prediction_error_variance <- data.frame(
    id = c("a", "b"),
    value = c(0.5, 0.6)
  )
  p <- ggplot2::autoplot(traits_in_ebv_only, "breeding_values")
  expect_equal(unique(p$data$pev[p$data$id == "a"]), 0.5)
})

test_that("the genetic-correlation heatmap needs a matrix with at least two traits", {
  one_trait <- hs_cov_plot_fit(list(genetic_correlation = matrix(1, 1, 1)))
  expect_error(
    ggplot2::autoplot(one_trait, "g_matrix"),
    "`type = \"g_matrix\"` needs a multivariate fit with a genetic correlation matrix (rotation-invariant).",
    fixed = TRUE
  )
})

test_that("the G scree needs at least two eigenvalues", {
  one_trait <- hs_cov_plot_fit(list(genetic_covariance = matrix(2, 1, 1)))
  expect_error(
    ggplot2::autoplot(one_trait, "g_geometry"),
    "`type = \"g_geometry\"` needs a multivariate fit with a genetic covariance matrix",
    fixed = TRUE
  )
})

test_that("rr eigenfunctions recomputed from K_g have no variance shares when none are carried", {
  fit <- hs_cov_rr_plot_fit(diag(c(0.8, 0.2)))
  p <- ggplot2::autoplot(fit, "rr_eigenfunctions")
  expect_s3_class(p, "ggplot")
  expect_identical(attr(p, "hsquared_meta")$type, "rr_eigenfunctions")
})

test_that("the rr covariance surface equals phi K phi' and its correlation has a unit diagonal", {
  K <- diag(c(0.8, 0.2))
  fit <- hs_cov_rr_plot_fit(K)
  at <- c(0, 2, 4)
  p <- ggplot2::autoplot(fit, "rr_surface", at = at)
  expect_s3_class(p, "ggplot")
  t_std <- 2 * (at - 0) / (4 - 0) - 1
  phi <- hsquared:::hs_legendre_design(t_std, 2L)
  surface <- phi %*% K %*% t(phi)
  expect_equal(sort(unique(round(p$data[[ncol(p$data)]], 10))), sort(unique(round(as.numeric(surface), 10))))

  corr <- ggplot2::autoplot(fit, "rr_surface", at = at, correlation = TRUE)
  expect_s3_class(corr, "ggplot")
  expect_lte(max(corr$data[[ncol(corr$data)]]), 1 + 1e-12)
})

test_that("an rr correlation surface is refused where the genetic variance is not positive", {
  fit <- hs_cov_rr_plot_fit(matrix(0, 2, 2))
  expect_error(
    ggplot2::autoplot(fit, "rr_surface", at = c(0, 4), correlation = TRUE),
    "`type = \"rr_surface\"` correlation is undefined: a covariate point has non-positive genetic variance.",
    fixed = TRUE
  )
})

test_that("a flat vector of length n^2 is read back as an n x n matrix, anything else is not", {
  as_sq <- hsquared:::hs_as_square_matrix
  m <- matrix(c(1, 2, 3, 4), 2)
  expect_identical(as_sq(m), m)
  expect_identical(as_sq(c(1, 2, 3, 4)), m)
  expect_identical(as_sq(as.list(c(1, 2, 3, 4))), m)
  expect_null(as_sq(c(1, 2, 3)))
  expect_null(as_sq(1))
  expect_null(as_sq(1:5))
  expect_null(as_sq(character()))
})

test_that("an rr eigenfunction payload without variance shares is drawn with no shares", {
  ef_mat <- matrix(c(0.5, 0.6, 0.7, -0.1, 0.0, 0.1), nrow = 3)
  fit <- hs_cov_plot_fit(
    list(
      rr_eigenfunctions_plot_data = list(
        covariate = c(1, 2, 3),
        eigenfunctions = ef_mat,
        rotation_invariant = TRUE
      )
    )
  )
  p <- ggplot2::autoplot(fit, "rr_eigenfunctions")
  expect_equal(nrow(p$data), 6L)
  expect_equal(sort(p$data$value), sort(as.numeric(ef_mat)))
})
