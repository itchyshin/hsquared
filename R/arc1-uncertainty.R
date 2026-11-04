# Explicit controls and extractors for the bounded Arc 1 uncertainty methods.

hs_validate_arc1_uncertainty_control <- function(
  control,
  target,
  spec,
  payload,
  automatic_fa = FALSE
) {
  method <- hs_engine_control_value(control, "uncertainty_method", NULL)
  bootstrap_keys <- intersect(
    names(control$engine_control),
    c("bootstrap_B", "bootstrap_seeds", "bootstrap_seed")
  )
  if (length(bootstrap_keys) > 0L && !identical(method, "arc1_bootstrap_v1")) {
    hs_abort_unsupported_syntax(
      "Bootstrap controls require `uncertainty_method = \"arc1_bootstrap_v1\"`."
    )
  }
  if (is.null(method)) {
    return(NULL)
  }
  if (
    !is.character(method) ||
      length(method) != 1L ||
      is.na(method) ||
      !method %in%
        c(
          "arc1_profile_v1",
          "arc1_profile_v2",
          "arc1_profile_v3",
          "arc1_profile_v4",
          "arc1_bootstrap_v1"
        )
  ) {
    hs_abort_unsupported_syntax(
      "`uncertainty_method` accepts only the documented Arc 1 profile methods or `\"arc1_bootstrap_v1\"`."
    )
  }
  if (
    method %in%
      c(
        "arc1_profile_v1",
        "arc1_profile_v2",
        "arc1_profile_v3",
        "arc1_profile_v4"
      )
  ) {
    counts <- if (!is.null(payload$Z)) {
      Matrix::colSums(payload$Z != 0)
    } else {
      numeric()
    }
    ignored <- intersect(
      names(control$engine_control),
      c("initial", "iterations", "max_dense_cells")
    )
    if (
      !identical(spec$family$family, "gaussian") ||
        isTRUE(spec$response$multivariate) ||
        !identical(target, "repeatability") ||
        is.null(payload$pedigree) ||
        is.null(spec$random$permanent) ||
        length(counts) == 0L ||
        any(Matrix::rowSums(payload$Z != 0) != 1) ||
        any(counts[counts > 0] != 2) ||
        !identical(
          hs_engine_control_value(control, "scale_method", "dense"),
          "dense"
        ) ||
        length(ignored) > 0L
    ) {
      hs_abort_unsupported_syntax(
        "Arc 1 profile methods require a univariate Gaussian pedigree repeatability model, exactly two records per observed animal, `scale_method = \"dense\"`, and no `initial`, `iterations`, or `max_dense_cells` override."
      )
    }
  } else {
    B <- hs_engine_control_value(control, "bootstrap_B", NULL)
    seeds <- hs_arc1_exact_seeds(control, B)
    if (
      !isTRUE(automatic_fa) ||
        !identical(target, "multivariate") ||
        !identical(
          hs_engine_control_value(control, "optimizer_policy", NULL),
          "arc1_v1"
        )
    ) {
      hs_abort_unsupported_syntax(
        "`arc1_bootstrap_v1` requires automatic four-trait FA selection with `optimizer_policy = \"arc1_v1\"`."
      )
    }
    return(list(method = method, B = as.integer(B), seeds = seeds))
  }
  list(method = method)
}

hs_arc1_exact_seeds <- function(control, B) {
  if (
    is.null(B) ||
      length(B) != 1L ||
      is.na(B) ||
      !is.numeric(B) ||
      B < 1 ||
      B != floor(B) ||
      B > .Machine$integer.max
  ) {
    hs_abort_unsupported_syntax("`bootstrap_B` must be one positive integer.")
  }
  seeds <- hs_engine_control_value(control, "bootstrap_seeds", NULL)
  if (!is.null(seeds) && "bootstrap_seed" %in% names(control$engine_control)) {
    hs_abort_unsupported_syntax(
      "`bootstrap_seed` cannot be combined with `bootstrap_seeds`."
    )
  }
  if (is.null(seeds)) {
    seed <- hs_engine_control_value(control, "bootstrap_seed", NULL)
    if (is.null(seed)) {
      hs_abort_unsupported_syntax(
        "`arc1_bootstrap_v1` requires an explicit `bootstrap_seeds` vector."
      )
    }
    if (
      is.numeric(seed) &&
        (length(seed) != 1L ||
          is.na(seed) ||
          !is.finite(seed) ||
          abs(seed) > (2^53 - 1) ||
          seed != floor(seed))
    ) {
      hs_abort_unsupported_syntax(
        "Numeric `bootstrap_seed` must be an exact integer no larger than 2^53 - 1."
      )
    }
    seed <- as.character(seed)
    if (
      !grepl("^(0|[1-9][0-9]{0,19})$", seed) ||
        (nchar(seed) == 20L && seed > "18446744073709551615")
    ) {
      hs_abort_unsupported_syntax(
        "`bootstrap_seed` must be an exact decimal UInt64."
      )
    }
    hs_abort_unsupported_syntax(
      "Seed-stream derivation is not available through this bridge yet; supply the canonical `bootstrap_seeds` vector."
    )
  }
  if (
    is.numeric(seeds) &&
      any(!is.finite(seeds) | abs(seeds) > (2^53 - 1) | seeds != floor(seeds))
  ) {
    hs_abort_unsupported_syntax(
      "Numeric `bootstrap_seeds` must contain only exact integers no larger than 2^53 - 1."
    )
  }
  seeds <- as.character(seeds)
  if (
    length(seeds) != B ||
      anyNA(seeds) ||
      any(!grepl("^(0|[1-9][0-9]{0,19})$", seeds)) ||
      any(nchar(seeds) == 20L & seeds > "18446744073709551615") ||
      anyDuplicated(seeds)
  ) {
    hs_abort_unsupported_syntax(
      "`bootstrap_seeds` must contain exactly B distinct decimal UInt64 strings."
    )
  }
  seeds
}

