# Coverage lane for R/extractors.R: the S3 default refusals, the shape
# normalisers and the R-side random-regression and SNP-BLUP computations, run on
# hand-built fits (no Julia). Numerical branches use closed-form oracles.

hs_cov_ext_fit <- function(result = list(), spec = list(), payload = list(y = c(1, 2, 3, 4))) {
  hsquared:::hs_new_fit(
    spec = utils::modifyList(
      list(method = "REML", family = list(family = "gaussian")),
      spec
    ),
    payload = payload,
    result = utils::modifyList(
      list(
        variance_components = data.frame(
          component = c("animal", "residual"),
          estimate = c(0.6, 0.4)
        ),
        converged = TRUE
      ),
      result
    )
  )
}

test_that("every extractor refuses a non-fit object by naming itself and the missing fit", {
  not_a_fit <- list(a = 1)
  cases <- list(
    residual_covariance = "requires an `hsquared_fit` object from the multivariate model",
    R_matrix = "requires an `hsquared_fit` object from the multivariate model",
    genetic_correlation = "requires an `hsquared_fit` object from the multivariate model",
    eigen_G = "`eigen_G()` requires an `hsquared_fit` object.",
    specific_variance = "requires an `hsquared_fit` object from a future validated",
    maternal_effects = "requires an `hsquared_fit` object from the opt-in maternal",
    lod_scores = "requires an `hsquared_fit` object with marker/QTL/eQTL results.",
    fixef = "`fixef()` requires an `hsquared_fit` object.",
    ranef = "`ranef()` requires an `hsquared_fit` object.",
    rr_genetic_variance = "random-regression",
    rr_heritability = "random-regression",
    rr_eigenfunctions = "random-regression",
    direct_variance = "direct-maternal correlated model",
    partner_variance = "direct-maternal correlated model",
    direct_maternal_covariance = "direct-maternal correlated model",
    heritability_interval = "`heritability_interval()` requires an `hsquared_fit` object.",
    heritability_standard_error = "`heritability_standard_error()` requires an `hsquared_fit` object.",
    fit_diagnostics = "`fit_diagnostics()` requires an `hsquared_fit` object."
  )
  for (name in names(cases)) {
    fn <- get(name, envir = asNamespace("hsquared"))
    expect_error(fn(not_a_fit), cases[[name]], fixed = TRUE, info = name)
  }
})

test_that("R_matrix() on a fit is residual_covariance() on that fit", {
  R <- matrix(c(1.2, 0.3, 0.3, 0.9), 2)
  fit <- hs_cov_ext_fit(result = list(residual_covariance = R))
  expect_identical(R_matrix(fit), residual_covariance(fit))
  expect_identical(R_matrix(fit), R)
})

test_that("specific_variance() reserves effect = 'animal' only", {
  fit <- hs_cov_ext_fit()
  expect_error(
    specific_variance(fit, effect = "maternal"),
    "`specific_variance()` currently supports only `effect = \"animal\"`.",
    fixed = TRUE
  )
})

test_that("common_env_effects() and marker_effects() return the engine field or name the gap", {
  effects <- data.frame(group = c("a", "b"), effect = c(0.1, -0.1))
  fit <- hs_cov_ext_fit(result = list(common_env_effects = effects))
  expect_identical(common_env_effects(fit), effects)
  expect_error(
    common_env_effects(hs_cov_ext_fit()),
    "does not contain common-environment effects",
    fixed = TRUE
  )
  expect_error(
    marker_effects(hs_cov_ext_fit()),
    "does not contain marker effects",
    fixed = TRUE
  )
})

test_that("lod_scores() on a scan needs marker and lod columns", {
  scan <- data.frame(marker = c("m1", "m2"), z = c(1, 2))
  class(scan) <- c("hs_gwas", "data.frame")
  expect_error(
    lod_scores(scan),
    "`lod_scores()` requires an `hs_gwas` object with `marker` and `lod` columns.",
    fixed = TRUE
  )
})

