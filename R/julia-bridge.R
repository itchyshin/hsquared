hs_julia_bridge_state <- new.env(parent = emptyenv())

hs_default_julia_project <- function() {
  env <- Sys.getenv("HSQUARED_JULIA_PROJECT", unset = "")
  if (nzchar(env)) {
    return(env)
  }

  normalizePath(
    file.path(dirname(system.file(package = "hsquared")), "HSquared.jl"),
    winslash = "/",
    mustWork = FALSE
  )
}

hs_julia_bridge_available <- function(project = hs_default_julia_project()) {
  requireNamespace("JuliaCall", quietly = TRUE) &&
    nzchar(Sys.which("julia")) &&
    file.exists(file.path(project, "Project.toml"))
}

hs_julia_attach_standard_plot_data <- function() {
  JuliaCall::julia_command(paste(
    "if isdefined(HSquared, :variance_components_plot_data);",
    "hsq_vcpd = try; HSquared.variance_components_plot_data(hsq_fit);",
    "catch; nothing; end;",
    "if hsq_vcpd !== nothing;",
    "hsq_result = merge(hsq_result, (",
    "variance_components_plot_data = hsq_vcpd,));",
    "end;",
    "end;",
    "if isdefined(HSquared, :breeding_values_plot_data);",
    "hsq_bvpd = try; HSquared.breeding_values_plot_data(hsq_fit);",
    "catch; nothing; end;",
    "if hsq_bvpd !== nothing;",
    "hsq_result = merge(hsq_result, (breeding_values_plot_data = hsq_bvpd,));",
    "end;",
    "end;"
  ))
  invisible(TRUE)
}

hs_fit_julia_payload <- function(
  payload,
  project = hs_default_julia_project(),
  initial = c(sigma_a2 = 1, sigma_e2 = 1)
) {
  if (!inherits(payload, "hs_bridge_payload")) {
    stop("`payload` must be an internal `hs_bridge_payload`.", call. = FALSE)
  }
  if (!hs_julia_bridge_available(project)) {
    stop(
      "The experimental Julia bridge requires Julia, the `JuliaCall` R ",
      "package, and a local `HSquared.jl` project.",
      call. = FALSE
    )
  }

  hs_julia_setup(project)
  initial <- hs_validate_initial_variances(initial)
  hs_julia_assign_payload(payload, initial)
  JuliaCall::julia_command(paste(
    "hsq_ped = HSquared.normalize_pedigree(hsq_id, hsq_sire, hsq_dam);",
    "hsq_Ainv = HSquared.pedigree_inverse(hsq_ped);",
    "hsq_fit = HSquared.fit_animal_model(",
    "hsq_y, hsq_X, hsq_Z, hsq_Ainv;",
    "ids = hsq_ped.ids,",
    "method = Symbol(hsq_method),",
    "initial = (sigma_a2 = hsq_initial_sigma_a2,",
    "sigma_e2 = hsq_initial_sigma_e2)",
    ");",
    "hsq_result = HSquared.result_payload(hsq_fit);",
    # Enrich with PEV/reliability only for older engines whose result_payload
    # does not already carry them; current engines emit them via :selinv, and
    # re-merging would clobber that standard field with a redundant :dense solve.
    "if !hasproperty(hsq_result, :prediction_error_variance) &&",
    "isdefined(HSquared, :prediction_error_variance) &&",
    "isdefined(HSquared, :reliability);",
    "hsq_result = merge(hsq_result, (",
    "prediction_error_variance =",
    "HSquared.prediction_error_variance(hsq_fit),",
    "reliability = HSquared.reliability(hsq_fit)));",
    "end;"
  ))
  hs_julia_attach_standard_plot_data()

  raw <- JuliaCall::julia_eval(
    "Dict(String(k) => getfield(hsq_result, k) for k in keys(hsq_result))"
  )
  result <- hs_normalize_julia_result(raw, payload)
  hs_new_fit(
    spec = list(
      method = payload$method,
      family = list(family = payload$family, link = "identity")
    ),
    payload = payload,
    result = result,
    engine = "HSquared.jl"
  )
}

hs_fit_julia_henderson_mme_payload <- function(
  payload,
  project = hs_default_julia_project(),
  variance_components
) {
  if (!inherits(payload, "hs_bridge_payload")) {
    stop("`payload` must be an internal `hs_bridge_payload`.", call. = FALSE)
  }
  if (!hs_julia_bridge_available(project)) {
    stop(
      "The experimental Julia bridge requires Julia, the `JuliaCall` R ",
      "package, and a local `HSquared.jl` project.",
      call. = FALSE
    )
  }

  variance_components <- hs_validate_supplied_variances(variance_components)
  hs_julia_setup(project)
  hs_julia_assign_payload(payload, variance_components)
  JuliaCall::julia_assign(
    "hsq_supplied_sigma_a2",
    unname(variance_components[["sigma_a2"]])
  )
  JuliaCall::julia_assign(
    "hsq_supplied_sigma_e2",
    unname(variance_components[["sigma_e2"]])
  )
  JuliaCall::julia_command(paste(
    "hsq_ped = HSquared.normalize_pedigree(hsq_id, hsq_sire, hsq_dam);",
    "hsq_Ainv = HSquared.pedigree_inverse(hsq_ped);",
    "hsq_spec = HSquared.animal_model_spec(",
    "hsq_y, hsq_X, hsq_Z, hsq_Ainv;",
    "ids = hsq_ped.ids, method = Symbol(hsq_method));",
    "hsq_mme = HSquared.henderson_mme(",
    "hsq_spec, hsq_supplied_sigma_a2, hsq_supplied_sigma_e2);",
    "hsq_mme_bv = HSquared.breeding_values(hsq_mme);",
    "hsq_mme_raw = Dict(",
    "\"fixed_effects\" => HSquared.fixed_effects(hsq_mme),",
    "\"animal_ids\" => hsq_mme_bv.ids,",
    "\"animal_effects\" => hsq_mme_bv.values,",
    "\"fitted\" => HSquared.fitted_values(hsq_mme),",
    # PEV/reliability are now standard on the Henderson MME result (dense,
    # validation-scale): prediction_error_variance/reliability default to
    # method = :dense, so they are attached unconditionally rather than probed.
    "\"prediction_error_variance\" =>",
    "HSquared.prediction_error_variance(hsq_mme),",
    "\"reliability\" => HSquared.reliability(hsq_mme),",
    "\"nobs\" => length(hsq_y)",
    ");"
  ))

  raw <- JuliaCall::julia_eval("hsq_mme_raw")
  result <- hs_normalize_julia_henderson_mme_result(
    raw,
    payload,
    variance_components
  )
  hs_new_fit(
    spec = list(
      method = payload$method,
      family = list(family = payload$family, link = "identity"),
      target = "henderson_mme"
    ),
    payload = payload,
    result = result,
    engine = "HSquared.jl"
  )
}

hs_fit_julia_metafounder_payload <- function(
  payload,
  project = hs_default_julia_project(),
  variance_components
) {
  if (!inherits(payload, "hs_bridge_payload")) {
    stop("`payload` must be an internal `hs_bridge_payload`.", call. = FALSE)
  }
  if (
    !identical(payload$relationship_source, "metafounder") ||
      is.null(payload$group_of) ||
      is.null(payload$Gamma)
  ) {
    stop(
      "Internal bridge error: the metafounder payload is incomplete ",
      "(needs group_of and Gamma).",
      call. = FALSE
    )
  }
  variance_components <- hs_validate_supplied_variances(
    variance_components,
    target = "metafounder"
  )
  if (!hs_julia_bridge_available(project)) {
    stop(
      "The experimental Julia bridge requires Julia, the `JuliaCall` R ",
      "package, and a local `HSquared.jl` project.",
      call. = FALSE
    )
  }

  hs_julia_setup(project)
  hs_julia_assign_payload(payload, variance_components)
  JuliaCall::julia_assign("hsq_group_of", unname(payload$group_of))
  JuliaCall::julia_assign("hsq_Gamma_vec", as.numeric(payload$Gamma))
  JuliaCall::julia_assign("hsq_Gamma_n", as.integer(nrow(payload$Gamma)))
  JuliaCall::julia_assign(
    "hsq_supplied_sigma_a2",
    unname(variance_components[["sigma_a2"]])
  )
  JuliaCall::julia_assign(
    "hsq_supplied_sigma_e2",
    unname(variance_components[["sigma_e2"]])
  )
  JuliaCall::julia_command(paste(
    "hsq_ped = HSquared.normalize_pedigree(hsq_id, hsq_sire, hsq_dam);",
    "collect(String, hsq_ped.ids) == hsq_id ||",
    "error(\"metafounder: engine pedigree order != R order\");",
    "hsq_Gamma = reshape(collect(Float64, hsq_Gamma_vec),",
    "Int(hsq_Gamma_n), Int(hsq_Gamma_n));",
    "hsq_mme = HSquared.metafounder_animal_model(",
    "hsq_y, hsq_X, hsq_Z, hsq_ped, hsq_group_of, hsq_Gamma,",
    "hsq_supplied_sigma_a2, hsq_supplied_sigma_e2;",
    "ids = hsq_ped.ids);",
    "hsq_mme_bv = HSquared.breeding_values(hsq_mme);",
    "hsq_mme_raw = Dict(",
    "\"fixed_effects\" => HSquared.fixed_effects(hsq_mme),",
    "\"animal_ids\" => hsq_mme_bv.ids,",
    "\"animal_effects\" => hsq_mme_bv.values,",
    "\"fitted\" => HSquared.fitted_values(hsq_mme),",
    "\"prediction_error_variance\" =>",
    "HSquared.prediction_error_variance(hsq_mme),",
    "\"reliability\" => HSquared.reliability(hsq_mme),",
    "\"nobs\" => length(hsq_y)",
    ");"
  ))

  raw <- JuliaCall::julia_eval("hsq_mme_raw")
  result <- hs_normalize_julia_henderson_mme_result(
    raw,
    payload,
    variance_components
  )
  result$variance_components$component[
    result$variance_components$component == "animal"
  ] <- "metafounder"
  result$heritability$term[result$heritability$term == "animal"] <-
    "metafounder"
  names(result$random_effects)[
    names(result$random_effects) == "animal"
  ] <- "metafounder"
  result$diagnostics$target <- "metafounder"
  result$diagnostics$variance_components <- "supplied_metafounder"
  result$diagnostics$gamma_source <- "supplied"
  hs_new_fit(
    spec = list(
      method = payload$method,
      family = list(family = payload$family, link = "identity"),
      target = "metafounder"
    ),
    payload = payload,
    result = result,
    engine = "HSquared.jl"
  )
}

hs_fit_julia_sparse_reml_payload <- function(
  payload,
  project = hs_default_julia_project(),
  initial = c(sigma_a2 = 1, sigma_e2 = 1),
  iterations = 1000L
) {
  if (!inherits(payload, "hs_bridge_payload")) {
    stop("`payload` must be an internal `hs_bridge_payload`.", call. = FALSE)
  }
  if (!hs_julia_bridge_available(project)) {
    stop(
      "The experimental Julia bridge requires Julia, the `JuliaCall` R ",
      "package, and a local `HSquared.jl` project.",
      call. = FALSE
    )
  }

  initial <- hs_validate_initial_variances(initial)
  iterations <- hs_validate_iterations(iterations)
  hs_julia_setup(project)
  hs_julia_assign_payload(payload, initial)
  JuliaCall::julia_assign("hsq_iterations", iterations)
  JuliaCall::julia_command(paste(
    "hsq_ped = HSquared.normalize_pedigree(hsq_id, hsq_sire, hsq_dam);",
    "hsq_Ainv = HSquared.pedigree_inverse(hsq_ped);",
    "hsq_spec = HSquared.animal_model_spec(",
    "hsq_y, hsq_X, hsq_Z, hsq_Ainv;",
    "ids = hsq_ped.ids, method = :REML);",
    "hsq_fit = HSquared.fit_sparse_reml(",
    "hsq_spec;",
    "initial = (sigma_a2 = hsq_initial_sigma_a2,",
    "sigma_e2 = hsq_initial_sigma_e2),",
    "iterations = hsq_iterations);",
    "hsq_result = HSquared.result_payload(hsq_fit);",
    # Enrich with PEV/reliability only for older engines whose result_payload
    # does not already carry them; current engines emit them via :selinv, and
    # re-merging would clobber that standard field with a redundant :dense solve.
    "if !hasproperty(hsq_result, :prediction_error_variance) &&",
    "isdefined(HSquared, :prediction_error_variance) &&",
    "isdefined(HSquared, :reliability) &&",
    "applicable(HSquared.prediction_error_variance, hsq_fit) &&",
    "applicable(HSquared.reliability, hsq_fit);",
    "hsq_result = merge(hsq_result, (",
    "prediction_error_variance =",
    "HSquared.prediction_error_variance(hsq_fit),",
    "reliability = HSquared.reliability(hsq_fit)));",
    "end;"
  ))
  hs_julia_attach_standard_plot_data()

  raw <- JuliaCall::julia_eval(
    "Dict(String(k) => getfield(hsq_result, k) for k in keys(hsq_result))"
  )
  result <- hs_normalize_julia_result(raw, payload)
  result$diagnostics$variance_components <- "estimated_sparse_reml"
  hs_new_fit(
    spec = list(
      # fit_sparse_reml is a REML-only optimizer; stamp what was computed
      # rather than echoing the requested method.
      method = "REML",
      family = list(family = payload$family, link = "identity"),
      target = "sparse_reml"
    ),
    payload = payload,
    result = result,
    engine = "HSquared.jl"
  )
}

