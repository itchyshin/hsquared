test_that("FA control requires explicit four-trait rank-one Julia opt-in", {
  fa <- hs_control(
    engine = "julia",
    engine_control = list(
      target = "multivariate",
      genetic_structure = "factor_analytic",
      rank = 1L,
      julia_project = "/tmp/HSquared.jl"
    )
  )
  expect_equal(
    hsquared:::hs_validate_genetic_structure_control(fa, "multivariate"),
    "factor_analytic"
  )
  expect_error(
    hsquared:::hs_validate_genetic_structure_control(
      hs_control(
        engine = "julia",
        engine_control = list(
          target = "multivariate",
          genetic_structure = "factor_analytic"
        )
      ),
      "multivariate"
    ),
    "rank = 1"
  )
  expect_error(
    hsquared:::hs_validate_genetic_structure_control(
      hs_control(
        engine = "julia",
        engine_control = list(
          target = "multivariate",
          genetic_structure = "factor_analytic",
          rank = 2L
        )
      ),
      "multivariate"
    ),
    "rank = 1"
  )
  expect_error(
    hsquared:::hs_validate_genetic_structure_control(
      hs_control(
        engine = "julia",
        engine_control = list(
          target = "multivariate",
          genetic_structure = "lowrank",
          rank = 1L
        )
      ),
      "multivariate"
    ),
    "lowrank"
  )
  for (field in c("loadings", "uniqueness")) {
    start <- list(G0 = diag(4), R0 = diag(4))
    start[[field]] <- if (identical(field, "loadings")) {
      matrix(0.5, 4, 1)
    } else {
      rep(0.5, 4)
    }
    expect_error(
      hsquared:::hs_validate_multivariate_initial(
        start,
        4L,
        genetic_structure = "factor_analytic"
      ),
      field,
      fixed = TRUE
    )
  }
})

