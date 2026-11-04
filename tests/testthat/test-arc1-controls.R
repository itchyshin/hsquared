test_that("arc1_v1 controls enforce the frozen pedigree FA scope", {
  spec <- list(method = "REML", response = list(multivariate = TRUE), random = list(animal = TRUE))
  payload <- list(
    Y = matrix(seq_len(20), 5L, 4L), X = matrix(1, 5L, 1L), Z = diag(5L),
    family = "gaussian", pedigree = list(id = letters[1:5]),
    metadata = list(fixed_colnames = "(Intercept)")
  )
  automatic <- hs_control(engine = "julia", engine_control = list(
    target = "multivariate", rank_selection = "auto", optimizer_policy = "arc1_v1"
  ))
  expect_true(hsquared:::hs_validate_auto_fa_rank_control(
    automatic, "multivariate", spec, payload
  ))
  fixed <- hs_control(engine = "julia", engine_control = list(
    target = "multivariate", genetic_structure = "factor_analytic", rank = 1L,
    optimizer_policy = "arc1_v1"
  ))
  expect_false(hsquared:::hs_validate_auto_fa_rank_control(
    fixed, "multivariate", spec, payload
  ))
  fixed_v2 <- hs_control(engine = "julia", engine_control = list(
    target = "multivariate", genetic_structure = "factor_analytic", rank = 1L,
    optimizer_policy = "arc1_v2"
  ))
  expect_false(hsquared:::hs_validate_auto_fa_rank_control(
    fixed_v2, "multivariate", spec, payload
  ))
  for (bad in list(
    list(target = "multivariate", rank_selection = "auto", optimizer_policy = "arc1_v1", iterations = 2001L),
    list(target = "multivariate", rank_selection = "auto", optimizer_policy = "arc1_v1", initial = list(G0 = diag(4), R0 = diag(4))),
    list(target = "multivariate", optimizer_policy = "arc1_v1", genetic_structure = "unstructured", rank = 1L)
  )) {
    control <- hs_control(engine = "julia", engine_control = bad)
    expect_error(hsquared:::hs_validate_auto_fa_rank_control(
      control, "multivariate", spec, payload
    ), class = "hsquared_unsupported_syntax")
  }
  for (with_policy in c(FALSE, TRUE)) {
    bad <- list(target = "multivariate", rank_selection = "fixed")
    if (with_policy) bad$optimizer_policy <- "arc1_v1"
    expect_error(hsquared:::hs_validate_auto_fa_rank_control(
      hs_control(engine = "julia", engine_control = bad), "multivariate", spec, payload
    ), class = "hsquared_unsupported_syntax")
  }
  no_pedigree <- payload
  no_pedigree$pedigree <- NULL
  expect_error(hsquared:::hs_validate_auto_fa_rank_control(
    automatic, "multivariate", spec, no_pedigree
  ), class = "hsquared_unsupported_syntax")
})

