# Parity pin for payload_v2 routes `multi_effect` and `direct_maternal`
# (hsquared parity cell 37).
#
# HSquared.jl ships payload_v2 fixtures only for single animal, animal + common
# environment, and animal + permanent (test/fixtures/payload_v2). It has none
# for `direct_maternal` or `multi_effect`, so these two routes were R-only.
#
# Here the R bridge result (which assembles a payload-v2 block list and calls
# HSquared.fit_payload_v2) is confronted with a DIRECT engine call
# (fit_multi_effect_reml / fit_direct_maternal_reml) whose inputs (y, X, Z,
# Ainv) are rebuilt in Julia from the raw data, not from the R payload.
# Start-matched: the bridge forwards no `initial`, so both sides use the
# engine's own default start (all variances 1). Absolute tolerances are not to
# be widened.

hs_pin37_skip <- function() {
  hs_skip_live_julia()
  testthat::skip_on_cran()
  skip_if_not(
    hsquared:::hs_julia_bridge_available(),
    "JuliaCall, Julia, and local HSquared.jl are required."
  )
  hsquared:::hs_julia_setup(hsquared:::hs_default_julia_project())
}

hs_pin37_assign_pedigree <- function(ped) {
  JuliaCall::julia_assign("pin_id", as.character(ped$id))
  JuliaCall::julia_assign(
    "pin_sire",
    ifelse(is.na(ped$sire), "0", as.character(ped$sire))
  )
  JuliaCall::julia_assign(
    "pin_dam",
    ifelse(is.na(ped$dam), "0", as.character(ped$dam))
  )
  JuliaCall::julia_command(paste(
    "pin_ped = HSquared.normalize_pedigree(pin_id, pin_sire, pin_dam);",
    "pin_Ainv = Matrix{Float64}(HSquared.pedigree_inverse(pin_ped));",
    "pin_ix = Dict(string(a) => k for (k, a) in enumerate(pin_ped.ids));"
  ))
}

hs_pin37_fixture <- function() {
  ped <- hs_sim_pedigree(n_founder = 40, n_per_gen = 100, n_gen = 3, seed = 37)
  a <- hs_sim_genedrop_bv(ped, sigma_a2 = 1.0, seed = 37)
  m <- hs_sim_genedrop_bv(ped, sigma_a2 = 0.5, seed = 38)
  kids <- ped[!is.na(ped$dam) & !is.na(ped$sire), , drop = FALSE]
  set.seed(3737)
  n <- nrow(kids)
  nest <- paste0("n", sample(8L, n, replace = TRUE))
  year <- paste0("y", sample(4L, n, replace = TRUE))
  nest_e <- stats::setNames(
    stats::rnorm(8, 0, sqrt(0.6)),
    paste0("n", 1:8)
  )
  year_e <- stats::setNames(
    stats::rnorm(4, 0, sqrt(0.4)),
    paste0("y", 1:4)
  )
  dat <- data.frame(
    id = as.character(kids$id),
    dam = as.character(kids$dam),
    nest = nest,
    year = year,
    stringsAsFactors = FALSE
  )
  dat$y_me <- 2 +
    a[dat$id] +
    nest_e[dat$nest] +
    year_e[dat$year] +
    stats::rnorm(n, 0, sqrt(0.7))
  dat$y_dm <- 2 +
    a[dat$id] +
    m[dat$dam] +
    stats::rnorm(n, 0, sqrt(0.7))
  list(ped = ped, dat = dat)
}