hs_fit_julia_ai_reml_payload <- function(
  payload,
  project = hs_default_julia_project(),
  initial = c(sigma_a2 = 1, sigma_e2 = 1),
  iterations = 100L,
  em_warmup = 0L
) {
  if (!inherits(payload, "hs_bridge_payload")) {
    stop("`payload` must be an internal `hs_bridge_payload`.", call. = FALSE)
  }
  if (!hs_julia_bridge_available(project)) {
    stop(
      "The experimental Julia bridge requires Julia, the `JuliaCall` R ",
      "package, and a local `HSquared.jl` project.",
      call. = FALSE
    )
  }

  initial <- hs_validate_initial_variances(initial)
  iterations <- hs_validate_iterations(iterations)
  em_warmup <- hs_validate_em_warmup(em_warmup)
  hs_julia_setup(project)
  hs_julia_assign_payload(payload, initial)
  JuliaCall::julia_assign("hsq_iterations", iterations)
  JuliaCall::julia_assign("hsq_em_warmup", em_warmup)
  JuliaCall::julia_command(paste(
    "hsq_ped = HSquared.normalize_pedigree(hsq_id, hsq_sire, hsq_dam);",
    "hsq_Ainv = HSquared.pedigree_inverse(hsq_ped);",
    "hsq_spec = HSquared.animal_model_spec(",
    "hsq_y, hsq_X, hsq_Z, hsq_Ainv;",
    "ids = hsq_ped.ids, method = :REML);",
    "hsq_fit = HSquared.fit_ai_reml(",
    "hsq_spec;",
    "initial = (sigma_a2 = hsq_initial_sigma_a2,",
    "sigma_e2 = hsq_initial_sigma_e2),",
    # em_warmup (engine V1-AI-REML): opt-in EM-REML warm-start before the AI step;
    # default 0 = byte-identical to the pre-warm-start engine call.
    "iterations = hsq_iterations, em_warmup = hsq_em_warmup);",
    "hsq_result = HSquared.result_payload(hsq_fit);",
    # Enrich with PEV/reliability only for older engines whose result_payload
    # does not already carry them; current engines emit them via :selinv, and
    # re-merging would clobber that standard field with a redundant :dense solve.
    "if !hasproperty(hsq_result, :prediction_error_variance) &&",
    "isdefined(HSquared, :prediction_error_variance) &&",
    "isdefined(HSquared, :reliability) &&",
    "applicable(HSquared.prediction_error_variance, hsq_fit) &&",
    "applicable(HSquared.reliability, hsq_fit);",
    "hsq_result = merge(hsq_result, (",
    "prediction_error_variance =",
    "HSquared.prediction_error_variance(hsq_fit),",
    "reliability = HSquared.reliability(hsq_fit)));",
    "end;",
    # Experimental, opt-in heritability CI (engine row V1-HERIT-CI, partial).
    # Guarded by a try: the engine throws when h2 is on the (0, 1) boundary,
    # which must not abort the fit.
    "if isdefined(HSquared, :heritability_interval) &&",
    "applicable(HSquared.heritability_interval, hsq_fit);",
    "hsq_hi = try; HSquared.heritability_interval(hsq_fit); catch; nothing; end;",
    "if hsq_hi !== nothing;",
    "hsq_result = merge(hsq_result, (heritability_interval = hsq_hi,));",
    "end;",
    "end;",
    # Experimental, opt-in variance-component and heritability standard errors
    # (engine row V1-HERIT-CI, partial). variance_component_covariance() can
    # throw on a singular/ill-conditioned AI matrix, so each call is wrapped in
    # a try so an SE failure never aborts the fit.
    "if isdefined(HSquared, :variance_component_standard_errors) &&",
    "applicable(HSquared.variance_component_standard_errors, hsq_fit);",
    "hsq_vcse = try; HSquared.variance_component_standard_errors(hsq_fit); catch; nothing; end;",
    "if hsq_vcse !== nothing;",
    "hsq_result = merge(hsq_result, (variance_component_se = hsq_vcse,));",
    "end;",
    "end;",
    "if isdefined(HSquared, :heritability_standard_error) &&",
    "applicable(HSquared.heritability_standard_error, hsq_fit);",
    "hsq_h2se = try; HSquared.heritability_standard_error(hsq_fit); catch; nothing; end;",
    "if hsq_h2se !== nothing;",
    "hsq_result = merge(hsq_result, (heritability_se = hsq_h2se,));",
    "end;",
    "end;"
  ))
  hs_julia_attach_standard_plot_data()

  raw <- JuliaCall::julia_eval(
    "Dict(String(k) => getfield(hsq_result, k) for k in keys(hsq_result))"
  )
  result <- hs_normalize_julia_result(raw, payload)
  result$diagnostics$variance_components <- "estimated_ai_reml"
  hs_new_fit(
    spec = list(
      # fit_ai_reml is a REML-only (average-information) optimizer; stamp what
      # was computed rather than echoing the requested method.
      method = "REML",
      family = list(family = payload$family, link = "identity"),
      target = "ai_reml"
    ),
    payload = payload,
    result = result,
    engine = "HSquared.jl"
  )
}

# Map an R `family` object to the engine's non-Gaussian family symbol:
# `poisson(log)` -> "poisson"; `binomial(logit)` -> "bernoulli" for a binary 0/1
# response (or an all-ones `cbind` total), or "binomial" when any per-record trial
# count in `n_trials` exceeds 1 (a `cbind(successes, failures)` counts response;
# `n_trials` may be a per-record vector). Other families are planned. The rule is
# vector-safe: `any(n_trials > 1L)`, so a vector whose first element is 1 (e.g.
# c(1, 4, 5)) is still classified Binomial, not silently reduced to Bernoulli.
hs_nongaussian_family_symbol <- function(family, n_trials = NULL) {
  if (identical(family$family, "poisson") && identical(family$link, "log")) {
    return("poisson")
  }
  if (identical(family$family, "binomial") && identical(family$link, "logit")) {
    if (!is.null(n_trials) && any(n_trials > 1L)) {
      return("binomial")
    }
    return("bernoulli")
  }
  stop(
    "The opt-in non-Gaussian target fits `poisson(log)` and `binomial(logit)` ",
    "(binary 0/1, or `cbind(successes, failures)` counts) only; `",
    hs_family_label(family),
    "` is not implemented. Other families are planned.",
    call. = FALSE
  )
}

# Resolve the non-Gaussian marginal-method name to the engine's canonical symbol.
# "laplace" (the Laplace approximation; default) and "variational" (the
# variational/ELBO marginal) are accepted, with the DRM-style short spellings
# "la"/"va" as aliases (the engine itself accepts :laplace/:LA and
# :variational/:VA). Both objectives are engine-validated (row V6-LAPLACE/VA).
hs_validate_marginal_method <- function(marginal) {
  if (is.null(marginal)) {
    return("laplace")
  }
  canon <- switch(
    tolower(as.character(marginal)),
    laplace = "laplace",
    la = "laplace",
    variational = "variational",
    va = "variational",
    NULL
  )
  if (is.null(canon)) {
    stop(
      "`engine_control$marginal` must be \"laplace\" (Laplace approximation) or ",
      "\"variational\" (variational/ELBO; aliases \"la\"/\"va\"); got `",
      as.character(marginal),
      "`.",
      call. = FALSE
    )
  }
  canon
}

# Opt-in, experimental non-Gaussian (GLMM) animal model. Surfaces the
# Julia-owned `HSquared.fit_laplace_reml()` REML optimizer for a
# `poisson`/`bernoulli` response on the latent scale, over either the Laplace
# (`marginal = "laplace"`, default) or variational (`marginal = "variational"`)
# marginal. There is no residual-variance scale for these families, so the result
# deliberately carries NO heritability. Experimental, REML-only, not
# coverage-calibrated (mirrors the engine row V6-LAPLACE/VA, partial); the VA
# objective is the ELBO (a lower bound on the marginal log-likelihood, so VA and
# Laplace `logLik`/`AIC` are NOT comparable); Bernoulli `sigma_a2` is prone to a
# search-bound boundary at small scale.
hs_fit_julia_nongaussian_payload <- function(
  payload,
  project = hs_default_julia_project(),
  family = stats::binomial(),
  marginal = "laplace",
  iterations = 200L
) {
  if (!inherits(payload, "hs_bridge_payload")) {
    stop("`payload` must be an internal `hs_bridge_payload`.", call. = FALSE)
  }
  if (is.null(payload$pedigree)) {
    stop(
      "Internal bridge error: the non-Gaussian target requires a pedigree ",
      "animal-model payload.",
      call. = FALSE
    )
  }
  if (!hs_julia_bridge_available(project)) {
    stop(
      "The experimental Julia bridge requires Julia, the `JuliaCall` R ",
      "package, and a local `HSquared.jl` project.",
      call. = FALSE
    )
  }

  n_trials <- payload$n_trials
  family_symbol <- hs_nongaussian_family_symbol(family, n_trials)
  marginal <- hs_validate_marginal_method(marginal)
  iterations <- hs_validate_iterations(iterations)
  hs_julia_setup(project)
  JuliaCall::julia_assign("hsq_y", payload$y)
  JuliaCall::julia_assign("hsq_X", payload$X)
  hs_julia_assign_sparse_csc("hsq_Z", payload$Z)
  JuliaCall::julia_assign("hsq_id", payload$pedigree$id)
  JuliaCall::julia_assign(
    "hsq_sire",
    hs_parent_for_julia(payload$pedigree$sire)
  )
  JuliaCall::julia_assign("hsq_dam", hs_parent_for_julia(payload$pedigree$dam))
  JuliaCall::julia_assign("hsq_family", family_symbol)
  JuliaCall::julia_assign("hsq_marginal", marginal)
  JuliaCall::julia_assign("hsq_iterations", iterations)
  # A binomial-counts response carries per-record trial counts; the engine's
  # BinomialResponse takes them via the n_trials keyword (Bernoulli == all-ones,
  # so the keyword is omitted for every non-binomial family). When every record
  # shares one trial count we pass the scalar (the live-verified common-trial
  # path); a genuinely varying vector is passed as a Vector{Int} (the per-record
  # path, R-side parsed/tested but verified live separately).
  n_trials_kw <- ""
  if (identical(family_symbol, "binomial")) {
    n_trials_int <- as.integer(n_trials)
    if (length(unique(n_trials_int)) == 1L) {
      JuliaCall::julia_assign("hsq_n_trials", n_trials_int[[1L]])
      n_trials_kw <- "n_trials = Int(hsq_n_trials), "
    } else {
      JuliaCall::julia_assign("hsq_n_trials", n_trials_int)
      n_trials_kw <- "n_trials = Vector{Int}(hsq_n_trials), "
    }
  }
  JuliaCall::julia_command(paste0(
    "hsq_ped = HSquared.normalize_pedigree(hsq_id, hsq_sire, hsq_dam); ",
    "hsq_Ainv = HSquared.pedigree_inverse(hsq_ped); ",
    "hsq_fit = HSquared.fit_laplace_reml(",
    "hsq_y, hsq_X, hsq_Z, hsq_Ainv; ",
    "family = Symbol(hsq_family), marginal = Symbol(hsq_marginal), ",
    n_trials_kw,
    "ids = hsq_ped.ids, iterations = hsq_iterations);",
    "hsq_result = HSquared.nongaussian_result_payload(hsq_fit);",
    "hsq_ng_raw = Dict(",
    "\"family\" => String(hsq_result.family),",
    "\"method\" => String(hsq_result.method),",
    "\"sigma_a2\" => hsq_result.variance_components.sigma_a2,",
    "\"beta\" => collect(Float64, hsq_result.fixed_effects),",
    "\"breeding_ids\" => string.(collect(hsq_result.breeding_values.ids)),",
    "\"breeding_values\" => collect(Float64, hsq_result.breeding_values.values),",
    "\"n_trials\" => (hasproperty(hsq_result, :n_trials) ? hsq_result.n_trials : nothing),",
    "\"loglik\" => hsq_result.loglik,",
    "\"converged\" => hsq_result.converged",
    ");"
  ))

  raw <- JuliaCall::julia_eval("hsq_ng_raw")
  result <- hs_normalize_nongaussian_result(raw, payload)
  # The engine echoes the canonical method it actually ran (laplace/variational);
  # surface it in the user-facing spec method rather than assuming Laplace.
  method_label <- if (identical(result$marginal_method, "variational")) {
    "Variational-REML"
  } else {
    "Laplace-REML"
  }
  hs_new_fit(
    spec = list(
      method = method_label,
      family = list(family = family$family, link = family$link),
      target = "nongaussian"
    ),
    payload = payload,
    result = result,
    engine = "HSquared.jl"
  )
}

hs_normalize_nongaussian_result <- function(raw, payload) {
  family <- as.character(raw$family)
  method <- hs_validate_marginal_method(raw$method)
  n_trials <- raw$n_trials
  if (!is.null(n_trials)) {
    n_trials <- as.integer(n_trials)
  }
  fixed_effects <- as.numeric(raw$beta)
  fixed_names <- payload$metadata$fixed_colnames
  if (length(fixed_effects) == length(fixed_names)) {
    names(fixed_effects) <- fixed_names
  }
  animal_bv <- data.frame(
    id = as.character(raw$breeding_ids),
    value = as.numeric(raw$breeding_values),
    stringsAsFactors = FALSE
  )
  converged <- isTRUE(raw$converged)
  result <- list(
    # Latent-scale additive genetic variance; a non-Gaussian family has no
    # residual-variance scale, so no heritability is reported (surfacing a
    # liability-scale h2 here would be an unbacked claim).
    variance_components = data.frame(
      component = "animal",
      estimate = as.numeric(raw$sigma_a2),
      stringsAsFactors = FALSE
    ),
    breeding_values = animal_bv,
    random_effects = list(animal = animal_bv),
    fixed_effects = fixed_effects,
    nobs = length(payload$y),
    converged = converged,
    family = family,
    marginal_method = method,
    diagnostics = list(
      target = "nongaussian",
      variance_components = if (identical(method, "variational")) {
        "estimated_variational_reml"
      } else {
        "estimated_laplace_reml"
      },
      engine_family = family,
      marginal_method = method,
      latent_scale = TRUE,
      # The Laplace marginal reports the Laplace-approximate marginal loglik; the
      # variational marginal reports the ELBO (a LOWER BOUND on log p(y)), so
      # logLik/AIC are NOT comparable across the two marginals.
      loglik_kind = if (identical(method, "variational")) {
        "elbo (variational lower bound)"
      } else {
        "laplace marginal loglik"
      },
      heritability_note = paste(
        "No heritability is reported: a non-Gaussian family has no",
        "residual-variance scale, so a latent/liability-scale h2 would be an",
        "unbacked claim."
      )
    )
  )
  if (!is.null(n_trials)) {
    result$n_trials <- n_trials
  }
  if (converged) {
    result$loglik <- as.numeric(raw$loglik)
    # The objective value: the Laplace-approximate marginal log-likelihood for
    # `marginal = "laplace"`, or the ELBO (a lower bound) for `"variational"` --
    # see diagnostics$loglik_kind; the two are not comparable across marginals.
    result$loglik_kind <- result$diagnostics$loglik_kind
    # df = fixed effects + the single additive-genetic variance component.
    result$df <- as.integer(ncol(payload$X) + 1L)
  }
  result
}

