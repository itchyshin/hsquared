# One replicate of the genomic-h2 recovery study: simulate, fit genomic GREML and
# the pedigree animal model, record estimates/SEs and scan power. Small output.
#   Rscript dev-test/genomic-sim/replicate.R <seed>
Sys.setenv(
  HSQUARED_JULIA_PROJECT = normalizePath("../../Julia/HSquared.jl"),
  PATH = paste(path.expand("~/.juliaup/bin"), Sys.getenv("PATH"), sep = ":")
)
suppressPackageStartupMessages(devtools::load_all(quiet = TRUE))
source("dev-test/genomic-sim/simulate.R")
seed <- as.integer(commandArgs(trailingOnly = TRUE)[1])
s <- simulate_population(seed)
dat <- s$pheno
M_rec <- s$markers[dat$id, ]

ok <- function(expr) tryCatch(expr, error = function(e) NA_real_)
t_g <- system.time(fit_g <- hsquared(
  y ~ sex + genomic(1 | id, markers = M_rec), data = dat, family = gaussian(),
  REML = TRUE,
  control = hs_control(engine = "julia", engine_control = list(target = "genomic"))
))[[3]]
t_a <- system.time(fit_a <- hsquared(
  y ~ sex + animal(1 | id, pedigree = s$pedigree), data = dat,
  family = gaussian(), REML = TRUE
))[[3]]
t_s <- system.time(scan <- as.data.frame(unclass(gwas(fit_a, s$markers))))[[3]]

vg <- variance_components(fit_g); va <- variance_components(fit_a)
gebv <- breeding_values(fit_g); ebv <- breeding_values(fit_a)
ebv <- ebv[match(dat$id, ebv$id), ]
gebv <- gebv[match(dat$id, gebv$id), ]
scan$causal <- s$map$causal[match(scan$marker, s$map$marker)]
sig <- scan$bonferroni_p < 0.05

out <- data.frame(
  seed = seed,
  true_h2 = s$truth$h2,
  # realised h2 in this sample: Var(true g) / (Var(true g) + Var(y - g | sex))
  realised_h2 = var(dat$true_g) / var(dat$y - 0.5 * (dat$sex == "M")),
  g_h2 = heritability(fit_g)$estimate,
  g_h2_se = ok(heritability_standard_error(fit_g)$se),
  g_var = vg$estimate[vg$component == "genomic"],
  g_res = vg$estimate[vg$component == "residual"],
  g_converged = isTRUE(fit_g$result$converged),
  a_h2 = heritability(fit_a)$estimate,
  a_h2_se = ok(as.numeric(heritability_standard_error(fit_a)$se)),
  a_var = va$estimate[va$component == "animal"],
  a_res = va$estimate[va$component == "residual"],
  acc_gebv = cor(gebv$value, dat$true_g),
  acc_ebv = cor(ebv$value, dat$true_g),
  n_sig = sum(sig), n_sig_causal = sum(sig & scan$causal),
  lambda_gc = median(scan$chisq) / qchisq(0.5, 1),
  sec_genomic = t_g, sec_animal = t_a, sec_gwas = t_s
)
dir.create("dev-test/genomic-sim/reps", showWarnings = FALSE)
saveRDS(out, sprintf("dev-test/genomic-sim/reps/rep-%03d.rds", seed))
print(out)
