# hsquared with se_method = "ai" (new default) vs "observed": SEs and timing.
#   Rscript dev-test/se-investigation/08-se-method-timing.R [reps] [julia_project]
# reps = 0 runs one fit per setting and prints the SEs only (correctness check).
a <- commandArgs(trailingOnly = TRUE)
reps <- if (length(a) >= 1) as.integer(a[1]) else 7L
proj <- if (length(a) >= 2) a[2] else path.expand("~/hsq-wt/hjl-se-info")
Sys.setenv(
  HSQUARED_JULIA_PROJECT = normalizePath(proj),
  PATH = paste(path.expand("~/.juliaup/bin"), Sys.getenv("PATH"), sep = ":")
)
suppressPackageStartupMessages(devtools::load_all(quiet = TRUE))
inp <- readRDS("dev-test/se-investigation/inputs.rds")

fit <- function(d, ped, se_method) {
  rownames(ped) <- NULL
  b <- hs_data(phenotypes = d, pedigree = ped, id = "animal")
  suppressWarnings(hsquared(
    y ~ year_f + round_f + exp_manip + female.age +
      animal(1 | animal) + permanent(1 | animal),
    data = b, family = gaussian(), REML = TRUE,
    control = hs_control(engine = "julia", se_method = se_method,
                         engine_control = list(target = "repeatability",
                                               scale_method = "auto"))
  ))
}

t_cold <- system.time(f0 <- fit(inp[[1]]$data, inp[[1]]$ped, "ai"))[["elapsed"]]
rows <- list(); ses <- list()
for (tr in names(inp)) for (m in c("ai", "observed")) {
  f <- fit(inp[[tr]]$data, inp[[tr]]$ped, m) # warm-up, and the SEs we report
  ses[[paste(tr, m)]] <- c(
    variance_component_standard_errors(f)$se,
    h2 = heritability_standard_error(f)$se,
    used = NA)
  stopifnot(identical(f$result$se_method, m))
  t <- if (reps > 0) {
    vapply(seq_len(reps), function(i)
      system.time(fit(inp[[tr]]$data, inp[[tr]]$ped, m))[["elapsed"]], 0)
  } else NA_real_
  rows[[paste(tr, m)]] <- data.frame(engine = paste0("hsquared (se_method = \"", m, "\")"),
                                     trait = tr, median_s = median(t), min_s = min(t),
                                     max_s = max(t), reps = reps)
}
cat("cold first call (Julia start + compile):", round(t_cold, 1), "s\n\n")
se_tab <- do.call(rbind, lapply(ses, function(x) x[1:4]))
colnames(se_tab) <- c("animal", "permanent", "residual", "h2")
print(signif(se_tab, 6))
res <- do.call(rbind, rows)
res$julia_threads <- JuliaCall::julia_eval("Threads.nthreads()")
res$blas_threads <- JuliaCall::julia_eval("using LinearAlgebra; BLAS.get_num_threads()")
print(res, digits = 4)
if (reps > 0) {
  saveRDS(list(timing = res, se = se_tab, cold = t_cold),
          "dev-test/se-investigation/timing-se-method.rds")
}