hs_arc1_confint_table <- function(object) {
  uncertainty <- if (inherits(object, "hsquared_fa_rank_selection")) {
    object$arc1_uncertainty
  } else {
    object$result$arc1_uncertainty
  }
  if (is.null(uncertainty)) {
    stop("This fit has no `arc1_uncertainty` result.", call. = FALSE)
  }
  profile_methods <- c(
    "arc1_profile_v1",
    "arc1_profile_v2",
    "arc1_profile_v3",
    "arc1_profile_v4"
  )
  if (
    uncertainty$method %in%
      c("arc1_profile_v2", "arc1_profile_v3", "arc1_profile_v4") &&
      is.null(uncertainty$method_version)
  ) {
    stop(
      "Arc 1 profile v2/v3/v4 requires an explicit method_version matching its method identity.",
      call. = FALSE
    )
  }
  if (
    is.character(uncertainty$method) &&
      length(uncertainty$method) == 1L &&
      uncertainty$method %in% profile_methods &&
      !is.null(uncertainty$method_version) &&
      !identical(uncertainty$method, uncertainty$method_version)
  ) {
    stop(
      "Arc 1 profile method version does not match its method identity.",
      call. = FALSE
    )
  }
  if (
    is.null(uncertainty$source_identity) ||
      is.null(uncertainty$reference_source_identity) ||
      !identical(
        uncertainty$source_identity,
        uncertainty$reference_source_identity
      )
  ) {
    stop(
      "Arc 1 uncertainty and reference point source identities do not match.",
      call. = FALSE
    )
  }
  if (
    inherits(object, "hsquared_fit") &&
      uncertainty$method %in% profile_methods &&
      !identical(
        uncertainty$point_identity,
        object$result$diagnostics$point_identity
      )
  ) {
    stop(
      "Arc 1 profile intervals and displayed point estimates do not share one point fit.",
      call. = FALSE
    )
  }
  intervals <- uncertainty$intervals
  if (is.null(intervals)) {
    stop("The Arc 1 result has no interval table.", call. = FALSE)
  }
  as.data.frame(intervals, stringsAsFactors = FALSE)
}

hs_julia_arc1_plain_command <- function() {
  paste(
    "hsq_arc1_plain(x) = x === nothing ? \"__HSQ_NONE__\" :",
    "x === missing ? \"__HSQ_MISSING__\" :",
    "x isa UInt64 ? string(x) : x isa Symbol || x isa Enum ? string(x) :",
    "x isa Rational ? Dict(\"__arc1_rational__\" => Dict(\"numerator\" =>",
    "string(numerator(x)), \"denominator\" => string(denominator(x)),",
    "\"type\" => string(typeof(x)))) :",
    "x isa NamedTuple ? Dict(String(k)=>hsq_arc1_plain(getfield(x,k)) for k in keys(x)) :",
    "x isa AbstractDict ? Dict(hsq_arc1_plain(k)=>hsq_arc1_plain(v) for (k,v) in pairs(x)) :",
    "x isa AbstractArray && eltype(x) <: NamedTuple ? Any[hsq_arc1_plain(v) for v in x] :",
    "x isa AbstractArray ? map(hsq_arc1_plain,x) :",
    "x isa Tuple ? Any[hsq_arc1_plain(v) for v in x] :",
    "x isa Number || x isa AbstractString || x isa Bool ? x :",
    "error(\"unsupported Arc1 bridge leaf type: \", typeof(x));"
  )
}

hs_arc1_plain_to_list <- function(x, .seen_envs = list(), .path = "") {
  # JuliaCall leaves some nested Julia values (notably Dicts inside a returned
  # NamedTuple) as JuliaObject external pointers.  Convert those through the
  # package's documented as.list method before descending; otherwise partial
  # diagnostics can look present while remaining unusable to R callers.
  if (inherits(x, "JuliaObject")) {
    converted <- tryCatch(as.list(x), error = function(e) e)
    if (inherits(converted, "error") || identical(converted, list(x))) {
      julia_type <- tryCatch(
        as.character(JuliaCall::julia_call("typeof", x)),
        error = function(e) "unavailable"
      )
      stop(
        sprintf(
          paste0(
            "could not convert JuliaCall object in Arc 1 diagnostics at path %s ",
            "(R wrapper class: %s; Julia type: %s)."
          ),
          .path,
          paste(class(x), collapse = "/"),
          paste(julia_type, collapse = "/")
        ),
        call. = FALSE
      )
    }
    x <- converted
  }
  if (is.environment(x)) {
    if (
      any(vapply(.seen_envs, function(parent) identical(parent, x), logical(1)))
    ) {
      stop(
        "cyclic JuliaCall environment in Arc 1 diagnostics at ",
        .path,
        ".",
        call. = FALSE
      )
    }
    .seen_envs[[length(.seen_envs) + 1L]] <- x
    x <- as.list.environment(x, all.names = TRUE)
  }
  if (is.list(x) && !is.data.frame(x)) {
    nms <- names(x)
    paths <- vapply(
      seq_along(x),
      function(i) {
        label <- if (!is.null(nms) && nzchar(nms[[i]])) {
          paste0("$", nms[[i]])
        } else {
          paste0("[[", i, "]]")
        }
        paste0(.path, label)
      },
      character(1)
    )
    return(
      lapply(seq_along(x), function(i) {
        hs_arc1_plain_to_list(
          x[[i]],
          .seen_envs = .seen_envs,
          .path = paths[[i]]
        )
      }) |>
        stats::setNames(nms)
    )
  }
  x
}

