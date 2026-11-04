test_that("Arc1 uncertainty controls fail closed and preserve exact UInt64 seeds", {
  profile_spec <- list(
    family = list(family = "gaussian"),
    response = list(multivariate = FALSE),
    random = list(permanent = list())
  )
  profile_payload <- list(
    pedigree = list(ids = c("a", "b")),
    Z = Matrix::sparseMatrix(i = 1:4, j = c(1, 1, 2, 2), x = 1, dims = c(4, 2))
  )
  profile <- hs_control(
    engine = "julia",
    engine_control = list(
      target = "repeatability",
      uncertainty_method = "arc1_profile_v1"
    )
  )
  expect_equal(
    hs_validate_arc1_uncertainty_control(
      profile,
      "repeatability",
      profile_spec,
      profile_payload
    )$method,
    "arc1_profile_v1"
  )
  profile_v2 <- profile
  profile_v2$engine_control$uncertainty_method <- "arc1_profile_v2"
  expect_identical(
    hs_validate_arc1_uncertainty_control(
      profile_v2,
      "repeatability",
      profile_spec,
      profile_payload
    )$method,
    "arc1_profile_v2"
  )
  profile_v3 <- profile
  profile_v3$engine_control$uncertainty_method <- "arc1_profile_v3"
  expect_identical(
    hs_validate_arc1_uncertainty_control(
      profile_v3,
      "repeatability",
      profile_spec,
      profile_payload
    ),
    list(method = "arc1_profile_v3")
  )
  profile_v4 <- profile
  profile_v4$engine_control$uncertainty_method <- "arc1_profile_v4"
  expect_identical(
    hs_validate_arc1_uncertainty_control(
      profile_v4,
      "repeatability",
      profile_spec,
      profile_payload
    ),
    list(method = "arc1_profile_v4")
  )
  expect_identical(
    hs_julia_arc1_profile_method_argument("arc1_profile_v1"),
    'method="arc1_profile_v1"'
  )
  expect_identical(
    hs_julia_arc1_profile_method_argument("arc1_profile_v2"),
    'method="arc1_profile_v2"'
  )
  expect_identical(
    hs_julia_arc1_profile_method_argument("arc1_profile_v3"),
    'method="arc1_profile_v3", v3_evidence_sink=hsq_arc1_v3_evidence_sink'
  )
  expect_identical(
    hs_julia_arc1_profile_method_argument("arc1_profile_v4"),
    'method="arc1_profile_v4", v3_evidence_sink=hsq_arc1_v3_evidence_sink'
  )
  bad_profile_payload <- profile_payload
  bad_profile_payload$Z <- Matrix::sparseMatrix(
    i = 1:3,
    j = c(1, 1, 2),
    x = 1,
    dims = c(3, 2)
  )
  expect_error(
    hs_validate_arc1_uncertainty_control(
      profile,
      "repeatability",
      profile_spec,
      bad_profile_payload
    ),
    "exactly two records"
  )

  bootstrap <- hs_control(
    engine = "julia",
    engine_control = list(
      target = "multivariate",
      optimizer_policy = "arc1_v1",
      uncertainty_method = "arc1_bootstrap_v1",
      bootstrap_B = 2L,
      bootstrap_seeds = c("18446744073709551614", "18446744073709551615")
    )
  )
  request <- hs_validate_arc1_uncertainty_control(
    bootstrap,
    "multivariate",
    list(
      family = list(family = "gaussian"),
      response = list(multivariate = TRUE)
    ),
    list(pedigree = TRUE),
    automatic_fa = TRUE
  )
  expect_identical(
    request$seeds,
    c("18446744073709551614", "18446744073709551615")
  )
  bootstrap_v2 <- bootstrap
  bootstrap_v2$engine_control$optimizer_policy <- "arc1_v2"
  bootstrap_v2$engine_control$uncertainty_method <- "arc1_bootstrap_v2"
  expect_error(
    hs_validate_arc1_uncertainty_control(
      bootstrap_v2,
      "multivariate",
      list(
        family = list(family = "gaussian"),
        response = list(multivariate = TRUE)
      ),
      list(pedigree = TRUE),
      automatic_fa = TRUE
    ),
    "arc1_bootstrap_v1"
  )
  safe_numeric <- hs_control(
    engine = "julia",
    engine_control = list(
      target = "multivariate",
      optimizer_policy = "arc1_v1",
      uncertainty_method = "arc1_bootstrap_v1",
      bootstrap_B = 1L,
      bootstrap_seeds = 2^53 - 1
    )
  )
  safe_request <- hs_validate_arc1_uncertainty_control(
    safe_numeric,
    "multivariate",
    list(
      family = list(family = "gaussian"),
      response = list(multivariate = TRUE)
    ),
    list(pedigree = TRUE),
    automatic_fa = TRUE
  )
  expect_identical(safe_request$seeds, "9007199254740991")
  unsafe <- hs_control(
    engine = "julia",
    engine_control = list(
      target = "multivariate",
      optimizer_policy = "arc1_v1",
      uncertainty_method = "arc1_bootstrap_v1",
      bootstrap_B = 1L,
      bootstrap_seeds = 2^53
    )
  )
  expect_error(
    hs_validate_arc1_uncertainty_control(
      unsafe,
      "multivariate",
      list(
        family = list(family = "gaussian"),
        response = list(multivariate = TRUE)
      ),
      list(pedigree = TRUE),
      automatic_fa = TRUE
    ),
    "no larger than 2\\^53 - 1"
  )
  rounded_unsafe <- hs_control(
    engine = "julia",
    engine_control = list(
      target = "multivariate",
      optimizer_policy = "arc1_v1",
      uncertainty_method = "arc1_bootstrap_v1",
      bootstrap_B = 1L,
      bootstrap_seeds = 9007199254740993
    )
  )
  expect_error(
    hs_validate_arc1_uncertainty_control(
      rounded_unsafe,
      "multivariate",
      list(
        family = list(family = "gaussian"),
        response = list(multivariate = TRUE)
      ),
      list(pedigree = TRUE),
      automatic_fa = TRUE
    ),
    "no larger than 2\\^53 - 1"
  )
  rounded_scalar <- hs_control(
    engine = "julia",
    engine_control = list(
      target = "multivariate",
      optimizer_policy = "arc1_v1",
      uncertainty_method = "arc1_bootstrap_v1",
      bootstrap_B = 1L,
      bootstrap_seed = 9007199254740993
    )
  )
  expect_error(
    hs_validate_arc1_uncertainty_control(
      rounded_scalar,
      "multivariate",
      list(
        family = list(family = "gaussian"),
        response = list(multivariate = TRUE)
      ),
      list(pedigree = TRUE),
      automatic_fa = TRUE
    ),
    "no larger than 2\\^53 - 1"
  )
})

