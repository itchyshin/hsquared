#!/usr/bin/env Rscript

# Developer entry point. The canonical base-R implementation lives under
# inst/tools so R CMD build/check installs the exact code exercised by tests.
file_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
script <- if (length(file_arg)) sub("^--file=", "", file_arg[[1L]]) else ""
root <- if (nzchar(script)) {
  dirname(dirname(normalizePath(script, mustWork = TRUE)))
} else {
  getwd()
}
candidate <- file.path(root, "inst", "tools", "v07_genomic_recovery_recompute.R")
if (!file.exists(candidate)) {
  candidate <- system.file(
    "tools", "v07_genomic_recovery_recompute.R", package = "hsquared"
  )
}
if (!nzchar(candidate) || !file.exists(candidate)) {
  stop("cannot locate the installed v0.7 recovery recomputation tool", call. = FALSE)
}
source(candidate, local = globalenv())
v07_main(commandArgs(trailingOnly = TRUE))

