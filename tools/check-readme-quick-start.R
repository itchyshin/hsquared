#!/usr/bin/env Rscript
# Execute the documented no-Julia first workflow against an installed package.
# Usage: Rscript tools/check-readme-quick-start.R SOURCE_ROOT [R_LIBRARY]
args <- commandArgs(trailingOnly = TRUE)
stopifnot(length(args) %in% c(1L, 2L))
if (length(args) == 2L) .libPaths(c(args[[2L]], .libPaths()))
lines <- readLines(file.path(args[[1L]], "README.md"), warn = FALSE)
heading <- grep("^## Quick start", lines)
stopifnot(length(heading) == 1L)
start <- which(seq_along(lines) > heading & lines == "```r")[[1L]]
end <- which(seq_along(lines) > start & lines == "```")[[1L]]
code <- paste(lines[seq.int(start + 1L, end - 1L)], collapse = "\n")
Sys.setenv(HSQUARED_JULIA_PROJECT = tempfile("absent-julia-project-"))
result <- eval(parse(text = code), envir = new.env(parent = globalenv()))
stopifnot(is.list(result), identical(result$bridge$engine, "HSquared.jl"),
          identical(result$bridge$target, "fit_animal_model(y, X, Z, Ainv; method = :REML)"))
cat("README no-Julia quick start: PASS\n")