# Opt-in, experimental repeatability (permanent-environment) estimator. Surfaces
# the Julia-owned `HSquared.fit_repeatability_reml()` REML-only optimizer through
# the bridge. The permanent-environment effect shares the animal incidence `Z`
# (the engine carries an identity relationship for it), so the existing payload
# is sufficient. Variance components σ²a and σ²pe are only identifiable with
# repeated records per individual.
hs_fit_julia_repeatability_payload <- function(
  payload,
  project = hs_default_julia_project(),
  initial = c(sigma_a2 = 1, sigma_pe2 = 1, sigma_e2 = 1),
  iterations = 200L
) {
  if (!inherits(payload, "hs_bridge_payload")) {
    stop("`payload` must be an internal `hs_bridge_payload`.", call. = FALSE)
  }
  if (!hs_julia_bridge_available(project)) {
    stop(
      "The experimental Julia bridge requires Julia, the `JuliaCall` R ",
      "package, and a local `HSquared.jl` project.",
      call. = FALSE
    )
  }

  initial <- hs_validate_repeatability_initial(initial)
  iterations <- hs_validate_iterations(iterations)
  hs_julia_setup(project)
  hs_julia_assign_payload(payload, initial)
  JuliaCall::julia_assign(
    "hsq_initial_sigma_pe2",
    unname(initial[["sigma_pe2"]])
  )
  JuliaCall::julia_assign("hsq_iterations", iterations)
  JuliaCall::julia_command(paste(
    "hsq_ped = HSquared.normalize_pedigree(hsq_id, hsq_sire, hsq_dam);",
    "hsq_Ainv = HSquared.pedigree_inverse(hsq_ped);",
    "hsq_fit = HSquared.fit_repeatability_reml(",
    "hsq_y, hsq_X, hsq_Z, hsq_Ainv;",
    "initial = (sigma_a2 = hsq_initial_sigma_a2,",
    "sigma_pe2 = hsq_initial_sigma_pe2,",
    "sigma_e2 = hsq_initial_sigma_e2),",
    "iterations = hsq_iterations, ids = hsq_ped.ids);"
  ))

  # Experimental, opt-in repeatability-coefficient CI (engine row V3-REPEAT-REML,
  # partial). repeatability_interval() takes the raw matrices (not a fit) and
  # refits internally; it throws on a non-positive-definite REML information
  # (flat/boundary optimum) or a boundary t, so the try guard keeps an interval
  # failure from aborting the fit. hsq_has_ri gates the eval so a Julia `nothing`
  # never crosses the bridge.
  JuliaCall::julia_command(paste(
    "hsq_ri = if isdefined(HSquared, :repeatability_interval) &&",
    "applicable(HSquared.repeatability_interval, hsq_y, hsq_X, hsq_Z, hsq_Ainv);",
    "try; HSquared.repeatability_interval(",
    "hsq_y, hsq_X, hsq_Z, hsq_Ainv;",
    "initial = (sigma_a2 = hsq_initial_sigma_a2,",
    "sigma_pe2 = hsq_initial_sigma_pe2,",
    "sigma_e2 = hsq_initial_sigma_e2),",
    "iterations = hsq_iterations, ids = hsq_ped.ids);",
    "catch; nothing; end; else; nothing; end;",
    "hsq_has_ri = hsq_ri !== nothing;"
  ))

  raw <- JuliaCall::julia_eval(paste(
    "Dict(",
    "\"sigma_a2\" => hsq_fit.variance_components.sigma_a2,",
    "\"sigma_pe2\" => hsq_fit.variance_components.sigma_pe2,",
    "\"sigma_e2\" => hsq_fit.variance_components.sigma_e2,",
    "\"repeatability\" => hsq_fit.repeatability,",
    "\"heritability\" => hsq_fit.heritability,",
    "\"beta\" => collect(Float64, hsq_fit.beta),",
    "\"animal_ids\" => string.(collect(hsq_fit.animal_effects.ids)),",
    "\"animal_values\" => collect(Float64, hsq_fit.animal_effects.values),",
    "\"pe_ids\" => string.(collect(hsq_fit.permanent_effects.ids)),",
    "\"pe_values\" => collect(Float64, hsq_fit.permanent_effects.values),",
    "\"loglik\" => hsq_fit.loglik,",
    "\"converged\" => hsq_fit.converged)"
  ))

  result <- hs_normalize_repeatability_result(raw, payload)
  if (isTRUE(JuliaCall::julia_eval("hsq_has_ri"))) {
    raw_ri <- JuliaCall::julia_eval(paste(
      "Dict(",
      "\"repeatability\" => hsq_ri.repeatability,",
      "\"lower\" => hsq_ri.lower,",
      "\"upper\" => hsq_ri.upper,",
      "\"level\" => hsq_ri.level,",
      "\"se\" => hsq_ri.se)"
    ))
    result$repeatability_interval <- hs_normalize_repeatability_interval(raw_ri)
  }
  hs_new_fit(
    spec = list(
      method = "REML",
      family = list(family = payload$family, link = "identity"),
      target = "repeatability"
    ),
    payload = payload,
    result = result,
    engine = "HSquared.jl"
  )
}

hs_normalize_repeatability_result <- function(raw, payload) {
  fixed_effects <- as.numeric(raw$beta)
  fixed_names <- payload$metadata$fixed_colnames
  if (length(fixed_effects) == length(fixed_names)) {
    names(fixed_effects) <- fixed_names
  }
  animal_bv <- data.frame(
    id = as.character(raw$animal_ids),
    value = as.numeric(raw$animal_values),
    stringsAsFactors = FALSE
  )
  list(
    variance_components = data.frame(
      component = c("animal", "permanent", "residual"),
      estimate = c(
        as.numeric(raw$sigma_a2),
        as.numeric(raw$sigma_pe2),
        as.numeric(raw$sigma_e2)
      ),
      stringsAsFactors = FALSE
    ),
    heritability = data.frame(
      term = "animal",
      estimate = as.numeric(raw$heritability)
    ),
    repeatability = data.frame(
      term = "individual",
      estimate = as.numeric(raw$repeatability)
    ),
    breeding_values = animal_bv,
    permanent_effects = data.frame(
      id = as.character(raw$pe_ids),
      value = as.numeric(raw$pe_values),
      stringsAsFactors = FALSE
    ),
    random_effects = list(
      animal = animal_bv,
      permanent = data.frame(
        id = as.character(raw$pe_ids),
        value = as.numeric(raw$pe_values),
        stringsAsFactors = FALSE
      )
    ),
    fixed_effects = fixed_effects,
    loglik = as.numeric(raw$loglik),
    nobs = length(payload$y),
    converged = isTRUE(raw$converged),
    diagnostics = list(variance_components = "estimated_repeatability_reml")
  )
}

hs_validate_repeatability_initial <- function(initial) {
  if (
    !is.numeric(initial) ||
      !setequal(names(initial), c("sigma_a2", "sigma_pe2", "sigma_e2"))
  ) {
    stop(
      "`initial` for the repeatability target must be a named numeric vector ",
      "with `sigma_a2`, `sigma_pe2`, and `sigma_e2`.",
      call. = FALSE
    )
  }
  if (any(!is.finite(initial)) || any(initial <= 0)) {
    stop(
      "`initial` variance components must be finite and positive.",
      call. = FALSE
    )
  }
  initial[c("sigma_a2", "sigma_pe2", "sigma_e2")]
}

# Opt-in, experimental two-effect (common-environment) estimator. Surfaces the
# Julia-owned `HSquared.fit_two_effect_reml()` REML-only optimizer: effect 1 is
# the additive-genetic animal effect (Z, pedigree Ainv); effect 2 is the
# common-environment effect (Z2 from the environmental grouping, identity
# relationship). Returns three variance components (animal, common_env,
# residual).
hs_fit_julia_two_effect_payload <- function(
  payload,
  project = hs_default_julia_project(),
  initial = c(sigma_a2 = 1, sigma_c2 = 1, sigma_e2 = 1),
  iterations = 200L
) {
  if (!inherits(payload, "hs_bridge_payload")) {
    stop("`payload` must be an internal `hs_bridge_payload`.", call. = FALSE)
  }
  if (is.null(payload$Z2) || is.null(payload$effect2)) {
    stop(
      "Internal bridge error: the two-effect payload is missing its second ",
      "design matrix.",
      call. = FALSE
    )
  }
  if (!inherits(payload$Z2, "dgCMatrix")) {
    stop(
      "Internal bridge error: the two-effect Z2 must be a sparse dgCMatrix.",
      call. = FALSE
    )
  }
  if (!hs_julia_bridge_available(project)) {
    stop(
      "The experimental Julia bridge requires Julia, the `JuliaCall` R ",
      "package, and a local `HSquared.jl` project.",
      call. = FALSE
    )
  }

  initial <- hs_validate_two_effect_initial(initial)
  iterations <- hs_validate_iterations(iterations)
  hs_julia_setup(project)
  hs_julia_assign_payload(payload, initial)
  hs_julia_assign_sparse_csc("hsq_Z2", payload$Z2)
  JuliaCall::julia_assign("hsq_initial_sigma_c2", unname(initial[["sigma_c2"]]))
  JuliaCall::julia_assign("hsq_iterations", iterations)

  if (identical(payload$effect2$relationship, "pedigree")) {
    # Maternal genetic effect: effect 2 shares the pedigree relationship; its
    # columns are the pedigree animals (dams expressed through Z2).
    ainv2_cmd <- "hsq_Ainv2 = hsq_Ainv;"
    ids2_cmd <- "ids2 = hsq_ped.ids"
  } else {
    # IID effect (e.g. common environment): identity relationship over levels.
    JuliaCall::julia_assign("hsq_env_levels", payload$effect2$levels)
    ainv2_cmd <- paste(
      "hsq_n2 = size(hsq_Z2, 2);",
      "hsq_Ainv2 = sparse(collect(1:hsq_n2), collect(1:hsq_n2),",
      "ones(Float64, hsq_n2), hsq_n2, hsq_n2);"
    )
    ids2_cmd <- "ids2 = hsq_env_levels"
  }

  JuliaCall::julia_command(paste(
    "hsq_ped = HSquared.normalize_pedigree(hsq_id, hsq_sire, hsq_dam);",
    "hsq_Ainv = HSquared.pedigree_inverse(hsq_ped);",
    ainv2_cmd,
    "hsq_fit = HSquared.fit_two_effect_reml(",
    "hsq_y, hsq_X, hsq_Z, hsq_Ainv, hsq_Z2, hsq_Ainv2;",
    "initial = (sigma1 = hsq_initial_sigma_a2,",
    "sigma2 = hsq_initial_sigma_c2,",
    "sigma_e2 = hsq_initial_sigma_e2),",
    "iterations = hsq_iterations, ids1 = hsq_ped.ids,",
    ids2_cmd,
    ");"
  ))

  raw <- JuliaCall::julia_eval(paste(
    "Dict(",
    "\"sigma_a2\" => hsq_fit.variance_components.sigma1,",
    "\"sigma_c2\" => hsq_fit.variance_components.sigma2,",
    "\"sigma_e2\" => hsq_fit.variance_components.sigma_e2,",
    "\"heritability\" => hsq_fit.ratio1,",
    "\"c2\" => hsq_fit.ratio2,",
    "\"beta\" => collect(Float64, hsq_fit.beta),",
    "\"animal_ids\" => string.(collect(hsq_fit.effect1.ids)),",
    "\"animal_values\" => collect(Float64, hsq_fit.effect1.values),",
    "\"env_ids\" => string.(collect(hsq_fit.effect2.ids)),",
    "\"env_values\" => collect(Float64, hsq_fit.effect2.values),",
    "\"loglik\" => hsq_fit.loglik,",
    "\"converged\" => hsq_fit.converged)"
  ))

  result <- hs_normalize_two_effect_result(raw, payload)
  hs_new_fit(
    spec = list(
      method = "REML",
      family = list(family = payload$family, link = "identity"),
      target = "two_effect"
    ),
    payload = payload,
    result = result,
    engine = "HSquared.jl"
  )
}

hs_normalize_two_effect_result <- function(raw, payload) {
  fixed_effects <- as.numeric(raw$beta)
  fixed_names <- payload$metadata$fixed_colnames
  if (length(fixed_effects) == length(fixed_names)) {
    names(fixed_effects) <- fixed_names
  }
  animal_bv <- data.frame(
    id = as.character(raw$animal_ids),
    value = as.numeric(raw$animal_values),
    stringsAsFactors = FALSE
  )
  type2 <- payload$effect2$type
  second_eff <- data.frame(
    id = as.character(raw$env_ids),
    value = as.numeric(raw$env_values),
    stringsAsFactors = FALSE
  )
  result <- list(
    variance_components = data.frame(
      component = c("animal", type2, "residual"),
      estimate = c(
        as.numeric(raw$sigma_a2),
        as.numeric(raw$sigma_c2),
        as.numeric(raw$sigma_e2)
      ),
      stringsAsFactors = FALSE
    ),
    heritability = data.frame(
      term = "animal",
      estimate = as.numeric(raw$heritability)
    ),
    breeding_values = animal_bv,
    random_effects = list(animal = animal_bv),
    fixed_effects = fixed_effects,
    loglik = as.numeric(raw$loglik),
    nobs = length(payload$y),
    converged = isTRUE(raw$converged),
    diagnostics = list(variance_components = "estimated_two_effect_reml")
  )
  result$random_effects[[type2]] <- second_eff
  if (identical(type2, "common_env")) {
    result$common_env_effects <- second_eff
    result$common_env_proportion <- data.frame(
      term = "common_env",
      estimate = as.numeric(raw$c2)
    )
  } else {
    result$maternal_effects <- second_eff
    result$maternal_proportion <- data.frame(
      term = "maternal_genetic",
      estimate = as.numeric(raw$c2)
    )
  }
  result
}

hs_fit_julia_multivariate_payload <- function(
  payload,
  project = hs_default_julia_project(),
  initial = NULL,
  iterations = 2000L,
  genetic_structure = "unstructured"
) {
  if (!inherits(payload, "hs_bridge_payload")) {
    stop("`payload` must be an internal `hs_bridge_payload`.", call. = FALSE)
  }
  if (is.null(payload$Y) || !is.matrix(payload$Y)) {
    stop(
      "Internal bridge error: the multivariate payload is missing its `Y` ",
      "response matrix.",
      call. = FALSE
    )
  }
  if (is.null(payload$pedigree)) {
    stop(
      "Internal bridge error: the multivariate target requires a pedigree ",
      "animal-model payload.",
      call. = FALSE
    )
  }
  if (!hs_julia_bridge_available(project)) {
    stop(
      "The experimental Julia bridge requires Julia, the `JuliaCall` R ",
      "package, and a local `HSquared.jl` project.",
      call. = FALSE
    )
  }

  ntraits <- ncol(payload$Y)
  initial <- hs_validate_multivariate_initial(initial, ntraits)
  iterations <- hs_validate_iterations(iterations)
  traits <- payload$metadata$trait_names %||% colnames(payload$Y)
  if (is.null(traits)) {
    traits <- paste0("trait", seq_len(ntraits))
  }

  hs_julia_setup(project)
  JuliaCall::julia_assign("hsq_Y", payload$Y)
  JuliaCall::julia_assign("hsq_X", payload$X)
  hs_julia_assign_sparse_csc("hsq_Z", payload$Z)
  JuliaCall::julia_assign("hsq_id", payload$pedigree$id)
  JuliaCall::julia_assign(
    "hsq_sire",
    hs_parent_for_julia(payload$pedigree$sire)
  )
  JuliaCall::julia_assign("hsq_dam", hs_parent_for_julia(payload$pedigree$dam))
  JuliaCall::julia_assign("hsq_traits", as.character(traits))
  JuliaCall::julia_assign("hsq_initial_G0", initial$G0)
  JuliaCall::julia_assign("hsq_initial_R0", initial$R0)
  JuliaCall::julia_assign("hsq_iterations", iterations)
  JuliaCall::julia_assign(
    "hsq_genetic_structure",
    as.character(genetic_structure)
  )
  JuliaCall::julia_command(paste(
    "hsq_ped = HSquared.normalize_pedigree(hsq_id, hsq_sire, hsq_dam);",
    "hsq_Ainv = HSquared.pedigree_inverse(hsq_ped);",
    "hsq_fit = HSquared.fit_multivariate_reml(",
    "hsq_Y, hsq_X, hsq_Z, hsq_Ainv;",
    "initial = (G0 = hsq_initial_G0, R0 = hsq_initial_R0),",
    "iterations = hsq_iterations, ids = hsq_ped.ids, traits = hsq_traits,",
    "genetic_structure = Symbol(hsq_genetic_structure));",
    "hsq_mv_raw = Dict(",
    "\"genetic_covariance\" => Matrix{Float64}(hsq_fit.genetic_covariance),",
    "\"residual_covariance\" => Matrix{Float64}(hsq_fit.residual_covariance),",
    "\"genetic_correlation\" => Matrix{Float64}(hsq_fit.genetic_correlation),",
    "\"residual_correlation\" => Matrix{Float64}(hsq_fit.residual_correlation),",
    "\"heritability\" => collect(Float64, hsq_fit.heritability),",
    "\"beta\" => Matrix{Float64}(hsq_fit.beta),",
    "\"breeding_ids\" => string.(collect(hsq_fit.breeding_values.ids)),",
    "\"breeding_traits\" => string.(collect(hsq_fit.breeding_values.traits)),",
    "\"breeding_values\" => Matrix{Float64}(hsq_fit.breeding_values.values),",
    "\"loglik\" => hsq_fit.loglik,",
    "\"converged\" => hsq_fit.converged,",
    "\"iterations\" => hsq_fit.iterations,",
    "\"traits\" => string.(collect(hsq_fit.traits)),",
    "\"genetic_structure\" => string(hsq_fit.genetic_structure)",
    ");",
    # Number of genetic covariance parameters (contract field for the
    # structure LRT). Read from the engine payload when present; the R
    # normalizer falls back to deriving it from genetic_structure + n_traits.
    "if hasproperty(hsq_fit, :n_genetic_params);",
    "hsq_mv_raw[\"n_genetic_params\"] = hsq_fit.n_genetic_params;",
    "end;",
    # Experimental covariance standard errors (engine row V4-MV-REML, partial;
    # :unstructured only — the engine throws for structured / factor-analytic
    # fits, and the observed information can be non-positive-definite at a
    # flat/boundary optimum, hence the try guard).
    "if isdefined(HSquared, :multivariate_covariance_standard_errors) &&",
    "hsq_fit.genetic_structure == :unstructured;",
    "hsq_mvse = try; HSquared.multivariate_covariance_standard_errors(",
    "hsq_fit, hsq_Y, hsq_X, hsq_Z, hsq_Ainv); catch; nothing; end;",
    "if hsq_mvse !== nothing;",
    "hsq_mv_raw[\"se_genetic_covariance\"] = Matrix{Float64}(hsq_mvse.genetic_covariance);",
    "hsq_mv_raw[\"se_residual_covariance\"] = Matrix{Float64}(hsq_mvse.residual_covariance);",
    "hsq_mv_raw[\"se_genetic_correlation\"] = Matrix{Float64}(hsq_mvse.genetic_correlation);",
    "hsq_mv_raw[\"se_residual_correlation\"] = Matrix{Float64}(hsq_mvse.residual_correlation);",
    "hsq_mv_raw[\"se_heritability\"] = collect(Float64, hsq_mvse.heritability);",
    "end;",
    "end;"
  ))
  hs_julia_attach_multivariate_plot_data()

  raw <- JuliaCall::julia_eval("hsq_mv_raw")
  result <- hs_normalize_multivariate_result(raw, payload)
  hs_new_fit(
    spec = list(
      method = "REML",
      family = list(family = payload$family, link = "identity"),
      target = "multivariate"
    ),
    payload = payload,
    result = result,
    engine = "HSquared.jl"
  )
}

