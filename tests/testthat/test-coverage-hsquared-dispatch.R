# Coverage lane for R/hsquared.R: the front-door `hsquared()` router.
#
# Everything here runs without Julia. The Julia fitters are replaced by
# recording stubs so that what is exercised and asserted is the router itself:
# which fitter a call reaches, which engine_control values it forwards
# (documented defaults, and pass-through of every user-supplied key), and
# which pre-bridge guard fires with which condition class and message. The
# bridge (R/julia-bridge.R) is deliberately not tested here.

hs_cov_ped <- data.frame(
  id = letters[1:8],
  sire = c(NA, NA, NA, NA, "a", "a", "c", "c"),
  dam = c(NA, NA, NA, NA, "b", "b", "d", "d"),
  stringsAsFactors = FALSE
)
ped <- hs_cov_ped

# One record per individual: keeps the repeated-records warning silent.
dat <- data.frame(
  y = c(1.2, 0.8, 2.1, 1.9),
  y2 = c(2.2, 1.8, 3.1, 0.9),
  id = c("e", "f", "g", "h"),
  dam = c("b", "b", "d", "d"),
  grp = c("n1", "n1", "n2", "n2"),
  age = c(1, 2, 3, 4),
  stringsAsFactors = FALSE
)

# Two records per individual.
rdat <- data.frame(
  y = c(1.2, 0.8, 2.1, 1.9, 1.5, 2.3, 1.7, 0.9),
  y2 = c(2.2, 1.8, 3.1, 0.9, 1.0, 2.0, 3.0, 4.0),
  id = rep(c("e", "f", "g", "h"), 2),
  stringsAsFactors = FALSE
)

mrk <- matrix(
  c(0, 1, 2, 1, 0, 2, 1, 1, 0, 2, 1, 0, 1, 2, 0, 1, 2, 1, 0, 1, 2, 0, 1, 1),
  nrow = 8,
  dimnames = list(letters[1:8], c("m1", "m2", "m3"))
)
mf_group <- c(
  a = "base", b = "base", c = "base", d = "base",
  e = "", f = "", g = "", h = ""
)
Gamma <- matrix(0.25, nrow = 1, dimnames = list("base", "base"))
Kmat <- diag(4)
dimnames(Kmat) <- list(dat$id, dat$id)
Ginv <- Kmat

hs_cov_fitters <- c(
  "ai_reml", "direct_maternal", "genomic", "gllvm", "henderson_mme",
  "metafounder", "metafounder_single_step", "multivariate",
  "multivariate_repeatability", "n_effect", "nongaussian",
  "random_regression", "repeatability", "single_step_construct", "snp_blup",
  "snp_blup_reml", "sparse_reml", "two_effect"
)

# Replace every Julia fitter hsquared() can dispatch to with a stub that
# returns the route it was reached by and the arguments it was handed.
hs_cov_stub_fitters <- function(bridge = TRUE, .env = parent.frame()) {
  stub <- function(route) {
    force(route)
    function(...) {
      args <- list(...)
      structure(
        list(route = route, args = args[-1L], payload = args[[1L]]),
        class = "hs_cov_route"
      )
    }
  }
  mocks <- stats::setNames(
    lapply(hs_cov_fitters, stub),
    paste0("hs_fit_julia_", hs_cov_fitters, "_payload")
  )
  mocks$hs_fit_julia_payload <- stub("fit_animal_model")
  mocks$hs_julia_bridge_available <- function(...) bridge
  do.call(
    testthat::local_mocked_bindings,
    c(mocks, list(.package = "hsquared", .env = .env))
  )
}

jl <- function(...) {
  hs_control(engine = "julia", engine_control = list(...))
}

hs_cov_route <- function(formula, data, control, family = stats::gaussian()) {
  out <- hsquared(formula, data = data, family = family, control = control)
  expect_s3_class(out, "hs_cov_route")
  out
}

# ---- default `engine = "fit"` routing --------------------------------------

test_that("engine = fit with the bridge present routes the animal model to AI-REML with documented defaults", {
  withr::local_envvar(HSQUARED_JULIA_PROJECT = "/tmp/hsq-cov-project")
  hs_cov_stub_fitters()
  out <- hs_cov_route(
    y ~ animal(1 | id, pedigree = ped),
    dat,
    hs_control(engine = "fit")
  )
  expect_identical(out$route, "ai_reml")
  expect_identical(out$args$project, "/tmp/hsq-cov-project")
  expect_identical(out$args$initial, c(sigma_a2 = 1, sigma_e2 = 1))
  expect_identical(out$args$iterations, 100L)
  expect_identical(out$args$em_warmup, 0L)
  expect_false(out$args$skip_pev_reliability)
  expect_s3_class(out$payload, "hs_bridge_payload")
  expect_equal(out$payload$y, dat$y)
})

test_that("engine = fit forwards every honoured engine_control key unchanged", {
  hs_cov_stub_fitters()
  out <- hs_cov_route(
    y ~ animal(1 | id, pedigree = ped),
    dat,
    hs_control(
      engine = "fit",
      engine_control = list(
        julia_project = "/tmp/elsewhere",
        initial = c(sigma_a2 = 2, sigma_e2 = 3),
        iterations = 7,
        em_warmup = 2,
        skip_pev_reliability = TRUE
      )
    )
  )
  expect_identical(out$route, "ai_reml")
  expect_identical(out$args$project, "/tmp/elsewhere")
  expect_identical(out$args$initial, c(sigma_a2 = 2, sigma_e2 = 3))
  expect_identical(out$args$iterations, 7)
  expect_identical(out$args$em_warmup, 2)
  expect_true(out$args$skip_pev_reliability)
})

