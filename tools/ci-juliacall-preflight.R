#!/usr/bin/env Rscript
# CI-only: build JuliaCall's R<->Julia bridge once before covr::package_coverage().
# covr's instrumented test run repeatedly calls julia_setup(); prebuilding avoids
# install_dependency.jl races and reduces segfault risk on hosted runners.

project <- Sys.getenv("HSQUARED_JULIA_PROJECT", unset = "")
if (!nzchar(project)) {
  stop("HSQUARED_JULIA_PROJECT must be set", call. = FALSE)
}
project <- normalizePath(project, winslash = "/", mustWork = TRUE)

suppressPackageStartupMessages(library(JuliaCall))

JuliaCall::julia_setup(installJulia = FALSE, verbose = TRUE)
JuliaCall::julia_assign("hsq_project", project)
JuliaCall::julia_command(
  "using Pkg; Pkg.activate(hsq_project); using HSquared; using SparseArrays"
)

invisible(TRUE)