test_that("arc1_v1 metadata and scheduled versus attempted starts survive R normalization", {
  payload <- structure(list(), class = "hs_bridge_payload")
  raw <- list(
    selection_status = "unavailable", reason = "one start failed",
    optimizer_policy = "arc1_v1", optimizer_policy_version = 1L,
    optimizer_algorithm = "bfgs_hager_zhang", optimizer_iterations = 2000L,
    optimizer_tolerance = 1e-8, final_scaled_gradient_tolerance = 1e-6,
    numerical_gradient_steps = c(1e-4, 1e-5), numerical_gradient_tolerance = 5e-6,
    source_identity = "loaded-tree-sha256:abc", starts_planned = 19L,
    starts_attempted = 3L,
    candidate_summary = list(
      list(rank = 0L, structure = "diagonal", status = "eligible", eligible = TRUE),
      list(rank = 1L, structure = "factor_analytic", status = "failed", eligible = FALSE)
    ),
    attempts = list(list(
      rank = 1L, structure = "factor_analytic", start_id = "default",
      retry_index = 0L, attempted = TRUE, status = "failed",
      reason = "gradient check", final_gradient_inf_norm = 2,
      numerical_gradient_inf_norms = c(2, 2.1),
      numerical_gradient_discrepancies = c(.01, .02),
      numerical_gradient_status = "failed", failure_status = "gradient_failure",
      eligible = FALSE, optimizer_converged = TRUE,
      optimizer_assessment_status = "numerical_gradient_failure",
      optimizer_assessment_reason = "independent gradient gate failed"
    ), list(
      rank = 1L, structure = "factor_analytic", start_id = "secondary",
      retry_index = 0L, attempted = TRUE, status = "completed",
      reason = "optimizer completed but gradient gate refused eligibility",
      eligible = FALSE, failure_status = "numerical_gradient_refused"
    ))
  )
  result <- hsquared:::hs_normalize_fa_rank_selection(raw, payload)
  expect_identical(result$optimizer_policy, "arc1_v1")
  expect_identical(result$optimizer_policy_version, 1L)
  expect_identical(result$source_identity, "loaded-tree-sha256:abc")
  expect_identical(result$optimizer_algorithm, "bfgs_hager_zhang")
  expect_identical(result$optimizer_iterations, 2000L)
  expect_equal(result$numerical_gradient_steps, c(1e-4, 1e-5))
  expect_identical(result$starts_scheduled, 19L)
  expect_identical(result$starts_attempted, 3L)
  expect_identical(result$failure_count, 2L)
  expect_identical(result$failure_cause_counts$gradient_failure, 1L)
  expect_identical(result$failure_cause_counts$numerical_gradient_refused, 1L)
  expect_identical(result$attempts$numerical_gradient_status, c("failed", NA_character_))
  expect_true(result$attempts$optimizer_converged[[1L]])
  expect_identical(result$attempts$optimizer_assessment_status[[1L]], "numerical_gradient_failure")
  expect_identical(result$attempts$optimizer_assessment_reason[[1L]], "independent gradient gate failed")
  expect_equal(result$attempts$numerical_gradient_inf_norms[[1L]], c(2, 2.1))
  diagnostics <- fit_diagnostics(result)
  expect_true(all(c("optimizer_policy", "source_identity", "starts_scheduled",
    "starts_attempted", "failure_count") %in% diagnostics$metric))
  printed <- capture.output(print(result))
  expect_true(any(grepl("3 attempted of 19 scheduled", printed, fixed = TRUE)))
})

test_that("unavailable and interrupted selection payloads retain flat Arc1 identity", {
  payload <- structure(list(), class = "hs_bridge_payload")
  raw <- list(
    selection_status = "interrupted", reason = "interrupted during optimizer start",
    optimizer_policy = "arc1_v1", optimizer_policy_version = 1L,
    optimizer_algorithm = "bfgs_hager_zhang", optimizer_iterations = 2000L,
    optimizer_tolerance = 1e-8, final_scaled_gradient_tolerance = 1e-6,
    numerical_gradient_steps = c(1e-4, 1e-5), numerical_gradient_tolerance = 5e-6,
    source_identity = paste(rep("a", 64L), collapse = ""),
    starts_planned = 19L, starts_attempted = 1L,
    guard_results = list(schedule_complete = FALSE, better_unaccepted = FALSE,
      nonnested = FALSE, nesting_witness = list(status = "unavailable",
        discrepancy = "__HSQ_NONE__", tolerance = 1e-4)),
    candidate_summary = list(
      list(rank = 0L, structure = "diagonal", status = "interrupted", eligible = FALSE),
      list(rank = 1L, structure = "factor_analytic", status = "unattempted", eligible = FALSE)
    ),
    attempts = list(list(
      rank = 0L, structure = "diagonal", start_id = "default", retry_index = 0L,
      attempted = TRUE, status = "interrupted", reason = "interrupted during optimizer start",
      optimizer_converged = FALSE, optimizer_assessment_status = "interrupted",
      optimizer_assessment_reason = "Julia interrupt", failure_status = "interrupted",
      eligible = FALSE
    ))
  )
  result <- hsquared:::hs_normalize_fa_rank_selection(raw, payload)
  expect_identical(result$selection_status, "interrupted")
  expect_identical(result$optimizer_policy, "arc1_v1")
  expect_identical(result$optimizer_policy_version, 1L)
  expect_identical(result$source_identity, raw$source_identity)
  expect_identical(result$optimizer_algorithm, "bfgs_hager_zhang")
  expect_identical(result$optimizer_iterations, 2000L)
  expect_identical(result$attempts$optimizer_assessment_reason[[1L]], "Julia interrupt")
  expect_identical(result$attempts$failure_status[[1L]], "interrupted")
  expect_identical(result$guard_results$nesting_witness$status, "unavailable")
  expect_null(result$guard_results$nesting_witness$discrepancy)
})

