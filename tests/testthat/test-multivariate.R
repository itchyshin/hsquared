test_that("multivariate cbind response builds Y payload and preserves NA cells", {
  ped <- data.frame(
    id = c("sire", "dam", "calf1", "calf2"),
    sire = c(NA, NA, "sire", "sire"),
    dam = c(NA, NA, "dam", "dam")
  )
  dat <- data.frame(
    y1 = c(1, 2, 3, 4),
    y2 = c(1.5, NA, 3.5, 4.5),
    sex = c("m", "f", "f", "m"),
    id = ped$id
  )

  spec <- hsquared:::hs_build_model_spec(
    cbind(y1, y2) ~ sex + animal(1 | id, pedigree = ped),
    data = dat,
    family = stats::gaussian(),
    REML = TRUE
  )
  payload <- hsquared:::hs_build_bridge_payload(spec)

  expect_true(spec$response$multivariate)
  expect_equal(spec$response$trait_names, c("y1", "y2"))
  expect_match(spec$bridge$target, "fit_multivariate_reml", fixed = TRUE)
  expect_null(payload$y)
  expect_equal(dim(payload$Y), c(4L, 2L))
  expect_true(is.na(payload$Y[2, 2]))
  expect_equal(payload$metadata$response_type, "multivariate")
  expect_equal(payload$metadata$trait_names, c("y1", "y2"))
  expect_s4_class(payload$Z, "dgCMatrix")
})

test_that("multivariate cbind response requires unique non-empty trait names", {
  ped <- data.frame(
    id = c("sire", "dam", "calf1", "calf2"),
    sire = c(NA, NA, "sire", "sire"),
    dam = c(NA, NA, "dam", "dam")
  )
  dat <- data.frame(
    y1 = c(1, 2, 3, 4),
    y2 = c(1.5, 2.5, 3.5, 4.5),
    id = ped$id
  )

  expect_error(
    hsquared:::hs_build_model_spec(
      cbind(y1, y1) ~ animal(1 | id, pedigree = ped),
      data = dat,
      family = stats::gaussian(),
      REML = TRUE
    ),
    "duplicate names: y1",
    fixed = TRUE
  )

  expect_error(
    hsquared:::hs_validate_multivariate_trait_names(c("y1", "")),
    "empty or missing names",
    fixed = TRUE
  )
})

test_that("multivariate parser rejects fixed-effect NA and rank-deficient X", {
  ped <- data.frame(
    id = c("a", "b", "c", "d"),
    sire = c(NA, NA, "a", "a"),
    dam = c(NA, NA, "b", "b")
  )
  dat <- data.frame(
    y1 = c(1, 2, 3, 4),
    y2 = c(1.5, 2.5, 3.5, 4.5),
    x = c(0, 1, 0, 1),
    x_dup = c(0, 1, 0, 1),
    id = ped$id
  )
  dat_na <- dat
  dat_na$x[2] <- NA

  expect_error(
    hsquared:::hs_build_model_spec(
      cbind(y1, y2) ~ x + animal(1 | id, pedigree = ped),
      data = dat_na,
      family = stats::gaussian(),
      REML = TRUE
    ),
    "Missing values in fixed-effect variables",
    fixed = TRUE
  )
  expect_error(
    hsquared:::hs_build_model_spec(
      cbind(y1, y2) ~ x + x_dup + animal(1 | id, pedigree = ped),
      data = dat,
      family = stats::gaussian(),
      REML = TRUE
    ),
    "rank deficient",
    fixed = TRUE
  )
})

test_that("multivariate target is explicitly opt-in and cbind-only", {
  ped <- data.frame(
    id = c("sire", "dam", "calf"),
    sire = c(NA, NA, "sire"),
    dam = c(NA, NA, "dam")
  )
  dat <- data.frame(
    y1 = c(1, 2, 3),
    y2 = c(1.5, 2.5, 3.5),
    id = ped$id
  )

  expect_error(
    hsquared(
      cbind(y1, y2) ~ animal(1 | id, pedigree = ped),
      data = dat
    ),
    "experimental and opt-in",
    fixed = TRUE
  )
  expect_error(
    hsquared(
      cbind(y1, y2) ~ animal(1 | id, pedigree = ped),
      data = dat,
      control = hs_control(engine = "julia")
    ),
    "requires the opt-in `target = \"multivariate\"`",
    fixed = TRUE
  )
  expect_error(
    hsquared(
      y1 ~ animal(1 | id, pedigree = ped),
      data = dat,
      control = hs_control(
        engine = "julia",
        engine_control = list(target = "multivariate")
      )
    ),
    "requires a `cbind",
    fixed = TRUE
  )
  expect_equal(
    hsquared:::hs_validate_julia_target("multivariate"),
    "multivariate"
  )
})

