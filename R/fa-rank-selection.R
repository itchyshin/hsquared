# Experimental R surface for the bounded automatic FA-rank selector.

hs_validate_auto_fa_rank_control <- function(control, target, spec, payload) {
  rank_selection <- hs_engine_control_value(control, "rank_selection", NULL)
  optimizer_policy <- hs_engine_control_value(control, "optimizer_policy", NULL)
  if (
    !is.null(optimizer_policy) &&
      (!is.character(optimizer_policy) ||
        length(optimizer_policy) != 1L ||
        is.na(optimizer_policy) ||
        !optimizer_policy %in% c("arc1_v1", "arc1_v2"))
  ) {
    hs_abort_unsupported_syntax(
      "`engine_control$optimizer_policy` accepts `\"arc1_v1\"` or `\"arc1_v2\"`."
    )
  }
  rank_selection_was_missing <- is.null(rank_selection)
  if (rank_selection_was_missing && is.null(optimizer_policy)) {
    return(FALSE)
  }
  if (rank_selection_was_missing) {
    rank_selection <- "fixed"
  }
  if (
    !is.character(rank_selection) ||
      length(rank_selection) != 1L ||
      is.na(rank_selection) ||
      !(rank_selection %in%
        "auto" ||
        (rank_selection_was_missing && !is.null(optimizer_policy)))
  ) {
    hs_abort_unsupported_syntax(
      "`engine_control$rank_selection` currently accepts only `\"auto\"`."
    )
  }
  if (
    !identical(control$engine, "julia") ||
      !identical(target, "multivariate") ||
      !"target" %in% names(control$engine_control)
  ) {
    hs_abort_unsupported_syntax(
      "Automatic FA-rank selection requires explicit `engine = \"julia\"` and `target = \"multivariate\"`."
    )
  }
  if ("max_dense_cells" %in% names(control$engine_control)) {
    hs_abort_unsupported_syntax(
      "Arc 1 FA rank selection does not honour an explicit `max_dense_cells` override."
    )
  }
  effective_iterations <- hs_engine_control_value(control, "iterations", 2000L)
  hs_validate_iterations(effective_iterations)
  policy_enabled <- !is.null(optimizer_policy)
  if (policy_enabled && is.null(payload$pedigree)) {
    hs_abort_unsupported_syntax(
      "`optimizer_policy = \"arc1_v1\"` requires a validated pedigree relationship."
    )
  }
  if (policy_enabled && !identical(as.integer(effective_iterations), 2000L)) {
    hs_abort_unsupported_syntax(
      "`optimizer_policy = \"arc1_v1\"` uses frozen `iterations = 2000`; omit `iterations`."
    )
  }
  conflicts <- if (identical(rank_selection, "auto")) {
    intersect(
      names(control$engine_control),
      c("rank", "initial", "genetic_structure")
    )
  } else {
    intersect(names(control$engine_control), "initial")
  }
  if (length(conflicts)) {
    hs_abort_unsupported_syntax(
      "FA policy selection cannot be combined with explicit ",
      paste(sprintf("`%s`", conflicts), collapse = ", "),
      "."
    )
  }
  if (
    identical(rank_selection, "fixed") &&
      (!identical(
        hs_engine_control_value(control, "genetic_structure", NULL),
        "factor_analytic"
      ) ||
        !identical(hs_engine_control_value(control, "rank", NULL), 1L))
  ) {
    hs_abort_unsupported_syntax(
      "`optimizer_policy = \"arc1_v1\"` fixed-rank mode requires `genetic_structure = \"factor_analytic\"` and `rank = 1L`."
    )
  }
  if (
    !isTRUE(spec$response$multivariate) ||
      !is.matrix(payload$Y) ||
      ncol(payload$Y) != 4L ||
      anyNA(payload$Y) ||
      !identical(payload$family, "gaussian") ||
      !identical(spec$method, "REML") ||
      !identical(names(spec$random), "animal") ||
      ncol(payload$X) != 1L ||
      !identical(payload$metadata$fixed_colnames, "(Intercept)") ||
      nrow(payload$Z) != nrow(payload$Y) ||
      any(Matrix::rowSums(payload$Z != 0) != 1) ||
      any(Matrix::colSums(payload$Z != 0) > 1)
  ) {
    hs_abort_unsupported_syntax(
      "Automatic FA-rank selection currently requires four complete Gaussian traits, ",
      "a pedigree `animal()` effect, trait intercepts only, and one record per observed animal."
    )
  }
  identical(rank_selection, "auto")
}