test_that("legacy Julia errors remain translated by the established fit wrapper", {
  expect_error(hsquared:::hs_julia_fit(
    stop("raw Julia exception", call. = FALSE), hint = "R control hint"
  ), class = "hsquared_julia_error", regexp = "raw Julia exception.*R control hint")
})

test_that("the Julia interrupt boundary retains request-local partial evidence", {
  partial <- list(selection_status = "interrupted", optimizer_policy = "arc1_v1")
  err <- tryCatch(hsquared:::hs_julia_run_fa_rank_command(
    "unused", "ledger", runner = function(command) stop(structure(
      list(message = "interrupted", call = NULL), class = c("interrupt", "condition")
    )), ledger_reader = function() partial
  ), interrupt = identity, error = identity)
  expect_s3_class(err, "hsquared_fa_rank_interrupt")
  expect_identical(err$partial_ledger, partial)
})

test_that("arc1_v1 identity is retained on an ordinary selected fit", {
  traits <- paste0("t", 1:4)
  ids <- c("a", "b")
  L <- matrix(c(1, .2, .1, .3), ncol = 1L)
  psi <- c(.5, .6, .7, .8)
  G <- tcrossprod(L) + diag(psi)
  R <- diag(4L)
  payload <- structure(list(
    Y = matrix(seq_len(8), 2L, 4L, dimnames = list(ids, traits)),
    y = seq_len(8), ids = ids, X = matrix(1, 2L, 1L), Z = diag(2L),
    metadata = list(trait_names = traits, fixed_colnames = "(Intercept)")
  ), class = "hs_bridge_payload")
  raw_fit <- list(
    genetic_structure = "factor_analytic", genetic_rank = 1L,
    traits = traits, breeding_traits = traits, breeding_ids = ids,
    genetic_covariance = G, residual_covariance = R,
    genetic_correlation = cov2cor(G), residual_correlation = diag(4L),
    genetic_uniqueness = psi,
    genetic_uniqueness_identification = "not_assessed_by_fit",
    heritability = diag(G) / (diag(G) + diag(R)),
    beta = matrix(0, 1L, 4L), breeding_values = matrix(0, 2L, 4L),
    loglik = -12.5, converged = TRUE, iterations = 1L,
    optimizer_policy = "arc1_v1", optimizer_policy_version = 1L,
    source_identity = "loaded-tree-sha256:abc", starts_scheduled = 19L,
    starts_attempted = 19L, final_gradient_inf_norm = 1e-7,
    numerical_gradient_inf_norms = c(1e-7, 2e-7),
    numerical_gradient_discrepancies = c(1e-8, 2e-8),
    numerical_gradient_status = "passed"
  )
  result <- hsquared:::hs_normalize_multivariate_result(
    raw_fit, payload, allow_missing_fa_start_metadata = TRUE
  )
  expect_identical(result$diagnostics$source_identity, "loaded-tree-sha256:abc")
  expect_identical(result$diagnostics$optimizer_policy_version, 1L)
  expect_equal(result$diagnostics$numerical_gradient_inf_norms, c(1e-7, 2e-7))
})

