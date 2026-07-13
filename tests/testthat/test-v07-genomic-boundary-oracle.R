oracle_tool <- testthat::test_path("..", "..", "tools", "v07_genomic_boundary_oracle.R")
testthat::skip_if_not(
  file.exists(oracle_tool),
  "repository-only v0.7 boundary oracle is unavailable in the built package"
)
oracle_tool <- normalizePath(oracle_tool, mustWork = TRUE)
source(oracle_tool, local = TRUE)

v07_test_hash <- function(letter, n = 64L) paste(rep(letter, n), collapse = "")

v07_test_write <- function(x, path) {
  utils::write.table(x, path, sep = "\t", quote = FALSE, row.names = FALSE)
}

v07_test_reseal <- function(root) {
  lock <- data.frame(
    relative_path = v07_sealed_files,
    sha256 = vapply(
      v07_sealed_files,
      function(file) v07_sha256_file(file.path(root, file)),
      character(1L)
    ),
    stringsAsFactors = FALSE
  )
  v07_test_write(lock, file.path(root, "files.sha256.tsv"))
}

v07_test_packet <- function() {
  root <- tempfile("v07-oracle-packet-")
  dir.create(root)
  set.seed(1)
  y <- stats::rnorm(8)
  K <- crossprod(matrix(stats::rnorm(64), 8, 8)) / 8 + diag(8) * 0.1
  X <- matrix(1, 8, 1, dimnames = list(NULL, "x1"))
  colnames(K) <- paste0("k", seq_len(8))
  oracle <- v07_classify_oracle(y, X, K)
  stopifnot(oracle$class == "interior_oracle")

  metadata <- c(
    schema_version = v07_exchange_schema,
    phase = "holdout",
    cell_id = "n120_m600_r020",
    seed = "2027135001",
    role = "holdout",
    n = "8",
    p = "1",
    m = "12",
    ridge = "0.01",
    marker_hash = v07_test_hash("a"),
    id_hash = v07_test_hash("b"),
    kernel_hash = v07_test_hash("c"),
    doc45_commit = v07_frozen_documents[["doc45_commit"]],
    doc45_sha256 = v07_frozen_documents[["doc45_sha256"]],
    doc45a_commit = v07_frozen_documents[["doc45a_commit"]],
    doc45a_sha256 = v07_frozen_documents[["doc45a_sha256"]],
    doc45b_commit = v07_frozen_documents[["doc45b_commit"]],
    doc45b_sha256 = v07_frozen_documents[["doc45b_sha256"]],
    execution_commit = v07_test_hash("4", 40)
  )
  metadata <- data.frame(key = names(metadata), value = unname(metadata))
  arm <- stats::setNames(
    as.list(rep(NA, length(v07_arm_columns))),
    v07_arm_columns
  )
  arm[c("phase", "cell_id", "seed", "role")] <-
    list("holdout", "n120_m600_r020", 2027135001, "holdout")
  arm$arm_id <- "C100_E0"
  arm$cap <- 100
  arm$em_warmup <- 0
  arm$start_id <- "current"
  arm$start_sigma_g2 <- 1
  arm$start_sigma_e2 <- 1
  arm$converged <- TRUE
  arm$termination_reason <- "converged"
  arm$iterations <- 10
  arm$em_steps <- 0
  arm$factorizations <- 11
  arm$step_halvings <- 0
  arm$estimate_sigma_g2 <- oracle$sigma_g2
  arm$estimate_sigma_e2 <- oracle$sigma_e2
  arm$estimate_ratio <- oracle$ratio
  arm$julia_objective <- -oracle$loglik
  arm$ai_score_norm <- 0
  arm$julia_fd_log_gradient_norm <- 0
  arm$last_relative_change <- 0
  arm$smallest_component <- min(oracle$sigma_g2, oracle$sigma_e2)
  arm$runtime_seconds <- 0.1
  arm$peak_rss_mb <- 10
  arm$error_class <- "none"
  arm$marker_hash <- v07_test_hash("a")
  arm$id_hash <- v07_test_hash("b")
  arm$kernel_hash <- v07_test_hash("c")

  v07_test_write(data.frame(row = seq_along(y), y = y), file.path(root, "y.tsv"))
  v07_test_write(
    data.frame(row = seq_len(nrow(X)), as.data.frame(X), check.names = FALSE),
    file.path(root, "X.tsv")
  )
  v07_test_write(
    data.frame(row = seq_len(nrow(K)), as.data.frame(K), check.names = FALSE),
    file.path(root, "K.tsv")
  )
  v07_test_write(metadata, file.path(root, "metadata.tsv"))
  arm <- as.data.frame(arm, check.names = FALSE)
  second_arm <- arm
  second_arm$arm_id <- "C1000_E0"
  second_arm$cap <- 1000
  v07_test_write(rbind(arm, second_arm), file.path(root, "arms.tsv"))
  v07_test_reseal(root)
  root
}