hs_fa_rank_scalar <- function(row, name, type) {
  value <- row[[name]]
  if (is.null(value) || length(value) == 0L) {
    return(switch(
      type,
      numeric = NA_real_,
      integer = NA_integer_,
      logical = NA,
      character = NA_character_
    ))
  }
  if (is.character(value) && identical(value[[1L]], "__HSQ_NONE__")) {
    return(switch(
      type,
      numeric = NA_real_,
      integer = NA_integer_,
      logical = NA,
      character = NA_character_
    ))
  }
  switch(
    type,
    numeric = as.numeric(value[[1L]]),
    integer = as.integer(value[[1L]]),
    logical = as.logical(value[[1L]]),
    character = as.character(value[[1L]])
  )
}

hs_fa_decode_vector <- function(value) {
  if (is.null(value) || length(value) == 0L) {
    return(NULL)
  }
  if (!is.character(value) || is.na(value[[1L]])) {
    return(as.numeric(value))
  }
  encoded <- value[[1L]]
  if (identical(encoded, "__HSQ_NONE__")) {
    return(NULL)
  }
  if (!nzchar(encoded)) {
    return(numeric())
  }
  parts <- strsplit(encoded, ",", fixed = TRUE)[[1L]]
  parts[parts %in% c("__HSQ_MISSING__", "missing", "nothing")] <- NA_character_
  as.numeric(parts)
}

hs_fa_decode_matrix <- function(value) {
  if (is.null(value) || length(value) == 0L) {
    return(NULL)
  }
  if (!is.character(value) || is.na(value[[1L]])) {
    return(value)
  }
  encoded <- value[[1L]]
  if (identical(encoded, "__HSQ_NONE__")) {
    return(NULL)
  }
  dimensions_text <- sub(":.*$", "", encoded)
  dimensions <- as.integer(strsplit(dimensions_text, "x", fixed = TRUE)[[1L]])
  if (length(dimensions) != 2L || anyNA(dimensions)) {
    stop(
      "Internal bridge error: encoded selector matrix has invalid dimensions.",
      call. = FALSE
    )
  }
  values_text <- sub("^[^:]*:", "", encoded)
  values <- if (nzchar(values_text)) {
    as.numeric(strsplit(values_text, ",", fixed = TRUE)[[1L]])
  } else {
    numeric()
  }
  if (length(values) != prod(dimensions)) {
    stop(
      "Internal bridge error: encoded selector matrix has invalid value count.",
      call. = FALSE
    )
  }
  matrix(values, nrow = dimensions[[1L]], ncol = dimensions[[2L]])
}

# Shared production interrupt boundary. The runner and reader are private
# injection seams for the controlled Julia->R interruption witness.
hs_julia_run_fa_rank_command <- function(
  command,
  ledger_name,
  runner = JuliaCall::julia_command,
  ledger_reader = function() JuliaCall::julia_eval(paste0(ledger_name, "[]"))
) {
  propagate_interrupt <- function(err) {
    partial <- tryCatch(ledger_reader(), error = function(ignore) NULL)
    condition <- structure(
      list(
        message = conditionMessage(err),
        call = conditionCall(err),
        partial_ledger = partial
      ),
      class = c("hsquared_fa_rank_interrupt", "interrupt", "condition")
    )
    stop(condition)
  }
  tryCatch(
    runner(command),
    interrupt = propagate_interrupt,
    error = function(err) {
      is_interrupt <- inherits(err, "interrupt") ||
        inherits(err, "hsquared_julia_interrupt") ||
        grepl(
          "InterruptException|interrupted",
          conditionMessage(err),
          ignore.case = TRUE
        )
      if (is_interrupt) {
        propagate_interrupt(err)
      }
      stop(err)
    }
  )
}

