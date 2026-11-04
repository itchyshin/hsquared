test_that("FA-rank plain fields retain both candidates, actual attempts, and missing values", {
  payload <- structure(list(), class = "hs_bridge_payload")
  G <- diag(4)
  raw <- list(
    selection_status = "unavailable",
    candidate_summary = list(
      list(rank = 0L, structure = "diagonal", status = "eligible", eligible = TRUE),
      list(rank = 1L, structure = "factor_analytic", status = "failed", eligible = FALSE)
    ),
    attempts = list(list(
      rank = 0L, structure = "diagonal", start_id = "default", retry_index = 0L,
      status = "eligible", attempted = TRUE, eligible = TRUE,
      genetic_covariance = G, residual_covariance = G,
      initial_parameters = c(1, 2), estimated_parameters = c(3, 4),
      uniqueness = c(1, 2, 3, 4), floor_distances = c(0.1, 0.2, 0.3, 0.4),
      line_search_stats = "callback_requests = 3"
    ))
  )
  result <- hsquared:::hs_normalize_fa_rank_selection(raw, payload)

  expect_s3_class(result, "hsquared_fa_rank_selection")
  expect_equal(nrow(result$candidate_summary), 2L)
  expect_equal(result$candidate_summary$rank, c(0L, 1L))
  expect_equal(nrow(result$attempts), 1L)
  expect_true(is.matrix(result$attempts$genetic_covariance[[1L]]))
  expect_equal(result$attempts$initial_parameters[[1L]], c(1, 2))
  expect_equal(result$attempts$estimated_parameters[[1L]], c(3, 4))
  expect_equal(result$attempts$uniqueness[[1L]], 1:4)
  expect_identical(result$attempts$line_search_stats, "callback_requests = 3")
  expect_true(is.na(result$criterion_difference))
  expect_true(is.na(result$reason))
  expect_true(is.na(result$attempts$criterion[[1L]]))
  expect_null(result$selected_fit)
})

test_that("FA-rank column payloads tolerate absent optional schema fields", {
  rows <- list(
    rank = c("0", "1"),
    status = c("eligible", "failed"),
    eligible = c("true", "false"),
    line_search_stats = c("callback_requests = 3", "callback_requests = 0")
  )
  schema <- list(
    rank = "integer",
    status = "character",
    eligible = "logical",
    line_search_stats = "character",
    source_identity = "character"
  )

  normalized <- hsquared:::hs_fa_rank_rows(rows, schema)

  expect_identical(normalized$rank, c(0L, 1L))
  expect_identical(normalized$status, c("eligible", "failed"))
  expect_identical(normalized$eligible, c(TRUE, FALSE))
  expect_identical(
    normalized$line_search_stats,
    c("callback_requests = 3", "callback_requests = 0")
  )
  expect_true(all(is.na(normalized$source_identity)))
})

test_that("FA-rank column payloads tolerate extra keys and preserve rank row count", {
  covariance <- array(seq_len(24), dim = c(2L, 3L, 2L))
  rows <- list(
    genetic_covariance = covariance,
    rank = c("0", "1"),
    status = c("eligible", "failed"),
    julia_extra_diagnostic = c("x", "y")
  )
  schema <- list(
    rank = "integer",
    status = "character",
    genetic_covariance = "matrix"
  )

  normalized <- hsquared:::hs_fa_rank_rows(rows, schema)

  expect_identical(normalized$rank, c(0L, 1L))
  expect_identical(normalized$status, c("eligible", "failed"))
  expect_equal(nrow(normalized), 2L)
  expect_identical(normalized$genetic_covariance[[1L]], covariance[, , 1L])
  expect_identical(normalized$genetic_covariance[[2L]], covariance[, , 2L])
})

test_that("FA-rank column payloads refuse columns inconsistent with empty rank", {
  schema <- list(rank = "integer", status = "character")

  expect_error(
    hsquared:::hs_fa_rank_rows(
      list(rank = integer(), status = "eligible"), schema
    ),
    "column lengths do not match rank rows"
  )
})

test_that("FA-rank column payloads preserve vector-matrix orientation", {
  rows <- list(
    rank = c("0", "1"),
    genetic_vector = matrix(seq_len(6L), nrow = 3L)
  )
  schema <- list(rank = "integer", genetic_vector = "vector")

  normalized <- hsquared:::hs_fa_rank_rows(rows, schema)

  expect_identical(normalized$rank, c(0L, 1L))
  expect_identical(normalized$genetic_vector[[1L]], c(1, 2, 3))
  expect_identical(normalized$genetic_vector[[2L]], c(4, 5, 6))
})