test_that("engine = fit names every Julia-only engine_control key it would otherwise ignore", {
  hs_cov_stub_fitters()
  err <- expect_error(
    hsquared(
      y ~ animal(1 | id, pedigree = ped),
      data = dat,
      control = hs_control(
        engine = "fit",
        engine_control = list(
          target = "ai_reml",
          variance_components = c(sigma_a2 = 1, sigma_e2 = 1),
          iterations = 5
        )
      )
    ),
    "`engine = \"fit\"` does not use `engine_control` `target`, `variance_components`.",
    fixed = TRUE
  )
  expect_match(
    conditionMessage(err),
    "Use `engine = \"julia\"` to set `target` or `variance_components`",
    fixed = TRUE
  )
  expect_no_match(conditionMessage(err), "iterations", fixed = TRUE)
})

test_that("the fit path refuses REML = FALSE itself when called through a qualified or aliased name", {
  hs_cov_stub_fitters()
  err <- expect_error(
    hsquared::hsquared(
      y ~ animal(1 | id, pedigree = ped),
      data = dat,
      REML = FALSE,
      control = hs_control(engine = "fit")
    ),
    class = "hsquared_unsupported_syntax"
  )
  expect_match(
    conditionMessage(err),
    "The v0.1 default fit path estimates variance components by REML",
    fixed = TRUE
  )
  expect_match(
    conditionMessage(err),
    "use `REML = TRUE` (the default)",
    fixed = TRUE
  )
})

test_that("engine = fit without the bridge stops with install guidance naming the validate escape hatch", {
  hs_cov_stub_fitters(bridge = FALSE)
  err <- expect_error(
    hsquared(
      y ~ animal(1 | id, pedigree = ped),
      data = dat,
      control = hs_control(engine = "fit")
    ),
    "requires the HSquared.jl Julia engine",
    fixed = TRUE
  )
  msg <- conditionMessage(err)
  expect_match(msg, "HSQUARED_JULIA_PROJECT", fixed = TRUE)
  expect_match(msg, "hs_control(engine = \"validate\")", fixed = TRUE)
  expect_false(inherits(err, "hsquared_unsupported_syntax"))
})

test_that("engine = fit auto-routes a cbind() response to the multivariate fitter and warns once per session", {
  hs_cov_stub_fitters()
  flags <- hsquared:::hs_session_flags
  old <- flags$cbind_experimental
  withr::defer(flags$cbind_experimental <- old)
  flags$cbind_experimental <- FALSE

  expect_warning(
    out <- hs_cov_route(
      cbind(y, y2) ~ animal(1 | id, pedigree = ped),
      dat,
      hs_control(engine = "fit")
    ),
    "multivariate is covered at validation scale",
    fixed = TRUE
  )
  expect_identical(out$route, "multivariate")
  expect_null(out$args$initial)
  expect_identical(out$args$iterations, 2000L)
  expect_identical(out$args$genetic_structure, "unstructured")
  expect_equal(out$args$max_dense_cells, 1e6)
  expect_equal(out$payload$metadata$trait_names, c("y", "y2"))
  expect_equal(unname(out$payload$Y), cbind(dat$y, dat$y2))

  expect_no_warning(
    again <- hs_cov_route(
      cbind(y, y2) ~ animal(1 | id, pedigree = ped),
      dat,
      hs_control(engine = "fit")
    )
  )
  expect_identical(again$route, "multivariate")
})

test_that("engine = fit sends cbind() + permanent() to the multivariate repeatability fitter, never the animal-only one", {
  hs_cov_stub_fitters()
  flags <- hsquared:::hs_session_flags
  old <- flags$cbind_experimental
  withr::defer(flags$cbind_experimental <- old)
  flags$cbind_experimental <- TRUE

  out <- hs_cov_route(
    cbind(y, y2) ~ animal(1 | id, pedigree = ped) + permanent(1 | id),
    rdat,
    hs_control(
      engine = "fit",
      engine_control = list(iterations = 11L, max_dense_cells = 5e5)
    )
  )
  expect_identical(out$route, "multivariate_repeatability")
  expect_identical(out$args$iterations, 11L)
  expect_equal(out$args$max_dense_cells, 5e5)
  expect_null(out$args$initial)
})

# ---- default-path guards ----------------------------------------------------

test_that("engine = fit names the opt-in target for each non-default random effect", {
  hs_cov_stub_fitters()
  fit_ctl <- hs_control(engine = "fit")

  err <- expect_error(
    hsquared(
      y ~ animal(1 | id, pedigree = ped) + (1 | grp),
      data = dat,
      control = fit_ctl
    ),
    class = "hsquared_unsupported_syntax"
  )
  expect_match(
    conditionMessage(err),
    "bare `(1 | group)` i.i.d. random-effect (multi-effect) model is experimental and opt-in",
    fixed = TRUE
  )
  expect_match(conditionMessage(err), "target = \"multi_effect\"", fixed = TRUE)

  err <- expect_error(
    hsquared(
      y ~ animal(1 | id, pedigree = ped) + maternal_genetic(1 | dam),
      data = dat,
      control = fit_ctl
    ),
    class = "hsquared_unsupported_syntax"
  )
  expect_match(conditionMessage(err), "direct_maternal", fixed = TRUE)
  expect_match(conditionMessage(err), "two_effect", fixed = TRUE)

  err <- expect_error(
    hsquared(
      y ~ single_step(1 | id, pedigree = ped, markers = mrk),
      data = dat,
      control = fit_ctl
    ),
    class = "hsquared_unsupported_syntax"
  )
  expect_match(conditionMessage(err), "single_step_construct", fixed = TRUE)

  err <- expect_error(
    hsquared(
      y ~ genomic(1 | id, Ginv = Ginv),
      data = dat,
      control = fit_ctl
    ),
    class = "hsquared_unsupported_syntax"
  )
  expect_match(conditionMessage(err), "genomic", fixed = TRUE)

  for (term in c("relmat(1 | id, K = Kmat)", "precision(1 | id, Q = Kmat)")) {
    type <- sub("\\(.*$", "", term)
    err <- expect_error(
      hsquared(
        stats::as.formula(paste("y ~", term), env = environment()),
        data = dat,
        control = fit_ctl
      ),
      class = "hsquared_unsupported_syntax"
    )
    expect_match(
      conditionMessage(err),
      paste0("The `", type, "` model is experimental and opt-in"),
      fixed = TRUE
    )
    expect_match(
      conditionMessage(err),
      paste0("target = \"", type, "\""),
      fixed = TRUE
    )
  }
})

