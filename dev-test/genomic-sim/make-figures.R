# Figures for vignettes/articles/genomic-simulation-case-study.Rmd.
# Inputs: case-study-seed1.rds (case-study.R) and reps/rep-*.rds (replicate.R).
#   Rscript dev-test/genomic-sim/make-figures.R
cs <- readRDS("dev-test/genomic-sim/case-study-seed1.rds")
reps <- do.call(rbind, lapply(
  list.files("dev-test/genomic-sim/reps", "^rep-.*\\.rds$", full.names = TRUE), readRDS))

ink <- "#1f1f1e"; muted <- "#6b6a63"; grid <- "#e4e3dd"
blue <- "#2a78d6"; orange <- "#eb6834"
chr_grey <- c("#b9b8b0", "#8f8e86")
base_par <- function() par(family = "sans", col.axis = muted, col.lab = ink,
                           fg = muted, las = 1, mgp = c(2.4, 0.6, 0), tcl = -0.3)

# ---- 1. Manhattan plot, causal SNPs marked ---------------------------------
s <- cs$scan
s <- s[order(s$chr, s$pos), ]
s$x <- s$chr - 1 + s$pos * 0.92 # chromosomes laid end to end, small gap
s$lp <- -log10(s$p_value)
bonf <- -log10(0.05 / nrow(s))
sig <- s$bonferroni_p < 0.05

ragg::agg_png("man/figures/genomic-sim-manhattan.png", width = 8, height = 3.6, units = "in", res = 200)
base_par(); par(mar = c(3.4, 3.8, 1.2, 0.6))
plot(NA, xlim = c(0, 10), ylim = c(0, max(s$lp) * 1.05), xaxt = "n",
     xlab = "Chromosome", ylab = expression(-log[10](italic(p))), bty = "n")
abline(h = pretty(c(0, max(s$lp))), col = grid, lwd = 0.8)
axis(1, at = seq_len(10) - 0.54, labels = seq_len(10), lwd = 0, lwd.ticks = 0)
nc <- !s$causal
points(s$x[nc], s$lp[nc], pch = 16, cex = 0.35, col = chr_grey[(s$chr[nc] %% 2) + 1])
points(s$x[s$causal], s$lp[s$causal], pch = 21, cex = 0.75, bg = blue, col = "white", lwd = 0.6)
abline(h = bonf, lty = 2, col = ink, lwd = 1)
text(10, bonf, "Bonferroni 5%", adj = c(1, -0.5), col = ink, cex = 0.75)
legend("topright", bty = "n", cex = 0.75, text.col = ink,
       pch = c(21, 16), pt.bg = c(blue, NA), col = c("white", chr_grey[2]),
       pt.cex = c(0.9, 0.6), legend = c("causal SNP (200)", "other SNP"))
dev.off()

# ---- 2. Heritability recovery across 20 replicates -------------------------
r <- reps[order(reps$g_h2), ]
r$k <- seq_len(nrow(r))
svglite::svglite("man/figures/genomic-sim-h2-recovery.svg", width = 8, height = 3.8)
base_par(); par(mar = c(3.4, 3.8, 1.2, 0.6))
yl <- range(c(r$g_h2 - 1.96 * r$g_h2_se, r$a_h2 + 1.96 * r$a_h2_se,
              r$a_h2 - 1.96 * r$a_h2_se, r$g_h2 + 1.96 * r$g_h2_se))
plot(NA, xlim = c(0.5, nrow(r) + 0.5), ylim = yl + c(0, 0.07), xaxt = "n", bty = "n",
     xlab = "Replicate (ordered by genomic estimate)", ylab = "Heritability estimate")
abline(h = axTicks(2), col = grid, lwd = 0.8)
abline(h = 0.4, col = ink, lwd = 1, lty = 2)
off <- 0.18
segments(r$k - off, r$g_h2 - 1.96 * r$g_h2_se, r$k - off, r$g_h2 + 1.96 * r$g_h2_se, col = blue, lwd = 2)
segments(r$k + off, r$a_h2 - 1.96 * r$a_h2_se, r$k + off, r$a_h2 + 1.96 * r$a_h2_se, col = orange, lwd = 2)
points(r$k - off, r$g_h2, pch = 21, bg = blue, col = "white", cex = 1.1, lwd = 0.8)
points(r$k + off, r$a_h2, pch = 24, bg = orange, col = "white", cex = 1, lwd = 0.8)
points(r$k, r$realised_h2, pch = 4, col = ink, cex = 0.7, lwd = 1)
legend("topleft", bty = "n", cex = 0.75, text.col = ink,
       pch = c(21, 24), pt.bg = c(blue, orange), col = "white",
       legend = c("genomic GREML ± 1.96 SE", "pedigree animal model ± 1.96 SE"))
legend(nrow(r) * 0.45, par("usr")[4], bty = "n", cex = 0.75, text.col = ink,
       pch = c(4, NA), lty = c(NA, 2), col = ink,
       legend = c("realised h² in the sample", "simulated h² = 0.4"))
dev.off()

# ---- 3. GEBV / EBV against the true genetic value (seed 1) -----------------
b <- cs$bv
ragg::agg_png("man/figures/genomic-sim-gebv.png", width = 8, height = 3.6, units = "in", res = 200)
base_par(); par(mfrow = c(1, 2), mar = c(3.4, 3.8, 1.8, 0.8))
for (w in c("gebv", "ebv")) {
  col <- if (w == "gebv") blue else orange
  lab <- if (w == "gebv") "Genomic (GBLUP)" else "Pedigree (BLUP)"
  lim <- range(c(b$true_g, b$gebv, b$ebv))
  plot(b$true_g, b[[w]], pch = 16, cex = 0.35, col = adjustcolor(col, 0.45),
       xlim = lim, ylim = lim, bty = "n", xlab = "True genetic value",
       ylab = "Predicted breeding value")
  abline(0, 1, col = ink, lty = 2)
  mtext(sprintf("%s: r = %.3f", lab, cor(b$true_g, b[[w]])), side = 3,
        adj = 0, col = ink, cex = 0.85, line = 0.3)
}
dev.off()
cat("wrote 3 figures\n")