test_that("profiled REML agrees with a direct dense base-R calculation", {
  set.seed(41)
  y <- stats::rnorm(7)
  X <- cbind(1, seq_len(7))
  K <- crossprod(matrix(stats::rnorm(49), 7, 7)) / 7 + diag(7) * 0.2
  r <- 0.37
  H <- r * K + (1 - r) * diag(7)
  Hinv <- solve(H)
  middle <- solve(crossprod(X, Hinv %*% X))
  P <- Hinv - Hinv %*% X %*% middle %*% t(X) %*% Hinv
  t_hat <- drop(crossprod(y, P %*% y)) / (7 - ncol(X))
  direct <- -0.5 *
    ((7 - ncol(X)) *
      (1 + log(2 * pi * t_hat)) +
      as.numeric(determinant(H, logarithm = TRUE)$modulus) +
      as.numeric(
        determinant(crossprod(X, Hinv %*% X), logarithm = TRUE)$modulus
      ))
  expect_equal(v07_profile_loglik(r, y, X, K), direct, tolerance = 1e-12)
})

test_that("grid refinement and endpoint KKT rules classify both cases", {
  set.seed(1)
  y <- stats::rnorm(8)
  K <- crossprod(matrix(stats::rnorm(64), 8, 8)) / 8 + diag(8) * 0.1
  expect_identical(
    v07_classify_oracle(y, matrix(1, 8, 1), K)$class,
    "interior_oracle"
  )

  set.seed(99)
  y <- stats::rnorm(8)
  A <- matrix(stats::rnorm(64), 8, 8)
  K <- crossprod(A) / 8 + diag(8) * 0.05
  X <- matrix(1, 8, 1)
  ordinary <- v07_classify_oracle(y, X, K)
  reversed <- v07_classify_oracle(y, X, K, reverse_kkt = TRUE)
  expect_identical(ordinary$class, "lower_boundary")
  expect_identical(reversed$class, "oracle_unresolved")

  tied <- v07_classify_oracle(stats::rnorm(8), matrix(1, 8, 1), diag(8))
  expect_identical(tied$class, "oracle_unresolved")
})

test_that("endpoint adjacency is symmetric at the frozen 1e-7 threshold", {
  expect_false(v07_is_distinct_interior(0.5e-7))
  expect_false(v07_is_distinct_interior(1e-7))
  expect_true(v07_is_distinct_interior(2e-7))
  expect_false(v07_is_distinct_interior(1 - 0.5e-7))
  expect_false(v07_is_distinct_interior(1 - 1e-7))
  expect_true(v07_is_distinct_interior(1 - 2e-7))
})

test_that("sealed packet produces a create-once 42-column per-arm join", {
  skip_if(Sys.which("shasum") == "" && Sys.which("sha256sum") == "")
  root <- v07_test_packet()
  exchange <- v07_read_exchange(root)
  out <- v07_build_oracle_rows(exchange)
  expect_identical(names(out), v07_oracle_columns)
  expect_length(names(out), 42L)
  expect_true(all(out$interior_agreement))
  expect_equal(out$oracle_fd_log_gradient_norm, c(0, 0), tolerance = 1e-8)

  output <- file.path(dirname(root), "oracle.tsv")
  expect_invisible(v07_write_create_once(out, output))
  expect_true(file.exists(output))
  expect_true(file.exists(paste0(output, ".sha256")))
  expect_invisible(v07_verify_output_sidecar(output))
  expect_invisible(v07_compare_output(v07_read_tsv(output), out))
  expect_error(v07_write_create_once(out, output), "refusing to overwrite")
})

