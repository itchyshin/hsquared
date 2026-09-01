.onAttach <- function(libname, pkgname) {
  packageStartupMessage(
    "hsquared is experimental (first CRAN target 0.5.0, not 1.0). ",
    "Default hsquared() fitting requires Julia + HSquared.jl; ",
    "use hs_control(engine = \"validate\") to preview without fitting. ",
    "Report point estimates only for covered rows in validation_status(); ",
    "intervals are experimental and not coverage-calibrated. ",
    "See ?validation_status and vignette(\"model-status\", package = \"hsquared\")."
  )
}
