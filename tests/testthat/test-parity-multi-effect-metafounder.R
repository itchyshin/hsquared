# Cross-engine parity pins (PARITY-MAP cells 13 and 31): the R bridge must
# return the value a DIRECT HSquared.jl call returns for the same inputs.
#
#   * Cell 13, multi_effect (K = 3 independent blocks): the bridge fit vs a
#     direct `HSquared.fit_multi_effect_reml`, started from the same point
#     (all variances 1, passed to BOTH sides so the two optimisers walk the
#     same path; default starts differ by ~1e-4 relative on flat surfaces).
#     The pinned design converges in the interior (no boundary exit, cf.
#     HSquared.jl#426), so the pin is on an identified optimum.
#   * Cell 31, metafounder: the bridge at a NON-ZERO Gamma vs a direct
#     `HSquared.metafounder_animal_model` (fixed effects, BLUPs, fitted
#     values). The Gamma = 0 reduction is already covered elsewhere.
#
# Both legs are live and skip-guarded (hs_skip_live_julia()).

hs_parity_skip_unless_bridge <- function() {
  hs_skip_live_julia()
  testthat::skip_if_not(
    hsquared:::hs_julia_bridge_available(),
    "JuliaCall, Julia, and local HSquared.jl are required for a live parity pin."
  )
}

hs_parity_ped30 <- function() {
  utils::read.csv(
    testthat::test_path(
      "fixtures",
      "animal_model_engine_parity",
      "pedigree.csv"
    ),
    stringsAsFactors = FALSE,
    na.strings = ""
  )
}

# 30 animals x 4 records; random herd (8) and year (5) membership.
hs_parity_me_data <- function(ped, seed = 1317) {
  set.seed(seed)
  dat <- data.frame(id = rep(ped$id, each = 4), stringsAsFactors = FALSE)
  dat$herd <- paste0("h", sample(1:8, nrow(dat), TRUE))
  dat$yr <- paste0("y", sample(1:5, nrow(dat), TRUE))
  ph <- hs_sim_genedrop_phenotypes(
    ped,
    sigma_a2 = 1,
    sigma_e2 = 0.5,
    seed = seed
  )
  herd_eff <- stats::setNames(stats::rnorm(8, 0, 1), paste0("h", 1:8))
  yr_eff <- stats::setNames(stats::rnorm(5, 0, 0.8), paste0("y", 1:5))
  dat$y <- ph$y[match(dat$id, ph$id)] +
    herd_eff[dat$herd] +
    yr_eff[dat$yr] +
    stats::rnorm(nrow(dat), 0, 0.7)
  dat
}

hs_parity_indicator <- function(x, levels) {
  Z <- matrix(0, length(x), length(levels))
  Z[cbind(seq_along(x), match(x, levels))] <- 1
  Z
}

test_that("multi_effect (K = 3) bridge matches direct fit_multi_effect_reml, start-matched [live, cell 13]", {
  hs_parity_skip_unless_bridge()

  ped <- hs_parity_ped30()
  dat <- hs_parity_me_data(ped)

  fit <- suppressWarnings(hsquared(
    y ~ animal(1 | id, pedigree = ped) + (1 | herd) + (1 | yr),
    data = dat,
    control = hs_control(
      engine = "julia",
      engine_control = list(target = "multi_effect", initial = c(1, 1, 1, 1))
    )
  ))
  expect_true(isTRUE(fit$result$converged))

  # Direct engine call: same data, same start, no bridge.
  herds <- sort(unique(dat$herd))
  yrs <- sort(unique(dat$yr))
  JuliaCall::julia_assign("pm_y", dat$y)
  JuliaCall::julia_assign("pm_X", matrix(1, nrow(dat), 1))
  JuliaCall::julia_assign("pm_Za", hs_parity_indicator(dat$id, ped$id))
  JuliaCall::julia_assign("pm_Zh", hs_parity_indicator(dat$herd, herds))
  JuliaCall::julia_assign("pm_Zy", hs_parity_indicator(dat$yr, yrs))
  JuliaCall::julia_assign("pm_pid", ped$id)
  JuliaCall::julia_assign("pm_sire", hsquared:::hs_parent_for_julia(ped$sire))
  JuliaCall::julia_assign("pm_dam", hsquared:::hs_parent_for_julia(ped$dam))
  JuliaCall::julia_command(paste(
    "pm_ped = HSquared.normalize_pedigree(pm_pid, pm_sire, pm_dam);",
    "collect(String, pm_ped.ids) == pm_pid || error(\"pedigree order\");",
    "pm_Ainv = Matrix(HSquared.pedigree_inverse(pm_ped));",
    "pm_Ih = Matrix{Float64}(HSquared.LinearAlgebra.I, size(pm_Zh, 2), size(pm_Zh, 2));",
    "pm_Iy = Matrix{Float64}(HSquared.LinearAlgebra.I, size(pm_Zy, 2), size(pm_Zy, 2));",
    "pm_fit = HSquared.fit_multi_effect_reml(pm_y, pm_X,",
    "[(pm_Za, pm_Ainv), (pm_Zh, pm_Ih), (pm_Zy, pm_Iy)];",
    "initial = [1.0, 1.0, 1.0, 1.0]);"
  ))
  direct_converged <- JuliaCall::julia_eval("pm_fit.converged")
  direct_vc <- c(
    JuliaCall::julia_eval(
      "collect(Float64, pm_fit.variance_components.sigmas)"
    ),
    JuliaCall::julia_eval("Float64(pm_fit.variance_components.sigma_e2)")
  )
  direct_beta <- JuliaCall::julia_eval("collect(Float64, pm_fit.beta)")

  # The direct fit must itself be an interior, converged optimum, otherwise
  # this pin would be comparing boundary exits (HSquared.jl#426).
  expect_true(isTRUE(direct_converged))
  expect_true(all(direct_vc / sum(direct_vc) > 1e-3))

  vc <- variance_components(fit)
  expect_identical(vc$component, c("animal", "herd", "yr", "residual"))
  expect_equal(vc$estimate, direct_vc, tolerance = 1e-8)
  expect_equal(
    unname(fit$result$fixed_effects),
    direct_beta,
    tolerance = 1e-8
  )
})

