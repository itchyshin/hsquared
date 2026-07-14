driver_tool <- testthat::test_path(
  "..", "..", "tools", "v07_genomic_recovery_v3.R"
)
testthat::skip_if_not(
  file.exists(driver_tool),
  "repository-only recovery-v3 driver is unavailable"
)
source(normalizePath(driver_tool, mustWork = TRUE), local = TRUE)

v3d_test_row <- function(seed = 123L) {
  data.frame(
    stage = "d1", cell_id = "SYNTHETIC_ONLY", cell_index = 1L,
    seed_offset = seed, seed = seed, n = 8L, m = 12L,
    marker_ratio = 1.5, marker_ratio_code = "r1p5",
    truth_sigma_g2 = 0.5, truth_sigma_e2 = 0.5,
    truth_ratio = 0.5, ridge = 0.01,
    stringsAsFactors = FALSE
  )[v3p_d1_columns]
}

v3d_test_preseal <- function() {
  c(
    relationship_source = "markers",
    relationship_method = "vanraden1",
    allele_frequency_source = "sample",
    relationship_scale = "K_lambda",
    ridge = "0.01",
    r_auto_route_commit = strrep("a", 40L),
    julia_candidate_commit = strrep("b", 40L),
    r_driver_commit = strrep("c", 40L),
    preseal_sha256 = strrep("d", 64L)
  )
}

v3d_test_construction <- function(touch_rng = FALSE) {
  force(touch_rng)
  function(M, ids, marker_names, julia_root) {
    if (touch_rng) stats::runif(17L)
    p <- colMeans(M) / 2
    W <- sweep(M, 2L, 2 * p, "-")
    k <- 2 * sum(p * (1 - p))
    K <- tcrossprod(W) / k + diag(0.01, nrow(M))
    Q <- solve(K)
    list(
      K = K, Q = Q,
      provenance = list(
        relationship_source = "markers",
        relationship_method = "vanraden1",
        allele_frequency_source = "sample",
        relationship_scale = "K_lambda",
        ridge = 0.01,
        scale_denominator = k,
        marker_content_fingerprint = v07d_marker_fingerprint(M, ids, marker_names),
        id_order_fingerprint = v07d_id_fingerprint(ids),
        kernel_fingerprint = v07d_matrix_fingerprint("K_lambda", K, ids),
        precision_fingerprint = v07d_matrix_fingerprint("Q_lambda", Q, ids)
      )
    )
  }
}

test_that("the public fit call is singular and contract exact", {
  code <- paste(deparse(body(v3d_fit_call)), collapse = "\n")
  hits <- gregexpr("hsquared::hsquared", code, fixed = TRUE)[[1L]]
  expect_equal(sum(hits > 0L), 1L)
  expect_match(code, "y ~ genomic\\(1 \\| id, markers = M\\)")
  expect_match(code, "family = stats::gaussian\\(\\)")
  expect_match(code, "REML = TRUE")
  expect_false(grepl("control|engine|target[[:space:]]*=", code))
})

test_that("execution guard admits only pinned Totoro or DRAC compute", {
  env <- c(
    GITHUB_ACTIONS = "false", CI = "false", SLURM_JOB_ID = "",
    OPENBLAS_NUM_THREADS = "1",
    JULIA_NUM_THREADS = "1", OMP_NUM_THREADS = "1", MKL_NUM_THREADS = "1",
    VECLIB_MAXIMUM_THREADS = "1", NUMEXPR_NUM_THREADS = "1"
  )
  expect_silent(v3d_assert_execution_context(host = "totoro", environment = env))
  expect_error(
    v3d_assert_execution_context(host = "login1", cluster = "fir", environment = env),
    "SLURM allocation"
  )
  allocated <- env; allocated[["SLURM_JOB_ID"]] <- "12345678"
  expect_silent(v3d_assert_execution_context(
    host = "login1", cluster = "fir", environment = allocated
  ))
  malformed <- allocated; malformed[["SLURM_JOB_ID"]] <- "interactive"
  expect_error(v3d_assert_execution_context(
    host = "login1", cluster = "fir", environment = malformed
  ), "SLURM allocation")
  bad <- env; bad[["GITHUB_ACTIONS"]] <- "true"
  expect_error(v3d_assert_execution_context(host = "totoro", environment = bad), "forbidden")
  bad <- env; bad[["CI"]] <- "TRUE"
  expect_error(v3d_assert_execution_context(host = "totoro", environment = bad), "forbidden")
  bad <- env; bad[["OPENBLAS_NUM_THREADS"]] <- "2"
  expect_error(v3d_assert_execution_context(host = "totoro", environment = bad), "pinned")
  expect_error(v3d_assert_execution_context(host = "laptop", environment = env), "Totoro")
})

