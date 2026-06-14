hs_build_model_spec <- function(formula, data, family, REML) {
  env <- environment(formula)
  if (is.null(env)) {
    env <- parent.frame()
  }
  model_data <- hs_model_data_context(data, env)
  data <- model_data$data
  env <- model_data$env

  hs_validate_model_inputs(formula, data, family, REML)

  rhs_terms <- hs_split_additive_rhs(formula[[3L]])
  # Planned QG markers the parser now consumes: `permanent()`/`common_env()`/
  # `maternal_genetic()` as the second random effect of an opt-in two-effect
  # model, and `genomic()` as an opt-in primary genomic effect. Every other
  # planned marker still errors as not implemented.
  planned_pos <- which(vapply(
    rhs_terms,
    function(e) {
      hs_is_planned_marker_call(e) &&
        !hs_is_second_effect_call(e) &&
        !hs_is_relinv_primary_call(e)
    },
    logical(1L)
  ))
  if (length(planned_pos) > 0L) {
    hs_stop_planned_marker(rhs_terms[[planned_pos[[1L]]]])
  }

  # The primary effect is exactly one of `animal()` (pedigree) or a
  # supplied-relationship-inverse term (`genomic()` with `Ginv`, or
  # `single_step()` with `Hinv`).
  animal_pos <- which(vapply(rhs_terms, hs_is_animal_call, logical(1L)))
  relinv_pos <- which(vapply(
    rhs_terms,
    hs_is_relinv_primary_call,
    logical(1L)
  ))
  primary_pos <- c(animal_pos, relinv_pos)

  if (length(primary_pos) == 0L) {
    stop(
      "`formula` must contain exactly one primary term: ",
      "`animal(1 | id, pedigree = ped)` or `genomic(1 | id, Ginv = Ginv)`.",
      call. = FALSE
    )
  }
  if (length(primary_pos) > 1L) {
    stop(
      "`formula` can contain only one primary effect ",
      "(`animal()` or `genomic()`).",
      call. = FALSE
    )
  }

  if (length(animal_pos) == 1L) {
    primary_type <- "animal"
    primary_spec <- hs_parse_animal_call(
      rhs_terms[[animal_pos]],
      data,
      env,
      model_data = model_data
    )
  } else {
    primary_spec <- hs_parse_relinv_primary_call(
      rhs_terms[[relinv_pos]],
      data,
      env
    )
    primary_type <- primary_spec$type
  }

  second_pos <- which(vapply(rhs_terms, hs_is_second_effect_call, logical(1L)))
  second_spec <- NULL
  if (length(second_pos) > 0L && !identical(primary_type, "animal")) {
    stop(
      "A second random effect (`permanent()`/`common_env()`/",
      "`maternal_genetic()`) requires an `animal()` primary term, not ",
      "`genomic()`.",
      call. = FALSE
    )
  }
  if (length(second_pos) > 1L) {
    stop(
      "`formula` can contain at most one additional random effect ",
      "(`permanent()` or `common_env()`) alongside `animal()`.",
      call. = FALSE
    )
  }
  if (length(second_pos) == 1L) {
    second_spec <- hs_parse_second_effect_call(
      rhs_terms[[second_pos]],
      data,
      primary_spec
    )
  }

  # Any leftover bar term (a bare `(... | group)` random effect that is not a
  # recognized named effect) would otherwise be silently swallowed into the
  # fixed-effect design; reject it with a pointer to the named effects.
  leftover_pos <- setdiff(seq_along(rhs_terms), c(primary_pos, second_pos))
  bar_pos <- leftover_pos[vapply(
    rhs_terms[leftover_pos],
    hs_is_bar_expr,
    logical(1L)
  )]
  if (length(bar_pos) > 0L) {
    hs_stop_unsupported_random_effect(rhs_terms[[bar_pos[[1L]]]])
  }

  fixed_terms <- rhs_terms[-c(primary_pos, second_pos)]
  fixed_formula <- formula
  fixed_formula[[3L]] <- hs_rebuild_additive_rhs(fixed_terms)
  environment(fixed_formula) <- env

  model_frame <- stats::model.frame(
    fixed_formula,
    data = data,
    na.action = stats::na.pass,
    drop.unused.levels = FALSE
  )

  response_pos <- attr(stats::terms(fixed_formula), "response")
  fixed_frame <- model_frame
  if (!is.null(response_pos) && response_pos > 0L) {
    fixed_frame <- model_frame[-response_pos]
  }
  if (length(fixed_frame) > 0L && anyNA(fixed_frame)) {
    stop(
      "Missing values in fixed-effect variables are not implemented. ",
      "For multivariate responses, use `NA` only inside the `cbind()` ",
      "response matrix to mark missing trait records.",
      call. = FALSE
    )
  }

  response <- hs_build_response_spec(formula[[2L]], stats::model.response(
    model_frame
  ))

  fixed_terms_obj <- stats::terms(fixed_formula)
  fixed_design <- stats::model.matrix(fixed_terms_obj, data = model_frame)
  hs_validate_fixed_design(fixed_design)

  random <- list()
  random[[primary_type]] <- primary_spec
  bridge_target <- if (primary_type %in% c("genomic", "single_step")) {
    if (identical(primary_spec$source, "markers")) {
      paste0(
        "fit_ai_reml(y, X, Z, ",
        "genomic_relationship_inverse(genomic_relationship_matrix(markers)); ",
        "method = :REML)"
      )
    } else {
      sprintf(
        "fit_ai_reml(y, X, Z, %s; method = :REML)",
        if (identical(primary_type, "genomic")) "Ginv" else "Hinv"
      )
    }
  } else {
    "fit_animal_model(y, X, Z, Ainv; method = :REML)"
  }
  if (!is.null(second_spec)) {
    random[[second_spec$type]] <- second_spec
    bridge_target <- if (identical(second_spec$type, "permanent")) {
      "fit_repeatability_reml(y, X, Z, Ainv; method = :REML)"
    } else {
      "fit_two_effect_reml(y, X, Z, Ainv, Z2, Ainv2; method = :REML)"
    }
  }
  if (isTRUE(response$multivariate)) {
    if (!identical(primary_type, "animal") || !is.null(second_spec)) {
      stop(
        "The opt-in multivariate path currently supports only ",
        "`cbind(...) ~ fixed + animal(1 | id, pedigree = ped)`. ",
        "Multivariate genomic, single-step, and second-effect models are ",
        "planned, not implemented.",
        call. = FALSE
      )
    }
    bridge_target <- "fit_multivariate_reml(Y, X, Z, Ainv; method = :REML)"
  }

  list(
    formula = formula,
    fixed_formula = fixed_formula,
    family = list(family = family$family, link = family$link),
    method = if (isTRUE(REML)) "REML" else "ML",
    response = response,
    fixed = list(
      terms = attr(fixed_terms_obj, "term.labels"),
      design = fixed_design,
      contrasts = attr(fixed_design, "contrasts")
    ),
    random = random,
    bridge = list(
      status = "planned",
      engine = "HSquared.jl",
      target = bridge_target
    )
  )
}