hs_normalize_multivariate_result <- function(raw, payload) {
  traits <- as.character(raw$traits %||% payload$metadata$trait_names)
  if (length(traits) == 0L) {
    traits <- paste0("trait", seq_len(ncol(payload$Y)))
  }
  ntraits <- length(traits)
  fixed_names <- payload$metadata$fixed_colnames
  ids <- as.character(raw$breeding_ids %||% payload$ids)

  G0 <- hs_matrix_from_julia(
    raw$genetic_covariance,
    ntraits,
    ntraits,
    "genetic covariance"
  )
  R0 <- hs_matrix_from_julia(
    raw$residual_covariance,
    ntraits,
    ntraits,
    "residual covariance"
  )
  Gcor <- hs_matrix_from_julia(
    raw$genetic_correlation,
    ntraits,
    ntraits,
    "genetic correlation"
  )
  Rcor <- hs_matrix_from_julia(
    raw$residual_correlation,
    ntraits,
    ntraits,
    "residual correlation"
  )
  dimnames(G0) <- dimnames(R0) <- dimnames(Gcor) <- dimnames(Rcor) <-
    list(traits, traits)

  beta <- hs_matrix_from_julia(
    raw$beta,
    length(fixed_names),
    ntraits,
    "fixed effects"
  )
  fixed_effects <- data.frame(
    term = rep(fixed_names, times = ntraits),
    trait = rep(traits, each = length(fixed_names)),
    estimate = as.vector(beta),
    stringsAsFactors = FALSE
  )

  bv <- hs_matrix_from_julia(
    raw$breeding_values,
    length(ids),
    ntraits,
    "breeding values"
  )
  breeding_values <- hs_long_matrix(bv, ids = ids, traits = traits)

  converged <- isTRUE(raw$converged)
  p <- ncol(payload$X)
  n_covariance_parameters <- ntraits * (ntraits + 1L)

  result <- list(
    variance_components = data.frame(
      component = rep(c("genetic", "residual"), each = ntraits),
      trait = rep(traits, times = 2L),
      estimate = c(diag(G0), diag(R0)),
      stringsAsFactors = FALSE
    ),
    heritability = data.frame(
      term = traits,
      trait = traits,
      estimate = as.numeric(raw$heritability),
      stringsAsFactors = FALSE
    ),
    genetic_covariance = G0,
    residual_covariance = R0,
    genetic_correlation = Gcor,
    residual_correlation = Rcor,
    breeding_values = breeding_values,
    fixed_effects = fixed_effects,
    random_effects = list(animal = breeding_values),
    nobs = as.integer(sum(!is.na(payload$Y))),
    converged = converged,
    diagnostics = list(
      target = "multivariate",
      variance_components = "estimated_multivariate_reml",
      optimizer_status = if (converged) "converged" else "not_converged",
      iterations = as.integer(raw$iterations),
      n_traits = ntraits,
      n_records = nrow(payload$Y),
      n_observed_trait_records = sum(!is.na(payload$Y)),
      dense_validation_path = TRUE,
      conditioning_caveat = paste(
        "Experimental dense validation-scale path; the Julia engine inverts",
        "Ainv internally, so deep-inbreeding/high-condition-number pedigrees",
        "remain a twin-side hardening item."
      ),
      genetic_structure = raw$genetic_structure %||% "unstructured"
    )
  )
  if (converged) {
    result$loglik <- as.numeric(raw$loglik)
    result$df <- as.integer(p * ntraits + n_covariance_parameters)
  }
  # Genetic-structure label + number of genetic covariance parameters, for the
  # covariance-structure LRT. Prefer the engine payload field; otherwise derive
  # it from the structure (diagonal = t; unstructured = t(t+1)/2).
  gstruct <- raw$genetic_structure %||% "unstructured"
  result$genetic_structure <- gstruct
  result$n_genetic_params <- if (!is.null(raw$n_genetic_params)) {
    as.integer(raw$n_genetic_params)
  } else if (identical(gstruct, "diagonal")) {
    as.integer(ntraits)
  } else {
    as.integer(ntraits * (ntraits + 1L) / 2L)
  }
  if (!is.null(raw$se_genetic_covariance)) {
    lab <- function(m) {
      m <- as.matrix(m)
      dimnames(m) <- list(traits, traits)
      m
    }
    result$covariance_standard_errors <- list(
      genetic_covariance = lab(raw$se_genetic_covariance),
      residual_covariance = lab(raw$se_residual_covariance),
      genetic_correlation = lab(raw$se_genetic_correlation),
      residual_correlation = lab(raw$se_residual_correlation),
      heritability = stats::setNames(as.numeric(raw$se_heritability), traits)
    )
  }
  result <- hs_attach_multivariate_plot_data(result, raw, traits)
  result
}

hs_validate_multivariate_initial <- function(initial, ntraits) {
  if (is.null(initial)) {
    initial <- list(G0 = diag(1, ntraits), R0 = diag(1, ntraits))
  }
  if (
    !is.list(initial) ||
      is.null(names(initial)) ||
      !all(c("G0", "R0") %in% names(initial))
  ) {
    stop(
      "`initial` for the multivariate target must be a named list with ",
      "`G0` and `R0` covariance matrices.",
      call. = FALSE
    )
  }
  list(
    G0 = hs_validate_initial_covariance(initial$G0, "initial$G0", ntraits),
    R0 = hs_validate_initial_covariance(initial$R0, "initial$R0", ntraits)
  )
}

hs_validate_initial_covariance <- function(x, name, ntraits) {
  x <- as.matrix(x)
  if (!is.numeric(x) || !identical(dim(x), c(ntraits, ntraits))) {
    stop(
      "`",
      name,
      "` must be a numeric ",
      ntraits,
      " x ",
      ntraits,
      " covariance matrix.",
      call. = FALSE
    )
  }
  if (any(!is.finite(x))) {
    stop("`", name, "` must contain only finite values.", call. = FALSE)
  }
  if (!isTRUE(all.equal(x, t(x), tolerance = 1e-8, check.attributes = FALSE))) {
    stop("`", name, "` must be symmetric.", call. = FALSE)
  }
  pd <- tryCatch(
    {
      chol((x + t(x)) / 2)
      TRUE
    },
    error = function(e) FALSE
  )
  if (!isTRUE(pd)) {
    stop("`", name, "` must be positive definite.", call. = FALSE)
  }
  unname(x)
}

hs_matrix_from_julia <- function(x, nrow, ncol, label) {
  out <- as.matrix(x)
  storage.mode(out) <- "double"
  if (!identical(dim(out), c(nrow, ncol))) {
    if (length(out) == nrow * ncol) {
      out <- matrix(as.numeric(out), nrow = nrow, ncol = ncol)
    } else {
      stop(
        "The Julia multivariate result returned ",
        label,
        " with unexpected dimensions.",
        call. = FALSE
      )
    }
  }
  out
}

hs_long_matrix <- function(x, ids, traits) {
  data.frame(
    id = rep(as.character(ids), times = length(traits)),
    trait = rep(as.character(traits), each = length(ids)),
    value = as.vector(x),
    stringsAsFactors = FALSE
  )
}

hs_julia_attach_multivariate_plot_data <- function() {
  JuliaCall::julia_command(paste(
    "if isdefined(HSquared, :genetic_correlation_plot_data);",
    "hsq_gcpd = try;",
    "HSquared.genetic_correlation_plot_data(",
    "hsq_fit.genetic_covariance;",
    "traits = string.(collect(hsq_fit.traits)),",
    "heritabilities = collect(Float64, hsq_fit.heritability));",
    "catch; nothing; end;",
    "if hsq_gcpd !== nothing;",
    "hsq_mv_raw[\"genetic_correlation_plot_data\"] = hsq_gcpd;",
    "end;",
    "end;",
    "if isdefined(HSquared, :genetic_pca_plot_data);",
    "hsq_gppd = try;",
    "HSquared.genetic_pca_plot_data(hsq_fit.genetic_covariance);",
    "catch; nothing; end;",
    "if hsq_gppd !== nothing;",
    "hsq_mv_raw[\"genetic_pca_plot_data\"] = hsq_gppd;",
    "end;",
    "end;"
  ))
  invisible(TRUE)
}

hs_julia_attach_random_regression_plot_data <- function() {
  JuliaCall::julia_command(paste(
    "hsq_rr_plot_ts = collect(range(-1.0, 1.0; length = 25));",
    "if isdefined(HSquared, :rr_genetic_variance_plot_data);",
    "hsq_rr_gvpd = try;",
    "HSquared.rr_genetic_variance_plot_data(",
    "hsq_fit.variance_components.K_g, hsq_rr_plot_ts;",
    "residual = hsq_fit.variance_components.sigma_e2);",
    "catch; nothing; end;",
    "if hsq_rr_gvpd !== nothing;",
    "hsq_rr_raw[\"rr_genetic_variance_plot_data\"] = hsq_rr_gvpd;",
    "end;",
    "end;",
    "if isdefined(HSquared, :rr_eigenfunctions_plot_data);",
    "hsq_rr_efpd = try;",
    "HSquared.rr_eigenfunctions_plot_data(",
    "hsq_fit.variance_components.K_g, hsq_rr_plot_ts);",
    "catch; nothing; end;",
    "if hsq_rr_efpd !== nothing;",
    "hsq_rr_raw[\"rr_eigenfunctions_plot_data\"] = hsq_rr_efpd;",
    "end;",
    "end;",
    "if isdefined(HSquared, :rr_covariance_surface_plot_data);",
    "hsq_rr_sfpd = try;",
    "HSquared.rr_covariance_surface_plot_data(",
    "hsq_fit.variance_components.K_g, hsq_rr_plot_ts);",
    "catch; nothing; end;",
    "if hsq_rr_sfpd !== nothing;",
    "hsq_rr_raw[\"rr_covariance_surface_plot_data\"] = hsq_rr_sfpd;",
    "end;",
    "end;"
  ))
  invisible(TRUE)
}

# Opt-in, experimental random-regression (reaction-norm) bridge. Mirrors the
# multivariate payload path: assign the univariate response, fixed design, sparse
# record incidence, pedigree, the per-record covariate, and the Legendre order;
# build the n x k Legendre design Phi in Julia from the standardized covariate;
# call the Julia-owned `HSquared.fit_random_regression_reml`; unpack the
# NamedTuple fields into a Dict; normalize to an `hsquared_fit`. The grammar is
# PROVISIONAL (proposed to the twin on HSquared.jl#61, awaiting ack).
hs_fit_julia_random_regression_payload <- function(
  payload,
  project = hs_default_julia_project(),
  iterations = 2000L
) {
  if (!inherits(payload, "hs_bridge_payload")) {
    stop("`payload` must be an internal `hs_bridge_payload`.", call. = FALSE)
  }
  if (is.null(payload$y)) {
    stop(
      "Internal bridge error: the random-regression payload is missing its ",
      "univariate `y` response vector.",
      call. = FALSE
    )
  }
  if (is.null(payload$random_regression)) {
    stop(
      "Internal bridge error: the random-regression target requires an ",
      "`animal(rr(covariate, order = k) | id, ...)` payload.",
      call. = FALSE
    )
  }
  if (is.null(payload$pedigree)) {
    stop(
      "Internal bridge error: the random-regression target requires a ",
      "pedigree animal-model payload.",
      call. = FALSE
    )
  }
  if (!hs_julia_bridge_available(project)) {
    stop(
      "The experimental Julia bridge requires Julia, the `JuliaCall` R ",
      "package, and a local `HSquared.jl` project.",
      call. = FALSE
    )
  }

  rr <- payload$random_regression
  iterations <- hs_validate_iterations(iterations)
  order <- as.integer(rr$order)

  hs_julia_setup(project)
  JuliaCall::julia_assign("hsq_y", payload$y)
  JuliaCall::julia_assign("hsq_X", payload$X)
  hs_julia_assign_sparse_csc("hsq_Z", payload$Z)
  JuliaCall::julia_assign("hsq_id", payload$pedigree$id)
  JuliaCall::julia_assign(
    "hsq_sire",
    hs_parent_for_julia(payload$pedigree$sire)
  )
  JuliaCall::julia_assign("hsq_dam", hs_parent_for_julia(payload$pedigree$dam))
  JuliaCall::julia_assign("hsq_age", as.numeric(rr$values))
  JuliaCall::julia_assign("hsq_order", order)
  JuliaCall::julia_assign("hsq_iterations", iterations)
  JuliaCall::julia_command(paste(
    "hsq_ped = HSquared.normalize_pedigree(hsq_id, hsq_sire, hsq_dam);",
    "hsq_Ainv = HSquared.pedigree_inverse(hsq_ped);",
    # Standardize the per-record covariate to [-1, 1] over its observed range and
    # build the n x k normalized-Legendre design Phi (basis convention fixed to
    # Kirkpatrick/Meyer/Schaeffer normalized Legendre on standardized t).
    "hsq_Phi = HSquared.legendre_design(",
    "HSquared.standardize_covariate(hsq_age), hsq_order);",
    "hsq_fit = HSquared.fit_random_regression_reml(",
    "hsq_y, hsq_X, hsq_Phi, hsq_Z, hsq_Ainv;",
    "iterations = hsq_iterations, ids = hsq_ped.ids);",
    "hsq_rr_raw = Dict(",
    "\"K_g\" => Matrix{Float64}(hsq_fit.variance_components.K_g),",
    "\"sigma_e2\" => hsq_fit.variance_components.sigma_e2,",
    "\"beta\" => collect(Float64, hsq_fit.beta),",
    "\"coef_ids\" => string.(collect(hsq_fit.random_coefficients.ids)),",
    "\"coef_values\" => Matrix{Float64}(hsq_fit.random_coefficients.values),",
    "\"loglik\" => hsq_fit.loglik,",
    "\"converged\" => hsq_fit.converged,",
    "\"iterations\" => hsq_fit.iterations,",
    "\"ncoef\" => hsq_fit.basis.ncoef",
    ");"
  ))
  hs_julia_attach_random_regression_plot_data()

  raw <- JuliaCall::julia_eval("hsq_rr_raw")
  result <- hs_normalize_random_regression_result(raw, payload)
  hs_new_fit(
    spec = list(
      method = "REML",
      family = list(family = payload$family, link = "identity"),
      target = "random_regression"
    ),
    payload = payload,
    result = result,
    engine = "HSquared.jl"
  )
}