test_that("FA normalization reports Psi without assessing its identification", {
  traits <- paste0("t", 1:4)
  G <- diag(2, 4) + 0.3
  R <- diag(1, 4)
  raw <- list(
    traits = traits,
    genetic_covariance = G,
    residual_covariance = R,
    genetic_correlation = stats::cov2cor(G),
    residual_correlation = R,
    genetic_uniqueness = rep(2, 4),
    genetic_rank = 1L,
    genetic_uniqueness_identification = "not_assessed_by_fit",
    heritability = diag(G) / (diag(G) + 1),
    beta = matrix(0, 1, 4),
    breeding_ids = c("a", "b"),
    breeding_traits = traits,
    breeding_values = matrix(0, 2, 4),
    genetic_structure = "factor_analytic",
    loglik = -30,
    converged = TRUE,
    iterations = 10L,
    fa_start_strategy = "default_and_balanced",
    fa_start_starts_attempted = 2L,
    fa_start_selected_start = "balanced",
    fa_start_objective_range = 0.5,
    fa_start_g_relative_disagreement = 0.02,
    fa_start_r_relative_disagreement = 0.03,
    fa_start_better_nonconverged_start = FALSE,
    fa_start_minimum_uniqueness = 0.1,
    fa_start_uniqueness_floor_distance = 0.0999,
    fa_start_near_uniqueness_floor = FALSE,
    fa_start_names = c("default", "balanced"),
    fa_start_loglik = c(-30.5, -30),
    fa_start_valid = c(TRUE, TRUE),
    fa_start_converged = c(TRUE, TRUE),
    fa_start_iterations = c(10L, 12L),
    fa_start_minimum_uniqueness_by_start = c(0.2, 0.1),
    fa_start_uniqueness_floor_distance_by_start = c(0.1999, 0.0999)
  )
  payload <- list(
    Y = matrix(1:8, 2, 4),
    X = matrix(1, 2, 1),
    ids = c("a", "b"),
    metadata = list(fixed_colnames = "(Intercept)", trait_names = traits)
  )
  malformed <- raw
  malformed$genetic_covariance[1, 2] <- malformed$genetic_covariance[1, 2] + .2
  expect_error(
    hsquared:::hs_normalize_multivariate_result(malformed, payload),
    "genetic covariance must be symmetric"
  )
  malformed <- raw
  malformed$residual_covariance <- diag(c(-1, 1, 1, 1))
  expect_error(
    hsquared:::hs_normalize_multivariate_result(malformed, payload),
    "residual covariance must have positive marginal variances"
  )
  malformed <- raw
  malformed$genetic_correlation <- diag(4)
  expect_error(
    hsquared:::hs_normalize_multivariate_result(malformed, payload),
    "inconsistent with genetic covariance"
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
  expect_equal(
    genetic_covariance(fit),
    structure(G, dimnames = list(traits, traits))
  )
  expect_equal(
    genetic_correlation(fit),
    structure(stats::cov2cor(G), dimnames = list(traits, traits))
  )
  expect_equal(specific_variance(fit), stats::setNames(rep(2, 4), traits))
  expect_identical(
    result$diagnostics$genetic_uniqueness_identification,
    "not_assessed_by_fit"
  )
  expect_equal(result$n_genetic_params, 8L)
  expect_identical(result$diagnostics$fa_start_strategy, "default_and_balanced")
  expect_identical(result$diagnostics$fa_start_selected_start, "balanced")
  expect_equal(result$diagnostics$fa_start_loglik, c(-30.5, -30))
  expect_equal(result$diagnostics$fa_start_iterations, c(10L, 12L))
  expect_equal(result$diagnostics$fa_start_minimum_uniqueness, 0.1)
  expect_equal(result$diagnostics$fa_start_uniqueness_floor_distance, 0.0999)
  expect_false(result$diagnostics$fa_start_near_uniqueness_floor)
  expect_false(result$diagnostics$fa_start_better_nonconverged_start)
  expect_identical(
    result$diagnostics$fa_start_starts$name,
    c("default", "balanced")
  )
  expect_equal(result$diagnostics$fa_start_starts$valid, c(TRUE, TRUE))
  expect_equal(result$diagnostics$fa_start_starts$converged, c(TRUE, TRUE))
  expect_equal(
    result$diagnostics$fa_start_starts$minimum_uniqueness,
    c(0.2, 0.1)
  )
  expect_equal(
    result$diagnostics$fa_start_starts$uniqueness_floor_distance,
    c(0.1999, 0.0999)
  )
  fd <- fit_diagnostics(fit)
  expect_identical(
    fd$value[fd$metric == "fa_start_selected_start"],
    "balanced"
  )
  expect_identical(
    fd$value[fd$metric == "fa_start_loglik"],
    "-30.5, -30.0"
  )
  expect_true("fa_start_starts" %in% fd$metric)
  expect_match(
    fd$value[fd$metric == "fa_start_starts"],
    "default.*balanced"
  )
  expect_false(any(fd$value == "<list>"))
  expect_equal(attr(stats::logLik(fit), "df"), 22L)
  expect_match(result$diagnostics$identifiability_caveat, "local")
  expect_identical(
    fit_diagnostics(fit)$value[
      fit_diagnostics(fit)$metric == "genetic_uniqueness_identification"
    ],
    "not_assessed_by_fit"
  )
  expect_match(
    fit_diagnostics(fit)$value[
      fit_diagnostics(fit)$metric == "identifiability_caveat"
    ],
    "locally identifiable"
  )
  expect_error(genetic_loadings(fit), "planned", fixed = TRUE)
  expect_null(result$covariance_standard_errors)
  missing_status <- raw
  missing_status$genetic_uniqueness_identification <- NULL
  expect_error(
    hsquared:::hs_normalize_multivariate_result(missing_status, payload),
    "genetic_uniqueness_identification",
    fixed = TRUE
  )
  unknown_status <- raw
  unknown_status$genetic_uniqueness_identification <- "identified"
  expect_error(
    hsquared:::hs_normalize_multivariate_result(unknown_status, payload),
    "not_assessed_by_fit",
    fixed = TRUE
  )
  missing_fa_starts <- raw
  missing_fa_starts$fa_start_iterations <- NULL
  expect_error(
    hsquared:::hs_normalize_multivariate_result(missing_fa_starts, payload),
    "fa_start_iterations",
    fixed = TRUE
  )
  malformed_fa_starts <- raw
  malformed_fa_starts$fa_start_converged <- TRUE
  expect_error(
    hsquared:::hs_normalize_multivariate_result(malformed_fa_starts, payload),
    "same length",
    fixed = TRUE
  )
  nonfinite_fa_starts <- raw
  nonfinite_fa_starts$fa_start_loglik[2] <- Inf
  expect_error(
    hsquared:::hs_normalize_multivariate_result(nonfinite_fa_starts, payload),
    "finite",
    fixed = TRUE
  )
  unknown_selected_fa_start <- raw
  unknown_selected_fa_start$fa_start_selected_start <- "restart_3"
  expect_error(
    hsquared:::hs_normalize_multivariate_result(
      unknown_selected_fa_start,
      payload
    ),
    "selected start",
    fixed = TRUE
  )
  mixed_validity <- raw
  mixed_validity$fa_start_selected_start <- "default"
  mixed_validity$fa_start_valid <- c(TRUE, FALSE)
  mixed_validity$fa_start_converged <- c(TRUE, FALSE)
  mixed_validity$fa_start_loglik <- c(-30.5, NA_real_)
  mixed_validity$fa_start_minimum_uniqueness_by_start <- c(0.2, NA_real_)
  mixed_validity$fa_start_uniqueness_floor_distance_by_start <- c(
    0.1999,
    NA_real_
  )
  mixed_validity$fa_start_objective_range <- NA_real_
  mixed_validity$fa_start_g_relative_disagreement <- NA_real_
  mixed_validity$fa_start_r_relative_disagreement <- NA_real_
  normalized_mixed <- hsquared:::hs_normalize_multivariate_result(
    mixed_validity,
    payload
  )
  expect_identical(
    normalized_mixed$diagnostics$fa_start_selected_start,
    "default"
  )
  expect_true(is.na(normalized_mixed$diagnostics$fa_start_loglik[2]))
  expect_true(is.na(
    normalized_mixed$diagnostics$fa_start_starts$minimum_uniqueness[2]
  ))
  expect_true(is.na(normalized_mixed$diagnostics$fa_start_objective_range))
  reordered_traits <- raw
  reordered_traits$traits <- rev(traits)
  expect_error(
    hsquared:::hs_normalize_multivariate_result(reordered_traits, payload),
    "trait order",
    fixed = TRUE
  )
  reordered_breeding_traits <- raw
  reordered_breeding_traits$breeding_traits <- rev(traits)
  expect_error(
    hsquared:::hs_normalize_multivariate_result(
      reordered_breeding_traits,
      payload
    ),
    "breeding-trait order",
    fixed = TRUE
  )
  reordered_ids <- raw
  reordered_ids$breeding_ids <- rev(raw$breeding_ids)
  expect_error(
    hsquared:::hs_normalize_multivariate_result(reordered_ids, payload),
    "pedigree ID order",
    fixed = TRUE
  )
  for (field in c("traits", "breeding_traits", "breeding_ids")) {
    missing_order <- raw
    missing_order[[field]] <- NULL
    expect_error(
      hsquared:::hs_normalize_multivariate_result(missing_order, payload),
      paste("missing required order metadata:", field),
      fixed = TRUE
    )
  }
  raw$se_genetic_covariance <- diag(4)
  expect_null(
    hsquared:::hs_normalize_multivariate_result(
      raw,
      payload
    )$covariance_standard_errors
  )
  raw$genetic_uniqueness <- c(2, 2, 2, NA_real_)
  expect_error(
    hsquared:::hs_normalize_multivariate_result(raw, payload),
    "positive `genetic_uniqueness`",
    fixed = TRUE
  )
})

test_that("FA bridge cell rejects incomplete and wider models before Julia", {
  ped <- data.frame(
    id = letters[1:8],
    sire = NA_character_,
    dam = NA_character_
  )
  dat <- data.frame(
    id = ped$id,
    t1 = 1:8,
    t2 = 2:9,
    t3 = 3:10,
    t4 = 4:11
  )
  spec <- hsquared:::hs_build_model_spec(
    cbind(t1, t2, t3, t4) ~ animal(1 | id, pedigree = ped),
    dat,
    stats::gaussian(),
    TRUE
  )
  payload <- hsquared:::hs_build_bridge_payload(spec)
  fa <- hs_control(
    engine = "julia",
    engine_control = list(
      target = "multivariate",
      genetic_structure = "factor_analytic",
      rank = 1L,
      julia_project = "/tmp/HSquared.jl"
    )
  )
  expect_null(hsquared:::hs_validate_fa_optin_spec(
    fa,
    "multivariate",
    spec,
    payload
  ))
  no_project <- fa
  no_project$engine_control$julia_project <- NULL
  expect_error(
    hsquared:::hs_validate_fa_optin_spec(
      no_project,
      "multivariate",
      spec,
      payload
    ),
    "julia_project",
    fixed = TRUE
  )
  default_engine <- fa
  default_engine$engine <- "fit"
  expect_error(
    hsquared:::hs_validate_fa_optin_spec(
      default_engine,
      "multivariate",
      spec,
      payload
    ),
    "explicit",
    fixed = TRUE
  )
  expect_error(
    hsquared(
      cbind(t1, t2, t3, t4) ~ animal(1 | id, pedigree = ped),
      data = dat,
      control = hs_control(
        engine = "fit",
        engine_control = list(
          target = "multivariate",
          genetic_structure = "factor_analytic",
          rank = 1L,
          julia_project = "/tmp/HSquared.jl"
        )
      )
    ),
    "requires explicit",
    fixed = TRUE
  )
  no_target <- fa
  no_target$engine_control$target <- NULL
  expect_error(
    hsquared:::hs_validate_fa_optin_spec(
      no_target,
      "fit_animal_model",
      spec,
      payload
    ),
    "target = \"multivariate\"",
    fixed = TRUE
  )
  three <- payload
  three$Y <- three$Y[, 1:3, drop = FALSE]
  expect_error(
    hsquared:::hs_validate_fa_optin_spec(
      fa,
      "multivariate",
      spec,
      three
    ),
    "exactly four traits",
    fixed = TRUE
  )
  missing <- payload
  missing$Y[1, 1] <- NA_real_
  expect_error(
    hsquared:::hs_validate_fa_optin_spec(
      fa,
      "multivariate",
      spec,
      missing
    ),
    "complete Gaussian",
    fixed = TRUE
  )
  slope <- payload
  slope$X <- cbind(slope$X, x = 1:8)
  expect_error(
    hsquared:::hs_validate_fa_optin_spec(
      fa,
      "multivariate",
      spec,
      slope
    ),
    "trait intercepts only",
    fixed = TRUE
  )
  other_effect <- spec
  other_effect$random$permanent <- list()
  expect_error(
    hsquared:::hs_validate_fa_optin_spec(
      fa,
      "multivariate",
      other_effect,
      payload
    ),
    "pedigree `animal()`",
    fixed = TRUE
  )
  bad_start <- list(G0 = diag(4), R0 = diag(4), loadings = matrix(0.5, 4, 1))
  expect_error(
    hsquared(
      cbind(t1, t2, t3, t4) ~ animal(1 | id, pedigree = ped),
      data = dat,
      control = hs_control(
        engine = "julia",
        engine_control = list(
          target = "multivariate",
          genetic_structure = "factor_analytic",
          rank = 1L,
          julia_project = "/tmp/HSquared.jl",
          initial = bad_start
        )
      )
    ),
    "`loadings` would otherwise be silently ignored",
    fixed = TRUE
  )
})

test_that("FA bridge keeps unsorted pedigree labels aligned with incidence", {
  ped <- data.frame(
    id = c("offspring", "dam", "sire", "founder"),
    sire = c("sire", NA, NA, NA),
    dam = c("dam", NA, NA, NA)
  )
  dat <- data.frame(
    id = rep(c("offspring", "sire", "dam", "founder"), each = 2L),
    t1 = 1:8,
    t2 = 2:9,
    t3 = 3:10,
    t4 = 4:11
  )
  spec <- hsquared:::hs_build_model_spec(
    cbind(t1, t2, t3, t4) ~ animal(1 | id, pedigree = ped),
    dat,
    stats::gaussian(),
    TRUE
  )
  payload <- hsquared:::hs_build_bridge_payload(spec)
  expect_identical(payload$ids, payload$pedigree$id)
  expect_identical(
    as.character(payload$ids[max.col(as.matrix(payload$Z))]),
    as.character(dat$id)
  )

  hs_skip_live_julia()
  project <- hsquared:::hs_default_julia_project()
  testthat::skip_if_not(
    hsquared:::hs_julia_bridge_available(project),
    "JuliaCall and a local HSquared.jl project are required for ID parity."
  )
  hsquared:::hs_julia_setup(project)
  JuliaCall::julia_assign("hsq_fa_probe_id", payload$pedigree$id)
  JuliaCall::julia_assign(
    "hsq_fa_probe_sire",
    hsquared:::hs_parent_for_julia(payload$pedigree$sire)
  )
  JuliaCall::julia_assign(
    "hsq_fa_probe_dam",
    hsquared:::hs_parent_for_julia(payload$pedigree$dam)
  )
  expect_identical(
    as.character(JuliaCall::julia_eval(
      "string.(HSquared.normalize_pedigree(hsq_fa_probe_id, hsq_fa_probe_sire, hsq_fa_probe_dam).ids)"
    )),
    as.character(payload$ids)
  )
})

test_that("live four-trait FA opt-in returns G, correlations, and Psi", {
  hs_skip_live_julia()
  project <- hsquared:::hs_default_julia_project()
  testthat::skip_if_not(
    hsquared:::hs_julia_bridge_available(project),
    "JuliaCall and a local HSquared.jl project are required for live FA smoke."
  )
  set.seed(27)
  n_animals <- 10L
  repeats <- 3L
  traits <- paste0("t", 1:4)
  loading <- c(0.8, 0.6, 0.5, 0.7)
  Gtrue <- tcrossprod(loading) + diag(0.3, 4)
  Rtrue <- diag(0.7, 4) + 0.1
  pedigree_ids <- paste0("a", seq_len(n_animals))
  offspring <- 5:n_animals
  ped <- data.frame(
    id = pedigree_ids,
    sire = c(
      rep(NA_character_, 4L),
      rep(pedigree_ids[[1L]], length(offspring))
    ),
    dam = NA_character_,
    stringsAsFactors = FALSE
  )
  A <- diag(1, n_animals)
  A[offspring, offspring] <- 0.25
  diag(A) <- 1
  A[1L, offspring] <- A[offspring, 1L] <- 0.5
  U <- t(chol(A)) %*%
    matrix(stats::rnorm(n_animals * 4), n_animals, 4) %*%
    chol(Gtrue)
  E <- matrix(stats::rnorm(n_animals * repeats * 4), n_animals * repeats, 4) %*%
    chol(Rtrue)
  Y <- U[rep(seq_len(n_animals), each = repeats), , drop = FALSE] + E
  dat <- data.frame(Y, id = rep(ped$id, each = repeats))
  names(dat)[1:4] <- traits
  fit <- suppressWarnings(hsquared(
    cbind(t1, t2, t3, t4) ~ animal(1 | id, pedigree = ped),
    data = dat,
    control = hs_control(
      engine = "julia",
      engine_control = list(
        target = "multivariate",
        genetic_structure = "factor_analytic",
        rank = 1L,
        julia_project = project,
        iterations = 5000L
      )
    )
  ))
  expect_s3_class(fit, "hsquared_fit")
  expect_true(fit$result$converged)
  expect_equal(dim(genetic_covariance(fit)), c(4L, 4L))
  expect_equal(dim(genetic_correlation(fit)), c(4L, 4L))
  expect_equal(length(specific_variance(fit)), 4L)
  expect_true(all(specific_variance(fit) > 0))
  expect_identical(
    fit$result$diagnostics$genetic_uniqueness_identification,
    "not_assessed_by_fit"
  )
  expect_true(all(
    specific_variance(fit) <= diag(genetic_covariance(fit)) + 1e-8
  ))
  expect_equal(fit$result$n_genetic_params, 8L)
  expect_match(fit$result$diagnostics$identifiability_caveat, "local")
  expect_null(fit$result$covariance_standard_errors)
  expect_error(genetic_loadings(fit), "planned", fixed = TRUE)

  # Same-input R/Julia parity: this reruns the estimator with the bridge's
  # marshaled Y/X/Z/Ainv, rank, and phenotype-scaled default start. Absolute
  # max-element tolerance 1e-8 was fixed before this leg was first run.
  expect_equal(
    normalizePath(JuliaCall::julia_eval("Base.active_project()")),
    normalizePath(file.path(project, "Project.toml"))
  )
  spec <- hsquared:::hs_build_model_spec(
    cbind(t1, t2, t3, t4) ~ animal(1 | id, pedigree = ped),
    dat,
    stats::gaussian(),
    TRUE
  )
  payload <- hsquared:::hs_build_bridge_payload(spec)
  expect_equal(JuliaCall::julia_eval("hsq_Y"), unname(payload$Y))
  expect_equal(
    JuliaCall::julia_eval("hsq_X"),
    matrix(as.numeric(payload$X), nrow = nrow(payload$X))
  )
  expect_equal(
    JuliaCall::julia_eval("Matrix(hsq_Z)"),
    unname(as.matrix(payload$Z))
  )
  JuliaCall::julia_command(paste(
    "hsq_fa_direct = HSquared.fit_multivariate_reml(",
    "hsq_Y, hsq_X, hsq_Z, hsq_Ainv; initial = nothing,",
    "iterations = hsq_iterations, ids = hsq_ped.ids, traits = hsq_traits,",
    "genetic_structure = :factor_analytic, rank = 1);",
    "fa = hsq_fa_direct.fa_start_diagnostics;",
    "hsq_fa_direct_raw = Dict(",
    "\"G\" => Matrix{Float64}(hsq_fa_direct.genetic_covariance),",
    "\"R\" => Matrix{Float64}(hsq_fa_direct.residual_covariance),",
    "\"Gcor\" => Matrix{Float64}(hsq_fa_direct.genetic_correlation),",
    "\"psi\" => collect(Float64, hsq_fa_direct.genetic_uniqueness),",
    "\"h2\" => collect(Float64, hsq_fa_direct.heritability),",
    "\"beta\" => Matrix{Float64}(hsq_fa_direct.beta),",
    "\"fa_start_strategy\" => string(fa.strategy),",
    "\"fa_start_starts_attempted\" => fa.starts_attempted,",
    "\"fa_start_selected_start\" => string(fa.selected_start),",
    "\"fa_start_objective_range\" => fa.objective_range,",
    "\"fa_start_g_relative_disagreement\" => fa.g_relative_disagreement,",
    "\"fa_start_r_relative_disagreement\" => fa.r_relative_disagreement,",
    "\"fa_start_better_nonconverged_start\" => fa.better_nonconverged_start,",
    "\"fa_start_minimum_uniqueness\" => fa.minimum_uniqueness,",
    "\"fa_start_uniqueness_floor_distance\" => fa.uniqueness_floor_distance,",
    "\"fa_start_near_uniqueness_floor\" => fa.near_uniqueness_floor,",
    "\"fa_start_names\" => [string(s.name) for s in fa.starts],",
    "\"fa_start_loglik\" => [s.loglik for s in fa.starts],",
    "\"fa_start_valid\" => [s.valid for s in fa.starts],",
    "\"fa_start_converged\" => [s.converged for s in fa.starts],",
    "\"fa_start_iterations\" => [s.iterations for s in fa.starts],",
    "\"fa_start_minimum_uniqueness_by_start\" => [s.minimum_uniqueness for s in fa.starts],",
    "\"fa_start_uniqueness_floor_distance_by_start\" => [s.uniqueness_floor_distance for s in fa.starts],",
    "\"bv\" => Matrix{Float64}(hsq_fa_direct.breeding_values.values),",
    "\"loglik\" => hsq_fa_direct.loglik);"
  ))
  direct <- JuliaCall::julia_eval("hsq_fa_direct_raw")
  tol <- 1e-8
  expect_lt(max(abs(unname(genetic_covariance(fit)) - direct$G)), tol)
  expect_lt(max(abs(unname(residual_covariance(fit)) - direct$R)), tol)
  expect_lt(max(abs(unname(genetic_correlation(fit)) - direct$Gcor)), tol)
  expect_lt(max(abs(unname(specific_variance(fit)) - direct$psi)), tol)
  expect_lt(max(abs(heritability(fit)$estimate - direct$h2)), tol)
  expect_lt(max(abs(fixef(fit)$estimate - as.vector(direct$beta))), tol)
  expect_lt(max(abs(breeding_values(fit)$value - as.vector(direct$bv))), tol)
  expect_lt(abs(as.numeric(stats::logLik(fit)) - direct$loglik), tol)
  expect_identical(
    fit$result$diagnostics$fa_start_strategy,
    direct$fa_start_strategy
  )
  expect_identical(
    fit$result$diagnostics$fa_start_selected_start,
    direct$fa_start_selected_start
  )
  expect_equal(
    fit$result$diagnostics$fa_start_starts_attempted,
    direct$fa_start_starts_attempted
  )
  expect_equal(
    fit$result$diagnostics$fa_start_objective_range,
    direct$fa_start_objective_range,
    tolerance = tol
  )
  expect_equal(
    fit$result$diagnostics$fa_start_g_relative_disagreement,
    direct$fa_start_g_relative_disagreement,
    tolerance = tol
  )
  expect_equal(
    fit$result$diagnostics$fa_start_r_relative_disagreement,
    direct$fa_start_r_relative_disagreement,
    tolerance = tol
  )
  expect_identical(
    fit$result$diagnostics$fa_start_better_nonconverged_start,
    direct$fa_start_better_nonconverged_start
  )
  expect_equal(
    fit$result$diagnostics$fa_start_minimum_uniqueness,
    direct$fa_start_minimum_uniqueness,
    tolerance = tol
  )
  expect_equal(
    fit$result$diagnostics$fa_start_uniqueness_floor_distance,
    direct$fa_start_uniqueness_floor_distance,
    tolerance = tol
  )
  expect_identical(
    fit$result$diagnostics$fa_start_near_uniqueness_floor,
    direct$fa_start_near_uniqueness_floor
  )
  expect_identical(
    fit$result$diagnostics$fa_start_starts$name,
    direct$fa_start_names
  )
  expect_equal(
    fit$result$diagnostics$fa_start_loglik,
    direct$fa_start_loglik,
    tolerance = tol
  )
  expect_identical(fit$result$diagnostics$fa_start_valid, direct$fa_start_valid)
  expect_identical(
    fit$result$diagnostics$fa_start_converged,
    direct$fa_start_converged
  )
  expect_equal(
    fit$result$diagnostics$fa_start_iterations,
    direct$fa_start_iterations
  )
  expect_equal(
    fit$result$diagnostics$fa_start_minimum_uniqueness_by_start,
    direct$fa_start_minimum_uniqueness_by_start,
    tolerance = tol
  )
  expect_equal(
    fit$result$diagnostics$fa_start_uniqueness_floor_distance_by_start,
    direct$fa_start_uniqueness_floor_distance_by_start,
    tolerance = tol
  )

  # With an explicit user start, Julia reports no cross-start range or
  # disagreement values (`nothing`). The bridge maps those fields to missing
  # R diagnostics rather than dropping the fields or rejecting the fit.
  single_start_fit <- suppressWarnings(hsquared(
    cbind(t1, t2, t3, t4) ~ animal(1 | id, pedigree = ped),
    data = dat,
    control = hs_control(
      engine = "julia",
      engine_control = list(
        target = "multivariate",
        genetic_structure = "factor_analytic",
        rank = 1L,
        julia_project = project,
        iterations = 5000L,
        initial = list(G0 = Gtrue, R0 = Rtrue)
      )
    )
  ))
  # The diagnostics serialization contract applies even when an individual
  # user-supplied start does not converge; convergence is covered by the
  # multi-start fit above.
  expect_length(single_start_fit$result$converged, 1L)
  expect_identical(
    single_start_fit$result$diagnostics$fa_start_strategy,
    "user_initial"
  )
  expect_equal(
    single_start_fit$result$diagnostics$fa_start_starts_attempted,
    1L
  )
  expect_true(is.na(
    single_start_fit$result$diagnostics$fa_start_objective_range
  ))
  expect_true(is.na(
    single_start_fit$result$diagnostics$fa_start_g_relative_disagreement
  ))
  expect_true(is.na(
    single_start_fit$result$diagnostics$fa_start_r_relative_disagreement
  ))
})