hs_build_response_spec <- function(lhs, response) {
  multivariate <- is.matrix(response)
  if (multivariate && !hs_is_call(hs_unwrap_parentheses(lhs), "cbind")) {
    stop(
      "Multivariate responses must use `cbind(trait1, trait2, ...)` on the ",
      "left-hand side.",
      call. = FALSE
    )
  }

  if (multivariate) {
    values <- unname(as.matrix(response))
    if (!is.numeric(values)) {
      stop("Multivariate `cbind()` responses must be numeric.", call. = FALSE)
    }
    if (ncol(values) < 2L) {
      stop(
        "Multivariate `cbind()` responses require at least two trait columns.",
        call. = FALSE
      )
    }
    observed <- !is.na(values)
    if (any(observed & !is.finite(values))) {
      stop(
        "Observed multivariate response values must be finite. Use `NA` for ",
        "missing trait records.",
        call. = FALSE
      )
    }
    if (any(colSums(observed) == 0L)) {
      stop(
        "Each trait in a multivariate `cbind()` response must have at least ",
        "one observed value.",
        call. = FALSE
      )
    }
    trait_names <- colnames(response)
    if (is.null(trait_names) || anyNA(trait_names) || any(!nzchar(trait_names))) {
      trait_names <- all.vars(lhs)
    }
    if (length(trait_names) != ncol(values)) {
      trait_names <- paste0("trait", seq_len(ncol(values)))
    }
    colnames(values) <- trait_names
    return(list(
      name = hs_deparse(lhs),
      values = values,
      trait_names = trait_names,
      multivariate = TRUE
    ))
  }

  if (!is.numeric(response)) {
    stop(
      "The v0.1 parser supports numeric Gaussian responses only.",
      call. = FALSE
    )
  }
  if (anyNA(response)) {
    stop(
      "Missing values in the response are not implemented for univariate ",
      "models. Use a multivariate `cbind()` response only when missing trait ",
      "records are intended.",
      call. = FALSE
    )
  }
  if (any(!is.finite(response))) {
    stop("Response values must be finite.", call. = FALSE)
  }

  list(
    name = all.vars(lhs)[1L],
    values = as.numeric(response),
    trait_names = NULL,
    multivariate = FALSE
  )
}

hs_validate_fixed_design <- function(fixed_design) {
  if (ncol(fixed_design) == 0L) {
    return(invisible(TRUE))
  }
  if (qr(fixed_design)$rank < ncol(fixed_design)) {
    stop(
      "The fixed-effect design matrix is rank deficient. Remove redundant ",
      "fixed-effect columns before fitting.",
      call. = FALSE
    )
  }
  invisible(TRUE)
}

hs_model_data_context <- function(data, env) {
  if (!inherits(data, "hs_data")) {
    return(list(
      data = data,
      env = env,
      is_hs_data = FALSE,
      components = list()
    ))
  }
  if (!is.data.frame(data$phenotypes)) {
    stop(
      "`data` is an `hs_data` object, but `data$phenotypes` is not a ",
      "data frame.",
      call. = FALSE
    )
  }

  components <- list(
    phenotypes = data$phenotypes,
    pedigree = data$pedigree,
    genotypes = data$genotypes,
    markers = data$markers,
    expression = data$expression,
    annotation = data$annotation,
    environment = data$environment
  )
  components <- components[!vapply(components, is.null, logical(1L))]

  list(
    data = data$phenotypes,
    env = list2env(components, parent = env),
    is_hs_data = TRUE,
    components = components
  )
}