test_that("profile refuses an ignored dense cap while legacy repeatability accepts it", {
  profile_spec <- list(
    family = list(family = "gaussian"),
    response = list(multivariate = FALSE),
    random = list(permanent = list())
  )
  profile_payload <- list(
    pedigree = list(ids = c("a", "b")),
    Z = Matrix::sparseMatrix(i = 1:4, j = c(1, 1, 2, 2), x = 1, dims = c(4, 2))
  )
  explicit_profile <- hs_control(
    engine = "julia",
    engine_control = list(
      target = "repeatability",
      uncertainty_method = "arc1_profile_v1",
      max_dense_cells = 2000000L
    )
  )
  expect_error(
    hs_validate_arc1_uncertainty_control(
      explicit_profile,
      "repeatability",
      profile_spec,
      profile_payload
    ),
    "no `initial`, `iterations`, or `max_dense_cells` override"
  )

  legacy_repeatability <- hs_control(
    engine = "julia",
    engine_control = list(target = "repeatability", max_dense_cells = 2000000L)
  )
  expect_identical(
    hs_engine_control_value(legacy_repeatability, "max_dense_cells", NULL),
    2000000L
  )
  expect_null(hs_validate_arc1_uncertainty_control(
    legacy_repeatability,
    "repeatability",
    profile_spec,
    profile_payload
  ))
})

test_that("explicit Arc1 confint preserves refused rows and legacy defaults", {
  table <- data.frame(
    estimand = c("heritability", "repeatability"),
    trait = c("", ""),
    segment = 1:2,
    estimate = c(.4, .6),
    lower = c(.1, NA_real_),
    upper = c(.8, NA_real_),
    formed = c(TRUE, FALSE),
    status = c("formed", "nuisance_unresolved")
  )
  fit <- structure(
    list(
      result = list(
        arc1_uncertainty = list(
          method = "arc1_profile_v1",
          method_version = "arc1_profile_v1",
          source_identity = "same",
          reference_source_identity = "same",
          point_identity = "point",
          intervals = table
        ),
        diagnostics = list(point_identity = "point")
      )
    ),
    class = "hsquared_fit"
  )
  expect_identical(confint(fit, method = "arc1_profile_v1"), table)
  expect_error(confint(fit), "not implemented")
  expect_error(
    confint(fit, method = "arc1_bootstrap_v1"),
    "must match the method selected when fitting"
  )
  expect_error(
    confint(fit, method = "arc1_profile_v2"),
    "must match the method selected when fitting"
  )
  profile_v2_fit <- fit
  profile_v2_fit$result$arc1_uncertainty$method <- "arc1_profile_v2"
  profile_v2_fit$result$arc1_uncertainty$method_version <- "arc1_profile_v2"
  expect_identical(confint(profile_v2_fit, method = "arc1_profile_v2"), table)
  missing_v2_version <- profile_v2_fit
  missing_v2_version$result$arc1_uncertainty$method_version <- NULL
  expect_error(
    confint(missing_v2_version, method = "arc1_profile_v2"),
    "requires an explicit method_version"
  )
  legacy_v1_without_version <- fit
  legacy_v1_without_version$result$arc1_uncertainty$method_version <- NULL
  expect_identical(
    confint(legacy_v1_without_version, method = "arc1_profile_v1"),
    table
  )
  expect_error(
    confint(profile_v2_fit, method = "arc1_profile_v1"),
    "must match the method selected when fitting"
  )
  mismatched_profile_v2 <- profile_v2_fit
  mismatched_profile_v2$result$arc1_uncertainty$method_version <- "arc1_profile_v1"
  expect_error(
    confint(mismatched_profile_v2, method = "arc1_profile_v2"),
    "method version does not match"
  )
  profile_v3_fit <- fit
  profile_v3_fit$result$arc1_uncertainty$method <- "arc1_profile_v3"
  profile_v3_fit$result$arc1_uncertainty$method_version <- "arc1_profile_v3"
  expect_identical(confint(profile_v3_fit, method = "arc1_profile_v3"), table)
  profile_v4_fit <- fit
  profile_v4_fit$result$arc1_uncertainty$method <- "arc1_profile_v4"
  profile_v4_fit$result$arc1_uncertainty$method_version <- "arc1_profile_v4"
  profile_v4_fit$result$diagnostics$uncertainty_method <- "arc1_profile_v4"
  expect_identical(confint(profile_v4_fit, method = "arc1_profile_v4"), table)
  expect_identical(
    summary(profile_v4_fit)$diagnostics$uncertainty_method,
    "arc1_profile_v4"
  )
  expect_identical(arc1_uncertainty(profile_v4_fit), table)
  missing_v4_version <- profile_v4_fit
  missing_v4_version$result$arc1_uncertainty$method_version <- NULL
  expect_error(
    confint(missing_v4_version, method = "arc1_profile_v4"),
    "requires an explicit method_version"
  )
  missing_v3_version <- profile_v3_fit
  missing_v3_version$result$arc1_uncertainty$method_version <- NULL
  expect_error(
    confint(missing_v3_version, method = "arc1_profile_v3"),
    "requires an explicit method_version"
  )
  mismatched_v3_version <- profile_v3_fit
  mismatched_v3_version$result$arc1_uncertainty$method_version <- "arc1_profile_v2"
  expect_error(
    confint(mismatched_v3_version, method = "arc1_profile_v3"),
    "method version does not match"
  )
  mismatch <- fit
  mismatch$result$arc1_uncertainty$reference_source_identity <- "other-source"
  expect_error(
    confint(mismatch, method = "arc1_profile_v1"),
    "source identities do not match"
  )

  selected <- structure(
    list(
      arc1_uncertainty = list(
        method = "arc1_bootstrap_v1",
        source_identity = "same",
        reference_source_identity = "same",
        intervals = table
      )
    ),
    class = "hsquared_fa_rank_selection"
  )
  expect_identical(confint(selected, method = "arc1_bootstrap_v1"), table)
  expect_error(
    confint(selected, method = "arc1_bootstrap_v2"),
    "arc1_bootstrap_v1"
  )
  expect_error(confint(selected), "explicit")
})