hs_normalize_random_regression_result <- function(raw, payload) {
  rr <- payload$random_regression %||% payload$metadata$random_regression
  fixed_names <- payload$metadata$fixed_colnames
  ids <- as.character(raw$coef_ids %||% payload$ids)
  k <- as.integer(raw$ncoef)
  if (is.na(k) || k < 1L) {
    k <- as.integer(rr$order)
  }
  coef_labels <- paste0("legendre", seq_len(k) - 1L)

  K_g <- hs_matrix_from_julia(raw$K_g, k, k, "coefficient genetic covariance")
  dimnames(K_g) <- list(coef_labels, coef_labels)
  sigma_e2 <- as.numeric(raw$sigma_e2)

  beta <- as.numeric(raw$beta)
  fixed_effects <- data.frame(
    term = fixed_names,
    estimate = beta,
    stringsAsFactors = FALSE
  )

  coefficients <- hs_matrix_from_julia(
    raw$coef_values,
    length(ids),
    k,
    "random-regression coefficients"
  )
  dimnames(coefficients) <- list(ids, coef_labels)
  random_coefficients <- data.frame(
    id = rep(ids, times = k),
    coefficient = rep(coef_labels, each = length(ids)),
    value = as.vector(coefficients),
    stringsAsFactors = FALSE
  )

  converged <- isTRUE(raw$converged)
  p <- ncol(payload$X)
  n_covariance_parameters <- as.integer(k * (k + 1L) / 2L) + 1L

  result <- list(
    variance_components = data.frame(
      component = c(paste0("K_g_", coef_labels), "residual"),
      estimate = c(diag(K_g), sigma_e2),
      stringsAsFactors = FALSE
    ),
    coefficient_covariance = K_g,
    residual_variance = sigma_e2,
    random_coefficients = random_coefficients,
    fixed_effects = fixed_effects,
    nobs = as.integer(length(payload$y)),
    converged = converged,
    # Standardization + basis metadata: extractors recompute the genetic
    # variance / heritability / correlation trajectories in R from K_g and the
    # normalized-Legendre basis, re-standardizing any user-supplied `at =` on the
    # original covariate scale with these recorded bounds.
    random_regression = list(
      covariate = rr$covariate,
      order = k,
      lower = as.numeric(rr$lower),
      upper = as.numeric(rr$upper)
    ),
    diagnostics = list(
      target = "random_regression",
      variance_components = "estimated_random_regression_reml",
      optimizer_status = if (converged) "converged" else "not_converged",
      iterations = as.integer(raw$iterations),
      n_coefficients = k,
      n_records = length(payload$y),
      covariate = rr$covariate,
      covariate_range = c(as.numeric(rr$lower), as.numeric(rr$upper)),
      dense_validation_path = TRUE,
      residual_model = "homogeneous",
      conditioning_caveat = paste(
        "Experimental dense validation-scale path with a HOMOGENEOUS residual",
        "and NO permanent-environment term; both are planned. The Julia engine",
        "inverts Ainv internally, so deep-inbreeding/high-condition-number",
        "pedigrees remain a twin-side hardening item."
      )
    )
  )
  if (converged) {
    result$loglik <- as.numeric(raw$loglik)
    result$df <- as.integer(p + n_covariance_parameters)
  }
  result <- hs_attach_random_regression_plot_data(result, raw)
  result
}

# Normalized Legendre basis row vector phi(t) = [phi_0(t), ..., phi_{k-1}(t)] at a
# standardized covariate t in [-1, 1], mirroring `HSquared.legendre_basis`:
# phi_n(t) = sqrt((2n+1)/2) * P_n(t), with P_n the ordinary Legendre polynomials
# via the Bonnet recurrence. Used by the R-side reaction-norm trajectory
# extractors so they need no live Julia round-trip.
hs_legendre_basis <- function(t, order) {
  order <- as.integer(order)
  tt <- max(-1, min(1, as.numeric(t)))
  p <- numeric(order)
  p[1L] <- 1
  if (order >= 2L) {
    p[2L] <- tt
  }
  if (order >= 3L) {
    for (n in 2:(order - 1L)) {
      p[n + 1L] <- ((2 * n - 1) * tt * p[n] - (n - 1) * p[n - 1L]) / n
    }
  }
  phi <- numeric(order)
  for (n in 0:(order - 1L)) {
    phi[n + 1L] <- sqrt((2 * n + 1) / 2) * p[n + 1L]
  }
  phi
}

# n x order normalized-Legendre design over already-standardized points `ts`,
# mirroring `HSquared.legendre_design`.
hs_legendre_design <- function(ts, order) {
  do.call(rbind, lapply(ts, hs_legendre_basis, order = order))
}

# Map a raw covariate value/vector onto t in [-1, 1] using the recorded fit
# range, mirroring `HSquared.standardize_covariate`
# (t = 2(a - lower)/(upper - lower) - 1).
hs_standardize_covariate <- function(a, lower, upper) {
  2 * (as.numeric(a) - lower) / (upper - lower) - 1
}

hs_unstandardize_covariate <- function(t, lower, upper) {
  lower + (as.numeric(t) + 1) * (upper - lower) / 2
}

hs_validate_two_effect_initial <- function(initial) {
  if (
    !is.numeric(initial) ||
      !setequal(names(initial), c("sigma_a2", "sigma_c2", "sigma_e2"))
  ) {
    stop(
      "`initial` for the two-effect target must be a named numeric vector ",
      "with `sigma_a2`, `sigma_c2`, and `sigma_e2`.",
      call. = FALSE
    )
  }
  if (any(!is.finite(initial)) || any(initial <= 0)) {
    stop(
      "`initial` variance components must be finite and positive.",
      call. = FALSE
    )
  }
  initial[c("sigma_a2", "sigma_c2", "sigma_e2")]
}

# Opt-in, experimental genomic GREML estimator. Surfaces the Julia-owned
# `HSquared.fit_ai_reml()` REML optimizer on an animal_model_spec built with the
# user-supplied genomic relationship inverse `Ginv` (in place of a pedigree
# Ainv). Reuses the standard result normalizer, relabelling the genetic
# component as "genomic".
hs_fit_julia_genomic_payload <- function(
  payload,
  project = hs_default_julia_project(),
  initial = c(sigma_a2 = 1, sigma_e2 = 1),
  iterations = 100L
) {
  if (!inherits(payload, "hs_bridge_payload")) {
    stop("`payload` must be an internal `hs_bridge_payload`.", call. = FALSE)
  }
  from_markers <- identical(payload$relationship_source, "markers")
  if (is.null(payload$Ginv) && !from_markers) {
    stop(
      "Internal bridge error: the genomic payload is missing its `Ginv`.",
      call. = FALSE
    )
  }
  if (from_markers && is.null(payload$markers)) {
    stop(
      "Internal bridge error: the genomic payload is missing its `markers`.",
      call. = FALSE
    )
  }
  if (!hs_julia_bridge_available(project)) {
    stop(
      "The experimental Julia bridge requires Julia, the `JuliaCall` R ",
      "package, and a local `HSquared.jl` project.",
      call. = FALSE
    )
  }

  initial <- hs_validate_initial_variances(initial)
  iterations <- hs_validate_iterations(iterations)
  hs_julia_setup(project)
  JuliaCall::julia_assign("hsq_y", payload$y)
  JuliaCall::julia_assign("hsq_X", payload$X)
  hs_julia_assign_sparse_csc("hsq_Z", payload$Z)
  JuliaCall::julia_assign("hsq_ids", payload$ids)
  JuliaCall::julia_assign("hsq_initial_sigma_a2", unname(initial[["sigma_a2"]]))
  JuliaCall::julia_assign("hsq_initial_sigma_e2", unname(initial[["sigma_e2"]]))
  JuliaCall::julia_assign("hsq_iterations", iterations)
  if (from_markers) {
    # Build the genomic relationship inverse from the marker matrix in Julia.
    JuliaCall::julia_assign("hsq_markers", payload$markers)
    JuliaCall::julia_assign("hsq_ridge", payload$ridge)
    relinv_cmd <- paste(
      "hsq_G = HSquared.genomic_relationship_matrix(hsq_markers);",
      "hsq_Ginvs = sparse(HSquared.genomic_relationship_inverse(",
      "hsq_G; ridge = hsq_ridge));"
    )
  } else {
    JuliaCall::julia_assign("hsq_Ginv", payload$Ginv)
    relinv_cmd <- "hsq_Ginvs = sparse(hsq_Ginv);"
  }
  JuliaCall::julia_command(paste(
    relinv_cmd,
    "hsq_spec = HSquared.animal_model_spec(",
    "hsq_y, hsq_X, hsq_Z, hsq_Ginvs;",
    "ids = hsq_ids, method = :REML);",
    "hsq_fit = HSquared.fit_ai_reml(",
    "hsq_spec;",
    "initial = (sigma_a2 = hsq_initial_sigma_a2,",
    "sigma_e2 = hsq_initial_sigma_e2),",
    "iterations = hsq_iterations);",
    "hsq_result = HSquared.result_payload(hsq_fit);"
  ))
  hs_julia_attach_standard_plot_data()

  raw <- JuliaCall::julia_eval(
    "Dict(String(k) => getfield(hsq_result, k) for k in keys(hsq_result))"
  )
  rel <- payload$relationship
  result <- hs_normalize_julia_result(raw, payload)
  result$variance_components$component[
    result$variance_components$component == "animal"
  ] <- rel
  result$heritability$term[result$heritability$term == "animal"] <- rel
  names(result$random_effects)[
    names(result$random_effects) == "animal"
  ] <- rel
  result$diagnostics$variance_components <- paste0(
    "estimated_",
    rel,
    "_ai_reml"
  )
  hs_new_fit(
    spec = list(
      method = "REML",
      family = list(family = payload$family, link = "identity"),
      target = rel
    ),
    payload = payload,
    result = result,
    engine = "HSquared.jl"
  )
}

# Opt-in, experimental single-step H^-1 CONSTRUCTION estimator. Builds Ainv + dense
# A from the pedigree and G from the genotyped-subset markers, then fits via the
# Julia-owned `fit_single_step_reml` (which assembles H^-1 = A^-1 + scatter over the
# genotyped rows). Mirrors `fit_ai_reml` on the supplied-Hinv path; experimental,
# dense/validation-scale (docs/design/25).
hs_fit_julia_single_step_construct_payload <- function(
  payload,
  project = hs_default_julia_project(),
  initial = c(sigma_a2 = 1, sigma_e2 = 1),
  iterations = 100L
) {
  if (!inherits(payload, "hs_bridge_payload")) {
    stop("`payload` must be an internal `hs_bridge_payload`.", call. = FALSE)
  }
  if (
    !identical(payload$relationship_source, "construct") ||
      is.null(payload$markers) ||
      is.null(payload$pedigree) ||
      is.null(payload$genotyped_rows)
  ) {
    stop(
      "Internal bridge error: the single-step construction payload is ",
      "incomplete (needs pedigree, markers, and genotyped_rows).",
      call. = FALSE
    )
  }
  if (!hs_julia_bridge_available(project)) {
    stop(
      "The experimental Julia bridge requires Julia, the `JuliaCall` R ",
      "package, and a local `HSquared.jl` project.",
      call. = FALSE
    )
  }

  initial <- hs_validate_initial_variances(initial)
  iterations <- hs_validate_iterations(iterations)
  hs_julia_setup(project)
  JuliaCall::julia_assign("hsq_y", payload$y)
  JuliaCall::julia_assign("hsq_X", payload$X)
  hs_julia_assign_sparse_csc("hsq_Z", payload$Z)
  JuliaCall::julia_assign("hsq_id", payload$pedigree$id)
  JuliaCall::julia_assign(
    "hsq_sire",
    hs_parent_for_julia(payload$pedigree$sire)
  )
  JuliaCall::julia_assign("hsq_dam", hs_parent_for_julia(payload$pedigree$dam))
  JuliaCall::julia_assign("hsq_markers", payload$markers)
  JuliaCall::julia_assign(
    "hsq_grows",
    as.integer(payload$genotyped_rows)
  )
  JuliaCall::julia_assign("hsq_tau", payload$single_step$tau)
  JuliaCall::julia_assign("hsq_omega", payload$single_step$omega)
  JuliaCall::julia_assign("hsq_bw", payload$single_step$blend_weight)
  JuliaCall::julia_assign("hsq_ssridge", payload$single_step$ridge)
  JuliaCall::julia_assign("hsq_initial_sigma_a2", unname(initial[["sigma_a2"]]))
  JuliaCall::julia_assign("hsq_initial_sigma_e2", unname(initial[["sigma_e2"]]))
  JuliaCall::julia_assign("hsq_iterations", iterations)
  JuliaCall::julia_command(paste(
    "hsq_ped = HSquared.normalize_pedigree(hsq_id, hsq_sire, hsq_dam);",
    # Guard the genotyped_rows alignment (docs/design/25 §8): the R-computed
    # genotyped_rows index R's pedigree order, so the engine's normalize_pedigree
    # must preserve that order. Fail loudly rather than fit a misaligned G.
    "collect(String, hsq_ped.ids) == hsq_id ||",
    "error(\"single_step construct: engine pedigree order != R order\");",
    "hsq_Ainv = HSquared.pedigree_inverse(hsq_ped);",
    "hsq_A = HSquared.additive_relationship(hsq_ped);",
    "hsq_G = HSquared.genomic_relationship_matrix(hsq_markers);",
    "hsq_fit = HSquared.fit_single_step_reml(",
    "hsq_y, hsq_X, hsq_Z, hsq_Ainv, hsq_A, hsq_G, hsq_grows;",
    "ids = hsq_ped.ids,",
    "tau = hsq_tau, omega = hsq_omega, blend_weight = hsq_bw, ridge = hsq_ssridge,",
    "initial = (sigma_a2 = hsq_initial_sigma_a2,",
    "sigma_e2 = hsq_initial_sigma_e2));",
    "hsq_result = HSquared.result_payload(hsq_fit);"
  ))
  hs_julia_attach_standard_plot_data()

  raw <- JuliaCall::julia_eval(
    "Dict(String(k) => getfield(hsq_result, k) for k in keys(hsq_result))"
  )
  rel <- payload$relationship
  result <- hs_normalize_julia_result(raw, payload)
  result$variance_components$component[
    result$variance_components$component == "animal"
  ] <- rel
  result$heritability$term[result$heritability$term == "animal"] <- rel
  names(result$random_effects)[
    names(result$random_effects) == "animal"
  ] <- rel
  result$diagnostics$variance_components <- "estimated_single_step_construct_ai_reml"
  hs_new_fit(
    spec = list(
      method = "REML",
      family = list(family = payload$family, link = "identity"),
      target = "single_step_construct"
    ),
    payload = payload,
    result = result,
    engine = "HSquared.jl"
  )
}

