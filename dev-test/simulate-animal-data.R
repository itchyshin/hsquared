# Simulate a simple animal-model data set with no predictors.
#
# `h2` is the narrow-sense heritability in the generating model. The total
# phenotypic variance is fixed at one, so Va = h2 and Ve = 1 - h2.
simulate_animal_data <- function(N, h2) {
  if (
    length(N) != 1L || !is.numeric(N) || !is.finite(N) ||
      N < 3 || N > .Machine$integer.max || N != as.integer(N)
  ) {
    stop("`N` must be one integer greater than or equal to 3.", call. = FALSE)
  }
  if (
    length(h2) != 1L || !is.numeric(h2) || !is.finite(h2) ||
      h2 < 0 || h2 > 1
  ) {
    stop("`h2` must be one finite number between 0 and 1.", call. = FALSE)
  }

  N <- as.integer(N)
  n_founders <- max(2L, ceiling(N / 2))
  sire <- dam <- rep(NA_integer_, N)

  if (n_founders < N) {
    founder_ids <- seq_len(n_founders)
    for (i in seq.int(n_founders + 1L, N)) {
      parents <- sample(founder_ids, size = 2L, replace = FALSE)
      sire[i] <- parents[1L]
      dam[i] <- parents[2L]
    }
  }

  ped <- data.frame(
    id = seq_len(N),
    sire = sire,
    dam = dam
  )

  additive_value <- numeric(N)
  additive_value[seq_len(n_founders)] <- stats::rnorm(
    n_founders,
    sd = sqrt(h2)
  )

  if (n_founders < N) {
    for (i in seq.int(n_founders + 1L, N)) {
      parent_mean <- (additive_value[sire[i]] + additive_value[dam[i]]) / 2
      additive_value[i] <- parent_mean + stats::rnorm(
        1L,
        sd = sqrt(h2 / 2)
      )
    }
  }

  residual <- stats::rnorm(N, sd = sqrt(1 - h2))
  data <- data.frame(
    id = factor(seq_len(N)),
    y = additive_value + residual
  )

  list(ped = ped, data = data)
}

# Example object. Change these two values as needed for development tests.
set.seed(1)
s <- simulate_animal_data(N = 200L, h2 = 0.4)

system.time(fit <- hsquared(y ~ animal(1 | id, pedigree = s$ped), data = s$data))

Ainv <- ainverse(s$ped)
system.time(fitasreml <- asreml(y ~ 1,
          random = ~ vm(id, Ainv),
          data = s$data, trace = FALSE
      ))