test_that("SNP-BLUP marker variance explained is derived from effects and centred dosages", {
  markers <- matrix(
    c(0, 1, 2, 1,
      2, 1, 0, 1,
      0, 0, 2, 2),
    nrow = 4,
    dimnames = list(NULL, c("m1", "m2", "m3"))
  )
  effects <- c(0.5, -1, 0.25)
  fit <- hs_cov_ext_fit(
    spec = list(target = "snp_blup"),
    payload = list(y = 1:4, markers = markers),
    result = list(
      marker_effects = data.frame(marker = c("m1", "m2", "m3"), effect = effects)
    )
  )
  out <- marker_variance_explained(fit)
  centred_var <- apply(markers, 2, function(x) mean((x - mean(x))^2))
  contribution <- centred_var * effects^2
  expect_equal(out$centered_marker_variance, unname(centred_var))
  expect_equal(out$contribution, unname(contribution))
  expect_equal(out$proportion, unname(contribution / sum(contribution)))
  expect_equal(sum(out$proportion), 1)
  expect_identical(out$marker, c("m1", "m2", "m3"))

  with_p <- hs_cov_ext_fit(
    spec = list(target = "snp_blup"),
    payload = list(y = 1:4, markers = markers),
    result = list(
      marker_effects = data.frame(marker = c("m1", "m2", "m3"), effect = effects),
      marker_allele_frequencies = c(0.5, 0.5, 0.5)
    )
  )
  out_p <- marker_variance_explained(with_p)
  fixed_var <- apply(markers, 2, function(x) mean((x - 1)^2))
  expect_equal(out_p$centered_marker_variance, unname(fixed_var))
  expect_equal(out_p$proportion, unname(fixed_var * effects^2 / sum(fixed_var * effects^2)))
})

test_that("SNP-BLUP marker variance uses Z %*% markers when the payload carries a design", {
  markers <- matrix(c(0, 1, 2, 2, 1, 0), nrow = 3, dimnames = list(NULL, c("m1", "m2")))
  Z <- matrix(c(1, 0, 0, 1, 0, 0, 0, 0, 1), nrow = 3)[c(1, 2, 3, 1), ]
  effects <- c(1, 2)
  fit <- hs_cov_ext_fit(
    spec = list(target = "snp_blup"),
    payload = list(y = 1:4, markers = markers, Z = Z),
    result = list(marker_effects = data.frame(marker = c("m1", "m2"), effect = effects))
  )
  design <- Z %*% markers
  expected_var <- apply(design, 2, function(x) mean((x - mean(x))^2))
  expect_equal(marker_variance_explained(fit)$centered_marker_variance, unname(expected_var))
})

test_that("an engine-supplied marker_variance_explained table is returned untouched", {
  table <- data.frame(marker = "m1", proportion = 1)
  fit <- hs_cov_ext_fit(result = list(marker_variance_explained = table))
  expect_identical(marker_variance_explained(fit), table)
})

test_that("fixef() and ranef() hand back engine results and name the gap otherwise", {
  fixed <- data.frame(term = "(Intercept)", estimate = 2.5)
  fit <- hs_cov_ext_fit(result = list(fixed_effects = fixed))
  expect_identical(fixef(fit), fixed)
  expect_error(fixef(hs_cov_ext_fit()), "does not contain fixed-effect estimates", fixed = TRUE)
})

test_that("heritability_standard_error() always returns term/se and labels from the heritability frame", {
  bare <- hs_cov_ext_fit(result = list(heritability_se = 0.05))
  expect_identical(
    heritability_standard_error(bare),
    data.frame(term = "animal", se = 0.05, stringsAsFactors = FALSE)
  )

  single <- hs_cov_ext_fit(
    result = list(
      heritability_se = 0.05,
      heritability = data.frame(term = "h2_T", estimate = 0.6)
    )
  )
  expect_identical(heritability_standard_error(single)$term, "h2_T")

  several_with_animal <- hs_cov_ext_fit(
    result = list(
      heritability_se = 0.05,
      heritability = data.frame(term = c("repeatability", "animal"), estimate = c(0.7, 0.4))
    )
  )
  expect_identical(heritability_standard_error(several_with_animal)$term, "animal")

  several_without <- hs_cov_ext_fit(
    result = list(
      heritability_se = 0.05,
      heritability = data.frame(term = c("h2_T", "m2"), estimate = c(0.4, 0.1))
    )
  )
  expect_identical(heritability_standard_error(several_without)$term, "h2_T")

  framed <- hs_cov_ext_fit(
    result = list(
      heritability_se = data.frame(term = factor("animal"), se = 0.07, extra = "x")
    )
  )
  expect_identical(
    heritability_standard_error(framed),
    data.frame(term = "animal", se = 0.07, stringsAsFactors = FALSE)
  )

  malformed <- hs_cov_ext_fit(result = list(heritability_se = data.frame(se = 0.07)))
  expect_error(
    heritability_standard_error(malformed),
    "`heritability_se` on the fit must be a numeric or a data frame with columns `term` and `se`.",
    fixed = TRUE
  )
})

