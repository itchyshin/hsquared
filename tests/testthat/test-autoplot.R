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

mock_mv_fit_h2 <- function(h2 = c(t1 = 0.05, t2 = 0.4)) {
  f <- mock_mv_fit()
  f$result$heritability <- data.frame(
    term = names(h2),
    estimate = as.numeric(h2),
    stringsAsFactors = FALSE
  )
  f
}

# A fit carrying the engine `genetic_correlation_plot_data` payload. NOTE: the
# bridge does NOT attach this field at fit time yet (the recompute fallback is the
# live path); this mock exercises the forward-looking auto-detect branch so it
# cannot silently break when the bridge wires the payload. The payload correlation
# (0.55) differs from the `genetic_correlation` field (0.3) to prove consumption.
mock_mv_fit_plotdata <- function() {
  structure(
    list(
      result = list(
        genetic_correlation = matrix(
          c(1, 0.3, 0.3, 1),
          2,
          2,
          dimnames = list(c("t1", "t2"), c("t1", "t2"))
        ),
        genetic_correlation_plot_data = list(
          traits = c("t1", "t2"),
          genetic_correlations = matrix(c(1, 0.55, 0.55, 1), 2, 2),
          heritabilities = c(0.05, 0.4),
          rotation_invariant = TRUE
        )
      )
    ),
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

test_that("g_matrix flags off-diagonal cells involving a low-h2 trait", {
  p <- autoplot(mock_mv_fit_h2(c(t1 = 0.05, t2 = 0.4)), "g_matrix")
  expect_s3_class(p, "ggplot")
  off <- p$data[as.character(p$data$row) != as.character(p$data$col), ]
  dia <- p$data[as.character(p$data$row) == as.character(p$data$col), ]
  # t1 h2 = 0.05 < 0.1 -> every off-diagonal cell is imprecise; diagonal is not.
  expect_true(all(off$low))
  expect_false(any(dia$low))
  expect_true(grepl("imprecise", p$labels$subtitle))
})

test_that("g_matrix renders the flag as a glyph, not a literal escape", {
  p <- autoplot(mock_mv_fit_h2(c(t1 = 0.05, t2 = 0.4)), "g_matrix")
  dagger <- intToUtf8(0x2020)
  # the dagger glyph is present on flagged labels and in the subtitle ...
  expect_true(any(grepl(dagger, p$data$label, fixed = TRUE)))
  expect_true(grepl(dagger, p$labels$subtitle, fixed = TRUE))
  # ... and the literal escape text never leaks (guards the backslash-escape bug).
  expect_false(any(grepl("u2020", p$data$label)))
  expect_false(grepl("u2020", p$labels$subtitle))
  expect_false(grepl("u00b2", p$labels$subtitle))
})

test_that("g_matrix does not flag when all traits clear low_h2", {
  p <- autoplot(mock_mv_fit_h2(c(t1 = 0.5, t2 = 0.6)), "g_matrix")
  expect_false(any(p$data$low))
  expect_false(grepl("imprecise", p$labels$subtitle))
})

test_that("g_matrix low_h2 threshold is configurable", {
  fit <- mock_mv_fit_h2(c(t1 = 0.2, t2 = 0.6))
  # the default 0.1 does not flag (0.2 >= 0.1) ...
  expect_false(any(autoplot(fit, "g_matrix")$data$low))
  # ... but a higher threshold does, and the threshold shows in the subtitle.
  p <- autoplot(fit, "g_matrix", low_h2 = 0.3)
  off <- p$data[as.character(p$data$row) != as.character(p$data$col), ]
  expect_true(all(off$low))
  expect_true(grepl("0.3", p$labels$subtitle, fixed = TRUE))
})

test_that("g_matrix handles a single NA heritability without false flags", {
  # t1 NA, t2 clears -> the off-diagonal involves no finite low-h2 trait: no flag.
  p_na <- autoplot(mock_mv_fit_h2(c(t1 = NA, t2 = 0.4)), "g_matrix")
  expect_false(any(p_na$data$low))
  # t1 low, t2 NA -> the off-diagonal involves t1 (finite, low): flagged.
  p_low <- autoplot(mock_mv_fit_h2(c(t1 = 0.05, t2 = NA)), "g_matrix")
  off <- p_low$data[
    as.character(p_low$data$row) != as.character(p_low$data$col),
  ]
  expect_true(all(off$low))
})

test_that("g_matrix degrades gracefully without heritabilities (no flag)", {
  p <- autoplot(mock_mv_fit(), "g_matrix")
  expect_s3_class(p, "ggplot")
  expect_false(any(p$data$low))
  # recompute path uses the genetic_correlation field value (0.3).
  off <- p$data[as.character(p$data$row) != as.character(p$data$col), ]
  expect_true(all(abs(off$value - 0.3) < 1e-9))
})

test_that("g_matrix consumes the engine genetic_correlation_plot_data payload", {
  p <- autoplot(mock_mv_fit_plotdata(), "g_matrix")
  off <- p$data[as.character(p$data$row) != as.character(p$data$col), ]
  # payload correlation 0.55 is used, not the 0.3 in result$genetic_correlation
  expect_true(all(abs(off$value - 0.55) < 1e-9))
  # payload heritabilities (t1 = 0.05) flag the imprecise off-diagonal cells
  expect_true(all(off$low))
})

test_that("g_matrix ignores a payload that is not rotation-invariant", {
  fit <- mock_mv_fit_plotdata()
  fit$result$genetic_correlation_plot_data$rotation_invariant <- FALSE
  p <- autoplot(fit, "g_matrix")
  off <- p$data[as.character(p$data$row) != as.character(p$data$col), ]
  # falls back to the recompute path -> the 0.3 genetic_correlation, not 0.55.
  expect_true(all(abs(off$value - 0.3) < 1e-9))
})

test_that("g_matrix drops mismatched-length payload heritabilities (no flag)", {
  fit <- mock_mv_fit_plotdata()
  # 3 heritabilities for a 2-trait G -> the guard drops h2 rather than mis-flag.
  fit$result$genetic_correlation_plot_data$heritabilities <- c(0.02, 0.5, 0.5)
  p <- autoplot(fit, "g_matrix")
  expect_false(any(p$data$low))
})

test_that("g_matrix handles a payload with NULL traits (engine default labels)", {
  fit <- mock_mv_fit_plotdata()
  fit$result$genetic_correlation_plot_data$traits <- NULL
  fit$result$genetic_correlation_plot_data$genetic_correlations <-
    unname(fit$result$genetic_correlation_plot_data$genetic_correlations)
  p <- autoplot(fit, "g_matrix")
  expect_s3_class(p, "ggplot")
  # default labels match the engine preparer convention (trait_1, trait_2).
  expect_true(all(c("trait_1", "trait_2") %in% as.character(p$data$row)))
})

test_that("g_matrix payload and recompute paths agree on identical G", {
  # Julia-free consumer parity: the same correlation via the payload vs the
  # recompute path must yield identical tidy frames (value, low, label).
  corr <- matrix(c(1, 0.42, 0.42, 1), 2, 2)
  h2 <- c(t1 = 0.05, t2 = 0.4)
  fit_recompute <- mock_mv_fit_h2(h2)
  fit_recompute$result$genetic_correlation <- matrix(
    c(1, 0.42, 0.42, 1),
    2,
    2,
    dimnames = list(c("t1", "t2"), c("t1", "t2"))
  )
  fit_payload <- structure(
    list(
      result = list(
        genetic_correlation_plot_data = list(
          traits = c("t1", "t2"),
          genetic_correlations = corr,
          heritabilities = as.numeric(h2),
          rotation_invariant = TRUE
        )
      )
    ),
    class = "hsquared_fit"
  )
  d_recompute <- autoplot(fit_recompute, "g_matrix")$data
  d_payload <- autoplot(fit_payload, "g_matrix")$data
  expect_equal(d_payload$value, d_recompute$value)
  expect_equal(d_payload$low, d_recompute$low)
  expect_equal(d_payload$label, d_recompute$label)
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

test_that("autoplot figures carry the hsquared_meta honest-status attribute", {
  m_g <- attr(autoplot(mock_mv_fit(), "g_matrix"), "hsquared_meta")
  expect_equal(m_g$type, "g_matrix")
  expect_equal(m_g$rotation_status, "rotation_invariant")

  m_gw <- attr(autoplot(mock_gwas()), "hsquared_meta")
  expect_equal(m_gw$type, "manhattan")
  expect_equal(m_gw$interval_status, "uncalibrated")

  m_v <- attr(autoplot(mock_uni_fit(), "variance"), "hsquared_meta")
  expect_equal(m_v$type, "variance")
  expect_equal(m_v$interval_status, "experimental_asymptotic")
})