hs_validate_model_inputs <- function(formula, data, family, REML) {
  if (!inherits(formula, "formula") || length(formula) != 3L) {
    stop("`formula` must be a two-sided formula.", call. = FALSE)
  }
  if (!is.data.frame(data)) {
    stop("`data` must be a data frame.", call. = FALSE)
  }
  if (!inherits(family, "family")) {
    stop(
      "`family` must be an R family object such as `gaussian()`.",
      call. = FALSE
    )
  }
  if (
    !identical(family$family, "gaussian") || !identical(family$link, "identity")
  ) {
    stop(
      "The v0.1 parser supports only `family = gaussian()` with identity ",
      "link. Other families are planned, not implemented.",
      call. = FALSE
    )
  }
  if (!is.logical(REML) || length(REML) != 1L || is.na(REML)) {
    stop("`REML` must be `TRUE` or `FALSE`.", call. = FALSE)
  }

  invisible(TRUE)
}

hs_parse_animal_call <- function(call, data, env, model_data) {
  call <- hs_unwrap_parentheses(call)
  args <- as.list(call)[-1L]
  arg_names <- names(args)
  if (is.null(arg_names)) {
    arg_names <- rep("", length(args))
  }

  bar_candidates <- which(arg_names == "" | arg_names == "formula")
  if (length(bar_candidates) != 1L) {
    stop(
      "`animal()` must have one random-effect expression, for example ",
      "`animal(1 | id, pedigree = ped)`.",
      call. = FALSE
    )
  }

  bar <- hs_unwrap_parentheses(args[[bar_candidates]])
  if (!hs_is_call(bar, "|") || length(bar) != 3L) {
    stop(
      "The first `animal()` argument must be a random-effect expression ",
      "such as `1 | id`.",
      call. = FALSE
    )
  }

  lhs <- hs_unwrap_parentheses(bar[[2L]])
  group_expr <- hs_unwrap_parentheses(bar[[3L]])
  if (!hs_is_one(lhs)) {
    hs_stop_animal_non_intercept()
  }
  if (!is.symbol(group_expr)) {
    stop(
      "The grouping variable in `animal()` must be a bare column name.",
      call. = FALSE
    )
  }

  group <- as.character(group_expr)
  if (!group %in% names(data)) {
    stop(
      "`animal()` grouping variable `",
      group,
      "` was not found in `data`.",
      call. = FALSE
    )
  }

  named_args <- args[arg_names != ""]
  unsupported <- setdiff(names(named_args), "pedigree")
  if (length(unsupported) > 0L) {
    if ("cov" %in% unsupported) {
      hs_stop_animal_covariance_arg()
    }
    stop(
      "`animal()` argument",
      if (length(unsupported) > 1L) "s " else " ",
      paste(sprintf("`%s`", unsupported), collapse = ", "),
      if (length(unsupported) > 1L) {
        " are planned, not implemented in v0.1."
      } else {
        " is planned, not implemented in v0.1."
      },
      call. = FALSE
    )
  }
  pedigree_input <- hs_resolve_animal_pedigree(
    named_args,
    data,
    env,
    model_data
  )
  pedigree_spec <- hs_validate_pedigree(
    pedigree_input$data,
    data_ids = data[[group]],
    group = group
  )

  list(
    type = "animal",
    term = hs_deparse(call),
    design = "intercept",
    group = group,
    values = as.character(data[[group]]),
    relationship = "pedigree",
    covariance = "scalar",
    pedigree_source = pedigree_input$source,
    pedigree = pedigree_spec
  )
}

hs_stop_animal_non_intercept <- function() {
  stop(
    "Only random-intercept syntax `animal(1 | id, pedigree = ped)` is ",
    "implemented inside `animal()`. For the current opt-in multivariate animal ",
    "model, put traits on the left-hand side as ",
    "`cbind(trait1, trait2) ~ ... + animal(1 | id, pedigree = ped)` and use ",
    "`engine_control = list(target = \"multivariate\")`. Long-format ",
    "`animal(trait | id, cov = ...)` and random-slope syntax are planned, not ",
    "implemented.",
    call. = FALSE
  )
}

hs_stop_animal_covariance_arg <- function() {
  stop(
    "`animal()` argument `cov` is planned, not implemented. For the current ",
    "opt-in multivariate animal model, put traits on the left-hand side as ",
    "`cbind(trait1, trait2) ~ ... + animal(1 | id, pedigree = ped)` and use ",
    "`engine_control = list(target = \"multivariate\")`. Structured covariance ",
    "grammar such as `animal(trait | id, cov = us())` or `cov = fa(K = 2)` ",
    "is planned.",
    call. = FALSE
  )
}

hs_resolve_animal_pedigree <- function(named_args, data, env, model_data) {
  if ("pedigree" %in% names(named_args)) {
    return(list(
      data = hs_eval_pedigree(named_args$pedigree, data, env),
      source = "formula"
    ))
  }

  if (
    isTRUE(model_data$is_hs_data) &&
      !is.null(model_data$components$pedigree)
  ) {
    return(list(
      data = model_data$components$pedigree,
      source = "hs_data"
    ))
  }

  stop(
    "`animal()` requires `pedigree = ped` in the v0.1 parser, unless ",
    "`data` is an `hs_data()` object with a pedigree component.",
    call. = FALSE
  )
}

