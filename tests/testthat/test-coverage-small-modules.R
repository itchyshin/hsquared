# Coverage lane for the small pure-R modules: G-matrix geometry guards and
# closed forms (R/evolvability.R), formula_status() printing, condition-helper
# edges (R/conditions.R) and the internal alignment guards of
# R/bridge-payload.R.

hs_cov_geo_fit <- function(G) {
  hsquared:::hs_new_fit(
    spec = list(target = "multivariate", method = "REML", family = list(family = "gaussian")),
    payload = list(),
    result = list(genetic_covariance = G, converged = TRUE)
  )
}

# ---- G-matrix geometry ------------------------------------------------------------

test_that("every geometry metric refuses a non-fit and a fit without a G matrix", {
  for (fn in c(
    "evolvability", "respondability", "conditional_evolvability", "autonomy",
    "mean_evolvability", "g_max", "variance_along_gradient"
  )) {
    f <- get(fn)
    expect_error(
      if (fn %in% c("mean_evolvability", "g_max")) f(1) else f(1, c(1, 0)),
      paste0("`", fn, "()` requires an `hsquared_fit` object."),
      fixed = TRUE,
      info = fn
    )
  }
  bare <- hsquared:::hs_new_fit(spec = list(), payload = list(), result = list())
  expect_error(
    g_max(bare),
    "G-matrix geometry requires a multivariate fit that reports a `genetic_covariance()` matrix",
    fixed = TRUE
  )
  expect_error(
    hsquared:::hs_fit_genetic_G(list()),
    "`object` must be an `hsquared_fit` object.",
    fixed = TRUE
  )
})

test_that("a malformed genetic covariance is refused with the specific reason", {
  expect_error(
    g_max(hs_cov_geo_fit(matrix(1, 2, 3))),
    "The genetic covariance matrix must be square.",
    fixed = TRUE
  )
  expect_error(
    g_max(hs_cov_geo_fit(matrix(c(1, NA, 0, 1), 2))),
    "The genetic covariance matrix must be finite.",
    fixed = TRUE
  )
  expect_error(
    g_max(hs_cov_geo_fit(matrix(c(1, 0.5, 0, 1), 2))),
    "The genetic covariance matrix must be symmetric.",
    fixed = TRUE
  )
  expect_error(
    g_max(hs_cov_geo_fit(matrix(c(1, 2, 2, 1), 2))),
    "The genetic covariance matrix must be positive semidefinite.",
    fixed = TRUE
  )
})

test_that("a singular G has g_max but no conditional evolvability or autonomy", {
  singular <- hs_cov_geo_fit(matrix(c(1, 1, 1, 1), 2))
  expect_equal(g_max(singular)$eigenvalue, 2)
  expect_error(
    conditional_evolvability(singular, c(1, 0)),
    "requires a positive-definite genetic covariance matrix",
    fixed = TRUE
  )
  expect_error(
    autonomy(singular, c(1, 0)),
    "requires a positive-definite genetic covariance matrix",
    fixed = TRUE
  )
})

test_that("geometry metrics equal their closed forms for G = [[2, 1], [1, 2]]", {
  fit <- hs_cov_geo_fit(matrix(c(2, 1, 1, 2), 2))
  e1 <- c(1, 0)
  diag_dir <- c(1, 1)

  expect_equal(evolvability(fit, e1), 2)
  expect_equal(evolvability(fit, diag_dir), 3)
  expect_equal(evolvability(fit, 10 * diag_dir), evolvability(fit, diag_dir))
  expect_equal(evolvability(fit, c(1, -1)), 1)

  expect_equal(respondability(fit, e1), sqrt(2^2 + 1^2))
  expect_equal(respondability(fit, diag_dir), 3)

  Ginv <- matrix(c(2, -1, -1, 2), 2) / 3
  expect_equal(conditional_evolvability(fit, e1), 1 / Ginv[1, 1])
  expect_equal(conditional_evolvability(fit, e1), 1.5)
  expect_equal(autonomy(fit, e1), 1.5 / 2)
  expect_equal(autonomy(fit, diag_dir), 1)

  expect_equal(mean_evolvability(fit), 2)
  gm <- g_max(fit)
  expect_equal(gm$eigenvalue, 3)
  expect_equal(gm$eigenvector, c(1, 1) / sqrt(2))

  expect_equal(variance_along_gradient(fit, diag_dir), 3)
  expect_equal(variance_along_gradient(fit, diag_dir, normalize = FALSE), 6)
  expect_equal(variance_along_gradient(fit, c(2, 0), normalize = FALSE), 8)
})