test_that("a genomic fit labels its ratio SE with the relationship scale and refuses at a boundary", {
  genomic <- hs_cov_ext_fit(
    spec = list(target = "genomic"),
    result = list(
      heritability_se = 0.05,
      heritability = data.frame(
        term = "genomic",
        component = "genomic",
        relationship_scale = "K_lambda",
        estimate = 0.5
      )
    )
  )
  out <- heritability_standard_error(genomic)
  expect_identical(out$term, "genomic")
  expect_identical(out$component, "genomic")
  expect_identical(out$relationship_scale, "K_lambda")

  no_h2 <- hs_cov_ext_fit(spec = list(target = "genomic"), result = list(heritability_se = 0.05))
  expect_identical(heritability_standard_error(no_h2)$se, 0.05)
  expect_identical(names(heritability_standard_error(no_h2)), c("term", "se"))

  boundary <- hs_cov_ext_fit(
    spec = list(target = "genomic"),
    result = list(
      heritability_se = 0.05,
      genomic_boundary = list(status = "boundary_upper")
    )
  )
  expect_error(
    suppressWarnings(heritability_standard_error(boundary)),
    "not available for this genomic fit: the ratio is at a variance-component boundary (boundary_upper)",
    fixed = TRUE
  )
  expect_error(
    suppressWarnings(heritability_interval(boundary)),
    "`heritability_interval()` is not available for this genomic fit",
    fixed = TRUE
  )
})

test_that("a genomic heritability interval is labelled with the relationship scale", {
  genomic <- hs_cov_ext_fit(
    spec = list(target = "genomic"),
    result = list(
      heritability_interval = data.frame(
        estimate = 0.5, lower = 0.3, upper = 0.7, level = 0.95, se = 0.05, method = "logit_delta"
      ),
      heritability = data.frame(
        term = "genomic",
        component = "genomic",
        relationship_scale = "K_lambda",
        estimate = 0.5
      )
    )
  )
  out <- heritability_interval(genomic)
  expect_identical(out$relationship_scale, "K_lambda")
  expect_identical(out$term, "genomic")
  expect_true(out$lower < out$estimate && out$estimate < out$upper)
})

test_that("the boundary classifier distinguishes zero, negative, interior and unclassifiable layouts", {
  cls <- function(est, component = c("animal", "residual"), vc = NULL) {
    fit <- hs_cov_ext_fit()
    fit$result$variance_components <- if (is.null(vc)) {
      data.frame(component = component, estimate = est)
    } else {
      vc
    }
    hsquared:::hs_fit_boundary_class(fit)
  }

  expect_identical(cls(c(0.6, 0.4)), FALSE)
  expect_identical(cls(c(1e-9, 1)), "zero")
  expect_identical(cls(c(-0.1, 1)), "negative")
  expect_identical(cls(c(-2, 1)), "negative")
  expect_null(cls(c(0.5, NA)))
  expect_null(cls(c(0.5, Inf)))
  expect_null(cls(c(0.5, 0.5), component = c("genetic", "residual")))
  expect_null(cls(c(0.5, 0.5), component = c("animal", "genomic")))
  expect_null(cls(NULL, vc = c(0.5, 0.5)))
  expect_null(cls(NULL, vc = list(estimate = 1)))
  expect_null(cls(NULL, vc = list(component = "animal")))
  expect_null(cls(c(0, 0)))

  expect_null(hsquared:::hs_fit_boundary_condition_label(NULL))
  expect_null(hsquared:::hs_fit_boundary_condition_label(FALSE))
  expect_identical(
    hsquared:::hs_fit_boundary_condition_label("zero"),
    "at/near zero (clean boundary)"
  )
  expect_identical(
    hsquared:::hs_fit_boundary_condition_label("negative"),
    "negative (inadmissible variance)"
  )
  expect_null(hsquared:::hs_fit_boundary_condition_label("something_else"))
})

