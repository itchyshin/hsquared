test_that("hs_control stores validated defaults", {
  control <- hs_control()

  expect_s3_class(control, "hs_control")
  expect_equal(control$engine, "fit")
  expect_equal(control$backend, "auto")
  expect_equal(control$accelerator, "auto")
  expect_equal(control$precision, "float64")
  expect_equal(control$save, "minimal")
  expect_equal(control$engine_control, list())
})

test_that("hs_control validates engine selection", {
  control <- hs_control(
    engine = "julia",
    engine_control = list(
      initial = c(sigma_a2 = 1, sigma_e2 = 1),
      target = "henderson_mme",
      variance_components = c(sigma_a2 = 1.2, sigma_e2 = 0.8)
    )
  )

  expect_equal(control$engine, "julia")
  expect_equal(control$engine_control$initial, c(sigma_a2 = 1, sigma_e2 = 1))
  expect_equal(control$engine_control$target, "henderson_mme")
  expect_equal(
    control$engine_control$variance_components,
    c(sigma_a2 = 1.2, sigma_e2 = 0.8)
  )

  expect_error(
    hs_control(engine = "not-an-engine"),
    "'arg' should be one of",
    fixed = TRUE
  )
})

test_that("hs_control preserves planned backend vocabulary", {
  expect_equal(hs_control(backend = "threads")$backend, "threads")
  expect_equal(hs_control(backend = "cuda")$backend, "cuda")
  expect_equal(hs_control(backend = "amdgpu")$backend, "amdgpu")
  expect_equal(hs_control(backend = "metal")$backend, "metal")
  expect_equal(hs_control(backend = "oneapi")$backend, "oneapi")
  expect_equal(hs_control(accelerator = "gpu")$accelerator, "gpu")
  expect_equal(hs_control(accelerator = "metal")$accelerator, "metal")
  expect_equal(hs_control(accelerator = "amdgpu")$accelerator, "amdgpu")
  expect_equal(hs_control(accelerator = "oneapi")$accelerator, "oneapi")

  expect_error(hs_control(backend = "tpu"), "'arg' should be one of")
  expect_error(hs_control(accelerator = "tpu"), "'arg' should be one of")
})

test_that("backend_info separates control vocabulary from execution", {
  info <- backend_info(hs_control(backend = "metal"))

  expect_s3_class(info, "hs_backend_info")
  expect_equal(
    info$backend,
    c("cpu", "threads", "cuda", "amdgpu", "metal", "oneapi")
  )
  expect_true(info$requested[info$backend == "metal"])
  expect_true(all(info$selectable))
  expect_false(any(info$execution_available))
  expect_true(all(info$status == "planned"))

  gpu_info <- backend_info(hs_control(accelerator = "gpu"))
  expect_true(all(
    gpu_info$requested[
      gpu_info$backend %in%
        c(
          "cuda",
          "amdgpu",
          "metal",
          "oneapi"
        )
    ]
  ))

  expect_error(
    backend_info(control = list()),
    "`control` must be created by `hs_control\\(\\)`."
  )
})

