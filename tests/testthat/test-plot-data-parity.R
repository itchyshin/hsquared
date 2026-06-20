# Live R<->engine parity guard for the plotting plot-data contract
# (docs/design/24-plotting-standard.md §5/§7; twin HSquared.jl#93). Skip-guarded
# on the local HSquared.jl bridge. As preparers land engine-side, add a parity
# case here so the R `autoplot` recompute path and the engine `*_plot_data`
# preparer cannot drift apart. (A Julia-free consumer-parity test -- payload vs
# recompute tidy frames -- lives in test-autoplot.R and always runs.)

test_that("genetic_correlation_plot_data engine preparer matches cov2cor + h2 [live]", {
  testthat::skip_on_cran()
  testthat::skip_if_not(
    hsquared:::hs_julia_bridge_available(),
    "JuliaCall, Julia, and local HSquared.jl are required for the live plot-data parity test."
  )
  hsquared:::hs_julia_setup(hsquared:::hs_default_julia_project())

  g_cov <- matrix(
    c(
      2.0,
      0.6,
      0.2,
      0.6,
      1.0,
      0.1,
      0.2,
      0.1,
      0.5
    ),
    nrow = 3,
    byrow = TRUE
  )
  h2 <- c(0.05, 0.40, 0.30)
  JuliaCall::julia_assign("G_par", g_cov)
  JuliaCall::julia_assign("h_par", h2)
  JuliaCall::julia_command(
    "pd_par = HSquared.genetic_correlation_plot_data(G_par; heritabilities = h_par);"
  )
  corr_engine <- JuliaCall::julia_eval(
    "Matrix{Float64}(pd_par.genetic_correlations)"
  )
  h2_engine <- JuliaCall::julia_eval("collect(Float64, pd_par.heritabilities)")
  rot_engine <- JuliaCall::julia_eval("pd_par.rotation_invariant")

  # The engine's `genetic_correlations` is D^-1 G D^-1 == stats::cov2cor(G). The R
  # autoplot consumer trusts this contract for BOTH paths it can take: the
  # bridge-attached payload and the recompute fallback (the fit-stored
  # `genetic_correlation`, the same engine function evaluated at fit time).
  expect_equal(corr_engine, unname(stats::cov2cor(g_cov)), tolerance = 1e-12)
  expect_equal(h2_engine, h2, tolerance = 1e-12)
  expect_true(isTRUE(rot_engine))
})

test_that("autoplot consumes a live-marshalled genetic_correlation_plot_data payload [live]", {
  testthat::skip_on_cran()
  testthat::skip_if_not(
    hsquared:::hs_julia_bridge_available(),
    "JuliaCall, Julia, and local HSquared.jl are required for the live plot-data parity test."
  )
  hsquared:::hs_julia_setup(hsquared:::hs_default_julia_project())

  g_cov <- matrix(
    c(
      2.0,
      0.6,
      0.2,
      0.6,
      1.0,
      0.1,
      0.2,
      0.1,
      0.5
    ),
    nrow = 3,
    byrow = TRUE
  )
  h2 <- c(0.05, 0.40, 0.30)
  JuliaCall::julia_assign("G_par2", g_cov)
  JuliaCall::julia_assign("h_par2", h2)
  JuliaCall::julia_command(paste(
    "pd2 = HSquared.genetic_correlation_plot_data(G_par2;",
    "traits = [\"t1\", \"t2\", \"t3\"], heritabilities = h_par2);"
  ))
  # Marshal the whole NamedTuple into R exactly as a bridge attachment would, to
  # check JuliaCall hands back a real R matrix (not a flattened vector) and that
  # the consumer unpack path works end-to-end on live engine output.
  pd_list <- JuliaCall::julia_eval(paste(
    "(traits = collect(String, pd2.traits),",
    "genetic_correlations = Matrix{Float64}(pd2.genetic_correlations),",
    "heritabilities = collect(Float64, pd2.heritabilities),",
    "rotation_invariant = pd2.rotation_invariant)"
  ))
  expect_true(is.matrix(pd_list$genetic_correlations))
  expect_equal(dim(pd_list$genetic_correlations), c(3L, 3L))

  fit <- structure(
    list(result = list(genetic_correlation_plot_data = pd_list)),
    class = "hsquared_fit"
  )
  p <- autoplot(fit, "g_matrix")
  cc <- unname(stats::cov2cor(g_cov))
  v_12 <- p$data$value[
    as.character(p$data$row) == "t1" & as.character(p$data$col) == "t2"
  ]
  expect_equal(v_12, cc[1, 2], tolerance = 1e-10)
  # t1 (h2 = 0.05 < 0.1) flags its off-diagonal cells.
  off <- p$data[as.character(p$data$row) != as.character(p$data$col), ]
  expect_true(any(off$low))
})