test_that("direction vectors are validated before any metric is computed", {
  fit <- hs_cov_geo_fit(diag(2))
  expect_error(
    evolvability(fit, c(1, 0, 0)),
    "`direction` must be a numeric vector with one entry per trait (length 2).",
    fixed = TRUE
  )
  expect_error(
    evolvability(fit, "a"),
    "`direction` must be a numeric vector with one entry per trait (length 2).",
    fixed = TRUE
  )
  expect_error(
    evolvability(fit, c(1, NA)),
    "`direction` must contain only finite values.",
    fixed = TRUE
  )
  expect_error(
    evolvability(fit, c(0, 0)),
    "`direction` must be a nonzero direction.",
    fixed = TRUE
  )
  for (bad in list(c(1, Inf), c(1, 2, 3), "a")) {
    expect_error(
      variance_along_gradient(fit, bad, normalize = FALSE),
      "`direction` must be a finite numeric vector with one entry per trait (length 2).",
      fixed = TRUE
    )
  }
})

# ---- formula_status() printing ----------------------------------------------------

test_that("short term labels collapse each grammar family to its function name", {
  short <- hsquared:::hs_formula_status_short_term
  expect_identical(short("cbind(a, b)"), "cbind()")
  expect_identical(short("animal(rr(age, order = 2) | id)"), "animal(rr())")
  expect_identical(short("animal(1 | id, pedigree = ped)"), "animal()")
  expect_identical(short("(1 | group)"), "(1 | group)")
  expect_identical(short("missing = miss_control(...)"), "miss_control()")
  expect_identical(short("mi(x)"), "mi()")
  expect_identical(short("permanent(1 | id)"), "permanent()")
  expect_identical(short("plain"), "plain")
})

test_that("category lists stay on one line when short and wrap when long", {
  cat_list <- hsquared:::hs_formula_status_cat_list
  expect_identical(
    paste(utils::capture.output(cat_list("default", c("a", "b", "a"))), collapse = "\n"),
    "  default: a; b"
  )
  expect_identical(utils::capture.output(cat_list("default", character())), character())
  long <- paste0("term_", 1:30)
  out <- utils::capture.output(cat_list("opt-in", long))
  expect_identical(out[[1L]], "  opt-in: ")
  expect_gt(length(out), 2L)
  expect_true(all(nchar(out[-1L]) <= 74L))
  expect_identical(
    unlist(regmatches(out[-1L], gregexpr("term_[0-9]+", out[-1L]))),
    long
  )
})

test_that("a status frame without the display columns prints every column", {
  status <- structure(
    data.frame(topic = c("x", "y"), note = c("p", "q")),
    class = c("hs_formula_status", "data.frame")
  )
  text <- paste(utils::capture.output(returned <- print(status)), collapse = "\n")
  expect_identical(returned, status)
  expect_match(text, "<hs_formula_status>", fixed = TRUE)
  expect_match(text, "topic note", fixed = TRUE)
  expect_match(text, "x    p", fixed = TRUE)
})

# ---- condition helpers ------------------------------------------------------------

test_that("opt-in term labels and route notes name each route and fall back for unknown ones", {
  label <- hsquared:::hs_opt_in_term_label
  expect_identical(label("common_env"), "common_env()")
  expect_identical(label("permanent"), "permanent()")
  expect_identical(label("maternal_genetic"), "maternal_genetic()")
  expect_identical(label("iid_effects"), "(1 | group)")
  expect_identical(label("random_regression"), "rr(...)")
  expect_identical(label("mystery"), "mystery()")

  note <- hsquared:::hs_opt_in_route_note
  expect_match(note("common_env"), "covered for point estimates only", fixed = TRUE)
  expect_match(note("permanent"), "That route is experimental.", fixed = TRUE)
  expect_match(note("maternal_genetic"), "`target = \"direct_maternal\"` is covered for point estimates only", fixed = TRUE)
  expect_match(note("random_regression"), "Higher order is experimental.", fixed = TRUE)
  expect_match(note("mystery"), "experimental and opt-in. See formula_status().", fixed = TRUE)
})

