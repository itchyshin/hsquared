# Numbers for the "Simulated genomic case study" article, on merged main.
# Serial run (one R/Julia process), so timings are not contaminated by BLAS
# oversubscription. Writes dev-test/genomic-sim/case-study-seed1.rds.
#   Rscript dev-test/genomic-sim/case-study.R
Sys.setenv(
  HSQUARED_JULIA_PROJECT = normalizePath("../../Julia/HSquared.jl"),
  PATH = paste(path.expand("~/.juliaup/bin"), Sys.getenv("PATH"), sep = ":")
)
suppressPackageStartupMessages(devtools::load_all(quiet = TRUE))
source("dev-test/genomic-sim/simulate.R")

t_sim <- system.time(sim <- simulate_population(seed = 1))[[3]]
stopifnot(identical(sim$pheno, readRDS("dev-test/genomic-sim/sim-seed1.rds")$pheno))
dat <- sim$pheno
M <- sim$markers[dat$id, ]

fit_genomic <- function() hsquared(
  y ~ sex + genomic(1 | id, markers = M), data = dat,
  family = gaussian(), REML = TRUE,
  control = hs_control(engine = "julia", engine_control = list(target = "genomic"))
)
fit_pedigree <- function() hsquared(
  y ~ sex + animal(1 | id, pedigree = sim$pedigree), data = dat,
  family = gaussian(), REML = TRUE
)
tm <- function(e) system.time(e)[[3]]
t_cold <- tm(fit_g <- fit_genomic())
t_g <- tm(fit_g <- fit_genomic())
t_a <- tm(fit_a <- fit_pedigree())
t_a2 <- tm(fit_a <- fit_pedigree())
t_s <- tm(scan <- gwas(fit_a, sim$markers))

print(fit_g); print(fit_a)
vc_g <- variance_components(fit_g); vc_a <- variance_components(fit_a)
h_g <- heritability(fit_g); h_a <- heritability(fit_a)
se_g <- heritability_standard_error(fit_g); se_a <- heritability_standard_error(fit_a)
ci_g <- heritability_interval(fit_g); ci_a <- heritability_interval(fit_a)
print(vc_g); print(vc_a); print(h_g); print(h_a); print(se_g); print(se_a)
print(ci_g); print(ci_a)
print(fit_diagnostics(fit_g))

gebv <- breeding_values(fit_g); ebv <- breeding_values(fit_a)
gebv <- gebv[match(dat$id, gebv$id), ]; ebv <- ebv[match(dat$id, ebv$id), ]
scan_df <- as.data.frame(unclass(scan))
scan_df <- cbind(scan_df, sim$map[match(scan_df$marker, sim$map$marker), c("chr", "pos", "causal", "effect")])
top <- head(scan_df[order(scan_df$p_value), ], 12)
print(top)

out <- list(
  truth = sim$truth,
  realised_h2 = var(dat$true_g) / var(dat$y - 0.5 * (dat$sex == "M")),
  n = nrow(dat), n_ped = nrow(sim$pedigree), n_markers = ncol(sim$markers),
  vc_g = vc_g, vc_a = vc_a, h_g = h_g, h_a = h_a, se_g = se_g, se_a = se_a,
  ci_g = ci_g, ci_a = ci_a, se_method = c(g = fit_g$result$se_method, a = fit_a$result$se_method),
  converged = c(g = fit_g$result$converged, a = fit_a$result$converged),
  acc = c(gebv = cor(gebv$value, dat$true_g), ebv = cor(ebv$value, dat$true_g)),
  bv = data.frame(id = dat$id, true_g = dat$true_g, gebv = gebv$value, ebv = ebv$value),
  scan = scan_df[, c("marker", "chr", "pos", "causal", "effect", "z", "p_value", "bonferroni_p", "bh_qvalue")],
  lambda_gc = median(scan_df$chisq) / qchisq(0.5, 1),
  times = c(simulate = t_sim, genomic_cold = t_cold, genomic = t_g,
            pedigree_first = t_a, pedigree = t_a2, gwas = t_s),
  threads = c(julia = JuliaCall::julia_eval("Threads.nthreads()"),
              blas = JuliaCall::julia_eval("using LinearAlgebra; BLAS.get_num_threads()")),
  session = list(R = R.version.string, julia = JuliaCall::julia_eval("string(VERSION)"),
                 engine_commit = system("git -C ../../Julia/HSquared.jl rev-parse --short HEAD", intern = TRUE),
                 r_commit = system("git rev-parse --short HEAD", intern = TRUE))
)
print(out$times); print(out$acc); print(out$lambda_gc); print(out$threads)
saveRDS(out, "dev-test/genomic-sim/case-study-seed1.rds")