test_that("variance_components_plot_data engine preparer feeds the variance forest [live]", {
  testthat::skip_on_cran()
  testthat::skip_if_not(
    hsquared:::hs_julia_bridge_available(),
    "JuliaCall, Julia, and local HSquared.jl are required for the live plot-data parity test."
  )

  # A clean ~100-animal pedigree with simulated h2 = 0.4 so fit_ai_reml converges
  # to interior variance components (toy 3-5 animal datasets pin sigma_a2 -> 0).
  ped <- hs_sim_pedigree(n_founder = 20, n_per_gen = 40, n_gen = 2, seed = 7)
  dat <- hs_sim_genedrop_phenotypes(
    ped,
    sigma_a2 = 0.4,
    sigma_e2 = 0.6,
    seed = 7
  )
  fit <- hsquared(
    y ~ animal(1 | id, pedigree = ped),
    data = dat,
    family = stats::gaussian(),
    REML = TRUE
  )
  # The default engine = "fit" path leaves the Julia AnimalModelFit as `hsq_fit`
  # in the session; call the Set-B preparer on it and marshal as the bridge would.
  vcpd <- JuliaCall::julia_eval(paste(
    "let p = HSquared.variance_components_plot_data(hsq_fit);",
    "(term = collect(String, p.term), estimate = collect(Float64, p.estimate),",
    "lo = collect(Float64, p.lo), hi = collect(Float64, p.hi),",
    "panel = collect(String, p.panel), interval_status = p.interval_status); end"
  ))
  # Engine field names match the consumer's contract, and the estimates equal the
  # fit's variance components / heritability.
  expect_equal(vcpd$term, c("sigma_a2", "sigma_e2", "h2"))
  expect_equal(
    vcpd$estimate[1:2],
    variance_components(fit)$estimate,
    tolerance = 1e-8
  )

  fit2 <- structure(
    list(result = list(variance_components_plot_data = vcpd)),
    class = "hsquared_fit"
  )
  p <- autoplot(fit2, "variance")
  expect_s3_class(p, "ggplot")
  expect_true(all(
    c("sigma_a2", "sigma_e2", "h2") %in% as.character(p$data$term)
  ))
  expect_equal(
    p$data$estimate[as.character(p$data$term) == "sigma_a2"],
    vcpd$estimate[1],
    tolerance = 1e-10
  )

  # The preparer ships `lo`/`hi` as NaN where the interval is unavailable; confirm
  # a Julia Float64 NaN survives the JuliaCall bridge as R NaN (positions 1/3),
  # while a finite value passes through (position 2). The consumer turns the NaN
  # into NA -> no whisker, and keeps the finite one.
  mixed <- JuliaCall::julia_eval("collect(Float64, [NaN, 1.0, NaN])")
  expect_true(is.nan(mixed[1]))
  expect_false(is.nan(mixed[2]))
  fit_nan <- structure(
    list(
      result = list(
        variance_components_plot_data = list(
          term = c("sigma_a2", "sigma_e2", "h2"),
          estimate = c(0.5, 0.5, 0.4),
          lo = mixed,
          hi = mixed,
          panel = c(
            "variance components",
            "variance components",
            "heritability"
          ),
          interval_status = "none"
        )
      )
    ),
    class = "hsquared_fit"
  )
  lo_out <- autoplot(fit_nan, "variance")$data$lo
  expect_true(all(is.na(lo_out[c(1, 3)]))) # engine NaN -> R NA
  expect_equal(lo_out[2], 1.0) # finite value survives
})