hs_validate_pedigree <- function(pedigree, data_ids, group) {
  if (!is.data.frame(pedigree) || ncol(pedigree) < 3L) {
    stop(
      "`pedigree` must be a data frame with at least three columns: ",
      "`id`, `sire`, and `dam`.",
      call. = FALSE
    )
  }

  cols <- hs_pedigree_columns(pedigree)
  ids <- as.character(pedigree[[cols$id]])
  sire <- hs_normalize_parent(pedigree[[cols$sire]])
  dam <- hs_normalize_parent(pedigree[[cols$dam]])

  if (any(is.na(ids) | ids == "" | ids == "0")) {
    stop(
      "`pedigree` individual IDs cannot be missing, empty, or `0`.",
      call. = FALSE
    )
  }
  if (anyDuplicated(ids)) {
    stop("`pedigree` contains duplicate individual IDs.", call. = FALSE)
  }

  parent_values <- unique(c(stats::na.omit(sire), stats::na.omit(dam)))
  missing_parents <- setdiff(parent_values, ids)
  if (length(missing_parents) > 0L) {
    stop(
      "`pedigree` contains known parent ID",
      if (length(missing_parents) > 1L) "s" else "",
      " not present as individual IDs: ",
      paste(missing_parents, collapse = ", "),
      ".",
      call. = FALSE
    )
  }

  self_parent <- (!is.na(sire) & sire == ids) | (!is.na(dam) & dam == ids)
  if (any(self_parent)) {
    stop(
      "`pedigree` cannot list an individual as its own parent.",
      call. = FALSE
    )
  }

  same_known_parent <- !is.na(sire) & !is.na(dam) & sire == dam
  if (any(same_known_parent)) {
    stop(
      "`pedigree` rows with the same known sire and dam are not supported ",
      "in v0.1. Selfing and non-standard inheritance are planned later.",
      call. = FALSE
    )
  }

  observed_ids <- as.character(data_ids)
  if (any(is.na(observed_ids) | observed_ids == "" | observed_ids == "0")) {
    stop(
      "`data` column `",
      group,
      "` cannot contain missing, empty, or `0` IDs.",
      call. = FALSE
    )
  }

  observed_missing <- setdiff(unique(observed_ids), ids)
  if (length(observed_missing) > 0L) {
    stop(
      "`data` column `",
      group,
      "` contains ID",
      if (length(observed_missing) > 1L) "s" else "",
      " not present in `pedigree`: ",
      paste(observed_missing, collapse = ", "),
      ".",
      call. = FALSE
    )
  }

  normalized <- hs_topological_pedigree(ids, sire, dam)

  structure(
    list(
      data = normalized$data,
      columns = cols,
      ids = normalized$data$id,
      observed_ids = unique(observed_ids),
      parent_index = normalized$parent_index,
      original_order = normalized$original_order
    ),
    class = "hs_pedigree_spec"
  )
}

hs_pedigree_columns <- function(pedigree) {
  nm <- names(pedigree)
  pick <- function(candidates) {
    hit <- which(tolower(nm) %in% candidates)
    if (length(hit) == 0L) {
      return(NA_integer_)
    }
    hit[[1L]]
  }

  cols <- list(
    id = pick(c("id", "animal")),
    sire = pick(c("sire", "father")),
    dam = pick(c("dam", "mother"))
  )

  if (anyNA(unlist(cols, use.names = FALSE))) {
    cols <- list(id = 1L, sire = 2L, dam = 3L)
  }

  cols
}

hs_eval_pedigree <- function(expr, data, env) {
  tryCatch(
    eval(expr, envir = data, enclos = env),
    error = function(err) {
      stop(
        "Could not evaluate `pedigree = ",
        hs_deparse(expr),
        "`. ",
        "Provide a pedigree data frame in the formula environment.",
        call. = FALSE
      )
    }
  )
}

hs_is_genomic_primary_call <- function(expr) {
  expr <- hs_unwrap_parentheses(expr)
  hs_is_call(expr, "genomic")
}

hs_is_single_step_primary_call <- function(expr) {
  expr <- hs_unwrap_parentheses(expr)
  hs_is_call(expr, "single_step")
}

# The opt-in primary effects whose relationship is a user-supplied inverse:
# `genomic()` (a genomic relationship inverse `Ginv`) and `single_step()` (a
# single-step relationship inverse `Hinv`). Both fit by REML on a relationship-
# inverse-based animal_model_spec.
hs_is_relinv_primary_call <- function(expr) {
  hs_is_genomic_primary_call(expr) || hs_is_single_step_primary_call(expr)
}

