hs_build_model_spec <- function(
  formula,
  data,
  family,
  REML,
  allow_families = "gaussian"
) {
  env <- environment(formula)
  if (is.null(env)) {
    env <- parent.frame()
  }
  model_data <- hs_model_data_context(data, env)
  data <- model_data$data
  env <- model_data$env

  hs_validate_model_inputs(formula, data, family, REML, allow_families)

  rhs_terms <- hs_split_additive_rhs(formula[[3L]])

  # A bare `.` (all-other-columns shorthand) would otherwise reach
  # `model.frame()` and abort with the cryptic base-R error "'.' in formula and
  # no 'data' argument". Reject it by name and point to explicit fixed terms.
  hs_check_dot_term(rhs_terms)

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
      "(`animal()`, `genomic()`, or `single_step()`).",
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
      "(`permanent()`, `common_env()`, or `maternal_genetic()`) alongside ",
      "`animal()`.",
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

  # A recognized effect/marker call nested inside an interaction or function
  # term (e.g. `x:dominance(1 | id)`) is not a top-level random effect, so it
  # would otherwise leak into the fixed-effect model.frame and abort with a
  # cryptic base-R error. Reject it here with the named term.
  for (pos in leftover_pos) {
    hs_check_nested_effect(rhs_terms[[pos]])
  }

  fixed_terms <- rhs_terms[-c(primary_pos, second_pos)]

  # An `offset()` term is silently dropped from the fixed design (and the bridge
  # payload) by `model.matrix()`. Reject it by name, mirroring the bare-bar and
  # nested-effect guards, rather than quietly ignoring the user's offset.
  hs_check_offset_term(fixed_terms)

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

  response <- hs_build_response_spec(
    formula[[2L]],
    stats::model.response(
      model_frame
    )
  )

  fixed_terms_obj <- stats::terms(fixed_formula)

  # `model.matrix()` aborts with a cryptic base-R error ("contrasts can be
  # applied only to factors with 2 or more levels") on a zero-row model.frame or
  # a factor/character fixed effect with fewer than two observed levels. Catch
  # both first and name the offending term, consistent with the rank-deficient
  # wording below.
  hs_validate_fixed_model_frame(fixed_frame)

  fixed_design <- stats::model.matrix(fixed_terms_obj, data = model_frame)
  hs_validate_fixed_design(fixed_design)

  random <- list()
  random[[primary_type]] <- primary_spec
  bridge_target <- if (primary_type %in% c("genomic", "single_step")) {
    if (identical(primary_spec$source, "construct")) {
      paste0(
        "fit_single_step_reml(y, X, Z, Ainv, A, G, genotyped_rows; ",
        "method = :REML)"
      )
    } else if (identical(primary_spec$source, "markers")) {
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
  } else if (identical(primary_spec$design, "random_regression")) {
    "fit_random_regression_reml(y, X, Phi, Z, Ainv; ids = ped.ids)"
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
  # The opt-in random-regression design is a single-effect, univariate model. It
  # does not (yet) combine with a second random effect or a multivariate cbind()
  # response; both are planned.
  if (
    identical(primary_spec$design, "random_regression") && !is.null(second_spec)
  ) {
    stop(
      "A `rr(...)` random-regression term in `animal()` is a single-effect, ",
      "opt-in model; combining it with a second random effect ",
      "(`permanent()`/`common_env()`/`maternal_genetic()`) is planned, not ",
      "implemented.",
      call. = FALSE
    )
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
    if (identical(primary_spec$design, "random_regression")) {
      stop(
        "Multivariate random regression (`cbind(...)` response with a ",
        "`rr(...)` term) is planned, not implemented. Use a univariate ",
        "response with the opt-in `target = \"random_regression\"` path.",
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
    hs_validate_cbind_bare_columns(hs_unwrap_parentheses(lhs))
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
    if (
      is.null(trait_names) || anyNA(trait_names) || any(!nzchar(trait_names))
    ) {
      trait_names <- all.vars(lhs)
    }
    if (length(trait_names) != ncol(values)) {
      trait_names <- paste0("trait", seq_len(ncol(values)))
    }
    hs_validate_multivariate_trait_names(trait_names)
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
    name = hs_deparse(lhs),
    values = as.numeric(response),
    trait_names = NULL,
    multivariate = FALSE
  )
}

hs_validate_multivariate_trait_names <- function(trait_names) {
  missing_names <- is.na(trait_names) | !nzchar(trait_names)
  duplicate_names <- duplicated(trait_names) |
    duplicated(trait_names, fromLast = TRUE)

  if (!any(missing_names) && !any(duplicate_names)) {
    return(invisible(trait_names))
  }

  detail <- character()
  if (any(missing_names)) {
    detail <- c(detail, "empty or missing names")
  }
  if (any(duplicate_names)) {
    duplicates <- unique(trait_names[duplicate_names & !missing_names])
    detail <- c(
      detail,
      paste0("duplicate names: ", paste(duplicates, collapse = ", "))
    )
  }

  stop(
    "Multivariate `cbind()` responses require unique, non-empty trait names",
    if (length(detail) > 0L) {
      paste0(" (", paste(detail, collapse = "; "), ")")
    },
    ". Rename or wrap response columns before fitting.",
    call. = FALSE
  )
}

# Reject a multivariate `cbind()` response whose arguments are not bare trait
# column symbols (e.g. `cbind(y1, y1 + y2)` or `cbind(log(y1), y2)`). A derived
# column would otherwise be mislabelled from `all.vars(lhs)`, giving a
# confidently wrong trait name. Bare-column `cbind(y1, y2)` is left untouched.
hs_validate_cbind_bare_columns <- function(lhs) {
  args <- as.list(lhs)[-1L]
  bare <- vapply(args, is.symbol, logical(1L))
  if (all(bare)) {
    return(invisible(TRUE))
  }
  offending <- vapply(args[!bare], hs_deparse, character(1L))
  stop(
    "v0.1 multivariate responses require bare trait columns inside ",
    "`cbind()`. Derived or transformed column",
    if (length(offending) > 1L) "s " else " ",
    paste(sprintf("`%s`", offending), collapse = ", "),
    if (length(offending) > 1L) " are " else " is ",
    "not supported. Create the columns in `data` first, then list them as ",
    "`cbind(trait1, trait2, ...)`.",
    call. = FALSE
  )
}

# Reject a zero-row model.frame or a factor/character fixed effect with fewer
# than two observed levels before `model.matrix()` is built. `fixed_frame` is
# the model.frame with the response column removed (the fixed-effect columns).
# Without this guard base R aborts with "contrasts can be applied only to
# factors with 2 or more levels", which names neither the variable nor the
# cause.
hs_validate_fixed_model_frame <- function(fixed_frame) {
  if (length(fixed_frame) == 0L) {
    return(invisible(TRUE))
  }
  if (nrow(fixed_frame) == 0L) {
    stop(
      "The fixed-effect model frame has zero rows. Provide `data` with at ",
      "least one observed record before fitting.",
      call. = FALSE
    )
  }
  for (nm in names(fixed_frame)) {
    column <- fixed_frame[[nm]]
    if (!is.factor(column) && !is.character(column)) {
      next
    }
    n_levels <- length(unique(column[!is.na(column)]))
    if (n_levels < 2L) {
      stop(
        "The fixed-effect term `",
        nm,
        "` has ",
        if (n_levels == 0L) "no observed levels" else "only one observed level",
        ", so it cannot be coded as a contrast. Drop it or supply at least two ",
        "levels before fitting.",
        call. = FALSE
      )
    }
  }
  invisible(TRUE)
}

# Reject an `offset()` term in the fixed RHS. `model.matrix()` would otherwise
# silently drop it from both the design matrix and the bridge payload, so the
# offset the user wrote would have no effect. Mirror the bare-bar and
# nested-effect guards by naming the offending term.
hs_check_offset_term <- function(fixed_terms) {
  offset_pos <- which(vapply(
    fixed_terms,
    function(e) hs_is_call(hs_unwrap_parentheses(e), "offset"),
    logical(1L)
  ))
  if (length(offset_pos) == 0L) {
    return(invisible(NULL))
  }
  stop(
    "Offset terms (`",
    hs_deparse(fixed_terms[[offset_pos[[1L]]]]),
    "`) are planned, not implemented in v0.1. Remove the `offset()` term ",
    "before fitting. Run `formula_status()` for the live list of which terms ",
    "parse and which fit.",
    call. = FALSE
  )
}

# Reject a bare `.` (the all-other-columns shorthand) among the split RHS
# terms. Left alone it would reach `model.frame()` and abort with the cryptic
# base-R error "'.' in formula and no 'data' argument".
hs_check_dot_term <- function(rhs_terms) {
  is_dot <- vapply(
    rhs_terms,
    function(e) is.symbol(e) && identical(as.character(e), "."),
    logical(1L)
  )
  if (!any(is_dot)) {
    return(invisible(NULL))
  }
  stop(
    "The `.` all-columns shorthand is not supported. List the fixed-effect ",
    "terms explicitly, for example ",
    "`y ~ sex + age + animal(1 | id, pedigree = ped)`.",
    call. = FALSE
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

hs_validate_model_inputs <- function(
  formula,
  data,
  family,
  REML,
  allow_families = "gaussian"
) {
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
  # gaussian fits everywhere (identity link); poisson(log)/binomial(logit) are
  # accepted only on the opt-in non-Gaussian path (`allow_families` widened by
  # `hsquared()` when `target = "nongaussian"`).
  expected_link <- c(gaussian = "identity", poisson = "log", binomial = "logit")
  link_for_family <- expected_link[family$family]
  family_ok <- family$family %in%
    allow_families &&
    !is.na(link_for_family) &&
    identical(family$link, unname(link_for_family))
  if (!family_ok) {
    stop(
      "The requested family `",
      hs_family_label(family),
      "` is not fitted on this path. The default `hsquared()` path fits ",
      "`family = gaussian()` (identity link). Non-Gaussian `poisson(log)` and ",
      "`binomial(logit)` (binary 0/1) fit through the experimental, opt-in ",
      "`hs_control(engine = \"julia\", engine_control = list(target = ",
      "\"nongaussian\"))` path: a Laplace-REML latent-scale GLMM (engine ",
      "row V6-LAPLACE, partial): REML/Laplace-only, no heritability, not ",
      "coverage-calibrated. Use `model_spec()` with `family = gaussian()` to ",
      "inspect the contract without fitting.",
      call. = FALSE
    )
  }
  if (!is.logical(REML) || length(REML) != 1L || is.na(REML)) {
    stop("`REML` must be `TRUE` or `FALSE`.", call. = FALSE)
  }

  invisible(TRUE)
}

hs_family_label <- function(family) {
  family_name <- family$family
  link_name <- family$link
  if (is.null(family_name) || !nzchar(family_name)) {
    family_name <- "<unknown>"
  }
  if (is.null(link_name) || !nzchar(link_name)) {
    link_name <- "<unknown>"
  }
  paste0(family_name, "(", link_name, ")")
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
  # `rr(covariate, order = k)` on the left-hand side is the opt-in, experimental
  # random-regression (reaction-norm) design: a per-record Legendre polynomial of
  # a within-individual covariate. Any other non-intercept left-hand side is the
  # planned random-slope / long-format syntax, still rejected.
  rr_spec <- NULL
  if (!hs_is_one(lhs)) {
    if (hs_is_call(lhs, "rr")) {
      rr_spec <- hs_parse_rr_lhs(lhs, data)
    } else {
      hs_stop_animal_non_intercept()
    }
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

  spec <- list(
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
  if (!is.null(rr_spec)) {
    spec$design <- "random_regression"
    spec$covariance <- "random_regression"
    spec$random_regression <- rr_spec
  }
  spec
}

# Parse `rr(covariate, order = k)` from the left-hand side of an `animal()`
# random-effect expression. `covariate` is a bare data column that varies within
# individual (repeated records); `order` is the number of Legendre coefficients
# (default 2 = intercept + slope). The covariate is standardized to [-1, 1] via
# its observed data range in the engine; the (lower, upper) bounds are recorded
# here so extractors can re-standardize a user-supplied `at =` on the original
# scale. The grammar is ratified by the twin on HSquared.jl#61.
hs_parse_rr_lhs <- function(lhs, data) {
  lhs <- hs_unwrap_parentheses(lhs)
  args <- as.list(lhs)[-1L]
  arg_names <- names(args)
  if (is.null(arg_names)) {
    arg_names <- rep("", length(args))
  }

  covariate_candidates <- which(arg_names == "" | arg_names == "covariate")
  if (length(covariate_candidates) != 1L) {
    stop(
      "`rr()` must name exactly one covariate column, for example ",
      "`rr(age, order = 2)`.",
      call. = FALSE
    )
  }
  covariate_expr <- hs_unwrap_parentheses(args[[covariate_candidates]])
  if (!is.symbol(covariate_expr)) {
    stop(
      "The `rr()` covariate must be a bare column name, for example ",
      "`rr(age, order = 2)`.",
      call. = FALSE
    )
  }
  covariate <- as.character(covariate_expr)
  if (!covariate %in% names(data)) {
    stop(
      "`rr()` covariate `",
      covariate,
      "` was not found in `data`.",
      call. = FALSE
    )
  }

  named_args <- args[arg_names != "" & arg_names != "covariate"]
  unsupported <- setdiff(names(named_args), "order")
  if (length(unsupported) > 0L) {
    stop(
      "`rr()` argument",
      if (length(unsupported) > 1L) "s " else " ",
      paste(sprintf("`%s`", unsupported), collapse = ", "),
      if (length(unsupported) > 1L) {
        " are planned, not implemented."
      } else {
        " is planned, not implemented."
      },
      " The opt-in random-regression grammar currently accepts only ",
      "`rr(covariate, order = k)`.",
      call. = FALSE
    )
  }

  order <- if ("order" %in% names(named_args)) named_args$order else 2
  order <- suppressWarnings(as.integer(order))
  if (length(order) != 1L || is.na(order) || order < 1L) {
    stop(
      "`rr(order = ...)` must be a single positive integer (the number of ",
      "Legendre coefficients; 2 = intercept + slope).",
      call. = FALSE
    )
  }

  values <- data[[covariate]]
  if (!is.numeric(values)) {
    stop(
      "`rr()` covariate `",
      covariate,
      "` must be numeric.",
      call. = FALSE
    )
  }
  if (anyNA(values) || any(!is.finite(values))) {
    stop(
      "`rr()` covariate `",
      covariate,
      "` must contain only finite, non-missing values.",
      call. = FALSE
    )
  }
  lower <- min(values)
  upper <- max(values)
  if (!(upper > lower)) {
    stop(
      "`rr()` covariate `",
      covariate,
      "` must vary (its observed range has zero width), so it cannot be ",
      "standardized to [-1, 1].",
      call. = FALSE
    )
  }

  list(
    covariate = covariate,
    values = as.numeric(values),
    order = order,
    lower = as.numeric(lower),
    upper = as.numeric(upper)
  )
}

hs_stop_animal_non_intercept <- function() {
  stop(
    "Only random-intercept syntax `animal(1 | id, pedigree = ped)` and the ",
    "opt-in random-regression syntax `animal(rr(covariate, order = k) | id, ",
    "pedigree = ped)` are implemented inside `animal()`. For the current opt-in ",
    "multivariate animal model, put traits on the left-hand side as ",
    "`cbind(trait1, trait2) ~ ... + animal(1 | id, pedigree = ped)` and use ",
    "`engine_control = list(target = \"multivariate\")`. Random regression uses ",
    "`engine_control = list(target = \"random_regression\")`. Long-format ",
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
    "grammar such as `cov = us()`, `cov = diag()`, `cov = lowrank(K = 2)`, ",
    "or `cov = fa(K = 2)` is planned, not implemented.",
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

  # single_step() construction path: `pedigree = ped` + `markers = M` builds the
  # single-step H^-1 engine-side (Aguilar et al. 2010), distinct from the
  # supplied-`Hinv` path below.
  if (identical(term, "single_step")) {
    if ("pedigree" %in% arg_names) {
      return(hs_parse_single_step_construct(
        call,
        args,
        arg_names,
        group,
        data,
        env
      ))
    }
    if ("markers" %in% arg_names) {
      stop(
        "`single_step()` marker-based construction needs a pedigree: ",
        "`single_step(1 | id, pedigree = ped, markers = M)`. To use a ",
        "precomputed inverse instead, write `single_step(1 | id, Hinv = Hinv)`.",
        call. = FALSE
      )
    }
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

# Parse the single-step CONSTRUCTION call `single_step(1 | id, pedigree = ped,
# markers = M, ...)`. Combines the pedigree path (id/sire/dam -> Ainv, A) with a
# genotyped-subset marker matrix (-> G among the genotyped animals). The crux is
# the `genotyped_rows` alignment (docs/design/25 §3): the genotyped ids must be a
# subset of the pedigree ids (NOT the observed ids -- ungenotyped phenotyped
# animals are the whole point of single-step), and the marker rows are reordered
# to the genotyped animals' sorted pedigree-row positions so G aligns with the
# `genotyped_rows` the engine expects.
hs_parse_single_step_construct <- function(
  call,
  args,
  arg_names,
  group,
  data,
  env
) {
  named_args <- args[arg_names != ""]
  # The construction path and the supplied-inverse path are mutually exclusive.
  if (any(c("Hinv", "H") %in% names(named_args))) {
    stop(
      "`single_step()` takes EITHER a precomputed `Hinv` ",
      "(`single_step(1 | id, Hinv = Hinv)`) OR `pedigree` + `markers` to ",
      "construct H^-1 -- not both.",
      call. = FALSE
    )
  }
  accepted <- c(
    "pedigree",
    "markers",
    "tau",
    "omega",
    "blend_weight",
    "ridge"
  )
  unsupported <- setdiff(names(named_args), accepted)
  if (length(unsupported) > 0L) {
    stop(
      "`single_step()` construction argument",
      if (length(unsupported) > 1L) "s " else " ",
      paste(sprintf("`%s`", unsupported), collapse = ", "),
      if (length(unsupported) > 1L) " are" else " is",
      " planned, not implemented.",
      call. = FALSE
    )
  }
  if (is.null(named_args$markers)) {
    stop(
      "`single_step(1 | id, pedigree = ped, markers = M)` construction requires ",
      "a `markers` matrix alongside `pedigree`. Supply a precomputed `Hinv` ",
      "instead via `single_step(1 | id, Hinv = Hinv)`.",
      call. = FALSE
    )
  }

  observed_ids <- as.character(data[[group]])

  ped_df <- hs_eval_pedigree(named_args$pedigree, data, env)
  pedigree <- hs_validate_pedigree(ped_df, observed_ids, group)
  ped_ids <- pedigree$ids

  markers <- hs_eval_genomic_ginv(
    named_args$markers,
    data,
    env,
    what = "markers"
  )
  markers <- hs_validate_genomic_markers(markers)
  geno_ids <- rownames(markers)
  not_in_ped <- setdiff(geno_ids, ped_ids)
  if (length(not_in_ped) > 0L) {
    shown <- not_in_ped[seq_len(min(5L, length(not_in_ped)))]
    stop(
      "`single_step()` `markers` row ids must all be present in the pedigree. ",
      "Genotyped id(s) not in the pedigree: ",
      paste(sprintf("`%s`", shown), collapse = ", "),
      ".",
      call. = FALSE
    )
  }

  # genotyped_rows: the genotyped animals' pedigree-row positions, sorted
  # ascending; reorder the marker rows to match so G's rows/cols align.
  ped_pos <- match(geno_ids, ped_ids)
  ord <- order(ped_pos)
  genotyped_rows <- ped_pos[ord]
  markers <- markers[ord, , drop = FALSE]

  knob <- function(name, default) {
    if (is.null(named_args[[name]])) {
      return(default)
    }
    value <- as.numeric(eval(named_args[[name]], envir = data, enclos = env))
    if (length(value) != 1L || !is.finite(value)) {
      stop(
        "`single_step()` `",
        name,
        "` must be a single finite number.",
        call. = FALSE
      )
    }
    value
  }

  list(
    type = "single_step",
    source = "construct",
    term = hs_deparse(call),
    design = "intercept",
    group = group,
    values = observed_ids,
    ids = ped_ids,
    pedigree = pedigree,
    markers = markers,
    genotyped_rows = genotyped_rows,
    tau = knob("tau", 1),
    omega = knob("omega", 1),
    blend_weight = knob("blend_weight", 0),
    ridge = knob("ridge", 0),
    relationship = "single_step",
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

  # Iterative DFS post-order (explicit stack) emulating the former recursion so
  # deep linear pedigrees no longer overflow the call stack or get misreported
  # as cycles. The ordering is identical to the recursive version: for each node
  # we fully process the sire subtree, then the dam subtree, then emit the node.
  # `state` codes 0 = unseen (white), 1 = on the stack (grey), 2 = done (black);
  # re-entering a grey node is a real parent-offspring cycle.
  n <- length(ids)
  state <- integer(n)
  order <- integer(n)
  n_emitted <- 0L

  # Each stack frame is a node `index` with a `phase`: 0 = on entry (mark grey,
  # then descend to sire), 1 = sire subtree done (descend to dam), 2 = dam
  # subtree done (mark black, emit). Frames are stored in parallel vectors with
  # a top pointer to avoid per-push reallocation on deep pedigrees.
  cap <- max(n, 1L)
  stack_index <- integer(cap)
  stack_phase <- integer(cap)
  top <- 0L

  push <- function(index, phase) {
    top <<- top + 1L
    if (top > length(stack_index)) {
      new_cap <- length(stack_index) * 2L
      stack_index <<- c(stack_index, integer(new_cap - length(stack_index)))
      stack_phase <<- c(stack_phase, integer(new_cap - length(stack_phase)))
    }
    stack_index[[top]] <<- index
    stack_phase[[top]] <<- phase
    invisible(NULL)
  }

  for (start in seq_len(n)) {
    if (state[[start]] != 0L) {
      next
    }
    push(start, 0L)
    while (top > 0L) {
      index <- stack_index[[top]]
      phase <- stack_phase[[top]]

      if (phase == 0L) {
        # Entry: a grey node here means we re-entered a node still on the stack,
        # i.e. a true parent-offspring cycle. A black node was already emitted.
        if (state[[index]] == 2L) {
          top <- top - 1L
          next
        }
        if (state[[index]] == 1L) {
          stop(
            "`pedigree` contains a parent-offspring cycle involving ID `",
            ids[[index]],
            "`.",
            call. = FALSE
          )
        }
        state[[index]] <- 1L
        stack_phase[[top]] <- 1L
        if (sire_index[[index]] != 0L) {
          push(sire_index[[index]], 0L)
        }
      } else if (phase == 1L) {
        stack_phase[[top]] <- 2L
        if (dam_index[[index]] != 0L) {
          push(dam_index[[index]], 0L)
        }
      } else {
        state[[index]] <- 2L
        n_emitted <- n_emitted + 1L
        order[[n_emitted]] <- index
        top <- top - 1L
      }
    }
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
    "precision",
    "group",
    "unknown_parent_group",
    "metafounder",
    "inbreeding"
  )
}

hs_stop_planned_marker <- function(expr) {
  expr <- hs_unwrap_parentheses(expr)
  marker <- as.character(expr[[1L]])
  stop(
    "`",
    marker,
    "()` is planned, not implemented. Run `formula_status()` for the live ",
    "list of which terms parse and which fit.",
    call. = FALSE
  )
}

# Every recognized effect/marker name, whether implemented (`animal()`) or
# planned. Used to catch such a call nested inside an interaction or function
# term (e.g. `x:dominance(1 | id)`), which is not a top-level random effect.
hs_effect_marker_names <- function() {
  c("animal", hs_planned_marker_names())
}

# The first recognized effect/marker name used as a *call* anywhere inside an
# expression, or NA if none. Only call heads count, so a fixed variable that
# merely shares a name (e.g. a column called `dominance` in `sex:dominance`) is
# not flagged.
hs_nested_effect_call_name <- function(expr) {
  if (!is.call(expr)) {
    return(NA_character_)
  }
  head <- expr[[1L]]
  if (is.symbol(head) && as.character(head) %in% hs_effect_marker_names()) {
    return(as.character(head))
  }
  for (part in as.list(expr)[-1L]) {
    hit <- hs_nested_effect_call_name(part)
    if (!is.na(hit)) {
      return(hit)
    }
  }
  NA_character_
}

# Reject a recognized effect/marker call nested inside a fixed term. The term
# itself is not a top-level effect (those were already consumed), so any such
# call found here is nested and would otherwise abort with a cryptic base-R
# error when the fixed-effect model.frame is built. Ordinary fixed interactions
# such as `sex:age` are left untouched.
hs_check_nested_effect <- function(term) {
  marker <- hs_nested_effect_call_name(term)
  if (is.na(marker)) {
    return(invisible(NULL))
  }
  stop(
    "`",
    marker,
    "()` cannot appear inside an interaction or function call (`",
    hs_deparse(term),
    "`). Name it as a top-level random effect, for example ",
    "`y ~ ... + animal(1 | id, pedigree = ped)`. Run `formula_status()` for ",
    "the live list of which terms parse and which fit.",
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