hs_arc1_materialize_profile_evidence_projection <- function(projection) {
  projection <- hs_arc1_plain_to_list(projection)
  if (
    !is.list(projection) ||
      !all(c("evidence", "v4_alias_verified") %in% names(projection))
  ) {
    stop("Julia Arc 1 profile evidence projection is malformed.", call. = FALSE)
  }
  evidence <- projection$evidence
  if (!is.list(evidence)) {
    stop("Julia Arc 1 profile evidence must be a plain list.", call. = FALSE)
  }
  if (isTRUE(projection$v4_alias_verified)) {
    expected <- "arc1_profile_v4_evaluations"
    source <- "arc1_profile_v3_evaluations"
    if (
      !identical(evidence$requested_method_version, "arc1_profile_v4") ||
        !identical(evidence$actual_method_version, "arc1_profile_v4") ||
        !source %in% names(evidence) ||
        expected %in% names(evidence)
    ) {
      stop(
        "Julia Arc 1 v4 evidence alias projection is inconsistent.",
        call. = FALSE
      )
    }
    evidence[[expected]] <- evidence[[source]]
    attr(evidence, "hs_arc1_verified_bridge_alias") <- TRUE
  }
  evidence
}

hs_arc1_new_v3_sink_name <- function(method_version = "arc1_profile_v3") {
  if (
    !is.character(method_version) ||
      length(method_version) != 1L ||
      is.na(method_version) ||
      !method_version %in% c("arc1_profile_v3", "arc1_profile_v4")
  ) {
    stop("Unsupported Arc 1 evidence sink method.", call. = FALSE)
  }
  suffix <- if (identical(method_version, "arc1_profile_v4")) "v4" else "v3"
  token <- gsub(
    "[^A-Za-z0-9_]",
    "_",
    basename(tempfile(paste0("arc1", suffix, "_")))
  )
  paste0("hsq_arc1_", suffix, "_evidence_sink_", token)
}

hs_arc1_bind_profile_evidence_source <- function(evidence, source_identity) {
  if (!is.list(evidence) || is.data.frame(evidence)) {
    stop("Julia Arc 1 profile evidence must be a plain list.", call. = FALSE)
  }
  if (
    !is.character(source_identity) ||
      length(source_identity) != 1L ||
      is.na(source_identity) ||
      !nzchar(source_identity)
  ) {
    stop("The returned fit is missing its source identity.", call. = FALSE)
  }
  existing <- evidence$source_identity
  if (
    !is.character(existing) ||
      length(existing) != 1L ||
      is.na(existing) ||
      !nzchar(existing) ||
      !identical(existing, source_identity)
  ) {
    stop(
      "Julia Arc 1 profile evidence source identity does not match the returned fit.",
      call. = FALSE
    )
  }
  evidence
}

hs_arc1_julia_delete_binding <- function(name) {
  if (
    !is.character(name) ||
      length(name) != 1L ||
      !grepl("^[A-Za-z_][A-Za-z0-9_]*$", name)
  ) {
    stop("Invalid invocation-local Julia sink name.", call. = FALSE)
  }
  tryCatch(
    JuliaCall::julia_command(paste0(name, " = nothing")),
    error = function(e) invisible(NULL)
  )
  invisible(NULL)
}

hs_arc1_julia_clear_v3_binding_checked <- function(name) {
  if (
    !is.character(name) ||
      length(name) != 1L ||
      !grepl("^[A-Za-z_][A-Za-z0-9_]*$", name)
  ) {
    stop("Invalid invocation-local Julia sink name.", call. = FALSE)
  }
  JuliaCall::julia_command(paste0(name, " = nothing"))
  invisible(NULL)
}

hs_arc1_read_v3_julia_sink <- function(name) {
  plain <- JuliaCall::julia_eval(paste0("hsq_arc1_plain(", name, ")"))
  hs_arc1_plain_to_list(plain)
}

hs_arc1_read_profile_julia_sink <- function(name, method_version) {
  if (identical(method_version, "arc1_profile_v4")) {
    projection <- JuliaCall::julia_eval(paste0(
      "hsq_arc1_plain(",
      hs_julia_arc1_v4_evidence_projection_expression(name),
      ")"
    ))
    return(hs_arc1_materialize_profile_evidence_projection(projection))
  }
  hs_arc1_read_v3_julia_sink(name)
}