hs_fa_rank_rows <- function(rows, schema) {
  fields <- names(schema)
  if (is.environment(rows)) {
    rows <- as.list(rows)
  }
  if (is.null(rows)) {
    rows <- list()
  }
  if (is.data.frame(rows)) {
    rows <- lapply(seq_len(nrow(rows)), function(i) {
      as.list(rows[i, , drop = FALSE])
    })
  }
  if (
    is.list(rows) &&
      length(rows) &&
      !is.null(names(rows)) &&
      "rank" %in% names(rows)
  ) {
    # JuliaCall's column dictionaries can include diagnostic columns that the
    # current R schema does not consume. The rank column is the stable row
    # anchor; other schema columns may be omitted or arrive in any order.
    n_rows <- length(rows[["rank"]])
    supplied_schema_fields <- intersect(names(rows), fields)
    for (field in supplied_schema_fields) {
      column <- rows[[field]]
      type <- schema[[field]]
      column_n <- if (
        type %in% c("matrix", "vector") && is.null(column) && n_rows == 1L
      ) {
        1L
      } else if (type == "matrix" && length(dim(column)) == 3L) {
        dim(column)[[3L]]
      } else if (type == "matrix" && is.matrix(column)) {
        if (n_rows == 1L) 1L else ncol(column)
      } else if (type == "vector" && is.matrix(column)) {
        if (nrow(column) == n_rows) nrow(column) else ncol(column)
      } else {
        length(column)
      }
      if (column_n != n_rows) {
        stop(
          "Internal bridge error: selector column lengths do not match rank rows.",
          call. = FALSE
        )
      }
    }
    column_cell <- function(column, i, type) {
      if (type == "matrix") {
        if (is.character(column)) {
          return(hs_fa_decode_matrix(column[[i]]))
        }
        dimensions <- dim(column)
        if (length(dimensions) == 3L && dimensions[[3L]] == n_rows) {
          return(column[,, i])
        }
        if (is.list(column) && length(column) == n_rows) {
          return(column[[i]])
        }
        if (n_rows == 1L && length(dimensions) == 2L) {
          return(column)
        }
        if (is.null(column) && n_rows == 1L) {
          return(NULL)
        }
        stop(
          "Internal bridge error: selector covariance column lost row/matrix dimensions.",
          call. = FALSE
        )
      }
      if (type == "vector") {
        if (is.character(column)) {
          return(hs_fa_decode_vector(column[[i]]))
        }
        if (is.list(column) && length(column) == n_rows) {
          return(column[[i]])
        }
        if (is.matrix(column) && nrow(column) == n_rows) {
          return(as.numeric(column[i, ]))
        }
        if (is.matrix(column) && ncol(column) == n_rows) {
          return(as.numeric(column[, i]))
        }
        if (is.list(column) && n_rows == 1L) {
          return(column[[1L]])
        }
        if (is.null(column) && n_rows == 1L) {
          return(NULL)
        }
        stop(
          "Internal bridge error: selector vector column lost row dimensions.",
          call. = FALSE
        )
      }
      if (is.list(column)) column[[i]] else column[[i]]
    }
    rows <- lapply(seq_len(n_rows), function(i) {
      stats::setNames(
        lapply(fields, function(field) {
          type <- schema[[field]]
          column <- if (field %in% names(rows)) {
            rows[[field]]
          } else if (type %in% c("matrix", "vector")) {
            rep(list(NULL), n_rows)
          } else {
            rep("__HSQ_NONE__", n_rows)
          }
          column_cell(column, i, type)
        }),
        fields
      )
    })
  }
  if (!is.list(rows)) {
    stop("Internal bridge error: selector rows are not a list.", call. = FALSE)
  }
  out <- lapply(fields, function(field) {
    type <- schema[[field]]
    if (type %in% c("matrix", "vector")) {
      I(lapply(rows, function(row) row[[field]]))
    } else {
      vapply(
        rows,
        hs_fa_rank_scalar,
        FUN.VALUE = switch(
          type,
          numeric = NA_real_,
          integer = NA_integer_,
          logical = NA,
          character = NA_character_
        ),
        name = field,
        type = type
      )
    }
  })
  names(out) <- fields
  as.data.frame(
    out,
    optional = TRUE,
    stringsAsFactors = FALSE,
    check.names = FALSE
  )
}