test_that("packet and oracle mutations fail closed", {
  skip_if(Sys.which("shasum") == "" && Sys.which("sha256sum") == "")

  root <- v07_test_packet()
  write("extra", file.path(root, "extra.tsv"))
  expect_error(v07_read_exchange(root), "file set mismatch")

  root <- v07_test_packet()
  arms <- v07_read_tsv(file.path(root, "arms.tsv"))
  arms$julia_objective <- arms$julia_objective + 1
  v07_test_write(arms, file.path(root, "arms.tsv"))
  expect_error(v07_read_exchange(root), "sealed file hash mismatch")

  root <- v07_test_packet()
  arms <- v07_read_tsv(file.path(root, "arms.tsv"))
  arms$seed <- arms$seed + 1
  v07_test_write(arms, file.path(root, "arms.tsv"))
  v07_test_reseal(root)
  expect_error(v07_read_exchange(root), "mismatch in seed")

  root <- v07_test_packet()
  metadata <- v07_read_tsv(file.path(root, "metadata.tsv"))
  metadata$value[metadata$key == "doc45b_sha256"] <- v07_test_hash("0")
  v07_test_write(metadata, file.path(root, "metadata.tsv"))
  v07_test_reseal(root)
  expect_error(v07_read_exchange(root), "frozen doc45/doc45a/doc45b")

  root <- v07_test_packet()
  y <- v07_read_tsv(file.path(root, "y.tsv"))
  y$y[[1L]] <- Inf
  v07_test_write(y, file.path(root, "y.tsv"))
  v07_test_reseal(root)
  expect_error(v07_read_exchange(root), "non-finite")

  root <- v07_test_packet()
  exchange <- v07_read_exchange(root)
  expected <- v07_build_oracle_rows(exchange)
  output <- file.path(dirname(root), "mutated-oracle.tsv")
  v07_write_create_once(expected, output)
  changed <- v07_read_tsv(output)
  changed$oracle_class <- "lower_boundary"
  v07_test_write(changed, output)
  sidecar <- data.frame(
    sha256 = v07_sha256_file(output),
    file = basename(output)
  )
  v07_test_write(sidecar, paste0(output, ".sha256"))
  expect_invisible(v07_verify_output_sidecar(output))
  expect_error(
    v07_compare_output(v07_read_tsv(output), expected),
    "oracle_class"
  )

  for (field in c(
    "seed",
    "termination_reason",
    "estimate_ratio",
    "julia_objective",
    "oracle_ratio",
    "oracle_arm_loglik",
    "oracle_fd_log_gradient_norm",
    "interior_agreement",
    "dataset_files_digest"
  )) {
    changed <- expected
    if (is.logical(changed[[field]])) {
      changed[[field]][[1L]] <- !changed[[field]][[1L]]
    } else if (is.numeric(changed[[field]])) {
      changed[[field]][[1L]] <- changed[[field]][[1L]] + 1
    } else {
      changed[[field]][[1L]] <- paste0(changed[[field]][[1L]], "-mutated")
    }
    expect_error(v07_compare_output(changed, expected), field, fixed = TRUE)
  }

  reordered <- expected[rev(seq_len(nrow(expected))), , drop = FALSE]
  expect_error(v07_compare_output(reordered, expected), "mismatch")
})

test_that("CLI selftest is live", {
  result <- system2(
    file.path(R.home("bin"), "Rscript"),
    c(shQuote(oracle_tool), "selftest"),
    stdout = TRUE,
    stderr = TRUE
  )
  expect_null(attr(result, "status"))
  expect_true(any(grepl(
    "V07_GENOMIC_BOUNDARY_ORACLE_SELFTEST_PASS",
    result,
    fixed = TRUE
  )))
})

test_that("CLI oracle and verify modes exercise a sealed packet end to end", {
  skip_if(Sys.which("shasum") == "" && Sys.which("sha256sum") == "")
  root <- v07_test_packet()
  output <- file.path(dirname(root), paste0(basename(root), "-oracle.tsv"))
  common <- c("--dataset", shQuote(root), "--output", shQuote(output))
  created <- system2(
    file.path(R.home("bin"), "Rscript"),
    c(shQuote(oracle_tool), "oracle", common),
    stdout = TRUE,
    stderr = TRUE
  )
  expect_null(attr(created, "status"))
  verified <- system2(
    file.path(R.home("bin"), "Rscript"),
    c(shQuote(oracle_tool), "verify", common),
    stdout = TRUE,
    stderr = TRUE
  )
  expect_null(attr(verified, "status"))
  repeated <- suppressWarnings(system2(
    file.path(R.home("bin"), "Rscript"),
    c(shQuote(oracle_tool), "oracle", common),
    stdout = TRUE,
    stderr = TRUE
  ))
  expect_identical(attr(repeated, "status"), 1L)
  expect_true(any(grepl("refusing to overwrite", repeated, fixed = TRUE)))
})

