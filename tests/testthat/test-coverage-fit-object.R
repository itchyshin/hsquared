# Coverage lane for R/fit-object.R, R/model-spec-inspect.R and R/backend-info.R:
# the constructor guards, print/summary methods and label helpers of a fit
# object assembled by hand (no Julia). Printed numbers are checked against the
# closed form h2 = sigma_a^2 / (sigma_a^2 + sigma_e^2).

hs_cov_fit <- function(result = list(), spec = list(), call = NULL, payload = list(y = 1:4)) {
  base_spec <- list(method = "REML", family = list(family = "gaussian"))
  hsquared:::hs_new_fit(
    call = call,
    spec = utils::modifyList(base_spec, spec),
    payload = payload,
    result = utils::modifyList(
      list(
        variance_components = data.frame(
          component = c("animal", "residual"),
          estimate = c(0.6, 0.4)
        ),
        converged = TRUE
      ),
      result
    )
  )
}

hs_cov_out <- function(x) paste(utils::capture.output(print(x)), collapse = "\n")

test_that("hs_new_fit refuses non-list spec, payload or result", {
  expect_error(
    hsquared:::hs_new_fit(spec = "x", payload = list(), result = list()),
    "`spec` must be a list.",
    fixed = TRUE
  )
  expect_error(
    hsquared:::hs_new_fit(spec = list(), payload = 1, result = list()),
    "`payload` must be a list.",
    fixed = TRUE
  )
  expect_error(
    hsquared:::hs_new_fit(spec = list(), payload = list(), result = NULL),
    "`result` must be a list.",
    fixed = TRUE
  )
  fit <- hs_cov_fit()
  expect_s3_class(fit, "hsquared_fit")
  expect_identical(fit$version, as.character(utils::packageVersion("hsquared")))
})

test_that("the target label defaults to the default animal model and otherwise names the target", {
  expect_identical(hsquared:::hs_fit_target_label(hs_cov_fit()), "default animal")
  expect_identical(
    hsquared:::hs_fit_target_label(hs_cov_fit(spec = list(target = ""))),
    "default animal"
  )
  expect_identical(
    hsquared:::hs_fit_target_label(hs_cov_fit(spec = list(target = "repeatability"))),
    "repeatability"
  )
})

test_that("the formula label comes from the spec, then the recorded call, else is absent", {
  f <- y ~ sex + animal(1 | id, pedigree = ped)
  from_spec <- hs_cov_fit(spec = list(formula = f))
  expect_identical(
    hsquared:::hs_fit_formula_label(from_spec),
    "y ~ sex + animal(1 | id, pedigree = ped)"
  )
  from_call <- hs_cov_fit(call = quote(hsquared(y ~ x + animal(1 | id), data = d)))
  expect_identical(
    hsquared:::hs_fit_formula_label(from_call),
    "y ~ x + animal(1 | id)"
  )
  expect_null(hsquared:::hs_fit_formula_label(hs_cov_fit()))
  expect_null(hsquared:::hs_fit_formula_label(hs_cov_fit(call = quote(hsquared()))))
})

test_that("a missing result field names the target and points scan fields at gwas()", {
  fit <- hs_cov_fit(spec = list(target = "ai_reml"))
  err <- expect_error(
    hsquared:::hs_fit_result(fit, "lod_scores", "LOD scores"),
    "does not contain LOD scores"
  )
  msg <- conditionMessage(err)
  expect_match(msg, "(target = \"ai_reml\")", fixed = TRUE)
  expect_match(msg, "Use `gwas(fit, markers)` for a marker scan", fixed = TRUE)

  plain <- expect_error(
    hsquared:::hs_fit_result(fit, "something_else", "something else"),
    "does not contain something else"
  )
  expect_false(grepl("gwas(", conditionMessage(plain), fixed = TRUE))

  expect_error(
    hsquared:::hs_fit_result(list(), "x", "x"),
    "`object` must be an `hsquared_fit` object.",
    fixed = TRUE
  )
})