# Opt-in, experimental supplied-Gamma H^Gamma single-step bridge. This mirrors
# the ordinary construction helper above, but delegates H construction to the
# Julia-owned metafounder precision path. Gamma is supplied by the user; this
# bridge does not estimate Gamma or expose metafounder-specific extractors.
hs_fit_julia_metafounder_single_step_payload <- function(
  payload,
  project = hs_default_julia_project(),
  initial = c(sigma_a2 = 1, sigma_e2 = 1),
  iterations = 100L
) {
  if (!inherits(payload, "hs_bridge_payload")) {
    stop("`payload` must be an internal `hs_bridge_payload`.", call. = FALSE)
  }
  if (
    !identical(payload$relationship_source, "metafounder_single_step") ||
      is.null(payload$markers) ||
      is.null(payload$pedigree) ||
      is.null(payload$genotyped_rows) ||
      is.null(payload$group_of) ||
      is.null(payload$Gamma)
  ) {
    stop(
      "Internal bridge error: the metafounder single-step payload is ",
      "incomplete (needs pedigree, markers, genotyped_rows, group_of, and ",
      "Gamma).",
      call. = FALSE
    )
  }
  if (!hs_julia_bridge_available(project)) {
    stop(
      "The experimental Julia bridge requires Julia, the `JuliaCall` R ",
      "package, and a local `HSquared.jl` project.",
      call. = FALSE
    )
  }

  initial <- hs_validate_initial_variances(initial)
  iterations <- hs_validate_iterations(iterations)
  hs_julia_setup(project)
  JuliaCall::julia_assign("hsq_y", payload$y)
  JuliaCall::julia_assign("hsq_X", payload$X)
  hs_julia_assign_sparse_csc("hsq_Z", payload$Z)
  JuliaCall::julia_assign("hsq_id", payload$pedigree$id)
  JuliaCall::julia_assign(
    "hsq_sire",
    hs_parent_for_julia(payload$pedigree$sire)
  )
  JuliaCall::julia_assign("hsq_dam", hs_parent_for_julia(payload$pedigree$dam))
  JuliaCall::julia_assign("hsq_markers", payload$markers)
  JuliaCall::julia_assign(
    "hsq_grows",
    as.integer(payload$genotyped_rows)
  )
  JuliaCall::julia_assign("hsq_group_of", unname(payload$group_of))
  JuliaCall::julia_assign("hsq_Gamma_vec", as.numeric(payload$Gamma))
  JuliaCall::julia_assign("hsq_Gamma_n", as.integer(nrow(payload$Gamma)))
  JuliaCall::julia_assign("hsq_tau", payload$single_step$tau)
  JuliaCall::julia_assign("hsq_omega", payload$single_step$omega)
  JuliaCall::julia_assign("hsq_bw", payload$single_step$blend_weight)
  JuliaCall::julia_assign("hsq_ssridge", payload$single_step$ridge)
  JuliaCall::julia_assign("hsq_initial_sigma_a2", unname(initial[["sigma_a2"]]))
  JuliaCall::julia_assign("hsq_initial_sigma_e2", unname(initial[["sigma_e2"]]))
  JuliaCall::julia_assign("hsq_iterations", iterations)
  JuliaCall::julia_command(paste(
    "hsq_ped = HSquared.normalize_pedigree(hsq_id, hsq_sire, hsq_dam);",
    "collect(String, hsq_ped.ids) == hsq_id ||",
    "error(\"metafounder single_step: engine pedigree order != R order\");",
    "hsq_G = HSquared.genomic_relationship_matrix(hsq_markers);",
    "hsq_Gamma = reshape(collect(Float64, hsq_Gamma_vec),",
    "Int(hsq_Gamma_n), Int(hsq_Gamma_n));",
    "hsq_fit = HSquared.fit_metafounder_single_step_reml(",
    "hsq_y, hsq_X, hsq_Z, hsq_ped, hsq_group_of, hsq_Gamma, hsq_G, hsq_grows;",
    "ids = hsq_ped.ids,",
    "tau = hsq_tau, omega = hsq_omega, blend_weight = hsq_bw, ridge = hsq_ssridge,",
    "initial = (sigma_a2 = hsq_initial_sigma_a2,",
    "sigma_e2 = hsq_initial_sigma_e2));",
    "hsq_result = HSquared.result_payload(hsq_fit);"
  ))
  hs_julia_attach_standard_plot_data()

  raw <- JuliaCall::julia_eval(
    "Dict(String(k) => getfield(hsq_result, k) for k in keys(hsq_result))"
  )
  rel <- payload$relationship
  result <- hs_normalize_julia_result(raw, payload)
  result$variance_components$component[
    result$variance_components$component == "animal"
  ] <- rel
  result$heritability$term[result$heritability$term == "animal"] <- rel
  names(result$random_effects)[
    names(result$random_effects) == "animal"
  ] <- rel
  result$diagnostics$target <- "metafounder_single_step"
  result$diagnostics$variance_components <-
    "estimated_metafounder_single_step_ai_reml"
  result$diagnostics$gamma_source <- "supplied"
  hs_new_fit(
    spec = list(
      method = "REML",
      family = list(family = payload$family, link = "identity"),
      target = "metafounder_single_step"
    ),
    payload = payload,
    result = result,
    engine = "HSquared.jl"
  )
}

hs_fit_julia_snp_blup_payload <- function(
  payload,
  project = hs_default_julia_project(),
  variance_components = NULL
) {
  if (!inherits(payload, "hs_bridge_payload")) {
    stop("`payload` must be an internal `hs_bridge_payload`.", call. = FALSE)
  }
  if (
    !identical(payload$relationship_source, "markers") ||
      is.null(payload$markers)
  ) {
    stop(
      "Internal bridge error: SNP-BLUP requires a marker-matrix genomic ",
      "payload.",
      call. = FALSE
    )
  }
  if (!hs_julia_bridge_available(project)) {
    stop(
      "The experimental Julia bridge requires Julia, the `JuliaCall` R ",
      "package, and a local `HSquared.jl` project.",
      call. = FALSE
    )
  }

  variance_components <- hs_validate_snp_blup_variances(variance_components)
  sigma_g2 <- unname(variance_components[["sigma_g2"]])
  sigma_e2 <- unname(variance_components[["sigma_e2"]])

  markers_ind <- payload$markers
  # Per-record marker design: each record carries its individual's genotype.
  # `Z` maps records to the `ids` order that the `markers` rows are in, so
  # `Z %*% markers` aligns the marker rows with the response `y`.
  markers_rec <- as.matrix(payload$Z %*% markers_ind)

  hs_julia_setup(project)
  JuliaCall::julia_assign("hsq_y", payload$y)
  JuliaCall::julia_assign("hsq_X", payload$X)
  JuliaCall::julia_assign("hsq_markers_rec", markers_rec)
  JuliaCall::julia_assign("hsq_markers_ind", unname(markers_ind))
  JuliaCall::julia_assign("hsq_sigma_g2", sigma_g2)
  JuliaCall::julia_assign("hsq_sigma_e2", sigma_e2)
  JuliaCall::julia_command(paste(
    "hsq_snp = HSquared.fit_snp_blup(",
    "hsq_y, hsq_X, hsq_markers_rec, hsq_sigma_g2, hsq_sigma_e2);",
    # Per-individual GEBV at the same allele-frequency centering as the fit.
    "hsq_Wind = HSquared.centered_markers(",
    "hsq_markers_ind; allele_frequencies = hsq_snp.p).W;",
    "hsq_gebv_ind = hsq_Wind * hsq_snp.marker_effects;",
    "hsq_fitted = hsq_X * hsq_snp.beta .+ hsq_snp.gebv;",
    "hsq_snp_raw = Dict(",
    "\"marker_effects\" => hsq_snp.marker_effects,",
    "\"gebv\" => hsq_gebv_ind,",
    "\"beta\" => hsq_snp.beta,",
    "\"p\" => hsq_snp.p,",
    "\"fitted\" => hsq_fitted,",
    "\"k\" => hsq_snp.k,",
    "\"nobs\" => length(hsq_y)",
    ");"
  ))

  raw <- JuliaCall::julia_eval("hsq_snp_raw")
  result <- hs_normalize_julia_snp_blup_result(
    raw,
    payload,
    variance_components
  )
  hs_new_fit(
    spec = list(
      method = payload$method,
      family = list(family = payload$family, link = "identity"),
      target = "snp_blup"
    ),
    payload = payload,
    result = result,
    engine = "HSquared.jl"
  )
}

# Opt-in, experimental REML-estimated SNP-BLUP. Unlike the supplied-variance
# `hs_fit_julia_snp_blup_payload`, this estimates the genomic and residual
# variance components from the markers by REML (Julia-owned
# `HSquared.fit_snp_blup_reml`), so `genomic(1 | id, markers = M)` no longer needs
# the user to supply `sigma_g2`/`sigma_e2`. Experimental, dense/validation-scale
# (mirrors the engine row V2-SNPBLUP, partial).
hs_fit_julia_snp_blup_reml_payload <- function(
  payload,
  project = hs_default_julia_project()
) {
  if (!inherits(payload, "hs_bridge_payload")) {
    stop("`payload` must be an internal `hs_bridge_payload`.", call. = FALSE)
  }
  if (
    !identical(payload$relationship_source, "markers") ||
      is.null(payload$markers)
  ) {
    stop(
      "Internal bridge error: SNP-BLUP requires a marker-matrix genomic payload.",
      call. = FALSE
    )
  }
  if (!hs_julia_bridge_available(project)) {
    stop(
      "The experimental Julia bridge requires Julia, the `JuliaCall` R ",
      "package, and a local `HSquared.jl` project.",
      call. = FALSE
    )
  }

  markers_ind <- payload$markers
  markers_rec <- as.matrix(payload$Z %*% markers_ind)

  hs_julia_setup(project)
  JuliaCall::julia_assign("hsq_y", payload$y)
  JuliaCall::julia_assign("hsq_X", payload$X)
  JuliaCall::julia_assign("hsq_markers_rec", markers_rec)
  JuliaCall::julia_assign("hsq_markers_ind", unname(markers_ind))
  JuliaCall::julia_command(paste(
    "hsq_snp = HSquared.fit_snp_blup_reml(hsq_y, hsq_X, hsq_markers_rec);",
    # Per-individual GEBV at the same allele-frequency centering as the fit.
    "hsq_Wind = HSquared.centered_markers(",
    "hsq_markers_ind; allele_frequencies = hsq_snp.p).W;",
    "hsq_gebv_ind = hsq_Wind * hsq_snp.marker_effects;",
    "hsq_fitted = hsq_X * hsq_snp.beta .+ hsq_snp.gebv;",
    "hsq_snp_raw = Dict(",
    "\"marker_effects\" => hsq_snp.marker_effects,",
    "\"gebv\" => hsq_gebv_ind,",
    "\"beta\" => hsq_snp.beta,",
    "\"p\" => hsq_snp.p,",
    "\"fitted\" => hsq_fitted,",
    "\"k\" => hsq_snp.k,",
    "\"sigma_g2\" => hsq_snp.sigma_g2,",
    "\"sigma_e2\" => hsq_snp.sigma_e2,",
    "\"loglik\" => hsq_snp.loglik,",
    "\"converged\" => hsq_snp.converged,",
    "\"nobs\" => length(hsq_y)",
    ");"
  ))

  raw <- JuliaCall::julia_eval("hsq_snp_raw")
  estimated_vc <- c(
    sigma_g2 = as.numeric(raw$sigma_g2),
    sigma_e2 = as.numeric(raw$sigma_e2)
  )
  result <- hs_normalize_julia_snp_blup_result(
    raw,
    payload,
    estimated_vc,
    provenance = "estimated_snp_blup_reml",
    converged = isTRUE(raw$converged),
    loglik = as.numeric(raw$loglik)
  )
  # df for AIC/BIC: the fixed effects + the two REML-estimated variance
  # components (sigma_g2, sigma_e2). The marker effects are random (BLUP), not
  # free parameters. (The supplied-variance path estimates no VCs, so no df.)
  result$df <- as.integer(ncol(payload$X) + 2L)
  hs_new_fit(
    spec = list(
      method = "SNP-BLUP-REML",
      family = list(family = payload$family, link = "identity"),
      target = "snp_blup"
    ),
    payload = payload,
    result = result,
    engine = "HSquared.jl"
  )
}

hs_normalize_julia_snp_blup_result <- function(
  raw,
  payload,
  variance_components,
  provenance = "supplied",
  converged = TRUE,
  loglik = NULL
) {
  sigma_g2 <- unname(variance_components[["sigma_g2"]])
  sigma_e2 <- unname(variance_components[["sigma_e2"]])

  fixed_effects <- as.numeric(raw$beta)
  fixed_names <- payload$metadata$fixed_colnames
  if (length(fixed_effects) == length(fixed_names)) {
    names(fixed_effects) <- fixed_names
  }

  ids <- as.character(payload$ids)
  genomic_bv <- data.frame(id = ids, value = as.numeric(raw$gebv))

  effects <- as.numeric(raw$marker_effects)
  marker_labels <- payload$marker_names
  if (is.null(marker_labels) || length(marker_labels) != length(effects)) {
    marker_labels <- as.character(seq_along(effects))
  }
  markers_rec <- if (!is.null(payload$Z)) {
    as.matrix(payload$Z %*% payload$markers)
  } else {
    payload$markers
  }
  marker_allele_frequencies <- if (!is.null(raw$p)) as.numeric(raw$p) else NULL

  list(
    variance_components = data.frame(
      component = c("genomic", "residual"),
      estimate = c(sigma_g2, sigma_e2)
    ),
    heritability = data.frame(
      term = "genomic",
      estimate = sigma_g2 / (sigma_g2 + sigma_e2)
    ),
    breeding_values = genomic_bv,
    fixed_effects = fixed_effects,
    marker_effects = data.frame(
      marker = as.character(marker_labels),
      effect = effects
    ),
    marker_allele_frequencies = marker_allele_frequencies,
    marker_variance_explained = hs_marker_variance_explained_from_snp_blup(
      effects = effects,
      markers = markers_rec,
      marker_labels = marker_labels,
      allele_frequencies = marker_allele_frequencies
    ),
    random_effects = list(genomic = genomic_bv),
    predictions = data.frame(.fitted = as.numeric(raw$fitted)),
    nobs = as.integer(raw$nobs),
    loglik = loglik,
    diagnostics = list(
      target = "snp_blup",
      variance_components = provenance,
      optimizer_status = if (identical(provenance, "supplied")) {
        "not_run"
      } else if (isTRUE(converged)) {
        "converged"
      } else {
        "not_converged"
      },
      n_markers = length(effects)
    ),
    converged = isTRUE(converged)
  )
}

