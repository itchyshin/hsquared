# Fit one simulated replicate: genomic GREML from markers, the pedigree animal
# model on the same animals, and a relatedness-corrected marker scan.
#   Rscript dev-test/genomic-sim/fit-one.R [seed]
Sys.setenv(
  HSQUARED_JULIA_PROJECT = normalizePath("../../Julia/HSquared.jl"),
  PATH = paste(path.expand("~/.juliaup/bin"), Sys.getenv("PATH"), sep = ":")
)
suppressPackageStartupMessages(devtools::load_all(quiet = TRUE))
seed <- as.integer(commandArgs(trailingOnly = TRUE)[1] %||% 1)
s <- readRDS(sprintf("dev-test/genomic-sim/sim-seed%d.rds", seed))
dat <- s$pheno
M_rec <- s$markers[dat$id, ]

t_g <- system.time(fit_g <- hsquared(
  y ~ sex + genomic(1 | id, markers = M_rec),
  data = dat, family = gaussian(), REML = TRUE,
  control = hs_control(engine = "julia", engine_control = list(target = "genomic"))
))
print(fit_g)
print(variance_components(fit_g))
print(heritability(fit_g))
print(try(heritability_standard_error(fit_g)))
gebv <- breeding_values(fit_g)
str(gebv)

t_a <- system.time(fit_a <- hsquared(
  y ~ sex + animal(1 | id, pedigree = s$pedigree),
  data = dat, family = gaussian(), REML = TRUE
))
print(variance_components(fit_a))
print(heritability(fit_a))
print(try(heritability_standard_error(fit_a)))

t_s <- system.time(scan <- gwas(fit_a, s$markers))
print(head(scan[order(scan$p_value), ], 10))
cat("timings (s): genomic", t_g[3], " animal", t_a[3], " gwas", t_s[3], "\n")
saveRDS(list(fit_g = fit_g, fit_a = fit_a, scan = scan,
             times = c(genomic = t_g[[3]], animal = t_a[[3]], gwas = t_s[[3]])),
        sprintf("dev-test/genomic-sim/fit-seed%d.rds", seed))
