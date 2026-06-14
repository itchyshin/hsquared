test_that("snp_blup is an accepted opt-in engine target", {
  expect_identical(hsquared:::hs_validate_julia_target("snp_blup"), "snp_blup")
})

test_that("snp_blup requires a marker-matrix genomic term", {
  ped <- data.frame(
    id = c("a", "b", "c"),
    sire = c(NA, NA, "a"),
    dam = c(NA, NA, "b")
  )
  dat <- data.frame(y = c(1, 2, 3), id = c("a", "b", "c"))
  expect_error(
    hsquared(
      y ~ animal(1 | id, pedigree = ped),
      data = dat,
      family = stats::gaussian(),
      control = hs_control(
        engine = "julia",
        engine_control = list(
          target = "snp_blup",
          variance_components = c(sigma_g2 = 1, sigma_e2 = 1)
        )
      )
    ),
    "requires a `genomic(1 | id, markers = M)` term",
    fixed = TRUE
  )
})

test_that("snp_blup rejects a supplied-Ginv genomic term (needs raw markers)", {
  ids <- paste0("g", 1:3)
  Ginv <- diag(3)
  dimnames(Ginv) <- list(ids, ids)
  dat <- data.frame(y = c(1, 2, 3), id = ids)
  expect_error(
    hsquared(
      y ~ genomic(1 | id, Ginv = Ginv),
      data = dat,
      family = stats::gaussian(),
      control = hs_control(
        engine = "julia",
        engine_control = list(
          target = "snp_blup",
          variance_components = c(sigma_g2 = 1, sigma_e2 = 1)
        )
      )
    ),
    "requires a `genomic(1 | id, markers = M)` term",
    fixed = TRUE
  )
})

test_that("snp_blup requires supplied variance components", {
  ids <- paste0("g", 1:5)
  set.seed(4)
  M <- matrix(stats::rbinom(5 * 20, 2, 0.3), 5, 20)
  rownames(M) <- ids
  dat <- data.frame(y = c(1, 2, 3, 4, 5), id = ids)
  expect_error(
    hsquared(
      y ~ genomic(1 | id, markers = M),
      data = dat,
      family = stats::gaussian(),
      control = hs_control(
        engine = "julia",
        engine_control = list(target = "snp_blup")
      )
    ),
    "variance_components",
    fixed = TRUE
  )
})

test_that("snp_blup variance components must be named sigma_g2 / sigma_e2", {
  expect_error(
    hsquared:::hs_validate_snp_blup_variances(c(sigma_a2 = 1, sigma_e2 = 1)),
    "sigma_g2",
    fixed = TRUE
  )
  expect_equal(
    hsquared:::hs_validate_snp_blup_variances(c(sigma_g2 = 2, sigma_e2 = 3)),
    c(sigma_g2 = 2, sigma_e2 = 3)
  )
})

test_that("snp_blup normalizer reports descriptive marker variance shares", {
  markers <- matrix(
    c(
      0, 1, 2,
      0, 0, 2,
      1, 1, 1
    ),
    nrow = 3,
    ncol = 3
  )
  payload <- list(
    ids = paste0("g", 1:3),
    markers = markers,
    marker_names = c("m1", "m2", "m3"),
    y = c(1, 2, 3),
    metadata = list(fixed_colnames = "(Intercept)")
  )
  raw <- list(
    beta = 1,
    gebv = c(0.1, -0.2, 0.3),
    marker_effects = c(1, 2, 3),
    p = colMeans(markers) / 2,
    fitted = c(1.1, 1.8, 3.3),
    nobs = 3
  )

  result <- hsquared:::hs_normalize_julia_snp_blup_result(
    raw,
    payload,
    c(sigma_g2 = 1, sigma_e2 = 2)
  )
  mve <- result$marker_variance_explained
  centered <- sweep(markers, 2, colMeans(markers), check.margin = FALSE)
  expected_contribution <- colMeans(centered^2) * raw$marker_effects^2

  expect_equal(mve$marker, c("m1", "m2", "m3"))
  expect_equal(mve$effect, raw$marker_effects)
  expect_equal(result$marker_allele_frequencies, raw$p)
  expect_equal(mve$contribution, expected_contribution)
  expect_equal(sum(mve$proportion, na.rm = TRUE), 1)
  expect_equal(mve$contribution[3], 0)
  expect_equal(mve$proportion[3], 0)
})

test_that("hsquared fits opt-in SNP-BLUP marker effects from a marker matrix", {
  testthat::skip_on_cran()
  testthat::skip_if_not(
    hsquared:::hs_julia_bridge_available(),
    "JuliaCall, Julia, and local HSquared.jl are required for live SNP-BLUP."
  )

  set.seed(7)
  na <- 12
  ids <- paste0("g", seq_len(na))
  m <- 60
  M <- matrix(stats::rbinom(na * m, 2, 0.3), na, m)
  rownames(M) <- ids
  colnames(M) <- paste0("snp", seq_len(m))

  n <- 36
  rec <- rep(ids, length.out = n)
  dat <- data.frame(y = 5 + stats::rnorm(n, 0, 1), id = rec)

  fit <- hsquared(
    y ~ genomic(1 | id, markers = M),
    data = dat,
    family = stats::gaussian(),
    control = hs_control(
      engine = "julia",
      engine_control = list(
        target = "snp_blup",
        variance_components = c(sigma_g2 = 1.0, sigma_e2 = 2.0)
      )
    )
  )

  # Marker effects: one per marker, finite, labelled by the marker columns.
  me <- marker_effects(fit)
  expect_equal(nrow(me), m)
  expect_true(all(is.finite(me$effect)))
  expect_equal(me$marker[1], "snp1")

  # Descriptive fitted-marker shares: not scan p-values or QTL evidence.
  mve <- marker_variance_explained(fit)
  expect_equal(nrow(mve), m)
  expect_equal(mve$marker[1], "snp1")
  expect_true(all(is.finite(mve$contribution)))
  expect_true(all(mve$contribution >= 0))
  expect_equal(sum(mve$proportion, na.rm = TRUE), 1, tolerance = 1e-8)

  # Per-individual genomic breeding values: one per genotyped individual.
  bv <- breeding_values(fit)
  expect_equal(nrow(bv), na)
  expect_true(all(is.finite(bv$value)))

  # Supplied-variance solve: h2 is the supplied ratio, provenance "supplied".
  expect_equal(
    heritability(fit)$estimate,
    1.0 / (1.0 + 2.0),
    tolerance = 1e-8
  )
  expect_equal(
    fit_diagnostics(fit)$value[
      fit_diagnostics(fit)$metric == "variance_components_source"
    ],
    "supplied"
  )
})
