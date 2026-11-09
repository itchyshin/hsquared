# Timing, ASReml leg. Same inputs as the SE investigation (pruned pedigree).
#   Rscript dev-test/se-investigation/06-timing-asreml.R [reps]
# Times (a) building Ainv from the pedigree and (b) the fit itself, which in
# ASReml includes the AI-based SEs. One untimed warm-up fit per trait first.
suppressPackageStartupMessages(library(asreml))
reps <- as.integer(commandArgs(trailingOnly = TRUE)[1] %||% 5)
inp <- readRDS("dev-test/se-investigation/inputs.rds")

make_ainv <- function(ped) {
  rownames(ped) <- NULL
  m <- nadiv::makeAinv(ped)
  l <- m$listAinv
  structure(as.matrix(l), class = c("matrix", "array", "ginv"),
            rowNames = attr(l, "rowNames"), inbreeding = m$f,
            logdet = m$logDet, geneticGroups = c(0, 0))
}
fit <- function(d, Ainv) {
  d$animal <- factor(d$animal, levels = attr(Ainv, "rowNames"))
  asreml(y ~ year_f + round_f + exp_manip + female.age,
         random = ~ vm(animal, Ainv) + ide(animal), data = d,
         na.action = na.method(x = "include", y = "omit"))
}

ainvs <- lapply(inp, function(t) make_ainv(t$ped))
asreml.options(workspace = "2gb", trace = FALSE)
rows <- list()
for (tr in names(inp)) {
  t_ainv <- replicate(reps, system.time(make_ainv(inp[[tr]]$ped))[["elapsed"]])
  invisible(fit(inp[[tr]]$data, ainvs[[tr]])) # warm-up
  t_fit <- numeric(reps); iters <- NA
  for (i in seq_len(reps)) {
    t_fit[i] <- system.time(f <- fit(inp[[tr]]$data, ainvs[[tr]]))[["elapsed"]]
  }
  rows[[tr]] <- data.frame(engine = "ASReml-R", trait = tr, step = c("Ainv", "fit (incl. SEs)"),
                           median_s = c(median(t_ainv), median(t_fit)),
                           min_s = c(min(t_ainv), min(t_fit)),
                           max_s = c(max(t_ainv), max(t_fit)), reps = reps,
                           loglik = c(NA, f$loglik))
}
res <- do.call(rbind, rows)
res$version <- as.character(packageVersion("asreml"))
saveRDS(res, "dev-test/se-investigation/timing-asreml.rds")
print(res, digits = 4)
