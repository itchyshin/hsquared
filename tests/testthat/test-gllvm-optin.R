gllvm_control <- function(...) {
  values <- modifyList(list(target = "genetic_gllvm", genetic_structure = "lowrank",
    rank = 2L, experimental_gllvm = TRUE, julia_project = "/tmp/HSquared.jl"), list(...))
  hs_control(engine = "julia", engine_control = values)
}
gllvm_fixture <- function() {
  ped <- data.frame(id = letters[1:8], sire = NA_character_, dam = NA_character_)
  dat <- data.frame(id = rev(ped$id), t1 = 1:8, t2 = 2:9, t3 = 3:10)
  form <- cbind(t1, t2, t3) ~ animal(1 | id, pedigree = ped)
  spec <- hsquared:::hs_build_model_spec(form, dat, poisson(), TRUE,
                                        allow_families = "poisson")
  list(ped = ped, dat = dat, form = form, spec = spec,
       payload = hsquared:::hs_build_bridge_payload(spec))
}

test_that("genetic GLLVM requires explicit bounded expert controls", {
  f <- gllvm_fixture()
  expect_equal(hsquared:::hs_validate_gllvm_optin_spec(
    gllvm_control(), f$spec, f$payload), 8:1)
  for (change in list(list(rank = 1L), list(rank = 2.5),
      list(genetic_structure = "factor_analytic"), list(experimental_gllvm = FALSE),
      list(julia_project = ""))) {
    expect_error(hsquared:::hs_validate_gllvm_optin_spec(
      do.call(gllvm_control, change), f$spec, f$payload), "requires")
  }
  ctl <- gllvm_control(); ctl$engine <- "fit"
  expect_error(hsquared:::hs_validate_gllvm_optin_spec(ctl, f$spec, f$payload), "explicit")
  expect_error(hsquared:::hs_engine_control_forwarding(
    gllvm_control(initial_uniqueness = rep(1, 3)), "genetic_gllvm"), "initial_uniqueness")
})

test_that("genetic GLLVM rejects missing counts, wider models, and incomplete pedigrees", {
  f <- gllvm_fixture()
  for (bad in list(NA_real_, -1, 0.5, Inf)) {
    p <- f$payload; p$Y[1, 1] <- bad
    expect_error(hsquared:::hs_validate_gllvm_optin_spec(gllvm_control(), f$spec, p), "complete|integer")
  }
  p <- f$payload; p$Y[, 1] <- 0
  expect_error(hsquared:::hs_validate_gllvm_optin_spec(gllvm_control(), f$spec, p), "all-zero")
  p <- f$payload; p$Y <- p$Y[, 1:2]
  expect_error(hsquared:::hs_validate_gllvm_optin_spec(gllvm_control(), f$spec, p), "three traits")
  p <- f$payload; p$X <- cbind(p$X, seq_len(8))
  expect_error(hsquared:::hs_validate_gllvm_optin_spec(gllvm_control(), f$spec, p), "intercepts")
  p <- f$payload; p$Z[1, ] <- p$Z[2, ]
  expect_error(hsquared:::hs_validate_gllvm_optin_spec(gllvm_control(), f$spec, p), "one complete row")
  s <- f$spec; s$family <- list(family = "binomial", link = "logit")
  expect_error(hsquared:::hs_validate_gllvm_optin_spec(gllvm_control(), s, f$payload), "Poisson")
  s <- f$spec; s$random$permanent <- list()
  expect_error(hsquared:::hs_validate_gllvm_optin_spec(gllvm_control(), s, f$payload), "animal")
})

test_that("genetic GLLVM normalization preserves trait modes and labels its objective", {
  f <- gllvm_fixture(); p <- f$payload
  G <- tcrossprod(matrix(c(1, .5, .3, 0, .7, .4), 3, 2))
  raw <- list(genetic_covariance = G, genetic_correlation = cov2cor(G),
    beta = matrix(1:3, 1), breeding_values = matrix(1:24, 8, 3),
    ids = p$ids, converged = TRUE, iterations = 9L, loglik = -42)
  out <- hsquared:::hs_normalize_gllvm_result(raw, p)
  fit <- hsquared:::hs_new_fit(spec = list(target = "genetic_gllvm"), payload = p, result = out)
  expect_equal(unname(genetic_covariance(fit)), G)
  expect_equal(breeding_values(fit)$value, as.numeric(raw$breeding_values))
  expect_equal(breeding_values(fit)$id, rep(p$ids, times = 3))
  expect_match(out$diagnostics$effect_scale, "link")
  expect_match(out$diagnostics$effect_summary, "conditional modes")
  expect_match(out$diagnostics$objective, "fixed effects")
  expect_error(heritability(fit), "not defined")
  expect_error(stats::logLik(fit), "Laplace objective")
  expect_error(specific_variance(fit), "unavailable")
  expect_error(genetic_loadings(fit), "planned")
  perm <- c(3L, 1L, 2L)
  reordered <- p
  reordered$Y <- p$Y[, perm, drop = FALSE]
  reordered$metadata$trait_names <- p$metadata$trait_names[perm]
  reordered_raw <- raw
  reordered_raw$genetic_covariance <- raw$genetic_covariance[perm, perm]
  reordered_raw$genetic_correlation <- raw$genetic_correlation[perm, perm]
  reordered_raw$beta <- raw$beta[, perm, drop = FALSE]
  reordered_raw$breeding_values <- raw$breeding_values[, perm]
  reordered_result <- hsquared:::hs_normalize_gllvm_result(reordered_raw, reordered)
  expect_equal(reordered_result$genetic_covariance,
               out$genetic_covariance[perm, perm])
  expect_equal(reordered_result$trait_genetic_modes,
               out$trait_genetic_modes[, perm])
  expect_equal(reordered_result$breeding_values$trait,
               rep(p$metadata$trait_names[perm], each = length(p$ids)))
  wrong_ids <- raw
  wrong_ids$ids <- rev(raw$ids)
  expect_error(hsquared:::hs_normalize_gllvm_result(wrong_ids, p),
               "pedigree IDs do not match", fixed = TRUE)
  raw$breeding_values <- matrix(1:16, 8, 2)
  expect_error(hsquared:::hs_normalize_gllvm_result(raw, p), "breeding")
  raw$breeding_values <- matrix(1:24, 8, 3); raw$converged <- FALSE
  out <- hsquared:::hs_normalize_gllvm_result(raw, p)
  expect_false(out$converged)
  expect_match(out$diagnostics$failure_message, "did not converge")
})