test_that("multivariate genetic_structure control is fenced", {
  ped <- data.frame(
    id = c("sire", "dam", "calf"),
    sire = c(NA, NA, "sire"),
    dam = c(NA, NA, "dam")
  )
  dat <- data.frame(
    y1 = c(1, 2, 3),
    y2 = c(1.5, 2.5, 3.5),
    id = ped$id
  )

  expect_equal(
    hsquared:::hs_validate_genetic_structure_control(
      hs_control(
        engine = "julia",
        engine_control = list(
          target = "multivariate",
          genetic_structure = "unstructured"
        )
      ),
      "multivariate"
    ),
    "unstructured"
  )
  expect_error(
    hsquared:::hs_validate_genetic_structure_control(
      hs_control(
        engine = "julia",
        engine_control = list(
          target = "multivariate",
          genetic_structure = c("unstructured", "diagonal")
        )
      ),
      "multivariate"
    ),
    "must be a single string",
    fixed = TRUE
  )
  expect_error(
    hsquared:::hs_validate_genetic_structure_control(
      hs_control(
        engine = "julia",
        engine_control = list(
          target = "multivariate",
          genetic_structure = "toeplitz"
        )
      ),
      "multivariate"
    ),
    "must be one of",
    fixed = TRUE
  )
  expect_error(
    hsquared:::hs_validate_genetic_structure_control(
      hs_control(
        engine = "julia",
        engine_control = list(
          target = "ai_reml",
          genetic_structure = "unstructured"
        )
      ),
      "ai_reml"
    ),
    "only planned for the `target = \"multivariate\"` bridge",
    fixed = TRUE
  )
  expect_error(
    hsquared(
      cbind(y1, y2) ~ animal(1 | id, pedigree = ped),
      data = dat,
      control = hs_control(
        engine = "julia",
        engine_control = list(
          target = "multivariate",
          genetic_structure = "diagonal"
        )
      )
    ),
    "planned, not implemented",
    fixed = TRUE
  )
})

test_that("multivariate initial values are named covariance matrices", {
  expect_equal(
    hsquared:::hs_validate_multivariate_initial(NULL, 2L),
    list(G0 = diag(1, 2L), R0 = diag(1, 2L))
  )
  expect_error(
    hsquared:::hs_validate_multivariate_initial(list(diag(2), diag(2)), 2L),
    "named list",
    fixed = TRUE
  )
  expect_error(
    hsquared:::hs_validate_multivariate_initial(
      list(G0 = diag(2), R0 = matrix(1, 2, 2)),
      2L
    ),
    "positive definite",
    fixed = TRUE
  )
  expect_error(
    hsquared:::hs_fit_julia_multivariate_payload(list()),
    "must be an internal `hs_bridge_payload`",
    fixed = TRUE
  )
})

test_that("multivariate result normalizer exposes G, R, h2, and cross-trait EBVs", {
  payload <- list(
    Y = matrix(c(1, 2, 3, 4, 1.5, NA, 3.5, 4.5), nrow = 4),
    X = matrix(c(1, 1, 1, 1, 0, 1, 0, 1), nrow = 4),
    ids = c("sire", "dam", "calf1", "calf2"),
    family = "gaussian",
    metadata = list(
      fixed_colnames = c("(Intercept)", "sexm"),
      trait_names = c("y1", "y2")
    )
  )
  raw <- list(
    genetic_covariance = matrix(c(1.0, 0.2, 0.2, 1.5), 2),
    residual_covariance = matrix(c(2.0, 0.1, 0.1, 2.5), 2),
    genetic_correlation = matrix(c(1.0, 0.1633, 0.1633, 1.0), 2),
    residual_correlation = matrix(c(1.0, 0.0447, 0.0447, 1.0), 2),
    heritability = c(1 / 3, 1.5 / 4),
    beta = matrix(c(1, 0.5, 2, 0.7), nrow = 2),
    breeding_ids = payload$ids,
    breeding_traits = c("y1", "y2"),
    breeding_values = matrix(seq(0.1, 0.8, length.out = 8), nrow = 4),
    loglik = -22.5,
    converged = TRUE,
    iterations = 18L,
    traits = c("y1", "y2"),
    genetic_structure = "unstructured"
  )

  result <- hsquared:::hs_normalize_multivariate_result(raw, payload)
  fit <- hsquared:::hs_new_fit(
    spec = list(
      method = "REML",
      family = list(family = "gaussian"),
      target = "multivariate"
    ),
    payload = payload,
    result = result
  )

  expect_equal(dimnames(genetic_covariance(fit)), list(c("y1", "y2"), c("y1", "y2")))
  expect_equal(residual_covariance(fit), result$residual_covariance)
  expect_equal(genetic_correlation(fit), result$genetic_correlation)
  expect_equal(residual_correlation(fit), result$residual_correlation)
  expect_equal(nrow(heritability(fit)), 2L)
  expect_equal(nrow(breeding_values(fit)), 8L)
  expect_equal(stats::nobs(fit), 7L)
  expect_s3_class(stats::logLik(fit), "logLik")
})