test_that("formula_status separates parsed, reserved, and planned grammar", {
  status <- formula_status()

  expect_s3_class(status, "hs_formula_status")
  expect_equal(nrow(status), 30L)
  expect_true("term" %in% names(status))
  expect_true("syntax_status" %in% names(status))
  expect_true("fitting_status" %in% names(status))
  expect_equal(
    status$syntax_status[status$term == "animal(1 | id, pedigree = ped)"],
    "parsed"
  )
  expect_equal(
    status$syntax_status[
      status$term == "animal(1 | id) with data = hs_data(..., pedigree = ped)"
    ],
    "parsed"
  )
  expect_true(all(
    status$fitting_status[status$syntax_status != "parsed"] == "not available"
  ))
  expect_true("permanent(1 | id)" %in% status$term)
  expect_true("genomic(1 | id, Ginv = Ginv)" %in% status$term)
  rr_term <- "animal(rr(covariate, order = 2) | id, pedigree = ped)"
  expect_true(rr_term %in% status$term)
  expect_equal(status$syntax_status[status$term == rr_term], "parsed")
  expect_equal(
    status$fitting_status[status$term == rr_term],
    "fitted (opt-in random-regression)"
  )
  expect_equal(
    status$fitting_status[
      status$term == "cbind(trait1, trait2) ~ animal(1 | id, pedigree = ped)"
    ],
    "fitted (opt-in multivariate)"
  )
  expect_true(all(
    c(
      "animal(trait | id, pedigree = ped, cov = us())",
      "animal(trait | id, pedigree = ped, cov = diag())",
      "animal(trait | id, pedigree = ped, cov = lowrank(K = 2))",
      "animal(trait | id, pedigree = ped, cov = fa(K = 2))"
    ) %in%
      status$term
  ))
  expect_true(all(
    status$syntax_status[grepl("cov =", status$term, fixed = TRUE)] == "planned"
  ))
  expect_true(any(status$syntax_status == "planned"))
  expect_match(capture.output(print(status))[[1L]], "<hs_formula_status>")
  expect_match(
    paste(capture.output(print(status)), collapse = "\n"),
    "permanent\\(1 \\| id\\)"
  )
  expect_match(
    paste(capture.output(print(status)), collapse = "\n"),
    "planned grammar: rows marked planned/reserved error before fitting",
    fixed = TRUE
  )
  subset <- status[
    status$category == "multivariate and factor analytic",
    c("term", "syntax_status", "fitting_status")
  ]
  expect_s3_class(subset, "hs_formula_status")
  expect_output(print(subset), "cov = lowrank")
})

test_that("validation_status separates evidence from planned validation", {
  status <- validation_status()

  expect_s3_class(status, "hs_validation_status")
  expect_equal(nrow(status), 21L)
  expect_equal(
    status$status[
      status$capability ==
        "experimental supplied-relationship estimator (opt-in: genomic, single-step)"
    ],
    "partial"
  )
  expect_equal(
    status$status[
      status$capability == "experimental repeatability estimator (opt-in)"
    ],
    "partial"
  )
  expect_equal(
    status$status[
      status$capability == "experimental multivariate REML estimator (opt-in)"
    ],
    "partial"
  )
  expect_equal(
    status$status[
      status$capability ==
        "experimental two-effect estimator (opt-in: common-env, maternal)"
    ],
    "partial"
  )
  expect_true(all(
    c("capability", "phase", "status", "evidence", "claim_boundary") %in%
      names(status)
  ))
  expect_equal(
    status$status[
      status$capability == "supplied-variance Henderson MME fixture"
    ],
    "partial"
  )
  expect_equal(
    status$status[status$capability == "sparse REML likelihood identity"],
    "partial"
  )
  expect_equal(
    status$status[
      status$capability == "Mrode-style supplied-variance outputs"
    ],
    "partial"
  )
  expect_equal(
    status$status[
      status$capability == "experimental sparse REML estimator (opt-in)"
    ],
    "partial"
  )
  expect_equal(
    status$status[
      status$capability ==
        "univariate Gaussian animal-model fit (default path, AI-REML)"
    ],
    "covered"
  )
  expect_equal(
    status$status[
      status$capability ==
        "external published-REML recovery (gryphon, R reference)"
    ],
    "covered"
  )
  expect_equal(
    status$status[
      status$capability ==
        "known-truth DGP variance-component recovery (R reference)"
    ],
    "covered"
  )
  expect_equal(
    status$status[status$capability == "ASReml comparison policy"],
    "planned"
  )
  multivariate_row <- status[
    status$capability == "experimental multivariate REML estimator (opt-in)",
  ]
  expect_equal(multivariate_row$status, "partial")
  expect_match(
    multivariate_row$evidence,
    "100-replicate cold-start t=2 known-truth recovery study",
    fixed = TRUE
  )
  expect_match(
    multivariate_row$evidence,
    "full-unstructured residual sommer comparator",
    fixed = TRUE
  )
  expect_match(
    multivariate_row$claim_boundary,
    "covered promotion remains twin-gated",
    fixed = TRUE
  )
  expect_match(
    multivariate_row$claim_boundary,
    "published or Mrode-style multivariate target",
    fixed = TRUE
  )
  expect_match(
    multivariate_row$claim_boundary,
    "another independent same-estimand comparator",
    fixed = TRUE
  )
  expect_match(
    status$claim_boundary[
      status$capability == "CPU/GPU backend comparison"
    ],
    "no backend execution",
    fixed = TRUE
  )
  expect_match(capture.output(print(status))[[1L]], "<hs_validation_status>")
  expect_match(
    paste(capture.output(print(status)), collapse = "\n"),
    "supplied-variance Henderson MME fixture"
  )
})

