# Combine the four legs into one table per trait.
#   Rscript dev-test/se-investigation/05-compare.R
suppressPackageStartupMessages(library(coda))
asr <- readRDS("dev-test/se-investigation/res-asreml.rds")
hsq <- readRDS("dev-test/se-investigation/res-hsquared.rds")
ref <- readRDS("dev-test/se-investigation/res-reference.rds")
files <- list.files("dev-test/se-investigation/mcmc", "chain[0-9]+\\.rds$", full.names = TRUE)
chains <- lapply(files, readRDS)

post_sd <- function(tr) {
  cs <- Filter(function(z) z$trait == tr, chains)
  draws <- lapply(cs, function(z) {
    v <- as.matrix(z$VCV)
    cbind(animal = v[, "animal"], permanent = v[, "pe"], residual = v[, "units"],
          h2 = v[, "animal"] / rowSums(v))
  })
  all <- do.call(rbind, draws)
  sds <- apply(all, 2, sd)
  # MCSE of the posterior SD: delta method on the variance, with the ESS of the
  # squared deviations (per chain, pooled), cross-checked against the spread of
  # per-chain SDs.
  mu <- colMeans(all)
  ess_sq <- Reduce(`+`, lapply(draws, function(x)
    effectiveSize(mcmc(sweep(x, 2, mu)^2))))
  ess <- Reduce(`+`, lapply(draws, function(x) effectiveSize(mcmc(x))))
  m4 <- colMeans(sweep(all, 2, mu)^4)
  mcse_var <- sqrt((m4 - sds^4) / ess_sq)
  mcse_sd <- mcse_var / (2 * sds)
  chain_sd <- sapply(draws, function(x) apply(x, 2, sd))
  mcse_sd_between <- apply(chain_sd, 1, sd) / sqrt(ncol(chain_sd))
  rhat <- tryCatch(gelman.diag(mcmc.list(lapply(draws, mcmc)),
                               multivariate = FALSE)$psrf[, 1],
                   error = function(e) rep(NA, 4))
  list(mean = mu, mode = apply(all, 2, function(x) {
    dd <- density(x); dd$x[which.max(dd$y)] }),
    sd = sds, mcse_sd = mcse_sd, mcse_sd_between = mcse_sd_between,
    ess = ess, rhat = rhat, n_chains = length(cs), n_draws = nrow(all))
}

for (tr in names(asr)) {
  p <- post_sd(tr)
  r <- ref[[tr]]
  se_tab <- rbind(
    `ASReml (reported)` = r$se_asreml,
    `R ref: inverse AI` = r$se_AI,
    `hsquared (reported)` = c(hsq[[tr]]$varcomp$se, hsq[[tr]]$h2[["se"]]),
    `R ref: inverse observed` = r$se_OBS[, "rel3e-3"],
    `R ref: inverse expected` = r$se_EXP,
    `MCMCglmm posterior SD` = p$sd,
    `  MCSE of posterior SD` = p$mcse_sd,
    `  MCSE (between chains)` = p$mcse_sd_between
  )
  colnames(se_tab) <- c("animal", "permanent", "residual", "h2")
  est_tab <- rbind(
    ASReml = c(asr[[tr]]$varcomp$estimate, asr[[tr]]$h2[["estimate"]]),
    hsquared = c(hsq[[tr]]$varcomp$estimate, hsq[[tr]]$h2[["estimate"]]),
    `MCMCglmm mean` = p$mean, `MCMCglmm mode` = p$mode
  )
  colnames(est_tab) <- colnames(se_tab)
  cat("\n=====", tr, "=====", p$n_chains, "chains,", p$n_draws, "draws\n")
  cat("ESS:", format(round(p$ess)), "  Rhat:", format(round(p$rhat, 4)), "\n\nEstimates\n")
  print(signif(est_tab, 6))
  cat("\nStandard errors / posterior SDs\n")
  print(signif(se_tab, 4))
  z <- function(x) (p$sd - x) / p$mcse_sd
  cat("\n(posterior SD - SE) / MCSE:\n")
  print(round(rbind(vs_AI = z(r$se_AI), vs_observed = z(r$se_OBS[, "rel3e-3"]),
                    vs_expected = z(r$se_EXP)), 2))
}
