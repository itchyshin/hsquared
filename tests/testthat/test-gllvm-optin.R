gllvm_control <- function(...) {
  values <- modifyList(
    list(
      target = "genetic_gllvm",
      genetic_structure = "lowrank",
      rank = 2L,
      experimental_gllvm = TRUE,
      julia_project = "/tmp/HSquared.jl"
    ),
    list(...)
  )
  hs_control(engine = "julia", engine_control = values)
}
gllvm_fixture <- function() {
  ped <- data.frame(
    id = letters[1:8],
    sire = NA_character_,
    dam = NA_character_
  )
  dat <- data.frame(id = rev(ped$id), t1 = 1:8, t2 = 2:9, t3 = 3:10)
  form <- cbind(t1, t2, t3) ~ animal(1 | id, pedigree = ped)
  spec <- hsquared:::hs_build_model_spec(
    form,
    dat,
    poisson(),
    TRUE,
    allow_families = "poisson"
  )
  list(
    ped = ped,
    dat = dat,
    form = form,
    spec = spec,
    payload = hsquared:::hs_build_bridge_payload(spec)
  )
}

test_that("genetic GLLVM requires explicit bounded expert controls", {
  f <- gllvm_fixture()
  expect_equal(
    hsquared:::hs_validate_gllvm_optin_spec(
      gllvm_control(),
      f$spec,
      f$payload
    ),
    8:1
  )
  for (change in list(
    list(rank = 1L),
    list(rank = 2.5),
    list(genetic_structure = "factor_analytic"),
    list(experimental_gllvm = FALSE),
    list(julia_project = "")
  )) {
    expect_error(
      hsquared:::hs_validate_gllvm_optin_spec(
        do.call(gllvm_control, change),
        f$spec,
        f$payload
      ),
      "requires"
    )
  }
  ctl <- gllvm_control()
  ctl$engine <- "fit"
  expect_error(
    hsquared:::hs_validate_gllvm_optin_spec(ctl, f$spec, f$payload),
    "explicit"
  )
  expect_error(
    hsquared:::hs_engine_control_forwarding(
      gllvm_control(initial_uniqueness = rep(1, 3)),
      "genetic_gllvm"
    ),
    "initial_uniqueness"
  )
})

test_that("genetic GLLVM rejects missing counts, wider models, and incomplete pedigrees", {
  f <- gllvm_fixture()
  for (bad in list(NA_real_, -1, 0.5, Inf)) {
    p <- f$payload
    p$Y[1, 1] <- bad
    expect_error(
      hsquared:::hs_validate_gllvm_optin_spec(gllvm_control(), f$spec, p),
      "complete|integer"
    )
  }
  p <- f$payload
  p$Y[, 1] <- 0
  expect_error(
    hsquared:::hs_validate_gllvm_optin_spec(gllvm_control(), f$spec, p),
    "all-zero"
  )
  p <- f$payload
  p$Y <- p$Y[, 1:2]
  expect_error(
    hsquared:::hs_validate_gllvm_optin_spec(gllvm_control(), f$spec, p),
    "three traits"
  )
  p <- f$payload
  p$X <- cbind(p$X, seq_len(8))
  expect_error(
    hsquared:::hs_validate_gllvm_optin_spec(gllvm_control(), f$spec, p),
    "intercepts"
  )
  p <- f$payload
  p$Z[1, ] <- p$Z[2, ]
  expect_error(
    hsquared:::hs_validate_gllvm_optin_spec(gllvm_control(), f$spec, p),
    "one complete row"
  )
  s <- f$spec
  s$family <- list(family = "binomial", link = "logit")
  expect_error(
    hsquared:::hs_validate_gllvm_optin_spec(gllvm_control(), s, f$payload),
    "Poisson"
  )
  s <- f$spec
  s$random$permanent <- list()
  expect_error(
    hsquared:::hs_validate_gllvm_optin_spec(gllvm_control(), s, f$payload),
    "animal"
  )
})

