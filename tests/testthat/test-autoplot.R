test_that("theme_hsquared returns a ggplot2 theme", {
  th <- theme_hsquared()
  expect_s3_class(th, "theme")
})

mock_uni_fit <- function() {
  structure(
    list(
      result = list(
        variance_components = data.frame(
          component = c("animal", "residual"),
          estimate = c(0.6, 0.9)
        ),
        variance_component_se = data.frame(
          component = c("animal", "residual"),
          se = c(0.12, 0.10)
        ),
        heritability = data.frame(term = "animal", estimate = 0.4),
        heritability_se = 0.07,
        breeding_values = data.frame(
          id = letters[1:6],
          value = c(-1, -0.4, -0.1, 0.2, 0.5, 1)
        ),
        prediction_error_variance = data.frame(
          id = letters[1:6],
          value = c(0.2, 0.25, 0.22, 0.21, 0.24, 0.2)
        )
      )
    ),
    class = "hsquared_fit"
  )
}

mock_mv_fit <- function() {
  g <- matrix(
    c(1, 0.3, 0.3, 1),
    2,
    2,
    dimnames = list(c("t1", "t2"), c("t1", "t2"))
  )
  structure(
    list(result = list(genetic_correlation = g)),
    class = "hsquared_fit"
  )
}

mock_gwas <- function() {
  structure(
    data.frame(
      marker = paste0("m", 1:20),
      effect = rnorm(20),
      se = runif(20, 0.1, 0.3),
      z = rnorm(20),
      chisq = rchisq(20, 1),
      p_value = runif(20),
      bonferroni_p = runif(20),
      bh_qvalue = runif(20),
      lod = runif(20, 0, 3)
    ),
    class = c("hs_gwas", "data.frame")
  )
}

test_that("autoplot.hsquared_fit variance returns a ggplot with a zero line", {
  p <- autoplot(mock_uni_fit(), "variance")
  expect_s3_class(p, "ggplot")
  expect_true(any(vapply(
    p$layers,
    function(l) inherits(l$geom, "GeomVline"),
    logical(1)
  )))
})

test_that("autoplot.hsquared_fit breeding_values returns a ggplot", {
  p <- autoplot(mock_uni_fit(), "breeding_values")
  expect_s3_class(p, "ggplot")
  # the PEV band is present
  expect_true(any(vapply(
    p$layers,
    function(l) inherits(l$geom, "GeomRibbon"),
    logical(1)
  )))
})

test_that("autoplot.hsquared_fit g_matrix returns a ggplot for multivariate", {
  p <- autoplot(mock_mv_fit(), "g_matrix")
  expect_s3_class(p, "ggplot")
})

test_that("g_matrix errors on a univariate fit (no correlation matrix)", {
  expect_error(
    autoplot(mock_uni_fit(), "g_matrix"),
    "multivariate fit",
    fixed = TRUE
  )
})

test_that("autoplot.hs_gwas returns a Manhattan ggplot with a Bonferroni line", {
  p <- autoplot(mock_gwas())
  expect_s3_class(p, "ggplot")
  expect_true(any(vapply(
    p$layers,
    function(l) inherits(l$geom, "GeomHline"),
    logical(1)
  )))
})

test_that("hs_recovery_forest returns a ggplot and validates columns", {
  rec <- data.frame(
    target = c("a", "b"),
    bias = c(0.01, -0.02),
    mcse = c(0.02, 0.03)
  )
  p <- hs_recovery_forest(rec)
  expect_s3_class(p, "ggplot")
  expect_error(
    hs_recovery_forest(data.frame(x = 1)),
    "must have",
    fixed = TRUE
  )
})

test_that("variance autoplot errors when there are no variance components", {
  bad <- structure(list(result = list()), class = "hsquared_fit")
  expect_error(autoplot(bad, "variance"), "no variance-component")
})
