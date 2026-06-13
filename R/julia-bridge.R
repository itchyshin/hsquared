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
  hs_new_fit(
    spec = list(
      method = payload$method,
      family = list(family = payload$family, link = "identity"),
      target = "sparse_reml"
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
  if (!target %in% c("fit_animal_model", "henderson_mme", "sparse_reml")) {
    stop(
      "`engine_control$target` must be one of \"fit_animal_model\", ",
      "\"henderson_mme\", or \"sparse_reml\".",
      call. = FALSE
    )
  }
  target
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