test_that("non-converged multivariate fits do not expose logLik or AIC", {
  payload <- list(
    Y = matrix(1:4, nrow = 2),
    X = matrix(1, nrow = 2, ncol = 1),
    ids = c("a", "b"),
    metadata = list(fixed_colnames = "(Intercept)", trait_names = c("y1", "y2"))
  )
  raw <- list(
    genetic_covariance = diag(2),
    residual_covariance = diag(2),
    genetic_correlation = diag(2),
    residual_correlation = diag(2),
    heritability = c(0.5, 0.5),
    beta = matrix(c(1, 2), nrow = 1),
    breeding_ids = c("a", "b"),
    breeding_traits = c("y1", "y2"),
    breeding_values = matrix(0, 2, 2),
    loglik = -1,
    converged = FALSE,
    iterations = 10L,
    traits = c("y1", "y2"),
    genetic_structure = "unstructured"
  )
  fit <- hsquared:::hs_new_fit(
    spec = list(
      method = "REML",
      family = list(family = "gaussian"),
      target = "multivariate"
    ),
    payload = payload,
    result = hsquared:::hs_normalize_multivariate_result(raw, payload)
  )

  expect_error(stats::logLik(fit), "did not converge", fixed = TRUE)
  expect_error(AIC(fit), "did not converge", fixed = TRUE)
})

test_that("JuliaCall sends multivariate response NA cells as NaN", {
  testthat::skip_on_cran()
  testthat::skip_if_not(
    hsquared:::hs_julia_bridge_available(),
    "JuliaCall, Julia, and local HSquared.jl are required for live bridge smoke."
  )

  ped <- data.frame(
    id = c("sire", "dam", "calf1", "calf2"),
    sire = c(NA, NA, "sire", "sire"),
    dam = c(NA, NA, "dam", "dam")
  )
  dat <- data.frame(
    y1 = c(1, 2, 3, 4),
    y2 = c(1.5, NA, 3.5, 4.5),
    id = ped$id
  )
  spec <- hsquared:::hs_build_model_spec(
    cbind(y1, y2) ~ animal(1 | id, pedigree = ped),
    data = dat,
    family = stats::gaussian(),
    REML = TRUE
  )
  payload <- hsquared:::hs_build_bridge_payload(spec)
  hsquared:::hs_julia_setup(hsquared:::hs_default_julia_project())
  JuliaCall::julia_assign("hsq_Y_roundtrip", payload$Y)

  expect_equal(
    JuliaCall::julia_eval("sum(isnan.(hsq_Y_roundtrip))"),
    1L
  )
})

test_that("hsquared can use the opt-in experimental multivariate REML bridge", {
  testthat::skip_on_cran()
  testthat::skip_if_not(
    hsquared:::hs_julia_bridge_available(),
    "JuliaCall, Julia, and local HSquared.jl are required for live multivariate bridge smoke."
  )

  ped <- data.frame(
    id = c("s1", "d1", "s2", "d2", "a", "b", "c", "d"),
    sire = c(NA, NA, NA, NA, "s1", "s1", "s2", "s2"),
    dam = c(NA, NA, NA, NA, "d1", "d1", "d2", "d2")
  )
  dat <- data.frame(
    y1 = c(1.0, 1.8, 1.2, 2.0, 3.0, 3.4, 2.8, 3.2),
    y2 = c(2.1, 1.5, 2.2, 1.7, 3.1, NA, 3.0, 2.8),
    id = ped$id
  )

  fit <- hsquared(
    cbind(y1, y2) ~ animal(1 | id, pedigree = ped),
    data = dat,
    family = stats::gaussian(),
    REML = TRUE,
    control = hs_control(
      engine = "julia",
      engine_control = list(target = "multivariate", iterations = 400L)
    )
  )

  expect_s3_class(fit, "hsquared_fit")
  expect_equal(fit$spec$target, "multivariate")
  expect_equal(dim(genetic_covariance(fit)), c(2L, 2L))
  expect_equal(dim(residual_covariance(fit)), c(2L, 2L))
  expect_equal(dim(genetic_correlation(fit)), c(2L, 2L))
  expect_equal(dim(residual_correlation(fit)), c(2L, 2L))
  expect_equal(heritability(fit)$trait, c("y1", "y2"))
  expect_equal(nrow(breeding_values(fit)), 16L)
  expect_equal(stats::nobs(fit), 15L)
  expect_equal(
    fit_diagnostics(fit)$value[
      fit_diagnostics(fit)$metric == "variance_components_source"
    ],
    "estimated_multivariate_reml"
  )
})