test_that("FA-rank single-column vector matrices preserve trait orientation", {
  schema <- list(rank = "integer", genetic_vector = "vector")
  singleton <- hsquared:::hs_fa_rank_rows(
    list(rank = "1", genetic_vector = matrix(7:9, nrow = 3L)), schema
  )

  expect_identical(singleton$rank, 1L)
  expect_identical(singleton$genetic_vector[[1L]], c(7, 8, 9))
})

test_that("FA-rank singleton payloads allow explicit NULL matrix and vector cells", {
  rows <- list(rank = "1", genetic_vector = NULL, genetic_covariance = NULL)
  schema <- list(
    rank = "integer", genetic_vector = "vector", genetic_covariance = "matrix"
  )

  normalized <- hsquared:::hs_fa_rank_rows(rows, schema)

  expect_identical(normalized$rank, 1L)
  expect_null(normalized$genetic_vector[[1L]])
  expect_null(normalized$genetic_covariance[[1L]])
})

test_that("FA-rank column payload validation still rejects inconsistent shapes", {
  schema <- list(rank = "integer", genetic_vector = "vector")

  expect_error(
    hsquared:::hs_fa_rank_rows(
      list(rank = c("0", "1"), genetic_vector = matrix(seq_len(12L), nrow = 3L)),
      schema
    ),
    "column lengths do not match rank rows"
  )
  expect_error(
    hsquared:::hs_fa_rank_rows(
      list(rank = c("0", "1"), genetic_vector = list(1:3)), schema
    ),
    "column lengths do not match rank rows"
  )
})

test_that("K1 selected-fit normalization retains structured genetic metadata", {
  traits <- paste0("t", 1:4)
  ids <- c("a", "b")
  Y <- matrix(seq_len(8), nrow = 2L, dimnames = list(ids, traits))
  payload <- structure(list(
    Y = Y, y = as.vector(Y), ids = ids,
    X = matrix(1, 2L, 1L), Z = diag(2L),
    metadata = list(
      trait_names = traits, fixed_colnames = "(Intercept)"
    )
  ), class = "hs_bridge_payload")
  L <- matrix(c(1, .2, .1, .3), ncol = 1L,
    dimnames = list(traits, "factor1"))
  psi <- c(.5, .6, .7, .8)
  G <- tcrossprod(L) + diag(psi)
  R <- diag(4L)
  raw_fit <- list(
    genetic_structure = "factor_analytic", genetic_rank = 1L,
    traits = traits, breeding_traits = traits, breeding_ids = ids,
    genetic_covariance = G, residual_covariance = R,
    genetic_correlation = cov2cor(G), residual_correlation = diag(4L),
    genetic_uniqueness = psi,
    genetic_uniqueness_identification = "not_assessed_by_fit",
    heritability = diag(G) / (diag(G) + diag(R)),
    beta = matrix(0, 1L, 4L), breeding_values = matrix(0, 2L, 4L),
    loglik = -12.5, converged = TRUE, iterations = 7L,
    fa_start_strategy = "default_balanced_retry",
    fa_start_starts_attempted = 2L, fa_start_selected_start = "balanced",
    fa_start_objective_range = 0.1,
    fa_start_g_relative_disagreement = 0.01,
    fa_start_r_relative_disagreement = 0.01,
    fa_start_better_nonconverged_start = FALSE,
    fa_start_minimum_uniqueness = min(psi),
    fa_start_uniqueness_floor_distance = min(psi) - 0.05,
    fa_start_near_uniqueness_floor = FALSE,
    fa_start_names = c("default", "balanced"),
    fa_start_loglik = c(-12.6, -12.5),
    fa_start_valid = c(TRUE, TRUE), fa_start_converged = c(TRUE, TRUE),
    fa_start_iterations = c(5L, 7L),
    fa_start_minimum_uniqueness_by_start = c(min(psi), min(psi)),
    fa_start_uniqueness_floor_distance_by_start = c(.45, .45)
  )
  raw <- list(
    selection_status = "selected", selected_rank = 1L,
    candidate_summary = list(
      list(rank = 0L, structure = "diagonal", status = "eligible", eligible = TRUE),
      list(rank = 1L, structure = "factor_analytic", status = "selected", eligible = TRUE)
    ),
    attempts = list(), selected_fit = raw_fit
  )

  normalized <- hsquared:::hs_normalize_fa_rank_selection(raw, payload)
  expect_s3_class(normalized$selected_fit, "hsquared_fit")
  fit <- normalized$selected_fit
  expect_equal(fit$result$genetic_structure, "factor_analytic")
  expect_equal(fit$result$diagnostics$genetic_rank, 1L)
  expect_equal(fit$result$genetic_uniqueness, stats::setNames(psi, traits))
  expect_equal(fit$result$diagnostics$genetic_uniqueness_identification, "not_assessed_by_fit")
  expect_equal(unname(genetic_covariance(fit)), unname(G), tolerance = 1e-12)
  expect_equal(unname(residual_covariance(fit)), unname(R), tolerance = 1e-12)
  expect_equal(nrow(fit$result$diagnostics$fa_start_starts), 2L)
  expect_equal(fit$result$diagnostics$fa_start_selected_start, "balanced")
})