v07_test_holdout_reseal <- function(root) {
  for (file in v07_holdout_files) {
    path <- file.path(root, file)
    v07_test_write(
      data.frame(sha256 = v07_sha256_file(path), file = basename(path)),
      paste0(path, ".sha256")
    )
  }
  lock <- data.frame(
    relative_path = v07_holdout_files,
    sha256 = vapply(v07_holdout_files, function(file) {
      v07_sha256_file(file.path(root, file))
    }, character(1L))
  )
  lock_path <- file.path(root, "files.sha256.tsv")
  v07_test_write(lock, lock_path)
  v07_test_write(
    data.frame(sha256 = v07_sha256_file(lock_path), file = basename(lock_path)),
    paste0(lock_path, ".sha256")
  )
}

v07_test_holdout_binding <- local({
  cached <- NULL
  function() {
    if (!is.null(cached)) return(cached)
    root <- tempfile("v07-doc47-binding-")
    repo <- file.path(root, "r-repo")
    dir.create(file.path(repo, "tools"), recursive = TRUE)
    oracle <- file.path(repo, "tools", "v07_genomic_boundary_oracle.R")
    file.copy(oracle_tool, oracle)
    git <- function(...) {
      result <- system2("git", c("-C", shQuote(repo), ...), stdout = TRUE, stderr = TRUE)
      stopifnot(is.null(attr(result, "status")))
      result
    }
    git("init", "-q")
    git("config", "user.email", "oracle-test@example.invalid")
    git("config", "user.name", "Oracle Test")
    git("add", "tools/v07_genomic_boundary_oracle.R")
    git("commit", "-q", "-m", shQuote("freeze test oracle"))
    r_commit <- git("rev-parse", "HEAD")[[1L]]
    values <- stats::setNames(rep("fixture", length(v07_holdout_seal_keys)),
      v07_holdout_seal_keys)
    hash_keys <- grep("_sha256$", names(values), value = TRUE)
    values[hash_keys] <- v07_test_hash("1")
    values["discovery_digest"] <- v07_test_hash("2")
    values[c(
      "reference_commit", "julia_boundary_impl_commit", "r_boundary_impl_commit",
      "r_execution_commit", "discovery_candidate_commit",
      "candidate_implementation_commit", "julia_driver_commit", "execution_commit"
    )] <- v07_test_hash("7", 40)
    values[c(
      "schema_version", "exchange_schema"
    )] <- v07_holdout_schema
    values[c("candidate_id", "profiler_candidate_id")] <- v07_holdout_candidate_id
    values["doc46_commit"] <- v07_holdout_doc46[["commit"]]
    values["doc46_sha256"] <- v07_holdout_doc46[["sha256"]]
    values["doc47_commit"] <- v07_holdout_doc47[["commit"]]
    values["doc47_sha256"] <- v07_holdout_doc47[["sha256"]]
    values["reference_commit"] <- v07_holdout_reference_commit
    values[c("julia_boundary_impl_commit", "discovery_candidate_commit",
      "candidate_implementation_commit")] <- v07_holdout_julia_implementation_commit
    values[c("r_boundary_impl_commit", "r_execution_commit")] <- r_commit
    values["r_oracle_sha256"] <- v07_sha256_file(oracle)
    values["profiler_schema"] <- "v07-genomic-boundary-performance-v2"
    values["packet_file_set"] <- paste(v07_holdout_files, collapse = ",")
    values["provenance_domain_hex"] <-
      "48537175617265642d70726f76656e616e63652d763100"
    values["provenance_encoding"] <-
      "sha256-little-endian-u64-float64-length-framed-utf8-v1"
    values["result_digest_encoding"] <-
      "sha256-utf8-field-equals-value-newline-float17g-v1"
    values[c("id_hash_kind", "kernel_hash_kind", "precision_hash_kind")] <-
      c("id_order", "K_lambda", "Q_lambda")
    values["qk_identity_tolerance"] <- "1e-10"
    values[c("relationship_source", "relationship_method",
      "allele_frequency_source", "ridge", "relationship_scale")] <-
      unname(v07_holdout_relationship)
    values[c("boundary_epsilon", "grid_step", "refinement_abs_tol",
      "likelihood_tie_per_observation", "derivative_delta",
      "kkt_tolerance_per_observation")] <- sprintf(
        "%.17g", c(v07_holdout_epsilon, 0.0025, 1e-12, 1e-10, 1e-6, 1e-8)
      )
    values["holdout_seed_formula"] <- "2027120000+10000*cell_index+6001:6048"
    values["timing_protocol"] <- "fixed_nonholdout_warmup_then_seed_parity_order"
    values["holdout_p95_rule"] <- "sort(x)[ceil(0.95*48)]"
    values[c("holdout_runtime_ratio_limit", "discovery_runtime_ratio_limit",
      "discovery_reference_ratio_limit")] <- c("3", "2.5", "1.10")
    values[c("julia_driver_commit", "execution_commit")] <- v07_test_hash("8", 40)
    values[c("julia_num_threads", "openblas_num_threads", "omp_num_threads",
      "veclib_maximum_threads")] <- "1"
    values["holdout_absent_before_seal"] <- "true"
    values["spent_offset_block_excluded"] <- "5001:5048"
    seal <- file.path(root, "candidate_seal.tsv")
    v07_test_write(data.frame(key = names(values), value = unname(values)), seal)
    v07_test_write(
      data.frame(sha256 = v07_sha256_file(seal), file = basename(seal)),
      paste0(seal, ".sha256")
    )
    cached <<- list(
      root = root, repo = repo, oracle = oracle, seal = seal,
      values = values, digest = v07_sha256_file(seal)
    )
    cached
  }
})

