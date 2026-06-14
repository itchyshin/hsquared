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
    "if isdefined(HSquared, :prediction_error_variance) &&",
    "isdefined(HSquared, :reliability);",
    "hsq_result = merge(hsq_result, (",
    "prediction_error_variance =",
    "HSquared.prediction_error_variance(hsq_fit),",
    "reliability = HSquared.reliability(hsq_fit)));",
    "end;"
  ))

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
    "\"nobs\" => length(hsq_y)",
    ");",
    "if isdefined(HSquared, :prediction_error_variance) &&",
    "isdefined(HSquared, :reliability) &&",
    "applicable(HSquared.prediction_error_variance, hsq_mme) &&",
    "applicable(HSquared.reliability, hsq_mme);",
    "hsq_mme_raw[\"prediction_error_variance\"] =",
    "HSquared.prediction_error_variance(hsq_mme);",
    "hsq_mme_raw[\"reliability\"] = HSquared.reliability(hsq_mme);",
    "end;"
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
    "if isdefined(HSquared, :prediction_error_variance) &&",
    "isdefined(HSquared, :reliability) &&",
    "applicable(HSquared.prediction_error_variance, hsq_fit) &&",
    "applicable(HSquared.reliability, hsq_fit);",
    "hsq_result = merge(hsq_result, (",
    "prediction_error_variance =",
    "HSquared.prediction_error_variance(hsq_fit),",
    "reliability = HSquared.reliability(hsq_fit)));",
    "end;"
  ))

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
  iterations = 100L
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
    "hsq_fit = HSquared.fit_ai_reml(",
    "hsq_spec;",
    "initial = (sigma_a2 = hsq_initial_sigma_a2,",
    "sigma_e2 = hsq_initial_sigma_e2),",
    "iterations = hsq_iterations);",
    "hsq_result = HSquared.result_payload(hsq_fit);",
    "if isdefined(HSquared, :prediction_error_variance) &&",
    "isdefined(HSquared, :reliability) &&",
    "applicable(HSquared.prediction_error_variance, hsq_fit) &&",
    "applicable(HSquared.reliability, hsq_fit);",
    "hsq_result = merge(hsq_result, (",
    "prediction_error_variance =",
    "HSquared.prediction_error_variance(hsq_fit),",
    "reliability = HSquared.reliability(hsq_fit)));",
    "end;"
  ))

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
  if (is.null(payload$Ginv)) {
    stop(
      "Internal bridge error: the genomic payload is missing its `Ginv`.",
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
  JuliaCall::julia_assign("hsq_Ginv", payload$Ginv)
  JuliaCall::julia_assign("hsq_ids", payload$ids)
  JuliaCall::julia_assign("hsq_initial_sigma_a2", unname(initial[["sigma_a2"]]))
  JuliaCall::julia_assign("hsq_initial_sigma_e2", unname(initial[["sigma_e2"]]))
  JuliaCall::julia_assign("hsq_iterations", iterations)
  JuliaCall::julia_command(paste(
    "hsq_Ginvs = sparse(hsq_Ginv);",
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
        "sparse_reml",
        "ai_reml",
        "repeatability",
        "two_effect",
        "genomic",
        "single_step"
      )
  ) {
    stop(
      "`engine_control$target` must be one of \"fit_animal_model\", ",
      "\"henderson_mme\", \"sparse_reml\", \"ai_reml\", \"repeatability\", ",
      "\"two_effect\", \"genomic\", or \"single_step\".",
      call. = FALSE
    )
  }
  target
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
    genomic = "genomic",
    single_step = "single_step",
    stop("Unknown random effect type: ", type, call. = FALSE)
  )
}

hs_validate_supplied_variances <- function(variance_components) {
  if (is.null(variance_components)) {
    stop(
      "`engine_control$variance_components` is required when ",
      "`target = \"henderson_mme\"`.",
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

  result
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