test_that("arc1_v2 controls and selector rows preserve actual policy evidence", {
  spec <- list(method = "REML", response = list(multivariate = TRUE), random = list(animal = TRUE))
  payload <- list(
    Y = matrix(seq_len(20), 5L, 4L), X = matrix(1, 5L, 1L), Z = diag(5L),
    family = "gaussian", pedigree = list(id = letters[1:5]),
    metadata = list(fixed_colnames = "(Intercept)")
  )
  control <- hs_control(engine = "julia", engine_control = list(
    target = "multivariate", rank_selection = "auto", optimizer_policy = "arc1_v2"
  ))
  expect_true(hsquared:::hs_validate_auto_fa_rank_control(
    control, "multivariate", spec, payload
  ))
  bad <- hs_control(engine = "julia", engine_control = list(
    target = "multivariate", rank_selection = "auto", optimizer_policy = "arc1_v2", iterations = 1999L
  ))
  expect_error(hsquared:::hs_validate_auto_fa_rank_control(
    bad, "multivariate", spec, payload
  ), class = "hsquared_unsupported_syntax")

  identity <- paste(rep("a", 64L), collapse = "")
  raw <- list(
    selection_status = "unavailable", reason = "one start refused",
    optimizer_policy = "arc1_v2", optimizer_policy_version = 2L,
    requested_optimizer_policy = "arc1_v2", actual_optimizer_policy = "arc1_v2",
    covariance_representation = "retained_factors_v1", source_identity = identity,
    starts_planned = 19L, starts_attempted = 1L,
    candidate_summary = list(
      list(rank = 0L, structure = "diagonal", status = "eligible", eligible = TRUE,
        optimizer_policy = "arc1_v2", optimizer_policy_version = 2L,
        actual_optimizer_policy = "arc1_v2", source_identity = identity),
      list(rank = 1L, structure = "factor_analytic", status = "failed", eligible = FALSE,
        optimizer_policy = "arc1_v2", optimizer_policy_version = 2L,
        actual_optimizer_policy = "arc1_v2", source_identity = identity)
    ),
    attempts = list(list(
      rank = 1L, structure = "factor_analytic", start_id = "default",
      retry_index = 0L, attempted = TRUE, status = "failed",
      eligible = FALSE, failure_status = "numerical_gradient_failure",
      optimizer_assessment_status = "numerical_gradient_failure",
      optimizer_assessment_reason = "independent gate failed",
      optimizer_policy = "arc1_v2", optimizer_policy_version = 2L,
      requested_optimizer_policy = "arc1_v2", actual_optimizer_policy = "arc1_v2",
      covariance_representation = "retained_factors_v1", source_identity = identity
    ))
  )
  result <- hsquared:::hs_normalize_fa_rank_selection(raw, structure(list(), class = "hs_bridge_payload"))
  expect_identical(result$optimizer_policy, "arc1_v2")
  expect_identical(result$optimizer_policy_version, 2L)
  expect_identical(result$actual_optimizer_policy, "arc1_v2")
  expect_identical(result$source_identity, identity)
  expect_identical(result$attempts$optimizer_assessment_status[[1L]], "numerical_gradient_failure")
  expect_identical(result$attempts$actual_optimizer_policy[[1L]], "arc1_v2")
  expect_identical(result$attempts$source_identity[[1L]], identity)
})

test_that("arc1_v2 selected likelihood fit carries explicit downstream refusal", {
  traits <- paste0("t", 1:4)
  ids <- c("a", "b")
  L <- matrix(rep(1e8, 4L), ncol = 1L)
  psi <- c(.5, .6, .7, .8)
  G <- tcrossprod(L) + diag(psi)
  R <- diag(4L)
  payload <- structure(list(
    Y = matrix(seq_len(8), 2L, 4L, dimnames = list(ids, traits)),
    y = seq_len(8), ids = ids, X = matrix(1, 2L, 1L), Z = diag(2L),
    metadata = list(trait_names = traits, fixed_colnames = "(Intercept)")
  ), class = "hs_bridge_payload")
  identity <- paste(rep("b", 64L), collapse = "")
  selected_fit <- list(
    genetic_structure = "factor_analytic", genetic_rank = 1L,
    traits = traits, breeding_traits = traits, breeding_ids = ids,
    genetic_covariance = G, residual_covariance = R,
    genetic_correlation = cov2cor(G), residual_correlation = diag(4L),
    genetic_uniqueness = psi, genetic_uniqueness_identification = "not_assessed_by_fit",
    heritability = diag(G) / (diag(G) + diag(R)), beta = NULL,
    breeding_values = NULL, loglik = -12.5, converged = TRUE, iterations = 1L,
    optimizer_policy = "arc1_v2", optimizer_policy_version = 2L,
    requested_optimizer_policy = "arc1_v2", actual_optimizer_policy = "arc1_v2",
    covariance_representation = "retained_factors_v1", source_identity = identity,
    matrix_operations_status = "unavailable",
    matrix_operations_reason = "rounded covariance output does not certify solver accuracy",
    downstream_diagnostics = list(gls = "not_certified", blup = "not_certified")
  )
  raw <- list(selection_status = "selected", selected_rank = 1L,
    optimizer_policy = "arc1_v2", optimizer_policy_version = 2L,
    requested_optimizer_policy = "arc1_v2", actual_optimizer_policy = "arc1_v2",
    covariance_representation = "retained_factors_v1", source_identity = identity,
    candidate_summary = list(
      list(rank = 0L, structure = "diagonal", status = "eligible", eligible = TRUE),
      list(rank = 1L, structure = "factor_analytic", status = "selected", eligible = TRUE)
    ), attempts = list(), selected_fit = selected_fit)
  out <- hsquared:::hs_normalize_fa_rank_selection(raw, payload)
  expect_identical(out$selected_fit$result$diagnostics$downstream_fit_status, "not_certified")
  expect_null(out$selected_fit$result$breeding_values)
  expect_null(out$selected_fit$result$random_effects)
  expect_true(all(is.na(out$selected_fit$result$fixed_effects$estimate)))
  expect_identical(out$selected_fit$result$diagnostics$source_identity, identity)
  expect_identical(out$selected_fit$result$diagnostics$matrix_operations_status, "unavailable")
})