test_that("nested Julia Arc1 diagnostics retain primitive values and matrices", {
  diagnostics <- list(
    candidate_summary = list(
      scores = c(0.1, 0.2),
      accepted = c(TRUE, FALSE),
      covariance = matrix(c(1, 0.2, 0.2, 2), 2)
    ),
    guard_results = list(
      schedule_complete = FALSE,
      better_unaccepted = TRUE,
      nonnested = FALSE,
      nesting_witness = list(
        status = "failed",
        discrepancy = 0.2,
        tolerance = 1e-4
      )
    ),
    selector_attempts = list(list(
      status = "failed",
      seed = "18446744073709551615"
    ))
  )
  restored <- hs_arc1_plain_to_list(diagnostics)
  expect_type(restored$candidate_summary$scores, "double")
  expect_type(restored$candidate_summary$accepted, "logical")
  expect_identical(
    restored$candidate_summary$covariance,
    diagnostics$candidate_summary$covariance
  )
  expect_identical(restored$selector_attempts[[1]]$seed, "18446744073709551615")
  expect_identical(restored$guard_results$better_unaccepted, TRUE)
  expect_equal(restored$guard_results$nesting_witness$discrepancy, 0.2)
})

test_that("JuliaCall Arc1 transport converts enum and missing leaves and rejects cycles", {
  cyclic <- new.env(parent = emptyenv())
  cyclic$self <- cyclic
  expect_error(hs_arc1_plain_to_list(cyclic), "cyclic JuliaCall environment")

  project <- Sys.getenv("HSQUARED_JULIA_PROJECT", unset = "")
  if (
    !nzchar(project) ||
      !dir.exists(project) ||
      !hs_julia_bridge_available(project)
  ) {
    skip("A local JuliaCall engine is required for this transport regression.")
  }
  hs_julia_setup(project)
  JuliaCall::julia_command(paste(
    hs_julia_arc1_plain_command(),
    "@enum HsqArc1WireFlag hsq_arc1_wire_ok hsq_arc1_wire_bad;",
    "hsq_arc1_wire_result = hsq_arc1_plain((status=hsq_arc1_wire_ok,",
    "nested=(missing_value=missing, absent=nothing, seed=typemax(UInt64)),",
    "guard_results=(schedule_complete=false, better_unaccepted=true, nonnested=false,",
    "nesting_witness=(status=:unavailable, discrepancy=nothing, tolerance=1e-4))));"
  ))
  restored <- hs_arc1_plain_to_list(JuliaCall::julia_eval(
    "hsq_arc1_wire_result"
  ))
  expect_identical(restored$status, "hsq_arc1_wire_ok")
  expect_identical(restored$nested$missing_value, "__HSQ_MISSING__")
  expect_identical(restored$nested$absent, "__HSQ_NONE__")
  expect_identical(restored$nested$seed, "18446744073709551615")
  expect_false(restored$guard_results$schedule_complete)
  expect_true(restored$guard_results$better_unaccepted)
  expect_identical(restored$guard_results$nesting_witness$status, "unavailable")
  expect_identical(
    restored$guard_results$nesting_witness$discrepancy,
    "__HSQ_NONE__"
  )
  JuliaCall::julia_command(paste(
    hs_julia_arc1_plain_command(),
    "hsq_arc1_wire_rows = hsq_arc1_plain(((seed=UInt64(31), status=:ok),",
    "(seed=UInt64(32), status=:failed)));"
  ))
  restored_rows <- hs_arc1_plain_to_list(JuliaCall::julia_eval(
    "hsq_arc1_wire_rows"
  ))
  expect_length(restored_rows, 2L)
  expect_identical(restored_rows[[1L]]$seed, "31")
  expect_identical(restored_rows[[2L]]$status, "failed")
  JuliaCall::julia_command("struct HsqArc1UnsupportedWireLeaf end")
  expect_error(
    JuliaCall::julia_eval("hsq_arc1_plain(HsqArc1UnsupportedWireLeaf())"),
    "unsupported Arc1 bridge leaf type"
  )
})

