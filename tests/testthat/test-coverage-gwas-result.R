# Coverage lane for R/gwas.R: the pure-R result handling around a marker scan
# (marker labels, result normalisation, genome-wide column, printing). No Julia:
# the raw scan is built here from closed-form Wald quantities, so the checks
# are identities between the columns rather than echoes of fixed numbers.

hs_cov_scan_raw <- function(with_genome_wide = FALSE) {
  effects <- c(0.50, -0.20, 0.05)
  se <- c(0.10, 0.20, 0.10)
  z <- effects / se
  chisq <- z^2
  p <- 2 * stats::pnorm(-abs(z))
  raw <- list(
    marker_ids = c("m1", "m2", "m3"),
    effects = effects,
    standard_errors = se,
    z_scores = z,
    chisq = chisq,
    p_values = p,
    bonferroni = stats::p.adjust(p, "bonferroni"),
    bh = stats::p.adjust(p, "BH"),
    lod = chisq / (2 * log(10))
  )
  if (with_genome_wide) {
    raw$genome_wide_p_values <- c(1 / 1001, 0.4, 0.9)
    raw$calibration <- list(
      calibration_method = "permutation_addone",
      threshold_scale = "lod",
      threshold = 3.2,
      alpha = 0.05,
      empirical_type1 = NA_real_,
      marker_panel_mode = "real_panel",
      scan_method = "single",
      n_replicates = 1000L,
      seed = 7L,
      engine = "HSquared.genome_wide_marker_scan",
      package_version = "0.9.0",
      validation_reference = "external type-I-control gate"
    )
  }
  raw
}

test_that("hs_gwas_marker_ids prefers supplied ids, then column names, then positions", {
  markers <- matrix(0, 2, 3, dimnames = list(NULL, c("a", "b", "c")))
  expect_identical(
    hsquared:::hs_gwas_marker_ids(c("x", "y", "z"), markers),
    c("x", "y", "z")
  )
  expect_identical(
    hsquared:::hs_gwas_marker_ids(c(10, 20, 30), markers),
    c("10", "20", "30")
  )
  expect_identical(hsquared:::hs_gwas_marker_ids(NULL, markers), c("a", "b", "c"))
  expect_identical(
    hsquared:::hs_gwas_marker_ids(NULL, matrix(0, 2, 3)),
    c("1", "2", "3")
  )
  expect_error(
    hsquared:::hs_gwas_marker_ids(c("x", "y"), markers),
    "`marker_ids` must have one entry per marker column (3).",
    fixed = TRUE
  )
})

test_that("hs_scalar_character and hs_scalar_numeric return NA for anything but length one", {
  expect_identical(hsquared:::hs_scalar_character(c("a", "b")), NA_character_)
  expect_identical(hsquared:::hs_scalar_character(character()), NA_character_)
  expect_identical(hsquared:::hs_scalar_character(3), "3")
  expect_identical(hsquared:::hs_scalar_numeric(c(1, 2)), NA_real_)
  expect_identical(hsquared:::hs_scalar_numeric(NULL), NA_real_)
  expect_identical(hsquared:::hs_scalar_numeric("2.5"), 2.5)
})

test_that("a vector-valued calibration threshold is refused as non-finite", {
  calibration <- hs_cov_scan_raw(TRUE)$calibration
  calibration$threshold <- c(3, 4)
  expect_error(
    hsquared:::hs_validate_gwas_calibration_metadata(calibration, "single"),
    "GWAS calibration `threshold` must be positive and finite.",
    fixed = TRUE
  )
  calibration <- hs_cov_scan_raw(TRUE)$calibration
  calibration$n_replicates <- c(10, 20)
  expect_error(
    hsquared:::hs_validate_gwas_calibration_metadata(calibration, "single"),
    "`n_replicates` must be a positive whole number.",
    fixed = TRUE
  )
})