test_that("automatic FA-rank control is explicit and rejects conflicting or unsupported routes", {
  spec <- list(method = "REML", response = list(multivariate = TRUE), random = list(animal = TRUE))
  payload <- list(
    Y = matrix(1, 5, 4), X = matrix(1, 5, 1), Z = diag(5),
    family = "gaussian",
    metadata = list(fixed_colnames = "(Intercept)")
  )
  control <- hs_control(engine = "julia", engine_control = list(
    target = "multivariate", rank_selection = "auto"
  ))
  expect_true(hsquared:::hs_validate_auto_fa_rank_control(control, "multivariate", spec, payload))

  fixed_rank <- hs_control(engine = "julia", engine_control = list(
    target = "multivariate", genetic_structure = "factor_analytic", rank = 1L
  ))
  expect_false(hsquared:::hs_validate_auto_fa_rank_control(
    fixed_rank, "multivariate", spec, payload
  ))

  conflict <- hs_control(engine = "julia", engine_control = list(
    target = "multivariate", rank_selection = "auto", rank = 1L
  ))
  expect_error(
    hsquared:::hs_validate_auto_fa_rank_control(conflict, "multivariate", spec, payload),
    class = "hsquared_unsupported_syntax"
  )
  non_julia <- hs_control(engine = "fit", engine_control = list(
    target = "multivariate", rank_selection = "auto"
  ))
  expect_error(
    hsquared:::hs_validate_auto_fa_rank_control(non_julia, "multivariate", spec, payload),
    class = "hsquared_unsupported_syntax"
  )
  non_reml <- spec
  non_reml$method <- "ML"
  expect_error(
    hsquared:::hs_validate_auto_fa_rank_control(control, "multivariate", non_reml, payload),
    class = "hsquared_unsupported_syntax"
  )
  incomplete <- payload
  incomplete$Y[1, 1] <- NA_real_
  expect_error(
    hsquared:::hs_validate_auto_fa_rank_control(control, "multivariate", spec, incomplete),
    class = "hsquared_unsupported_syntax"
  )
  non_gaussian <- payload
  non_gaussian$family <- "poisson"
  expect_error(
    hsquared:::hs_validate_auto_fa_rank_control(control, "multivariate", spec, non_gaussian),
    class = "hsquared_unsupported_syntax"
  )
  repeated <- payload
  repeated$Z[2, ] <- repeated$Z[1, ]
  expect_error(
    hsquared:::hs_validate_auto_fa_rank_control(control, "multivariate", spec, repeated),
    class = "hsquared_unsupported_syntax"
  )
  three_traits <- payload
  three_traits$Y <- three_traits$Y[, 1:3, drop = FALSE]
  expect_error(
    hsquared:::hs_validate_auto_fa_rank_control(control, "multivariate", spec, three_traits),
    class = "hsquared_unsupported_syntax"
  )
})

hs_auto_fa_require_live <- function() {
  identical(tolower(Sys.getenv("HSQUARED_AUTO_FA_REQUIRE_LIVE", "false")), "true")
}