test_that("fit_diagnostics() formats every value type and reports the boundary condition", {
  fit <- hs_cov_ext_fit(
    result = list(
      variance_components = data.frame(
        component = c("animal", "residual"),
        estimate = c(-0.05, 1)
      ),
      diagnostics = list(
        a_logical = c(TRUE, FALSE),
        a_number = c(0.123456789012, 2),
        a_factor = factor(c("u", "v")),
        a_list = list(1, 2),
        a_empty = character(),
        a_text = c("p", "q")
      )
    )
  )
  diag <- fit_diagnostics(fit)
  value <- function(metric) diag$value[diag$metric == metric]
  expect_identical(value("a_logical"), "TRUE, FALSE")
  expect_identical(value("a_number"), "0.12345679, 2.00000000")
  expect_identical(value("a_factor"), "u, v")
  expect_identical(value("a_list"), "<list>")
  expect_identical(value("a_text"), "p, q")
  expect_true(is.na(value("a_empty")))
  expect_identical(value("at_boundary"), "TRUE")
  expect_identical(value("at_boundary_condition"), "negative (inadmissible variance)")
  expect_identical(value("family"), "gaussian")
  expect_identical(value("nobs"), "4")

  out <- utils::capture.output(res <- print(diag))
  expect_identical(out[[1L]], "<hs_fit_diagnostics>")
  expect_identical(res, diag)
})

test_that("a non-list diagnostics block is wrapped rather than crashing the table", {
  fit <- hs_cov_ext_fit(result = list(diagnostics = "ok"))
  diag <- fit_diagnostics(fit)
  expect_identical(diag$value[diag$metric == "diagnostics"], "ok")
})

test_that("factor-analytic start diagnostics are flattened into one labelled row", {
  starts <- data.frame(
    name = c("pca", "diag"),
    valid = c(TRUE, FALSE),
    converged = c(TRUE, TRUE),
    iterations = c(12L, 7L),
    loglik = c(-10.5, -11.25),
    minimum_uniqueness = c(0.1, 0.2),
    uniqueness_floor_distance = c(0.05, 0.15),
    stringsAsFactors = FALSE
  )
  fit <- hs_cov_ext_fit(result = list(diagnostics = list(fa_start_starts = starts)))
  text <- fit_diagnostics(fit)$value[fit_diagnostics(fit)$metric == "fa_start_starts"]
  expect_identical(
    text,
    paste0(
      "pca{valid=TRUE, converged=TRUE, iterations=12, loglik=-10.5, ",
      "minimum_uniqueness=0.1, floor_distance=0.05}; ",
      "diag{valid=FALSE, converged=TRUE, iterations=7, loglik=-11.25, ",
      "minimum_uniqueness=0.2, floor_distance=0.15}"
    )
  )

  empty <- hs_cov_ext_fit(
    result = list(diagnostics = list(fa_start_starts = starts[0, ]))
  )
  empty_diag <- fit_diagnostics(empty)
  expect_true("fa_start_starts" %in% empty_diag$metric)
  expect_false(any(grepl("valid=", empty_diag$value, fixed = TRUE)))
})

test_that("confint() points a fit at the extractor that actually exists", {
  hint <- function(...) {
    tryCatch(confint(hs_cov_ext_fit(...)), error = conditionMessage)
  }
  genomic_hi <- hint(
    spec = list(target = "genomic"),
    result = list(heritability_interval = data.frame(estimate = 0.5))
  )
  expect_match(genomic_hi, "genomic variance ratio on the `K_lambda` scale", fixed = TRUE)

  genomic_none <- hint(spec = list(target = "genomic"))
  expect_match(genomic_none, "not available for genomic fits without an engine-returned ratio interval", fixed = TRUE)

  rr <- hint(spec = list(target = "random_regression"))
  expect_match(rr, "use `rr_heritability()` for the h2(t) trajectory", fixed = TRUE)

  both <- hint(
    result = list(
      heritability_interval = data.frame(estimate = 0.5),
      variance_component_se = data.frame(component = "animal", se = 0.1)
    )
  )
  expect_match(both, "Use the experimental `heritability_interval()` and `variance_component_standard_errors()`", fixed = TRUE)

  only_hi <- hint(result = list(heritability_interval = data.frame(estimate = 0.5)))
  expect_match(only_hi, "Use the experimental `heritability_interval()` extractor", fixed = TRUE)

  only_se <- hint(result = list(variance_component_se = data.frame(component = "animal", se = 0.1)))
  expect_match(only_se, "Use the experimental `variance_component_standard_errors()` extractor", fixed = TRUE)

  neither <- hint()
  expect_match(neither, "exist when the engine returned those fields", fixed = TRUE)
})

