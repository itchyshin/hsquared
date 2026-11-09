# hsquared leg (Julia engine). Never load asreml in this process (libomp clash).
#   Rscript dev-test/se-investigation/03-hsquared.R
Sys.setenv(
  HSQUARED_JULIA_PROJECT = normalizePath("../../Julia/HSquared.jl"),
  PATH = paste(path.expand("~/.juliaup/bin"), Sys.getenv("PATH"), sep = ":")
)
suppressPackageStartupMessages(devtools::load_all(quiet = TRUE))
inp <- readRDS("dev-test/se-investigation/inputs.rds")

fit_one <- function(d, ped) {
  rownames(ped) <- NULL
  b <- hs_data(phenotypes = d, pedigree = ped, id = "animal")
  tm <- system.time(fit <- suppressWarnings(hsquared(
    y ~ year_f + round_f + exp_manip + female.age +
      animal(1 | animal) + permanent(1 | animal),
    data = b, family = gaussian(), REML = TRUE,
    control = hs_control(engine = "julia", engine_control = list(
      target = "repeatability", scale_method = "auto"))
  )))
  vc <- variance_components(fit)
  se <- variance_component_standard_errors(fit)
  list(
    varcomp = merge(vc, se, by = "component", sort = FALSE),
    h2 = c(estimate = heritability(fit)$estimate,
           se = heritability_standard_error(fit)$se),
    loglik = as.numeric(logLik(fit)),
    converged = fit$result$converged %||% NA,
    seconds = unname(tm["elapsed"])
  )
}
out <- lapply(inp, function(t) fit_one(t$data, t$ped))
saveRDS(out, "dev-test/se-investigation/res-hsquared.rds")
for (n in names(out)) {
  cat("\n==", n, "== loglik", out[[n]]$loglik, "\n")
  print(out[[n]]$varcomp, digits = 8)
  print(out[[n]]$h2, digits = 6)
}