test_that("hs_control validates engine_control", {
  expect_error(
    hs_control(engine_control = "not-a-list"),
    "`engine_control` must be a list.",
    fixed = TRUE
  )

  expect_error(
    hs_control(engine_control = list(1)),
    "`engine_control` must be a named list.",
    fixed = TRUE
  )
})

test_that("hsquared validates basic call shape", {
  expect_error(hsquared(), "`formula` is required.", fixed = TRUE)

  expect_error(hsquared(y ~ x), "`data` is required.", fixed = TRUE)

  expect_error(
    hsquared(y ~ x, data = data.frame(y = 1, x = 1), control = list()),
    "`control` must be created by `hs_control()`.",
    fixed = TRUE
  )
})

test_that("the validate engine validates and returns the spec without fitting", {
  ped <- data.frame(
    id = c("a", "b", "c", "d"),
    sire = c(NA, NA, "a", "a"),
    dam = c(NA, NA, "b", "c")
  )
  dat <- data.frame(
    y = c(1, 2, 3),
    sex = c("f", "m", "f"),
    age = c(1, 2, 3),
    id = c("a", "c", "d")
  )

  # `engine = "validate"` confirms the contract with a message and returns the
  # validated spec invisibly (it no longer stops), so it can be inspected.
  expect_message(
    spec <- hsquared(
      y ~ sex + age + animal(1 | id, pedigree = ped),
      data = dat,
      control = hs_control(engine = "validate")
    ),
    "Validated the v0.1 animal-model contract",
    fixed = TRUE
  )
  expect_type(spec, "list")
  expect_match(spec$bridge$target, "fit_animal_model", fixed = TRUE)
})

test_that("the default engine fits, and errors clearly without the Julia engine", {
  ped <- data.frame(
    id = c("a", "b", "c"),
    sire = c(NA, NA, "a"),
    dam = c(NA, NA, "b")
  )
  dat <- data.frame(
    y = c(1, 2, 3),
    sex = c("m", "f", "m"),
    id = c("a", "b", "c")
  )

  # Default engine = "fit"; with no Julia engine available it errors with
  # actionable install guidance rather than silently doing nothing.
  expect_error(
    hsquared(
      y ~ sex + animal(1 | id, pedigree = ped),
      data = dat,
      control = hs_control(
        engine = "fit",
        engine_control = list(julia_project = tempfile())
      )
    ),
    "requires the HSquared.jl Julia",
    fixed = TRUE
  )
})

test_that("the default fit path rejects REML = FALSE rather than mislabeling ML", {
  ped <- data.frame(
    id = c("a", "b", "c"),
    sire = c(NA, NA, "a"),
    dam = c(NA, NA, "b")
  )
  dat <- data.frame(
    y = c(1, 2, 3),
    sex = c("m", "f", "m"),
    id = c("a", "b", "c")
  )

  # The default fit path estimates variance components by REML only. A
  # `REML = FALSE` request must be rejected honestly (ML is not implemented),
  # not silently run as REML and returned mislabeled as "ML". This is a pure
  # request-validity error, so it fires before any Julia-engine check.
  expect_error(
    hsquared(
      y ~ sex + animal(1 | id, pedigree = ped),
      data = dat,
      family = stats::gaussian(),
      REML = FALSE
    ),
    "ML estimation",
    fixed = TRUE
  )
})
