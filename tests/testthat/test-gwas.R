# Post-fit relatedness-corrected marker scan, gwas(fit, markers). The result
# assembly + guards are checked without an engine; a skip-guarded live test
# fits a tiny animal model, runs the scan, and verifies it matches the engine's
# mixed_model_marker_scan element-wise (and differs from a fixed-effect scan, so
# the relationship correction genuinely enters). The p-values are NOT
# genome-wide calibrated (engine gate HSquared.jl#48).

hs_mock_gwas_fit <- function(
  n = 4,
  family = "gaussian",
  components = c("animal", "residual")
) {
  hsquared:::hs_new_fit(
    spec = list(
      method = "REML",
      family = list(family = family, link = "identity"),
      target = "ai_reml"
    ),
    payload = list(
      y = as.numeric(seq_len(n)),
      X = matrix(1, n, 1),
      Z = methods::as(diag(n), "CsparseMatrix"),
      pedigree = list(
        id = letters[seq_len(n)],
        sire = rep(NA_character_, n),
        dam = rep(NA_character_, n)
      )
    ),
    result = list(
      variance_components = data.frame(
        component = components,
        estimate = rep(1, length(components)),
        stringsAsFactors = FALSE
      )
    )
  )
}

test_that("the gwas normalizer assembles the marker-scan table with the caveat", {
  raw <- list(
    marker_ids = c("m1", "m2"),
    effects = c(0.3, -0.1),
    standard_errors = c(0.1, 0.2),
    z_scores = c(3, -0.5),
    chisq = c(9, 0.25),
    p_values = c(0.0027, 0.617),
    bonferroni = c(0.0054, 1),
    bh = c(0.0054, 0.617),
    lod = c(9, 0.25) / (2 * log(10))
  )
  g <- hsquared:::hs_normalize_gwas_result(raw)

  expect_s3_class(g, "hs_gwas")
  expect_equal(
    names(g),
    c(
      "marker",
      "effect",
      "se",
      "z",
      "chisq",
      "p_value",
      "bonferroni_p",
      "bh_qvalue",
      "lod"
    )
  )
  expect_equal(g$marker, c("m1", "m2"))
  expect_equal(g$lod, g$chisq / (2 * log(10)))
  expect_output(print(g), "NOT genome-wide calibrated")
})

test_that("gwas() guards the fit type and the markers shape (no engine needed)", {
  expect_error(gwas(list(), matrix(0, 4, 2)), "Gaussian animal model")

  ng <- hs_mock_gwas_fit(family = "binomial")
  expect_error(gwas(ng, matrix(0, 4, 2)), "Gaussian")

  no_vc <- hs_mock_gwas_fit(components = "residual")
  expect_error(gwas(no_vc, matrix(0, 4, 2)), "variance components")

  fit <- hs_mock_gwas_fit(n = 4)
  expect_error(gwas(fit, matrix(0, 3, 2)), "one row per animal")
  expect_error(
    gwas(fit, matrix(0, 4, 2), marker_ids = "only_one"),
    "one entry per marker"
  )
  expect_error(gwas(fit, matrix(NA_real_, 4, 2)), "finite")
})

test_that("gwas() runs a live relatedness-corrected scan matching the engine", {
  testthat::skip_on_cran()
  testthat::skip_if_not(
    hsquared:::hs_julia_bridge_available(),
    "JuliaCall, Julia, and local HSquared.jl are required for the live gwas scan."
  )

  set.seed(11)
  ped <- data.frame(
    id = c("s1", "s2", "d1", "d2", paste0("a", 1:16)),
    sire = c(NA, NA, NA, NA, rep(c("s1", "s2"), 8)),
    dam = c(NA, NA, NA, NA, rep(c("d1", "d2"), 8))
  )
  n <- nrow(ped)
  # Pedigree-structured breeding values so the additive variance is identifiable
  # and the AI-REML fit stays off the zero boundary.
  bv <- stats::setNames(numeric(n), ped$id)
  for (i in seq_len(n)) {
    s <- ped$sire[i]
    d <- ped$dam[i]
    bv[i] <- if (is.na(s)) {
      stats::rnorm(1)
    } else {
      0.5 * (bv[[s]] + bv[[d]]) + stats::rnorm(1, sd = sqrt(0.5))
    }
  }
  x <- stats::rnorm(n)
  dat <- data.frame(
    y = 1 + 0.5 * x + bv + stats::rnorm(n),
    id = ped$id,
    x = x
  )
  fit <- hsquared(
    y ~ x + animal(1 | id, pedigree = ped),
    data = dat,
    family = stats::gaussian(),
    REML = TRUE
  )

  M <- matrix(sample(0:2, n * 4L, replace = TRUE), n, 4L)
  g <- gwas(fit, M, marker_ids = paste0("m", 1:4))

  expect_s3_class(g, "hs_gwas")
  expect_equal(nrow(g), 4L)
  expect_equal(g$marker, paste0("m", 1:4))
  expect_true(all(g$p_value >= 0 & g$p_value <= 1))
  expect_true(all(is.finite(g$effect)))
  expect_equal(g$lod, g$chisq / (2 * log(10)), tolerance = 1e-10)

  # The gwas() bridge left hsq_y/X/Z/Ainv/markers/sigma assigned; recompute the
  # engine scan directly and assert element-wise parity.
  direct_p <- JuliaCall::julia_eval(
    "HSquared.mixed_model_marker_scan(hsq_y, hsq_X, hsq_Z, hsq_Ainv, hsq_markers, hsq_sigma_a2, hsq_sigma_e2).p_values"
  )
  expect_equal(g$p_value, direct_p, tolerance = 1e-10)
  direct_eff <- JuliaCall::julia_eval(
    "HSquared.mixed_model_marker_scan(hsq_y, hsq_X, hsq_Z, hsq_Ainv, hsq_markers, hsq_sigma_a2, hsq_sigma_e2).effects"
  )
  expect_equal(g$effect, direct_eff, tolerance = 1e-10)

  # The relatedness-corrected scan differs from a fixed-effect scan: Z/Ainv
  # genuinely enter (not a fixed-effect screen mislabelled).
  fixed_p <- JuliaCall::julia_eval(
    "HSquared.single_marker_scan(hsq_y, hsq_X, hsq_markers; sigma_e2 = hsq_sigma_e2).p_values"
  )
  expect_false(isTRUE(all.equal(g$p_value, fixed_p)))
})