test_that("v3 profile evidence survives the invoking Julia error handler", {
  retained <- list(
    requested_method_version = "arc1_profile_v3",
    actual_method_version = "arc1_profile_v3",
    source_identity = "source-v3",
    arc1_profile_v3_evaluations = list(list(
      target = "heritability",
      status = "interrupted",
      max_valid_loglik = -3.25,
      max_valid_centered_loglik = -0.5,
      events = list(list(event = "interrupted", components = c(0.2, 0.1, 0.7)))
    ))
  )
  caught <- tryCatch(
    hs_arc1_capture_v3_profile_error(
      hsquared:::hs_julia_fit(stop("controlled interruption")),
      "arc1_profile_v3",
      function() retained
    ),
    error = identity
  )
  expect_s3_class(caught, "hsquared_julia_error")
  expect_identical(conditionMessage(caught), "controlled interruption")
  expect_identical(
    attr(caught, "arc1_profile_method_requested"),
    "arc1_profile_v3"
  )
  expect_identical(
    attr(caught, "arc1_profile_method_actual"),
    "arc1_profile_v3"
  )
  expect_identical(attr(caught, "arc1_profile_source_identity"), "source-v3")
  expect_identical(attr(caught, "arc1_profile_evidence"), retained)
  expect_true(attr(caught, "arc1_profile_evidence_partial"))
  expect_null(attr(caught, "arc1_profile_evidence_retention_error"))

  # A separate invocation gets its own empty sink; it cannot inherit evidence
  # from the preceding call.
  second <- tryCatch(
    hs_arc1_capture_v3_profile_error(
      hsquared:::hs_julia_fit(stop("second controlled error")),
      "arc1_profile_v3",
      function() {
        list(
          requested_method_version = "arc1_profile_v3",
          arc1_profile_v3_evaluations = list()
        )
      }
    ),
    error = identity
  )
  expect_identical(conditionMessage(second), "second controlled error")
  expect_false(attr(second, "arc1_profile_evidence_partial"))
  expect_length(
    attr(second, "arc1_profile_evidence")$arc1_profile_v3_evaluations,
    0L
  )

  transport_failed <- tryCatch(
    hs_arc1_capture_v3_profile_error(
      hsquared:::hs_julia_fit(stop("original Julia failure")),
      "arc1_profile_v3",
      function() stop("sink conversion failed")
    ),
    error = identity
  )
  expect_s3_class(transport_failed, "hsquared_julia_error")
  expect_identical(conditionMessage(transport_failed), "original Julia failure")
  expect_identical(
    attr(transport_failed, "arc1_profile_evidence_retention_error"),
    "sink conversion failed"
  )

  post_conversion_failure <- structure(
    simpleError("controlled final conversion failure"),
    class = c("hsquared_julia_error", "error", "condition")
  )
  cleaned <- FALSE
  converted <- tryCatch(
    hs_arc1_run_v3_profile_operation(
      function() stop(post_conversion_failure),
      "arc1_profile_v3",
      function() retained,
      function() {
        cleaned <<- TRUE
        invisible(NULL)
      }
    ),
    error = identity
  )
  expect_s3_class(converted, "hsquared_julia_error")
  expect_identical(
    conditionMessage(converted),
    "controlled final conversion failure"
  )
  expect_identical(attr(converted, "arc1_profile_evidence"), retained)
  expect_true(cleaned)
})


