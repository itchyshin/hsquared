# Binomial count responses: cbind(successes, failures) ~ ... with family =
# binomial() must be a non-Gaussian binomial-trials model, NOT silently coerced
# into a 2-trait multivariate Gaussian (the family-blind cbind bug) or down to a
# binary Bernoulli (dropping the trial counts). The engine's BinomialResponse
# holds ONE common n_trials, so the cbind row totals (successes + failures) must
# be equal; varying totals error (per-record trials are an engine follow-up).

ped4 <- function() {
  data.frame(
    id = c("s", "d", "a", "b"),
    sire = c(NA, NA, "s", "s"),
    dam = c(NA, NA, "d", "d"),
    stringsAsFactors = FALSE
  )
}

test_that("cbind(successes, failures) + binomial() builds a binomial-counts spec, not multivariate", {
  ped <- ped4()
  # equal row totals (3 trials each) -> a single common n_trials = 3
  dat <- data.frame(
    succ = c(1, 2, 3, 0),
    fail = c(2, 1, 0, 3),
    id = c("s", "d", "a", "b")
  )
  spec <- hsquared:::hs_build_model_spec(
    cbind(succ, fail) ~ animal(1 | id, pedigree = ped),
    data = dat,
    family = stats::binomial(),
    REML = TRUE,
    allow_families = c("gaussian", "poisson", "binomial")
  )
  # NOT multivariate; it is a single-response binomial-counts model
  expect_false(isTRUE(spec$response$multivariate))
  expect_true(isTRUE(spec$response$binomial_counts))
  expect_equal(spec$response$n_trials, 3)
  # the response values are the success counts
  expect_equal(as.numeric(spec$response$values), c(1, 2, 3, 0))
})

test_that("cbind(successes, failures) + binomial() with varying row totals errors clearly", {
  ped <- ped4()
  dat <- data.frame(
    succ = c(1, 2, 3, 0),
    fail = c(2, 1, 1, 3), # totals 3,3,4,3 -> not all equal
    id = c("s", "d", "a", "b")
  )
  expect_error(
    hsquared:::hs_build_model_spec(
      cbind(succ, fail) ~ animal(1 | id, pedigree = ped),
      data = dat,
      family = stats::binomial(),
      REML = TRUE,
      allow_families = c("gaussian", "poisson", "binomial")
    ),
    "equal"
  )
})

test_that("cbind(t1, t2) + gaussian() is still multivariate (no regression)", {
  ped <- ped4()
  dat <- data.frame(
    t1 = c(1.1, 2.2, 3.0, 2.5),
    t2 = c(0.5, 1.5, 2.0, 1.0),
    id = c("s", "d", "a", "b")
  )
  spec <- hsquared:::hs_build_model_spec(
    cbind(t1, t2) ~ animal(1 | id, pedigree = ped),
    data = dat,
    family = stats::gaussian(),
    REML = TRUE
  )
  expect_true(isTRUE(spec$response$multivariate))
})

test_that("a binary 0/1 binomial response stays Bernoulli (vector, not counts)", {
  ped <- ped4()
  dat <- data.frame(y = c(0, 1, 1, 0), id = c("s", "d", "a", "b"))
  spec <- hsquared:::hs_build_model_spec(
    y ~ animal(1 | id, pedigree = ped),
    data = dat,
    family = stats::binomial(),
    REML = TRUE,
    allow_families = c("gaussian", "poisson", "binomial")
  )
  expect_false(isTRUE(spec$response$multivariate))
  expect_false(isTRUE(spec$response$binomial_counts))
})

test_that("the family-symbol mapper distinguishes Bernoulli from Binomial(n_trials)", {
  expect_equal(
    hsquared:::hs_nongaussian_family_symbol(stats::binomial()),
    "bernoulli"
  )
  expect_equal(
    hsquared:::hs_nongaussian_family_symbol(stats::binomial(), n_trials = 1L),
    "bernoulli"
  )
  expect_equal(
    hsquared:::hs_nongaussian_family_symbol(stats::binomial(), n_trials = 5L),
    "binomial"
  )
  expect_equal(
    hsquared:::hs_nongaussian_family_symbol(stats::poisson()),
    "poisson"
  )
})