test_that("mandatory live FA-rank bridge selects on ordinary starts and matches direct Julia", {
  if (!hs_auto_fa_require_live()) {
    skip("Set HSQUARED_AUTO_FA_REQUIRE_LIVE=true for mandatory-live FA-rank acceptance.")
  }
  if (!requireNamespace("JuliaCall", quietly = TRUE) ||
      !isTRUE(hsquared:::hs_julia_bridge_available())) {
    stop("HSQUARED_AUTO_FA_REQUIRE_LIVE=true but JuliaCall/Julia/HSquared.jl selector is unavailable.")
  }

  fixture <- utils::read.delim(
    testthat::test_path("fixtures", "auto_fa_rank", "ordinary_start.tsv"),
    stringsAsFactors = FALSE
  )
  id <- as.character(fixture$id)
  ped <- fixture[c("id", "sire", "dam")]
  ped$sire[ped$sire == 0] <- NA
  ped$dam[ped$dam == 0] <- NA
  dat <- data.frame(
    id = id, t1 = fixture$y1, t2 = fixture$y2,
    t3 = fixture$y3, t4 = fixture$y4
  )
  control <- hs_control(engine = "julia", engine_control = list(
    target = "multivariate", rank_selection = "auto", iterations = 10000L
  ))

  ledger_names_before <- as.character(JuliaCall::julia_eval(
    'string.(filter(n -> startswith(string(n), "hsq_fa_ledger_"), names(Main)))'
  ))
  selected <- hsquared(cbind(t1, t2, t3, t4) ~ animal(1 | id, pedigree = ped),
    data = dat, control = control)
  ledger_names_after <- as.character(JuliaCall::julia_eval(
    'string.(filter(n -> startswith(string(n), "hsq_fa_ledger_"), names(Main)))'
  ))
  new_ledgers <- setdiff(ledger_names_after, ledger_names_before)
  expect_gt(length(new_ledgers), 0L)
  expect_true(all(vapply(new_ledgers, function(name) {
    isTRUE(JuliaCall::julia_eval(paste0(name, "[] === nothing")))
  }, logical(1))))
  expect_s3_class(selected, "hsquared_fa_rank_selection")
  expect_identical(selected$selection_status, "selected")
  expect_true(selected$selected_rank %in% c(0L, 1L))
  expect_s3_class(selected$selected_fit, "hsquared_fit")
  expect_s3_class(selected$selected_fit$spec$formula, "formula")
  expect_false(is.null(selected$selected_fit$call))
  expect_equal(nrow(selected$candidate_summary), 2L)
  expect_gte(nrow(selected$attempts), 2L)
  expect_true("attempted" %in% names(selected$attempts))
  expect_true(all(selected$attempts$attempted %in% TRUE))
  expect_equal(selected$uncertainty_scope, "conditional_on_selected_rank")
  expect_equal(selected$candidate_summary$rank, c(0L, 1L))

  JuliaCall::julia_command(paste(
    "hsq_fa_direct = HSquared.select_fa_rank(hsq_Y, hsq_X, hsq_Z, hsq_ped;",
    "ids = hsq_ped.ids, traits = hsq_traits, iterations = hsq_iterations);"
  ))
  direct_rank <- JuliaCall::julia_eval("hsq_fa_direct.selected_rank")
  direct_G <- JuliaCall::julia_eval("Matrix(hsq_fa_direct.selected_fit.genetic_covariance)")
  direct_R <- JuliaCall::julia_eval("Matrix(hsq_fa_direct.selected_fit.residual_covariance)")
  direct_D <- JuliaCall::julia_eval("hsq_fa_direct.criterion_difference")
  direct_candidate_rank <- JuliaCall::julia_eval(
    "[row.rank for row in hsq_fa_direct.candidate_summary]"
  )
  direct_candidate_eligible <- JuliaCall::julia_eval(
    "[row.eligible for row in hsq_fa_direct.candidate_summary]"
  )
  direct_candidate_ll <- JuliaCall::julia_eval(
    "[row.loglik for row in hsq_fa_direct.candidate_summary]"
  )
  direct_candidate_q <- JuliaCall::julia_eval(
    "[row.q for row in hsq_fa_direct.candidate_summary]"
  )
  direct_candidate_penalty <- JuliaCall::julia_eval(
    "[row.penalty for row in hsq_fa_direct.candidate_summary]"
  )
  direct_candidate_criteria <- JuliaCall::julia_eval(
    "[row.criterion for row in hsq_fa_direct.candidate_summary]"
  )
  direct_attempt_rank <- JuliaCall::julia_eval("[row.rank for row in hsq_fa_direct.attempts]")
  direct_attempt_start <- JuliaCall::julia_eval("[string(row.start_id) for row in hsq_fa_direct.attempts]")
  direct_attempt_status <- JuliaCall::julia_eval("[string(row.status) for row in hsq_fa_direct.attempts]")
  direct_attempt_eligible <- JuliaCall::julia_eval("[row.eligible for row in hsq_fa_direct.attempts]")
  direct_attempt_converged <- JuliaCall::julia_eval("[row.converged for row in hsq_fa_direct.attempts]")
  direct_attempt_ll <- JuliaCall::julia_eval("[row.loglik for row in hsq_fa_direct.attempts]")
  direct_attempt_recheck <- JuliaCall::julia_eval("[row.reevaluated_loglik for row in hsq_fa_direct.attempts]")
  direct_attempt_discrepancy <- JuliaCall::julia_eval("[row.objective_discrepancy for row in hsq_fa_direct.attempts]")
  direct_attempt_near_floor <- JuliaCall::julia_eval("[row.near_floor for row in hsq_fa_direct.attempts]")
  direct_attempt_G <- lapply(seq_len(length(direct_attempt_rank)), function(i) {
    JuliaCall::julia_eval(sprintf("Matrix(hsq_fa_direct.attempts[%d].genetic_covariance)", i))
  })
  direct_attempt_R <- lapply(seq_len(length(direct_attempt_rank)), function(i) {
    JuliaCall::julia_eval(sprintf("Matrix(hsq_fa_direct.attempts[%d].residual_covariance)", i))
  })
  direct_attempt_psi <- lapply(seq_len(length(direct_attempt_rank)), function(i) {
    JuliaCall::julia_eval(sprintf("collect(Float64, hsq_fa_direct.attempts[%d].uniqueness)", i))
  })
  direct_attempt_floor <- lapply(seq_len(length(direct_attempt_rank)), function(i) {
    JuliaCall::julia_eval(sprintf("collect(Float64, hsq_fa_direct.attempts[%d].floor_distances)", i))
  })
  expect_equal(as.integer(direct_rank), selected$selected_rank)
  expect_equal(unname(genetic_covariance(selected$selected_fit)), direct_G, tolerance = 1e-8)
  expect_equal(unname(residual_covariance(selected$selected_fit)), direct_R, tolerance = 1e-8)
  expect_equal(as.numeric(direct_D), selected$criterion_difference, tolerance = 1e-8)
  expect_equal(as.integer(direct_candidate_rank), selected$candidate_summary$rank)
  expect_equal(as.logical(direct_candidate_eligible), selected$candidate_summary$eligible)
  expect_equal(as.numeric(direct_candidate_ll), selected$candidate_summary$loglik, tolerance = 1e-8)
  expect_equal(as.integer(direct_candidate_q), selected$candidate_summary$q)
  expect_equal(as.numeric(direct_candidate_penalty), selected$candidate_summary$penalty)
  expect_equal(as.numeric(direct_candidate_criteria), selected$candidate_summary$criterion, tolerance = 1e-8)
  expect_equal(as.integer(direct_attempt_rank), selected$attempts$rank)
  expect_equal(as.character(direct_attempt_start), selected$attempts$start_id)
  expect_equal(as.character(direct_attempt_status), selected$attempts$status)
  expect_equal(as.logical(direct_attempt_eligible), selected$attempts$eligible)
  expect_equal(as.logical(direct_attempt_converged), selected$attempts$converged)
  expect_equal(as.numeric(direct_attempt_ll), selected$attempts$loglik, tolerance = 1e-8)
  expect_equal(as.numeric(direct_attempt_recheck), selected$attempts$reevaluated_loglik, tolerance = 1e-8)
  expect_equal(as.numeric(direct_attempt_discrepancy), selected$attempts$objective_discrepancy, tolerance = 1e-10)
  expect_equal(as.logical(direct_attempt_near_floor), selected$attempts$near_floor)
  for (i in seq_along(direct_attempt_rank)) {
    expect_equal(selected$attempts$genetic_covariance[[i]], direct_attempt_G[[i]], tolerance = 1e-8)
    expect_equal(selected$attempts$residual_covariance[[i]], direct_attempt_R[[i]], tolerance = 1e-8)
    expect_equal(selected$attempts$uniqueness[[i]], direct_attempt_psi[[i]], tolerance = 1e-8)
    expect_equal(selected$attempts$floor_distances[[i]], direct_attempt_floor[[i]], tolerance = 1e-8)
  }

  # Reject a finite optimizer-reported objective that differs from the
  # independent same-covariance objective. Its raw value remains diagnostic,
  # while failed starts carry no inferential score and cannot drive summaries.
  JuliaCall::julia_command(paste(
    "hsq_bad_score = HSquared._select_fa_rank(hsq_Y, hsq_X, hsq_Z, hsq_ped;",
    "ids = hsq_ped.ids, traits = hsq_traits, iterations = hsq_iterations,",
    "attempt_runner = (objective, params0, iterations, rank, start_id) -> begin",
    "(; phat = copy(params0), objective = objective(params0) + 0.01,",
    "converged = true, iterations = 1, optimizer_status = \"injected_offset\")",
    "end);",
    "hsq_selection = hsq_bad_score;"
  ))
  JuliaCall::julia_command(hsquared:::hs_julia_fa_rank_serialization_command())
  bad_score_raw <- JuliaCall::julia_eval("hsq_selection_raw")
  bad_score <- hsquared:::hs_normalize_fa_rank_selection(
    bad_score_raw, selected$selected_fit$payload
  )
  expect_identical(bad_score$selection_status, "unavailable")
  expect_equal(nrow(bad_score$candidate_summary), 2L)
  expect_gt(nrow(bad_score$attempts), 0L)
  expect_true(all(bad_score$attempts$status == "failed"))
  expect_true(all(is.finite(bad_score$attempts$optimizer_objective)))
  expect_true(all(is.na(bad_score$attempts$loglik)))
  expect_true(all(is.na(bad_score$attempts$criterion)))
  expect_true(all(is.finite(bad_score$attempts$reevaluated_loglik)))
  expect_equal(
    bad_score$attempts$optimizer_objective + bad_score$attempts$reevaluated_loglik,
    rep(0.01, nrow(bad_score$attempts)), tolerance = 1e-8
  )
  expect_true(all(bad_score$candidate_summary$status == "failed"))
  expect_true(all(is.na(bad_score$candidate_summary$objective_range)))
  expect_false(bad_score$start_sensitive)

  direct_bv <- JuliaCall::julia_eval("Matrix(hsq_fa_direct.selected_fit.breeding_values.values)")
  direct_bv_ids <- JuliaCall::julia_eval("string.(collect(hsq_fa_direct.selected_fit.breeding_values.ids))")
  direct_bv_traits <- JuliaCall::julia_eval("string.(collect(hsq_fa_direct.selected_fit.breeding_values.traits))")
  expect_equal(breeding_values(selected$selected_fit)$id, rep(as.character(direct_bv_ids), times = length(direct_bv_traits)))
  expect_equal(breeding_values(selected$selected_fit)$trait, rep(as.character(direct_bv_traits), each = length(direct_bv_ids)))
  expect_equal(matrix(breeding_values(selected$selected_fit)$value,
    nrow = length(direct_bv_ids), ncol = length(direct_bv_traits)), direct_bv, tolerance = 1e-8)

  # Same phenotypes under unrelated founders are a real engine-level
  # identification refusal; the bridge must preserve both candidate reasons.
  JuliaCall::julia_command("hsq_auto_ped_before_identity = hsq_ped;")
  identity_ped <- data.frame(id = id, sire = NA_character_, dam = NA_character_)
  unavailable <- hsquared(
    cbind(t1, t2, t3, t4) ~ animal(1 | id, pedigree = identity_ped),
    data = dat, control = control
  )
  expect_identical(unavailable$selection_status, "unsupported_input")
  expect_null(unavailable$selected_fit)
  expect_equal(nrow(unavailable$candidate_summary), 2L)
  expect_equal(nrow(unavailable$attempts), 0L)
  expect_match(unavailable$reason, "unresolved on REML contrasts")
  JuliaCall::julia_command("hsq_ped = hsq_auto_ped_before_identity;")

  # Interrupt a real selector inside its first optimizer start. The exact
  # production Julia serializer/reader returns a plain R partial ledger before
  # this request-local Ref is cleared.
  interrupt_payload <- structure(list(
    Y = as.matrix(dat[c("t1", "t2", "t3", "t4")]),
    y = as.vector(as.matrix(dat[c("t1", "t2", "t3", "t4")])),
    ids = id, X = matrix(1, length(id), 1L), Z = diag(length(id)),
    family = "gaussian",
    metadata = list(
      trait_names = c("t1", "t2", "t3", "t4"),
      fixed_colnames = "(Intercept)"
    )
  ), class = "hs_bridge_payload")
  ledger_name <- paste0("hsq_interrupt_test_", gsub("[^A-Za-z0-9_]", "_", basename(tempfile())))
  JuliaCall::julia_command(paste0(ledger_name, " = Ref{Any}(nothing);"))
  interrupt_command <- paste(
    "hsq_selection = HSquared._select_fa_rank(hsq_Y, hsq_X, hsq_Z, hsq_ped;",
    "ids = hsq_ped.ids, traits = hsq_traits, iterations = 2000, ledger_sink =", ledger_name, ",",
    "attempt_runner = (objective, params0, iterations, rank, start_id) -> throw(InterruptException()));"
  )
  interrupted <- tryCatch(
    hsquared:::hs_julia_run_fa_rank_command(
      interrupt_command, ledger_name,
      ledger_reader = function() hsquared:::hs_julia_read_fa_rank_partial_ledger(
        ledger_name, interrupt_payload
      )
    ),
    hsquared_fa_rank_interrupt = identity
  )
  expect_s3_class(interrupted, "hsquared_fa_rank_interrupt")
  partial <- interrupted$partial_ledger
  expect_s3_class(partial, "hsquared_fa_rank_selection")
  expect_identical(partial$selection_status, "interrupted")
  expect_equal(nrow(partial$candidate_summary), 2L)
  expect_equal(partial$candidate_summary$rank, c(0L, 1L))
  expect_equal(nrow(partial$attempts), 1L)
  expect_identical(partial$attempts$rank, 0L)
  expect_identical(partial$attempts$status, "interrupted")
  expect_true(isTRUE(partial$attempts$attempted))
  expect_true(is.na(partial$attempts$optimizer_iterations))
  expect_true(is.na(partial$attempts$loglik))
  expect_true(is.na(partial$attempts$converged))
  expect_false(any(vapply(partial$attempts, inherits, logical(1), "JuliaObject")))
  expect_match(interrupted$message, "InterruptException|interrupted", ignore.case = TRUE)

  # Cleanup occurs only after the captured R snapshot is available; clearing
  # the request Ref must not mutate that immutable partial ledger.
  JuliaCall::julia_command(paste0(ledger_name, "[] = nothing;"))
  expect_true(is.null(JuliaCall::julia_eval(paste0(ledger_name, "[]"))))
  expect_identical(partial$selection_status, "interrupted")

  # Controlled transport witness: reuse a real eligible K1 attempt from the
  # ordinary selector run, mark another K1 start failed with genuinely missing
  # optimizer fields, and override only the selection winner. This tests K1
  # serialization and nullable diagnostics, not selection policy.
  JuliaCall::julia_command(paste(
    "hsq_k1_ctx = HSquared._fa_rank_context(hsq_Y, hsq_X, hsq_Z, hsq_ped, hsq_traits);",
    "hsq_k1_attempts = copy(hsq_fa_direct.attempts);",
    "hsq_k1_rows = findall(a -> a.rank == 1, hsq_k1_attempts);",
    "hsq_k1_good = filter(i -> hsq_k1_attempts[i].eligible, hsq_k1_rows);",
    "isempty(hsq_k1_good) && error(\"ordinary fixture has no eligible K1 transport witness\");",
    "hsq_k1_idx = hsq_k1_good[argmax([hsq_k1_attempts[i].loglik for i in hsq_k1_good])];",
    "hsq_k1_attempts[hsq_k1_idx] = merge(hsq_k1_attempts[hsq_k1_idx], (selected_within_rank=true, selected=true));",
    "hsq_k1_bad_rows = filter(i -> i != hsq_k1_idx, hsq_k1_rows);",
    "isempty(hsq_k1_bad_rows) && error(\"ordinary fixture has no second K1 diagnostic start\");",
    "hsq_k1_bad_idx = first(hsq_k1_bad_rows);",
    "hsq_k1_attempts[hsq_k1_bad_idx] = merge(hsq_k1_attempts[hsq_k1_bad_idx], (status=:failed, reason=\"controlled nonfinite objective after finite parameters\", converged=nothing, optimizer_iterations=nothing, finite_objective=false, finite_estimates=true, pd_genetic=nothing, pd_residual=nothing, loglik=nothing, reevaluated_loglik=nothing, objective_discrepancy=nothing, q=nothing, penalty=nothing, criterion=nothing, uniqueness=nothing, floor_distances=nothing, near_floor=nothing, eligible=false, selected_within_rank=false, selected=false, genetic_covariance=nothing, residual_covariance=nothing, genetic_loadings=nothing));",
    "hsq_k1_fit = HSquared._fa_rank_fit(hsq_k1_ctx, hsq_k1_attempts[hsq_k1_idx], hsq_fa_direct.candidate_summary, hsq_k1_attempts);",
    "hsq_k1_candidates = copy(hsq_fa_direct.candidate_summary);",
    "hsq_k1_candidates[2] = merge(hsq_k1_candidates[2], (status=:selected,));",
    "hsq_selection = merge(hsq_fa_direct, (selection_status=:selected, selected_rank=1, selected_fit=hsq_k1_fit, attempts=hsq_k1_attempts, candidate_summary=hsq_k1_candidates));"
  ))
  expect_equal(as.integer(JuliaCall::julia_eval("hsq_selection.selected_rank")), 1L)
  JuliaCall::julia_command(hsquared:::hs_julia_fa_rank_serialization_command())
  k1_raw <- JuliaCall::julia_eval("hsq_selection_raw")
  k1_payload <- structure(list(
    Y = as.matrix(dat[c("t1", "t2", "t3", "t4")]),
    y = as.vector(as.matrix(dat[c("t1", "t2", "t3", "t4")])),
    ids = id, X = matrix(1, length(id), 1L), Z = diag(length(id)),
    family = "gaussian",
    metadata = list(
      trait_names = c("t1", "t2", "t3", "t4"),
      fixed_colnames = "(Intercept)"
    )
  ), class = "hs_bridge_payload")
  k1_result <- hsquared:::hs_normalize_fa_rank_selection(k1_raw, k1_payload)
  expect_identical(k1_result$selection_status, "selected")
  expect_identical(k1_result$selected_rank, 1L)
  expect_s3_class(k1_result$selected_fit, "hsquared_fit")
  expect_equal(k1_result$selected_fit$result$genetic_structure, "factor_analytic")
  expect_equal(k1_result$selected_fit$result$diagnostics$genetic_rank, 1L)
  expect_equal(length(k1_result$selected_fit$result$genetic_uniqueness), 4L)
  expect_identical(
    k1_result$selected_fit$result$diagnostics$genetic_uniqueness_identification,
    "not_assessed_by_fit"
  )
  expect_equal(nrow(k1_result$selected_fit$result$diagnostics$fa_start_starts), 2L)
  k1_starts <- k1_result$selected_fit$result$diagnostics$fa_start_starts
  expect_equal(nrow(k1_starts), 2L)
  expect_equal(sum(!k1_starts$valid), 1L)
  failed_start <- which(!k1_starts$valid)
  expect_true(is.na(k1_starts$loglik[failed_start]))
  expect_true(is.na(k1_starts$converged[failed_start]))
  expect_true(is.na(k1_starts$iterations[failed_start]))
  expect_equal(unname(genetic_covariance(k1_result$selected_fit)),
    unname(k1_result$selected_fit$result$genetic_covariance), tolerance = 1e-8)
})

test_that("R bridge propagates interruption with its partial selector ledger", {
  partial <- list(selection_status = "interrupted", attempts = list(list(
    rank = 0L, status = "completed", attempted = TRUE
  )))
  ledger <- NULL
  runner <- function(command) {
    ledger <<- partial
    stop(structure(list(message = "user interrupt", call = NULL),
      class = c("interrupt", "condition")))
  }
  caught <- tryCatch(
    hsquared:::hs_julia_run_fa_rank_command(
      "controlled interrupt", "hsq_fa_ledger", runner = runner,
      ledger_reader = function() ledger
    ),
    hsquared_fa_rank_interrupt = identity
  )
  expect_s3_class(caught, "hsquared_fa_rank_interrupt")
  expect_identical(caught$partial_ledger, partial)
})