test_that("the preseal binds the operational independent recomputer", {
  r_root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  julia_root <- normalizePath(file.path(r_root, "..", "HSquared.jl"), mustWork = TRUE)
  context <- v3d_context(r_root, r_root, julia_root)
  expect_identical(basename(context$r_recomputer_path), "v07_genomic_recovery_v3_recompute.R")
  expect_false(identical(context$r_recomputer_path, context$d0_recomputer_path))
  expect_false(grepl("preseal", basename(context$r_recomputer_path), fixed = TRUE))
})

test_that("review receipts are canonical create-once pairs", {
  root <- tempfile("v3d-review-"); dir.create(root)
  root <- normalizePath(root, mustWork = TRUE)
  on.exit(unlink(root, recursive = TRUE, force = TRUE), add = TRUE)
  path <- file.path(root, "fisher.tsv")
  args <- list(
    path, "fisher", "CLEAN", strrep("a", 64L), strrep("a", 40L),
    strrep("b", 40L), strrep("c", 40L), strrep("d", 40L), strrep("e", 40L)
  )
  expect_silent(do.call(v3d_write_review, args))
  expect_silent(v07d_verify_pair(path))
  expect_error(do.call(v3d_write_review, args), "already exists")
  writeLines("mutated", paste0(path, ".sha256"))
  expect_error(v07d_verify_pair(path), "sidecar mismatch")
})

test_that("construction-side RNG cannot perturb the frozen phenotype", {
  row <- v3d_test_row()
  r_root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  julia_root <- normalizePath(file.path(r_root, "..", "HSquared.jl"), mustWork = TRUE)
  stop_fit <- function(M, dat) stop("synthetic fit stop")
  quiet <- v3d_fit_one(
    row, "d1", v3d_test_preseal(), r_root, julia_root,
    fit_fun = stop_fit, construction_fun = v3d_test_construction(FALSE),
    rss_fun = function() 100
  )
  noisy <- v3d_fit_one(
    row, "d1", v3d_test_preseal(), r_root, julia_root,
    fit_fun = stop_fit, construction_fun = v3d_test_construction(TRUE),
    rss_fun = function() 100
  )
  expect_identical(quiet$packet$markers, noisy$packet$markers)
  expect_identical(quiet$packet$phenotype, noisy$packet$phenotype)
  expect_identical(quiet$attempt$error_class, "synthetic_fit_stop")
  expect_false(quiet$attempt$converged)
})

test_that("successful fit provenance matches every construction and preseal field", {
  M <- outer(seq_len(8L), seq_len(12L), function(i, j) (i + j) %% 3)
  ids <- sprintf("g%06d", seq_len(nrow(M)))
  marker_names <- sprintf("m%06d", seq_len(ncol(M)))
  construction <- v3d_test_construction()(M, ids, marker_names, "unused")$provenance
  fit <- construction
  preseal <- v3d_test_preseal()
  expect_silent(v3d_validate_fit_provenance(fit, construction, preseal))
  fields <- c(
    v3d_provenance_fields, "ridge", "scale_denominator",
    "marker_content_fingerprint", "id_order_fingerprint",
    "kernel_fingerprint", "precision_fingerprint"
  )
  for (field in fields) {
    mutated <- fit
    mutated[[field]] <- if (field %in% c("ridge", "scale_denominator")) {
      as.numeric(mutated[[field]]) + 0.001
    } else if (grepl("fingerprint$", field)) {
      strrep("f", 64L)
    } else {
      paste0(as.character(mutated[[field]]), "_mutated")
    }
    expect_error(
      v3d_validate_fit_provenance(mutated, construction, preseal),
      "differ"
    )
  }
  bad_preseal <- preseal; bad_preseal[["relationship_scale"]] <- "G"
  expect_error(
    v3d_validate_construction_provenance(construction, bad_preseal, 0.01),
    "preseal"
  )
})