test_that("the live bridge fits a balanced binomial-counts model [live]", {
  testthat::skip_on_cran()
  testthat::skip_if_not(
    hsquared:::hs_julia_bridge_available(),
    "JuliaCall, Julia, and local HSquared.jl are required for the live bridge."
  )

  set.seed(5)
  ped <- data.frame(
    id = c("s1", "s2", "d1", "d2", paste0("a", 1:16)),
    sire = c(NA, NA, NA, NA, rep(c("s1", "s2"), 8)),
    dam = c(NA, NA, NA, NA, rep(c("d1", "d2"), 8))
  )
  n <- nrow(ped)
  trials <- 10L
  succ <- rbinom(n, trials, 0.4)
  dat <- data.frame(succ = succ, fail = trials - succ, id = ped$id)

  fit <- hsquared(
    cbind(succ, fail) ~ animal(1 | id, pedigree = ped),
    data = dat,
    family = stats::binomial(),
    REML = TRUE,
    control = hs_control(
      engine = "julia",
      engine_control = list(target = "nongaussian")
    )
  )
  expect_s3_class(fit, "hsquared_fit")
  expect_equal(fit$result$family, "binomial")
  expect_true(is.finite(variance_components(fit)$estimate))
  expect_equal(nrow(breeding_values(fit)), n)
  expect_error(heritability(fit), "heritability") # latent scale, no h2

  # parity: the R binomial-counts fit matches a direct engine fit_laplace_reml
  # with family = :binomial and the common n_trials (the bridge left hsq_*).
  direct_sa2 <- JuliaCall::julia_eval(
    "HSquared.fit_laplace_reml(hsq_y, hsq_X, hsq_Z, hsq_Ainv; family = :binomial, n_trials = Int(hsq_n_trials), ids = hsq_ped.ids).variance_components.sigma_a2"
  )
  expect_equal(variance_components(fit)$estimate, direct_sa2, tolerance = 1e-6)
})

test_that("a cbind binomial with one trial reduces to the Bernoulli fit [live]", {
  testthat::skip_on_cran()
  testthat::skip_if_not(
    hsquared:::hs_julia_bridge_available(),
    "JuliaCall, Julia, and local HSquared.jl are required for the live bridge."
  )

  set.seed(6)
  ped <- data.frame(
    id = c("s1", "s2", "d1", "d2", paste0("a", 1:16)),
    sire = c(NA, NA, NA, NA, rep(c("s1", "s2"), 8)),
    dam = c(NA, NA, NA, NA, rep(c("d1", "d2"), 8))
  )
  n <- nrow(ped)
  y01 <- rbinom(n, 1L, 0.5)
  ng_control <- hs_control(
    engine = "julia",
    engine_control = list(target = "nongaussian")
  )

  # cbind(successes, failures) with one trial each: n_trials = 1 -> Bernoulli
  fit_cbind <- hsquared(
    cbind(y, no) ~ animal(1 | id, pedigree = ped),
    data = data.frame(y = y01, no = 1L - y01, id = ped$id),
    family = stats::binomial(),
    REML = TRUE,
    control = ng_control
  )
  # the same data as a binary 0/1 Bernoulli response
  fit_binary <- hsquared(
    y ~ animal(1 | id, pedigree = ped),
    data = data.frame(y = y01, id = ped$id),
    family = stats::binomial(),
    REML = TRUE,
    control = ng_control
  )
  expect_equal(fit_cbind$result$family, "bernoulli")
  expect_equal(
    variance_components(fit_cbind)$estimate,
    variance_components(fit_binary)$estimate,
    tolerance = 1e-8
  )
})