test_that("engine = fit pastes the next call for permanent() and common_env() and reaches no fitter", {
  hs_cov_stub_fitters()
  err <- expect_error(
    hsquared(
      y ~ animal(1 | id, pedigree = ped) + permanent(1 | id),
      data = rdat,
      control = hs_control(engine = "fit")
    ),
    class = "hsquared_unsupported_syntax"
  )
  expect_match(conditionMessage(err), "`permanent()` is not on the default path", fixed = TRUE)
  expect_match(conditionMessage(err), "target = \"repeatability\"", fixed = TRUE)

  err <- expect_error(
    hsquared(
      y ~ animal(1 | id, pedigree = ped) + common_env(1 | grp),
      data = dat,
      control = hs_control(engine = "fit")
    ),
    class = "hsquared_unsupported_syntax"
  )
  expect_match(conditionMessage(err), "target = \"two_effect\"", fixed = TRUE)
})

test_that("engine = fit sends a random-regression term to its opt-in target", {
  hs_cov_stub_fitters()
  err <- expect_error(
    hsquared(
      y ~ animal(rr(age, order = 1) | id, pedigree = ped),
      data = dat,
      control = hs_control(engine = "fit")
    ),
    class = "hsquared_unsupported_syntax"
  )
  expect_match(conditionMessage(err), "`rr(...)` is not on the default path", fixed = TRUE)
  expect_match(conditionMessage(err), "target = \"random_regression\"", fixed = TRUE)
})

test_that("REML = FALSE is refused on every estimating route before any fitter is reached", {
  hs_cov_stub_fitters()
  fit_err <- expect_error(
    hsquared(
      y ~ animal(1 | id, pedigree = ped),
      data = dat,
      REML = FALSE,
      control = hs_control(engine = "fit")
    ),
    class = "hsquared_unsupported_syntax"
  )
  expect_match(
    conditionMessage(fit_err),
    "ML estimation (`REML = FALSE`) is not implemented.",
    fixed = TRUE
  )
  expect_match(
    conditionMessage(fit_err),
    "Closest working call: `REML = TRUE`",
    fixed = TRUE
  )

  for (ctl in list(jl(), jl(target = "ai_reml"), jl(target = "sparse_reml"))) {
    err <- expect_error(
      hsquared(
        y ~ animal(1 | id, pedigree = ped),
        data = dat,
        REML = FALSE,
        control = ctl
      ),
      class = "hsquared_unsupported_syntax"
    )
    expect_match(
      conditionMessage(err),
      "ML estimation (`REML = FALSE`) is not implemented; the v0.1 fit path estimates variance components by REML. Use `REML = TRUE`.",
      fixed = TRUE
    )
  }
})

test_that("supplied-variance targets are exempt from the REML = TRUE rule and carry an ML label", {
  hs_cov_stub_fitters()
  vc <- c(sigma_a2 = 1, sigma_e2 = 1)
  out <- hsquared(
    y ~ animal(1 | id, pedigree = ped),
    data = dat,
    REML = FALSE,
    control = jl(target = "henderson_mme", variance_components = vc)
  )
  expect_identical(out$route, "henderson_mme")
  expect_identical(out$payload$method, "ML")

  out <- hsquared(
    y ~ metafounder(1 | id, pedigree = ped, group = mf_group, Gamma = Gamma),
    data = dat,
    REML = FALSE,
    control = jl(target = "metafounder", variance_components = vc)
  )
  expect_identical(out$route, "metafounder")

  out <- hsquared(
    y ~ genomic(1 | id, markers = mrk),
    data = dat,
    REML = FALSE,
    control = jl(
      target = "snp_blup",
      variance_components = c(sigma_g2 = 1, sigma_e2 = 1)
    )
  )
  expect_identical(out$route, "snp_blup")
  expect_identical(out$payload$method, "ML")

  for (ctl in list(jl(target = "snp_blup"), jl(target = "multi_effect"))) {
    err <- expect_error(
      hsquared(
        y ~ genomic(1 | id, markers = mrk),
        data = dat,
        REML = FALSE,
        control = ctl
      ),
      class = "hsquared_unsupported_syntax"
    )
    expect_match(
      conditionMessage(err),
      "ML estimation (`REML = FALSE`) is not implemented;",
      fixed = TRUE
    )
  }
})

# ---- argument-level guards --------------------------------------------------

test_that("hsquared() requires formula, data and an hs_control() object", {
  expect_error(
    hsquared(data = dat),
    "`formula` is required.",
    fixed = TRUE
  )
  expect_error(
    hsquared(y ~ animal(1 | id, pedigree = ped)),
    "`data` is required.",
    fixed = TRUE
  )
  expect_error(
    hsquared(
      y ~ animal(1 | id, pedigree = ped),
      data = dat,
      control = list(engine = "validate")
    ),
    "`control` must be created by `hs_control()`.",
    fixed = TRUE
  )
})

test_that("unnamed and named dots are listed in the redirect error", {
  err <- expect_error(
    hsquared(
      y ~ animal(1 | id, pedigree = ped),
      data = dat,
      family = stats::gaussian(),
      REML = TRUE,
      control = hs_control(engine = "validate"),
      3
    ),
    "does not accept an unnamed argument in `...`",
    fixed = TRUE
  )
  expect_match(conditionMessage(err), "Engine options belong in", fixed = TRUE)

  err <- expect_error(
    hsquared(
      y ~ animal(1 | id, pedigree = ped),
      data = dat,
      family = stats::gaussian(),
      REML = TRUE,
      control = hs_control(engine = "validate"),
      alpha = 1,
      3
    ),
    "does not accept `alpha`, an unnamed argument in `...`",
    fixed = TRUE
  )
  expect_false(inherits(err, "hsquared_unsupported_syntax"))
})

