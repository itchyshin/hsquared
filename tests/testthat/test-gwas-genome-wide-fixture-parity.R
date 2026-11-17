# Cross-engine parity (parity map cell 33): gwas(genome_wide = TRUE) against the
# HSquared.jl `genome_wide_scan_parity` fixture (fixtures/genome_wide_scan_parity/,
# copied from HSquared.jl test/fixtures at engine commit
# b6830323858e9297edaff55dacc5e05651908020).
#
# The effect / se / chisq / p columns are deterministic (no RNG) and are pinned
# at 1e-10. genome_wide_p and the threshold come from the
# MersenneTwister(20264200) permutation null; per the fixture README they are
# the Julia-1.10 reference values and are exact only within a Julia minor
# version, so that leg is skipped (not loosened) on any other Julia.

hs_gw_fx <- function(file) {
  utils::read.csv(
    testthat::test_path("fixtures", "genome_wide_scan_parity", file),
    stringsAsFactors = FALSE
  )
}

test_that("gwas(genome_wide = TRUE) reproduces the HSquared.jl genome_wide_scan_parity fixture [live]", {
  hs_skip_live_julia()
  testthat::skip_if_not(
    hsquared:::hs_julia_bridge_available(),
    "JuliaCall, Julia, and local HSquared.jl are required for the live fixture parity."
  )

  ph <- hs_gw_fx("phenotypes.csv")
  mk <- hs_gw_fx("markers.csv")
  expected <- hs_gw_fx("expected_genome_wide_scan_payload.csv")
  meta <- hs_gw_fx("expected_metadata.csv")
  meta <- stats::setNames(meta$value, meta$field)
  n <- nrow(ph)

  # Intercept-only design, identity Z, residual variance 1 (the fixture's
  # sigma_e2 = 1.0). gwas() reads only y, X, Z and the variance components.
  fit <- hsquared:::hs_new_fit(
    spec = list(
      method = "REML",
      family = list(family = "gaussian", link = "identity"),
      target = "ai_reml"
    ),
    payload = list(
      y = ph$y,
      X = matrix(1, n, 1),
      Z = methods::as(diag(n), "CsparseMatrix"),
      pedigree = list(
        id = ph$id,
        sire = rep(NA_character_, n),
        dam = rep(NA_character_, n)
      )
    ),
    result = list(
      variance_components = data.frame(
        component = c("animal", "residual"),
        estimate = c(1, 1),
        stringsAsFactors = FALSE
      )
    )
  )
  M <- as.matrix(mk[, setdiff(names(mk), "id")])
  rownames(M) <- mk$id

  g <- gwas(
    fit,
    M,
    marker_ids = colnames(M),
    method = "single",
    genome_wide = TRUE,
    n_permutations = as.integer(meta[["n_permutations"]]),
    seed = as.integer(meta[["seed"]])
  )

  expect_identical(g$marker, expected$marker_id)
  expect_equal(g$effect, expected$effect, tolerance = 1e-10)
  expect_equal(g$se, expected$standard_error, tolerance = 1e-10)
  expect_equal(g$chisq, expected$chisq, tolerance = 1e-10)
  expect_equal(g$p_value, expected$p_value, tolerance = 1e-10)
  expect_identical(g$marker[which.max(g$chisq)], meta[["top_marker"]])

  jl_minor <- JuliaCall::julia_eval(
    "string(VERSION.major, \".\", VERSION.minor)"
  )
  testthat::skip_if_not(
    identical(jl_minor, "1.10"),
    "genome_wide_p reference values are Julia-1.10 permutation-stream values."
  )
  expect_equal(g$genome_wide_p, expected$genome_wide_p_value, tolerance = 1e-10)
})
