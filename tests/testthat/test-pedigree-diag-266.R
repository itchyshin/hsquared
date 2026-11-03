# #266: every pedigree-rows route hands the engine relationship_diag = 1 + F,
# so `reliability()` skips a selected inverse of Ainv. Pure-R: the Julia
# command each route sends is captured instead of run.

hs_266_capture_command <- function(fit_route) {
  sent <- NULL
  testthat::local_mocked_bindings(
    hs_julia_bridge_available = function(...) TRUE,
    hs_julia_setup = function(...) invisible(NULL),
    hs_julia_assign_payload = function(...) invisible(NULL),
    .package = "hsquared"
  )
  testthat::local_mocked_bindings(
    julia_assign = function(...) invisible(NULL),
    julia_command = function(cmd, ...) {
      sent <<- cmd
      stop("hs_266_captured")
    },
    .package = "JuliaCall"
  )
  payload <- structure(list(method = "REML"), class = "hs_bridge_payload")
  try(fit_route(payload), silent = TRUE)
  sent
}

test_that("pedigree routes send relationship_diag = 1 + F (#266)", {
  routes <- list(
    dense = function(p) hsquared:::hs_fit_julia_payload(p),
    sparse_reml = function(p) hsquared:::hs_fit_julia_sparse_reml_payload(p),
    ai_reml = function(p) hsquared:::hs_fit_julia_ai_reml_payload(p),
    henderson_mme = function(p) {
      hsquared:::hs_fit_julia_henderson_mme_payload(
        p,
        variance_components = c(sigma_a2 = 1, sigma_e2 = 1)
      )
    }
  )
  for (name in names(routes)) {
    cmd <- hs_266_capture_command(routes[[name]])
    expect_type(cmd, "character")
    expect_true(
      grepl(hsquared:::hs_julia_pedigree_diag_cmd, cmd, fixed = TRUE),
      info = name
    )
    expect_true(grepl("hsq_diag_kw...", cmd, fixed = TRUE), info = name)
  }
})

test_that("dense and supplied-variance routes carry 1 + F, values unchanged (#266)", {
  hs_skip_live_julia()
  testthat::skip_if_not(
    hsquared:::hs_julia_bridge_available(),
    "JuliaCall, Julia, and local HSquared.jl are required for live bridge smoke."
  )

  base <- hs_sim_pedigree(n_founder = 10, n_per_gen = 10, n_gen = 1, seed = 266)
  ped <- rbind(
    base,
    data.frame(
      id = c("x", "y", "z1", "z2", "z3"),
      sire = c("1", "1", "x", "x", "x"),
      dam = c("6", "6", "y", "y", "y"),
      stringsAsFactors = FALSE
    )
  )
  set.seed(266)
  dat <- data.frame(
    id = ped$id,
    y = stats::rnorm(nrow(ped), 10, 1),
    stringsAsFactors = FALSE
  )
  vc <- c(sigma_a2 = 0.5, sigma_e2 = 0.5)
  routes <- list(
    dense = list(initial = vc),
    henderson_mme = list(target = "henderson_mme", variance_components = vc)
  )

  for (name in names(routes)) {
    fit <- hsquared(
      y ~ animal(1 | id, pedigree = ped),
      data = dat,
      family = stats::gaussian(),
      control = hs_control(engine = "julia", engine_control = routes[[name]])
    )
    carried <- JuliaCall::julia_eval(
      if (identical(name, "dense")) {
        "hsq_fit.spec.relationship_diag"
      } else {
        "hsq_spec.relationship_diag"
      }
    )
    expect_equal(
      carried,
      JuliaCall::julia_eval("1 .+ HSquared.inbreeding_coefficients(hsq_ped)"),
      tolerance = 1e-12,
      info = name
    )
    expect_gt(max(carried), 1.2)

    # Selected-inverse oracle: the carried diagonal must not move reliability.
    oracle <- JuliaCall::julia_eval(paste0(
      "collect(Float64, HSquared.reliability(",
      if (identical(name, "dense")) "hsq_fit" else "hsq_mme",
      "; method = :selinv).values)"
    ))
    expect_equal(reliability(fit)$value, oracle, tolerance = 1e-8, info = name)
  }
})
