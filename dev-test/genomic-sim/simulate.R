# Gene-drop simulation of a genotyped, pedigreed population with a polygenic
# Gaussian trait. Base R only. Source this file, then call simulate_population().
#
# Design (defaults):
#   * n_founders unrelated founders (half male), in Hardy-Weinberg equilibrium,
#     allele frequencies p_j ~ U(0.05, 0.95), no founder LD;
#   * n_gen discrete generations of n_per_gen offspring from random sires/dams of
#     the previous generation (so half-sibs, full-sibs and cousins arise);
#   * n_chr chromosomes of length 1 Morgan, snps_per_chr markers at uniform
#     positions; Haldane meiosis (Poisson(1) crossovers per chromosome) -> LD
#     between linked loci within families;
#   * n_causal causal SNPs drawn from markers segregating in the recorded
#     generations, effects N(0, 1), rescaled so Var(g) = h2 in the recorded
#     animals (phenotypic variance about 1 before the sex effect);
#   * y = 10 + sex_effect * male + g + e, e ~ N(0, 1 - h2).
# Founders are genotyped but not phenotyped (they are the pedigree base).

simulate_population <- function(seed = 1, n_founders = 200, n_gen = 5,
                                n_per_gen = 400, n_chr = 10,
                                snps_per_chr = 1000, n_causal = 200,
                                h2 = 0.4, sex_effect = 0.5) {
  set.seed(seed)
  m <- n_chr * snps_per_chr
  chr <- rep(seq_len(n_chr), each = snps_per_chr)
  pos <- unlist(lapply(seq_len(n_chr), function(i) sort(runif(snps_per_chr))))
  chr_idx <- split(seq_len(m), chr)

  n_total <- n_founders + n_gen * n_per_gen
  # two haplotype matrices, one row per animal (0/1 alleles as raw to save RAM)
  hap1 <- matrix(as.raw(0), n_total, m)
  hap2 <- matrix(as.raw(0), n_total, m)
  p0 <- runif(m, 0.05, 0.95)
  hap1[seq_len(n_founders), ] <- as.raw(matrix(runif(n_founders * m) < rep(p0, each = n_founders), n_founders))
  hap2[seq_len(n_founders), ] <- as.raw(matrix(runif(n_founders * m) < rep(p0, each = n_founders), n_founders))

  id <- character(n_total); sire <- dam <- rep(NA_character_, n_total)
  sex <- character(n_total); gen <- integer(n_total)
  id[seq_len(n_founders)] <- sprintf("F%04d", seq_len(n_founders))
  sex[seq_len(n_founders)] <- rep(c("M", "F"), length.out = n_founders)

  gamete <- function(parent) {
    out <- raw(m)
    for (k in seq_len(n_chr)) {
      idx <- chr_idx[[k]]
      ncross <- rpois(1, 1)
      start_hap <- sample(2L, 1)
      if (ncross == 0) {
        out[idx] <- if (start_hap == 1) hap1[parent, idx] else hap2[parent, idx]
      } else {
        cuts <- sort(runif(ncross))
        seg <- findInterval(pos[idx], cuts) # 0..ncross
        from1 <- (seg %% 2 == 0) == (start_hap == 1)
        h <- hap2[parent, idx]
        h[from1] <- hap1[parent, idx][from1]
        out[idx] <- h
      }
    }
    out
  }

  prev <- seq_len(n_founders)
  nxt <- n_founders
  for (g in seq_len(n_gen)) {
    sires <- prev[sex[prev] == "M"]; dams <- prev[sex[prev] == "F"]
    kids <- nxt + seq_len(n_per_gen)
    for (j in kids) {
      s <- sires[sample.int(length(sires), 1)]
      d <- dams[sample.int(length(dams), 1)]
      hap1[j, ] <- gamete(s)
      hap2[j, ] <- gamete(d)
      sire[j] <- id[s]; dam[j] <- id[d]
    }
    id[kids] <- sprintf("G%d_%04d", g, seq_len(n_per_gen))
    sex[kids] <- sample(c("M", "F"), n_per_gen, replace = TRUE)
    gen[kids] <- g
    prev <- kids; nxt <- max(kids)
  }

  M <- matrix(as.integer(hap1) + as.integer(hap2), n_total, m)
  rownames(M) <- id
  colnames(M) <- sprintf("chr%d_%04d", chr, ave(chr, chr, FUN = seq_along))
  rm(hap1, hap2)

  rec <- which(gen > 0)
  # drop markers monomorphic in the recorded animals (VanRaden needs 0 < p < 1)
  seg <- which(apply(M[rec, , drop = FALSE], 2, function(x) any(x != x[1])))
  M <- M[, seg, drop = FALSE]; chr <- chr[seg]; pos <- pos[seg]

  causal <- sort(sample(ncol(M), n_causal))
  beta <- rnorm(n_causal)
  Wc <- scale(M[, causal, drop = FALSE], center = TRUE, scale = FALSE)
  g_all <- drop(Wc %*% beta)
  # scale so the genetic variance among recorded animals is h2
  k <- sqrt(h2 / var(g_all[rec]))
  beta <- beta * k; g_all <- g_all * k
  e <- rnorm(n_total, sd = sqrt(1 - h2))
  y <- 10 + sex_effect * (sex == "M") + g_all + e

  pheno <- data.frame(id = id, sex = factor(sex), generation = gen, y = y,
                      true_g = g_all)[rec, ]
  rownames(pheno) <- NULL
  list(
    pheno = pheno,
    pedigree = data.frame(id = id, dam = dam, sire = sire),
    markers = M, # all animals incl. founders, 0/1/2 dosages
    map = data.frame(marker = colnames(M), chr = chr, pos = pos,
                     causal = seq_len(ncol(M)) %in% causal,
                     effect = replace(numeric(ncol(M)), causal, beta)),
    truth = list(h2 = h2, var_g = var(g_all[rec]), var_e = 1 - h2,
                 sex_effect = sex_effect, seed = seed)
  )
}