test_that("public genetic GLLVM call fails before Julia for invalid scope", {
  f <- gllvm_fixture()
  expect_error(hsquared(f$form, f$dat, family = poisson(),
    control = gllvm_control(rank = 1)), "requires explicit")
  expect_error(hsquared(f$form, f$dat, family = poisson(), REML = FALSE,
    control = gllvm_control()), "REML = TRUE")
  f$dat$t1[1] <- NA_real_
  expect_error(hsquared(f$form, f$dat, family = poisson(),
    control = gllvm_control()), "complete")
})

test_that("live genetic GLLVM agrees with direct same-input Julia fit", {
  hs_skip_live_julia()
  project <- hsquared:::hs_default_julia_project()
  skip_if_not(hsquared:::hs_julia_bridge_available(project))
  ped <- data.frame(id = paste0("a", 1:12), sire = NA_character_, dam = NA_character_)
  ped$sire[7:12] <- ped$id[1:6]
  dat <- data.frame(id = rev(ped$id),
    t1 = c(2, 6, 1, 8, 3, 5, 1, 6, 2, 7, 4, 3),
    t2 = c(4, 3, 7, 2, 5, 1, 8, 3, 6, 1, 4, 2),
    t3 = c(5, 8, 2, 9, 4, 6, 2, 7, 3, 8, 6, 4))
  fit <- hsquared(cbind(t1, t2, t3) ~ animal(1 | id, pedigree = ped),
    data = dat, family = poisson(),
    control = gllvm_control(julia_project = project, iterations = 3000L))
  expect_true(fit$result$converged)
  expect_equal(dim(fit$result$trait_genetic_modes), c(12L, 3L))
  expect_equal(colnames(genetic_covariance(fit)), c("t1", "t2", "t3"))
  expect_match(fit$payload$metadata$julia_fit_target, "fit_gllvm_laplace_reml")
  expect_null(fit$payload$metadata$julia_spec_target)
  expect_equal(JuliaCall::julia_eval("hsq_gllvm_Y"),
               unname(as.matrix(dat[match(ped$id, dat$id), c("t1", "t2", "t3")])))
  expect_equal(as.character(JuliaCall::julia_eval("hsq_gllvm_ids")), ped$id)
  expect_equal(normalizePath(JuliaCall::julia_eval("Base.active_project()")),
               normalizePath(file.path(project, "Project.toml")))
  JuliaCall::julia_command(paste(
    "hsq_gllvm_direct = HSquared.fit_gllvm_laplace_reml(hsq_gllvm_Y, hsq_Ainv,",
    "HSquared.PoissonResponse(); rank=2, structure=:lowrank, X=hsq_gllvm_X,",
    "iterations=hsq_gllvm_iterations);",
    "hsq_gllvm_direct_raw = Dict(\"G\"=>hsq_gllvm_direct.genetic_covariance,",
    "\"Gcor\"=>hsq_gllvm_direct.latent_structure.genetic_correlation,",
    "\"beta\"=>hsq_gllvm_direct.beta, \"U\"=>hsq_gllvm_direct.breeding_values,",
    "\"objective\"=>hsq_gllvm_direct.loglik);"
  ))
  direct <- JuliaCall::julia_eval("hsq_gllvm_direct_raw")
  tol <- 1e-8
  expect_lt(max(abs(unname(genetic_covariance(fit)) - direct$G)), tol)
  expect_lt(max(abs(unname(genetic_correlation(fit)) - direct$Gcor)), tol)
  expect_lt(max(abs(fixef(fit)$estimate - as.vector(direct$beta))), tol)
  expect_lt(max(abs(breeding_values(fit)$value - as.vector(direct$U))), tol)
  expect_lt(abs(fit$result$diagnostics$laplace_objective - direct$objective), tol)
  expect_error(heritability(fit), "not defined")
  expect_error(stats::logLik(fit), "Laplace objective")
})
