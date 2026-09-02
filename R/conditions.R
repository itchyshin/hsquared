# Structured conditions for hsquared errors.

# Raise a structured "unsupported syntax" error.
#
# Genuine grammar/target rejections -- planned, opt-in-required, or
# not-implemented formula terms, unsupported response grammar, and unsupported
# `engine_control$target` branches -- are raised through this helper so they
# carry a stable, catchable condition class:
#
#   c("hsquared_unsupported_syntax", "hsquared_error", "error", "condition")
#
# Data validation, wrong-object, dimension, numeric-invariant, and internal
# payload guards stay plain `stop()`; they are a different family and must not
# carry this class.
#
# The `...` message pieces are concatenated with `paste0()`, matching the
# existing `stop("a", var, "b")` style. `call. = FALSE` is accepted and
# discarded so call sites can keep their existing ergonomics: the raised
# condition never carries a call (mirroring the previous `call. = FALSE`).
hs_abort_unsupported_syntax <- function(..., call. = FALSE) {
  cond <- errorCondition(
    paste0(...),
    class = c("hsquared_unsupported_syntax", "hsquared_error")
  )
  stop(cond)
}

# Session-scoped flags for warn-once messages. Reset in tests.
hs_session_flags <- new.env(parent = emptyenv())

hs_reset_session_flags <- function() {
  rm(list = ls(envir = hs_session_flags), envir = hs_session_flags)
  invisible(NULL)
}

# Default-path cbind() routes to the multivariate fitter (MV-4) but the
# capability stays partial/experimental. Warn once per session when that
# path actually fits, so the easy syntax does not look reportable.
hs_warn_cbind_experimental_once <- function() {
  if (isTRUE(hs_session_flags$cbind_experimental)) {
    return(invisible(FALSE))
  }
  hs_session_flags$cbind_experimental <- TRUE
  warning(
    "This cbind() model fitted, but it is experimental (partial).\n",
    "Do not report these numbers from hsquared alone.",
    call. = FALSE
  )
  invisible(TRUE)
}

# Deparse a user formula or data argument into a pasteable snippet.
hs_deparse_user_expr <- function(x) {
  paste(deparse(x, width.cutoff = 500L), collapse = "\n    ")
}

# Pasteable next call for an opt-in engine target, using the formula the
# user already wrote.
hs_format_next_call <- function(formula, data_name, target) {
  paste0(
    "  hsquared(\n",
    "    ",
    hs_deparse_user_expr(formula),
    ",\n",
    "    data = ",
    data_name,
    ",\n",
    "    control = hs_control(\n",
    "      engine = \"julia\",\n",
    "      engine_control = list(target = \"",
    target,
    "\")\n",
    "    )\n",
    "  )"
  )
}

hs_opt_in_term_label <- function(type) {
  switch(
    type,
    common_env = "common_env()",
    permanent = "permanent()",
    maternal_genetic = "maternal_genetic()",
    iid_effects = "(1 | group)",
    random_regression = "rr(...)",
    paste0(type, "()")
  )
}

# Honest one-paragraph status for the pasteable next call. Status words
# match capability-status: no covered flip, no new estimand.
hs_opt_in_route_note <- function(type) {
  switch(
    type,
    common_env = paste0(
      "That route is covered for point estimates only (validation-scale, ",
      "common-environment leg). Intervals are experimental."
    ),
    permanent = paste0(
      "That route is experimental. Do not report these numbers from ",
      "hsquared alone."
    ),
    maternal_genetic = paste0(
      "`target = \"two_effect\"` is experimental (independent maternal). ",
      "`target = \"direct_maternal\"` is covered for point estimates only ",
      "(validation-scale Willham triple: h2_direct, m2, r_am -- not a ",
      "scalar h2). Intervals are experimental."
    ),
    random_regression = paste0(
      "That route is covered for point estimates only (validation-scale, ",
      "k = 2). Higher order is experimental."
    ),
    paste0(
      "That route is experimental and opt-in. See formula_status()."
    )
  )
}

# Default-path abort that prints the call the user should paste.
# Used for common_env / permanent / maternal_genetic / rr(...).
hs_abort_opt_in_next_call <- function(
  type,
  formula,
  data_name,
  target = NULL
) {
  if (identical(type, "random_regression")) {
    target <- "random_regression"
  } else if (is.null(target)) {
    target <- hs_second_effect_target(type)
  }
  label <- hs_opt_in_term_label(type)
  extra <- ""
  if (identical(type, "maternal_genetic")) {
    extra <- paste0(
      "\n\nCovered alternative (Willham triple, not a scalar h2):\n\n",
      hs_format_next_call(formula, data_name, "direct_maternal")
    )
  }
  hs_abort_unsupported_syntax(
    "`",
    label,
    "` is not on the default path.\n\n",
    "Closest working call:\n\n",
    hs_format_next_call(formula, data_name, target),
    extra,
    "\n\n",
    hs_opt_in_route_note(type),
    "\nSee: current-limits article, formula_status()."
  )
}