hs_marker_variance_explained_from_snp_blup <- function(
  effects,
  markers,
  marker_labels = NULL,
  allele_frequencies = NULL
) {
  effects <- as.numeric(effects)
  markers <- as.matrix(markers)

  if (!is.numeric(markers) || ncol(markers) != length(effects)) {
    stop(
      "Internal bridge error: marker effects and marker matrix columns are ",
      "not aligned.",
      call. = FALSE
    )
  }
  if (nrow(markers) < 1L || ncol(markers) < 1L) {
    stop("Internal bridge error: marker matrix is empty.", call. = FALSE)
  }
  if (any(!is.finite(effects)) || any(!is.finite(markers))) {
    stop(
      "Internal bridge error: marker variance explained requires finite ",
      "marker effects and marker dosages.",
      call. = FALSE
    )
  }
  if (!is.null(allele_frequencies)) {
    allele_frequencies <- as.numeric(allele_frequencies)
    if (
      length(allele_frequencies) != ncol(markers) ||
        any(!is.finite(allele_frequencies))
    ) {
      stop(
        "Internal bridge error: allele frequencies must align with marker ",
        "columns.",
        call. = FALSE
      )
    }
    if (any(allele_frequencies < 0 | allele_frequencies > 1)) {
      stop(
        "Internal bridge error: allele frequencies must lie in [0, 1].",
        call. = FALSE
      )
    }
  }

  if (is.null(marker_labels) || length(marker_labels) != length(effects)) {
    marker_labels <- colnames(markers)
  }
  if (is.null(marker_labels) || length(marker_labels) != length(effects)) {
    marker_labels <- as.character(seq_along(effects))
  }

  center <- if (is.null(allele_frequencies)) {
    colMeans(markers)
  } else {
    2 * allele_frequencies
  }
  centered <- sweep(markers, 2L, center, check.margin = FALSE)
  centered_marker_variance <- colMeans(centered^2)
  contribution <- centered_marker_variance * effects^2
  total <- sum(contribution)
  proportion <- if (isTRUE(total > 0)) {
    contribution / total
  } else {
    rep(NA_real_, length(contribution))
  }

  data.frame(
    marker = as.character(marker_labels),
    effect = effects,
    centered_marker_variance = as.numeric(centered_marker_variance),
    contribution = as.numeric(contribution),
    proportion = as.numeric(proportion),
    stringsAsFactors = FALSE
  )
}

hs_julia_setup <- function(project) {
  project <- normalizePath(project, winslash = "/", mustWork = TRUE)
  if (
    isTRUE(hs_julia_bridge_state$initialized) &&
      identical(hs_julia_bridge_state$project, project)
  ) {
    return(invisible(TRUE))
  }

  JuliaCall::julia_setup(installJulia = FALSE, verbose = FALSE)
  JuliaCall::julia_assign("hsq_project", project)
  JuliaCall::julia_command(
    "using Pkg; Pkg.activate(hsq_project); using HSquared; using SparseArrays;"
  )
  hs_julia_bridge_state$initialized <- TRUE
  hs_julia_bridge_state$project <- project
  invisible(TRUE)
}

hs_julia_assign_payload <- function(payload, initial) {
  JuliaCall::julia_assign("hsq_y", payload$y)
  JuliaCall::julia_assign("hsq_X", payload$X)
  hs_julia_assign_sparse_csc("hsq_Z", payload$Z)
  JuliaCall::julia_assign("hsq_id", payload$pedigree$id)
  JuliaCall::julia_assign(
    "hsq_sire",
    hs_parent_for_julia(payload$pedigree$sire)
  )
  JuliaCall::julia_assign("hsq_dam", hs_parent_for_julia(payload$pedigree$dam))
  JuliaCall::julia_assign("hsq_method", payload$method)
  JuliaCall::julia_assign("hsq_initial_sigma_a2", unname(initial[["sigma_a2"]]))
  JuliaCall::julia_assign("hsq_initial_sigma_e2", unname(initial[["sigma_e2"]]))
  invisible(TRUE)
}

hs_julia_assign_sparse_csc <- function(name, x) {
  slots <- hs_sparse_csc_slots(x)
  JuliaCall::julia_assign(paste0(name, "_nrow"), slots$nrow)
  JuliaCall::julia_assign(paste0(name, "_ncol"), slots$ncol)
  JuliaCall::julia_assign(paste0(name, "_colptr"), slots$colptr)
  JuliaCall::julia_assign(paste0(name, "_rowval"), slots$rowval)
  JuliaCall::julia_assign(paste0(name, "_nzval"), slots$nzval)
  JuliaCall::julia_command(paste0(
    name,
    " = HSquared.sparse_csc_matrix(",
    name,
    "_nrow, ",
    name,
    "_ncol, ",
    name,
    "_colptr, ",
    name,
    "_rowval, ",
    name,
    "_nzval; index_base = :zero);"
  ))
  invisible(TRUE)
}

hs_sparse_csc_slots <- function(x) {
  if (!inherits(x, "dgCMatrix")) {
    stop("`x` must be a `Matrix::dgCMatrix` object.", call. = FALSE)
  }

  list(
    nrow = as.integer(nrow(x)),
    ncol = as.integer(ncol(x)),
    colptr = as.integer(x@p),
    rowval = as.integer(x@i),
    nzval = as.numeric(x@x)
  )
}

hs_parent_for_julia <- function(x) {
  x <- as.character(x)
  x[is.na(x)] <- "0"
  x
}

hs_validate_initial_variances <- function(initial) {
  if (
    is.null(names(initial)) ||
      !all(c("sigma_a2", "sigma_e2") %in% names(initial))
  ) {
    stop(
      "`initial` must include `sigma_a2` and `sigma_e2`.",
      call. = FALSE
    )
  }
  out <- as.numeric(initial[c("sigma_a2", "sigma_e2")])
  names(out) <- c("sigma_a2", "sigma_e2")
  if (any(!is.finite(out)) || any(out <= 0)) {
    stop(
      "`initial` variance values must be positive and finite.",
      call. = FALSE
    )
  }
  out
}

hs_validate_iterations <- function(iterations) {
  iterations <- suppressWarnings(as.integer(iterations))
  if (length(iterations) != 1L || is.na(iterations) || iterations <= 0L) {
    stop("`iterations` must be a single positive integer.", call. = FALSE)
  }
  iterations
}

# em_warmup: opt-in EM-REML warm-start iterations before the AI/Newton step (engine
# `fit_ai_reml`, V1-AI-REML). 0 (default) = off / byte-identical to the pre-warm-start path.
hs_validate_em_warmup <- function(em_warmup) {
  em_warmup <- suppressWarnings(as.integer(em_warmup))
  if (length(em_warmup) != 1L || is.na(em_warmup) || em_warmup < 0L) {
    stop("`em_warmup` must be a single non-negative integer.", call. = FALSE)
  }
  em_warmup
}

hs_validate_julia_target <- function(target) {
  if (!is.character(target) || length(target) != 1L || is.na(target)) {
    stop(
      "`engine_control$target` must be a single string.",
      call. = FALSE
    )
  }
  if (
    !target %in%
      c(
        "fit_animal_model",
        "henderson_mme",
        "metafounder",
        "sparse_reml",
        "ai_reml",
        "repeatability",
        "two_effect",
        "genomic",
        "single_step",
        "single_step_construct",
        "metafounder_single_step",
        "snp_blup",
        "multivariate",
        "random_regression",
        "nongaussian"
      )
  ) {
    stop(
      "`engine_control$target` must be one of \"fit_animal_model\", ",
      "\"henderson_mme\", \"sparse_reml\", \"ai_reml\", \"repeatability\", ",
      "\"metafounder\", \"two_effect\", \"genomic\", \"single_step\", ",
      "\"single_step_construct\", \"metafounder_single_step\", \"snp_blup\", \"multivariate\", ",
      "\"random_regression\", or \"nongaussian\".",
      call. = FALSE
    )
  }
  target
}

hs_validate_genetic_structure_control <- function(control, target) {
  value <- hs_engine_control_value(control, "genetic_structure", NULL)
  if (is.null(value)) {
    return("unstructured")
  }
  if (!is.character(value) || length(value) != 1L || is.na(value)) {
    stop(
      "`engine_control$genetic_structure` must be a single string.",
      call. = FALSE
    )
  }
  allowed <- c("unstructured", "diagonal", "lowrank", "factor_analytic")
  if (!value %in% allowed) {
    stop(
      "`engine_control$genetic_structure` must be one of \"unstructured\", ",
      "\"diagonal\", \"lowrank\", or \"factor_analytic\".",
      call. = FALSE
    )
  }
  if (!identical(target, "multivariate")) {
    stop(
      "`engine_control$genetic_structure` is only planned for the ",
      "`target = \"multivariate\"` bridge. Remove `genetic_structure`, or use ",
      "`target = \"multivariate\"` with a `cbind(...)` response.",
      call. = FALSE
    )
  }
  if (value %in% c("lowrank", "factor_analytic")) {
    stop(
      "Structured multivariate genetic covariance controls ",
      "(`genetic_structure = \"lowrank\"` or \"factor_analytic\") are planned, ",
      "not implemented in the R bridge: they are gated on a validated ",
      "rotation/interpretation convention for the loadings. The opt-in ",
      "multivariate path estimates `\"unstructured\"` or `\"diagonal\"` G0; use ",
      "one of those.",
      call. = FALSE
    )
  }
  # "unstructured" (default) and "diagonal" are both reachable. "diagonal" has
  # no loadings and no rotation ambiguity (it is just per-trait genetic
  # variances with zero genetic covariances), so it is honesty-clean to surface
  # ahead of lowrank/factor_analytic.
  rank <- hs_engine_control_value(control, "rank", NULL)
  if (!is.null(rank)) {
    if (
      !is.numeric(rank) ||
        length(rank) != 1L ||
        is.na(rank) ||
        !is.finite(rank) ||
        rank < 1L ||
        rank != as.integer(rank)
    ) {
      stop(
        "`engine_control$rank` must be a single positive integer.",
        call. = FALSE
      )
    }
    stop(
      "`engine_control$rank` is reserved for future `lowrank` and ",
      "`factor_analytic` structured covariance controls. The current ",
      "multivariate bridge estimates unstructured or diagonal G0 with ",
      "unstructured R0 only; remove `rank` until low-rank or ",
      "factor-analytic support is available.",
      call. = FALSE
    )
  }
  value
}

# All opt-in engine targets that can fit a given non-default random effect. A
# genomic marker primary fits either by GREML on the built relationship
# (`genomic`) or as a marker-effect model (`snp_blup`; supplied-variance, or
# REML-estimated when variances are omitted).
hs_effect_targets <- function(type) {
  switch(
    type,
    permanent = "repeatability",
    common_env = "two_effect",
    maternal_genetic = "two_effect",
    metafounder = "metafounder",
    genomic = c("genomic", "snp_blup"),
    single_step = c(
      "single_step",
      "single_step_construct",
      "metafounder_single_step"
    ),
    stop("Unknown random effect type: ", type, call. = FALSE)
  )
}

# Map a parsed second random effect to the opt-in engine target that fits it.
# Map a parsed non-default random effect (a second effect, or the genomic
# primary effect) to the opt-in engine target that fits it.
hs_second_effect_target <- function(type) {
  switch(
    type,
    permanent = "repeatability",
    common_env = "two_effect",
    maternal_genetic = "two_effect",
    metafounder = "metafounder",
    genomic = "genomic",
    single_step = "single_step",
    stop("Unknown random effect type: ", type, call. = FALSE)
  )
}

hs_validate_supplied_variances <- function(
  variance_components,
  target = "henderson_mme"
) {
  if (is.null(variance_components)) {
    stop(
      "`engine_control$variance_components` is required when ",
      "`target = \"",
      target,
      "\"`.",
      call. = FALSE
    )
  }
  if (
    is.null(names(variance_components)) ||
      !all(c("sigma_a2", "sigma_e2") %in% names(variance_components))
  ) {
    stop(
      "`engine_control$variance_components` must include `sigma_a2` and ",
      "`sigma_e2`.",
      call. = FALSE
    )
  }
  out <- as.numeric(variance_components[c("sigma_a2", "sigma_e2")])
  names(out) <- c("sigma_a2", "sigma_e2")
  if (any(!is.finite(out)) || any(out <= 0)) {
    stop(
      "`engine_control$variance_components` values must be positive and ",
      "finite.",
      call. = FALSE
    )
  }
  out
}

hs_validate_snp_blup_variances <- function(variance_components) {
  if (is.null(variance_components)) {
    stop(
      "`engine_control$variance_components` is required when ",
      "`target = \"snp_blup\"` (named `sigma_g2` and `sigma_e2`).",
      call. = FALSE
    )
  }
  if (
    is.null(names(variance_components)) ||
      !all(c("sigma_g2", "sigma_e2") %in% names(variance_components))
  ) {
    stop(
      "`engine_control$variance_components` must include `sigma_g2` (genomic) ",
      "and `sigma_e2` (residual) for `target = \"snp_blup\"`.",
      call. = FALSE
    )
  }
  out <- as.numeric(variance_components[c("sigma_g2", "sigma_e2")])
  names(out) <- c("sigma_g2", "sigma_e2")
  if (any(!is.finite(out)) || any(out <= 0)) {
    stop(
      "`engine_control$variance_components` values must be positive and ",
      "finite.",
      call. = FALSE
    )
  }
  out
}

hs_plot_data_try <- function(expr) {
  tryCatch(expr, error = function(e) NULL)
}

hs_plot_data_list <- function(x) {
  if (is.null(x)) {
    return(NULL)
  }
  x <- hs_drop_julia_classes(x)
  if (is.data.frame(x)) {
    x <- as.list(x)
  }
  if (!is.list(x)) {
    return(NULL)
  }
  x
}

hs_plot_data_character <- function(x, n = NULL) {
  if (is.null(x)) {
    return(NULL)
  }
  out <- as.character(x)
  if (!is.null(n) && length(out) != n) {
    return(NULL)
  }
  out
}

hs_plot_data_numeric <- function(x, n = NULL) {
  if (is.null(x)) {
    return(NULL)
  }
  out <- as.numeric(x)
  if (!is.null(n) && length(out) != n) {
    return(NULL)
  }
  out
}

hs_plot_data_scalar <- function(x) {
  if (is.null(x) || length(x) < 1L) {
    return(NULL)
  }
  x[[1L]]
}

