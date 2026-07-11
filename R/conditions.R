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