test_that("the v3 bridge captures late caller materialization failures", {
  production <- get(
    "hs_fit_julia_repeatability_payload",
    asNamespace("hsquared")
  )
  rewrite_juliacall <- function(x) {
    if (!is.call(x)) {
      return(x)
    }
    if (
      length(x) == 3L &&
        identical(as.character(x[[1L]]), "::") &&
        identical(as.character(x[[2L]]), "JuliaCall")
    ) {
      replacement <- switch(
        as.character(x[[3L]]),
        julia_assign = "test_julia_assign",
        julia_command = "test_julia_command",
        julia_eval = "test_julia_eval",
        NULL
      )
      if (!is.null(replacement)) return(as.name(replacement))
    }
    as.call(lapply(as.list(x), rewrite_juliacall))
  }
  make_caller <- function(
    failure_field = NULL,
    fail_early = FALSE,
    method = "arc1_profile_v3"
  ) {
    state <- new.env(parent = emptyenv())
    state$events <- character()
    state$fit_calls <- 0L
    state$eval_commands <- character()
    state$target_projection_command <- if (
      identical(method, "arc1_profile_v4")
    ) {
      "hsq_arc1_plain(hsq_arc1_targets_r)"
    } else {
      "hsq_arc1_plain(hsq_arc1.targets)"
    }
    state$target_details <- list(
      residual_variance = list(
        status = "formed",
        profile_diagnostics = list()
      )
    )
    retained_evidence <- list(
      requested_method_version = method,
      actual_method_version = method,
      source_identity = "source-v3"
    )
    shared_evaluations <- list(list(
      target = "residual_variance",
      fixed_value = 0.4,
      events = list(),
      producer_history = list(),
      provenance_failures = list(),
      max_valid_loglik = -2,
      max_valid_centered_loglik = -2,
      status = if (identical(method, "arc1_profile_v4")) {
        "unresolved_shared_competitor"
      } else {
        "returned"
      },
      tail_certificate = if (identical(method, "arc1_profile_v4")) {
        list(
          certified = TRUE,
          determinant = list(numerator = "5", denominator = "2"),
          precision = 256L,
          rounding = "directed_mpfr",
          design_identity = "design-v4"
        )
      } else {
        NULL
      }
    ))
    retained_evidence$arc1_profile_v3_evaluations <- shared_evaluations
    if (identical(method, "arc1_profile_v4")) {
      retained_evidence$arc1_profile_v4_evaluations <- shared_evaluations
    }
    state$retained_evidence <- retained_evidence
    state$evidence_projection <- if (identical(method, "arc1_profile_v4")) {
      projected <- retained_evidence
      projected$arc1_profile_v4_evaluations <- NULL
      list(evidence = projected, v4_alias_verified = TRUE)
    } else {
      retained_evidence
    }
    state$raw <- list(
      method = method,
      method_version = method,
      point_fit_status = "ok",
      point_fit_not_optimal = FALSE,
      estimand_definition = "repeatability",
      loglik_convention = "full",
      loglik_full_constant_offset = 0,
      loglik_comparable_across_routes = TRUE,
      level = 0.95,
      cutoff = 1.92,
      s0 = 1,
      max_constrained_loglik = -2,
      nuisance_statuses = list(),
      targets = list(),
      source_identity = "source-v3",
      reference_source_identity = "source-v3",
      point_identity = "point-v3",
      estimand = "repeatability",
      trait = "",
      segment = 1L,
      estimate = 0.6,
      lower = 0.3,
      upper = 0.8,
      formed = TRUE,
      status = "formed",
      target_status = list(),
      target_formed = list(),
      target_evaluated = list(),
      sigma_a2 = 0.3,
      sigma_pe2 = 0.3,
      sigma_e2 = 0.4,
      loglik = -2,
      v3_profile_evidence = retained_evidence
    )
    if (!is.null(failure_field)) {
      leaf <- structure(
        list(marker = failure_field),
        class = "InjectedJuliaLeaf"
      )
      if (identical(failure_field, "v3_profile_evidence")) {
        if (identical(method, "arc1_profile_v4")) {
          cycle <- new.env(parent = emptyenv())
          cycle$self <- cycle
          state$evidence_projection$evidence$test_conversion_probe <- cycle
        } else {
          state$retained_evidence$test_conversion_probe <- leaf
          state$evidence_projection <- state$retained_evidence
        }
      } else {
        if (identical(failure_field, "targets")) {
          state$target_details <- leaf
          state$raw[[failure_field]] <- leaf
        } else {
          state$raw[[failure_field]] <- leaf
        }
      }
    }
    env <- new.env(parent = asNamespace("hsquared"))
    caller <- production
    environment(caller) <- env
    body(caller) <- rewrite_juliacall(body(caller))
    env$hs_julia_bridge_available <- function(project) TRUE
    env$hs_julia_setup <- function(project) invisible(NULL)
    env$hs_julia_assign_payload <- function(payload, initial) invisible(NULL)
    env$test_julia_assign <- function(...) invisible(NULL)
    env$test_julia_command <- function(command) command
    env$test_julia_eval <- function(command) {
      state$eval_commands <- c(state$eval_commands, command)
      if (grepl("let source=", command, fixed = TRUE)) {
        return(state$evidence_projection)
      }
      if (identical(trimws(command), state$target_projection_command)) {
        return(state$target_details)
      }
      if (
        grepl("hsq_arc1_v3_evidence_sink_", command, fixed = TRUE) ||
          grepl("hsq_arc1_v4_evidence_sink_", command, fixed = TRUE)
      ) {
        return(state$retained_evidence)
      }
      state$raw
    }
    env$hs_julia_fit <- function(command, hint = NULL) {
      state$events <- c(state$events, "fit")
      if (fail_early) {
        condition <- structure(
          simpleError("injected early Julia failure"),
          class = c("hsquared_julia_error", "error", "condition")
        )
        stop(condition)
      }
      invisible(NULL)
    }
    env$hs_arc1_read_v3_julia_sink <- function(name) {
      state$events <- c(state$events, "read")
      evaluations <- if (fail_early) {
        list()
      } else {
        list(list(
          status = if (identical(method, "arc1_profile_v4")) {
            "unresolved_shared_competitor"
          } else {
            "interrupted"
          },
          tail_certificate = if (identical(method, "arc1_profile_v4")) {
            list(
              certified = TRUE,
              determinant = list(numerator = "5", denominator = "2"),
              precision = 256L,
              rounding = "directed_mpfr",
              design_identity = "design-v4"
            )
          } else {
            NULL
          }
        ))
      }
      evidence <- list(
        requested_method_version = method,
        actual_method_version = if (fail_early) NULL else method,
        source_identity = if (fail_early) NULL else "source-v3",
        arc1_profile_v3_evaluations = evaluations
      )
      if (identical(method, "arc1_profile_v4")) {
        evidence$arc1_profile_v4_evaluations <- evaluations
      }
      evidence
    }
    env$hs_arc1_read_profile_julia_sink <- function(name, method_version) {
      env$hs_arc1_read_v3_julia_sink(name)
    }
    env$hs_arc1_julia_clear_v3_binding_checked <- function(name) {
      state$events <- c(state$events, "cleanup")
      invisible(NULL)
    }
    env$hs_arc1_plain_to_list <- function(x, .seen_envs = list()) {
      if (inherits(x, "InjectedJuliaLeaf")) {
        condition <- structure(
          simpleError(paste("injected", x$marker, "conversion")),
          class = c("hsquared_julia_error", "error", "condition")
        )
        stop(condition)
      }
      if (is.list(x)) lapply(x, env$hs_arc1_plain_to_list) else x
    }
    env$hs_new_fit <- function(spec, payload, result) {
      state$events <- c(state$events, "materialized")
      state$fit_calls <- state$fit_calls + 1L
      list(
        spec = spec,
        payload = payload,
        result = result,
        class = "hsquared_fit"
      )
    }
    list(call = caller, env = env, state = state)
  }

  payload <- structure(list(family = "gaussian"), class = "hs_bridge_payload")
  for (field in c("nuisance_statuses", "targets", "v3_profile_evidence")) {
    fixture <- make_caller(field)
    caught <- tryCatch(
      fixture$call(
        payload,
        project = "fake",
        uncertainty_method = "arc1_profile_v3"
      ),
      error = identity
    )
    expect_s3_class(caught, "hsquared_julia_error")
    expect_identical(
      conditionMessage(caught),
      paste("injected", field, "conversion")
    )
    expect_identical(
      attr(caught, "arc1_profile_method_requested"),
      "arc1_profile_v3"
    )
    expect_identical(
      attr(caught, "arc1_profile_method_actual"),
      "arc1_profile_v3"
    )
    expect_identical(attr(caught, "arc1_profile_source_identity"), "source-v3")
    expect_true(attr(caught, "arc1_profile_evidence_partial"))
    expect_identical(fixture$state$events, c("fit", "read", "cleanup"))
    expect_identical(fixture$state$fit_calls, 0L)
  }

  success <- make_caller()
  fit <- success$call(
    payload,
    project = "fake",
    uncertainty_method = "arc1_profile_v3"
  )
  expect_identical(
    fit$result$arc1_uncertainty$method_version,
    "arc1_profile_v3"
  )
  expect_s3_class(fit$result$arc1_uncertainty$intervals, "data.frame")
  expect_identical(success$state$events, c("fit", "materialized", "cleanup"))
  expect_identical(success$state$fit_calls, 1L)
  expect_length(success$state$eval_commands, 3L)
  expect_identical(
    trimws(success$state$eval_commands[[2L]]),
    "hsq_arc1_plain(hsq_arc1.targets)"
  )
  expect_match(success$state$eval_commands[[3L]], "hsq_arc1_v3_evidence_sink_")
  expect_identical(
    fit$result$arc1_uncertainty$target_details,
    success$state$target_details
  )

  success_v4 <- make_caller(method = "arc1_profile_v4")
  fit_v4 <- success_v4$call(
    payload,
    project = "fake",
    uncertainty_method = "arc1_profile_v4"
  )
  expect_identical(fit_v4$result$arc1_uncertainty$method, "arc1_profile_v4")
  expect_identical(
    fit_v4$result$arc1_uncertainty$method_version,
    "arc1_profile_v4"
  )
  expect_identical(
    fit_v4$result$diagnostics$uncertainty_method,
    "arc1_profile_v4"
  )
  expect_identical(success_v4$state$events, c("fit", "materialized", "cleanup"))
  expect_length(success_v4$state$eval_commands, 3L)
  expect_identical(
    trimws(success_v4$state$eval_commands[[2L]]),
    "hsq_arc1_plain(hsq_arc1_targets_r)"
  )
  expect_match(
    success_v4$state$eval_commands[[3L]],
    "let source=hsq_arc1_v4_evidence_sink_"
  )
  expect_identical(
    fit_v4$result$arc1_uncertainty$target_details,
    success_v4$state$target_details
  )
  expect_null(fit_v4$result$arc1_uncertainty$v3_profile_evidence)
  expect_identical(
    fit_v4$result$arc1_uncertainty$profile_evidence$requested_method_version,
    "arc1_profile_v4"
  )
  expect_identical(
    fit_v4$result$arc1_uncertainty$profile_evidence$actual_method_version,
    "arc1_profile_v4"
  )
  expect_identical(
    fit_v4$result$arc1_uncertainty$profile_evidence$arc1_profile_v4_evaluations[[
      1
    ]]$status,
    "unresolved_shared_competitor"
  )
  expect_identical(
    fit_v4$result$arc1_uncertainty$profile_evidence$arc1_profile_v4_evaluations[[
      1
    ]]$tail_certificate$determinant,
    list(numerator = "5", denominator = "2")
  )

  late_v4 <- make_caller(
    failure_field = "v3_profile_evidence",
    method = "arc1_profile_v4"
  )
  caught_v4 <- tryCatch(
    late_v4$call(
      payload,
      project = "fake",
      uncertainty_method = "arc1_profile_v4"
    ),
    error = identity
  )
  expect_s3_class(caught_v4, "error")
  expect_match(
    conditionMessage(caught_v4),
    "cyclic JuliaCall environment in Arc 1 diagnostics"
  )
  expect_identical(
    attr(caught_v4, "arc1_profile_method_requested"),
    "arc1_profile_v4"
  )
  expect_identical(
    attr(caught_v4, "arc1_profile_method_actual"),
    "arc1_profile_v4"
  )
  expect_true(attr(caught_v4, "arc1_profile_evidence_partial"))
  expect_identical(
    attr(caught_v4, "arc1_profile_evidence")$arc1_profile_v4_evaluations[[
      1
    ]]$status,
    "unresolved_shared_competitor"
  )
  expect_identical(late_v4$state$events, c("fit", "read", "cleanup"))

  early <- make_caller(fail_early = TRUE)
  caught_early <- tryCatch(
    early$call(
      payload,
      project = "fake",
      uncertainty_method = "arc1_profile_v3"
    ),
    error = identity
  )
  expect_s3_class(caught_early, "hsquared_julia_error")
  expect_identical(
    conditionMessage(caught_early),
    "injected early Julia failure"
  )
  expect_identical(
    attr(caught_early, "arc1_profile_method_requested"),
    "arc1_profile_v3"
  )
  expect_null(attr(caught_early, "arc1_profile_method_actual"))
  expect_null(attr(caught_early, "arc1_profile_source_identity"))
  expect_false(attr(caught_early, "arc1_profile_evidence_partial"))
  expect_identical(early$state$events, c("fit", "read", "cleanup"))
  expect_identical(early$state$fit_calls, 0L)
})

