library(hsquared)
set.seed(1)

sim_animal <- function(n) {
  sire <- dam <- integer(n)
  for (i in 3:n) {
    sire[i] <- sample.int(i - 1L, 1L)
    dam_candidates <- setdiff(seq_len(i - 1L), sire[i])
    dam[i] <- dam_candidates[sample.int(length(dam_candidates), 1L)]
  }
  ped <- data.frame(
    id = seq_len(n),
    sire = replace(sire, sire == 0L, NA_integer_),
    dam = replace(dam, dam == 0L, NA_integer_)
  )
  stopifnot(!any(!is.na(ped$sire) & !is.na(ped$dam) & ped$sire == ped$dam))
  dat <- data.frame(id = as.factor(seq_len(n)), y = 10 + 2 * rnorm(n))
  list(ped = ped, dat = dat)
}

for (n in c(200, 500, 1000, 2000)) {
  s <- sim_animal(n)
  t <- system.time(
    fit <- hsquared(y ~ animal(1 | id, pedigree = s$ped), data = s$dat)   # goes through Julia
  )
  cat(sprintf("hsquared  n=%5d : %6.1f s\n", n, t["elapsed"]))
}

library(asreml)
for (n in c(200, 500, 1000, 2000)) {
  s <- sim_animal(n)
  Ainv <- ainverse(s$ped)
  t <- system.time(
      fitasreml <- asreml(y ~ 1,
          random = ~ vm(id, Ainv),
          data = s$dat, trace = FALSE
      )
  )
  cat(sprintf("asreml  n=%5d : %6.1f s\n", n, t["elapsed"]))
}