test_that("the genetic_gllvm target needs an explicit julia engine, whichever engine is chosen", {
  for (engine in c("fit", "validate")) {
    expect_error(
      hsquared(
        y ~ animal(1 | id, pedigree = ped),
        data = dat,
        control = hs_control(
          engine = engine,
          engine_control = list(target = "genetic_gllvm")
        )
      ),
      "Genetic GLLVM requires explicit engine = \"julia\".",
      fixed = TRUE,
      class = "hsquared_unsupported_syntax"
    )
  }
})

# ---- engine = "julia": target routing --------------------------------------

hs_cov_route_cases <- list(
  list(
    label = "default target",
    formula = y ~ animal(1 | id, pedigree = ped),
    control = jl(),
    route = "fit_animal_model",
    defaults = list(
      initial = c(sigma_a2 = 1, sigma_e2 = 1),
      max_dense_cells = 1e6,
      skip_pev_reliability = FALSE
    ),
    supplied = list(
      initial = c(sigma_a2 = 4, sigma_e2 = 5),
      max_dense_cells = 2e5,
      skip_pev_reliability = TRUE
    )
  ),
  list(
    label = "ai_reml",
    formula = y ~ animal(1 | id, pedigree = ped),
    control = jl(target = "ai_reml"),
    route = "ai_reml",
    defaults = list(
      initial = c(sigma_a2 = 1, sigma_e2 = 1),
      iterations = 100L,
      em_warmup = 0L,
      skip_pev_reliability = FALSE
    ),
    supplied = list(
      initial = c(sigma_a2 = 4, sigma_e2 = 5),
      iterations = 9,
      em_warmup = 3,
      skip_pev_reliability = TRUE
    )
  ),
  list(
    label = "sparse_reml",
    formula = y ~ animal(1 | id, pedigree = ped),
    control = jl(target = "sparse_reml"),
    route = "sparse_reml",
    defaults = list(
      initial = c(sigma_a2 = 1, sigma_e2 = 1),
      iterations = 1000L,
      skip_pev_reliability = FALSE
    ),
    supplied = list(
      initial = c(sigma_a2 = 4, sigma_e2 = 5),
      iterations = 9,
      skip_pev_reliability = TRUE
    )
  ),
  list(
    label = "henderson_mme",
    formula = y ~ animal(1 | id, pedigree = ped),
    control = jl(
      target = "henderson_mme",
      variance_components = c(sigma_a2 = 1.5, sigma_e2 = 0.5)
    ),
    route = "henderson_mme",
    defaults = list(variance_components = c(sigma_a2 = 1.5, sigma_e2 = 0.5)),
    supplied = list()
  ),
  list(
    label = "repeatability",
    formula = y ~ animal(1 | id, pedigree = ped) + permanent(1 | id),
    data = "rdat",
    control = jl(target = "repeatability"),
    route = "repeatability",
    defaults = list(
      initial = c(sigma_a2 = 1, sigma_pe2 = 1, sigma_e2 = 1),
      iterations = 200L,
      max_dense_cells = 1e6,
      scale_method = "dense"
    ),
    supplied = list(
      initial = c(sigma_a2 = 2, sigma_pe2 = 3, sigma_e2 = 4),
      iterations = 12,
      max_dense_cells = 3e5,
      scale_method = "dense"
    )
  ),
  list(
    label = "two_effect (common_env)",
    formula = y ~ animal(1 | id, pedigree = ped) + common_env(1 | grp),
    control = jl(target = "two_effect"),
    route = "two_effect",
    defaults = list(
      initial = c(sigma_a2 = 1, sigma_c2 = 1, sigma_e2 = 1),
      iterations = 200L
    ),
    supplied = list(
      initial = c(sigma_a2 = 2, sigma_c2 = 3, sigma_e2 = 4),
      iterations = 12
    )
  ),
  list(
    label = "two_effect (maternal_genetic)",
    formula = y ~ animal(1 | id, pedigree = ped) + maternal_genetic(1 | dam),
    control = jl(target = "two_effect"),
    route = "two_effect",
    defaults = list(
      initial = c(sigma_a2 = 1, sigma_c2 = 1, sigma_e2 = 1),
      iterations = 200L
    ),
    supplied = list()
  ),
  list(
    label = "multi_effect",
    formula = y ~ animal(1 | id, pedigree = ped) + (1 | grp),
    control = jl(target = "multi_effect"),
    route = "n_effect",
    defaults = list(scale_method = "dense", initial = NULL, iterations = NULL),
    supplied = list(
      scale_method = "auto",
      initial = c(1, 2, 3),
      iterations = 13
    )
  ),
  list(
    label = "direct_maternal",
    formula = y ~ animal(1 | id, pedigree = ped) + maternal_genetic(1 | dam),
    control = jl(target = "direct_maternal"),
    route = "direct_maternal",
    defaults = list(initial = NULL, iterations = NULL),
    supplied = list(initial = c(1, 2, 3, 4, 5), iterations = 14)
  ),
  list(
    label = "snp_blup (REML-estimated variances)",
    formula = y ~ genomic(1 | id, markers = mrk),
    control = jl(target = "snp_blup"),
    route = "snp_blup_reml",
    defaults = list(),
    supplied = list()
  ),
  list(
    label = "snp_blup (supplied variances)",
    formula = y ~ genomic(1 | id, markers = mrk),
    control = jl(
      target = "snp_blup",
      variance_components = c(sigma_g2 = 0.7, sigma_e2 = 0.3)
    ),
    route = "snp_blup",
    defaults = list(variance_components = c(sigma_g2 = 0.7, sigma_e2 = 0.3)),
    supplied = list()
  ),
  list(
    label = "single_step_construct",
    formula = y ~ single_step(1 | id, pedigree = ped, markers = mrk),
    control = jl(target = "single_step_construct"),
    route = "single_step_construct",
    defaults = list(initial = c(sigma_a2 = 1, sigma_e2 = 1), iterations = 100L),
    supplied = list(initial = c(sigma_a2 = 2, sigma_e2 = 3), iterations = 15)
  ),
  list(
    label = "metafounder_single_step",
    formula = y ~ single_step(
      1 | id,
      pedigree = ped,
      markers = mrk,
      group = mf_group,
      Gamma = Gamma
    ),
    control = jl(target = "metafounder_single_step"),
    route = "metafounder_single_step",
    defaults = list(initial = c(sigma_a2 = 1, sigma_e2 = 1), iterations = 100L),
    supplied = list(initial = c(sigma_a2 = 2, sigma_e2 = 3), iterations = 15)
  ),
  list(
    label = "metafounder",
    formula = y ~ metafounder(
      1 | id,
      pedigree = ped,
      group = mf_group,
      Gamma = Gamma
    ),
    control = jl(
      target = "metafounder",
      variance_components = c(sigma_a2 = 1, sigma_e2 = 1)
    ),
    route = "metafounder",
    defaults = list(variance_components = c(sigma_a2 = 1, sigma_e2 = 1)),
    supplied = list()
  ),
  list(
    label = "relmat",
    formula = y ~ relmat(1 | id, K = Kmat),
    control = jl(target = "relmat"),
    route = "genomic",
    defaults = list(initial = c(sigma_a2 = 1, sigma_e2 = 1), iterations = 100L),
    supplied = list(initial = c(sigma_a2 = 2, sigma_e2 = 3), iterations = 16)
  ),
  list(
    label = "precision",
    formula = y ~ precision(1 | id, Q = Kmat),
    control = jl(target = "precision"),
    route = "genomic",
    defaults = list(initial = c(sigma_a2 = 1, sigma_e2 = 1), iterations = 100L),
    supplied = list(initial = c(sigma_a2 = 2, sigma_e2 = 3), iterations = 16)
  ),
  list(
    label = "genomic (supplied Ginv)",
    formula = y ~ genomic(1 | id, Ginv = Ginv),
    control = jl(target = "genomic"),
    route = "genomic",
    defaults = list(initial = c(sigma_a2 = 1, sigma_e2 = 1), iterations = 100L),
    supplied = list(initial = c(sigma_a2 = 2, sigma_e2 = 3), iterations = 16)
  ),
  list(
    label = "single_step (supplied Hinv)",
    formula = y ~ single_step(1 | id, Hinv = Ginv),
    control = jl(target = "single_step"),
    route = "genomic",
    defaults = list(initial = c(sigma_a2 = 1, sigma_e2 = 1), iterations = 100L),
    supplied = list(initial = c(sigma_a2 = 2, sigma_e2 = 3), iterations = 16)
  ),
  list(
    label = "random_regression",
    formula = y ~ animal(rr(age, order = 1) | id, pedigree = ped),
    control = jl(target = "random_regression"),
    route = "random_regression",
    defaults = list(iterations = 2000L),
    supplied = list(iterations = 17)
  ),
  list(
    label = "multivariate (explicit)",
    formula = cbind(y, y2) ~ animal(1 | id, pedigree = ped),
    control = jl(target = "multivariate"),
    route = "multivariate",
    defaults = list(
      initial = NULL,
      iterations = 2000L,
      genetic_structure = "unstructured",
      rank = NULL,
      max_dense_cells = 1e6
    ),
    supplied = list(
      initial = diag(2),
      iterations = 18,
      genetic_structure = "diagonal",
      max_dense_cells = 4e5
    )
  ),
  list(
    label = "multivariate (auto from cbind)",
    formula = cbind(y, y2) ~ animal(1 | id, pedigree = ped),
    control = jl(),
    route = "multivariate",
    defaults = list(iterations = 2000L, genetic_structure = "unstructured"),
    supplied = list()
  ),
  list(
    label = "multivariate_repeatability (auto from cbind + permanent)",
    formula = cbind(y, y2) ~ animal(1 | id, pedigree = ped) + permanent(1 | id),
    data = "rdat",
    control = jl(),
    route = "multivariate_repeatability",
    defaults = list(initial = NULL, iterations = 2000L, max_dense_cells = 1e6),
    supplied = list()
  ),
  list(
    label = "multivariate target upgraded when permanent() is present",
    formula = cbind(y, y2) ~ animal(1 | id, pedigree = ped) + permanent(1 | id),
    data = "rdat",
    control = jl(target = "multivariate"),
    route = "multivariate_repeatability",
    defaults = list(iterations = 2000L),
    supplied = list()
  ),
  list(
    label = "multivariate_repeatability (explicit)",
    formula = cbind(y, y2) ~ animal(1 | id, pedigree = ped) + permanent(1 | id),
    data = "rdat",
    control = jl(target = "multivariate_repeatability"),
    route = "multivariate_repeatability",
    defaults = list(iterations = 2000L),
    supplied = list(iterations = 19, max_dense_cells = 7e5)
  )
)