hs_parse_relinv_primary_call <- function(call, data, env) {
  call <- hs_unwrap_parentheses(call)
  if (hs_is_genomic_primary_call(call)) {
    term <- "genomic"
    arg_name <- "Ginv"
  } else {
    term <- "single_step"
    arg_name <- "Hinv"
  }
  example <- sprintf("`%s(1 | id, %s = %s)`", term, arg_name, arg_name)

  args <- as.list(call)[-1L]
  arg_names <- names(args)
  if (is.null(arg_names)) {
    arg_names <- rep("", length(args))
  }

  bar_candidates <- which(arg_names == "" | arg_names == "formula")
  if (length(bar_candidates) != 1L) {
    stop(
      "`",
      term,
      "()` must have one random-effect expression, for example ",
      example,
      ".",
      call. = FALSE
    )
  }

  bar <- hs_unwrap_parentheses(args[[bar_candidates]])
  if (!hs_is_call(bar, "|") || length(bar) != 3L) {
    stop(
      "The first `",
      term,
      "()` argument must be a random-effect expression such as `1 | id`.",
      call. = FALSE
    )
  }

  lhs <- hs_unwrap_parentheses(bar[[2L]])
  group_expr <- hs_unwrap_parentheses(bar[[3L]])
  if (!hs_is_one(lhs)) {
    stop(
      "Only random-intercept syntax ",
      example,
      " is implemented. ",
      term,
      " slopes are planned, not implemented.",
      call. = FALSE
    )
  }
  if (!is.symbol(group_expr)) {
    stop(
      "The grouping variable in `",
      term,
      "()` must be a bare column name.",
      call. = FALSE
    )
  }

  group <- as.character(group_expr)
  if (!group %in% names(data)) {
    stop(
      "`",
      term,
      "()` grouping variable `",
      group,
      "` was not found in `data`.",
      call. = FALSE
    )
  }

  # `genomic()` accepts either a supplied `Ginv` or a marker matrix `markers`
  # (the engine builds the genomic relationship from markers); `single_step()`
  # accepts a supplied `Hinv`.
  accepted <- if (identical(term, "genomic")) c("Ginv", "markers") else arg_name
  named_args <- args[arg_names != ""]
  unsupported <- setdiff(names(named_args), accepted)
  if (length(unsupported) > 0L) {
    stop(
      "`",
      term,
      "()` argument",
      if (length(unsupported) > 1L) "s " else " ",
      paste(sprintf("`%s`", unsupported), collapse = ", "),
      " are planned, not implemented.",
      call. = FALSE
    )
  }
  supplied <- intersect(accepted, names(named_args))
  if (length(supplied) == 0L) {
    extra <- if (identical(term, "genomic")) {
      " (or `markers` to build one)"
    } else {
      ""
    }
    stop(
      "`",
      term,
      "()` requires a `",
      arg_name,
      "` argument (a relationship inverse with id dimnames)",
      extra,
      ".",
      call. = FALSE
    )
  }
  if (length(supplied) > 1L) {
    stop(
      "`genomic()` takes exactly one of `Ginv` or `markers`.",
      call. = FALSE
    )
  }
  arg_used <- supplied[[1L]]

  observed_ids <- as.character(data[[group]])

  if (identical(arg_used, "markers")) {
    markers <- hs_eval_genomic_ginv(
      named_args$markers,
      data,
      env,
      what = "markers"
    )
    markers <- hs_validate_genomic_markers(markers)
    ids <- rownames(markers)
    unknown <- setdiff(unique(observed_ids), ids)
    if (length(unknown) > 0L) {
      shown <- unknown[seq_len(min(5L, length(unknown)))]
      stop(
        "`genomic()` ids must be present in the `markers` row names. ID(s) not ",
        "in the `markers`: ",
        paste(sprintf("`%s`", shown), collapse = ", "),
        ".",
        call. = FALSE
      )
    }
    return(list(
      type = term,
      term = hs_deparse(call),
      design = "intercept",
      group = group,
      values = observed_ids,
      ids = ids,
      markers = markers,
      source = "markers",
      relationship = term,
      covariance = "scalar"
    ))
  }

  relinv <- hs_eval_genomic_ginv(
    named_args[[arg_used]],
    data,
    env,
    what = arg_used
  )
  relinv <- hs_validate_genomic_ginv(relinv)
  relinv_ids <- rownames(relinv)
  unknown <- setdiff(unique(observed_ids), relinv_ids)
  if (length(unknown) > 0L) {
    shown <- unknown[seq_len(min(5L, length(unknown)))]
    stop(
      "`",
      term,
      "()` ids must be present in the `",
      arg_used,
      "` dimnames. ID(s) not in the `",
      arg_used,
      "`: ",
      paste(sprintf("`%s`", shown), collapse = ", "),
      ".",
      call. = FALSE
    )
  }

  list(
    type = term,
    term = hs_deparse(call),
    design = "intercept",
    group = group,
    values = observed_ids,
    ids = relinv_ids,
    ginv = relinv,
    source = "supplied",
    relationship = term,
    covariance = "scalar"
  )
}

hs_eval_genomic_ginv <- function(expr, data, env, what = "Ginv") {
  tryCatch(
    eval(expr, envir = data, enclos = env),
    error = function(err) {
      stop(
        "Could not evaluate the `",
        what,
        "` argument (`",
        hs_deparse(expr),
        "`). Provide it as a matrix in the formula environment.",
        call. = FALSE
      )
    }
  )
}

