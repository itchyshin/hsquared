# External genomic comparator study (EXECUTED, 2026-06-22).
#
# Confronts the committed `genomic_gblup_snpblup_target` fixture with independent
# CRAN packages: AGHmatrix (VanRaden G), rrBLUP (GBLUP + SNP-BLUP), BGLR
# (Bayesian, agreement-only). This is external comparator EVIDENCE (a real run),
# not a runbook. Protocol:
# docs/dev-log/comparator-runs/2026-06-22-genomic-external-comparator-runbook.md
#
# Run: Rscript --vanilla data-raw/genomic-external-comparator-study.R

suppressMessages({
  library(AGHmatrix)
  library(rrBLUP)
  library(BGLR)
})

dir <- "tests/testthat/fixtures/genomic_gblup_snpblup_target"
phen <- read.csv(file.path(dir, "phenotypes.csv"))
M <- as.matrix(read.csv(file.path(dir, "markers.csv"), row.names = 1))
p <- read.csv(file.path(dir, "allele_frequencies.csv"))$frequency
y <- phen$y
names(y) <- phen$id
X <- matrix(1, length(y), 1)
sigma_g2 <- 2
sigma_e2 <- 1
lambda <- sigma_e2 / sigma_g2
G_t <- as.matrix(read.csv(file.path(dir, "expected_genomic_relationship.csv"), row.names = 1))
Gi_t <- as.matrix(read.csv(file.path(dir, "expected_genomic_precision.csv"), row.names = 1))
gebv_t <- read.csv(file.path(dir, "expected_gebv.csv"))
me_t <- read.csv(file.path(dir, "expected_marker_effects.csv"))
beta_t <- read.csv(file.path(dir, "expected_beta.csv"))$value

res <- function(label, value) cat(sprintf("%-56s %s\n", label, value))

cat("== reference: VanRaden-1 with SUPPLIED p (engine algebra, base R) ==\n")
W <- sweep(M, 2, 2 * p, FUN = "-")
k <- 2 * sum(p * (1 - p))
G_ref <- (W %*% t(W)) / k
res("k (fixture = 2.825):", sprintf("%.6f", k))
res("max|G_ref - fixture G|:", format(max(abs(G_ref - G_t)), digits = 3))
res("max|solve(G_ref) - fixture Ginv|:", format(max(abs(solve(G_ref) - Gi_t)), digits = 3))

cat("\n== external: AGHmatrix::Gmatrix VanRaden (sample-estimated p) ==\n")
G_agh <- Gmatrix(SNPmatrix = M, method = "VanRaden", ploidy = 2)
res("max|AGHmatrix G - fixture G| (sample p != supplied p):", format(max(abs(G_agh - G_t)), digits = 3))
cat("  (AGHmatrix re-estimates p from the sample; a direct match is NOT expected.\n")
cat("   The construction check uses the supplied-p base-R route above.)\n")

cat("\n== external exact-parity: VanRaden FORMULA vs AGHmatrix (matched p) ==\n")
cat("  (Gmatrix has no supplied-frequency argument, so instead verify the\n")
cat("   construction FORMULA by feeding the engine's VanRaden formula AGHmatrix's\n")
cat("   OWN sample p -- an exact, p-independent algorithm check.)\n")
p_agh <- colMeans(M) / 2
W_agh <- sweep(M, 2, 2 * p_agh, FUN = "-")
k_agh <- 2 * sum(p_agh * (1 - p_agh))
G_base_aghp <- (W_agh %*% t(W_agh)) / k_agh
res("AGHmatrix sample p:", paste(format(p_agh, digits = 3), collapse = " "))
res("max|base-R VanRaden(p_AGH) - AGHmatrix G|:", format(max(abs(G_base_aghp - G_agh)), digits = 3))

cat("\n== reference: supplied-variance GBLUP via Henderson MME (base R) ==\n")
Z <- diag(length(y))
Gi <- solve(G_ref)
C <- rbind(
  cbind(crossprod(X), t(X) %*% Z),
  cbind(t(Z) %*% X, crossprod(Z) + Gi * lambda)
)
rhs <- c(crossprod(X, y), crossprod(Z, y))
sol <- as.numeric(solve(C, rhs))
b_mme <- sol[1]
u_mme <- sol[-1]
res("MME intercept vs fixture beta:", sprintf("%.10f vs %.10f", b_mme, beta_t))
res("max|MME GBLUP - fixture gblup|:", format(max(abs(u_mme - gebv_t$gblup)), digits = 3))

cat("\n== external: rrBLUP GBLUP (K=G) and SNP-BLUP (Z=W), REML variances ==\n")
fit_g <- mixed.solve(y = y, K = G_ref, X = X)
gebv_rr <- as.numeric(fit_g$u)
fit_m <- mixed.solve(y = y, Z = W, X = X)
me_rr <- as.numeric(fit_m$u)
gebv_from_me <- as.numeric(W %*% me_rr)
res("rrBLUP GBLUP vs SNP-BLUP GEBV max|diff| (equivalence):", format(max(abs(gebv_rr - gebv_from_me)), digits = 3))
res("rrBLUP GBLUP GEBV cor with fixture gblup:", sprintf("%.6f", cor(gebv_rr, gebv_t$gblup)))
res("rrBLUP marker-effect cor with fixture effects:", sprintf("%.6f", cor(me_rr, me_t$effect)))
res("rrBLUP REML Vu / Ve (ratio):", sprintf("%.4f / %.4f (%.3f)", fit_g$Vu, fit_g$Ve, fit_g$Ve / fit_g$Vu))

cat("\n== external: BGLR Bayesian GBLUP (RKHS, K=G) -- agreement only ==\n")
set.seed(20260622)
sa <- file.path(tempdir(), "bglr_")
fm <- BGLR(
  y = y, ETA = list(list(K = G_ref, model = "RKHS")),
  nIter = 12000, burnIn = 2000, verbose = FALSE, saveAt = sa
)
gebv_bglr <- as.numeric(fm$ETA[[1]]$u)
res("BGLR posterior-mean GEBV cor with fixture gblup:", sprintf("%.6f", cor(gebv_bglr, gebv_t$gblup)))

cat("\n== session ==\n")
for (pk in c("AGHmatrix", "rrBLUP", "BGLR")) res(pk, as.character(packageVersion(pk)))
cat(R.version.string, "\n")
