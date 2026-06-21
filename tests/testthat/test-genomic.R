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

test_that("genomic() accepts a marker matrix to build the relationship", {
  ids <- paste0("g", 1:5)
  set.seed(4)
  M <- matrix(stats::rbinom(5 * 20, 2, 0.3), 5, 20)
  rownames(M) <- ids
  dat <- data.frame(y = c(1, 2, 3, 4, 5), id = ids)

  spec <- hsquared:::hs_build_model_spec(
    y ~ genomic(1 | id, markers = M),
    data = dat,
    family = stats::gaussian(),
    REML = TRUE
  )

  expect_equal(spec$random$genomic$type, "genomic")
  expect_equal(spec$random$genomic$source, "markers")
  expect_equal(spec$random$genomic$ids, ids)
  expect_true(is.matrix(spec$random$genomic$markers))
  expect_null(spec$random$genomic$ginv)
  expect_match(spec$bridge$target, "genomic_relationship_inverse", fixed = TRUE)
})

test_that("marker-based genomic builds a markers bridge payload", {
  ids <- paste0("g", 1:5)
  set.seed(4)
  M <- matrix(stats::rbinom(5 * 20, 2, 0.3), 5, 20)
  rownames(M) <- ids
  dat <- data.frame(y = c(1, 2, 3, 4, 5), id = ids)

  spec <- hsquared:::hs_build_model_spec(
    y ~ genomic(1 | id, markers = M),
    data = dat,
    family = stats::gaussian(),
    REML = TRUE
  )
  payload <- hsquared:::hs_build_bridge_payload(spec)

  expect_equal(payload$relationship_source, "markers")
  expect_null(payload$Ginv)
  expect_true(is.matrix(payload$markers))
  expect_equal(dim(payload$markers), c(5L, 20L))
})

test_that("supplied-Ginv genomic still builds a supplied bridge payload", {
  ids <- paste0("g", 1:3)
  Ginv <- hs_test_ginv(ids)
  dat <- data.frame(y = c(1, 2, 3), id = ids)

  spec <- hsquared:::hs_build_model_spec(
    y ~ genomic(1 | id, Ginv = Ginv),
    data = dat,
    family = stats::gaussian(),
    REML = TRUE
  )
  payload <- hsquared:::hs_build_bridge_payload(spec)

  expect_equal(payload$relationship_source, "supplied")
  expect_null(payload$markers)
  expect_true(is.matrix(payload$Ginv))
})

test_that("genomic() takes exactly one of Ginv or markers", {
  ids <- paste0("g", 1:3)
  Ginv <- hs_test_ginv(ids)
  M <- matrix(0, 3, 5)
  rownames(M) <- ids
  dat <- data.frame(y = c(1, 2, 3), id = ids)
  expect_error(
    hsquared:::hs_build_model_spec(
      y ~ genomic(1 | id, Ginv = Ginv, markers = M),
      data = dat,
      family = stats::gaussian(),
      REML = TRUE
    ),
    "exactly one of `Ginv` or `markers`",
    fixed = TRUE
  )
})

test_that("genomic() marker ids must cover the data ids", {
  ids <- paste0("g", 1:3)
  M <- matrix(0, 3, 5)
  rownames(M) <- ids
  dat <- data.frame(y = c(1, 2), id = c("g1", "ghost"))
  expect_error(
    hsquared:::hs_build_model_spec(
      y ~ genomic(1 | id, markers = M),
      data = dat,
      family = stats::gaussian(),
      REML = TRUE
    ),
    "not in the `markers`",
    fixed = TRUE
  )
})

