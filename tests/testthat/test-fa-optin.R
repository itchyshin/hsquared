test_that("FA control requires explicit four-trait rank-one Julia opt-in", {
  fa <- hs_control(
    engine = "julia",
    engine_control = list(
      target = "multivariate", genetic_structure = "factor_analytic",
      rank = 1L, julia_project = "/tmp/HSquared.jl"
    )
  )
  expect_equal(
    hsquared:::hs_validate_genetic_structure_control(fa, "multivariate"),
    "factor_analytic"
  )
  expect_error(
    hsquared:::hs_validate_genetic_structure_control(
      hs_control(engine = "julia", engine_control = list(
        target = "multivariate", genetic_structure = "factor_analytic"
      )), "multivariate"
    ),
    "rank = 1"
  )
  expect_error(
    hsquared:::hs_validate_genetic_structure_control(
      hs_control(engine = "julia", engine_control = list(
        target = "multivariate", genetic_structure = "factor_analytic", rank = 2L
      )), "multivariate"
    ),
    "rank = 1"
  )
  expect_error(
    hsquared:::hs_validate_genetic_structure_control(
      hs_control(engine = "julia", engine_control = list(
        target = "multivariate", genetic_structure = "lowrank", rank = 1L
      )), "multivariate"
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
        start, 4L, genetic_structure = "factor_analytic"
      ),
      field, fixed = TRUE
    )
  }
})

test_that("FA normalization exposes identified Psi and correct parameter count", {
  traits <- paste0("t", 1:4)
  G <- diag(2, 4) + 0.3
  R <- diag(1, 4)
  raw <- list(
    traits = traits, genetic_covariance = G, residual_covariance = R,
    genetic_correlation = stats::cov2cor(G), residual_correlation = R,
    genetic_uniqueness = rep(2, 4), genetic_rank = 1L,
    heritability = diag(G) / (diag(G) + 1),
    beta = matrix(0, 1, 4), breeding_ids = c("a", "b"),
    breeding_traits = traits, breeding_values = matrix(0, 2, 4),
    genetic_structure = "factor_analytic", loglik = -30,
    converged = TRUE, iterations = 10L
  )
  payload <- list(
    Y = matrix(1:8, 2, 4), X = matrix(1, 2, 1), ids = c("a", "b"),
    metadata = list(fixed_colnames = "(Intercept)", trait_names = traits)
  )
  result <- hsquared:::hs_normalize_multivariate_result(raw, payload)
  fit <- hsquared:::hs_new_fit(
    spec = list(method = "REML", family = list(family = "gaussian"),
                target = "multivariate"),
    payload = payload, result = result
  )
  expect_equal(genetic_covariance(fit), structure(G, dimnames = list(traits, traits)))
  expect_equal(genetic_correlation(fit), structure(stats::cov2cor(G), dimnames = list(traits, traits)))
  expect_equal(specific_variance(fit), stats::setNames(rep(2, 4), traits))
  expect_equal(result$n_genetic_params, 8L)
  expect_equal(attr(stats::logLik(fit), "df"), 22L)
  expect_match(result$diagnostics$identifiability_caveat, "local")
  expect_match(
    fit_diagnostics(fit)$value[
      fit_diagnostics(fit)$metric == "identifiability_caveat"
    ], "locally identifiable"
  )
  expect_error(genetic_loadings(fit), "planned", fixed = TRUE)
  expect_null(result$covariance_standard_errors)
  raw$se_genetic_covariance <- diag(4)
  expect_null(
    hsquared:::hs_normalize_multivariate_result(raw, payload)$covariance_standard_errors
  )
  raw$genetic_uniqueness <- c(2, 2, 2, NA_real_)
  expect_error(
    hsquared:::hs_normalize_multivariate_result(raw, payload),
    "positive `genetic_uniqueness`", fixed = TRUE
  )
})

test_that("FA bridge cell rejects incomplete and wider models before Julia", {
  ped <- data.frame(id = letters[1:8], sire = NA_character_, dam = NA_character_)
  dat <- data.frame(
    id = ped$id, t1 = 1:8, t2 = 2:9, t3 = 3:10, t4 = 4:11
  )
  spec <- hsquared:::hs_build_model_spec(
    cbind(t1, t2, t3, t4) ~ animal(1 | id, pedigree = ped),
    dat, stats::gaussian(), TRUE
  )
  payload <- hsquared:::hs_build_bridge_payload(spec)
  fa <- hs_control(engine = "julia", engine_control = list(
    target = "multivariate", genetic_structure = "factor_analytic",
    rank = 1L, julia_project = "/tmp/HSquared.jl"
  ))
  expect_null(hsquared:::hs_validate_fa_optin_spec(
    fa, "multivariate", spec, payload
  ))
  no_project <- fa
  no_project$engine_control$julia_project <- NULL
  expect_error(hsquared:::hs_validate_fa_optin_spec(
    no_project, "multivariate", spec, payload
  ), "julia_project", fixed = TRUE)
  default_engine <- fa
  default_engine$engine <- "fit"
  expect_error(hsquared:::hs_validate_fa_optin_spec(
    default_engine, "multivariate", spec, payload
  ), "explicit", fixed = TRUE)
  expect_error(hsquared(
    cbind(t1, t2, t3, t4) ~ animal(1 | id, pedigree = ped),
    data = dat,
    control = hs_control(engine = "fit", engine_control = list(
      target = "multivariate", genetic_structure = "factor_analytic",
      rank = 1L, julia_project = "/tmp/HSquared.jl"
    ))
  ), "requires explicit", fixed = TRUE)
  no_target <- fa
  no_target$engine_control$target <- NULL
  expect_error(hsquared:::hs_validate_fa_optin_spec(
    no_target, "fit_animal_model", spec, payload
  ), "target = \"multivariate\"", fixed = TRUE)
  three <- payload
  three$Y <- three$Y[, 1:3, drop = FALSE]
  expect_error(hsquared:::hs_validate_fa_optin_spec(
    fa, "multivariate", spec, three
  ), "exactly four traits", fixed = TRUE)
  missing <- payload
  missing$Y[1, 1] <- NA_real_
  expect_error(hsquared:::hs_validate_fa_optin_spec(
    fa, "multivariate", spec, missing
  ), "complete Gaussian", fixed = TRUE)
  slope <- payload
  slope$X <- cbind(slope$X, x = 1:8)
  expect_error(hsquared:::hs_validate_fa_optin_spec(
    fa, "multivariate", spec, slope
  ), "trait intercepts only", fixed = TRUE)
  other_effect <- spec
  other_effect$random$permanent <- list()
  expect_error(hsquared:::hs_validate_fa_optin_spec(
    fa, "multivariate", other_effect, payload
  ), "pedigree `animal()`", fixed = TRUE)
  bad_start <- list(G0 = diag(4), R0 = diag(4),
                    loadings = matrix(0.5, 4, 1))
  expect_error(hsquared(
    cbind(t1, t2, t3, t4) ~ animal(1 | id, pedigree = ped),
    data = dat,
    control = hs_control(engine = "julia", engine_control = list(
      target = "multivariate", genetic_structure = "factor_analytic",
      rank = 1L, julia_project = "/tmp/HSquared.jl", initial = bad_start
    ))
  ), "`loadings` would otherwise be silently ignored", fixed = TRUE)
})