hs_arc1_validate_profile_evidence <- function(
  evidence,
  requested_method_version,
  require_identity = FALSE,
  verified_bridge_alias = FALSE,
  expected_source_identity = NULL
) {
  supported <- c("arc1_profile_v3", "arc1_profile_v4")
  if (
    !is.character(requested_method_version) ||
      length(requested_method_version) != 1L ||
      is.na(requested_method_version) ||
      !requested_method_version %in% supported
  ) {
    stop("Unsupported Arc 1 evidence method identity.", call. = FALSE)
  }
  if (is.null(evidence)) {
    if (isTRUE(require_identity)) {
      stop(
        "Julia Arc 1 profile evidence is missing its method identity.",
        call. = FALSE
      )
    }
    return(NULL)
  }
  if (!is.list(evidence)) {
    stop("Julia Arc 1 profile evidence must be a plain list.", call. = FALSE)
  }
  expected_key <- paste0(requested_method_version, "_evaluations")
  requested <- evidence$requested_method_version
  actual <- evidence$actual_method_version
  for (identity in list(requested, actual)) {
    if (
      !is.null(identity) &&
        (!is.character(identity) ||
          length(identity) != 1L ||
          is.na(identity) ||
          !identical(identity, requested_method_version))
    ) {
      stop(
        "Julia Arc 1 profile evidence method identity does not match the requested method.",
        call. = FALSE
      )
    }
  }
  if (
    isTRUE(require_identity) &&
      (!identical(requested, requested_method_version) ||
        !identical(actual, requested_method_version))
  ) {
    stop(
      "Julia Arc 1 profile evidence is missing its method identity.",
      call. = FALSE
    )
  }
  evaluation_keys <- grep(
    "^arc1_profile_v[34]_evaluations$",
    names(evidence),
    value = TRUE
  )
  other_keys <- setdiff(evaluation_keys, expected_key)
  if (length(evaluation_keys) > 0L && !expected_key %in% evaluation_keys) {
    stop(
      "Julia Arc 1 profile evidence contains cross-method evaluation history.",
      call. = FALSE
    )
  }
  if (isTRUE(require_identity)) {
    if (
      !is.character(expected_source_identity) ||
        length(expected_source_identity) != 1L ||
        is.na(expected_source_identity) ||
        !nzchar(expected_source_identity) ||
        !is.character(evidence$source_identity) ||
        length(evidence$source_identity) != 1L ||
        is.na(evidence$source_identity) ||
        !identical(evidence$source_identity, expected_source_identity)
    ) {
      stop(
        "Julia Arc 1 profile evidence source identity does not match the returned fit.",
        call. = FALSE
      )
    }
  }
  if (
    requested_method_version == "arc1_profile_v3" && length(other_keys) > 0L
  ) {
    stop(
      "Julia Arc 1 profile evidence contains cross-method evaluation history.",
      call. = FALSE
    )
  }
  if (
    requested_method_version == "arc1_profile_v4" &&
      all(
        c("arc1_profile_v3_evaluations", "arc1_profile_v4_evaluations") %in%
          evaluation_keys
      ) &&
      !(isTRUE(verified_bridge_alias) &&
        isTRUE(attr(evidence, "hs_arc1_verified_bridge_alias"))) &&
      !identical(
        evidence$arc1_profile_v3_evaluations,
        evidence$arc1_profile_v4_evaluations
      )
  ) {
    stop(
      "Julia Arc 1 v3/v4 aliases contain conflicting evaluation history.",
      call. = FALSE
    )
  }
  if (isTRUE(require_identity) && !expected_key %in% names(evidence)) {
    stop(
      "Julia Arc 1 profile evidence is missing its method-specific evaluation history.",
      call. = FALSE
    )
  }
  if (isTRUE(require_identity)) {
    history <- evidence[[expected_key]]
    if (!is.list(history) || is.data.frame(history)) {
      stop(
        "Julia Arc 1 profile evaluation history must be a list.",
        call. = FALSE
      )
    }
    record_fields <- c(
      "target",
      "fixed_value",
      "status",
      "events",
      "producer_history",
      "provenance_failures",
      "max_valid_loglik",
      "max_valid_centered_loglik"
    )
    valid_record <- function(record) {
      valid_event <- function(event) {
        if (!is.list(event) || is.data.frame(event)) {
          return(FALSE)
        }
        # The v3 observer remains active during v4, so v4 history may contain
        # either its path-bearing observation Dict or the corner `capture` Dict.
        path_event_fields <- c(
          "kind",
          "value",
          "status",
          "evaluation_valid",
          "components",
          "path",
          "owner",
          "candidate_id",
          "source_id"
        )
        if (all(path_event_fields %in% names(event))) {
          return(TRUE)
        }
        if (!identical(requested_method_version, "arc1_profile_v4")) {
          return(FALSE)
        }
        # Match the v4 `capture` Dict emitted by arc1_profiles.jl: its
        # corner observations carry label/components/centering_ve, and values
        # evolve through started, returned, invalid_return, error, or interrupted.
        # `hs_julia_arc1_plain_command()` encodes missing/nothing as distinct
        # string sentinels, and tuples are converted to R lists.
        event_fields <- c(
          "label",
          "components",
          "centering_ve",
          "kind",
          "status",
          "value",
          "evaluation_valid",
          "error",
          "owner",
          "candidate_id",
          "source_id"
        )
        if (
          !all(event_fields %in% names(event)) ||
            !is.character(event$label) ||
            length(event$label) != 1L ||
            is.na(event$label) ||
            !nzchar(event$label) ||
            !is.numeric(event$components) ||
            length(event$components) != 3L ||
            any(!is.finite(event$components)) ||
            !is.numeric(event$centering_ve) ||
            length(event$centering_ve) != 1L ||
            !is.finite(event$centering_ve) ||
            !is.character(event$kind) ||
            length(event$kind) != 1L ||
            is.na(event$kind) ||
            !event$kind %in% c("full", "centered") ||
            !is.character(event$status) ||
            length(event$status) != 1L ||
            is.na(event$status) ||
            !event$status %in%
              c(
                "started",
                "returned",
                "invalid_return",
                "error",
                "interrupted"
              ) ||
            !is.logical(event$evaluation_valid) ||
            length(event$evaluation_valid) != 1L ||
            is.na(event$evaluation_valid) ||
            !is.character(event$owner) ||
            length(event$owner) != 1L ||
            is.na(event$owner) ||
            !event$owner %in% c("shared", "candidate")
        ) {
          return(FALSE)
        }
        is_missing <- function(value) identical(value, "__HSQ_MISSING__")
        candidate_id <- event$candidate_id
        candidate_valid <- if (identical(event$owner, "shared")) {
          identical(candidate_id, "__HSQ_NONE__")
        } else {
          is.numeric(candidate_id) &&
            length(candidate_id) == 1L &&
            is.finite(candidate_id) &&
            candidate_id == trunc(candidate_id)
        }
        source_id <- event$source_id
        ownership_consistent <- candidate_valid &&
          is.list(source_id) &&
          length(source_id) == 5L &&
          identical(source_id[[1L]], "corner_callback") &&
          identical(source_id[[2L]], event$owner) &&
          identical(source_id[[3L]], candidate_id) &&
          identical(source_id[[4L]], event$centering_ve) &&
          identical(source_id[[5L]], event$label)
        if (!ownership_consistent) {
          return(FALSE)
        }
        valid <- isTRUE(event$evaluation_valid)
        status <- event$status
        if (valid) {
          status == "returned" &&
            is.numeric(event$value) &&
            length(event$value) == 1L &&
            is.finite(event$value) &&
            is_missing(event$error)
        } else if (status %in% c("started", "invalid_return")) {
          is_missing(event$value) && is_missing(event$error)
        } else if (status %in% c("error", "interrupted")) {
          is_missing(event$value) &&
            is.character(event$error) &&
            length(event$error) == 1L &&
            !is.na(event$error)
        } else {
          FALSE
        }
      }
      valid_producer <- function(producer) {
        producer_fields <- c(
          "path",
          "owner",
          "candidate_id",
          "source_id",
          "record"
        )
        is.list(producer) &&
          !is.data.frame(producer) &&
          all(producer_fields %in% names(producer))
      }
      is.list(record) &&
        !is.data.frame(record) &&
        all(record_fields %in% names(record)) &&
        is.character(record$target) &&
        length(record$target) == 1L &&
        !is.na(record$target) &&
        record$target %in%
          c(
            "additive_variance",
            "permanent_environment_variance",
            "residual_variance"
          ) &&
        is.numeric(record$fixed_value) &&
        length(record$fixed_value) == 1L &&
        is.finite(record$fixed_value) &&
        is.character(record$status) &&
        length(record$status) == 1L &&
        !is.na(record$status) &&
        is.list(record$events) &&
        !is.data.frame(record$events) &&
        (!length(record$events) ||
          all(vapply(record$events, valid_event, logical(1)))) &&
        is.list(record$producer_history) &&
        !is.data.frame(record$producer_history) &&
        (!length(record$producer_history) ||
          all(vapply(
            record$producer_history,
            valid_producer,
            logical(1)
          ))) &&
        is.list(record$provenance_failures) &&
        !is.data.frame(record$provenance_failures) &&
        is.numeric(record$max_valid_loglik) &&
        length(record$max_valid_loglik) == 1L &&
        !is.na(record$max_valid_loglik) &&
        is.numeric(record$max_valid_centered_loglik) &&
        length(record$max_valid_centered_loglik) == 1L &&
        !is.na(record$max_valid_centered_loglik)
    }
    if (length(history) && !all(vapply(history, valid_record, logical(1)))) {
      stop(
        "Julia Arc 1 profile evaluation record shape is malformed.",
        call. = FALSE
      )
    }
    if ("v4_tail_certificates" %in% names(evidence)) {
      certificates <- evidence$v4_tail_certificates
      valid_certificate <- function(item) {
        is.list(item) &&
          !is.data.frame(item) &&
          all(c("target", "certificate") %in% names(item)) &&
          is.character(item$target) &&
          length(item$target) == 1L &&
          !is.na(item$target) &&
          is.list(item$certificate) &&
          !is.data.frame(item$certificate)
      }
      if (
        !is.list(certificates) ||
          is.data.frame(certificates) ||
          (length(certificates) &&
            !all(vapply(certificates, valid_certificate, logical(1))))
      ) {
        stop(
          "Julia Arc 1 v4 tail certificate evidence is malformed.",
          call. = FALSE
        )
      }
    }
  }
  evidence
}

