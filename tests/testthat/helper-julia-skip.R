# CRAN-safe skip for any test that may reach JuliaCall::julia_setup().
# Pattern stolen from drmTMB `drm_skip_live_julia()` after Ligges hung ~10k s
# inside julia_setup() on a CRAN-lane expect_error(engine = "julia") path.
#
# Opt in with HSQUARED_JULIA_TESTS=true. Repository CI / maintainer live suites
# use NOT_CRAN=true (this skip is then a no-op aside from skip_on_cran).
#
# Call this at the top of every live Julia test (or shared skip helper) before
# hs_julia_setup() / engine = "julia" fits. Intentional pre-setup gates
# (hsquared_unsupported_syntax) may still run on CRAN without this helper.

hs_skip_live_julia <- function() {
  if (identical(Sys.getenv("HSQUARED_JULIA_TESTS"), "true")) {
    return(invisible(TRUE))
  }
  if (
    !isTRUE(as.logical(Sys.getenv("NOT_CRAN", "false"))) &&
      !interactive()
  ) {
    testthat::skip(
      "Live Julia skipped on CRAN lane (set NOT_CRAN=true or HSQUARED_JULIA_TESTS=true)."
    )
  }
  testthat::skip_on_cran()
  invisible(TRUE)
}
