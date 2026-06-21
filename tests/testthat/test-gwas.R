# Post-fit relatedness-corrected marker scan, gwas(fit, markers). The result
# assembly + guards are checked without an engine; a skip-guarded live test
# fits a tiny animal model, runs the scan, and verifies it matches the engine's
# mixed_model_marker_scan element-wise (and differs from a fixed-effect scan, so
# the relationship correction genuinely enters). The p-values are NOT
# genome-wide calibrated; Julia's fixed-panel smoke does not activate an R
# threshold.

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
  expect_equal(attr(g, "scan_method"), "mixed")

  # the single-marker variant carries its method + a relatedness-uncorrected print
  g1 <- hsquared:::hs_normalize_gwas_result(raw, method = "single")
  expect_equal(attr(g1, "scan_method"), "single")
  expect_output(print(g1), "relatedness-UNcorrected")

  # the LOCO variant carries its method + a scale-mismatch / LOCO print
  gl <- hsquared:::hs_normalize_gwas_result(raw, method = "loco")
  expect_equal(attr(gl, "scan_method"), "loco")
  expect_output(print(gl), "leave-one-group-out")
  expect_output(print(gl), "scale mismatch")
})

test_that("GWAS calibration metadata is absent unless a complete payload exists", {
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
  expect_null(attr(g, "calibration"))
})

test_that("GWAS calibration metadata validator rejects incomplete or inconsistent payloads", {
  calibration <- list(
    calibration_method = "permutation",
    threshold_scale = "p_value",
    threshold = 0.01,
    alpha = 0.05,
    empirical_type1 = 0.048,
    marker_panel_mode = "realistic_ld",
    scan_method = "mixed",
    n_replicates = 1000,
    seed = c(1L, 2L, 3L),
    engine = "HSquared.mixed_model_marker_scan",
    package_version = "0.1.0"
  )

  validated <- hsquared:::hs_validate_gwas_calibration_metadata(calibration)
  expect_equal(validated$calibration_method, "permutation")
  expect_equal(validated$threshold, 0.01)
  expect_equal(validated$n_replicates, 1000L)

  missing_field <- calibration
  missing_field$threshold <- NULL
  expect_error(
    hsquared:::hs_validate_gwas_calibration_metadata(missing_field),
    "missing field.*threshold"
  )

  none_method <- calibration
  none_method$calibration_method <- "none"
  expect_error(
    hsquared:::hs_validate_gwas_calibration_metadata(none_method),
    "other than `none`"
  )

  bad_p <- calibration
  bad_p$threshold <- 2
  expect_error(
    hsquared:::hs_validate_gwas_calibration_metadata(bad_p),
    "between 0 and 1"
  )

  bad_method <- calibration
  bad_method$scan_method <- "loco"
  expect_error(
    hsquared:::hs_validate_gwas_calibration_metadata(bad_method),
    "must match"
  )

  bad_reps <- calibration
  bad_reps$n_replicates <- 10.5
  expect_error(
    hsquared:::hs_validate_gwas_calibration_metadata(bad_reps),
    "positive whole number"
  )
})

test_that("the gwas normalizer preserves validated future calibration metadata", {
  raw <- list(
    marker_ids = "m1",
    effects = 0.3,
    standard_errors = 0.1,
    z_scores = 3,
    chisq = 9,
    p_values = 0.0027,
    bonferroni = 0.0027,
    bh = 0.0027,
    lod = 9 / (2 * log(10)),
    calibration = list(
      calibration_method = "fixed_panel_simulation",
      threshold_scale = "lod",
      threshold = 3.2,
      alpha = 0.05,
      empirical_type1 = 0.048,
      marker_panel_mode = "fixed",
      scan_method = "mixed",
      n_replicates = 200,
      seed = 20260621L,
      engine = "HSquared.mixed_model_marker_scan",
      package_version = "0.1.0"
    )
  )

  g <- hsquared:::hs_normalize_gwas_result(raw)
  calibration <- attr(g, "calibration")
  expect_type(calibration, "list")
  expect_equal(calibration$threshold_scale, "lod")
  expect_equal(calibration$marker_panel_mode, "fixed")
  expect_equal(calibration$scan_method, attr(g, "scan_method"))
})