test_that("genetic GLLVM normalization preserves trait modes and labels its objective", {
  f <- gllvm_fixture()
  p <- f$payload
  G <- tcrossprod(matrix(c(1, .5, .3, 0, .7, .4), 3, 2))
  raw <- list(
    genetic_covariance = G,
    genetic_correlation = cov2cor(G),
    beta = matrix(1:3, 1),
    breeding_values = matrix(1:24, 8, 3),
    ids = p$ids,
    trait_names = p$metadata$trait_names,
    converged = TRUE,
    optimizer_converged = TRUE,
    mode_converged = TRUE,
    mode_gradient_norm = 1e-9,
    mode_iterations = 6L,
    mode_stop_reason = "gradient_tolerance",
    mode_backtracks = 0L,
    iterations = 9L,
    loglik = -42
  )
  out <- hsquared:::hs_normalize_gllvm_result(raw, p)
  fit <- hsquared:::hs_new_fit(
    spec = list(target = "genetic_gllvm"),
    payload = p,
    result = out
  )
  expect_equal(unname(genetic_covariance(fit)), G)
  expect_equal(breeding_values(fit)$value, as.numeric(raw$breeding_values))
  expect_equal(breeding_values(fit)$id, rep(p$ids, times = 3))
  expect_match(out$diagnostics$effect_scale, "link")
  expect_match(out$diagnostics$effect_summary, "conditional modes")
  expect_match(out$diagnostics$objective, "fixed effects")
  expect_true(out$diagnostics$optimizer_converged)
  expect_true(out$diagnostics$inner_mode_converged)
  expect_equal(out$diagnostics$inner_mode_gradient_norm, 1e-9)
  expect_equal(out$diagnostics$inner_mode_iterations, 6L)
  expect_equal(out$diagnostics$inner_mode_stop_reason, "gradient_tolerance")
  expect_equal(out$diagnostics$inner_mode_backtracks, 0L)
  diagnostics <- fit_diagnostics(fit)
  expect_true(all(
    c(
      "optimizer_converged",
      "inner_mode_converged",
      "inner_mode_gradient_norm",
      "inner_mode_iterations",
      "inner_mode_stop_reason",
      "inner_mode_backtracks"
    ) %in%
      diagnostics$metric
  ))
  malformed <- raw
  malformed$mode_gradient_norm <- Inf
  expect_error(hsquared:::hs_normalize_gllvm_result(malformed, p), "finite")
  malformed <- raw
  malformed$genetic_correlation[1, 1] <- Inf
  expect_error(hsquared:::hs_normalize_gllvm_result(malformed, p), "non-finite")
  malformed <- raw
  malformed$loglik <- c(-42, -43)
  expect_error(
    hsquared:::hs_normalize_gllvm_result(malformed, p),
    "one finite numeric value"
  )
  malformed <- raw
  malformed$loglik <- Inf
  expect_error(
    hsquared:::hs_normalize_gllvm_result(malformed, p),
    "one finite numeric value"
  )
  malformed <- raw
  malformed$converged <- FALSE
  expect_error(hsquared:::hs_normalize_gllvm_result(malformed, p), "combined")
  malformed <- raw
  malformed$genetic_covariance <- diag(c(-1, 1, 1))
  expect_error(
    hsquared:::hs_normalize_gllvm_result(malformed, p),
    "positive marginal variances"
  )
  malformed <- raw
  malformed$genetic_covariance <- matrix(
    c(1, -.8, -.8, -.8, 1, -.8, -.8, -.8, 1),
    3
  )
  expect_error(
    hsquared:::hs_normalize_gllvm_result(malformed, p),
    "positive semidefinite"
  )
  # A raw-scale eigenvalue tolerance must not hide invalid correlation
  # geometry when the traits have very different measurement units.
  scales <- c(1e8, 1, 1)
  invalid_correlation <- matrix(-.6, 3, 3)
  diag(invalid_correlation) <- 1
  malformed <- raw
  malformed$genetic_covariance <- outer(scales, scales) *
    invalid_correlation
  malformed$genetic_correlation <- invalid_correlation
  expect_error(
    hsquared:::hs_normalize_gllvm_result(malformed, p),
    "positive semidefinite"
  )
  malformed <- raw
  malformed$genetic_covariance[1, 2] <- malformed$genetic_covariance[1, 2] + .2
  expect_error(
    hsquared:::hs_normalize_gllvm_result(malformed, p),
    "genetic covariance must be symmetric"
  )
  malformed <- raw
  malformed$genetic_covariance <- diag(c(1e16, 1, 1))
  malformed$genetic_covariance[2, 3] <- .1
  malformed$genetic_correlation <- matrix(
    c(
      1,
      0,
      0,
      0,
      1,
      .05,
      0,
      .05,
      1
    ),
    3
  )
  expect_error(
    hsquared:::hs_normalize_gllvm_result(malformed, p),
    "genetic covariance must be symmetric"
  )
  malformed <- raw
  malformed$genetic_correlation <- diag(3) * 17
  expect_error(
    hsquared:::hs_normalize_gllvm_result(malformed, p),
    "genetic correlation must have a unit diagonal"
  )
  malformed <- raw
  malformed$genetic_correlation <- diag(3)
  expect_error(
    hsquared:::hs_normalize_gllvm_result(malformed, p),
    "inconsistent with genetic covariance"
  )
  expect_error(heritability(fit), "not defined")
  expect_error(stats::logLik(fit), "Laplace objective")
  expect_error(specific_variance(fit), "unavailable")
  expect_error(genetic_loadings(fit), "planned")
  perm <- c(3L, 1L, 2L)
  reordered <- p
  reordered$Y <- p$Y[, perm, drop = FALSE]
  reordered$metadata$trait_names <- p$metadata$trait_names[perm]
  reordered_raw <- raw
  reordered_raw$trait_names <- raw$trait_names[perm]
  reordered_raw$genetic_covariance <- raw$genetic_covariance[perm, perm]
  reordered_raw$genetic_correlation <- raw$genetic_correlation[perm, perm]
  reordered_raw$beta <- raw$beta[, perm, drop = FALSE]
  reordered_raw$breeding_values <- raw$breeding_values[, perm]
  reordered_result <- hsquared:::hs_normalize_gllvm_result(
    reordered_raw,
    reordered
  )
  expect_equal(
    reordered_result$genetic_covariance,
    out$genetic_covariance[perm, perm]
  )
  expect_equal(
    reordered_result$trait_genetic_modes,
    out$trait_genetic_modes[, perm]
  )
  expect_equal(
    reordered_result$breeding_values$trait,
    rep(p$metadata$trait_names[perm], each = length(p$ids))
  )
  wrong_traits <- raw
  wrong_traits$trait_names <- rev(raw$trait_names)
  expect_error(
    hsquared:::hs_normalize_gllvm_result(wrong_traits, p),
    "trait order does not match",
    fixed = TRUE
  )
  missing_traits <- raw
  missing_traits$trait_names <- NULL
  expect_error(
    hsquared:::hs_normalize_gllvm_result(missing_traits, p),
    "trait order does not match",
    fixed = TRUE
  )
  wrong_ids <- raw
  wrong_ids$ids <- rev(raw$ids)
  expect_error(
    hsquared:::hs_normalize_gllvm_result(wrong_ids, p),
    "pedigree IDs do not match",
    fixed = TRUE
  )
  raw$breeding_values <- matrix(1:16, 8, 2)
  expect_error(hsquared:::hs_normalize_gllvm_result(raw, p), "breeding")
  raw$breeding_values <- matrix(1:24, 8, 3)
  raw$converged <- FALSE
  raw$optimizer_converged <- FALSE
  out <- hsquared:::hs_normalize_gllvm_result(raw, p)
  expect_false(out$converged)
  expect_match(out$diagnostics$failure_message, "did not converge")
})