test_that("synthetic D0F success extracts the fixed-panel fit end to end", {
  M <- outer(seq_len(8L), seq_len(12L), function(i, j) (i + 2 * j) %% 3)
  ids <- sprintf("g%06d", seq_len(nrow(M)))
  marker_names <- sprintf("m%06d", seq_len(ncol(M)))
  construction_fun <- v3d_test_construction()
  construction <- construction_fun(M, ids, marker_names, "unused")
  hashes <- c(
    marker_hash = construction$provenance$marker_content_fingerprint,
    id_hash = construction$provenance$id_order_fingerprint,
    kernel_hash = construction$provenance$kernel_fingerprint,
    precision_hash = construction$provenance$precision_fingerprint
  )
  row <- data.frame(
    stage = "d0f", design_id = "SYNTHETIC_D0F", design_index = 1L,
    panel_id = "SYNTHETIC_PANEL", panel_rank = 1L,
    source_cell_id = "SYNTHETIC_SOURCE", panel_source_seed = 11,
    phenotype_rank = 1L, seed = 321, n = 8L, m = 12L,
    marker_ratio = 1.5, retained_m = 12L,
    truth_sigma_g2 = 0.5, truth_sigma_e2 = 0.5,
    truth_ratio = 0.5, ridge = 0.01,
    marker_hash = hashes[["marker_hash"]], id_hash = hashes[["id_hash"]],
    kernel_hash = hashes[["kernel_hash"]], precision_hash = hashes[["precision_hash"]],
    stringsAsFactors = FALSE
  )[v3p_d0f_phenotype_columns]
  fixed_panel <- function(row) list(M = M, ids = ids, marker_names = marker_names)
  fit_fun <- function(M, dat) list(result = list(
    genomic_boundary = list(
      status = "interior", reason = "ai_interior", boundary_epsilon = 1e-7,
      profile_loglik = -1, lower_derivative_per_observation = 1,
      upper_derivative_per_observation = -1, profile_ratio = 0.5,
      numerical_ratio = 0.5
    ),
    converged = TRUE, relationship_provenance = construction$provenance,
    diagnostics = list(iterations = 3, gradient_norm = 1e-10), loglik = -1
  ))
  vc_fun <- function(fit) data.frame(
    component = c("genomic", "residual"), estimate = c(0.5, 0.5)
  )
  r_root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  julia_root <- normalizePath(file.path(r_root, "..", "HSquared.jl"), mustWork = TRUE)
  result <- v3d_fit_one(
    row, "d0f", v3d_test_preseal(), r_root, julia_root,
    fit_fun = fit_fun, construction_fun = construction_fun,
    fixed_panel_fun = fixed_panel, rss_fun = function() 100, vc_fun = vc_fun
  )
  expect_identical(result$attempt$status, "success")
  expect_true(result$attempt$converged)
  expect_equal(result$attempt$scientific_ratio, 0.5)
  expect_identical(names(result$attempt), v3p_d0f_attempt_columns)
  mutated <- row; mutated$kernel_hash <- strrep("f", 64L)
  expect_error(v3d_fit_one(
    mutated, "d0f", v3d_test_preseal(), r_root, julia_root,
    fit_fun = fit_fun, construction_fun = construction_fun,
    fixed_panel_fun = fixed_panel, rss_fun = function() 100, vc_fun = vc_fun
  ), "fixed-panel manifest")
})

test_that("packet publication is atomic and exact-membership fail-closed", {
  row <- v3d_test_row()
  r_root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  julia_root <- normalizePath(file.path(r_root, "..", "HSquared.jl"), mustWork = TRUE)
  generated <- v3d_fit_one(
    row, "d1", v3d_test_preseal(), r_root, julia_root,
    fit_fun = function(M, dat) stop("synthetic fit stop"),
    construction_fun = v3d_test_construction(), rss_fun = function() 100
  )
  output <- tempfile("v3d-output-"); dir.create(output)
  output <- normalizePath(output, mustWork = TRUE)
  on.exit(unlink(output, recursive = TRUE, force = TRUE), add = TRUE)
  expect_silent(v3d_write_packet(output, "d1", row, generated$packet))
  packet <- v3d_packet_dir(output, "d1", row)
  expect_silent(v3d_verify_packet(packet, "d1"))
  expect_error(v3d_write_packet(output, "d1", row, generated$packet), "already exists")
  writeLines("race mutation", file.path(packet, "unexpected.tmp"))
  expect_error(v3d_verify_packet(packet, "d1"), "file-set drift")
})