test_that("FA bridge keeps unsorted pedigree labels aligned with incidence", {
  ped <- data.frame(
    id = c("offspring", "dam", "sire", "founder"),
    sire = c("sire", NA, NA, NA), dam = c("dam", NA, NA, NA)
  )
  dat <- data.frame(
    id = rep(c("offspring", "sire", "dam", "founder"), each = 2L),
    t1 = 1:8, t2 = 2:9, t3 = 3:10, t4 = 4:11
  )
  spec <- hsquared:::hs_build_model_spec(
    cbind(t1, t2, t3, t4) ~ animal(1 | id, pedigree = ped),
    dat, stats::gaussian(), TRUE
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
    "hsq_fa_probe_sire", hsquared:::hs_parent_for_julia(payload$pedigree$sire)
  )
  JuliaCall::julia_assign(
    "hsq_fa_probe_dam", hsquared:::hs_parent_for_julia(payload$pedigree$dam)
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
  U <- matrix(stats::rnorm(n_animals * 4), n_animals, 4) %*% chol(Gtrue)
  E <- matrix(stats::rnorm(n_animals * repeats * 4),
              n_animals * repeats, 4) %*% chol(Rtrue)
  Y <- U[rep(seq_len(n_animals), each = repeats), , drop = FALSE] + E
  ped <- data.frame(
    id = paste0("a", seq_len(n_animals)),
    sire = NA_character_, dam = NA_character_
  )
  dat <- data.frame(Y, id = rep(ped$id, each = repeats))
  names(dat)[1:4] <- traits
  fit <- suppressWarnings(hsquared(
    cbind(t1, t2, t3, t4) ~ animal(1 | id, pedigree = ped),
    data = dat,
    control = hs_control(engine = "julia", engine_control = list(
      target = "multivariate", genetic_structure = "factor_analytic",
      rank = 1L, julia_project = project, iterations = 5000L
    ))
  ))
  expect_s3_class(fit, "hsquared_fit")
  expect_true(fit$result$converged)
  expect_equal(dim(genetic_covariance(fit)), c(4L, 4L))
  expect_equal(dim(genetic_correlation(fit)), c(4L, 4L))
  expect_equal(length(specific_variance(fit)), 4L)
  expect_true(all(specific_variance(fit) > 0))
  expect_true(all(specific_variance(fit) <= diag(genetic_covariance(fit)) + 1e-8))
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
    dat, stats::gaussian(), TRUE
  )
  payload <- hsquared:::hs_build_bridge_payload(spec)
  expect_equal(JuliaCall::julia_eval("hsq_Y"), unname(payload$Y))
  expect_equal(
    JuliaCall::julia_eval("hsq_X"),
    matrix(as.numeric(payload$X), nrow = nrow(payload$X))
  )
  expect_equal(JuliaCall::julia_eval("Matrix(hsq_Z)"),
               unname(as.matrix(payload$Z)))
  JuliaCall::julia_command(paste(
    "hsq_fa_direct = HSquared.fit_multivariate_reml(",
    "hsq_Y, hsq_X, hsq_Z, hsq_Ainv; initial = nothing,",
    "iterations = hsq_iterations, ids = hsq_ped.ids, traits = hsq_traits,",
    "genetic_structure = :factor_analytic, rank = 1);",
    "hsq_fa_direct_raw = Dict(",
    "\"G\" => Matrix{Float64}(hsq_fa_direct.genetic_covariance),",
    "\"R\" => Matrix{Float64}(hsq_fa_direct.residual_covariance),",
    "\"Gcor\" => Matrix{Float64}(hsq_fa_direct.genetic_correlation),",
    "\"psi\" => collect(Float64, hsq_fa_direct.genetic_uniqueness),",
    "\"h2\" => collect(Float64, hsq_fa_direct.heritability),",
    "\"beta\" => Matrix{Float64}(hsq_fa_direct.beta),",
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
})