test_that("the maternal opt-in abort names the covered direct-maternal alternative", {
  err <- expect_error(
    hsquared:::hs_abort_opt_in_next_call(
      "maternal_genetic",
      quote(y ~ animal(1 | id, pedigree = ped) + maternal_genetic(1 | dam)),
      "dat"
    ),
    "`maternal_genetic()` is not on the default path.",
    fixed = TRUE,
    class = "hsquared_unsupported_syntax"
  )
  msg <- conditionMessage(err)
  expect_match(msg, "Covered alternative (Willham triple, not a scalar h2):", fixed = TRUE)
  expect_match(msg, "target = \"two_effect\"", fixed = TRUE)
  expect_match(msg, "target = \"direct_maternal\"", fixed = TRUE)

  rr <- expect_error(
    hsquared:::hs_abort_opt_in_next_call(
      "random_regression",
      quote(y ~ animal(rr(age, order = 2) | id, pedigree = ped)),
      "dat",
      target = "ignored"
    ),
    "`rr(...)` is not on the default path.",
    fixed = TRUE,
    class = "hsquared_unsupported_syntax"
  )
  expect_match(conditionMessage(rr), "target = \"random_regression\"", fixed = TRUE)
})

test_that("the public control lookup finds only an hs_control bound as `control` in an hsquared() frame", {
  lookup <- hsquared:::hs_public_hsquared_control

  hsquared <- function(control) lookup()
  expect_identical(hsquared(control = hs_control()), hs_control())
  expect_null(hsquared(control = "not a control"))
  expect_null(hsquared(control = NULL))

  no_control_binding <- function() {
    hsquared <- function() lookup()
    hsquared()
  }
  expect_null(no_control_binding())

  expect_null(lookup())
})

test_that("REML = FALSE on the public path is refused only for the validate and fit engines", {
  abort <- hsquared:::hs_abort_reml_false_on_public_path
  expect_false(abort(TRUE))
  expect_false(abort(FALSE))

  hsquared <- function(control, REML) abort(REML)
  expect_false(hsquared(hs_control(engine = "julia"), REML = FALSE))
  expect_error(
    hsquared(hs_control(engine = "validate"), REML = FALSE),
    "REML",
    fixed = TRUE
  )
})

test_that("repeated-record and rr-scale warnings stay silent when their inputs are missing", {
  expect_false(hsquared:::hs_warn_unmodelled_repeated_records(list(random = list())))
  no_values <- list(random = list(animal = list(values = NULL)))
  expect_false(hsquared:::hs_warn_unmodelled_repeated_records(no_values))

  expect_false(hsquared:::hs_warn_rr_response_scale(list(response = list(values = NULL))))
  expect_false(hsquared:::hs_warn_rr_response_scale(list(response = list(values = 1))))
  expect_false(hsquared:::hs_warn_rr_response_scale(list(response = list(values = c(3, 3, 3)))))
  expect_false(hsquared:::hs_warn_rr_response_scale(list(response = list(values = c(1, 2, 3)))))
  expect_true(
    suppressWarnings(
      hsquared:::hs_warn_rr_response_scale(
        list(response = list(name = "milk", values = c(1000, 5000, 9000)))
      )
    )
  )
})

# ---- bridge-payload alignment guards -----------------------------------------------

test_that("payload builders refuse record IDs that are not in the validated pedigree or Hinv", {
  ped <- data.frame(id = c("a", "b", "c"), sire = c(NA, NA, "a"), dam = c(NA, NA, "b"))
  dat <- data.frame(y = c(1, 2, 3), id = c("a", "b", "c"))
  spec <- hsquared:::hs_build_model_spec(
    y ~ animal(1 | id, pedigree = ped),
    data = dat,
    family = stats::gaussian(),
    REML = TRUE
  )
  spec$random$animal$values <- c("a", "b", "zzz")
  expect_error(
    hsquared:::hs_build_bridge_payload(spec),
    "Internal bridge error: observed animal IDs are not aligned with the validated pedigree.",
    fixed = TRUE
  )

  primary <- list(values = c("a", "q"), ids = c("a", "b"))
  expect_error(
    hsquared:::hs_build_relinv_bridge_payload(list(), primary),
    "Internal bridge error: observed IDs are not aligned with the relationship-inverse dimnames.",
    fixed = TRUE
  )
})