test_that("the genomic target fixture pins VanRaden GBLUP and SNP-BLUP routes", {
  fixture <- testthat::test_path(
    "fixtures",
    "genomic_gblup_snpblup_target"
  )
  phenotypes <- utils::read.csv(
    file.path(fixture, "phenotypes.csv"),
    stringsAsFactors = FALSE
  )
  markers_df <- utils::read.csv(
    file.path(fixture, "markers.csv"),
    check.names = FALSE,
    stringsAsFactors = FALSE
  )
  frequencies <- utils::read.csv(
    file.path(fixture, "allele_frequencies.csv"),
    stringsAsFactors = FALSE
  )
  expected_g <- utils::read.csv(
    file.path(fixture, "expected_genomic_relationship.csv"),
    check.names = FALSE,
    stringsAsFactors = FALSE
  )
  expected_ginv <- utils::read.csv(
    file.path(fixture, "expected_genomic_precision.csv"),
    check.names = FALSE,
    stringsAsFactors = FALSE
  )
  expected_beta <- utils::read.csv(
    file.path(fixture, "expected_beta.csv"),
    stringsAsFactors = FALSE
  )
  expected_gebv <- utils::read.csv(
    file.path(fixture, "expected_gebv.csv"),
    stringsAsFactors = FALSE
  )
  expected_marker_effects <- utils::read.csv(
    file.path(fixture, "expected_marker_effects.csv"),
    stringsAsFactors = FALSE
  )
  metadata <- utils::read.csv(
    file.path(fixture, "expected_metadata.csv"),
    stringsAsFactors = FALSE
  )
  meta <- stats::setNames(metadata$value, metadata$key)

  ids <- markers_df$id
  markers <- as.matrix(markers_df[, -1, drop = FALSE])
  rownames(markers) <- ids
  storage.mode(markers) <- "numeric"

  expect_equal(phenotypes$id, ids)
  expect_equal(frequencies$marker, colnames(markers))
  expect_equal(expected_marker_effects$marker, colnames(markers))
  expect_equal(expected_gebv$id, ids)
  expect_equal(as.numeric(meta[["sigma_g2"]]), 2)
  expect_equal(as.numeric(meta[["sigma_e2"]]), 1)

  centered <- sweep(markers, 2, 2 * frequencies$frequency, "-")
  vanraden_scale <- 2 * sum(frequencies$frequency * (1 - frequencies$frequency))
  G <- tcrossprod(centered) / vanraden_scale
  rownames(G) <- colnames(G) <- ids

  G_expected <- as.matrix(expected_g[, -1, drop = FALSE])
  rownames(G_expected) <- expected_g$id
  storage.mode(G_expected) <- "numeric"
  expect_equal(rownames(G_expected), ids)
  expect_equal(colnames(G_expected), ids)
  expect_equal(G, G_expected, tolerance = 1e-12)
  expect_true(all(eigen(G, symmetric = TRUE, only.values = TRUE)$values > 0))
  expect_equal(as.numeric(meta[["k"]]), vanraden_scale, tolerance = 1e-12)

  Ginv <- solve(G)
  Ginv_expected <- as.matrix(expected_ginv[, -1, drop = FALSE])
  rownames(Ginv_expected) <- expected_ginv$id
  storage.mode(Ginv_expected) <- "numeric"
  expect_equal(rownames(Ginv_expected), ids)
  expect_equal(colnames(Ginv_expected), ids)
  expect_equal(Ginv, Ginv_expected, tolerance = 1e-12)
  expect_equal(unname(G %*% Ginv), diag(length(ids)), tolerance = 1e-12)

  X <- matrix(1, nrow(phenotypes), 1)
  sigma_ratio <- as.numeric(meta[["sigma_e2"]]) / as.numeric(meta[["sigma_g2"]])
  mme <- rbind(
    cbind(crossprod(X), t(X)),
    cbind(X, diag(length(ids)) + sigma_ratio * Ginv)
  )
  solution <- solve(mme, c(crossprod(X, phenotypes$y), phenotypes$y))
  beta <- unname(solution[1])
  gblup <- stats::setNames(unname(solution[-1]), ids)

  expect_equal(beta, expected_beta$value[1], tolerance = 1e-12)
  expect_equal(unname(gblup), expected_gebv$gblup, tolerance = 1e-12)
  expect_equal(
    max(abs(expected_gebv$gblup - expected_gebv$snp_blup)),
    as.numeric(meta[["gblup_snp_blup_max_abs_gebv_diff"]]),
    tolerance = 1e-12
  )

  snp_gebv <- centered %*% expected_marker_effects$effect
  expect_equal(as.numeric(snp_gebv), expected_gebv$snp_blup, tolerance = 1e-12)

  perturbed_g <- G_expected
  perturbed_g[1, 1] <- perturbed_g[1, 1] + 0.01
  expect_gt(max(abs(G - perturbed_g)), 0.001)
  perturbed_effects <- expected_marker_effects$effect
  perturbed_effects[1] <- perturbed_effects[1] + 0.01
  expect_gt(
    max(abs(
      as.numeric(centered %*% perturbed_effects) - expected_gebv$snp_blup
    )),
    0.001
  )
})

test_that("hsquared fits the opt-in genomic model from a marker matrix", {
  testthat::skip_on_cran()
  testthat::skip_if_not(
    hsquared:::hs_julia_bridge_available(),
    "JuliaCall, Julia, and local HSquared.jl are required for live marker GREML."
  )

  set.seed(6)
  na <- 10
  ids <- paste0("g", seq_len(na))
  M <- matrix(stats::rbinom(na * 80, 2, 0.3), na, 80)
  rownames(M) <- ids

  n <- 30
  rec <- rep(ids, length.out = n)
  dat <- data.frame(y = 3 + stats::rnorm(n, 0, 1), id = rec)

  fit <- hsquared(
    y ~ genomic(1 | id, markers = M),
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
  expect_equal(nrow(breeding_values(fit)), na)
})