hs_phase4_fixture_path <- function(file) {
  testthat::test_path("fixtures", "phase4_multitrait_parity", file)
}

hs_read_phase4_fixture <- function(file) {
  utils::read.csv(
    hs_phase4_fixture_path(file),
    stringsAsFactors = FALSE,
    na.strings = c("", "NA")
  )
}

hs_phase4_matrix <- function(file) {
  dat <- hs_read_phase4_fixture(file)
  out <- as.matrix(dat[-1])
  storage.mode(out) <- "double"
  rownames(out) <- dat[[1]]
  out
}

test_that("R consumes the shared Phase 4 multivariate parity fixture", {
  ped <- hs_read_phase4_fixture("pedigree.csv")
  names(ped)[names(ped) == "animal"] <- "id"
  ped$sire[ped$sire == "0"] <- NA
  ped$dam[ped$dam == "0"] <- NA

  pheno <- hs_read_phase4_fixture("phenotypes.csv")
  G0 <- hs_phase4_matrix("expected_genetic_covariance.csv")
  R0 <- hs_phase4_matrix("expected_residual_covariance.csv")
  beta <- hs_phase4_matrix("expected_beta.csv")
  h2 <- hs_read_phase4_fixture("expected_heritability.csv")
  ebv <- hs_read_phase4_fixture("expected_ebv.csv")
  metadata <- stats::setNames(
    hs_read_phase4_fixture("expected_metadata.csv")$value,
    hs_read_phase4_fixture("expected_metadata.csv")$key
  )

  spec <- hsquared:::hs_build_model_spec(
    cbind(trait1, trait2) ~ x + animal(1 | animal, pedigree = ped),
    data = pheno,
    family = stats::gaussian(),
    REML = TRUE
  )
  payload <- hsquared:::hs_build_bridge_payload(spec)

  expect_equal(payload$metadata$response_type, "multivariate")
  expect_equal(payload$metadata$trait_names, c("trait1", "trait2"))
  expect_equal(payload$metadata$fixed_colnames, c("(Intercept)", "x"))
  expect_equal(payload$metadata$observed_ids, pheno$animal)
  expect_equal(payload$ids, ped$id)
  expect_equal(dim(payload$Z), c(nrow(pheno), nrow(ped)))
  expect_equal(payload$Y, unname(as.matrix(pheno[c("trait1", "trait2")])))
  expect_equal(payload$X, unname(stats::model.matrix(~ x, data = pheno)))

  raw <- list(
    genetic_covariance = G0,
    residual_covariance = R0,
    genetic_correlation = stats::cov2cor(G0),
    residual_correlation = stats::cov2cor(R0),
    heritability = h2$h2,
    beta = beta,
    breeding_ids = ebv$animal,
    breeding_traits = c("trait1", "trait2"),
    breeding_values = as.matrix(ebv[c("trait1", "trait2")]),
    loglik = as.numeric(metadata[["loglik"]]),
    converged = identical(tolower(metadata[["converged"]]), "true"),
    iterations = as.integer(metadata[["iterations"]]),
    traits = c("trait1", "trait2"),
    genetic_structure = "unstructured"
  )
  result <- hsquared:::hs_normalize_multivariate_result(raw, payload)
  fit <- hsquared:::hs_new_fit(
    spec = list(
      method = "REML",
      family = list(family = "gaussian"),
      target = "multivariate"
    ),
    payload = payload,
    result = result
  )

  expect_equal(genetic_covariance(fit), G0, tolerance = 1e-10)
  expect_equal(G_matrix(fit), G0, tolerance = 1e-10)
  expect_equal(residual_covariance(fit), R0, tolerance = 1e-10)
  expect_equal(R_matrix(fit), R0, tolerance = 1e-10)
  expect_equal(genetic_correlation(fit), stats::cov2cor(G0), tolerance = 1e-10)
  expect_equal(residual_correlation(fit), stats::cov2cor(R0), tolerance = 1e-10)
  expect_equal(heritability(fit)$estimate, h2$h2, tolerance = 1e-10)

  fixed <- fixef(fit)
  expected_fixed <- data.frame(
    term = rep(c("(Intercept)", "x"), times = 2L),
    trait = rep(c("trait1", "trait2"), each = 2L),
    estimate = as.vector(beta),
    stringsAsFactors = FALSE
  )
  expect_equal(fixed, expected_fixed, tolerance = 1e-10)

  expected_ebv <- data.frame(
    id = rep(ebv$animal, times = 2L),
    trait = rep(c("trait1", "trait2"), each = nrow(ebv)),
    value = c(ebv$trait1, ebv$trait2),
    stringsAsFactors = FALSE
  )
  expect_equal(breeding_values(fit), expected_ebv, tolerance = 1e-10)
  expect_equal(stats::nobs(fit), nrow(pheno) * 2L)
  expect_equal(as.numeric(stats::logLik(fit)), as.numeric(metadata[["loglik"]]))
  expect_equal(
    attr(stats::logLik(fit), "df"),
    ncol(payload$X) * 2L + 2L * (2L + 1L)
  )
  expect_equal(
    fit_diagnostics(fit)$value[
      fit_diagnostics(fit)$metric == "genetic_structure"
    ],
    "unstructured"
  )
})