v07_test_holdout_packet <- function(binding = v07_test_holdout_binding()) {
  root <- tempfile("v07-doc47-packet-")
  dir.create(root)
  old_digits <- getOption("digits")
  options(digits = 17L)
  on.exit(options(digits = old_digits), add = TRUE)
  set.seed(1)
  y <- stats::rnorm(8)
  X <- matrix(1, 8, 1, dimnames = list(NULL, "x1"))
  K <- crossprod(matrix(stats::rnorm(64), 8, 8)) / 8 + diag(8) * 0.1
  Q <- solve(K)
  ids <- paste0("id", seq_len(8))
  colnames(K) <- paste0("k", seq_len(8))
  colnames(Q) <- paste0("q", seq_len(8))
  v07_test_write(data.frame(row = seq_len(8), K, check.names = FALSE),
    file.path(root, "K.tsv"))
  v07_test_write(data.frame(row = seq_len(8), Q, check.names = FALSE),
    file.path(root, "Q.tsv"))
  K <- v07_numeric_matrix(v07_read_tsv(file.path(root, "K.tsv"))[-1L], "K.tsv")
  Q <- v07_numeric_matrix(v07_read_tsv(file.path(root, "Q.tsv"))[-1L], "Q.tsv")
  colnames(K) <- paste0("k", seq_len(8))
  colnames(Q) <- paste0("q", seq_len(8))
  oracle <- v07_classify_oracle(y, X, K)
  stopifnot(oracle$class == "interior_oracle")
  metadata <- c(
    schema_version = v07_holdout_schema,
    candidate_id = v07_holdout_candidate_id,
    cell_id = "n120_m600_r020",
    seed = "2027135001",
    n = "8", p = "1", m = "12", ridge = "0.01",
    marker_hash = v07_test_hash("a"),
    id_hash = v07_id_fingerprint(ids),
    kernel_hash = v07_matrix_fingerprint("K_lambda", K, ids),
    precision_hash = v07_matrix_fingerprint("Q_lambda", Q, ids),
    relationship_source = v07_holdout_relationship[["source"]],
    relationship_method = v07_holdout_relationship[["method"]],
    allele_frequency_source = v07_holdout_relationship[["allele_frequency_source"]],
    relationship_scale = v07_holdout_relationship[["scale"]],
    doc46_commit = v07_holdout_doc46[["commit"]],
    doc46_sha256 = v07_holdout_doc46[["sha256"]],
    doc47_commit = v07_holdout_doc47[["commit"]],
    doc47_sha256 = v07_holdout_doc47[["sha256"]],
    julia_boundary_impl_commit = v07_holdout_julia_implementation_commit,
    r_boundary_impl_commit = binding$values[["r_boundary_impl_commit"]],
    discovery_digest = binding$values[["discovery_digest"]],
    discovery_equivalence_sha256 = binding$values[["discovery_equivalence_sha256"]],
    discovery_timing_sha256 = binding$values[["discovery_timing_sha256"]],
    discovery_selection_sha256 = binding$values[["discovery_selection_sha256"]],
    candidate_seal_sha256 = binding$digest,
    holdout_manifest_sha256 = binding$values[["holdout_manifest_sha256"]],
    execution_commit = binding$values[["execution_commit"]],
    driver_sha256 = binding$values[["boundary_driver_sha256"]],
    r_oracle_sha256 = binding$values[["r_oracle_sha256"]]
  )
  mkfit <- function(route) {
    candidate <- route == "boundary_candidate"
    out <- data.frame(
      cell_id = metadata[["cell_id"]], seed = as.numeric(metadata[["seed"]]),
      route = route, timed_order = "default_ai>boundary_candidate", converged = TRUE,
      termination_reason = if (candidate) "ai_interior" else "converged",
      optimizer_status = if (candidate) "ai_interior" else "converged",
      iterations = 10, sigma_g2 = oracle$sigma_g2,
      sigma_e2 = oracle$sigma_e2, numerical_ratio = oracle$ratio,
      profile_ratio = if (candidate) oracle$ratio else NaN,
      profile_t_hat = if (candidate) oracle$sigma_g2 + oracle$sigma_e2 else NaN,
      boundary_status = if (candidate) "interior" else "not_classified",
      boundary_epsilon = v07_holdout_epsilon,
      profile_loglik = if (candidate) oracle$loglik else NaN,
      lower_derivative_per_observation = if (candidate) {
        oracle$d0_per_observation
      } else NaN,
      upper_derivative_per_observation = if (candidate) {
        oracle$d1_per_observation
      } else NaN,
      objective = -oracle$loglik, ai_score_norm = 0,
      fd_log_gradient_norm = 0, runtime_seconds = 0.1,
      marker_hash = metadata[["marker_hash"]],
      id_hash = metadata[["id_hash"]], kernel_hash = metadata[["kernel_hash"]],
      precision_hash = metadata[["precision_hash"]],
      relationship_source = metadata[["relationship_source"]],
      relationship_method = metadata[["relationship_method"]],
      allele_frequency_source = metadata[["allele_frequency_source"]],
      ridge = as.numeric(metadata[["ridge"]]),
      relationship_scale = metadata[["relationship_scale"]],
      result_digest = NA_character_,
      error_class = "none",
      check.names = FALSE
    )
    out$result_digest <- v07_holdout_result_digest(out)
    out[v07_holdout_fit_columns]
  }
  v07_test_write(data.frame(row = seq_along(y), y = y), file.path(root, "y.tsv"))
  v07_test_write(data.frame(row = seq_len(8), X, check.names = FALSE),
    file.path(root, "X.tsv"))
  v07_test_write(data.frame(row = seq_len(8), K, check.names = FALSE),
    file.path(root, "K.tsv"))
  v07_test_write(data.frame(row = seq_len(8), Q, check.names = FALSE),
    file.path(root, "Q.tsv"))
  v07_test_write(data.frame(row = seq_len(8), id = ids),
    file.path(root, "ids.tsv"))
  v07_test_write(data.frame(key = names(metadata), value = unname(metadata)),
    file.path(root, "metadata.tsv"))
  fits_path <- file.path(root, "fits.tsv")
  v07_test_write(rbind(mkfit("default_ai"), mkfit("boundary_candidate")), fits_path)
  serialized_fits <- v07_read_tsv(fits_path)
  serialized_fits$result_digest <- vapply(seq_len(nrow(serialized_fits)), function(index) {
    v07_holdout_result_digest(serialized_fits[index, , drop = FALSE])
  }, character(1L))
  v07_test_write(serialized_fits, fits_path)
  v07_test_holdout_reseal(root)
  root
}