# For arc1_profile_v3/v4, callers catching `hsquared_julia_error` can inspect
# `arc1_profile_method_requested`, `arc1_profile_method_actual`,
# `arc1_profile_source_identity`, `arc1_profile_evidence`,
# `arc1_profile_evidence_retention_error`, and
# `arc1_profile_evidence_partial` with `attr()`. After interruption the partial
# diagnostics do not represent a fitted result or formed interval.
# Preserve the original translated Julia error while attaching partial profile
# evidence left in the invocation-local Julia sink after unwinding.
# The reader is called only on error. If transport fails, report that failure
# on the same condition rather than replacing the original error.
hs_arc1_profile_retention_condition_message <- function(condition) {
  message <- tryCatch(
    conditionMessage(condition),
    error = function(e) NULL,
    interrupt = function(e) NULL
  )
  if (
    is.character(message) &&
      length(message) == 1L &&
      !is.na(message) &&
      nzchar(message)
  ) {
    return(message)
  }
  paste0("secondary condition class: ", paste(class(condition), collapse = "/"))
}

hs_arc1_capture_v3_profile_error <- function(
  expr,
  requested_method_version,
  evidence_reader
) {
  retain_condition <- function(e) {
    evidence <- NULL
    retention_error <- NULL
    if (is.function(evidence_reader)) {
      evidence <- tryCatch(
        hs_arc1_validate_profile_evidence(
          evidence_reader(),
          requested_method_version
        ),
        error = function(read_error) {
          retention_error <<- hs_arc1_profile_retention_condition_message(
            read_error
          )
          NULL
        },
        interrupt = function(read_interrupt) {
          retention_error <<- hs_arc1_profile_retention_condition_message(
            read_interrupt
          )
          NULL
        }
      )
    }
    actual <- if (is.list(evidence)) {
      evidence$actual_method_version
    } else {
      NULL
    }
    source_identity <- if (is.list(evidence)) {
      evidence$source_identity
    } else {
      NULL
    }
    evaluation_keys <- if (is.list(evidence)) {
      grep("^arc1_profile_v[34]_evaluations$", names(evidence), value = TRUE)
    } else {
      character()
    }
    has_evaluations <- length(evaluation_keys) > 0L &&
      any(vapply(
        evaluation_keys,
        function(key) length(evidence[[key]]) > 0L,
        logical(1)
      ))
    has_certificates <- is.list(evidence) &&
      "v4_tail_certificates" %in% names(evidence) &&
      length(evidence$v4_tail_certificates) > 0L
    attr(e, "arc1_profile_method_requested") <- requested_method_version
    attr(e, "arc1_profile_method_actual") <- actual
    attr(e, "arc1_profile_source_identity") <- source_identity
    attr(e, "arc1_profile_evidence") <- evidence
    attr(e, "arc1_profile_evidence_retention_error") <- retention_error
    attr(e, "arc1_profile_evidence_partial") <- has_evaluations ||
      has_certificates
    stop(e)
  }
  tryCatch(force(expr), error = retain_condition, interrupt = retain_condition)
}