test_that("JuliaCall transports an invocation-local v3 interruption sink after unwind", {
  project <- Sys.getenv("HSQUARED_JULIA_PROJECT", unset = "")
  if (
    !nzchar(project) ||
      !dir.exists(project) ||
      !hs_julia_bridge_available(project)
  ) {
    skip("A local JuliaCall engine is required for this transport regression.")
  }
  hs_julia_setup(project)
  sink_name <- hs_arc1_new_v3_sink_name()
  julia_failure <- paste0(
    "using Optim;",
    hs_julia_arc1_plain_command(),
    sink_name,
    " = Dict{Symbol,Any}();",
    sink_name,
    "[:requested_method_version] = \"arc1_profile_v3\";",
    sink_name,
    "[:actual_method_version] = \"arc1_profile_v3\";",
    sink_name,
    "[:source_identity] = \"juliacall-interrupt-source\";",
    "push!(get!(",
    sink_name,
    ", :arc1_profile_v3_evaluations, Any[]), ",
    "Dict{Symbol,Any}(:target=>:heritability, :status=>:interrupted, ",
    ":max_valid_loglik=>-3.0, :max_valid_centered_loglik=>-0.5, ",
    ":native_diagnostics=>Dict{Symbol,Any}(:termination_code=>Optim.TerminationCode.NoObjectiveChange, ",
    ":native_tuple=>(missing, Inf, NaN), :native_dict=>Dict(:reason=>:line_search_stopped)), ",
    ":events=>[Dict{Symbol,Any}(:event=>:interrupted)]));",
    "throw(InterruptException())"
  )
  caught <- tryCatch(
    hs_arc1_run_v3_profile_operation(
      function() {
        hsquared:::hs_julia_fit(JuliaCall::julia_command(julia_failure))
      },
      "arc1_profile_v3",
      function() hs_arc1_read_v3_julia_sink(sink_name),
      function() hs_arc1_julia_delete_binding(sink_name)
    ),
    error = identity
  )
  expect_s3_class(caught, "hsquared_julia_error")
  expect_match(conditionMessage(caught), "InterruptException")
  expect_identical(
    attr(caught, "arc1_profile_method_requested"),
    "arc1_profile_v3"
  )
  expect_identical(
    attr(caught, "arc1_profile_method_actual"),
    "arc1_profile_v3"
  )
  expect_identical(
    attr(caught, "arc1_profile_source_identity"),
    "juliacall-interrupt-source"
  )
  expect_true(attr(caught, "arc1_profile_evidence_partial"))
  expect_identical(
    attr(caught, "arc1_profile_evidence")$arc1_profile_v3_evaluations[[
      1
    ]]$max_valid_loglik,
    -3.0
  )
  native <- attr(caught, "arc1_profile_evidence")$arc1_profile_v3_evaluations[[
    1
  ]]$native_diagnostics
  expect_identical(native$termination_code, "NoObjectiveChange")
  expect_identical(native$native_tuple[[1]], "__HSQ_MISSING__")
  expect_true(is.infinite(native$native_tuple[[2]]))
  expect_true(is.nan(native$native_tuple[[3]]))
  expect_null(JuliaCall::julia_eval(sink_name))

  # The method may return before the final Julia-to-R conversion fails. The
  # same invocation wrapper must read the still-live sink before cleanup.
  conversion_name <- hs_arc1_new_v3_sink_name()
  converted_condition <- structure(
    simpleError("injected post-call result conversion failure"),
    class = c("hsquared_julia_error", "error", "condition")
  )
  converted <- tryCatch(
    hs_arc1_run_v3_profile_operation(
      function() {
        JuliaCall::julia_command(paste0(
          hs_julia_arc1_plain_command(),
          conversion_name,
          " = Dict{Symbol,Any}();",
          conversion_name,
          "[:requested_method_version] = \"arc1_profile_v3\";",
          conversion_name,
          "[:actual_method_version] = \"arc1_profile_v3\";",
          conversion_name,
          "[:source_identity] = \"post-call-source\";",
          "push!(get!(",
          conversion_name,
          ", :arc1_profile_v3_evaluations, Any[]),",
          " Dict{Symbol,Any}(:status=>:returned, :native_tuple=>(missing, Inf, NaN)));"
        ))
        stop(converted_condition)
      },
      "arc1_profile_v3",
      function() hs_arc1_read_v3_julia_sink(conversion_name),
      function() hs_arc1_julia_delete_binding(conversion_name)
    ),
    error = identity
  )
  expect_s3_class(converted, "hsquared_julia_error")
  expect_identical(
    conditionMessage(converted),
    "injected post-call result conversion failure"
  )
  expect_true(attr(converted, "arc1_profile_evidence_partial"))
  expect_identical(
    attr(converted, "arc1_profile_evidence")$arc1_profile_v3_evaluations[[
      1
    ]]$native_tuple[[1]],
    "__HSQ_MISSING__"
  )
  expect_null(JuliaCall::julia_eval(conversion_name))

  next_name <- hs_arc1_new_v3_sink_name()
  expect_false(identical(sink_name, next_name))
  second <- tryCatch(
    hs_arc1_run_v3_profile_operation(
      function() {
        hsquared:::hs_julia_fit(JuliaCall::julia_command(paste0(
          next_name,
          " = Dict{Symbol,Any}();",
          next_name,
          "[:requested_method_version] = \"arc1_profile_v3\";",
          next_name,
          "[:actual_method_version] = \"arc1_profile_v3\";",
          next_name,
          "[:source_identity] = \"second-source\";",
          "throw(ErrorException(\"second invocation\"))"
        )))
      },
      "arc1_profile_v3",
      function() hs_arc1_read_v3_julia_sink(next_name),
      function() hs_arc1_julia_delete_binding(next_name)
    ),
    error = identity
  )
  expect_s3_class(second, "hsquared_julia_error")
  expect_false(attr(second, "arc1_profile_evidence_partial"))
  expect_length(
    attr(second, "arc1_profile_evidence")$arc1_profile_v3_evaluations,
    0L
  )
  expect_null(JuliaCall::julia_eval(next_name))
  cat("ARC1_V3_JULIACALL_FAILURE_CONTROL_ASSERTIONS_COMPLETE\n")
})

