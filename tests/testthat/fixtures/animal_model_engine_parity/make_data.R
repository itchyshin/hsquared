# Realizes the small inbred pedigree + phenotypes (committed as CSV; needs nadiv).
# Run from this directory: Rscript make_data.R
set.seed(20261036)  # first seed after 20261031 + 4 with an interior REML optimum
ped <- data.frame(
  id = sprintf("a%02d", 1:30),
  sire = NA_character_, dam = NA_character_, stringsAsFactors = FALSE
)
# Generation 0: founders a01-a06 (a01-a03 male, a04-a06 female).
# Generation 1: a07-a18, full- and half-sib families.
g1_sire <- rep(c("a01", "a02", "a03"), each = 4)
g1_dam  <- rep(c("a04", "a05", "a06", "a04", "a05", "a06"), each = 2)
ped$sire[7:18] <- g1_sire
ped$dam[7:18]  <- g1_dam
# Generation 2: a19-a30, including full-sib (a07 x a08) and half-sib matings
# so several animals are inbred (F > 0).
ped$sire[19:30] <- rep(c("a07", "a09", "a11", "a13", "a15", "a17"), each = 2)
ped$dam[19:30]  <- rep(c("a08", "a12", "a10", "a16", "a14", "a18"), each = 2)
A <- nadiv::makeA(ped)
a <- as.vector(t(chol(as.matrix(A))) %*% rnorm(30, sd = sqrt(1.5)))
sex <- c(rep("M", 3), rep("F", 3), rep(c("M", "F"), length.out = 24))
y <- 10 + 0.8 * (sex == "M") + a + rnorm(30, sd = 1)
write.csv(ped, "pedigree.csv", row.names = FALSE, na = "", quote = FALSE)
write.csv(data.frame(id = ped$id, sex = sex, y = round(y, 4)),
  "phenotypes.csv", row.names = FALSE, quote = FALSE)

