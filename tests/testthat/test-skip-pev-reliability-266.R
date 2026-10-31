# #266 (option 1): an opt-in `engine_control$skip_pev_reliability = TRUE`
# passes `skip_pev_reliability = true` to `HSquared.result_payload` on the
# pedigree routes, so the fit skips PEV and reliability. The default stays
# eager: the command a default fit sends must not change. Pure-R tests capture
# the Julia commands instead of running them.

hs_266opt_capture_commands <- function(fit_route) {
  sent <- character()
  testthat::local_mocked_bindings(
    hs_julia_bridge_available = function(...) TRUE,
    hs_julia_setup = function(...) invisible(NULL),
    hs_julia_assign_payload = function(...) invisible(NULL),
    .package = "hsquared"
  )
  testthat::local_mocked_bindings(
    julia_assign = function(...) invisible(NULL),
    julia_command = function(cmd, ...) {
      sent <<- c(sent, cmd)
      invisible(NULL)
    },
    julia_eval = function(...) stop("hs_266opt_captured"),
    .package = "JuliaCall"
  )
  payload <- structure(list(method = "REML"), class = "hs_bridge_payload")
  try(fit_route(payload), silent = TRUE)
  sent
}

hs_266opt_routes <- function(...) {
  list(
    dense = function(p) hsquared:::hs_fit_julia_payload(p, ...),
    sparse_reml = function(p) {
      hsquared:::hs_fit_julia_sparse_reml_payload(p, ...)
    },
    ai_reml = function(p) hsquared:::hs_fit_julia_ai_reml_payload(p, ...)
  )
}

test_that("default pedigree routes send the unchanged eager command (#266)", {
  default_routes <- hs_266opt_routes()
  explicit_false <- hs_266opt_routes(skip_pev_reliability = FALSE)
  for (name in names(default_routes)) {
    cmd <- hs_266opt_capture_commands(default_routes[[name]])
    expect_true(length(cmd) >= 2L, info = name)
    fit_cmd <- paste(cmd, collapse = "\n")
    expect_false(grepl("skip_pev_reliability", fit_cmd), info = name)
    expect_true(
      grepl("HSquared.result_payload(hsq_fit);", fit_cmd, fixed = TRUE),
      info = name
    )
    expect_true(
      grepl(
        "HSquared.breeding_values_plot_data(hsq_fit)",
        fit_cmd,
        fixed = TRUE
      ),
      info = name
    )
    # Explicit FALSE sends byte-identical commands to the default.
    expect_identical(
      hs_266opt_capture_commands(explicit_false[[name]]),
      cmd,
      info = name
    )
  }
})

test_that("skip_pev_reliability = TRUE asks the engine to skip PEV/reliability (#266)", {
  routes <- hs_266opt_routes(skip_pev_reliability = TRUE)
  for (name in names(routes)) {
    cmd <- paste(hs_266opt_capture_commands(routes[[name]]), collapse = "\n")
    expect_true(
      grepl(
        "HSquared.result_payload(hsq_fit; skip_pev_reliability = true);",
        cmd,
        fixed = TRUE
      ),
      info = name
    )
    # An engine without the keyword is an error, never a silent eager fit.
    expect_true(
      grepl(":skip_pev_reliability in Base.kwarg_decl(m)", cmd, fixed = TRUE),
      info = name
    )
    # No bridge-side recomputation: neither the older-engine PEV/reliability
    # enrichment nor the PEV-based breeding-value plot data.
    expect_false(
      grepl("HSquared.prediction_error_variance(hsq_fit)", cmd, fixed = TRUE),
      info = name
    )
    expect_false(
      grepl("HSquared.breeding_values_plot_data", cmd, fixed = TRUE),
      info = name
    )
    expect_true(
      grepl(
        "HSquared.variance_components_plot_data(hsq_fit)",
        cmd,
        fixed = TRUE
      ),
      info = name
    )
  }
})

test_that("skip_pev_reliability must be a single TRUE/FALSE (#266)", {
  for (bad in list(NA, "yes", c(TRUE, FALSE), 1)) {
    expect_error(
      hsquared:::hs_validate_skip_pev_reliability(bad),
      "skip_pev_reliability"
    )
  }
  expect_false(hsquared:::hs_validate_skip_pev_reliability(FALSE))
  expect_true(hsquared:::hs_validate_skip_pev_reliability(TRUE))
})

test_that("skip_pev_reliability is honoured only by the pedigree routes (#266)", {
  ctrl <- hs_control(
    engine = "julia",
    engine_control = list(skip_pev_reliability = TRUE)
  )
  for (target in c("fit_animal_model", "sparse_reml", "ai_reml")) {
    expect_identical(
      hsquared:::hs_engine_control_forwarding(ctrl, target),
      list(skip_pev_reliability = TRUE),
      info = target
    )
  }
  expect_error(
    hsquared:::hs_engine_control_forwarding(ctrl, "genomic"),
    "skip_pev_reliability"
  )
})