test_that("a fit made with skip_pev_reliability explains the missing PEV and reliability", {
  skipped <- hs_cov_fit(result = list(diagnostics = list(skip_pev_reliability = TRUE)))
  for (field in c("prediction_error_variance", "reliability")) {
    expect_error(
      hsquared:::hs_fit_result(skipped, field, field),
      "refit without it to get prediction error variances and reliability.",
      fixed = TRUE
    )
  }
  expect_identical(hsquared:::hs_fit_result_skipped_hint(skipped, "lod_scores"), "")
  not_skipped <- hs_cov_fit()
  expect_identical(
    hsquared:::hs_fit_result_skipped_hint(not_skipped, "reliability"),
    ""
  )
})

test_that("print shows heritability from a data frame, a bare scalar, or nothing", {
  h2 <- 0.6 / (0.6 + 0.4)
  unlabeled <- hs_cov_fit(result = list(heritability = data.frame(estimate = h2)))
  expect_match(hs_cov_out(unlabeled), "heritability: 1=0.6", fixed = TRUE)

  by_component <- hs_cov_fit(
    result = list(heritability = data.frame(component = "animal", estimate = h2))
  )
  expect_match(hs_cov_out(by_component), "heritability: animal=0.6", fixed = TRUE)

  by_term <- hs_cov_fit(
    result = list(heritability = data.frame(term = "h2_T", estimate = h2))
  )
  expect_match(hs_cov_out(by_term), "heritability: h2_T=0.6", fixed = TRUE)

  scalar <- hs_cov_fit(result = list(heritability = h2))
  expect_match(hs_cov_out(scalar), "heritability: 0.6", fixed = TRUE)

  none <- hs_cov_fit()
  expect_false(grepl("heritability:", hs_cov_out(none), fixed = TRUE))
  utils::capture.output(returned <- print(none))
  expect_identical(returned, none)
})

test_that("print reports the genomic boundary status and both endpoints only at a boundary", {
  boundary <- list(
    status = "boundary_lower",
    profile_ratio = 0,
    numerical_ratio = 1e-8
  )
  at <- hs_cov_fit(result = list(genomic_boundary = boundary))
  text <- hs_cov_out(at)
  expect_match(text, "genomic boundary status: boundary_lower", fixed = TRUE)
  expect_match(text, "genomic ratio (scientific endpoint): 0", fixed = TRUE)
  expect_match(text, "genomic ratio (numerical MME): 1e-08", fixed = TRUE)

  interior <- hs_cov_fit(
    result = list(genomic_boundary = list(status = "interior"))
  )
  text <- hs_cov_out(interior)
  expect_match(text, "genomic boundary status: interior", fixed = TRUE)
  expect_false(grepl("genomic ratio", text, fixed = TRUE))

  sm_at <- utils::capture.output(print(summary(at)))
  expect_true(any(grepl("genomic boundary status: boundary_lower", sm_at, fixed = TRUE)))
  expect_true(any(grepl("genomic ratio (scientific endpoint): 0", sm_at, fixed = TRUE)))
  expect_true(any(grepl("genomic ratio (numerical MME): 1e-08", sm_at, fixed = TRUE)))
  sm_in <- utils::capture.output(print(summary(interior)))
  expect_true(any(grepl("genomic boundary status: interior", sm_in, fixed = TRUE)))
  expect_false(any(grepl("genomic ratio", sm_in, fixed = TRUE)))
})

test_that("a non-converged fit is not reportable and warns once", {
  fit <- hs_cov_fit(
    result = list(converged = FALSE, heritability = data.frame(estimate = 1e-9))
  )
  expect_warning(
    text <- hs_cov_out(fit),
    "did not converge",
    fixed = TRUE
  )
  expect_match(text, "heritability: not reportable (fit did not converge)", fixed = TRUE)
})

test_that("the multivariate non-convergence warning names the iteration count", {
  fit <- hs_cov_fit(
    spec = list(target = "multivariate"),
    result = list(converged = FALSE, diagnostics = list(iterations = 2000))
  )
  expect_warning(
    hsquared:::hs_warn_if_unusable_fit(fit),
    "The optimizer used 2000 iterations. If that is the requested limit, retry with a larger `engine_control$iterations` value.",
    fixed = TRUE
  )
})

test_that("a near-boundary converged fit warns that the number is not an interior estimate", {
  fit <- hs_cov_fit(
    result = list(
      variance_components = data.frame(
        component = c("animal", "residual"),
        estimate = c(1e-9, 1)
      )
    )
  )
  expect_warning(
    hsquared:::hs_warn_if_unusable_fit(fit),
    "at a variance-component boundary",
    fixed = TRUE
  )
  expect_false(hsquared:::hs_warn_if_unusable_fit(hs_cov_fit()))
})