test_that("engine = julia reaches the documented fitter with the documented defaults", {
  hs_cov_stub_fitters()
  withr::local_envvar(HSQUARED_JULIA_PROJECT = "/tmp/hsq-cov-project")
  for (case in hs_cov_route_cases) {
    data <- if (identical(case$data, "rdat")) rdat else dat
    out <- suppressWarnings(
      hs_cov_route(case$formula, data, case$control)
    )
    expect_identical(out$route, case$route, label = case$label)
    expect_identical(
      out$args$project,
      "/tmp/hsq-cov-project",
      label = paste(case$label, "project")
    )
    for (nm in names(case$defaults)) {
      expect_equal(
        out$args[[nm]],
        case$defaults[[nm]],
        label = paste(case$label, nm)
      )
    }
  }
})

test_that("engine = julia forwards each supplied engine_control value unchanged", {
  hs_cov_stub_fitters()
  for (case in hs_cov_route_cases) {
    if (length(case$supplied) == 0L) {
      next
    }
    data <- if (identical(case$data, "rdat")) rdat else dat
    ctl <- case$control
    ctl$engine_control[names(case$supplied)] <- case$supplied
    ctl$engine_control$julia_project <- "/tmp/user-project"
    out <- suppressWarnings(hs_cov_route(case$formula, data, ctl))
    expect_identical(out$route, case$route, label = case$label)
    expect_identical(
      out$args$project,
      "/tmp/user-project",
      label = paste(case$label, "project")
    )
    for (nm in names(case$supplied)) {
      expect_identical(
        out$args[[nm]],
        case$supplied[[nm]],
        label = paste(case$label, nm)
      )
    }
  }
})

