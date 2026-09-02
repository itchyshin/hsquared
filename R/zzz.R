.onAttach <- function(libname, pkgname) {
  packageStartupMessage(
    "hsquared is experimental (first CRAN target 0.5.0, not 1.0). ",
    "Default hsquared() fitting requires Julia + HSquared.jl; ",
    "use hs_control(engine = \"validate\") to preview without fitting. ",
    "Report point estimates only for covered routes; intervals are ",
    "experimental and not coverage-calibrated. ",
    "validation_status() shows the covered rows but is not a complete list ",
    "of the covered routes: the opt-in random_regression (k = 2) and ",
    "direct_maternal targets are covered and have no row there yet. ",
    "See ?validation_status for the table, and ",
    "https://itchyshin.github.io/hsquared/articles/current-limits.html ",
    "for every covered route and what it may be reported as."
  )
}
