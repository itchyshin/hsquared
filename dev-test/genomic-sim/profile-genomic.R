# Where does a genomic GREML fit spend its time on the simulated n = 2,000 panel?
#   Rscript dev-test/genomic-sim/profile-genomic.R
Sys.setenv(
  HSQUARED_JULIA_PROJECT = normalizePath("../../Julia/HSquared.jl"),
  PATH = paste(path.expand("~/.juliaup/bin"), Sys.getenv("PATH"), sep = ":")
)
suppressPackageStartupMessages(devtools::load_all(quiet = TRUE))
library(JuliaCall)
s <- readRDS("dev-test/genomic-sim/sim-seed1.rds")
d <- s$pheno; M <- s$markers[d$id, ]
tm <- function(l, e) { t <- system.time(r <- e)[[3]]; cat(sprintf("%-55s %7.2f s\n", l, t)); invisible(r) }
f <- function() hsquared(y ~ sex + genomic(1 | id, markers = M), data = d,
  family = gaussian(), REML = TRUE,
  control = hs_control(engine = "julia", engine_control = list(target = "genomic")))
tm("hsquared() call 1 (incl. Julia start/JIT)", fit <- f())
tm("hsquared() call 2", fit <- f())
cat("iterations:", fit$result$diagnostics$iterations, " n =", nrow(d), " markers =", ncol(M), "\n")

X <- model.matrix(~ sex, d)
julia_command("using LinearAlgebra, SparseArrays")
julia_assign("g_M", M); julia_assign("g_y", d$y); julia_assign("g_X", X); julia_assign("g_ids", d$id)
tm("Julia: G/K/Q construction", julia_command("g_con = HSquared._genomic_activation_construction(g_M, g_ids);"))
julia_command("g_Z = sparse(1.0I, length(g_y), length(g_y)); g_spec = HSquared.animal_model_spec(g_y, g_X, g_Z, g_con.Q; ids = g_ids, method = :REML);")
tm("Julia: fit_ai_reml (plain)", julia_command("g_fit = HSquared.fit_ai_reml(g_spec);"))
tm("Julia: fit_ai_reml (plain, again)", julia_command("g_fit = HSquared.fit_ai_reml(g_spec);"))
cat("plain fit iterations:", julia_eval("g_fit.iterations"), "\n")
tm("Julia: boundary-certified genomic fit (route used for n <= 2000, Z = I)",
   julia_command(paste0("g_b = HSquared._fit_ai_reml_genomic_boundary(g_spec; ",
                        "provenance = HSquared._genomic_precision_provenance(g_con.Q, g_ids), ",
                        "kernel = nothing);")))
tm("Julia: variance_component_standard_errors", julia_command("HSquared.variance_component_standard_errors(g_fit);"))
tm("Julia: result_payload (PEV/reliability)", julia_command("HSquared.result_payload(g_fit);"))
cat("Threads:", julia_eval("Threads.nthreads()"), " BLAS:", julia_eval("BLAS.get_num_threads()"), "\n")