test_that("hs_gwas_marker_groups guards the LOCO group map (no engine needed)", {
  M <- matrix(0, 4, 4)

  # non-LOCO methods reject a supplied group map outright (both mixed and single)
  expect_null(hsquared:::hs_gwas_marker_groups(NULL, M, "mixed"))
  expect_null(hsquared:::hs_gwas_marker_groups(NULL, M, "single"))
  expect_error(
    hsquared:::hs_gwas_marker_groups(c("a", "a", "b", "b"), M, "mixed"),
    "only used when"
  )
  expect_error(
    hsquared:::hs_gwas_marker_groups(c("a", "a", "b", "b"), M, "single"),
    "only used when"
  )

  # LOCO requires the map, the right length, no NA/empty, >= 2 distinct groups
  expect_error(hsquared:::hs_gwas_marker_groups(NULL, M, "loco"), "requires")
  expect_error(
    hsquared:::hs_gwas_marker_groups(c("a", "b"), M, "loco"),
    "one entry per marker"
  )
  expect_error(
    hsquared:::hs_gwas_marker_groups(c("a", "a", NA, "b"), M, "loco"),
    "missing"
  )
  expect_error(
    hsquared:::hs_gwas_marker_groups(c("a", "a", "", "b"), M, "loco"),
    "empty"
  )
  expect_error(
    hsquared:::hs_gwas_marker_groups(rep("chr1", 4), M, "loco"),
    "at least two distinct"
  )
  # the success path coerces non-character labels (a chromosome integer/factor
  # column is what real callers pass) via as.character
  expect_identical(
    hsquared:::hs_gwas_marker_groups(c(1L, 1L, 2L, 2L), M, "loco"),
    c("1", "1", "2", "2")
  )
  expect_identical(
    hsquared:::hs_gwas_marker_groups(factor(c("a", "a", "b", "b")), M, "loco"),
    c("a", "a", "b", "b")
  )
})

test_that("gwas() routes method='loco' through the group guard before the bridge", {
  # engine-free: the guard fires before any Julia call, so a mock fit suffices
  fit <- hs_mock_gwas_fit(n = 4)
  expect_error(
    gwas(fit, matrix(0, 4, 2), method = "loco"),
    "requires"
  )
  expect_error(
    gwas(fit, matrix(0, 4, 2), marker_groups = c("a", "b")),
    "only used when"
  )
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

  # method = "single" surfaces exactly that relatedness-UNcorrected scan.
  g_single <- gwas(fit, M, marker_ids = paste0("m", 1:4), method = "single")
  expect_s3_class(g_single, "hs_gwas")
  expect_equal(attr(g_single, "scan_method"), "single")
  expect_equal(g_single$p_value, fixed_p, tolerance = 1e-10)
  # ... and it differs from the relatedness-corrected mixed scan.
  expect_false(isTRUE(all.equal(g_single$p_value, g$p_value)))

  # method = "loco": per-group genomic relationship correction. Two chromosomes.
  grp <- c("chr1", "chr1", "chr2", "chr2")
  g_loco <- gwas(
    fit,
    M,
    marker_ids = paste0("m", 1:4),
    method = "loco",
    marker_groups = grp
  )
  expect_s3_class(g_loco, "hs_gwas")
  expect_equal(attr(g_loco, "scan_method"), "loco")
  expect_equal(nrow(g_loco), 4L)
  expect_true(all(g_loco$p_value >= 0 & g_loco$p_value <= 1))

  # The loco branch left hsq_prec / hsq_groups / hsq_markers(record-level)
  # assigned; recompute the engine LOCO scan directly and assert parity.
  loco_p <- JuliaCall::julia_eval(
    "HSquared.loco_mixed_model_marker_scan(hsq_y, hsq_X, hsq_Z, hsq_prec, hsq_groups, hsq_markers, hsq_sigma_a2, hsq_sigma_e2).p_values"
  )
  expect_equal(g_loco$p_value, loco_p, tolerance = 1e-10)

  # A chr1 marker matches a single mixed scan that uses the chr1 precision
  # (the leave-out genuinely selects the per-group relationship).
  chr1_p <- JuliaCall::julia_eval(
    "HSquared.mixed_model_marker_scan(hsq_y, hsq_X, hsq_Z, hsq_prec[\"chr1\"], hsq_markers, hsq_sigma_a2, hsq_sigma_e2).p_values"
  )
  expect_equal(g_loco$p_value[1:2], chr1_p[1:2], tolerance = 1e-10)
  # ... and the chr2 markers differ from the chr1-precision scan.
  expect_false(isTRUE(all.equal(g_loco$p_value[3:4], chr1_p[3:4])))
  # the symmetric positive check: chr2 markers match the chr2-precision scan.
  chr2_p <- JuliaCall::julia_eval(
    "HSquared.mixed_model_marker_scan(hsq_y, hsq_X, hsq_Z, hsq_prec[\"chr2\"], hsq_markers, hsq_sigma_a2, hsq_sigma_e2).p_values"
  )
  expect_equal(g_loco$p_value[3:4], chr2_p[3:4], tolerance = 1e-10)

  # LOCO differs from the whole-pedigree mixed scan and the naive single scan.
  expect_false(isTRUE(all.equal(g_loco$p_value, g$p_value)))
  expect_false(isTRUE(all.equal(g_loco$p_value, g_single$p_value)))
})

