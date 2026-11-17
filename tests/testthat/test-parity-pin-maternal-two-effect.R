# PARITY-MAP row 11: the opt-in two_effect maternal-genetic bridge (effect 2
# shares the pedigree A, so A2 = A) must return the same variance components
# and REML logLik as a direct HSquared.jl fit_two_effect_reml() call on the
# same data. The live test in test-maternal.R only checks positivity.
# Live Julia only.
#
# Data: the 30-animal engine-parity pedigree; the 24 animals with known dams
# get 2 records each, with a direct additive effect (var 1) and a maternal
# effect carried by the dam (var 0.8). Seed 1 is the first seed with all three
# variances interior at the optimum (seeds 6, 7 and 9 sit on a boundary, which
# is the flat-ridge case of HSquared.jl#416 and is deliberately not pinned
# here); if an engine change moves this fit to a boundary, update the test on
# purpose rather than searching for another seed.

test_that("maternal two-effect bridge variance components and logLik match a direct HSquared.jl fit [live]", {
  hs_skip_live_julia()
  testthat::skip_if_not(
    hsquared:::hs_julia_bridge_available(),
    "JuliaCall, Julia, and local HSquared.jl are required for the live maternal parity pin."
  )

  ped <- hs_pin_pedigree()
  A <- hs_pin_numerator_relationship(ped)
  n <- nrow(ped)
  set.seed(1)
  a <- stats::setNames(
    as.vector(t(chol(A)) %*% stats::rnorm(n, sd = 1)),
    ped$id
  )
  m <- stats::setNames(
    as.vector(t(chol(A)) %*% stats::rnorm(n, sd = sqrt(0.8))),
    ped$id
  )
  kids <- ped[!is.na(ped$dam), ]
  k <- 2L
  id <- rep(kids$id, each = k)
  dam <- rep(kids$dam, each = k)
  sex <- rep(rep(c("M", "F"), length.out = nrow(kids)), each = k)
  y <- 5 + 0.5 * (sex == "M") + a[id] + m[dam] + stats::rnorm(length(id))
  dat <- data.frame(
    id = id,
    dam = dam,
    sex = sex,
    y = round(unname(y), 4),
    stringsAsFactors = FALSE
  )

  fit <- hsquared(
    y ~ sex + animal(1 | id, pedigree = ped) + maternal_genetic(1 | dam),
    data = dat,
    family = stats::gaussian(),
    control = hs_control(
      engine = "julia",
      engine_control = list(target = "two_effect")
    )
  )

  hs_pin_julia_assign(ped, dat)
  # Same start as the bridge default (all variances 1); see PR #383 / P3 in
  # DECISIONS-PENDING: default-start agreement is only ~1e-4 relative.
  Z2 <- Matrix::sparseMatrix(
    i = seq_len(nrow(dat)),
    j = match(dat$dam, ped$id),
    x = 1,
    dims = c(nrow(dat), nrow(ped))
  )
  hsquared:::hs_julia_assign_sparse_csc("hsq_pin_Z2", Z2)
  JuliaCall::julia_command(paste(
    "hsq_pin_fit = HSquared.fit_two_effect_reml(",
    "hsq_pin_y, hsq_pin_X, hsq_pin_Z, hsq_pin_Ainv, hsq_pin_Z2, hsq_pin_Ainv;",
    "initial = (sigma1 = 1.0, sigma2 = 1.0, sigma_e2 = 1.0),",
    "ids1 = hsq_pin_ped.ids, ids2 = hsq_pin_ped.ids);"
  ))
  direct <- JuliaCall::julia_eval(paste(
    "Float64[hsq_pin_fit.variance_components.sigma1,",
    "hsq_pin_fit.variance_components.sigma2,",
    "hsq_pin_fit.variance_components.sigma_e2, hsq_pin_fit.loglik]"
  ))
  expect_true(JuliaCall::julia_eval("hsq_pin_fit.converged"))
  expect_true(all(direct[1:3] > 1e-6)) # interior optimum, not a boundary fit
  # Guard the guard: animal and maternal components differ, so a swap fails.
  expect_gt(abs(direct[[1]] - direct[[2]]), 1e-2)

  vc <- variance_components(fit)
  expect_equal(vc$component, c("animal", "maternal_genetic", "residual"))
  hs_pin_expect_rel(vc$estimate[1], direct[[1]], "sigma_a2")
  hs_pin_expect_rel(vc$estimate[2], direct[[2]], "sigma_m2")
  hs_pin_expect_rel(vc$estimate[3], direct[[3]], "sigma_e2")
  hs_pin_expect_rel(as.numeric(stats::logLik(fit)), direct[[4]], "logLik")
})