test_that("a non-converged fit that is also at a boundary says so", {
  fit <- hs_cov_fit(
    result = list(
      converged = FALSE,
      variance_components = data.frame(
        component = c("animal", "residual"),
        estimate = c(1e-9, 1)
      )
    )
  )
  expect_warning(
    hsquared:::hs_warn_if_unusable_fit(fit),
    "A variance component is also at or near a boundary",
    fixed = TRUE
  )
})

test_that("a multivariate fit flags a genetic correlation at +/-1 and no other layout", {
  at_one <- matrix(c(1, 1, 1, 1), 2)
  fit <- hs_cov_fit(
    spec = list(target = "multivariate"),
    result = list(genetic_correlation = at_one)
  )
  expect_true(hsquared:::hs_fit_genetic_correlation_boundary(fit))
  expect_match(hs_cov_out(fit), "genetic correlation boundary: TRUE", fixed = TRUE)
  summ <- paste(utils::capture.output(print(summary(fit))), collapse = "\n")
  expect_match(summ, "genetic correlation boundary: TRUE", fixed = TRUE)

  interior <- hs_cov_fit(
    spec = list(target = "multivariate"),
    result = list(genetic_correlation = matrix(c(1, 0.4, 0.4, 1), 2))
  )
  expect_false(hsquared:::hs_fit_genetic_correlation_boundary(interior))

  for (bad in list(NULL, matrix(c(1, NA, NA, 1), 2), matrix(1, 1, 1), matrix(1, 2, 3), "x")) {
    odd <- hs_cov_fit(
      spec = list(target = "multivariate"),
      result = list(genetic_correlation = bad)
    )
    expect_null(hsquared:::hs_fit_genetic_correlation_boundary(odd))
  }
  univariate <- hs_cov_fit(result = list(genetic_correlation = at_one))
  expect_null(hsquared:::hs_fit_genetic_correlation_boundary(univariate))
})

test_that("summary print distinguishes an inadmissible negative variance from a clean boundary", {
  negative <- hs_cov_fit(
    result = list(
      variance_components = data.frame(
        component = c("animal", "residual"),
        estimate = c(-0.05, 1)
      )
    )
  )
  neg_text <- paste(utils::capture.output(print(summary(negative))), collapse = "\n")
  expect_match(neg_text, "a variance component is NEGATIVE", fixed = TRUE)

  zero <- hs_cov_fit(
    result = list(
      variance_components = data.frame(
        component = c("animal", "residual"),
        estimate = c(1e-9, 1)
      )
    )
  )
  zero_text <- paste(utils::capture.output(print(summary(zero))), collapse = "\n")
  expect_match(zero_text, "at/near zero", fixed = TRUE)
  expect_false(grepl("NEGATIVE", zero_text, fixed = TRUE))
})

test_that("summary print shows each uncertainty block only when the engine supplied it", {
  fit <- hs_cov_fit(
    spec = list(target = "ai_reml"),
    result = list(
      heritability_se = 0.05,
      heritability_interval = list(level = 0.95, lower = 0.45, upper = 0.72, method = "profile"),
      variance_component_se = data.frame(component = c("animal", "residual"), se = c(0.1, 0.2)),
      repeatability_interval = list(level = 0.9, lower = 0.3, upper = 0.5)
    )
  )
  text <- paste(utils::capture.output(print(summary(fit))), collapse = "\n")
  expect_match(text, "directional-conservative / not coverage-calibrated", fixed = TRUE)
  expect_match(text, "SE: 0.05", fixed = TRUE)
  expect_match(text, "95% CI: [0.45, 0.72] (profile)", fixed = TRUE)
  expect_match(text, "animal: 0.1", fixed = TRUE)
  expect_match(text, "residual: 0.2", fixed = TRUE)
  expect_match(text, "90% CI: [0.3, 0.5]", fixed = TRUE)

  other <- hs_cov_fit(
    spec = list(target = "multivariate"),
    result = list(
      heritability_se = 0.05,
      variance_component_se = data.frame(component = "animal", se = 0.1)
    )
  )
  other_text <- paste(utils::capture.output(print(summary(other))), collapse = "\n")
  expect_equal(
    lengths(regmatches(other_text, gregexpr("no coverage study for this route", other_text, fixed = TRUE))),
    2L
  )

  bare <- paste(utils::capture.output(print(summary(hs_cov_fit()))), collapse = "\n")
  expect_false(grepl("uncertainty", bare, fixed = TRUE))
})