hs_arc1_run_v3_profile_operation <- function(
  operation,
  requested_method_version,
  evidence_reader,
  cleanup
) {
  if (!is.function(operation) || !is.function(cleanup)) {
    stop(
      "The v3 profile operation and cleanup must be functions.",
      call. = FALSE
    )
  }
  captured_condition <- NULL
  value <- tryCatch(
    hs_arc1_capture_v3_profile_error(
      operation(),
      requested_method_version,
      evidence_reader
    ),
    error = function(e) {
      captured_condition <<- e
      e
    },
    interrupt = function(e) {
      captured_condition <<- e
      e
    }
  )
  cleanup_error <- tryCatch(
    cleanup(),
    error = identity,
    interrupt = identity
  )
  if (!is.null(cleanup_error)) {
    if (inherits(captured_condition, "condition")) {
      prior <- attr(captured_condition, "arc1_profile_evidence_retention_error")
      cleanup_message <- hs_arc1_profile_retention_condition_message(
        cleanup_error
      )
      attr(captured_condition, "arc1_profile_evidence_retention_error") <-
        if (is.null(prior)) {
          cleanup_message
        } else {
          paste(prior, cleanup_message, sep = "; cleanup: ")
        }
    } else {
      stop(cleanup_error)
    }
  }
  if (!is.null(captured_condition)) {
    stop(captured_condition)
  }
  value
}

hs_arc1_profile_point_status <- function(
  point_fit_status,
  point_fit_not_optimal
) {
  list(
    point_fit_status = as.character(point_fit_status),
    point_fit_not_optimal = isTRUE(point_fit_not_optimal),
    converged = identical(as.character(point_fit_status), "ok") &&
      !isTRUE(point_fit_not_optimal)
  )
}