test_that("public genetic GLLVM call fails before Julia for invalid scope", {
  f <- gllvm_fixture()
  expect_error(
    hsquared(
      f$form,
      f$dat,
      family = poisson(),
      control = gllvm_control(rank = 1)
    ),
    "requires explicit"
  )
  expect_error(
    hsquared(
      f$form,
      f$dat,
      family = poisson(),
      control = gllvm_control(initial = matrix(0, 3, 2))
    ),
    "not honoured"
  )
  expect_error(
    hsquared(
      f$form,
      f$dat,
      family = poisson(),
      REML = FALSE,
      control = gllvm_control()
    ),
    "REML = TRUE"
  )
  f$dat$t1[1] <- NA_real_
  expect_error(
    hsquared(f$form, f$dat, family = poisson(), control = gllvm_control()),
    "complete"
  )
})

test_that("live genetic GLLVM agrees with direct same-input Julia fit", {
  hs_skip_live_julia()
  project <- hsquared:::hs_default_julia_project()
  skip_if_not(hsquared:::hs_julia_bridge_available(project))
  ped <- data.frame(
    id = paste0("a", 1:12),
    sire = NA_character_,
    dam = NA_character_
  )
  ped$sire[7:12] <- ped$id[1:6]
  dat <- data.frame(
    id = rev(ped$id),
    t1 = c(2, 6, 1, 8, 3, 5, 1, 6, 2, 7, 4, 3),
    t2 = c(4, 3, 7, 2, 5, 1, 8, 3, 6, 1, 4, 2),
    t3 = c(5, 8, 2, 9, 4, 6, 2, 7, 3, 8, 6, 4)
  )
  fit <- hsquared(
    cbind(t1, t2, t3) ~ animal(1 | id, pedigree = ped),
    data = dat,
    family = poisson(),
    control = gllvm_control(julia_project = project, iterations = 3000L)
  )
  expect_true(fit$result$converged)
  expect_equal(dim(fit$result$trait_genetic_modes), c(12L, 3L))
  expect_equal(colnames(genetic_covariance(fit)), c("t1", "t2", "t3"))
  expect_match(fit$payload$metadata$julia_fit_target, "fit_gllvm_laplace_reml")
  expect_null(fit$payload$metadata$julia_spec_target)
  expect_equal(
    JuliaCall::julia_eval("hsq_gllvm_Y"),
    unname(as.matrix(dat[match(ped$id, dat$id), c("t1", "t2", "t3")]))
  )
  expect_equal(as.character(JuliaCall::julia_eval("hsq_gllvm_ids")), ped$id)
  expect_equal(
    normalizePath(JuliaCall::julia_eval("Base.active_project()")),
    normalizePath(file.path(project, "Project.toml"))
  )
  JuliaCall::julia_command(paste(
    "hsq_gllvm_direct = HSquared.fit_gllvm_laplace_reml(hsq_gllvm_Y, hsq_Ainv,",
    "HSquared.PoissonResponse(); rank=2, structure=:lowrank, X=hsq_gllvm_X,",
    "trait_names=[\"t1\", \"t2\", \"t3\"],",
    "iterations=hsq_gllvm_iterations);",
    "hsq_gllvm_direct_raw = Dict(\"G\"=>hsq_gllvm_direct.genetic_covariance,",
    "\"Gcor\"=>hsq_gllvm_direct.latent_structure.genetic_correlation,",
    "\"beta\"=>hsq_gllvm_direct.beta, \"U\"=>hsq_gllvm_direct.breeding_values,",
    "\"objective\"=>hsq_gllvm_direct.loglik,",
    "\"optimizer_converged\"=>hsq_gllvm_direct.optimizer_converged,",
    "\"mode_converged\"=>hsq_gllvm_direct.mode_converged,",
    "\"mode_gradient_norm\"=>hsq_gllvm_direct.mode_gradient_norm,",
    "\"mode_iterations\"=>hsq_gllvm_direct.mode_iterations,",
    "\"mode_stop_reason\"=>string(hsq_gllvm_direct.mode_stop_reason),",
    "\"mode_backtracks\"=>hsq_gllvm_direct.mode_backtracks,",
    "\"trait_names\"=>hsq_gllvm_direct.trait_names);"
  ))
  direct <- JuliaCall::julia_eval("hsq_gllvm_direct_raw")
  expect_identical(as.character(direct$trait_names), c("t1", "t2", "t3"))
  tol <- 1e-8
  expect_lt(max(abs(unname(genetic_covariance(fit)) - direct$G)), tol)
  expect_lt(max(abs(unname(genetic_correlation(fit)) - direct$Gcor)), tol)
  expect_lt(max(abs(fixef(fit)$estimate - as.vector(direct$beta))), tol)
  expect_lt(max(abs(breeding_values(fit)$value - as.vector(direct$U))), tol)
  expect_lt(
    abs(fit$result$diagnostics$laplace_objective - direct$objective),
    tol
  )
  expect_identical(
    fit$result$diagnostics$optimizer_converged,
    direct$optimizer_converged
  )
  expect_identical(
    fit$result$diagnostics$inner_mode_converged,
    direct$mode_converged
  )
  expect_equal(
    fit$result$diagnostics$inner_mode_gradient_norm,
    direct$mode_gradient_norm,
    tolerance = tol
  )
  expect_equal(
    fit$result$diagnostics$inner_mode_iterations,
    direct$mode_iterations
  )
  expect_equal(
    fit$result$diagnostics$inner_mode_stop_reason,
    direct$mode_stop_reason
  )
  expect_equal(
    fit$result$diagnostics$inner_mode_backtracks,
    direct$mode_backtracks
  )
  expect_identical(fit$result$trait_names, c("t1", "t2", "t3"))

  permuted_fit <- hsquared(
    cbind(t3, t1, t2) ~ animal(1 | id, pedigree = ped),
    data = dat,
    family = poisson(),
    control = gllvm_control(julia_project = project, iterations = 3000L)
  )
  expect_true(permuted_fit$result$converged)
  expect_identical(permuted_fit$result$trait_names, c("t3", "t1", "t2"))
  expect_identical(
    colnames(genetic_covariance(permuted_fit)),
    c("t3", "t1", "t2")
  )
  expect_identical(
    colnames(permuted_fit$result$trait_genetic_modes),
    c("t3", "t1", "t2")
  )
  trait_order <- c(3L, 1L, 2L)
  expect_equal(
    genetic_covariance(permuted_fit),
    genetic_covariance(fit)[trait_order, trait_order],
    tolerance = 1e-4
  )
  expect_equal(
    genetic_correlation(permuted_fit),
    genetic_correlation(fit)[trait_order, trait_order],
    tolerance = 1e-5
  )
  expect_identical(
    rownames(permuted_fit$result$trait_genetic_modes),
    rownames(fit$result$trait_genetic_modes)
  )
  expect_equal(
    permuted_fit$result$trait_genetic_modes,
    fit$result$trait_genetic_modes[, trait_order, drop = FALSE],
    tolerance = 5e-5
  )
  expect_equal(
    fixef(permuted_fit)$estimate,
    fixef(fit)$estimate[trait_order],
    tolerance = 1e-5
  )
  expect_identical(fixef(permuted_fit)$trait, c("t3", "t1", "t2"))
  expect_equal(
    permuted_fit$result$diagnostics$laplace_objective,
    fit$result$diagnostics$laplace_objective,
    tolerance = 5e-5
  )
  expect_error(heritability(fit), "not defined")
  expect_error(stats::logLik(fit), "Laplace objective")
})

test_that("covariance-correlation validation scales with trait units", {
  for (scale in c(1e-200, 1.7e308)) {
    covariance <- diag(2) * scale
    expect_true(hsquared:::hs_validate_covariance_correlation(
      covariance,
      diag(2),
      "test"
    ))
  }

  # Rank-two genetic covariance remains valid after heterogeneous changes of
  # trait units, even when one variance dominates the raw covariance scale.
  loadings <- matrix(c(1, 0, .5, 1, .3, .7), nrow = 3, ncol = 2)
  base_covariance <- tcrossprod(loadings)
  trait_scale <- c(1e8, 1, 1)
  covariance <- sweep(
    sweep(base_covariance, 1L, trait_scale, "*"),
    2L,
    trait_scale,
    "*"
  )
  expect_true(hsquared:::hs_validate_covariance_correlation(
    covariance,
    stats::cov2cor(covariance),
    "GLLVM",
    allow_semidefinite = TRUE
  ))
})
