# Timing, hsquared leg (Julia engine). Same inputs as the ASReml leg.
#   Rscript dev-test/se-investigation/07-timing-hsquared.R [reps]
# "cold" = the first hsquared() call in a fresh R session: Julia start-up,
# package load and JIT compilation included. "warm" = later calls in the same
# session. Each call includes hsquared's post-fit SEs (observed information).
Sys.setenv(
  HSQUARED_JULIA_PROJECT = normalizePath("../../Julia/HSquared.jl"),
  PATH = paste(path.expand("~/.juliaup/bin"), Sys.getenv("PATH"), sep = ":")
)
suppressPackageStartupMessages(devtools::load_all(quiet = TRUE))
reps <- as.integer(commandArgs(trailingOnly = TRUE)[1] %||% 5)
inp <- readRDS("dev-test/se-investigation/inputs.rds")

fit <- function(d, ped) {
  rownames(ped) <- NULL
  b <- hs_data(phenotypes = d, pedigree = ped, id = "animal")
  suppressWarnings(hsquared(
    y ~ year_f + round_f + exp_manip + female.age +
      animal(1 | animal) + permanent(1 | animal),
    data = b, family = gaussian(), REML = TRUE,
    control = hs_control(engine = "julia", engine_control = list(
      target = "repeatability", scale_method = "auto"))
  ))
}

t_cold <- system.time(f <- fit(inp[[1]]$data, inp[[1]]$ped))[["elapsed"]]
rows <- list(data.frame(engine = "hsquared", trait = names(inp)[1],
                        step = "fit, cold (Julia start + compile)",
                        median_s = t_cold, min_s = t_cold, max_s = t_cold,
                        reps = 1, loglik = as.numeric(logLik(f))))
for (tr in names(inp)) {
  invisible(fit(inp[[tr]]$data, inp[[tr]]$ped)) # warm-up for this trait
  t <- numeric(reps)
  for (i in seq_len(reps)) {
    t[i] <- system.time(f <- fit(inp[[tr]]$data, inp[[tr]]$ped))[["elapsed"]]
  }
  rows[[tr]] <- data.frame(engine = "hsquared", trait = tr,
                           step = "fit, warm (incl. SEs)", median_s = median(t),
                           min_s = min(t), max_s = max(t), reps = reps,
                           loglik = as.numeric(logLik(f)))
}
res <- do.call(rbind, rows)
res$julia_threads <- JuliaCall::julia_eval("Threads.nthreads()")
res$blas_threads <- JuliaCall::julia_eval("using LinearAlgebra; BLAS.get_num_threads()")
saveRDS(res, "dev-test/se-investigation/timing-hsquared.rds")
print(res, digits = 4)
