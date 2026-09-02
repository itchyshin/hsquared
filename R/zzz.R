.onAttach <- function(libname, pkgname) {
  packageStartupMessage(
    "hsquared is experimental (first CRAN target 0.5.0, not 1.0). ",
    "Default hsquared() fitting requires Julia + HSquared.jl; ",
    "use hs_control(engine = \"validate\") to preview without fitting. ",
    "What you may report is listed on Can I fit and report this? -- not ",
    "in validation_status(). Intervals are experimental and not ",
    "coverage-calibrated. See ",
    "https://itchyshin.github.io/hsquared/articles/current-limits.html"
  )
}