v07_test_read_holdout <- function(root, binding = v07_test_holdout_binding()) {
  v07_read_holdout_exchange(
    root, binding$seal, binding$repo, oracle_path = binding$oracle
  )
}

test_that("doc47 v2 holdout constants bind the selected candidate", {
  expect_identical(v07_holdout_schema, "v07-genomic-boundary-holdout-v2")
  expect_identical(v07_holdout_candidate_id, "doc47_boundary_performance_v1")
  expect_identical(
    v07_holdout_julia_implementation_commit,
    "fc9d39df650b20aa09d769d9f9528eed1b606f1e"
  )
  expect_identical(
    unname(v07_holdout_doc47),
    c(
      "13eb97c3dfd49b461db04b7b9cc10587c99a5a73",
      "400fbae28806443a6962545caf95587178f35ad0e91dd2b562cf88ea61a9b264"
    )
  )
  expect_identical(
    v07_holdout_files,
    c("K.tsv", "Q.tsv", "X.tsv", "fits.tsv", "ids.tsv", "metadata.tsv", "y.tsv")
  )
})

test_that("doc47 base-R provenance encoder matches the independent golden digests", {
  expect_identical(
    v07_id_fingerprint(c("alpha", "id2")),
    "e91221fde844edffa91e7d4701b28ecbfe2176eacb2eb341d062597726e2c4dc"
  )
  numeric_matrix <- matrix(c(1, -2.5, -0, 0), nrow = 2)
  expect_identical(
    v07_matrix_fingerprint("K_lambda", numeric_matrix, c("a", "b")),
    "2c21985923be46408dd7d1c9387a9faac9c167b75e677bd952dfef6e7fc7221e"
  )
})

