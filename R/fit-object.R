hs_new_fit <- function(
  call = NULL,
  spec,
  payload,
  result,
  engine = "HSquared.jl",
  version = utils::packageVersion("hsquared")
) {
  if (!is.list(spec)) {
    stop("`spec` must be a list.", call. = FALSE)
  }
  if (!is.list(payload)) {
    stop("`payload` must be a list.", call. = FALSE)
  }
  if (!is.list(result)) {
    stop("`result` must be a list.", call. = FALSE)
  }

  structure(
    list(
      call = call,
      spec = spec,
      payload = payload,
      result = result,
      engine = engine,
      version = as.character(version)
    ),
    class = "hsquared_fit"
  )
}

hs_fit_result <- function(object, name, label) {
  if (!inherits(object, "hsquared_fit")) {
    stop("`object` must be an `hsquared_fit` object.", call. = FALSE)
  }

  value <- object$result[[name]]
  if (is.null(value)) {
    stop(
      "This `hsquared_fit` object does not contain ",
      label,
      ". The extractor is part of the planned v0.1 contract, but the current ",
      "result payload did not provide this field.",
      call. = FALSE
    )
  }

  value
}

#' @export
print.hsquared_fit <- function(x, ...) {
  method <- x$spec$method %||% "unknown"
  family <- x$spec$family$family %||% "unknown"
  converged <- x$result$converged

  cat("<hsquared_fit>\n")
  cat("  engine: ", x$engine %||% "unknown", "\n", sep = "")
  cat("  family: ", family, "\n", sep = "")
  cat("  method: ", method, "\n", sep = "")
  if (!is.null(converged)) {
    cat("  converged: ", isTRUE(converged), "\n", sep = "")
  }
  invisible(x)
}

#' @export
summary.hsquared_fit <- function(object, ...) {
  structure(
    list(
      call = object$call,
      engine = object$engine,
      method = object$spec$method,
      family = object$spec$family,
      variance_components = object$result$variance_components,
      heritability = object$result$heritability,
      fixed_effects = object$result$fixed_effects,
      diagnostics = object$result$diagnostics,
      converged = object$result$converged,
      at_boundary = hs_fit_boundary_flag(object),
      at_boundary_class = hs_fit_boundary_class(object),
      # Experimental uncertainty surfaces (engine rows V1-HERIT-CI /
      # V3-REPEAT-REML, partial); present only when the engine returned them.
      heritability_interval = object$result$heritability_interval,
      heritability_se = object$result$heritability_se,
      variance_component_se = object$result$variance_component_se,
      repeatability_interval = object$result$repeatability_interval
    ),
    class = "summary_hsquared_fit"
  )
}

#' @export
print.summary_hsquared_fit <- function(x, ...) {
  cat("<summary_hsquared_fit>\n")
  cat("  engine: ", x$engine %||% "unknown", "\n", sep = "")
  cat("  method: ", x$method %||% "unknown", "\n", sep = "")
  if (!is.null(x$converged)) {
    cat("  converged: ", isTRUE(x$converged), "\n", sep = "")
  }
  if (isTRUE(x$at_boundary)) {
    if (identical(x$at_boundary_class, "negative")) {
      cat(
        "  at boundary: TRUE (a variance component is NEGATIVE; the fit is ",
        "inadmissible, not a clean boundary, and heritability cannot be read ",
        "as an ordinary interior estimate)\n",
        sep = ""
      )
    } else {
      cat(
        "  at boundary: TRUE (a variance component is at/near zero; ",
        "heritability is a boundary estimate, not an ordinary interior one)\n",
        sep = ""
      )
    }
  }
  hs_print_uncertainty(x)
  invisible(x)
}

# Print the experimental uncertainty surfaces (CIs / SEs) when present. These
# are asymptotic, REML-only, partial-row surfaces (V1-HERIT-CI / V3-REPEAT-REML)
# and are labelled experimental so they are never read as validated.
hs_print_uncertainty <- function(x) {
  fmt <- function(v) format(signif(as.numeric(v), 4))
  if (!is.null(x$heritability_se) || !is.null(x$heritability_interval)) {
    cat("  heritability uncertainty (experimental; asymptotic REML):\n")
    if (!is.null(x$heritability_se)) {
      cat("    SE: ", fmt(x$heritability_se), "\n", sep = "")
    }
    if (!is.null(x$heritability_interval)) {
      ci <- x$heritability_interval
      cat(
        sprintf(
          "    %g%% CI: [%s, %s] (%s)\n",
          100 * as.numeric(ci$level),
          fmt(ci$lower),
          fmt(ci$upper),
          ci$method
        )
      )
    }
  }
  if (!is.null(x$variance_component_se)) {
    cat("  variance-component SEs (experimental; asymptotic REML):\n")
    se <- x$variance_component_se
    for (i in seq_len(nrow(se))) {
      cat("    ", se$component[i], ": ", fmt(se$se[i]), "\n", sep = "")
    }
  }
  if (!is.null(x$repeatability_interval)) {
    ci <- x$repeatability_interval
    cat("  repeatability uncertainty (experimental; asymptotic REML):\n")
    cat(
      sprintf(
        "    %g%% CI: [%s, %s]\n",
        100 * as.numeric(ci$level),
        fmt(ci$lower),
        fmt(ci$upper)
      )
    )
  }
  invisible(x)
}

`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}