test_that("worker target checks ignore another worker's legitimate race window", {
  output <- tempfile("v3d-race-"); dir.create(output)
  output <- normalizePath(output, mustWork = TRUE)
  on.exit(unlink(output, recursive = TRUE, force = TRUE), add = TRUE)
  current <- v3d_test_row(123L)
  other <- v3d_test_row(124L)
  other_attempt <- v3d_attempt_path(output, "d1", other)
  dir.create(dirname(other_attempt), recursive = TRUE)
  writeLines("primary-before-sidecar", other_attempt)
  expect_identical(
    v3d_target_state(
      v3d_attempt_path(output, "d1", current),
      v3d_packet_dir(output, "d1", current)
    ),
    "absent"
  )
  expect_identical(
    v3d_target_state(other_attempt, v3d_packet_dir(output, "d1", other)),
    "partial"
  )
  run_body <- paste(deparse(body(v3d_run_one)), collapse = "\n")
  expect_false(grepl("v3d_phase_state", run_body, fixed = TRUE))
  expect_match(run_body, "v3d_target_state")
})

test_that("target state distinguishes regular pairs from directories and partials", {
  root <- tempfile("v3d-target-"); dir.create(root)
  root <- normalizePath(root, mustWork = TRUE)
  on.exit(unlink(root, recursive = TRUE, force = TRUE), add = TRUE)
  attempt <- file.path(root, "attempt.tsv")
  packet <- file.path(root, "packet")
  expect_identical(v3d_target_state(attempt, packet), "absent")
  dir.create(attempt)
  expect_identical(v3d_target_state(attempt, packet), "partial")
  unlink(attempt, recursive = TRUE)
  writeLines("attempt", attempt); writeLines("sidecar", paste0(attempt, ".sha256"))
  dir.create(packet)
  expect_identical(v3d_target_state(attempt, packet), "complete")
  unlink(packet, recursive = TRUE)
  expect_identical(v3d_target_state(attempt, packet), "partial")
})

test_that("quiescent phase enforces exact file and directory closure", {
  root <- tempfile("v3d-tree-"); dir.create(root)
  root <- normalizePath(root, mustWork = TRUE)
  outside <- tempfile("v3d-outside-"); dir.create(outside)
  on.exit(unlink(c(root, outside), recursive = TRUE, force = TRUE), add = TRUE)
  for (name in v3p_preseal_names("d1", TRUE)) {
    v07d_write_once(file.path(root, name), "synthetic\n")
  }
  manifest <- v3d_test_row()
  expect_silent(v3d_phase_state(root, "d1", manifest))
  dir.create(file.path(root, "extra-empty"))
  expect_error(v3d_phase_state(root, "d1", manifest), "file/directory member")
  unlink(file.path(root, "extra-empty"), recursive = TRUE)
  expect_true(file.symlink(outside, file.path(root, "extra-link")))
  expect_error(v3d_phase_state(root, "d1", manifest), "file/directory member|symlink")
  unlink(file.path(root, "extra-link"))
  fifo <- file.path(root, "extra-fifo")
  status <- system2("mkfifo", fifo)
  expect_identical(status, 0L)
  expect_error(v3d_phase_state(root, "d1", manifest), "file/directory member|non-regular")
})

test_that("external claims are create-once and block every quiescent gate", {
  output <- tempfile("v3d-claim-"); dir.create(output)
  output <- normalizePath(output, mustWork = TRUE)
  claim_root <- v3d_claim_root(output)
  on.exit(unlink(c(output, claim_root), recursive = TRUE, force = TRUE), add = TRUE)
  expect_false(dir.exists(claim_root))
  claim <- v3d_acquire_claim(output, "d1", v3d_test_row())
  expect_true(file.exists(claim))
  expect_error(v3d_acquire_claim(output, "d1", v3d_test_row()), "create-once")
  stale <- expect_error(v3d_assert_no_stale_claims(output), "stale or active")
  expect_match(conditionMessage(stale), claim, fixed = TRUE)
  expect_match(paste(deparse(body(v3d_verify_phase)), collapse = "\n"),
               "v3d_assert_no_stale_claims")
  expect_match(paste(deparse(body(v3d_lock_corpus)), collapse = "\n"),
               "v3d_assert_no_stale_claims")
  unlink(claim)
  expect_silent(v3d_assert_no_stale_claims(output))
})

test_that("synthetic selftest passes without consuming an official seed", {
  expect_message(v3d_selftest(), "PASS \\(synthetic only\\)")
})