test_that("arc1_v2 normalizers reject stale source and false eligibility", {
  payload <- structure(list(), class = "hs_bridge_payload")
  identity <- paste(rep("c", 64L), collapse = "")
  raw <- list(
    selection_status = "unavailable", optimizer_policy = "arc1_v2",
    optimizer_policy_version = 2L, source_identity = identity,
    candidate_summary = list(
      list(rank = 0L, structure = "diagonal"),
      list(rank = 1L, structure = "factor_analytic")
    ),
    attempts = list(list(
      rank = 1L, structure = "factor_analytic", attempted = TRUE,
      eligible = TRUE, optimizer_assessment_status = "missing",
      actual_optimizer_policy = "arc1_v2", source_identity = identity
    ))
  )
  expect_error(hsquared:::hs_normalize_fa_rank_selection(
    utils::modifyList(raw, list(source_identity = "stale")), payload
  ), "64-digit source identity")
  expect_error(hsquared:::hs_normalize_fa_rank_selection(raw, payload),
    "identity or acceptance evidence is inconsistent")
})

test_that("arc1_v2 selected K0 fits retain policy diagnostics without FA-only fields", {
  bridge_command <- hsquared:::hs_julia_fa_rank_serialization_command()
  expect_true(grepl("string.(hsq_mv_ids)", bridge_command, fixed = TRUE))
  expect_true(grepl('hsq_selection.optimizer_policy == "arc1_v2"', bridge_command, fixed = TRUE))
  traits <- paste0("t", 1:4)
  ids <- c("a", "b")
  G <- diag(c(1, 2, 3, 4))
  R <- diag(4L)
  payload <- structure(list(
    Y = matrix(seq_len(8), 2L, 4L, dimnames = list(ids, traits)),
    y = seq_len(8), ids = ids, X = matrix(1, 2L, 1L), Z = diag(2L),
    metadata = list(trait_names = traits, fixed_colnames = "(Intercept)")
  ), class = "hs_bridge_payload")
  selected_fit <- list(
    genetic_structure = "diagonal", traits = traits,
    breeding_traits = traits, breeding_ids = ids,
    genetic_covariance = G, residual_covariance = R,
    genetic_correlation = diag(4L), residual_correlation = diag(4L),
    heritability = diag(G) / (diag(G) + diag(R)), beta = NULL,
    breeding_values = NULL, loglik = -12.5, converged = TRUE, iterations = 1L,
    optimizer_policy = "arc1_v2", optimizer_policy_version = 2L,
    covariance_representation = "retained_factors_v1",
    source_identity = paste(rep("d", 64L), collapse = ""),
    matrix_operations_status = "unavailable",
    downstream_diagnostics = list(gls = "not_certified", blup = "not_certified")
  )
  raw <- list(
    selection_status = "selected", selected_rank = 0L,
    optimizer_policy = "arc1_v2", optimizer_policy_version = 2L,
    covariance_representation = "retained_factors_v1",
    source_identity = selected_fit$source_identity,
    candidate_summary = list(
      list(rank = 0L, structure = "diagonal", status = "selected", eligible = TRUE),
      list(rank = 1L, structure = "factor_analytic", status = "eligible", eligible = TRUE)
    ), attempts = list(), selected_fit = selected_fit
  )
  out <- hsquared:::hs_normalize_fa_rank_selection(raw, payload)
  expect_identical(out$selected_fit$result$diagnostics$optimizer_policy, "arc1_v2")
  expect_identical(out$selected_fit$result$diagnostics$downstream_fit_status, "not_certified")
  expect_null(out$selected_fit$result$breeding_values)
})