test_that("metafounder bridge at non-zero Gamma matches direct metafounder_animal_model [live, cell 31]", {
  hs_parity_skip_unless_bridge()

  ped <- hs_parity_ped30()
  ph <- utils::read.csv(
    testthat::test_path(
      "fixtures",
      "animal_model_engine_parity",
      "phenotypes.csv"
    ),
    stringsAsFactors = FALSE
  )
  founders <- ped$id[is.na(ped$sire) & is.na(ped$dam)]
  # Two metafounders; founders alternate between them. Non-founders get "".
  mf_group <- stats::setNames(rep("", nrow(ped)), ped$id)
  mf_group[founders] <- rep(c("M1", "M2"), length.out = length(founders))
  Gamma <- matrix(
    c(0.4, 0.1, 0.1, 0.3),
    nrow = 2,
    dimnames = list(c("M1", "M2"), c("M1", "M2"))
  )
  vc <- c(sigma_a2 = 0.6, sigma_e2 = 0.4)

  fit <- hsquared(
    y ~ sex +
      metafounder(1 | id, pedigree = ped, group = mf_group, Gamma = Gamma),
    data = ph,
    control = hs_control(
      engine = "julia",
      engine_control = list(target = "metafounder", variance_components = vc)
    )
  )
  expect_identical(fit$result$diagnostics$gamma_source, "supplied")

  # Direct engine call from the same raw inputs.
  X <- stats::model.matrix(~sex, ph)
  Z <- hs_parity_indicator(ph$id, ped$id)
  JuliaCall::julia_assign("pm_y", ph$y)
  JuliaCall::julia_assign("pm_X", X)
  JuliaCall::julia_assign("pm_Z", Z)
  JuliaCall::julia_assign("pm_pid", ped$id)
  JuliaCall::julia_assign("pm_sire", hsquared:::hs_parent_for_julia(ped$sire))
  JuliaCall::julia_assign("pm_dam", hsquared:::hs_parent_for_julia(ped$dam))
  JuliaCall::julia_assign("pm_group", unname(mf_group))
  JuliaCall::julia_assign("pm_Gvec", as.numeric(Gamma))
  JuliaCall::julia_assign("pm_sa", vc[["sigma_a2"]])
  JuliaCall::julia_assign("pm_se", vc[["sigma_e2"]])
  JuliaCall::julia_command(paste(
    "pm_ped = HSquared.normalize_pedigree(pm_pid, pm_sire, pm_dam);",
    "collect(String, pm_ped.ids) == pm_pid || error(\"pedigree order\");",
    "pm_G = reshape(collect(Float64, pm_Gvec), 2, 2);",
    "pm_mme = HSquared.metafounder_animal_model(pm_y, pm_X, pm_Z, pm_ped,",
    "pm_group, pm_G, pm_sa, pm_se; ids = pm_ped.ids);"
  ))
  direct_beta <- JuliaCall::julia_eval(
    "collect(Float64, HSquared.fixed_effects(pm_mme))"
  )
  direct_u <- JuliaCall::julia_eval(
    "collect(Float64, HSquared.breeding_values(pm_mme).values)"
  )
  direct_fit <- JuliaCall::julia_eval(
    "collect(Float64, HSquared.fitted_values(pm_mme))"
  )

  expect_equal(unname(fit$result$fixed_effects), direct_beta, tolerance = 1e-10)
  expect_equal(
    fit$result$random_effects$metafounder$value,
    direct_u,
    tolerance = 1e-10
  )
  expect_equal(fit$result$predictions$.fitted, direct_fit, tolerance = 1e-10)

  # Gamma must actually reach the engine: the Gamma = 0 solve differs.
  JuliaCall::julia_command(paste(
    "pm_mme0 = HSquared.metafounder_animal_model(pm_y, pm_X, pm_Z, pm_ped,",
    "pm_group, zeros(2, 2), pm_sa, pm_se; ids = pm_ped.ids);"
  ))
  u0 <- JuliaCall::julia_eval(
    "collect(Float64, HSquared.breeding_values(pm_mme0).values)"
  )
  expect_gt(max(abs(direct_u - u0)), 1e-3)
})