test_that("response-scale helpers refuse a multivariate fit before looking for predictions", {
  mv <- hs_cov_ext_fit(
    spec = list(target = "multivariate"),
    payload = list(Y = matrix(1:4, 2))
  )
  for (fn in c("predict", "fitted", "residuals")) {
    expect_error(
      get(fn)(mv),
      paste0("`", fn, "()` on the response scale is univariate-only in v0.1"),
      fixed = TRUE,
      info = fn
    )
  }
  by_payload <- hs_cov_ext_fit(payload = list(Y = matrix(1:4, 2)))
  expect_error(
    predict(by_payload),
    "univariate-only in v0.1",
    fixed = TRUE
  )
})

test_that("fitted() unwraps a .fitted column and otherwise returns the prediction as is", {
  with_col <- hs_cov_ext_fit(
    result = list(predictions = data.frame(id = c("a", "b"), .fitted = c(1.5, 2.5)))
  )
  expect_identical(fitted(with_col), c(1.5, 2.5))
  plain <- hs_cov_ext_fit(result = list(predictions = c(3, 4)))
  expect_identical(fitted(plain), c(3, 4))
})

test_that("covariance_structure_lrt() refuses mismatched fits before computing anything", {
  mv_fit <- function(...) {
    hs_cov_ext_fit(
      spec = list(target = "multivariate"),
      payload = list(
        Y = matrix(1:4, 2),
        X = matrix(1, 2, 1),
        pedigree = data.frame(id = c("a", "b")),
        metadata = list(trait_names = c("t1", "t2"), fixed_colnames = "(Intercept)")
      ),
      result = list(loglik = -10, n_genetic_params = 3L, nobs = 2L)
    )
  }
  base <- mv_fit()
  modify <- function(fit, path, value) {
    fit[[path[[1L]]]][[path[[2L]]]] <- value
    fit
  }
  expect_error(
    covariance_structure_lrt(base, list()),
    "must both be `hsquared_fit` objects",
    fixed = TRUE
  )
  expect_error(
    covariance_structure_lrt(modify(base, c("result", "converged"), FALSE), base),
    "must both have converged",
    fixed = TRUE
  )
  expect_error(
    covariance_structure_lrt(modify(base, c("result", "loglik"), NULL), base),
    "does not carry `loglik`",
    fixed = TRUE
  )
  expect_error(
    covariance_structure_lrt(modify(base, c("spec", "method"), "ML"), base),
    "requires two REML fits.",
    fixed = TRUE
  )
  expect_error(
    covariance_structure_lrt(modify(base, c("result", "nobs"), 3L), base),
    "must use the same number of observations.",
    fixed = TRUE
  )
  expect_error(
    covariance_structure_lrt(modify(base, c("payload", "Y"), matrix(5:8, 2)), base),
    "must use the same response data and traits.",
    fixed = TRUE
  )
  expect_error(
    covariance_structure_lrt(modify(base, c("payload", "X"), matrix(2, 2, 1)), base),
    "must use the same fixed-effect design.",
    fixed = TRUE
  )
  expect_error(
    covariance_structure_lrt(
      modify(base, c("payload", "pedigree"), data.frame(id = c("a", "z"))),
      base
    ),
    "must use the same pedigree.",
    fixed = TRUE
  )
  expect_error(
    covariance_structure_lrt(modify(base, c("spec", "family"), list(family = "poisson")), base),
    "must use the same response family.",
    fixed = TRUE
  )
})

# ---- random regression, computed in R ------------------------------------------

hs_cov_rr_fit <- function(K, lower = 1, upper = 5, order = 2L) {
  hs_cov_ext_fit(
    spec = list(target = "random_regression"),
    result = list(
      coefficient_covariance = K,
      random_regression = list(covariate = "age", lower = lower, upper = upper, order = order)
    )
  )
}

test_that("random-regression extractors refuse a non-rr fit and missing standardisation metadata", {
  plain <- hs_cov_ext_fit()
  expect_error(
    rr_covariance(plain),
    "requires a fit from the opt-in random-regression model",
    fixed = TRUE
  )
  no_meta <- hs_cov_ext_fit(
    spec = list(target = "random_regression"),
    result = list(coefficient_covariance = diag(2))
  )
  expect_error(
    rr_genetic_variance(no_meta),
    "missing its covariate standardization metadata.",
    fixed = TRUE
  )
})

