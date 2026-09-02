.onAttach <- function(libname, pkgname) {
  packageStartupMessage(
    "hsquared is experimental (first CRAN target 0.5.0, not 1.0). ",
    "Default fitting needs Julia + HSquared.jl; preview with ",
    "hs_control(engine = \"validate\").\n",
    "What you may report is listed on Can I fit and report this? ",
    "-- not in validation_status(). Intervals are not coverage-calibrated.\n",
    "See https://itchyshin.github.io/hsquared/articles/current-limits.html"
  )
}
