# MCMCglmm leg: one chain per process so chains run in parallel.
#   Rscript dev-test/se-investigation/04-mcmcglmm.R <trait> <chain> <nitt> <burnin> <thin>
# Flat fixed-effect prior (MCMCglmm default, variance 1e10) integrates the fixed
# effects out, the Bayesian analogue of REML. Variance priors are weak inverse-
# gamma (nu = 0.002) centred on a third of the phenotypic variance; at n ~ 11,700
# records the likelihood dominates them.
suppressPackageStartupMessages(library(MCMCglmm))
a <- commandArgs(trailingOnly = TRUE)
trait <- a[1]; chain <- as.integer(a[2])
nitt <- as.integer(a[3]); burnin <- as.integer(a[4]); thin <- as.integer(a[5])
inp <- readRDS("dev-test/se-investigation/inputs.rds")[[trait]]
d <- inp$data
d$pe <- d$animal
ped <- inp$ped
rownames(ped) <- NULL
names(ped) <- c("animal", "dam", "sire")
v3 <- var(d$y) / 3
prior <- list(R = list(V = v3, nu = 0.002),
              G = list(G1 = list(V = v3, nu = 0.002), G2 = list(V = v3, nu = 0.002)))
set.seed(1000 * chain + nchar(trait))
tm <- system.time(m <- MCMCglmm(
  y ~ year_f + round_f + exp_manip + female.age,
  random = ~ animal + pe, pedigree = ped, data = d, prior = prior,
  nitt = nitt, burnin = burnin, thin = thin, verbose = FALSE, pr = FALSE
))
out <- list(VCV = m$VCV, seconds = unname(tm["elapsed"]), trait = trait,
            chain = chain, nitt = nitt, burnin = burnin, thin = thin)
saveRDS(out, sprintf("dev-test/se-investigation/mcmc/%s-chain%d.rds", trait, chain))
cat(trait, "chain", chain, "done in", round(tm["elapsed"]), "s\n")