test_that("summary suppresses uncertainty surfaces on a fit that is not reportable", {
  fit <- hs_cov_fit(
    result = list(converged = FALSE, heritability_se = 0.05)
  )
  expect_null(summary(fit)$heritability_se)
  expect_equal(summary(hs_cov_fit(result = list(heritability_se = 0.05)))$heritability_se, 0.05)
})

# ---- model_spec() and backend_info() --------------------------------------------

test_that("model_spec() requires formula and data and reserves its dots", {
  expect_error(model_spec(data = data.frame(y = 1)), "`formula` is required.", fixed = TRUE)
  expect_error(model_spec(y ~ 1), "`data` is required.", fixed = TRUE)
  ped <- data.frame(id = c("a", "b", "c"), sire = c(NA, NA, "a"), dam = c(NA, NA, "b"))
  dat <- data.frame(y = c(1, 2, 3), id = c("a", "b", "c"))
  expect_error(
    model_spec(y ~ animal(1 | id, pedigree = ped), data = dat, extra = 1),
    "`...` is reserved for future `model_spec()` options.",
    fixed = TRUE
  )
})

test_that("print and summary of a model_spec describe the preview, never a fit", {
  ped <- data.frame(id = c("a", "b", "c"), sire = c(NA, NA, "a"), dam = c(NA, NA, "b"))
  dat <- data.frame(y = c(1, 2, 3), sex = c("m", "f", "m"), id = c("a", "b", "c"))
  spec <- model_spec(y ~ sex + animal(1 | id, pedigree = ped), data = dat)
  text <- paste(utils::capture.output(print(spec)), collapse = "\n")
  expect_match(text, "<hs_model_spec>", fixed = TRUE)
  expect_match(text, "response: y", fixed = TRUE)
  expect_match(text, "family: gaussian(identity)", fixed = TRUE)
  expect_match(text, "method: REML", fixed = TRUE)
  expect_match(text, "observations: 3; fixed columns: 2; animal IDs: 3", fixed = TRUE)
  expect_match(text, "animal term: animal(1 | id, pedigree = ped); group: id", fixed = TRUE)
  expect_match(text, "sparse Z with 3 nonzero entries", fixed = TRUE)
  expect_match(text, "fitting: not run by `model_spec()`", fixed = TRUE)
  utils::capture.output(returned <- print(spec))
  expect_identical(returned, spec)

  summ <- summary(spec)
  out <- utils::capture.output(res <- print(summ))
  expect_identical(res, summ)
  expect_identical(out[[1L]], "<summary_hs_model_spec>")
  expect_gt(length(out), 1L)
})

test_that("backend_info reports every planned backend and prints the requested ones", {
  expect_error(
    backend_info(list(engine = "validate")),
    "`control` must be created by `hs_control()`.",
    fixed = TRUE
  )
  info <- backend_info(hs_control(backend = "threads"))
  expect_identical(info$backend, c("cpu", "threads", "cuda", "amdgpu", "metal", "oneapi"))
  expect_identical(info$requested, info$backend == "threads")
  expect_false(any(info$execution_available))
  expect_true(all(info$selectable))
  expect_identical(attr(info, "control")$backend, "threads")

  text <- paste(utils::capture.output(res <- print(info)), collapse = "\n")
  expect_identical(res, info)
  expect_match(text, "<hs_backend_info>", fixed = TRUE)
  expect_match(text, "requested backend: threads", fixed = TRUE)
  expect_match(text, "execution: metadata only; no backend dispatch yet", fixed = TRUE)
  expect_identical(
    info$note[info$backend == "threads"],
    "Planned multi-threaded CPU control; not dispatched by R yet."
  )
})

test_that("a gpu accelerator request marks every GPU backend as requested", {
  info <- backend_info(hs_control(accelerator = "gpu"))
  gpu <- c("cuda", "amdgpu", "metal", "oneapi")
  expect_identical(info$requested, info$backend %in% gpu)
  expect_match(info$note[info$backend == "metal"], "Apple/Mac accelerator", fixed = TRUE)
})
