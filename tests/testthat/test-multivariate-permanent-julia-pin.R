# Parity pin for cbind() + permanent() (hsquared #237, parity cell 22).
#
# The bridge result is confronted with a DIRECT call to
# HSquared.fit_multivariate_repeatability_reml (HSquared.jl#398) whose inputs
# (Y, X, Z, Ainv) are rebuilt in Julia from the raw data, not from the R
# payload. Same estimator, same data, same start, deterministic Nelder-Mead:
# a marshalling / ordering / sparse hand-off pin. Tolerances are absolute and
# are not to be widened.

hs_pin22_direct_julia <- function(fx, initial = NULL) {
  JuliaCall::julia_assign("pin_Y", as.matrix(fx$dat[c("y1", "y2")]))
  JuliaCall::julia_assign("pin_rec_id", fx$dat$id)
  JuliaCall::julia_assign("pin_id", fx$ped$id)
  JuliaCall::julia_assign(
    "pin_sire",
    ifelse(is.na(fx$ped$sire), "0", fx$ped$sire)
  )
  JuliaCall::julia_assign("pin_dam", ifelse(is.na(fx$ped$dam), "0", fx$ped$dam))
  kw <- ""
  if (!is.null(initial)) {
    JuliaCall::julia_assign("pin_G0", initial$G0)
    JuliaCall::julia_assign("pin_P0", initial$P0)
    JuliaCall::julia_assign("pin_R0", initial$R0)
    kw <- "initial = (G0 = pin_G0, P0 = pin_P0, R0 = pin_R0),"
  }
  JuliaCall::julia_command(paste(
    "pin_ped = HSquared.normalize_pedigree(pin_id, pin_sire, pin_dam);",
    "pin_Ainv = HSquared.pedigree_inverse(pin_ped);",
    "pin_ix = Dict(string(a) => k for (k, a) in enumerate(pin_ped.ids));",
    "pin_Z = zeros(length(pin_rec_id), length(pin_ped.ids));",
    "for (i, a) in enumerate(pin_rec_id); pin_Z[i, pin_ix[string(a)]] = 1.0; end;",
    "pin_X = ones(length(pin_rec_id), 1);",
    "pin_fit = HSquared.fit_multivariate_repeatability_reml(",
    "pin_Y, pin_X, pin_Z, pin_Ainv;",
    kw,
    "iterations = 2000, ids = pin_ped.ids, traits = [\"y1\", \"y2\"]);"
  ))
  list(
    G0 = JuliaCall::julia_eval("Matrix{Float64}(pin_fit.genetic_covariance)"),
    P0 = JuliaCall::julia_eval("Matrix{Float64}(pin_fit.permanent_covariance)"),
    R0 = JuliaCall::julia_eval("Matrix{Float64}(pin_fit.residual_covariance)"),
    h2 = JuliaCall::julia_eval("collect(Float64, pin_fit.heritability)"),
    rep = JuliaCall::julia_eval("collect(Float64, pin_fit.repeatability)"),
    beta = JuliaCall::julia_eval("Matrix{Float64}(pin_fit.beta)"),
    loglik = JuliaCall::julia_eval("Float64(pin_fit.loglik)")
  )
}

hs_pin22_fit <- function(fx, initial = NULL) {
  ec <- list(target = "multivariate_repeatability", iterations = 2000L)
  if (!is.null(initial)) {
    ec$initial <- initial
  }
  suppressWarnings(hsquared(
    cbind(y1, y2) ~ animal(1 | id, pedigree = fx$ped) + permanent(1 | id),
    data = fx$dat,
    family = stats::gaussian(),
    REML = TRUE,
    control = hs_control(engine = "julia", engine_control = ec)
  ))
}

hs_pin22_expect <- function(fit, jl, tol = 1e-8) {
  expect_true(fit$result$converged)
  expect_lt(max(abs(unname(genetic_covariance(fit)) - jl$G0)), tol)
  expect_lt(max(abs(unname(fit$result$permanent_covariance) - jl$P0)), tol)
  expect_lt(max(abs(unname(residual_covariance(fit)) - jl$R0)), tol)
  expect_lt(abs(fit$result$loglik - jl$loglik), tol)
  expect_lt(max(abs(heritability(fit)$estimate - jl$h2)), tol)
  expect_lt(max(abs(repeatability(fit)$estimate - jl$rep)), tol)
  expect_lt(
    max(abs(matrix(fixef(fit)$estimate, nrow = nrow(jl$beta)) - jl$beta)),
    tol
  )
}

test_that("cbind + permanent bridge equals direct fit_multivariate_repeatability_reml", {
  hs_skip_live_julia()
  testthat::skip_on_cran()
  skip_if_not(
    hsquared:::hs_julia_bridge_available(),
    "JuliaCall, Julia, and local HSquared.jl are required."
  )
  hsquared:::hs_julia_setup(hsquared:::hs_default_julia_project())
  skip_if_not(
    isTRUE(JuliaCall::julia_eval(
      "isdefined(HSquared, :fit_multivariate_repeatability_reml)"
    )),
    "Need fit_multivariate_repeatability_reml (HSquared.jl#398)."
  )

  fx <- hs_237_simulate_mvpe(seed = 20260926L)
  start <- list(G0 = diag(2), P0 = diag(2), R0 = diag(2))

  # Start-matched: both sides begin from all-variances-1 identity matrices.
  jl <- hs_pin22_direct_julia(fx, initial = start)
  fit <- hs_pin22_fit(fx, initial = start)
  # Guard the guard: G0 and P0 differ, so a G0/P0 swap cannot pass.
  expect_gt(max(abs(jl$P0 - jl$G0)), 1e-3)
  hs_pin22_expect(fit, jl)

  # Default start: the bridge sends no `initial` here, so it uses the engine's
  # own data-scaled default; a direct call with no `initial` is the same start.
  jl0 <- hs_pin22_direct_julia(fx)
  fit0 <- hs_pin22_fit(fx)
  hs_pin22_expect(fit0, jl0)
})