hs_validate_genomic_ginv <- function(ginv) {
  if (inherits(ginv, "Matrix")) {
    ginv <- as.matrix(ginv)
  }
  if (!is.matrix(ginv) || !is.numeric(ginv)) {
    stop("`Ginv` must be a numeric matrix.", call. = FALSE)
  }
  if (nrow(ginv) != ncol(ginv)) {
    stop("`Ginv` must be a square matrix.", call. = FALSE)
  }
  ids <- rownames(ginv)
  if (is.null(ids) || any(is.na(ids)) || anyDuplicated(ids) > 0L) {
    stop(
      "`Ginv` must have unique, non-missing row/column names matching the ",
      "genomic ids.",
      call. = FALSE
    )
  }
  if (!identical(ids, colnames(ginv))) {
    stop("`Ginv` row and column names must match.", call. = FALSE)
  }
  ginv
}

hs_validate_genomic_markers <- function(markers) {
  if (inherits(markers, "Matrix")) {
    markers <- as.matrix(markers)
  }
  if (!is.matrix(markers) || !is.numeric(markers)) {
    stop("`markers` must be a numeric marker matrix.", call. = FALSE)
  }
  ids <- rownames(markers)
  if (is.null(ids) || any(is.na(ids)) || anyDuplicated(ids) > 0L) {
    stop(
      "`markers` must have unique, non-missing row names matching the ids ",
      "(one row per genotyped individual).",
      call. = FALSE
    )
  }
  markers
}

hs_normalize_parent <- function(x) {
  x <- as.character(x)
  x[is.na(x) | x == "" | x == "0"] <- NA_character_
  x
}

hs_topological_pedigree <- function(ids, sire, dam) {
  sire_index <- match(sire, ids)
  dam_index <- match(dam, ids)
  sire_index[is.na(sire_index)] <- 0L
  dam_index[is.na(dam_index)] <- 0L

  state <- integer(length(ids))
  order <- integer()

  visit <- function(index) {
    if (state[[index]] == 2L) {
      return(invisible(NULL))
    }
    if (state[[index]] == 1L) {
      stop(
        "`pedigree` contains a parent-offspring cycle involving ID `",
        ids[[index]],
        "`.",
        call. = FALSE
      )
    }

    state[[index]] <<- 1L
    if (sire_index[[index]] != 0L) {
      visit(sire_index[[index]])
    }
    if (dam_index[[index]] != 0L) {
      visit(dam_index[[index]])
    }
    state[[index]] <<- 2L
    order <<- c(order, index)
    invisible(NULL)
  }

  for (index in seq_along(ids)) {
    visit(index)
  }

  sorted_position <- integer(length(ids))
  sorted_position[order] <- seq_along(order)
  sorted_sire_index <- sire_index[order]
  sorted_dam_index <- dam_index[order]
  known_sire <- sorted_sire_index != 0L
  known_dam <- sorted_dam_index != 0L
  sorted_sire_index[known_sire] <- sorted_position[sorted_sire_index[
    known_sire
  ]]
  sorted_dam_index[known_dam] <- sorted_position[sorted_dam_index[known_dam]]

  list(
    data = data.frame(
      id = ids[order],
      sire = sire[order],
      dam = dam[order],
      stringsAsFactors = FALSE
    ),
    parent_index = list(
      sire = sorted_sire_index,
      dam = sorted_dam_index
    ),
    original_order = order
  )
}

hs_split_additive_rhs <- function(expr) {
  expr <- hs_unwrap_parentheses(expr)
  if (hs_is_call(expr, "+") && length(expr) == 3L) {
    return(c(
      hs_split_additive_rhs(expr[[2L]]),
      hs_split_additive_rhs(expr[[3L]])
    ))
  }
  list(expr)
}

hs_rebuild_additive_rhs <- function(terms) {
  if (length(terms) == 0L) {
    return(1)
  }
  Reduce(function(left, right) call("+", left, right), terms)
}

hs_is_animal_call <- function(expr) {
  expr <- hs_unwrap_parentheses(expr)
  hs_is_call(expr, "animal")
}

hs_is_permanent_call <- function(expr) {
  expr <- hs_unwrap_parentheses(expr)
  hs_is_call(expr, "permanent")
}

hs_is_common_env_call <- function(expr) {
  expr <- hs_unwrap_parentheses(expr)
  hs_is_call(expr, "common_env")
}

hs_is_maternal_genetic_call <- function(expr) {
  expr <- hs_unwrap_parentheses(expr)
  hs_is_call(expr, "maternal_genetic")
}

# The planned QG markers the parser now consumes as the (single) second random
# effect of an opt-in two-effect model: `permanent()` (repeatability),
# `common_env()` (IID common-environment), and `maternal_genetic()` (a
# pedigree-related maternal genetic effect).
hs_is_second_effect_call <- function(expr) {
  hs_is_permanent_call(expr) ||
    hs_is_common_env_call(expr) ||
    hs_is_maternal_genetic_call(expr)
}

hs_parse_second_effect_call <- function(call, data, animal_spec) {
  if (hs_is_permanent_call(call)) {
    hs_parse_permanent_call(call, data, animal_spec)
  } else if (hs_is_common_env_call(call)) {
    hs_parse_common_env_call(call, data)
  } else {
    hs_parse_maternal_genetic_call(call, data, animal_spec)
  }
}