test_that("doc47 sealed holdout packet produces and verifies one oracle row", {
  skip_if(Sys.which("shasum") == "" && Sys.which("sha256sum") == "")
  root <- v07_test_holdout_packet()
  exchange <- v07_test_read_holdout(root)
  out <- v07_build_holdout_oracle(exchange)
  expect_identical(names(out), v07_holdout_oracle_columns)
  expect_equal(nrow(out), 1L)
  expect_identical(out$oracle_class, "interior_oracle")
  output <- file.path(dirname(root), paste0(basename(root), "-oracle.tsv"))
  expect_invisible(v07_write_holdout_oracle(out, output))
  expect_invisible(v07_verify_holdout_oracle(output, out))
  expect_error(v07_write_holdout_oracle(out, output), "refusing to overwrite")

  changed <- v07_read_tsv(output)
  changed$precision_hash <- v07_test_hash("f")
  v07_test_write(changed, output)
  v07_test_write(
    data.frame(sha256 = v07_sha256_file(output), file = basename(output)),
    paste0(output, ".sha256")
  )
  expect_error(v07_verify_holdout_oracle(output, out), "precision_hash")
})

test_that("doc47 candidate seal and frozen R checkout mutations fail closed", {
  binding <- v07_test_holdout_binding()
  mutated <- tempfile("v07-mutated-seal-", fileext = ".tsv")
  seal <- v07_read_tsv(binding$seal)
  seal$value[seal$key == "candidate_id"] <- "doc46_boundary_v1"
  v07_test_write(seal, mutated)
  v07_test_write(
    data.frame(sha256 = v07_sha256_file(mutated), file = basename(mutated)),
    paste0(mutated, ".sha256")
  )
  expect_error(
    v07_holdout_read_candidate_seal(mutated, binding$repo, binding$oracle),
    "frozen contract"
  )

  dirty <- file.path(binding$repo, "untracked-mutation")
  writeLines("dirty", dirty)
  expect_error(
    v07_holdout_read_candidate_seal(binding$seal, binding$repo, binding$oracle),
    "not clean"
  )
  unlink(dirty)
  expect_type(
    v07_holdout_read_candidate_seal(binding$seal, binding$repo, binding$oracle),
    "list"
  )
})