test_that("optional sommer comparator matches the Phase 4 diagonal-residual target", {
  testthat::skip_on_cran()
  testthat::skip_if_not_installed("sommer")
  testthat::skip_if_not_installed("nadiv")

  ped <- hs_read_phase4_fixture("pedigree.csv")
  pheno <- hs_read_phase4_fixture("phenotypes.csv")
  G0 <- hs_phase4_matrix("expected_genetic_covariance.csv")
  R0 <- hs_phase4_matrix("expected_residual_covariance.csv")
  h2 <- hs_read_phase4_fixture("expected_heritability.csv")

  ped_a <- ped
  names(ped_a)[names(ped_a) == "animal"] <- "id"
  ped_a$sire[ped_a$sire == "0"] <- NA
  ped_a$dam[ped_a$dam == "0"] <- NA
  A <- suppressWarnings(
    as.matrix(nadiv::makeA(ped_a[, c("id", "sire", "dam")]))
  )
  A <- A[ped$animal, ped$animal]

  long <- stats::reshape(
    pheno[c("record", "animal", "x", "trait1", "trait2")],
    varying = c("trait1", "trait2"),
    v.names = "value",
    timevar = "trait",
    times = c("trait1", "trait2"),
    idvar = "record",
    direction = "long"
  )
  long$trait <- factor(long$trait, levels = c("trait1", "trait2"))
  long$animal <- factor(long$animal, levels = ped$animal)
  long$.record_index <- match(long$record, pheno$record)
  long <- long[with(long, order(trait, .record_index)), ]
  row.names(long) <- NULL

  fit <- tryCatch(
    sommer::mmes(
      value ~ trait + trait:x - 1,
      random = ~ sommer::vsm(
        sommer::usm(trait),
        sommer::ism(animal),
        Gu = A
      ),
      rcov = ~ sommer::vsm(sommer::dsm(trait), sommer::ism(units)),
      data = long,
      verbose = FALSE,
      dateWarning = FALSE,
      nIters = 80L
    ),
    error = function(e) e
  )
  if (inherits(fit, "error")) {
    testthat::skip(paste(
      "sommer multivariate comparator API did not fit this fixture:",
      conditionMessage(fit)
    ))
  }
  expect_true(isTRUE(fit$convergence))

  genetic_i <- grep("animal", names(fit$theta), fixed = TRUE)
  residual_i <- match("units", names(fit$theta))
  if (length(genetic_i) != 1L || is.na(residual_i)) {
    testthat::skip("sommer theta layout changed; comparator extraction needs review.")
  }

  Ghat <- as.matrix(fit$theta[[genetic_i]])
  Rhat <- as.matrix(fit$theta[[residual_i]])
  dimnames(Ghat) <- dimnames(G0)
  dimnames(Rhat) <- dimnames(R0)

  expect_equal(Ghat, G0, tolerance = 5e-4)
  expect_equal(diag(Rhat), diag(R0), tolerance = 5e-4)
  expect_equal(
    unname(diag(Ghat) / (diag(Ghat) + diag(Rhat))),
    unname(h2$h2),
    tolerance = 5e-4
  )
  expect_equal(Rhat[upper.tri(Rhat)], 0, tolerance = 1e-12)
})