#' Extract Arc 1 uncertainty intervals
#'
#' Extract the interval table from a bounded experimental Gaussian uncertainty
#' result. Interval formation is a computational result; it does not establish
#' coverage or calibration. Legacy interval fields retain their existing
#' meanings.
#'
#' @param object An `hsquared_fit` or `hsquared_fa_rank_selection` object with
#'   an explicit Arc 1 uncertainty result.
#' @details Select a method through `hs_control()` with the expert
#'   `uncertainty_method` control. `arc1_profile_v1` and the opt-in
#'   `arc1_profile_v2`, explicit `arc1_profile_v3`, and experimental
#'   `arc1_profile_v4` are limited to a univariate
#'   Gaussian pedigree repeatability model with a permanent effect and exactly
#'   two records per observed animal. The R route requires
#'   `scale_method = "dense"`, accepts no `initial`, `iterations`, or
#'   `max_dense_cells` override,
#'   and is requested in `confint()` with the matching method name at
#'   the candidate nominal 95 percent likelihood-ratio cutoff; coverage remains
#'   unvalidated. Existing version 1 and version 2 requests retain their
#'   meanings. Version 3 must be selected explicitly and adds only a narrowly
#'   eligible fixed-residual, two-genetic-zero corner certificate. It reports additive variance,
#'   permanent-environment variance, residual variance, heritability, and
#'   repeatability. The R example uses an intercept; the Julia interface also
#'   accepts other finite, full-rank fixed-effect matrices.
#'   `arc1_bootstrap_v1` requires automatic four-trait FA selection with
#'   `optimizer_policy = "arc1_v1"`, a fixed `bootstrap_B`, and exactly that
#'   many distinct UInt64 seeds in `bootstrap_seeds`; supplying bootstrap
#'   controls without this method is refused. Scalar `bootstrap_seed` is
#'   recognized only to return a refusal because seed-stream derivation is
#'   unavailable. Supply the required seed vector as decimal
#'   strings to preserve UInt64 values exactly; numeric seed inputs are
#'   restricted to integers no larger than `2^53 - 1`. The
#'   bootstrap method is requested in `confint()` with
#'   `method = "arc1_bootstrap_v1"`; it requires `level = 0.95` and uses fixed
#'   percentile bounds.
#'
#'   `arc1_uncertainty()` returns an interval table. The separate metadata is
#'   available as `fit$arc1_uncertainty` for an `hsquared_fa_rank_selection`
#'   object and `fit$result$arc1_uncertainty` for an `hsquared_fit` object.
#'   Refused estimands remain as rows with missing bounds; disconnected
#'   profile segments are represented on separate rows. These methods use
#'   fixed nominal 95 percent rules, but their coverage remains unvalidated.
#'   If an explicitly requested `arc1_profile_v3` or `arc1_profile_v4` call raises
#'   `hsquared_julia_error`, inspect the `arc1_profile_method_requested`,
#'   `arc1_profile_method_actual`, `arc1_profile_source_identity`,
#'   `arc1_profile_evidence`, `arc1_profile_evidence_retention_error`, and
#'   `arc1_profile_evidence_partial` attributes with `attr(error, "...")`.
#'   Partial diagnostics after interruption do not form a fitted result or
#'   interval.
#' @param parm Included for compatibility with [stats::confint()].
#' @param ... Extra arguments are currently accepted but ignored by the
#'   bootstrap `confint()` method.
#' @param level All explicit Arc 1 methods require `0.95`. The profile methods
#'   use a fixed nominal 95 percent likelihood-ratio cutoff; the bootstrap
#'   method uses fixed nominal 95 percent percentile bounds.
#' @param method For `hsquared_fit`, the optional explicit method is
#'   `"arc1_profile_v1"`, `"arc1_profile_v2"`, `"arc1_profile_v3"`, or
#'   `"arc1_profile_v4"`; it must match the method
#'   selected when fitting. For
#'   `hsquared_fa_rank_selection`, `"arc1_bootstrap_v1"` is required; `NULL` or
#'   another value is refused.
#' @return A data frame with interval rows and estimand, trait, segment,
#'   estimate, lower, upper, formed, and status columns. Refused estimands have
#'   missing bounds. The nested `arc1_uncertainty` component retains method,
#'   point-fit, and provenance details; bootstrap results also retain seed and
#'   attempt records.
#' @export
arc1_uncertainty <- function(object) {
  if (!inherits(object, c("hsquared_fit", "hsquared_fa_rank_selection"))) {
    stop(
      "`object` must be an `hsquared_fit` or `hsquared_fa_rank_selection`.",
      call. = FALSE
    )
  }
  hs_arc1_confint_table(object)
}