# Parse `common_env(1 | group)` as the common-environment effect of the opt-in
# two-effect model: a random intercept on an environmental grouping (e.g. litter
# or cage) carrying an identity relationship (each level an independent IID
# effect). Unlike `permanent()`, the grouping is a separate environmental column,
# not the animal id.
hs_parse_common_env_call <- function(call, data) {
  call <- hs_unwrap_parentheses(call)
  args <- as.list(call)[-1L]
  arg_names <- names(args)
  if (is.null(arg_names)) {
    arg_names <- rep("", length(args))
  }

  bar_candidates <- which(arg_names == "" | arg_names == "formula")
  if (length(bar_candidates) != 1L) {
    stop(
      "`common_env()` must have one random-effect expression, for example ",
      "`common_env(1 | litter)`.",
      call. = FALSE
    )
  }

  bar <- hs_unwrap_parentheses(args[[bar_candidates]])
  if (!hs_is_call(bar, "|") || length(bar) != 3L) {
    stop(
      "The `common_env()` argument must be a random-effect expression such as ",
      "`1 | litter`.",
      call. = FALSE
    )
  }

  lhs <- hs_unwrap_parentheses(bar[[2L]])
  group_expr <- hs_unwrap_parentheses(bar[[3L]])
  if (!hs_is_one(lhs)) {
    stop(
      "Only random-intercept syntax `common_env(1 | group)` is implemented. ",
      "Common-environment slopes are planned, not implemented.",
      call. = FALSE
    )
  }
  if (!is.symbol(group_expr)) {
    stop(
      "The grouping variable in `common_env()` must be a bare column name.",
      call. = FALSE
    )
  }

  named_args <- args[arg_names != ""]
  if (length(named_args) > 0L) {
    stop(
      "`common_env()` takes no extra arguments in the v0.1 two-effect model.",
      call. = FALSE
    )
  }

  group <- as.character(group_expr)
  if (!group %in% names(data)) {
    stop(
      "`common_env()` grouping variable `",
      group,
      "` was not found in `data`.",
      call. = FALSE
    )
  }

  list(
    type = "common_env",
    term = hs_deparse(call),
    design = "intercept",
    group = group,
    values = as.character(data[[group]]),
    levels = unique(as.character(data[[group]])),
    relationship = "identity",
    covariance = "scalar"
  )
}

# Parse `maternal_genetic(1 | dam)` as the maternal genetic effect of the opt-in
# two-effect model: a random intercept expressed through the dam, carrying the
# SAME pedigree relationship as the direct animal effect (A2 = pedigree A). The
# grouping column holds dam ids, which must be animals in the `animal()`
# pedigree; the maternal effect is predicted for every pedigree animal.
hs_parse_maternal_genetic_call <- function(call, data, animal_spec) {
  call <- hs_unwrap_parentheses(call)
  args <- as.list(call)[-1L]
  arg_names <- names(args)
  if (is.null(arg_names)) {
    arg_names <- rep("", length(args))
  }

  bar_candidates <- which(arg_names == "" | arg_names == "formula")
  if (length(bar_candidates) != 1L) {
    stop(
      "`maternal_genetic()` must have one random-effect expression, for ",
      "example `maternal_genetic(1 | dam)`.",
      call. = FALSE
    )
  }

  bar <- hs_unwrap_parentheses(args[[bar_candidates]])
  if (!hs_is_call(bar, "|") || length(bar) != 3L) {
    stop(
      "The `maternal_genetic()` argument must be a random-effect expression ",
      "such as `1 | dam`.",
      call. = FALSE
    )
  }

  lhs <- hs_unwrap_parentheses(bar[[2L]])
  group_expr <- hs_unwrap_parentheses(bar[[3L]])
  if (!hs_is_one(lhs)) {
    stop(
      "Only random-intercept syntax `maternal_genetic(1 | dam)` is implemented. ",
      "Maternal slopes are planned, not implemented.",
      call. = FALSE
    )
  }
  if (!is.symbol(group_expr)) {
    stop(
      "The grouping variable in `maternal_genetic()` must be a bare column name.",
      call. = FALSE
    )
  }

  named_args <- args[arg_names != ""]
  if (length(named_args) > 0L) {
    stop(
      "`maternal_genetic()` takes no extra arguments in the v0.1 two-effect ",
      "model (the dam relationships come from the animal() pedigree).",
      call. = FALSE
    )
  }

  group <- as.character(group_expr)
  if (!group %in% names(data)) {
    stop(
      "`maternal_genetic()` grouping variable `",
      group,
      "` was not found in `data`.",
      call. = FALSE
    )
  }

  dam_values <- as.character(data[[group]])
  ped_ids <- animal_spec$pedigree$ids
  unknown <- setdiff(unique(dam_values), ped_ids)
  if (length(unknown) > 0L) {
    shown <- unknown[seq_len(min(5L, length(unknown)))]
    stop(
      "`maternal_genetic()` dams must be animals in the `animal()` pedigree. ",
      "Dam(s) not in the pedigree: ",
      paste(sprintf("`%s`", shown), collapse = ", "),
      ".",
      call. = FALSE
    )
  }

  list(
    type = "maternal_genetic",
    term = hs_deparse(call),
    design = "intercept",
    group = group,
    values = dam_values,
    levels = ped_ids,
    relationship = "pedigree",
    covariance = "scalar"
  )
}