hs_normalize_fa_rank_selection <- function(
  raw,
  payload,
  selected_fit = NULL,
  spec = NULL,
  call = NULL
) {
  if (is.environment(raw)) {
    raw <- as.list(raw)
  }
  get <- function(name, default = NULL) raw[[name]] %||% default
  policy_request <- get("optimizer_policy")
  if (identical(policy_request, "arc1_v2")) {
    source_identity <- get("source_identity")
    if (
      !is.character(source_identity) ||
        length(source_identity) != 1L ||
        is.na(source_identity) ||
        !grepl("^[[:xdigit:]]{64}$", source_identity)
    ) {
      stop(
        "Internal bridge error: arc1_v2 requires a 64-digit source identity.",
        call. = FALSE
      )
    }
    if (!identical(as.integer(get("optimizer_policy_version")), 2L)) {
      stop(
        "Internal bridge error: arc1_v2 policy version must be 2.",
        call. = FALSE
      )
    }
  }
  candidate_schema <- list(
    rank = "integer",
    structure = "character",
    status = "character",
    reason = "character",
    eligible = "logical",
    selected_start = "character",
    loglik = "numeric",
    q = "integer",
    penalty = "numeric",
    criterion = "numeric",
    converged = "logical",
    attempts_count = "integer",
    minimum_floor_distance = "numeric",
    near_floor = "logical",
    objective_range = "numeric",
    g_relative_disagreement = "numeric",
    r_relative_disagreement = "numeric",
    requested_optimizer_policy = "character",
    actual_optimizer_policy = "character",
    optimizer_policy = "character",
    optimizer_policy_version = "integer",
    covariance_representation = "character",
    source_identity = "character"
  )
  attempt_schema <- list(
    rank = "integer",
    structure = "character",
    start_id = "character",
    retry_index = "integer",
    attempted = "logical",
    status = "character",
    reason = "character",
    failure_status = "character",
    converged = "logical",
    optimizer_converged = "logical",
    optimizer_assessment_status = "character",
    optimizer_assessment_reason = "character",
    optimizer_status = "character",
    line_search_stats = "character",
    optimizer_iterations = "integer",
    optimizer_objective = "numeric",
    finite_objective = "logical",
    finite_estimates = "logical",
    pd_genetic = "logical",
    pd_residual = "logical",
    loglik = "numeric",
    reevaluated_loglik = "numeric",
    objective_discrepancy = "numeric",
    q = "integer",
    penalty = "numeric",
    criterion = "numeric",
    initial_parameters = "vector",
    estimated_parameters = "vector",
    uniqueness = "vector",
    floor_distances = "vector",
    near_floor = "logical",
    eligible = "logical",
    selected_within_rank = "logical",
    selected = "logical",
    genetic_covariance = "matrix",
    residual_covariance = "matrix",
    genetic_loadings = "matrix",
    requested_optimizer_policy = "character",
    actual_optimizer_policy = "character",
    optimizer_policy = "character",
    optimizer_policy_version = "integer",
    covariance_representation = "character",
    source_identity = "character",
    factor_valid = "logical",
    rounded_matrix_pd = "character",
    matrix_operations_status = "character",
    matrix_operations_reason = "character"
  )
  if (
    !is.null(get("optimizer_policy")) &&
      get("optimizer_policy") %in% c("arc1_v1", "arc1_v2")
  ) {
    attempt_schema <- c(
      attempt_schema,
      list(
        scaled_objective = "numeric",
        final_gradient_inf_norm = "numeric",
        numerical_gradient_inf_norms = "vector",
        numerical_gradient_discrepancies = "vector",
        numerical_gradient_status = "character",
        numerical_gradient_reason = "character",
        line_search_success = "logical",
        algorithm = "character",
        callback_requests = "integer",
        objective_evaluations = "integer",
        rejected_trials = "integer",
        domain_restarts = "integer",
        requested_optimizer_policy = "character",
        actual_optimizer_policy = "character",
        covariance_representation = "character",
        factor_valid = "logical",
        rounded_matrix_pd = "character",
        matrix_operations_status = "character",
        matrix_operations_reason = "character"
      )
    )
  }
  candidate_summary <- hs_fa_rank_rows(
    get("candidate_summary"),
    candidate_schema
  )
  attempts <- hs_fa_rank_rows(get("attempts"), attempt_schema)
  if (identical(policy_request, "arc1_v2") && nrow(attempts) > 0L) {
    attempted <- attempts$attempted %in% TRUE
    bad_actual <- attempted &
      !is.na(attempts$actual_optimizer_policy) &
      attempts$actual_optimizer_policy != "arc1_v2"
    bad_identity <- attempted &
      !is.na(attempts$source_identity) &
      attempts$source_identity != get("source_identity")
    bad_eligible <- attempted &
      attempts$eligible %in% TRUE &
      (is.na(attempts$optimizer_assessment_status) |
        attempts$optimizer_assessment_status != "accepted")
    if (any(bad_actual | bad_identity | bad_eligible, na.rm = TRUE)) {
      stop(
        "Internal bridge error: arc1_v2 attempt identity or acceptance evidence is inconsistent.",
        call. = FALSE
      )
    }
  }
  if (nrow(candidate_summary) != 2L) {
    stop(
      "Internal bridge error: FA selector must return both candidate rows.",
      call. = FALSE
    )
  }
  status <- as.character(get("selection_status", "unavailable"))[[1L]]
  selected <- NULL
  if (identical(status, "selected")) {
    if (is.null(selected_fit)) {
      selected_fit <- get("selected_fit")
    }
    if (is.null(selected_fit)) {
      stop(
        "Internal bridge error: selected rank lacks its fit payload.",
        call. = FALSE
      )
    }
    result <- hs_normalize_multivariate_result(
      selected_fit,
      payload,
      allow_missing_fa_start_metadata = TRUE
    )
    selected_spec <- spec %||%
      list(
        method = "REML",
        family = list(family = "gaussian", link = "identity"),
        target = "multivariate"
      )
    selected <- hs_new_fit(
      call = call,
      spec = selected_spec,
      payload = payload,
      result = result,
      engine = "HSquared.jl"
    )
  }
  policy <- get("optimizer_policy")
  attempted_rows <- if ("attempted" %in% names(attempts)) {
    sum(attempts$attempted, na.rm = TRUE)
  } else {
    nrow(attempts)
  }
  failed_rows <- if (
    "attempted" %in% names(attempts) && "eligible" %in% names(attempts)
  ) {
    sum(attempts$attempted & !attempts$eligible, na.rm = TRUE)
  } else if ("status" %in% names(attempts)) {
    sum(
      attempts$status %in%
        c(
          "failed",
          "interrupted",
          "nonconverged",
          "numerical_gradient_refused"
        ),
      na.rm = TRUE
    )
  } else {
    0L
  }
  failure_cause_counts <- if ("failure_status" %in% names(attempts)) {
    as.list(table(
      attempts$failure_status[attempts$attempted %in% TRUE],
      useNA = "no"
    ))
  } else {
    list()
  }
  scheduled_value <- get("starts_scheduled", get("starts_planned"))
  if (
    is.null(scheduled_value) &&
      !is.null(policy) &&
      policy %in% c("arc1_v1", "arc1_v2")
  ) {
    scheduled_value <- nrow(attempts)
  }
  guard_results <- get("guard_results")
  if (!is.null(guard_results)) {
    guard_results <- hs_arc1_plain_to_list(guard_results)
    witness <- guard_results$nesting_witness
    if (is.list(witness) && identical(witness$discrepancy, "__HSQ_NONE__")) {
      witness$discrepancy <- NULL
      guard_results$nesting_witness <- witness
    }
  }
  structure(
    list(
      selection_status = status,
      reason = hs_fa_rank_scalar(
        list(reason = get("reason")),
        "reason",
        "character"
      ),
      requested_ranks = c(0L, 1L),
      selected_rank = hs_fa_rank_scalar(
        list(x = get("selected_rank")),
        "x",
        "integer"
      ),
      criterion = as.character(get("criterion", "reml_aic_covariance"))[[1L]],
      criterion_status = as.character(get("criterion_status", "experimental"))[[
        1L
      ]],
      q = as.integer(unlist(get("q", c(14L, 18L)), use.names = FALSE)),
      penalties = as.numeric(unlist(
        get("penalties", c(28, 36)),
        use.names = FALSE
      )),
      criterion_difference = hs_fa_rank_scalar(
        list(x = get("criterion_difference")),
        "x",
        "numeric"
      ),
      tie_tolerance = hs_fa_rank_scalar(
        list(x = get("tie_tolerance")),
        "x",
        "numeric"
      ),
      near_tie = hs_fa_rank_scalar(list(x = get("near_tie")), "x", "logical"),
      kernel_ratio = hs_fa_rank_scalar(
        list(x = get("kernel_ratio")),
        "x",
        "numeric"
      ),
      nesting_witness_discrepancy = hs_fa_rank_scalar(
        list(x = get("nesting_witness_discrepancy")),
        "x",
        "numeric"
      ),
      guard_results = guard_results,
      candidate_summary = candidate_summary,
      attempts = attempts,
      records = get("records"),
      design_fingerprint = get("design_fingerprint"),
      relationship_fingerprint = get("relationship_fingerprint"),
      boundary_sensitive = hs_fa_rank_scalar(
        list(x = get("boundary_sensitive")),
        "x",
        "logical"
      ),
      start_sensitive = hs_fa_rank_scalar(
        list(x = get("start_sensitive")),
        "x",
        "logical"
      ),
      uncertainty_scope = as.character(get(
        "uncertainty_scope",
        "conditional_on_selected_rank"
      ))[[1L]],
      optimizer_policy = hs_fa_rank_scalar(list(x = policy), "x", "character"),
      requested_optimizer_policy = hs_fa_rank_scalar(
        list(x = get("requested_optimizer_policy")),
        "x",
        "character"
      ),
      actual_optimizer_policy = hs_fa_rank_scalar(
        list(x = get("actual_optimizer_policy")),
        "x",
        "character"
      ),
      covariance_representation = hs_fa_rank_scalar(
        list(x = get("covariance_representation")),
        "x",
        "character"
      ),
      optimizer_policy_version = hs_fa_rank_scalar(
        list(x = get("optimizer_policy_version")),
        "x",
        "integer"
      ),
      optimizer_algorithm = hs_fa_rank_scalar(
        list(x = get("optimizer_algorithm")),
        "x",
        "character"
      ),
      optimizer_iterations = hs_fa_rank_scalar(
        list(x = get("optimizer_iterations")),
        "x",
        "integer"
      ),
      optimizer_tolerance = hs_fa_rank_scalar(
        list(x = get("optimizer_tolerance")),
        "x",
        "numeric"
      ),
      final_scaled_gradient_tolerance = hs_fa_rank_scalar(
        list(x = get("final_scaled_gradient_tolerance")),
        "x",
        "numeric"
      ),
      numerical_gradient_steps = hs_fa_decode_vector(get(
        "numerical_gradient_steps"
      )),
      numerical_gradient_tolerance = hs_fa_rank_scalar(
        list(x = get("numerical_gradient_tolerance")),
        "x",
        "numeric"
      ),
      source_identity = hs_fa_rank_scalar(
        list(x = get("source_identity")),
        "x",
        "character"
      ),
      failure_count = hs_fa_rank_scalar(
        list(x = get("failure_count", failed_rows)),
        "x",
        "integer"
      ),
      failure_cause_counts = failure_cause_counts,
      starts_scheduled = hs_fa_rank_scalar(
        list(x = scheduled_value),
        "x",
        "integer"
      ),
      starts_attempted = hs_fa_rank_scalar(
        list(x = get("starts_attempted", attempted_rows)),
        "x",
        "integer"
      ),
      selected_fit = selected
    ),
    class = "hsquared_fa_rank_selection"
  )
}