hs_arc1_run_bootstrap_bridge <- function(request, traits) {
  JuliaCall::julia_assign("hsq_arc1_seed_strings", request$seeds)
  JuliaCall::julia_command(paste(
    hs_julia_arc1_plain_command(),
    "hsq_arc1_boot = HSquared.arc1_bootstrap(hsq_selection, hsq_Y, hsq_X, hsq_Z, hsq_ped;",
    "selector=:arc1_v1, B=length(hsq_arc1_seed_strings),",
    "seeds=UInt64[parse(UInt64,s) for s in hsq_arc1_seed_strings],",
    "ids=hsq_ped.ids, traits=hsq_traits);",
    "hsq_arc1_boot_ci = hsq_arc1_boot.intervals;",
    "hsq_arc1_boot_attempts = hsq_arc1_plain(hsq_arc1_boot.attempts);"
  ))
  raw <- JuliaCall::julia_eval(paste(
    "let b=hsq_arc1_boot, ci=hsq_arc1_boot_ci; Dict(",
    "\"schema\"=>b.schema, \"method\"=>b.method, \"method_version\"=>b.method_version,",
    "\"policy\"=>b.policy, \"policy_version\"=>b.policy_version,",
    "\"source_identity\"=>b.source_identity, \"reference_source_identity\"=>b.reference_source_identity,",
    "\"seed_derivation_version\"=>b.seed_derivation_version, \"quantile_convention\"=>b.quantile_convention,",
    "\"estimand\"=>b.estimand, \"traits\"=>string.(b.traits),",
    "\"point_estimates\"=>b.point_estimates, \"requested_seeds\"=>string.(b.requested_seeds),",
    "\"requested_bootstrap_count\"=>b.requested_bootstrap_count, \"usable_bootstrap_count\"=>b.usable_bootstrap_count,",
    "\"required_usable_count\"=>b.required_usable_count, \"formed\"=>b.formed,",
    "\"outer_selection_failure\"=>(hasproperty(b, :outer_selection_failure) ? b.outer_selection_failure : nothing),",
    "\"status\"=>string(b.status), \"prefix_size\"=>b.prefix_size, \"retained_full_stream_count\"=>b.retained_full_stream_count,",
    "\"rank_frequencies\"=>b.rank_frequencies,",
    "\"failure_causes\"=>b.failure_causes, \"counts\"=>b.counts,",
    "\"interruption_ledger\"=>b.interruption_ledger, \"calibration_status\"=>string(b.calibration_status),",
    "\"formation_claim\"=>string(b.formation_claim),",
    "\"rng_identity\"=>b.rng_identity, \"julia_version\"=>b.julia_version,",
    "\"estimand_rows\"=>string.([r.estimand for r in ci]), \"trait_rows\"=>string.([r.trait for r in ci]),",
    "\"segment\"=>Int[r.segment for r in ci], \"estimate\"=>Float64[r.estimate for r in ci],",
    "\"lower\"=>Float64[ismissing(r.lower) ? NaN : r.lower for r in ci],",
    "\"upper\"=>Float64[ismissing(r.upper) ? NaN : r.upper for r in ci],",
    "\"formed_rows\"=>Bool[r.formed for r in ci], \"status_rows\"=>string.([r.status for r in ci]),",
    "\"attempts\"=>hsq_arc1_boot_attempts) |> hsq_arc1_plain end"
  ))
  intervals <- data.frame(
    estimand = as.character(raw$estimand_rows),
    trait = as.character(raw$trait_rows),
    segment = as.integer(raw$segment),
    estimate = as.numeric(raw$estimate),
    lower = as.numeric(raw$lower),
    upper = as.numeric(raw$upper),
    formed = as.logical(raw$formed_rows),
    status = as.character(raw$status_rows),
    stringsAsFactors = FALSE
  )
  intervals[!is.finite(intervals$lower), "lower"] <- NA_real_
  intervals[!is.finite(intervals$upper), "upper"] <- NA_real_
  list(
    schema = raw$schema,
    method = raw$method,
    method_version = as.integer(raw$method_version),
    policy = raw$policy,
    policy_version = as.integer(raw$policy_version),
    source_identity = raw$source_identity,
    reference_source_identity = raw$reference_source_identity,
    seed_derivation_version = raw$seed_derivation_version,
    quantile_convention = raw$quantile_convention,
    estimand_definition = raw$estimand,
    traits = as.character(raw$traits),
    point_estimates = stats::setNames(
      as.numeric(raw$point_estimates),
      as.character(raw$traits)
    ),
    requested_seeds = as.character(raw$requested_seeds),
    requested_bootstrap_count = as.integer(raw$requested_bootstrap_count),
    usable_bootstrap_count = as.integer(raw$usable_bootstrap_count),
    required_usable_count = as.integer(raw$required_usable_count),
    formed = isTRUE(raw$formed),
    outer_selection_failure = if (
      identical(raw$outer_selection_failure, "__HSQ_NONE__")
    ) {
      NULL
    } else {
      as.character(raw$outer_selection_failure)
    },
    status = raw$status,
    prefix_size = as.integer(raw$prefix_size),
    retained_full_stream_count = as.integer(raw$retained_full_stream_count),
    intervals = intervals,
    attempts = hs_arc1_plain_to_list(raw$attempts),
    interruption_ledger = hs_arc1_plain_to_list(raw$interruption_ledger),
    rank_frequencies = hs_arc1_plain_to_list(raw$rank_frequencies),
    failure_causes = hs_arc1_plain_to_list(raw$failure_causes),
    counts = hs_arc1_plain_to_list(raw$counts),
    calibration_status = raw$calibration_status,
    rng_identity = raw$rng_identity,
    julia_version = raw$julia_version,
    formation_claim = raw$formation_claim
  )
}


#' @rdname arc1_uncertainty
#' @export
confint.hsquared_fa_rank_selection <- function(
  object,
  parm,
  level = 0.95,
  method = NULL,
  ...
) {
  if (is.null(method) || !identical(method, "arc1_bootstrap_v1")) {
    stop(
      "Select `method = \"arc1_bootstrap_v1\"` explicitly for this uncertainty result.",
      call. = FALSE
    )
  }
  if (!identical(level, 0.95)) {
    stop(
      "`arc1_bootstrap_v1` uses fixed percentile bounds at 95%.",
      call. = FALSE
    )
  }
  hs_arc1_confint_table(object)
}