test_that("multi_effect bridge equals direct fit_multi_effect_reml (K = 3)", {
  hs_pin37_skip()
  fx <- hs_pin37_fixture()
  dat <- fx$dat

  fit <- hsquared(
    y_me ~ animal(1 | id, pedigree = fx$ped) + (1 | nest) + (1 | year),
    data = dat,
    family = stats::gaussian(),
    REML = TRUE,
    control = hs_control(
      engine = "julia",
      engine_control = list(target = "multi_effect")
    )
  )

  hs_pin37_assign_pedigree(fx$ped)
  JuliaCall::julia_assign("pin_y", dat$y_me)
  JuliaCall::julia_assign("pin_rec_id", dat$id)
  JuliaCall::julia_assign("pin_nest", dat$nest)
  JuliaCall::julia_assign("pin_year", dat$year)
  JuliaCall::julia_command(paste(
    "pin_n = length(pin_y);",
    "pin_X = ones(pin_n, 1);",
    "pin_Za = zeros(pin_n, length(pin_ped.ids));",
    "for (i, a) in enumerate(pin_rec_id); pin_Za[i, pin_ix[string(a)]] = 1.0; end;",
    "pin_lv(v) = sort(unique(v));",
    "pin_Zg(v) = [v[i] == l ? 1.0 : 0.0 for i in 1:length(v), l in pin_lv(v)];",
    "pin_Zn = pin_Zg(pin_nest); pin_Zy = pin_Zg(pin_year);",
    "pin_eff = [(pin_Za, pin_Ainv),",
    "(pin_Zn, Matrix{Float64}(I, size(pin_Zn, 2), size(pin_Zn, 2))),",
    "(pin_Zy, Matrix{Float64}(I, size(pin_Zy, 2), size(pin_Zy, 2)))];",
    "pin_fit = HSquared.fit_multi_effect_reml(pin_y, pin_X, pin_eff);"
  ))
  ref_sigmas <- JuliaCall::julia_eval(
    "collect(Float64, pin_fit.variance_components.sigmas)"
  )
  ref_e <- JuliaCall::julia_eval(
    "Float64(pin_fit.variance_components.sigma_e2)"
  )
  ref_ll <- JuliaCall::julia_eval("Float64(pin_fit.loglik)")
  ref_beta <- JuliaCall::julia_eval("collect(Float64, pin_fit.beta)")

  vc <- variance_components(fit)
  expect_equal(nrow(vc), 4L) # animal, nest, year, residual
  # Guard the guard: components are distinct, so a block-order slip cannot pass.
  expect_gt(max(abs(diff(ref_sigmas))), 1e-3)
  expect_true(fit$result$converged)
  expect_lt(max(abs(vc$estimate - c(ref_sigmas, ref_e))), 1e-8)
  expect_lt(abs(fit$result$loglik - ref_ll), 1e-8)
  expect_lt(max(abs(unname(fixef(fit)) - ref_beta)), 1e-8)
})

test_that("direct_maternal bridge equals direct fit_direct_maternal_reml (all components)", {
  hs_pin37_skip()
  fx <- hs_pin37_fixture()
  dat <- fx$dat

  fit <- hsquared(
    y_dm ~ animal(1 | id, pedigree = fx$ped) + maternal_genetic(1 | dam),
    data = dat,
    family = stats::gaussian(),
    REML = TRUE,
    control = hs_control(
      engine = "julia",
      engine_control = list(target = "direct_maternal")
    )
  )

  hs_pin37_assign_pedigree(fx$ped)
  JuliaCall::julia_assign("pin_y", dat$y_dm)
  JuliaCall::julia_assign("pin_rec_id", dat$id)
  JuliaCall::julia_assign("pin_rec_dam", dat$dam)
  JuliaCall::julia_command(paste(
    "pin_n = length(pin_y);",
    "pin_X = ones(pin_n, 1);",
    "pin_Zd = zeros(pin_n, length(pin_ped.ids));",
    "pin_Zm = zeros(pin_n, length(pin_ped.ids));",
    "for i in 1:pin_n; pin_Zd[i, pin_ix[string(pin_rec_id[i])]] = 1.0;",
    "pin_Zm[i, pin_ix[string(pin_rec_dam[i])]] = 1.0; end;",
    "pin_fit = HSquared.fit_direct_maternal_reml(pin_y, pin_X, pin_Zd, pin_Zm,",
    "pin_Ainv; ids = pin_ped.ids);"
  ))
  vcj <- function(f) {
    JuliaCall::julia_eval(sprintf("Float64(pin_fit.variance_components.%s)", f))
  }
  ref <- c(
    direct = vcj("sigma_ad"),
    maternal = vcj("sigma_am"),
    covariance = vcj("sigma_dm"),
    residual = vcj("sigma_e2")
  )
  ref_ll <- JuliaCall::julia_eval("Float64(pin_fit.loglik)")

  vc <- variance_components(fit)
  est <- stats::setNames(vc$estimate, vc$component)[names(ref)]
  # Guard the guard: the covariance is a real, non-zero quantity here.
  expect_gt(abs(ref[["covariance"]]), 1e-3)
  expect_true(fit$result$converged)
  expect_lt(max(abs(est - ref)), 1e-8)
  expect_lt(abs(fit$result$loglik - ref_ll), 1e-8)
})