#' @export
print.hsquared_fa_rank_selection <- function(x, ...) {
  cat("<hsquared_fa_rank_selection>\n")
  cat("  status: ", x$selection_status, "\n", sep = "")
  if (!is.null(x$selected_rank) && !is.na(x$selected_rank)) {
    cat("  selected shared-factor count: ", x$selected_rank, "\n", sep = "")
  }
  if (!is.null(x$reason) && !is.na(x$reason)) {
    cat("  reason: ", x$reason, "\n", sep = "")
  }
  if (!is.null(x$criterion_difference) && !is.na(x$criterion_difference)) {
    cat(
      "  criterion difference (K1 - K0): ",
      signif(x$criterion_difference, 5),
      "\n",
      sep = ""
    )
  }
  cat("  uncertainty: conditional on selected rank\n")
  attempted <- x$starts_attempted
  if (is.null(attempted) || is.na(attempted)) {
    attempted <- if ("attempted" %in% names(x$attempts)) {
      sum(x$attempts$attempted, na.rm = TRUE)
    } else {
      nrow(x$attempts)
    }
  }
  scheduled <- x$starts_scheduled %||% NA_integer_
  cat(
    "  optimizer starts: ",
    attempted,
    " attempted of ",
    scheduled,
    " scheduled\n",
    sep = ""
  )
  invisible(x)
}