test_that("serialized missing entries in optimizer vectors decode without warnings", {
  expect_no_warning(decoded <- hs_fa_decode_vector("1.25,__HSQ_MISSING__,3.5"))
  expect_identical(decoded, c(1.25, NA_real_, 3.5))
})

test_that("profile transport keeps local convergence separate from global point failure", {
  locally_converged <- hs_arc1_profile_point_status("ok", FALSE)
  expect_identical(locally_converged$point_fit_status, "ok")
  expect_false(locally_converged$point_fit_not_optimal)
  expect_true(locally_converged$converged)

  better_constrained_fit <- hs_arc1_profile_point_status("ok", TRUE)
  expect_identical(better_constrained_fit$point_fit_status, "ok")
  expect_true(better_constrained_fit$point_fit_not_optimal)
  expect_false(better_constrained_fit$converged)

  optimizer_failure <- hs_arc1_profile_point_status("optimizer_failed", FALSE)
  expect_false(optimizer_failure$converged)
})


test_that("inactive bootstrap controls cannot be silently discarded", {
  for (key in c("bootstrap_B", "bootstrap_seeds", "bootstrap_seed")) {
    ctl <- hs_control(
      engine = "julia",
      engine_control = setNames(list(1L), key)
    )
    expect_error(
      hs_validate_arc1_uncertainty_control(ctl, "multivariate", list(), list()),
      "Bootstrap controls require"
    )
    ctl$engine_control$uncertainty_method <- "arc1_profile_v1"
    expect_error(
      hs_validate_arc1_uncertainty_control(
        ctl,
        "repeatability",
        list(),
        list()
      ),
      "Bootstrap controls require"
    )
  }
  expect_null(hs_validate_arc1_uncertainty_control(
    hs_control(),
    "repeatability",
    list(),
    list()
  ))
  ctl <- hs_control(
    engine = "julia",
    engine_control = list(
      uncertainty_method = "arc1_bootstrap_v1",
      bootstrap_B = 1L,
      bootstrap_seeds = "1",
      bootstrap_seed = "2"
    )
  )
  expect_error(hs_arc1_exact_seeds(ctl, 1L), "cannot be combined")
})