test_that("non-Gaussian target forwards the family and its controls", {
  hs_cov_stub_fitters()
  out <- hs_cov_route(
    y ~ animal(1 | id, pedigree = ped),
    dat,
    jl(target = "nongaussian"),
    family = stats::poisson()
  )
  expect_identical(out$route, "nongaussian")
  expect_identical(out$args$family$family, "poisson")
  expect_identical(out$args$family$link, "log")
  expect_identical(out$args$marginal, "laplace")
  expect_identical(out$args$iterations, 200L)
  expect_null(out$args$initial)
  expect_false(out$args$restart_check)

  out <- hs_cov_route(
    y ~ animal(1 | id, pedigree = ped),
    dat,
    jl(
      target = "nongaussian",
      marginal = "variational",
      iterations = 33,
      restart_check = TRUE
    ),
    family = stats::poisson()
  )
  expect_identical(out$args$marginal, "variational")
  expect_identical(out$args$iterations, 33)
  expect_true(out$args$restart_check)
})

test_that("non-Gaussian target refuses a Gaussian family and any dots", {
  hs_cov_stub_fitters()
  expect_error(
    hsquared(
      y ~ animal(1 | id, pedigree = ped),
      data = dat,
      control = jl(target = "nongaussian")
    ),
    "`family = gaussian()` fits through the default path or `target = \"ai_reml\"`",
    fixed = TRUE,
    class = "hsquared_unsupported_syntax"
  )
  expect_error(
    hsquared(
      y ~ animal(1 | id, pedigree = ped),
      data = dat,
      family = stats::poisson(),
      control = jl(target = "nongaussian"),
      weights = 1
    ),
    "The v0.9 non-Gaussian contract does not accept weights.",
    fixed = TRUE
  )
  expect_error(
    hsquared(
      y ~ animal(1 | id, pedigree = ped),
      data = dat,
      family = stats::poisson(),
      control = jl(target = "nongaussian"),
      offset = 1
    ),
    "does not accept ... controls",
    fixed = TRUE
  )
})

# ---- engine = "julia": pre-bridge guards -----------------------------------

test_that("engine = julia rejects an unknown target with the full allowlist", {
  err <- expect_error(
    hsquared(
      y ~ animal(1 | id, pedigree = ped),
      data = dat,
      control = jl(target = "bogus")
    ),
    class = "hsquared_unsupported_syntax"
  )
  msg <- conditionMessage(err)
  expect_match(msg, "`engine_control$target` must be one of", fixed = TRUE)
  expect_match(msg, "\"direct_maternal\"", fixed = TRUE)
})

test_that("each opt-in target without its formula term names the missing term", {
  hs_cov_stub_fitters()
  base <- y ~ animal(1 | id, pedigree = ped)
  cases <- list(
    list(jl(target = "metafounder"), base, "requires `metafounder(1 | id, pedigree = ped, group = mf_group, Gamma = Gamma)`"),
    list(jl(target = "repeatability"), base, "requires a `permanent(1 | id)` term"),
    list(jl(target = "two_effect"), base, "requires a `common_env(1 | group)` term, or a `maternal_genetic(1 | dam)` term"),
    list(jl(target = "multi_effect"), base, "requires an `animal(1 | id, ...)` term plus one or more bare `(1 | group)`"),
    list(jl(target = "direct_maternal"), base, "requires a `maternal_genetic(1 | dam)` term"),
    list(jl(target = "snp_blup"), base, "requires a `genomic(1 | id, markers = M)` term"),
    list(jl(target = "single_step_construct"), base, "requires a `single_step(1 | id, pedigree = ped, markers = M)` term"),
    list(jl(target = "metafounder_single_step"), base, "requires `single_step(1 | id, pedigree = ped, markers = M, group = mf_group, Gamma = Gamma)`"),
    list(jl(target = "genomic"), base, "requires a `genomic(1 | id, Ginv = Ginv)` term"),
    list(jl(target = "single_step"), base, "requires a `single_step(1 | id, Hinv = Hinv)` term"),
    list(jl(target = "random_regression"), base, "requires an `animal(rr(covariate, order = k) | id, pedigree = ped)` term")
  )
  for (case in cases) {
    expect_error(
      hsquared(case[[2L]], data = dat, control = case[[1L]]),
      case[[3L]],
      fixed = TRUE,
      class = "hsquared_unsupported_syntax"
    )
  }
  for (target in c("relmat", "precision")) {
    arg <- if (identical(target, "relmat")) "K" else "Q"
    expect_error(
      hsquared(base, data = dat, control = jl(target = target)),
      paste0(
        "`target = \"", target, "\"` requires a `", target, "(1 | id, ", arg,
        " = ", arg, ")` term in the formula."
      ),
      fixed = TRUE
    )
  }
})

test_that("a single_step group/Gamma term is not accepted by the ordinary construct target", {
  hs_cov_stub_fitters()
  expect_error(
    hsquared(
      y ~ single_step(
        1 | id,
        pedigree = ped,
        markers = mrk,
        group = mf_group,
        Gamma = Gamma
      ),
      data = dat,
      control = jl(target = "single_step_construct")
    ),
    "is the planned `target = \"metafounder_single_step\"` contract",
    fixed = TRUE,
    class = "hsquared_unsupported_syntax"
  )
})