#' @export
fit_diagnostics.hsquared_fa_rank_selection <- function(object, ...) {
  if (!inherits(object, "hsquared_fa_rank_selection")) {
    stop(
      "`object` must be an `hsquared_fa_rank_selection` object.",
      call. = FALSE
    )
  }
  value <- function(x) {
    if (is.null(x) || length(x) == 0L) {
      return(NA_character_)
    }
    paste(as.character(x), collapse = ", ")
  }
  data.frame(
    metric = c(
      "selection_status",
      "reason",
      "selected_rank",
      "criterion",
      "criterion_status",
      "criterion_difference",
      "tie_tolerance",
      "near_tie",
      "kernel_ratio",
      "nesting_witness_discrepancy",
      "boundary_sensitive",
      "start_sensitive",
      "uncertainty_scope",
      "candidate_rows",
      "attempt_rows_in_ledger",
      "actual_attempted_rows",
      "optimizer_policy",
      "optimizer_policy_version",
      "optimizer_algorithm",
      "optimizer_iterations",
      "optimizer_tolerance",
      "final_scaled_gradient_tolerance",
      "numerical_gradient_steps",
      "numerical_gradient_tolerance",
      "source_identity",
      "starts_scheduled",
      "starts_attempted",
      "failure_count"
    ),
    value = c(
      value(object$selection_status),
      value(object$reason),
      value(object$selected_rank),
      value(object$criterion),
      value(object$criterion_status),
      value(object$criterion_difference),
      value(object$tie_tolerance),
      value(object$near_tie),
      value(object$kernel_ratio),
      value(object$nesting_witness_discrepancy),
      value(object$boundary_sensitive),
      value(object$start_sensitive),
      value(object$uncertainty_scope),
      as.character(nrow(object$candidate_summary)),
      as.character(nrow(object$attempts)),
      as.character(object$starts_attempted),
      value(object$optimizer_policy),
      value(object$optimizer_policy_version),
      value(object$optimizer_algorithm),
      value(object$optimizer_iterations),
      value(object$optimizer_tolerance),
      value(object$final_scaled_gradient_tolerance),
      value(object$numerical_gradient_steps),
      value(object$numerical_gradient_tolerance),
      value(object$source_identity),
      value(object$starts_scheduled),
      value(object$starts_attempted),
      value(object$failure_count)
    ),
    stringsAsFactors = FALSE
  )
}