test_that("a normalised scan keeps the Wald identities and has no genome-wide column by default", {
  out <- hsquared:::hs_normalize_gwas_result(hs_cov_scan_raw(), method = "mixed")
  expect_s3_class(out, "hs_gwas")
  expect_s3_class(out, "data.frame")
  expect_identical(attr(out, "scan_method"), "mixed")
  expect_null(attr(out, "calibration"))
  expect_false("genome_wide_p" %in% names(out))
  expect_identical(
    names(out),
    c("marker", "effect", "se", "z", "chisq", "p_value", "bonferroni_p", "bh_qvalue", "lod")
  )
  expect_equal(out$z, out$effect / out$se)
  expect_equal(out$chisq, out$z^2)
  expect_equal(out$p_value, 2 * stats::pnorm(-abs(out$z)))
  expect_equal(out$p_value, stats::pchisq(out$chisq, df = 1, lower.tail = FALSE))
  expect_equal(out$lod, out$chisq / (2 * log(10)))
  expect_equal(out$bonferroni_p, pmin(1, 3 * out$p_value))
  expect_true(all(out$bh_qvalue >= out$p_value - 1e-12))
})

test_that("a genome-wide scan adds the permutation p column and carries validated calibration metadata", {
  out <- hsquared:::hs_normalize_gwas_result(hs_cov_scan_raw(TRUE), method = "single")
  expect_identical(out$genome_wide_p, c(1 / 1001, 0.4, 0.9))
  expect_true(all(out$genome_wide_p >= 1 / 1001))
  cal <- attr(out, "calibration")
  expect_identical(cal$calibration_method, "permutation_addone")
  expect_identical(cal$scan_method, "single")
  expect_identical(cal$n_replicates, 1000L)
  expect_identical(cal$alpha, 0.05)
  expect_true(is.na(cal$empirical_type1))

  mismatched <- hs_cov_scan_raw(TRUE)
  expect_error(
    hsquared:::hs_normalize_gwas_result(mismatched, method = "mixed"),
    "GWAS calibration `scan_method` must match the scan result method (`mixed`).",
    fixed = TRUE
  )
})

test_that("printing a genome-wide single scan states what is and is not calibrated", {
  out <- hsquared:::hs_normalize_gwas_result(hs_cov_scan_raw(TRUE), method = "single")
  text <- paste(utils::capture.output(print(out)), collapse = "\n")
  expect_match(text, "dense single-marker (OLS) scan -- relatedness-UNcorrected", fixed = TRUE)
  expect_match(text, "The `genome_wide_p` column IS genome-wide calibrated", fixed = TRUE)
  expect_match(text, "permutation_addone, type-I-control validated", fixed = TRUE)
  expect_match(text, "Significant when genome_wide_p <= 0.05.", fixed = TRUE)
  expect_match(text, "columns remain NOT", fixed = TRUE)
  expect_match(text, "m1", fixed = TRUE)
  expect_false(grepl("Pass `genome_wide = TRUE`", text, fixed = TRUE))

  nominal <- hsquared:::hs_normalize_gwas_result(hs_cov_scan_raw(), method = "single")
  nominal_text <- paste(utils::capture.output(print(nominal)), collapse = "\n")
  expect_match(nominal_text, "Pass `genome_wide = TRUE`", fixed = TRUE)
  expect_false(grepl("IS genome-wide calibrated", nominal_text, fixed = TRUE))
})

test_that("print() returns its input invisibly and honours head()'s n", {
  out <- hsquared:::hs_normalize_gwas_result(hs_cov_scan_raw(), method = "mixed")
  utils::capture.output(res <- print(out, n = 2L))
  expect_identical(res, out)
  lines <- utils::capture.output(print(out, n = 2L))
  expect_match(paste(lines, collapse = "\n"), "m2", fixed = TRUE)
  expect_false(grepl("m3", paste(lines, collapse = "\n"), fixed = TRUE))
})