test_that("snp_blup refuses a supplied-Ginv genomic term", {
  hs_cov_stub_fitters()
  expect_error(
    hsquared(
      y ~ genomic(1 | id, Ginv = Ginv),
      data = dat,
      control = jl(target = "snp_blup")
    ),
    "a precomputed `Ginv` cannot be used",
    fixed = TRUE,
    class = "hsquared_unsupported_syntax"
  )
})

test_that("a second random effect on the wrong target prints the closest working call", {
  hs_cov_stub_fitters()
  err <- expect_error(
    hsquared(
      y ~ animal(1 | id, pedigree = ped) + (1 | grp),
      data = dat,
      control = jl(target = "ai_reml")
    ),
    class = "hsquared_unsupported_syntax"
  )
  msg <- conditionMessage(err)
  expect_match(msg, "bare `(1 | group)` i.i.d. random term", fixed = TRUE)
  expect_match(msg, "needs `target = \"multi_effect\"`", fixed = TRUE)
  expect_match(msg, "Closest working call:", fixed = TRUE)
  expect_match(msg, "y ~ animal(1 | id, pedigree = ped) + (1 | grp)", fixed = TRUE)

  err <- expect_error(
    hsquared(
      y ~ animal(1 | id, pedigree = ped) + maternal_genetic(1 | dam),
      data = dat,
      control = jl(target = "ai_reml")
    ),
    class = "hsquared_unsupported_syntax"
  )
  msg <- conditionMessage(err)
  expect_match(msg, "`maternal_genetic(...)` term", fixed = TRUE)
  expect_match(msg, "needs `target = \"two_effect\"` (or \"direct_maternal\")", fixed = TRUE)
  expect_match(msg, "target = \"direct_maternal\"", fixed = TRUE)

  err <- expect_error(
    hsquared(
      y ~ single_step(1 | id, Hinv = Ginv),
      data = dat,
      control = jl(target = "ai_reml")
    ),
    class = "hsquared_unsupported_syntax"
  )
  msg <- conditionMessage(err)
  expect_match(msg, "`single_step(...)` term", fixed = TRUE)
  expect_match(msg, "needs `target = \"single_step\"` (or \"single_step_construct\")", fixed = TRUE)

  err <- expect_error(
    hsquared(
      y ~ relmat(1 | id, K = Kmat),
      data = dat,
      control = jl(target = "precision")
    ),
    class = "hsquared_unsupported_syntax"
  )
  expect_match(
    conditionMessage(err),
    "needs `target = \"relmat\"`. The `precision` target fits the single additive-genetic effect only.",
    fixed = TRUE
  )
})

test_that("multivariate responses and targets must agree before dispatch", {
  hs_cov_stub_fitters()
  expect_error(
    hsquared(
      cbind(y, y2) ~ animal(1 | id, pedigree = ped),
      data = dat,
      control = jl(target = "ai_reml")
    ),
    "the `ai_reml` target fits a univariate response.",
    fixed = TRUE,
    class = "hsquared_unsupported_syntax"
  )
  expect_error(
    hsquared(
      y ~ animal(1 | id, pedigree = ped),
      data = dat,
      control = jl(target = "multivariate")
    ),
    "`target = \"multivariate\"` requires a `cbind(trait1, trait2, ...)` response",
    fixed = TRUE,
    class = "hsquared_unsupported_syntax"
  )
  expect_error(
    hsquared(
      y ~ animal(1 | id, pedigree = ped) + permanent(1 | id),
      data = rdat,
      control = jl(target = "multivariate_repeatability")
    ),
    "`target = \"multivariate_repeatability\"` requires a `cbind(trait1, trait2, ...)` response",
    fixed = TRUE,
    class = "hsquared_unsupported_syntax"
  )
  expect_error(
    hsquared(
      cbind(y, y2) ~ animal(1 | id, pedigree = ped),
      data = dat,
      control = jl(target = "multivariate_repeatability")
    ),
    "requires `cbind(...) ~ ... + animal(1 | id, pedigree = ped) + permanent(1 | id)`",
    fixed = TRUE,
    class = "hsquared_unsupported_syntax"
  )
})

test_that("random-regression terms and the random_regression target must agree", {
  hs_cov_stub_fitters()
  expect_error(
    hsquared(
      y ~ animal(rr(age, order = 1) | id, pedigree = ped),
      data = dat,
      control = jl(target = "ai_reml")
    ),
    "requires the opt-in `target = \"random_regression\"` Julia engine path",
    fixed = TRUE,
    class = "hsquared_unsupported_syntax"
  )
})

test_that("engine_control keys a target does not honour are named, alongside the target", {
  hs_cov_stub_fitters()
  err <- expect_error(
    hsquared(
      y ~ animal(1 | id, pedigree = ped),
      data = dat,
      control = jl(target = "ai_reml", variance_components = c(1, 1), marginal = "laplace")
    ),
    class = "hsquared_unsupported_syntax"
  )
  msg <- conditionMessage(err)
  expect_match(msg, "`engine_control` keys `variance_components`, `marginal` are not honoured", fixed = TRUE)
  expect_match(msg, "`target = \"ai_reml\"`", fixed = TRUE)
})

test_that("repeatability with scale_method = auto warns that initial and iterations are ignored, and still forwards", {
  hs_cov_stub_fitters()
  expect_warning(
    out <- hs_cov_route(
      y ~ animal(1 | id, pedigree = ped) + permanent(1 | id),
      rdat,
      jl(
        target = "repeatability",
        scale_method = "auto",
        initial = c(sigma_a2 = 1, sigma_pe2 = 1, sigma_e2 = 1),
        iterations = 5
      )
    ),
    "ignores `initial` and `iterations`",
    fixed = TRUE
  )
  expect_identical(out$route, "repeatability")
  expect_identical(out$args$scale_method, "auto")

  expect_warning(
    hs_cov_route(
      y ~ animal(1 | id, pedigree = ped) + permanent(1 | id),
      rdat,
      jl(target = "repeatability", scale_method = "auto", iterations = 5)
    ),
    "ignores `iterations`:",
    fixed = TRUE
  )

  expect_no_warning(
    hs_cov_route(
      y ~ animal(1 | id, pedigree = ped) + permanent(1 | id),
      rdat,
      jl(target = "repeatability", scale_method = "auto")
    )
  )
})