test_that("loco gwas() uses ANIMAL-level precisions under a non-square Z", {
  # The dimensional crux (doc 26 §2): the LOCO precision enters the Ainv slot, so
  # it must be (n_animals x n_animals) -- built from ANIMAL-level markers -- while
  # the scan tests RECORD-level markers (Z %*% markers). With one record per
  # animal (Z square) the two are identical and a markers/markers_rec swap would
  # pass undetected. A repeated-records fit makes Z NON-square, so the engine's
  # size(Z,2) == size(precision,1) guard fires on the wrong wiring.
  testthat::skip_on_cran()
  testthat::skip_if_not(
    hsquared:::hs_julia_bridge_available(),
    "JuliaCall, Julia, and local HSquared.jl are required for the live gwas scan."
  )

  ped <- hs_sim_pedigree(n_founder = 20, n_per_gen = 30, n_gen = 2, seed = 7)
  n_animals <- nrow(ped)
  # animal-level breeding values by gene-drop (keeps sigma_a2 off the boundary)
  set.seed(7)
  u <- stats::setNames(numeric(n_animals), ped$id)
  for (i in seq_len(n_animals)) {
    s <- ped$sire[i]
    d <- ped$dam[i]
    u[i] <- if (is.na(s)) {
      stats::rnorm(1)
    } else {
      0.5 * (u[[s]] + u[[d]]) + stats::rnorm(1, sd = sqrt(0.5))
    }
  }
  # the youngest generation is measured twice -> more records than animals
  young <- utils::tail(ped$id, 30)
  obs <- c(ped$id, young)
  set.seed(99)
  dat <- data.frame(
    y = as.numeric(u[obs]) + stats::rnorm(length(obs)),
    id = obs
  )

  fit <- hsquared(
    y ~ animal(1 | id, pedigree = ped),
    data = dat,
    family = stats::gaussian(),
    REML = TRUE
  )
  # the design is genuinely non-square (records > animals) with interior sigma_a2
  expect_gt(nrow(fit$payload$Z), ncol(fit$payload$Z))
  vc <- fit$result$variance_components
  expect_gt(vc$estimate[vc$component == "animal"], 1e-4)

  set.seed(3)
  M <- matrix(sample(0:2, n_animals * 4L, replace = TRUE), n_animals, 4L)
  grp <- c("chr1", "chr1", "chr2", "chr2")

  # If the wrapper fed record-level markers to loco_relationship_precisions, the
  # precision would be (n_records x n_records) and the engine size guard would
  # throw -> gwas() would error. Reaching the assertions proves animal-level use.
  g_loco <- gwas(
    fit,
    M,
    marker_ids = paste0("m", 1:4),
    method = "loco",
    marker_groups = grp
  )
  expect_s3_class(g_loco, "hs_gwas")
  expect_equal(nrow(g_loco), 4L)

  # Parity against a direct engine LOCO scan built from ANIMAL-level precisions
  # (hsq_markers_animal, 80x4) + RECORD-level scan markers (hsq_markers, 110x4).
  loco_p <- JuliaCall::julia_eval(
    "HSquared.loco_mixed_model_marker_scan(hsq_y, hsq_X, hsq_Z, HSquared.loco_relationship_precisions(hsq_markers_animal, hsq_groups), hsq_groups, hsq_markers, hsq_sigma_a2, hsq_sigma_e2).p_values"
  )
  expect_equal(g_loco$p_value, loco_p, tolerance = 1e-10)

  # The wrong wiring (record-level markers -> precisions) genuinely errors under
  # the non-square Z: this is what the square-Z block could not detect.
  expect_error(
    JuliaCall::julia_eval(
      "HSquared.loco_mixed_model_marker_scan(hsq_y, hsq_X, hsq_Z, HSquared.loco_relationship_precisions(hsq_markers, hsq_groups), hsq_groups, hsq_markers, hsq_sigma_a2, hsq_sigma_e2).p_values"
    )
  )
})
