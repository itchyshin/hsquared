hs_build_model_spec <- function(formula, data, family, REML) {
  hs_validate_model_inputs(formula, data, family, REML)

  env <- environment(formula)
  if (is.null(env)) {
    env <- parent.frame()
  }

  rhs_terms <- hs_split_additive_rhs(formula[[3L]])
  planned_pos <- which(vapply(
    rhs_terms,
    hs_is_planned_genomic_marker_call,
    logical(1L)
  ))
  if (length(planned_pos) > 0L) {
    hs_stop_planned_genomic_marker(rhs_terms[[planned_pos[[1L]]]])
  }

  animal_pos <- which(vapply(rhs_terms, hs_is_animal_call, logical(1L)))

  if (length(animal_pos) == 0L) {
    stop(
      "`formula` must contain exactly one v0.1 animal term: ",
      "`animal(1 | id, pedigree = ped)`.",
      call. = FALSE
    )
  }
  if (length(animal_pos) > 1L) {
    stop(
      "`formula` can contain only one `animal()` term in the v0.1 parser. ",
      "Multiple animal effects are planned, not implemented.",
      call. = FALSE
    )
  }

  animal_spec <- hs_parse_animal_call(rhs_terms[[animal_pos]], data, env)
  fixed_terms <- rhs_terms[-animal_pos]
  fixed_formula <- formula
  fixed_formula[[3L]] <- hs_rebuild_additive_rhs(fixed_terms)
  environment(fixed_formula) <- env

  model_frame <- stats::model.frame(
    fixed_formula,
    data = data,
    na.action = stats::na.pass,
    drop.unused.levels = FALSE
  )

  if (anyNA(model_frame)) {
    stop(
      "Missing values in the response or fixed-effect variables are not ",
      "implemented for the v0.1 parser.",
      call. = FALSE
    )
  }

  response <- stats::model.response(model_frame)
  if (!is.numeric(response)) {
    stop(
      "The v0.1 parser supports numeric Gaussian responses only.",
      call. = FALSE
    )
  }

  fixed_terms_obj <- stats::terms(fixed_formula)
  fixed_design <- stats::model.matrix(fixed_terms_obj, data = model_frame)

  list(
    formula = formula,
    fixed_formula = fixed_formula,
    family = list(family = family$family, link = family$link),
    method = if (isTRUE(REML)) "REML" else "ML",
    response = list(name = all.vars(formula[[2L]])[1L], values = response),
    fixed = list(
      terms = attr(fixed_terms_obj, "term.labels"),
      design = fixed_design,
      contrasts = attr(fixed_design, "contrasts")
    ),
    random = list(animal = animal_spec),
    bridge = list(
      status = "planned",
      engine = "HSquared.jl",
      target = "fit_animal_model(y, X, Z, Ainv; method = :REML)"
    )
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

hs_parse_animal_call <- function(call, data, env) {
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
    stop(
      "Only random-intercept syntax `animal(1 | id, pedigree = ped)` is ",
      "implemented. Animal slopes and trait terms are planned, not ",
      "implemented.",
      call. = FALSE
    )
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
  if (!"pedigree" %in% names(named_args)) {
    stop(
      "`animal()` requires `pedigree = ped` in the v0.1 parser.",
      call. = FALSE
    )
  }

  pedigree <- hs_eval_pedigree(named_args$pedigree, data, env)
  pedigree_spec <- hs_validate_pedigree(
    pedigree,
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
    pedigree = pedigree_spec
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

hs_is_planned_genomic_marker_call <- function(expr) {
  expr <- hs_unwrap_parentheses(expr)
  is.call(expr) &&
    as.character(expr[[1L]]) %in% hs_planned_genomic_marker_names()
}

hs_planned_genomic_marker_names <- function() {
  c("genomic", "single_step", "markers", "marker_scan", "qtl_scan")
}

hs_stop_planned_genomic_marker <- function(expr) {
  expr <- hs_unwrap_parentheses(expr)
  marker <- as.character(expr[[1L]])
  stop(
    "`",
    marker,
    "()` is planned, not implemented. The v0.1 parser currently accepts ",
    "only `animal(1 | id, pedigree = ped)`. Genomic, marker-scan, ",
    "single-step, and QTL/eQTL terms are tracked in the roadmap.",
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