# Parse `permanent(1 | id)` as the permanent-environment effect of the opt-in
# repeatability model. It must be a random intercept on the SAME grouping
# variable as `animal()`, because the engine shares the animal incidence matrix
# `Z` between the additive-genetic and permanent-environment effects (the PE
# effect carries an identity relationship, A2 = I).
hs_parse_permanent_call <- function(call, data, animal_spec) {
  call <- hs_unwrap_parentheses(call)
  args <- as.list(call)[-1L]
  arg_names <- names(args)
  if (is.null(arg_names)) {
    arg_names <- rep("", length(args))
  }

  bar_candidates <- which(arg_names == "" | arg_names == "formula")
  if (length(bar_candidates) != 1L) {
    stop(
      "`permanent()` must have one random-effect expression, for example ",
      "`permanent(1 | id)`.",
      call. = FALSE
    )
  }

  bar <- hs_unwrap_parentheses(args[[bar_candidates]])
  if (!hs_is_call(bar, "|") || length(bar) != 3L) {
    stop(
      "The `permanent()` argument must be a random-effect expression such as ",
      "`1 | id`.",
      call. = FALSE
    )
  }

  lhs <- hs_unwrap_parentheses(bar[[2L]])
  group_expr <- hs_unwrap_parentheses(bar[[3L]])
  if (!hs_is_one(lhs)) {
    stop(
      "Only random-intercept syntax `permanent(1 | id)` is implemented. ",
      "Permanent-environment slopes are planned, not implemented.",
      call. = FALSE
    )
  }
  if (!is.symbol(group_expr)) {
    stop(
      "The grouping variable in `permanent()` must be a bare column name.",
      call. = FALSE
    )
  }

  named_args <- args[arg_names != ""]
  if (length(named_args) > 0L) {
    stop(
      "`permanent()` takes no extra arguments in the v0.1 repeatability model.",
      call. = FALSE
    )
  }

  group <- as.character(group_expr)
  if (!identical(group, animal_spec$group)) {
    stop(
      "`permanent()` must use the same grouping variable as `animal()` ",
      "(the permanent-environment effect shares the animal incidence). Got ",
      "`permanent(1 | ",
      group,
      ")` with `animal(1 | ",
      animal_spec$group,
      ")`.",
      call. = FALSE
    )
  }

  list(
    type = "permanent",
    term = hs_deparse(call),
    design = "intercept",
    group = group,
    values = as.character(data[[group]]),
    relationship = "identity",
    covariance = "scalar"
  )
}

hs_is_planned_marker_call <- function(expr) {
  expr <- hs_unwrap_parentheses(expr)
  is.call(expr) &&
    as.character(expr[[1L]]) %in% hs_planned_marker_names()
}

hs_planned_marker_names <- function() {
  c(
    hs_planned_genomic_marker_names(),
    hs_planned_qg_effect_marker_names()
  )
}

hs_planned_genomic_marker_names <- function() {
  c("genomic", "single_step", "markers", "marker_scan", "qtl_scan")
}

hs_planned_qg_effect_marker_names <- function() {
  c(
    "permanent",
    "common_env",
    "maternal_genetic",
    "maternal_env",
    "paternal_genetic",
    "paternal_env",
    "cytoplasmic",
    "imprinting",
    "dominance",
    "epistasis",
    "relmat",
    "precision"
  )
}

hs_stop_planned_marker <- function(expr) {
  expr <- hs_unwrap_parentheses(expr)
  marker <- as.character(expr[[1L]])
  stop(
    "`",
    marker,
    "()` is planned, not implemented. The v0.1 parser currently accepts ",
    "only `animal(1 | id, pedigree = ped)`. Standard quantitative-genetic, ",
    "parental, inheritance-kernel, genomic, marker-scan, single-step, and ",
    "QTL/eQTL terms are tracked in the roadmap.",
    call. = FALSE
  )
}

hs_is_call <- function(expr, name) {
  is.call(expr) && identical(as.character(expr[[1L]]), name)
}

hs_is_one <- function(expr) {
  is.numeric(expr) && length(expr) == 1L && identical(as.numeric(expr), 1)
}

hs_unwrap_parentheses <- function(expr) {
  while (hs_is_call(expr, "(") && length(expr) == 2L) {
    expr <- expr[[2L]]
  }
  expr
}

hs_deparse <- function(expr) {
  paste(deparse(expr, width.cutoff = 500L), collapse = " ")
}

# A bare grouping/random-effect expression like `(1 | x)` or `x | id` — i.e. a
# top-level `|` call that is not wrapped in a recognized effect function such as
# `animal()`/`permanent()`. These must be named, not silently absorbed into the
# fixed-effect design.
hs_is_bar_expr <- function(expr) {
  hs_is_call(hs_unwrap_parentheses(expr), "|")
}

hs_stop_unsupported_random_effect <- function(term) {
  stop(
    "Unsupported random-effect term `",
    hs_deparse(term),
    "`. hsquared does not parse bare `(... | group)` random effects. Name the ",
    "effect instead: `animal(1 | id, pedigree = ped)` for the additive ",
    "genetic effect, or an opt-in second effect such as `permanent(1 | id)`, ",
    "`common_env(1 | group)`, or `maternal_genetic(1 | dam)`.",
    call. = FALSE
  )
}