test_that("a constant-only genetic covariance gives a flat variance trajectory and unit correlation", {
  fit <- hs_cov_rr_fit(matrix(c(0.8, 0, 0, 0), 2))
  grid <- seq(1, 5, length.out = 25L)
  v <- rr_genetic_variance(fit)
  expect_equal(v$covariate, grid)
  expect_equal(v$value, rep(0.8 / 2, 25L))

  corr <- rr_correlation(fit, at = c(1, 3, 5))
  expect_equal(unname(corr), matrix(1, 3, 3))
  expect_identical(dimnames(corr), list(c("1", "3", "5"), c("1", "3", "5")))
})

test_that("rr_genetic_variance equals a/2 + 3b t^2/2 for K = diag(a, b) at the standardised t", {
  fit <- hs_cov_rr_fit(diag(c(0.8, 0.3)))
  out <- rr_genetic_variance(fit, at = c(1, 3, 5))
  expect_equal(out$value, c(0.4 + 0.45, 0.4, 0.4 + 0.45))
})

test_that("rr_genetic_variance scales exactly with the covariance matrix", {
  K <- matrix(c(0.8, 0.1, 0.1, 0.3), 2)
  base <- rr_genetic_variance(hs_cov_rr_fit(K), at = c(1, 2.5, 5))$value
  doubled <- rr_genetic_variance(hs_cov_rr_fit(2 * K), at = c(1, 2.5, 5))$value
  expect_equal(doubled, 2 * base)
  expect_true(all(base >= 0))
})

test_that("rr_correlation refuses points where the genetic variance is not positive", {
  fit <- hs_cov_rr_fit(matrix(0, 2, 2))
  expect_error(
    rr_correlation(fit, at = c(1, 5)),
    "`rr_correlation()` is undefined: at least one covariate point has non-positive genetic variance.",
    fixed = TRUE
  )
})

test_that("rr evaluation points must be finite and inside the fitted covariate range", {
  fit <- hs_cov_rr_fit(diag(2))
  expect_error(rr_genetic_variance(fit, at = c(1, NA)), "`at` must be finite covariate values.", fixed = TRUE)
  expect_error(rr_genetic_variance(fit, at = numeric()), "`at` must be finite covariate values.", fixed = TRUE)
  expect_error(rr_genetic_variance(fit, at = Inf), "`at` must be finite covariate values.", fixed = TRUE)
  expect_error(
    rr_genetic_variance(fit, at = c(3, 9)),
    "`at` must lie inside the fitted covariate range [1, 5] (covariate `age`); got 9.",
    fixed = TRUE
  )
  expect_s3_class(
    tryCatch(rr_genetic_variance(fit, at = 9), error = identity),
    "hsquared_out_of_range"
  )
})

# ---- direct-maternal -----------------------------------------------------------

test_that("direct-maternal extractors need the direct-maternal fit and return its fields", {
  plain <- hs_cov_ext_fit()
  for (fn in c("direct_variance", "partner_variance")) {
    expect_error(
      get(fn)(plain),
      "direct-maternal correlated model",
      fixed = TRUE,
      info = fn
    )
  }
  dm <- hs_cov_ext_fit(
    spec = list(target = "direct_maternal"),
    result = list(direct_variance = 0.4, partner_variance = 0.2)
  )
  expect_identical(direct_variance(dm), 0.4)
  expect_identical(partner_variance(dm), 0.2)
})

test_that("planned factor-analytic extractors reserve effect = 'animal' and refuse rotation", {
  fit <- hs_cov_ext_fit()
  for (fn in c("genetic_loadings", "latent_breeding_values")) {
    expect_error(
      get(fn)(fit, effect = "maternal"),
      paste0("`", fn, "()` currently reserves only `effect = \"animal\"`; other effects are planned, not implemented."),
      fixed = TRUE,
      info = fn
    )
  }
  expect_error(
    genetic_loadings(fit, rotate = "varimax"),
    "`genetic_loadings()` rotation controls are planned, not implemented.",
    fixed = TRUE
  )
})

test_that("complex-valued diagnostics are rendered as text rather than dropped", {
  expect_identical(hsquared:::hs_diagnostic_value(1 + 2i), "1+2i")
})

test_that("the direct-maternal guard refuses a non-fit and a fit without the direct-maternal fields", {
  expect_error(
    hsquared:::hs_require_direct_maternal(list(), "direct_variance"),
    "`direct_variance()` requires an `hsquared_fit` object from the opt-in direct-maternal correlated model",
    fixed = TRUE
  )
})