test_that("hsquared() passes skip_pev_reliability through on the default route (#266)", {
  got <- NULL
  testthat::local_mocked_bindings(
    hs_julia_bridge_available = function(...) TRUE,
    hs_fit_julia_ai_reml_payload = function(payload, ...) {
      got <<- list(...)
      stop("hs_266opt_routed")
    },
    .package = "hsquared"
  )
  ped <- data.frame(
    id = c("a", "b", "c", "d"),
    sire = c(NA, NA, "a", "a"),
    dam = c(NA, NA, "b", "b")
  )
  dat <- data.frame(id = ped$id, y = c(1, 2, 3, 4))
  expect_error(
    hsquared(
      y ~ animal(1 | id, pedigree = ped),
      data = dat,
      control = hs_control(engine_control = list(skip_pev_reliability = TRUE))
    ),
    "hs_266opt_routed"
  )
  expect_true(got$skip_pev_reliability)

  expect_error(
    hsquared(y ~ animal(1 | id, pedigree = ped), data = dat),
    "hs_266opt_routed"
  )
  expect_false(got$skip_pev_reliability)
})

hs_266opt_live_data <- function() {
  ped <- hs_sim_pedigree(n_founder = 10, n_per_gen = 10, n_gen = 2, seed = 266)
  set.seed(266)
  dat <- data.frame(
    id = ped$id,
    y = stats::rnorm(nrow(ped), 10, 1),
    stringsAsFactors = FALSE
  )
  list(ped = ped, dat = dat)
}

hs_266opt_skip_without_engine_keyword <- function() {
  hs_skip_live_julia()
  testthat::skip_if_not(
    hsquared:::hs_julia_bridge_available(),
    "JuliaCall, Julia, and local HSquared.jl are required for live bridge smoke."
  )
  hsquared:::hs_julia_setup(hsquared:::hs_default_julia_project())
  has_kw <- JuliaCall::julia_eval(paste(
    "any(m -> :skip_pev_reliability in Base.kwarg_decl(m),",
    "methods(HSquared.result_payload))"
  ))
  testthat::skip_if_not(
    isTRUE(has_kw),
    "HSquared.jl lacks result_payload(...; skip_pev_reliability) (HSquared.jl #266 twin PR)."
  )
}

test_that("default live fit still carries eager PEV/reliability (#266)", {
  hs_skip_live_julia()
  testthat::skip_if_not(
    hsquared:::hs_julia_bridge_available(),
    "JuliaCall, Julia, and local HSquared.jl are required for live bridge smoke."
  )
  d <- hs_266opt_live_data()
  ped <- d$ped
  fit <- hsquared(y ~ animal(1 | id, pedigree = ped), data = d$dat)
  pev_engine <- JuliaCall::julia_eval(
    "collect(Float64, HSquared.prediction_error_variance(hsq_fit; method = :auto).values)"
  )
  expect_equal(
    prediction_error_variance(fit)$value,
    pev_engine,
    tolerance = 1e-10
  )
  expect_length(reliability(fit)$value, nrow(ped))
  expect_false(is.null(fit$result$breeding_values_plot_data))
})

test_that("live skip_pev_reliability fit drops only PEV/reliability (#266)", {
  hs_266opt_skip_without_engine_keyword()
  d <- hs_266opt_live_data()
  ped <- d$ped
  for (ec in list(
    list(),
    list(target = "sparse_reml"),
    list(target = "ai_reml")
  )) {
    info <- if (length(ec)) ec$target else "default"
    engine <- if (length(ec)) "julia" else "fit"
    eager <- hsquared(
      y ~ animal(1 | id, pedigree = ped),
      data = d$dat,
      control = hs_control(engine = engine, engine_control = ec)
    )
    explicit_false <- hsquared(
      y ~ animal(1 | id, pedigree = ped),
      data = d$dat,
      control = hs_control(
        engine = engine,
        engine_control = c(ec, list(skip_pev_reliability = FALSE))
      )
    )
    expect_equal(explicit_false$result, eager$result, info = info)

    lean <- hsquared(
      y ~ animal(1 | id, pedigree = ped),
      data = d$dat,
      control = hs_control(
        engine = engine,
        engine_control = c(ec, list(skip_pev_reliability = TRUE))
      )
    )
    expect_null(lean$result$prediction_error_variance)
    expect_null(lean$result$reliability)
    expect_null(lean$result$breeding_values_plot_data)
    expect_error(reliability(lean), "skip_pev_reliability")
    expect_error(prediction_error_variance(lean), "skip_pev_reliability")
    expect_equal(
      variance_components(lean),
      variance_components(eager),
      info = info
    )
    expect_equal(breeding_values(lean), breeding_values(eager), info = info)
  }
})

test_that("an engine without the keyword errors instead of fitting eagerly (#266)", {
  hs_skip_live_julia()
  testthat::skip_if_not(
    hsquared:::hs_julia_bridge_available(),
    "JuliaCall, Julia, and local HSquared.jl are required for live bridge smoke."
  )
  hsquared:::hs_julia_setup(hsquared:::hs_default_julia_project())
  has_kw <- JuliaCall::julia_eval(paste(
    "any(m -> :skip_pev_reliability in Base.kwarg_decl(m),",
    "methods(HSquared.result_payload))"
  ))
  testthat::skip_if(isTRUE(has_kw), "HSquared.jl already has the keyword.")
  d <- hs_266opt_live_data()
  ped <- d$ped
  expect_error(
    hsquared(
      y ~ animal(1 | id, pedigree = ped),
      data = d$dat,
      control = hs_control(engine_control = list(skip_pev_reliability = TRUE))
    ),
    "skip_pev_reliability",
    class = "hsquared_julia_error"
  )
})