hs_plot_data_matrix <- function(x, nr = NULL, nc = NULL) {
  if (is.null(x)) {
    return(NULL)
  }
  out <- as.matrix(x)
  storage.mode(out) <- "double"
  if (!is.null(nr) && !is.null(nc)) {
    if (!identical(dim(out), c(nr, nc))) {
      if (length(out) != nr * nc) {
        return(NULL)
      }
      out <- matrix(as.numeric(out), nrow = nr, ncol = nc)
    }
  } else if (!is.null(nr) && nrow(out) != nr) {
    if (length(out) %% nr != 0L) {
      return(NULL)
    }
    out <- matrix(as.numeric(out), nrow = nr)
  }
  out
}

hs_normalize_variance_components_plot_data <- function(pd) {
  pd <- hs_plot_data_list(pd)
  if (is.null(pd)) {
    return(NULL)
  }
  term <- hs_plot_data_character(pd$term)
  estimate <- hs_plot_data_numeric(pd$estimate)
  if (is.null(term) || is.null(estimate) || length(term) != length(estimate)) {
    return(NULL)
  }
  n <- length(term)
  out <- list(term = term, estimate = estimate)
  lo <- hs_plot_data_numeric(pd$lo, n)
  hi <- hs_plot_data_numeric(pd$hi, n)
  panel <- hs_plot_data_character(pd$panel, n)
  if (!is.null(lo)) {
    out$lo <- lo
  }
  if (!is.null(hi)) {
    out$hi <- hi
  }
  if (!is.null(panel)) {
    out$panel <- panel
  }
  interval_status <- hs_plot_data_scalar(pd$interval_status)
  interval_method <- hs_plot_data_scalar(pd$interval_method)
  if (!is.null(interval_status)) {
    out$interval_status <- as.character(interval_status)
  }
  if (!is.null(interval_method)) {
    out$interval_method <- as.character(interval_method)
  }
  out
}

hs_normalize_breeding_values_plot_data <- function(pd) {
  pd <- hs_plot_data_list(pd)
  if (is.null(pd)) {
    return(NULL)
  }
  id <- hs_plot_data_character(pd$id %||% pd$ids)
  value <- hs_plot_data_numeric(
    pd$value %||% pd$values %||% pd$breeding_value %||% pd$breeding_values
  )
  if (is.null(id) || is.null(value) || length(id) != length(value)) {
    return(NULL)
  }
  n <- length(id)
  out <- list(id = id, value = value)
  trait <- hs_plot_data_character(pd$trait, n)
  pev <- hs_plot_data_numeric(pd$pev %||% pd$prediction_error_variance, n)
  if (
    !is.null(trait) &&
      !(length(unique(trait)) == 1L && unique(trait) %in% c("1", "trait_1"))
  ) {
    out$trait <- trait
  }
  if (!is.null(pev)) {
    out$pev <- pev
  }
  pev_scale <- hs_plot_data_scalar(pd$pev_scale)
  if (!is.null(pev_scale)) {
    out$pev_scale <- as.character(pev_scale)
  }
  out
}

hs_attach_standard_plot_data <- function(result, raw) {
  vcpd <- hs_plot_data_try(
    hs_normalize_variance_components_plot_data(
      raw$variance_components_plot_data
    )
  )
  if (!is.null(vcpd)) {
    result$variance_components_plot_data <- vcpd
  }
  bvpd <- hs_plot_data_try(
    hs_normalize_breeding_values_plot_data(raw$breeding_values_plot_data)
  )
  if (!is.null(bvpd)) {
    result$breeding_values_plot_data <- bvpd
  }
  result
}

hs_normalize_genetic_correlation_plot_data <- function(pd, traits = NULL) {
  pd <- hs_plot_data_list(pd)
  if (is.null(pd) || is.null(pd$genetic_correlations)) {
    return(NULL)
  }
  rg <- hs_plot_data_matrix(pd$genetic_correlations)
  if (is.null(rg) || nrow(rg) != ncol(rg)) {
    return(NULL)
  }
  pd_traits <- hs_plot_data_character(pd$traits)
  traits <- pd_traits %||% traits
  if (is.null(traits) || length(traits) != nrow(rg)) {
    traits <- paste0("trait_", seq_len(nrow(rg)))
  }
  dimnames(rg) <- list(traits, traits)
  out <- list(
    traits = as.character(traits),
    genetic_correlations = rg,
    rotation_invariant = isTRUE(hs_plot_data_scalar(pd$rotation_invariant))
  )
  h2 <- hs_plot_data_numeric(pd$heritabilities, length(traits))
  if (!is.null(h2)) {
    out$heritabilities <- h2
  }
  out
}

hs_normalize_genetic_pca_plot_data <- function(pd) {
  pd <- hs_plot_data_list(pd)
  if (is.null(pd)) {
    return(NULL)
  }
  eigenvalues <- hs_plot_data_numeric(pd$eigenvalues)
  if (is.null(eigenvalues)) {
    return(NULL)
  }
  n <- length(eigenvalues)
  out <- list(
    eigenvalues = eigenvalues,
    rotation_invariant = isTRUE(hs_plot_data_scalar(pd$rotation_invariant)),
    is_eigenstructure_not_loadings = isTRUE(hs_plot_data_scalar(
      pd$is_eigenstructure_not_loadings
    ))
  )
  variance_explained <- hs_plot_data_numeric(pd$variance_explained, n)
  axis_labels <- hs_plot_data_character(pd$axis_labels, n)
  if (!is.null(variance_explained)) {
    out$variance_explained <- variance_explained
  }
  if (!is.null(axis_labels)) {
    out$axis_labels <- axis_labels
  }
  out
}

hs_attach_multivariate_plot_data <- function(result, raw, traits = NULL) {
  gcpd <- hs_plot_data_try(
    hs_normalize_genetic_correlation_plot_data(
      raw$genetic_correlation_plot_data,
      traits
    )
  )
  if (!is.null(gcpd)) {
    result$genetic_correlation_plot_data <- gcpd
  }
  gppd <- hs_plot_data_try(
    hs_normalize_genetic_pca_plot_data(raw$genetic_pca_plot_data)
  )
  if (!is.null(gppd)) {
    result$genetic_pca_plot_data <- gppd
  }
  result
}

hs_rr_payload_covariate <- function(pd, rr) {
  cov <- hs_plot_data_numeric(pd$covariate)
  if (is.null(cov)) {
    return(NULL)
  }
  hs_unstandardize_covariate(cov, rr$lower, rr$upper)
}

hs_normalize_rr_genetic_variance_plot_data <- function(pd, rr) {
  pd <- hs_plot_data_list(pd)
  if (is.null(pd)) {
    return(NULL)
  }
  cov <- hs_rr_payload_covariate(pd, rr)
  value <- hs_plot_data_numeric(pd$value %||% pd$genetic_variance)
  if (is.null(cov) || is.null(value) || length(cov) != length(value)) {
    return(NULL)
  }
  n <- length(cov)
  out <- list(covariate = cov, value = value, genetic_variance = value)
  h2 <- hs_plot_data_numeric(pd$heritability, n)
  if (!is.null(h2)) {
    out$heritability <- h2
  }
  basis_order <- hs_plot_data_scalar(pd$basis_order)
  supplied <- hs_plot_data_scalar(pd$supplied)
  if (!is.null(basis_order)) {
    out$basis_order <- as.integer(basis_order)
  }
  if (!is.null(supplied)) {
    out$supplied <- isTRUE(supplied)
  }
  out
}

hs_normalize_rr_eigenfunctions_plot_data <- function(pd, rr) {
  pd <- hs_plot_data_list(pd)
  if (is.null(pd)) {
    return(NULL)
  }
  cov <- hs_rr_payload_covariate(pd, rr)
  if (is.null(cov)) {
    return(NULL)
  }
  eigenfunctions <- hs_plot_data_matrix(pd$eigenfunctions, nr = length(cov))
  if (is.null(eigenfunctions)) {
    return(NULL)
  }
  k <- ncol(eigenfunctions)
  out <- list(
    covariate = cov,
    eigenfunctions = eigenfunctions,
    rotation_invariant = isTRUE(hs_plot_data_scalar(pd$rotation_invariant))
  )
  variance_explained <- hs_plot_data_numeric(pd$variance_explained, k)
  axis <- hs_plot_data_numeric(pd$axis, k)
  if (!is.null(variance_explained)) {
    out$variance_explained <- variance_explained
  }
  if (!is.null(axis)) {
    out$axis <- as.integer(axis)
  }
  out
}

hs_normalize_rr_covariance_surface_plot_data <- function(pd, rr) {
  pd <- hs_plot_data_list(pd)
  if (is.null(pd)) {
    return(NULL)
  }
  cov <- hs_rr_payload_covariate(pd, rr)
  if (is.null(cov)) {
    return(NULL)
  }
  surface <- hs_plot_data_matrix(pd$surface, nr = length(cov), nc = length(cov))
  if (is.null(surface)) {
    return(NULL)
  }
  list(
    covariate = cov,
    surface = surface,
    is_correlation = isTRUE(hs_plot_data_scalar(pd$is_correlation))
  )
}

hs_attach_random_regression_plot_data <- function(result, raw) {
  rr <- result$random_regression
  gvpd <- hs_plot_data_try(
    hs_normalize_rr_genetic_variance_plot_data(
      raw$rr_genetic_variance_plot_data,
      rr
    )
  )
  if (!is.null(gvpd)) {
    result$rr_genetic_variance_plot_data <- gvpd
  }
  efpd <- hs_plot_data_try(
    hs_normalize_rr_eigenfunctions_plot_data(
      raw$rr_eigenfunctions_plot_data,
      rr
    )
  )
  if (!is.null(efpd)) {
    result$rr_eigenfunctions_plot_data <- efpd
  }
  sfpd <- hs_plot_data_try(
    hs_normalize_rr_covariance_surface_plot_data(
      raw$rr_covariance_surface_plot_data,
      rr
    )
  )
  if (!is.null(sfpd)) {
    result$rr_covariance_surface_plot_data <- sfpd
  }
  result
}

hs_normalize_julia_result <- function(raw, payload) {
  breeding_values <- raw$breeding_values
  animal <- raw$random_effects$animal

  fixed_effects <- as.numeric(raw$fixed_effects)
  fixed_names <- payload$metadata$fixed_colnames
  if (length(fixed_effects) == length(fixed_names)) {
    names(fixed_effects) <- fixed_names
  }

  result <- list(
    variance_components = data.frame(
      component = c("animal", "residual"),
      estimate = c(
        raw$variance_components$sigma_a2,
        raw$variance_components$sigma_e2
      )
    ),
    heritability = data.frame(
      term = "animal",
      estimate = raw$heritability
    ),
    breeding_values = data.frame(
      id = as.character(breeding_values$ids),
      value = as.numeric(breeding_values$values)
    ),
    fixed_effects = fixed_effects,
    random_effects = list(
      animal = data.frame(
        id = as.character(animal$ids),
        value = as.numeric(animal$values)
      )
    ),
    loglik = as.numeric(raw$loglik),
    df = as.integer(raw$df),
    nobs = as.integer(raw$nobs),
    predictions = data.frame(.fitted = as.numeric(raw$predictions)),
    diagnostics = hs_drop_julia_classes(raw$diagnostics),
    converged = isTRUE(raw$converged)
  )

  if (!is.null(raw$prediction_error_variance)) {
    result$prediction_error_variance <- hs_julia_id_values(
      raw$prediction_error_variance
    )
  }
  if (!is.null(raw$reliability)) {
    result$reliability <- hs_julia_id_values(raw$reliability)
  }
  if (!is.null(raw$heritability_interval)) {
    result$heritability_interval <- hs_normalize_heritability_interval(
      raw$heritability_interval
    )
  }
  if (!is.null(raw$variance_component_se)) {
    result$variance_component_se <- hs_normalize_variance_component_se(
      raw$variance_component_se
    )
  }
  if (!is.null(raw$heritability_se)) {
    result$heritability_se <- as.numeric(raw$heritability_se)
  }

  result <- hs_attach_standard_plot_data(result, raw)
  result
}

# Normalize the engine's heritability_interval NamedTuple
# (heritability, lower, upper, level, [se], method) into a one-row data frame.
# `se` is absent for the profile method.
hs_normalize_heritability_interval <- function(hi) {
  data.frame(
    estimate = as.numeric(hi$heritability),
    lower = as.numeric(hi$lower),
    upper = as.numeric(hi$upper),
    level = as.numeric(hi$level),
    se = if (!is.null(hi$se)) as.numeric(hi$se) else NA_real_,
    method = as.character(hi$method),
    stringsAsFactors = FALSE
  )
}

# Normalize the engine's variance_component_standard_errors NamedTuple
# (sigma_a2, sigma_e2) into a data frame of component standard errors.
hs_normalize_variance_component_se <- function(vcse) {
  data.frame(
    component = c("animal", "residual"),
    se = c(as.numeric(vcse$sigma_a2), as.numeric(vcse$sigma_e2)),
    stringsAsFactors = FALSE
  )
}

# Normalize the engine's repeatability_interval NamedTuple
# (repeatability, lower, upper, level, se) into a one-row data frame. This is the
# delta-method CI for the repeatability coefficient t = (Va + Vpe)/Vp (engine row
# V3-REPEAT-REML, partial), not for h2; the engine offers only the delta method
# for t, so there is no `method` column.
hs_normalize_repeatability_interval <- function(ri) {
  data.frame(
    estimate = as.numeric(ri$repeatability),
    lower = as.numeric(ri$lower),
    upper = as.numeric(ri$upper),
    level = as.numeric(ri$level),
    se = as.numeric(ri$se),
    stringsAsFactors = FALSE
  )
}

hs_normalize_julia_henderson_mme_result <- function(
  raw,
  payload,
  variance_components
) {
  fixed_effects <- as.numeric(raw$fixed_effects)
  fixed_names <- payload$metadata$fixed_colnames
  if (length(fixed_effects) == length(fixed_names)) {
    names(fixed_effects) <- fixed_names
  }

  animal <- data.frame(
    id = as.character(raw$animal_ids),
    value = as.numeric(raw$animal_effects)
  )

  result <- list(
    variance_components = data.frame(
      component = c("animal", "residual"),
      estimate = c(
        unname(variance_components[["sigma_a2"]]),
        unname(variance_components[["sigma_e2"]])
      )
    ),
    heritability = data.frame(
      term = "animal",
      estimate = unname(variance_components[["sigma_a2"]]) /
        sum(unname(variance_components))
    ),
    breeding_values = animal,
    fixed_effects = fixed_effects,
    random_effects = list(animal = animal),
    predictions = data.frame(.fitted = as.numeric(raw$fitted)),
    nobs = as.integer(raw$nobs),
    diagnostics = list(
      target = "henderson_mme",
      variance_components = "supplied",
      optimizer_status = "not_run"
    ),
    converged = TRUE
  )

  if (!is.null(raw$prediction_error_variance)) {
    result$prediction_error_variance <- hs_julia_id_values(
      raw$prediction_error_variance
    )
  }
  if (!is.null(raw$reliability)) {
    result$reliability <- hs_julia_id_values(raw$reliability)
  }

  result
}

hs_julia_id_values <- function(x) {
  data.frame(
    id = as.character(x$ids),
    value = as.numeric(x$values)
  )
}

hs_drop_julia_classes <- function(x) {
  if (is.list(x)) {
    x <- lapply(x, hs_drop_julia_classes)
    class(x) <- NULL
  }
  x
}