test_that("the random-regression route warns about response scale only outside [0.1, 10] standard deviations", {
  hs_cov_stub_fitters()
  form <- y ~ animal(rr(age, order = 1) | id, pedigree = ped)
  big <- dat
  big$y <- 1000 * big$y
  expect_equal(stats::sd(big$y) > 10, TRUE)
  expect_warning(
    out <- hs_cov_route(form, big, jl(target = "random_regression")),
    "far from unit scale",
    fixed = TRUE
  )
  expect_identical(out$route, "random_regression")
  expect_match(
    tryCatch(
      hs_cov_route(form, big, jl(target = "random_regression")),
      warning = function(w) conditionMessage(w)
    ),
    sprintf("standard deviation %s", signif(stats::sd(big$y), 3)),
    fixed = TRUE
  )

  tiny <- dat
  tiny$y <- tiny$y / 1000
  expect_warning(
    hs_cov_route(form, tiny, jl(target = "random_regression")),
    "far from unit scale",
    fixed = TRUE
  )

  expect_no_warning(hs_cov_route(form, dat, jl(target = "random_regression")))

  const <- dat
  const$y <- 1
  expect_no_warning(hs_cov_route(form, const, jl(target = "random_regression")))
})

# ---- genetic GLLVM routing --------------------------------------------------

hs_cov_gllvm_control <- function(...) {
  values <- utils::modifyList(
    list(
      target = "genetic_gllvm",
      genetic_structure = "lowrank",
      rank = 2L,
      experimental_gllvm = TRUE,
      julia_project = "/tmp/HSquared.jl"
    ),
    list(...)
  )
  hs_control(engine = "julia", engine_control = values)
}

hs_cov_gllvm_data <- function(order = letters[1:8]) {
  counts <- data.frame(
    id = letters[1:8],
    t1 = c(2L, 0L, 1L, 4L, 3L, 1L, 0L, 2L),
    t2 = c(1L, 3L, 0L, 2L, 5L, 1L, 2L, 0L),
    t3 = c(0L, 1L, 2L, 1L, 0L, 3L, 1L, 4L),
    stringsAsFactors = FALSE
  )
  counts[match(order, counts$id), ]
}

test_that("genetic GLLVM routes complete Poisson counts and returns a row order that recovers pedigree order", {
  hs_cov_stub_fitters()
  gped <- data.frame(
    id = letters[1:8],
    sire = NA_character_,
    dam = NA_character_,
    stringsAsFactors = FALSE
  )
  truth <- hs_cov_gllvm_data()
  expected_Y <- as.matrix(truth[, c("t1", "t2", "t3")])

  for (order in list(letters[1:8], rev(letters[1:8]), c("c", "a", "h", "b", "g", "d", "f", "e"))) {
    gdat <- hs_cov_gllvm_data(order)
    out <- hsquared(
      cbind(t1, t2, t3) ~ animal(1 | id, pedigree = gped),
      data = gdat,
      family = stats::poisson(),
      control = hs_cov_gllvm_control()
    )
    expect_identical(out$route, "gllvm")
    expect_identical(out$args$project, "/tmp/HSquared.jl")
    expect_identical(out$args$iterations, 1000L)
    expect_type(out$args$row_order, "integer")
    expect_setequal(out$args$row_order, 1:8)
    recovered <- unname(out$payload$Y[out$args$row_order, , drop = FALSE])
    expect_equal(recovered, unname(expected_Y))
    expect_identical(
      out$payload$method,
      "Laplace integrated fixed-effects objective"
    )
    expect_null(out$payload$metadata$julia_spec_target)
    expect_match(
      out$payload$metadata$julia_fit_target,
      "HSquared.fit_gllvm_laplace_reml(Y, Ainv, PoissonResponse(); rank = 2, structure = :lowrank, X = X)",
      fixed = TRUE
    )
  }

  out <- hsquared(
    cbind(t1, t2, t3) ~ animal(1 | id, pedigree = gped),
    data = hs_cov_gllvm_data(),
    family = stats::poisson(),
    control = hs_cov_gllvm_control(iterations = 55)
  )
  expect_identical(out$args$iterations, 55)
})

test_that("genetic GLLVM refuses incomplete expert controls, other families and incomplete data", {
  hs_cov_stub_fitters()
  gped <- data.frame(
    id = letters[1:8],
    sire = NA_character_,
    dam = NA_character_,
    stringsAsFactors = FALSE
  )
  form <- cbind(t1, t2, t3) ~ animal(1 | id, pedigree = gped)
  gdat <- hs_cov_gllvm_data()

  expect_error(
    hsquared(form, data = gdat, family = stats::poisson(),
             control = hs_cov_gllvm_control(experimental_gllvm = FALSE)),
    "Genetic GLLVM requires explicit engine = \"julia\" and engine_control =",
    fixed = TRUE,
    class = "hsquared_unsupported_syntax"
  )
  expect_error(
    hsquared(form, data = gdat, family = stats::gaussian(),
             control = hs_cov_gllvm_control()),
    "The requested family `gaussian(identity)` is not fitted on this path.",
    fixed = TRUE,
    class = "hsquared_unsupported_syntax"
  )
  zero <- gdat
  zero$t2 <- 0L
  expect_error(
    hsquared(form, data = zero, family = stats::poisson(),
             control = hs_cov_gllvm_control()),
    "An all-zero Poisson trait has no finite intercept mode",
    fixed = TRUE,
    class = "hsquared_unsupported_syntax"
  )
  expect_error(
    hsquared(form, data = gdat, family = stats::poisson(),
             control = hs_cov_gllvm_control(scale_method = "auto")),
    "`engine_control` key `scale_method` is not honoured by `target = \"genetic_gllvm\"`",
    fixed = TRUE,
    class = "hsquared_unsupported_syntax"
  )
})