test_that("doc47 packet hash, order, fit, seed, and hash drift fail closed", {
  skip_if(Sys.which("shasum") == "" && Sys.which("sha256sum") == "")
  root <- v07_test_holdout_packet()
  lock <- v07_read_tsv(file.path(root, "files.sha256.tsv"))
  lock_path <- file.path(root, "files.sha256.tsv")
  v07_test_write(lock[c(2, 1, 3:7), ], lock_path)
  v07_test_write(
    data.frame(sha256 = v07_sha256_file(lock_path), file = basename(lock_path)),
    paste0(lock_path, ".sha256")
  )
  expect_error(v07_test_read_holdout(root), "set or order")

  root <- v07_test_holdout_packet()
  fits <- v07_read_tsv(file.path(root, "fits.tsv"))
  fits$objective[[2L]] <- fits$objective[[2L]] + 1
  v07_test_write(fits, file.path(root, "fits.tsv"))
  expect_error(
    v07_test_read_holdout(root),
    "checksum|sidecar|sealed file hash mismatch"
  )

  root <- v07_test_holdout_packet()
  fits <- v07_read_tsv(file.path(root, "fits.tsv"))
  fits$seed[[2L]] <- fits$seed[[2L]] + 1
  v07_test_write(fits, file.path(root, "fits.tsv")); v07_test_holdout_reseal(root)
  expect_error(v07_test_read_holdout(root), "mismatch in seed")

  root <- v07_test_holdout_packet()
  fits <- v07_read_tsv(file.path(root, "fits.tsv"))
  fits$kernel_hash[[2L]] <- v07_test_hash("f")
  v07_test_write(fits, file.path(root, "fits.tsv")); v07_test_holdout_reseal(root)
  expect_error(v07_test_read_holdout(root), "mismatch in kernel_hash")

  root <- v07_test_holdout_packet()
  metadata <- v07_read_tsv(file.path(root, "metadata.tsv"))
  metadata$value[metadata$key == "candidate_id"] <- "doc46_boundary_v1"
  v07_test_write(metadata, file.path(root, "metadata.tsv")); v07_test_holdout_reseal(root)
  expect_error(v07_test_read_holdout(root), "candidate")

  root <- v07_test_holdout_packet()
  metadata <- v07_read_tsv(file.path(root, "metadata.tsv"))
  metadata$value[metadata$key == "relationship_method"] <- "vanraden2"
  v07_test_write(metadata, file.path(root, "metadata.tsv")); v07_test_holdout_reseal(root)
  expect_error(v07_test_read_holdout(root), "construction or scale")

  root <- v07_test_holdout_packet()
  Q <- v07_read_tsv(file.path(root, "Q.tsv"))
  Q$q1[[1L]] <- Q$q1[[1L]] + 0.01
  v07_test_write(Q, file.path(root, "Q.tsv")); v07_test_holdout_reseal(root)
  expect_error(v07_test_read_holdout(root), "symmetry|identity|fingerprint")

  root <- v07_test_holdout_packet()
  fits <- v07_read_tsv(file.path(root, "fits.tsv"))
  fits$result_digest[[2L]] <- v07_test_hash("0")
  v07_test_write(fits, file.path(root, "fits.tsv")); v07_test_holdout_reseal(root)
  expect_error(v07_test_read_holdout(root), "scientific-result digest")

  root <- v07_test_holdout_packet()
  fits <- v07_read_tsv(file.path(root, "fits.tsv"))
  fits$termination_reason[[2L]] <- "boundary_lower"
  fits$optimizer_status[[2L]] <- "boundary_lower"
  fits$boundary_status[[2L]] <- "boundary_lower"
  fits$profile_ratio[[2L]] <- 0
  fits$numerical_ratio[[2L]] <- v07_holdout_epsilon / 2
  fits_path <- file.path(root, "fits.tsv")
  v07_test_write(fits, fits_path)
  fits <- v07_read_tsv(fits_path)
  fits$result_digest[[2L]] <- v07_holdout_result_digest(fits[2L, , drop = FALSE])
  v07_test_write(fits, fits_path); v07_test_holdout_reseal(root)
  expect_error(v07_test_read_holdout(root), "lower-boundary scientific/numerical")
})

test_that("doc47 endpoint adjacency, tie, and KKT signs fail safely", {
  expect_false(v07_is_distinct_interior(v07_holdout_epsilon))
  expect_true(v07_is_distinct_interior(2 * v07_holdout_epsilon))
  expect_false(v07_is_distinct_interior(1 - v07_holdout_epsilon))
  expect_true(v07_is_distinct_interior(1 - 2 * v07_holdout_epsilon))

  set.seed(99)
  y <- stats::rnorm(8); A <- matrix(stats::rnorm(64), 8, 8)
  K <- crossprod(A) / 8 + diag(8) * 0.05; X <- matrix(1, 8, 1)
  expect_identical(v07_classify_oracle(y, X, K)$class, "lower_boundary")
  expect_identical(
    v07_classify_oracle(y, X, K, reverse_kkt = TRUE)$class,
    "oracle_unresolved"
  )
  expect_identical(
    v07_classify_oracle(stats::rnorm(8), X, diag(8))$class,
    "oracle_unresolved"
  )
})

test_that("doc47 CLI modes create and independently verify synthetic output", {
  skip_if(Sys.which("shasum") == "" && Sys.which("sha256sum") == "")
  binding <- v07_test_holdout_binding()
  root <- v07_test_holdout_packet(binding)
  output <- file.path(dirname(root), paste0(basename(root), "-cli-oracle.tsv"))
  common <- c(
    "--dataset", shQuote(root), "--output", shQuote(output),
    "--seal", shQuote(binding$seal), "--r-repo", shQuote(binding$repo)
  )
  created <- system2(file.path(R.home("bin"), "Rscript"),
    c(shQuote(binding$oracle), "holdout-oracle", common), stdout = TRUE, stderr = TRUE)
  expect_null(attr(created, "status"))
  verified <- system2(file.path(R.home("bin"), "Rscript"),
    c(shQuote(binding$oracle), "holdout-verify", common), stdout = TRUE, stderr = TRUE)
  expect_null(attr(verified, "status"))
})
