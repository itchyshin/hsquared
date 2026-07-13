#!/usr/bin/env Rscript

# Independent base-R closed-domain REML oracle for the frozen v0.7 genomic
# optimizer-localization study. This developer tool deliberately does not load
# hsquared or call any package construction or fitting helper.

v07_oracle_source_path <- local({
  file_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
  candidates <- gsub("~+~", " ", sub("^--file=", "", file_arg), fixed = TRUE)
  frame_files <- vapply(sys.frames(), function(frame) {
    value <- frame$ofile
    if (is.null(value)) "" else as.character(value[[1L]])
  }, character(1L))
  candidates <- c(candidates, rev(frame_files[nzchar(frame_files)]))
  if (!length(candidates)) NULL else normalizePath(candidates[[1L]], mustWork = TRUE)
})

v07_exchange_schema <- "v07-genomic-localization-exchange-v1"
v07_endpoint_adjacency <- 1e-7
v07_frozen_documents <- c(
  doc45_commit = "e2b4b23957ab4075205a7399214daae186a04bcb",
  doc45_sha256 = "4eb8b7012140d6f5f30d7c4cfbaf46f974ef5a3caa7b0c4f14e002ddf8657f50",
  doc45a_commit = "1ce3720ab31eb2108acd842fdd74f6c1ddbc45ec",
  doc45a_sha256 = "f88509b2aa715c5836bbc387284e94e3fcc6904d66ec00290f71b2e099f18182",
  doc45b_commit = "a4a5e27ae2dbc7e86012aa1f81438ce73ebaf156",
  doc45b_sha256 = "75ae42baa13ce5044e95be4d2a4d4a5b71a2eef3b98caa22c57adbad9e46c6a3"
)
v07_sealed_files <- c("K.tsv", "X.tsv", "arms.tsv", "metadata.tsv", "y.tsv")
v07_metadata_keys <- c(
  "schema_version",
  "phase",
  "cell_id",
  "seed",
  "role",
  "n",
  "p",
  "m",
  "ridge",
  "marker_hash",
  "id_hash",
  "kernel_hash",
  "doc45_commit",
  "doc45_sha256",
  "doc45a_commit",
  "doc45a_sha256",
  "doc45b_commit",
  "doc45b_sha256",
  "execution_commit"
)
v07_arm_columns <- c(
  "phase",
  "cell_id",
  "seed",
  "role",
  "arm_id",
  "cap",
  "em_warmup",
  "start_id",
  "start_sigma_g2",
  "start_sigma_e2",
  "converged",
  "termination_reason",
  "iterations",
  "em_steps",
  "factorizations",
  "step_halvings",
  "estimate_sigma_g2",
  "estimate_sigma_e2",
  "estimate_ratio",
  "julia_objective",
  "ai_score_norm",
  "julia_fd_log_gradient_norm",
  "last_relative_change",
  "smallest_component",
  "runtime_seconds",
  "peak_rss_mb",
  "error_class",
  "marker_hash",
  "id_hash",
  "kernel_hash"
)
v07_atomic_arm_ids <- c(
  "C100_E0", "C1000_E0", "C100_E5", "C1000_E5",
  "S050_C100_E0", "S050_C1000_E0", "S050_C100_E5", "S050_C1000_E5",
  "S010_C100_E0", "S010_C1000_E0", "S010_C100_E5", "S010_C1000_E5",
  "S090_C100_E0", "S090_C1000_E0", "S090_C100_E5", "S090_C1000_E5"
)
v07_oracle_columns <- c(
  "phase",
  "cell_id",
  "seed",
  "role",
  "arm_id",
  "cap",
  "em_warmup",
  "start_id",
  "start_sigma_g2",
  "start_sigma_e2",
  "converged",
  "termination_reason",
  "iterations",
  "em_steps",
  "factorizations",
  "step_halvings",
  "estimate_sigma_g2",
  "estimate_sigma_e2",
  "estimate_ratio",
  "julia_objective",
  "ai_score_norm",
  "julia_fd_log_gradient_norm",
  "last_relative_change",
  "smallest_component",
  "runtime_seconds",
  "peak_rss_mb",
  "error_class",
  "marker_hash",
  "id_hash",
  "kernel_hash",
  "oracle_class",
  "oracle_ratio",
  "oracle_sigma_g2",
  "oracle_sigma_e2",
  "oracle_arm_loglik",
  "oracle_loglik",
  "objective_gap_per_observation",
  "oracle_fd_log_gradient_norm",
  "lower_derivative_per_observation",
  "upper_derivative_per_observation",
  "interior_agreement",
  "dataset_files_digest"
)

# Frozen doc-47 holdout exchange.  This is deliberately separate from the
# doc-45 localization exchange above: the holdout packet contains exactly the
# unchanged AI fit and the sealed boundary-aware candidate, not optimizer arms.
v07_holdout_schema <- "v07-genomic-boundary-holdout-v2"
v07_holdout_candidate_id <- "doc47_boundary_performance_v1"
v07_holdout_epsilon <- 1e-7
v07_holdout_inverse_tolerance <- 1e-10
v07_holdout_doc46 <- c(
  commit = "fe96a147be23d74c5331eb37cd8b681ecce77be6",
  sha256 = "283ab00bab3da925f0ac2916959efacaa7fb711c5da4dce09dd49ea568eef030"
)
v07_holdout_doc47 <- c(
  commit = "13eb97c3dfd49b461db04b7b9cc10587c99a5a73",
  sha256 = "400fbae28806443a6962545caf95587178f35ad0e91dd2b562cf88ea61a9b264"
)
v07_holdout_julia_implementation_commit <-
  "fc9d39df650b20aa09d769d9f9528eed1b606f1e"
v07_holdout_reference_commit <- "ecc058f380be71058c9cfde373c345ab7a2f6aba"
v07_holdout_relationship <- c(
  source = "markers",
  method = "vanraden1",
  allele_frequency_source = "sample",
  ridge = "0.01",
  scale = "K_lambda"
)
v07_holdout_files <- c(
  "K.tsv", "Q.tsv", "X.tsv", "fits.tsv", "ids.tsv", "metadata.tsv", "y.tsv"
)
v07_holdout_metadata_keys <- c(
  "schema_version", "candidate_id", "cell_id", "seed", "n", "p", "m",
  "ridge", "marker_hash", "id_hash", "kernel_hash", "precision_hash",
  "relationship_source", "relationship_method", "allele_frequency_source",
  "relationship_scale", "doc46_commit", "doc46_sha256", "doc47_commit",
  "doc47_sha256", "julia_boundary_impl_commit", "r_boundary_impl_commit",
  "discovery_digest", "discovery_equivalence_sha256", "discovery_timing_sha256",
  "discovery_selection_sha256", "candidate_seal_sha256",
  "holdout_manifest_sha256", "execution_commit", "driver_sha256", "r_oracle_sha256"
)
v07_holdout_fit_columns <- c(
  "cell_id", "seed", "route", "timed_order", "converged", "termination_reason",
  "optimizer_status",
  "iterations", "sigma_g2", "sigma_e2", "numerical_ratio", "profile_ratio",
  "profile_t_hat", "boundary_status", "boundary_epsilon", "profile_loglik",
  "lower_derivative_per_observation", "upper_derivative_per_observation",
  "objective", "ai_score_norm", "fd_log_gradient_norm", "runtime_seconds",
  "marker_hash", "id_hash", "kernel_hash", "precision_hash",
  "relationship_source", "relationship_method", "allele_frequency_source",
  "ridge", "relationship_scale", "result_digest", "error_class"
)
v07_holdout_result_fields <- c(
  "digest_version", "status", "reason", "converged", "termination",
  "profile_ratio", "numerical_ratio", "t_hat", "profile_loglik", "d0", "d1",
  "sigma_g2", "sigma_e2", "marker_hash", "id_hash", "kernel_hash",
  "precision_hash", "relationship_source", "relationship_method",
  "allele_frequency_source", "ridge", "relationship_scale"
)
v07_holdout_seal_keys <- strsplit(
  paste(
    "schema_version candidate_id doc46_commit doc46_sha256 doc47_commit doc47_sha256",
    "reference_commit julia_boundary_impl_commit r_boundary_impl_commit r_execution_commit",
    "localization_driver_sha256 performance_driver_sha256 boundary_driver_sha256",
    "launcher_sha256 genomic_source_sha256 r_oracle_sha256 exchange_schema",
    "exchange_schema_sha256 profiler_schema",
    "profiler_candidate_id packet_file_set provenance_domain_hex provenance_encoding",
    "result_digest_encoding id_hash_kind kernel_hash_kind precision_hash_kind",
    "qk_identity_tolerance relationship_source relationship_method allele_frequency_source",
    "ridge relationship_scale boundary_epsilon grid_step refinement_abs_tol",
    "likelihood_tie_per_observation derivative_delta kkt_tolerance_per_observation",
    "holdout_seed_formula timing_protocol holdout_p95_rule holdout_runtime_ratio_limit",
    "discovery_runtime_ratio_limit discovery_reference_ratio_limit holdout_manifest_sha256",
    "discovery_manifest_sha256 discovery_admission_sha256 discovery_environment_sha256",
    "discovery_admission_lock_sha256 discovery_raw_locks_sha256 discovery_equivalence_sha256",
    "discovery_timing_sha256 discovery_selection_sha256 discovery_summary_lock_sha256",
    "discovery_digest discovery_candidate_commit candidate_implementation_commit",
    "julia_driver_commit execution_commit host cpu_model machine kernel arch julia_version",
    "r_version project_sha256 manifest_sha256 julia_num_threads openblas_num_threads",
    "omp_num_threads veclib_maximum_threads holdout_absent_before_seal spent_offset_block_excluded"
  ),
  " ", fixed = TRUE
)[[1L]]
v07_holdout_oracle_columns <- c(
  "cell_id", "seed", "packet_files_lock_sha256", "candidate_seal_sha256",
  "candidate_id", "doc46_commit", "doc46_sha256", "doc47_commit", "doc47_sha256",
  "julia_boundary_impl_commit", "r_boundary_impl_commit", "r_oracle_sha256",
  "marker_hash", "id_hash", "kernel_hash", "precision_hash",
  "default_result_digest", "candidate_result_digest",
  "oracle_class", "oracle_profile_ratio", "oracle_t_hat",
  "oracle_profile_loglik", "oracle_lower_derivative_per_observation",
  "oracle_upper_derivative_per_observation", "oracle_sigma_g2_numerical",
  "oracle_sigma_e2_numerical"
)

v07_stop <- function(...) stop(..., call. = FALSE)

v07_assert_names <- function(x, expected, label) {
  if (!identical(names(x), expected)) {
    v07_stop(
      label,
      " schema mismatch; expected: ",
      paste(expected, collapse = ",")
    )
  }
  invisible(TRUE)
}

v07_sha256_file <- function(path) {
  if (!file.exists(path) || file.info(path)$isdir) {
    v07_stop("cannot hash missing regular file: ", path)
  }
  if (nzchar(Sys.which("shasum"))) {
    out <- system2(
      "shasum",
      c("-a", "256", shQuote(path)),
      stdout = TRUE,
      stderr = TRUE
    )
  } else if (nzchar(Sys.which("sha256sum"))) {
    out <- system2("sha256sum", shQuote(path), stdout = TRUE, stderr = TRUE)
  } else {
    v07_stop("neither shasum nor sha256sum is available")
  }
  status <- attr(out, "status")
  if (!is.null(status) && status != 0L) {
    v07_stop("SHA-256 command failed for: ", path)
  }
  hash <- strsplit(out[[1L]], "[[:space:]]+")[[1L]][[1L]]
  if (!grepl("^[0-9a-f]{64}$", hash)) {
    v07_stop("invalid SHA-256 output for: ", path)
  }
  hash
}

v07_sha256_raw <- function(value) {
  path <- tempfile("v07-sha256-")
  on.exit(unlink(path), add = TRUE)
  connection <- file(path, open = "wb")
  on.exit(try(close(connection), silent = TRUE), add = TRUE)
  writeBin(value, connection)
  close(connection)
  v07_sha256_file(path)
}

v07_holdout_exchange_schema_preimage <- function() {
  lines <- c(
    paste0("schema_version=", v07_holdout_schema),
    paste0("candidate_id=", v07_holdout_candidate_id),
    paste0("holdout_columns=", paste(c("cell_id", "seed", "n", "m", "ridge"),
      collapse = ",")),
    paste0("fit_columns=", paste(v07_holdout_fit_columns, collapse = ",")),
    paste0("result_fields=", paste(v07_holdout_result_fields, collapse = ",")),
    paste0("metadata_keys=", paste(v07_holdout_metadata_keys, collapse = ",")),
    paste0("packet_files=", paste(v07_holdout_files, collapse = ",")),
    paste0("oracle_columns=", paste(v07_holdout_oracle_columns, collapse = ","))
  )
  paste0(paste(lines, collapse = "\n"), "\n")
}

v07_holdout_exchange_schema_sha256 <- function() {
  v07_sha256_raw(charToRaw(enc2utf8(v07_holdout_exchange_schema_preimage())))
}

v07_u64_raw <- function(value) {
  if (length(value) != 1L || !is.finite(value) || value < 0 ||
      value != floor(value) || value > 2^53) {
    v07_stop("cannot canonically encode a non-UInt64-sized value")
  }
  out <- raw(8L)
  for (index in seq_len(8L)) {
    out[[index]] <- as.raw(value %% 256)
    value <- floor(value / 256)
  }
  out
}

v07_string_raw <- function(value) {
  if (length(value) != 1L || is.na(value)) {
    v07_stop("cannot canonically encode a missing or non-scalar string")
  }
  bytes <- charToRaw(enc2utf8(as.character(value)))
  c(v07_u64_raw(length(bytes)), bytes)
}

v07_strings_raw <- function(values) {
  values <- as.character(values)
  if (anyNA(values)) v07_stop("cannot canonically encode missing strings")
  c(v07_u64_raw(length(values)), unlist(lapply(values, v07_string_raw), use.names = FALSE))
}

v07_float64_raw <- function(values) {
  values <- as.numeric(values)
  if (any(!is.finite(values))) {
    v07_stop("cannot canonically encode non-finite Float64 values")
  }
  values[values == 0] <- 0
  writeBin(values, raw(), size = 8L, endian = "little")
}

v07_provenance_prefix <- function(kind) {
  c(
    charToRaw("HSquared-provenance-v1"), as.raw(0),
    charToRaw(enc2utf8(kind)), as.raw(0)
  )
}

v07_id_fingerprint <- function(ids) {
  v07_sha256_raw(c(v07_provenance_prefix("id_order"), v07_strings_raw(ids)))
}

v07_matrix_fingerprint <- function(kind, matrix, ids) {
  matrix <- as.matrix(matrix)
  if (nrow(matrix) != ncol(matrix) || length(ids) != nrow(matrix)) {
    v07_stop(kind, " fingerprint dimensions do not match the ID order")
  }
  bytes <- c(
    v07_provenance_prefix(kind),
    v07_u64_raw(nrow(matrix)),
    v07_u64_raw(ncol(matrix)),
    v07_strings_raw(ids),
    v07_strings_raw(ids),
    v07_float64_raw(matrix)
  )
  v07_sha256_raw(bytes)
}

v07_holdout_read_candidate_seal <- function(path, r_repo, oracle_path = v07_oracle_source_path) {
  path <- normalizePath(path, mustWork = TRUE)
  v07_verify_output_sidecar(path)
  seal <- v07_read_tsv(path)
  v07_assert_names(seal, c("key", "value"), "doc47 candidate_seal.tsv")
  if (!identical(as.character(seal$key), v07_holdout_seal_keys) ||
      anyDuplicated(seal$key) || any(!nzchar(seal$key)) ||
      any(!nzchar(seal$value))) {
    v07_stop("doc47 candidate seal key set, order, or value mismatch")
  }
  out <- stats::setNames(seal$value, seal$key)
  expected <- c(
    schema_version = v07_holdout_schema,
    candidate_id = v07_holdout_candidate_id,
    doc46_commit = v07_holdout_doc46[["commit"]],
    doc46_sha256 = v07_holdout_doc46[["sha256"]],
    doc47_commit = v07_holdout_doc47[["commit"]],
    doc47_sha256 = v07_holdout_doc47[["sha256"]],
    reference_commit = v07_holdout_reference_commit,
    julia_boundary_impl_commit = v07_holdout_julia_implementation_commit,
    exchange_schema = v07_holdout_schema,
    exchange_schema_sha256 = v07_holdout_exchange_schema_sha256(),
    profiler_schema = "v07-genomic-boundary-performance-v2",
    profiler_candidate_id = v07_holdout_candidate_id,
    packet_file_set = paste(v07_holdout_files, collapse = ","),
    provenance_domain_hex = "48537175617265642d70726f76656e616e63652d763100",
    provenance_encoding = "sha256-little-endian-u64-float64-length-framed-utf8-v1",
    result_digest_encoding = "sha256-utf8-field-equals-value-newline-float17g-v1",
    id_hash_kind = "id_order",
    kernel_hash_kind = "K_lambda",
    precision_hash_kind = "Q_lambda",
    qk_identity_tolerance = "1e-10",
    relationship_source = v07_holdout_relationship[["source"]],
    relationship_method = v07_holdout_relationship[["method"]],
    allele_frequency_source = v07_holdout_relationship[["allele_frequency_source"]],
    ridge = v07_holdout_relationship[["ridge"]],
    relationship_scale = v07_holdout_relationship[["scale"]],
    boundary_epsilon = sprintf("%.17g", v07_holdout_epsilon),
    grid_step = sprintf("%.17g", 0.0025),
    refinement_abs_tol = sprintf("%.17g", 1e-12),
    likelihood_tie_per_observation = sprintf("%.17g", 1e-10),
    derivative_delta = sprintf("%.17g", 1e-6),
    kkt_tolerance_per_observation = sprintf("%.17g", 1e-8),
    holdout_seed_formula = "2027120000+10000*cell_index+6001:6048",
    timing_protocol = "fixed_nonholdout_warmup_then_seed_parity_order",
    holdout_p95_rule = "sort(x)[ceil(0.95*48)]",
    holdout_runtime_ratio_limit = "3",
    discovery_runtime_ratio_limit = "2.5",
    discovery_reference_ratio_limit = "1.10",
    discovery_candidate_commit = v07_holdout_julia_implementation_commit,
    candidate_implementation_commit = v07_holdout_julia_implementation_commit,
    holdout_absent_before_seal = "true",
    spent_offset_block_excluded = "5001:5048"
  )
  if (any(!names(expected) %in% names(out)) ||
      !identical(unname(out[names(expected)]), unname(expected))) {
    v07_stop("doc47 candidate seal frozen contract mismatch")
  }
  required_hashes <- c(
    grep("_sha256$", names(out), value = TRUE),
    "discovery_digest"
  )
  required_commits <- c(
    "reference_commit", "julia_boundary_impl_commit", "r_boundary_impl_commit",
    "r_execution_commit", "discovery_candidate_commit",
    "candidate_implementation_commit", "execution_commit", "julia_driver_commit"
  )
  if (any(!grepl("^[0-9a-f]{64}$", out[required_hashes])) ||
      any(!grepl("^[0-9a-f]{40}$", out[required_commits])) ||
      !identical(out[["r_execution_commit"]], out[["r_boundary_impl_commit"]]) ||
      !identical(out[["julia_driver_commit"]], out[["execution_commit"]])) {
    v07_stop("doc47 candidate seal hash or commit binding is invalid")
  }
  r_repo <- normalizePath(r_repo, mustWork = TRUE)
  oracle_path <- normalizePath(oracle_path, mustWork = TRUE)
  if (!startsWith(oracle_path, paste0(r_repo, .Platform$file.sep))) {
    v07_stop("doc47 oracle is outside the frozen R repository")
  }
  git <- function(...) {
    value <- system2("git", c("-C", shQuote(r_repo), ...), stdout = TRUE, stderr = TRUE)
    status <- attr(value, "status")
    if (!is.null(status) && status != 0L) v07_stop("cannot inspect frozen R repository")
    value
  }
  if (length(git("status", "--porcelain", "--untracked-files=all"))) {
    v07_stop("doc47 R repository is not clean")
  }
  head <- git("rev-parse", "HEAD")[[1L]]
  if (!identical(head, out[["r_boundary_impl_commit"]])) {
    v07_stop("doc47 R implementation commit does not match the candidate seal")
  }
  relative <- substring(oracle_path, nchar(r_repo) + 2L)
  git("ls-files", "--error-unmatch", shQuote(relative))
  if (!identical(v07_sha256_file(oracle_path), out[["r_oracle_sha256"]])) {
    v07_stop("doc47 oracle SHA-256 does not match the candidate seal")
  }
  list(values = out, digest = v07_sha256_file(path), path = path)
}

v07_read_tsv <- function(path) {
  if (!file.exists(path)) {
    v07_stop("missing exchange file: ", path)
  }
  out <- tryCatch(
    utils::read.delim(
      path,
      header = TRUE,
      sep = "\t",
      quote = "",
      check.names = FALSE,
      stringsAsFactors = FALSE,
      comment.char = ""
    ),
    error = function(e) {
      v07_stop("cannot read ", path, ": ", conditionMessage(e))
    }
  )
  lines <- readLines(path, warn = FALSE)
  if (!length(lines) || !identical(lines[[1L]], paste(names(out), collapse = "\t"))) {
    v07_stop("noncanonical TSV header in: ", path)
  }
  tokens <- if (nrow(out)) {
    rows <- strsplit(lines[-1L], "\t", fixed = TRUE)
    if (length(rows) != nrow(out) || any(lengths(rows) != ncol(out))) {
      v07_stop("noncanonical TSV row width in: ", path)
    }
    matrix(unlist(rows, use.names = FALSE), nrow = nrow(out), byrow = TRUE)
  } else {
    matrix(character(), nrow = 0L, ncol = ncol(out))
  }
  attr(out, "v07_tokens") <- tokens
  out
}

v07_verify_seal <- function(dataset_dir) {
  lock_path <- file.path(dataset_dir, "files.sha256.tsv")
  lock <- v07_read_tsv(lock_path)
  v07_assert_names(lock, c("relative_path", "sha256"), "files.sha256.tsv")
  if (nrow(lock) != length(v07_sealed_files) || anyDuplicated(lock$relative_path)) {
    v07_stop("files.sha256.tsv must contain each sealed file exactly once")
  }
  if (!identical(lock$relative_path, v07_sealed_files)) {
    v07_stop("sealed file set or order mismatch")
  }
  actual_files <- sort(basename(list.files(dataset_dir, full.names = TRUE)))
  expected_files <- sort(c(v07_sealed_files, "files.sha256.tsv"))
  if (!identical(actual_files, expected_files)) {
    v07_stop("dataset file set mismatch")
  }
  if (!all(grepl("^[0-9a-f]{64}$", lock$sha256))) {
    v07_stop("files.sha256.tsv contains an invalid SHA-256")
  }
  actual <- vapply(
    v07_sealed_files,
    function(x) v07_sha256_file(file.path(dataset_dir, x)),
    character(1L)
  )
  if (!identical(unname(actual), lock$sha256)) {
    v07_stop("sealed file hash mismatch")
  }
  list(lock = lock, digest = v07_sha256_file(lock_path))
}

v07_read_metadata <- function(path) {
  x <- v07_read_tsv(path)
  v07_assert_names(x, c("key", "value"), "metadata.tsv")
  if (
    nrow(x) != length(v07_metadata_keys) ||
      anyDuplicated(x$key) ||
      !identical(x$key, v07_metadata_keys)
  ) {
    v07_stop("metadata.tsv key set or order mismatch")
  }
  if (any(!nzchar(x$value))) {
    v07_stop("metadata.tsv contains an empty value")
  }
  out <- stats::setNames(x$value, x$key)
  if (!identical(out[["schema_version"]], v07_exchange_schema)) {
    v07_stop("unsupported exchange schema version")
  }
  for (key in c(
    "marker_hash",
    "id_hash",
    "kernel_hash",
    "doc45_sha256",
    "doc45a_sha256",
    "doc45b_sha256"
  )) {
    if (!grepl("^[0-9a-f]{64}$", out[[key]])) {
      v07_stop("invalid SHA-256 metadata: ", key)
    }
  }
  for (key in c(
    "doc45_commit",
    "doc45a_commit",
    "doc45b_commit",
    "execution_commit"
  )) {
    if (!grepl("^[0-9a-f]{40}$", out[[key]])) {
      v07_stop("invalid git commit metadata: ", key)
    }
  }
  if (
    !identical(
      unname(out[names(v07_frozen_documents)]),
      unname(v07_frozen_documents)
    )
  ) {
    v07_stop("metadata does not bind the frozen doc45/doc45a/doc45b identities")
  }
  numeric_values <- suppressWarnings(as.numeric(out[c(
    "seed",
    "n",
    "p",
    "m",
    "ridge"
  )]))
  if (any(!is.finite(numeric_values))) {
    v07_stop("non-finite numeric metadata")
  }
  if (
    numeric_values[[2L]] < 2 ||
      numeric_values[[3L]] < 1 ||
      numeric_values[[3L]] >= numeric_values[[2L]] ||
      numeric_values[[4L]] < 1 ||
      numeric_values[[5L]] != 0.01
  ) {
    v07_stop("invalid or unfrozen n/p/ridge metadata")
  }
  out
}

v07_numeric_matrix <- function(x, label) {
  if (!ncol(x) || !nrow(x)) {
    v07_stop(label, " is empty")
  }
  values <- suppressWarnings(as.matrix(data.frame(
    lapply(x, as.numeric),
    check.names = FALSE
  )))
  storage.mode(values) <- "double"
  if (any(!is.finite(values))) {
    v07_stop(label, " contains non-finite or nonnumeric values")
  }
  values
}

v07_validate_arms <- function(arms, metadata) {
  v07_assert_names(arms, v07_arm_columns, "arms.tsv")
  if (!nrow(arms)) {
    v07_stop("arms.tsv is empty")
  }
  identity_fields <- c(
    "phase",
    "cell_id",
    "seed",
    "role",
    "marker_hash",
    "id_hash",
    "kernel_hash"
  )
  for (field in identity_fields) {
    if (any(as.character(arms[[field]]) != metadata[[field]])) {
      v07_stop("arms.tsv/metadata mismatch in ", field)
    }
  }
  if (
    anyDuplicated(arms$arm_id) ||
      anyDuplicated(arms[c("cap", "em_warmup", "start_id")])
  ) {
    v07_stop("arms.tsv contains a duplicate atomic arm")
  }
  phase <- metadata[["phase"]]
  if (identical(phase, "discovery")) {
    if (!identical(as.character(arms$arm_id), v07_atomic_arm_ids)) {
      v07_stop("discovery arms.tsv arm set or frozen order mismatch")
    }
  } else if (identical(phase, "holdout")) {
    indices <- match(as.character(arms$arm_id), v07_atomic_arm_ids)
    if (anyNA(indices) || arms$arm_id[[1L]] != "C100_E0" ||
        any(diff(indices) <= 0)) {
      v07_stop("holdout arms.tsv arm set or frozen order mismatch")
    }
  } else {
    v07_stop("unsupported phase in arms.tsv")
  }
  numeric_fields <- c(
    "cap",
    "em_warmup",
    "start_sigma_g2",
    "start_sigma_e2",
    "iterations",
    "em_steps",
    "factorizations",
    "step_halvings",
    "estimate_sigma_g2",
    "estimate_sigma_e2",
    "estimate_ratio",
    "julia_objective",
    "ai_score_norm",
    "julia_fd_log_gradient_norm",
    "last_relative_change",
    "smallest_component",
    "runtime_seconds",
    "peak_rss_mb"
  )
  for (field in numeric_fields) {
    value <- suppressWarnings(as.numeric(arms[[field]]))
    arms[[field]] <- value
  }
  always_finite <- c(
    "cap",
    "em_warmup",
    "start_sigma_g2",
    "start_sigma_e2",
    "iterations",
    "em_steps",
    "factorizations",
    "step_halvings",
    "runtime_seconds",
    "peak_rss_mb"
  )
  for (field in always_finite) {
    if (any(!is.finite(arms[[field]]))) {
      v07_stop("arms.tsv has non-finite required field: ", field)
    }
  }
  integer_fields <- c(
    "cap",
    "em_warmup",
    "iterations",
    "em_steps",
    "factorizations",
    "step_halvings"
  )
  if (
    any(vapply(arms[setdiff(integer_fields, "iterations")],
      function(x) any(x < 0 | x != floor(x)), logical(1L))) ||
      any(arms$iterations != floor(arms$iterations)) ||
      any(arms$iterations < -1)
  ) {
    v07_stop("arms.tsv contains an invalid counter")
  }
  if (
    any(!arms$cap %in% c(100, 1000)) ||
      any(!arms$em_warmup %in% c(0, 5)) ||
      any(arms$start_sigma_g2 <= 0 | arms$start_sigma_e2 <= 0) ||
      any(arms$estimate_sigma_g2[is.finite(arms$estimate_sigma_g2)] < 0) ||
      any(arms$estimate_sigma_e2[is.finite(arms$estimate_sigma_e2)] < 0) ||
      any(arms$estimate_ratio[is.finite(arms$estimate_ratio)] < 0 |
          arms$estimate_ratio[is.finite(arms$estimate_ratio)] > 1) ||
      any(arms$smallest_component[is.finite(arms$smallest_component)] < 0) ||
      any(arms$runtime_seconds < 0 | arms$peak_rss_mb < 0)
  ) {
    v07_stop("arms.tsv contains a value outside the frozen domain")
  }
  logical_value <- tolower(as.character(arms$converged))
  if (any(!logical_value %in% c("true", "false"))) {
    v07_stop("arms.tsv converged must contain only TRUE or FALSE")
  }
  arms$converged <- logical_value == "true"
  success <- arms$converged & arms$error_class == "none"
  if (any(arms$converged != (arms$error_class == "none"))) {
    v07_stop("arms.tsv convergence/error_class inconsistency")
  }
  success_finite <- c(
    "estimate_sigma_g2",
    "estimate_sigma_e2",
    "estimate_ratio",
    "julia_objective",
    "ai_score_norm",
    "julia_fd_log_gradient_norm",
    "smallest_component"
  )
  if (any(success) && any(vapply(
    arms[success_finite],
    function(x) any(!is.finite(x[success])),
    logical(1L)
  ))) {
    v07_stop("successful arm contains a non-finite required diagnostic")
  }
  failed <- !success
  if (any(failed)) {
    if (any(arms$termination_reason[failed] %in% c("", "converged")) ||
        any(arms$error_class[failed] == "none")) {
      v07_stop("failed arm lacks a fail-closed termination/error class")
    }
    prefit <- arms$termination_reason == "exception"
    if (any(arms$iterations == -1 & !prefit) ||
        any(prefit & arms$iterations != -1)) {
      v07_stop("iterations=-1 is reserved for pre-fit exceptions")
    }
  }
  character_fields <- setdiff(
    names(arms),
    c(numeric_fields, "converged", "seed")
  )
  if (
    any(vapply(
      arms[character_fields],
      function(x) any(!nzchar(as.character(x))),
      logical(1L)
    ))
  ) {
    v07_stop("arms.tsv contains an empty character field")
  }
  arms
}

v07_read_exchange <- function(dataset_dir) {
  dataset_dir <- normalizePath(dataset_dir, mustWork = TRUE)
  seal <- v07_verify_seal(dataset_dir)
  metadata <- v07_read_metadata(file.path(dataset_dir, "metadata.tsv"))
  y_frame <- v07_read_tsv(file.path(dataset_dir, "y.tsv"))
  v07_assert_names(y_frame, c("row", "y"), "y.tsv")
  if (!identical(as.integer(y_frame$row), seq_len(nrow(y_frame)))) {
    v07_stop("y.tsv row index drift")
  }
  y <- as.numeric(y_frame$y)
  if (any(!is.finite(y))) {
    v07_stop("y.tsv contains non-finite or nonnumeric values")
  }
  X_frame <- v07_read_tsv(file.path(dataset_dir, "X.tsv"))
  K_frame <- v07_read_tsv(file.path(dataset_dir, "K.tsv"))
  if (!identical(as.integer(X_frame$row), seq_len(nrow(X_frame))) ||
      !identical(as.integer(K_frame$row), seq_len(nrow(K_frame)))) {
    v07_stop("X.tsv or K.tsv row index drift")
  }
  X <- v07_numeric_matrix(X_frame[-1L], "X.tsv")
  K <- v07_numeric_matrix(K_frame[-1L], "K.tsv")
  n <- as.integer(metadata[["n"]])
  p <- as.integer(metadata[["p"]])
  if (
    !identical(colnames(X), paste0("x", seq_len(p))) ||
      !identical(colnames(K), paste0("k", seq_len(n)))
  ) {
    v07_stop("X.tsv or K.tsv column schema mismatch")
  }
  if (
    length(y) != n ||
      nrow(X) != n ||
      ncol(X) != p ||
      nrow(K) != n ||
      ncol(K) != n
  ) {
    v07_stop("y/X/K dimensions disagree with metadata")
  }
  if (qr(X)$rank != p) {
    v07_stop("X.tsv is not full column rank")
  }
  if (max(abs(K - t(K))) > 1e-12) {
    v07_stop("K.tsv is not symmetric to 1e-12")
  }
  tryCatch(chol(K), error = function(e) {
    v07_stop("K.tsv is not positive definite")
  })
  arms_raw <- v07_read_tsv(file.path(dataset_dir, "arms.tsv"))
  arm_tokens <- attr(arms_raw, "v07_tokens")
  arms <- v07_validate_arms(arms_raw, metadata)
  list(
    y = y,
    X = X,
    K = K,
    metadata = metadata,
    arms = arms,
    arm_tokens = arm_tokens,
    seal = seal
  )
}

v07_reml_parts <- function(V, y, X) {
  n <- length(y)
  p <- ncol(X)
  R <- tryCatch(chol(V), error = function(e) NULL)
  if (is.null(R)) {
    return(NULL)
  }
  logdet_v <- 2 * sum(log(diag(R)))
  vi_x <- backsolve(R, forwardsolve(t(R), X))
  vi_y <- drop(backsolve(R, forwardsolve(t(R), y)))
  xt_vi_x <- crossprod(X, vi_x)
  RX <- tryCatch(chol(xt_vi_x), error = function(e) NULL)
  if (is.null(RX)) {
    return(NULL)
  }
  rhs <- drop(crossprod(X, vi_y))
  beta_part <- drop(crossprod(rhs, backsolve(RX, forwardsolve(t(RX), rhs))))
  quad <- drop(crossprod(y, vi_y)) - beta_part
  if (!is.finite(quad) || quad <= 0) {
    return(NULL)
  }
  list(
    quad = quad,
    logdet_v = logdet_v,
    logdet_xt_vi_x = 2 * sum(log(diag(RX))),
    df = n - p
  )
}

v07_profile_loglik <- function(r, y, X, K) {
  if (length(r) != 1L || !is.finite(r) || r < 0 || r > 1) {
    return(-Inf)
  }
  H <- r * K + (1 - r) * diag(length(y))
  z <- v07_reml_parts(H, y, X)
  if (is.null(z)) {
    return(-Inf)
  }
  t_hat <- z$quad / z$df
  value <- -0.5 *
    (z$df * (1 + log(2 * pi * t_hat)) + z$logdet_v + z$logdet_xt_vi_x)
  if (is.finite(value)) value else -Inf
}

v07_component_loglik <- function(sigma_g2, sigma_e2, y, X, K) {
  if (
    length(sigma_g2) != 1L ||
      length(sigma_e2) != 1L ||
      !is.finite(sigma_g2) ||
      !is.finite(sigma_e2) ||
      sigma_g2 <= 0 ||
      sigma_e2 <= 0
  ) {
    return(-Inf)
  }
  z <- v07_reml_parts(sigma_g2 * K + sigma_e2 * diag(length(y)), y, X)
  if (is.null(z)) {
    return(-Inf)
  }
  value <- -0.5 * (z$df * log(2 * pi) + z$logdet_v + z$logdet_xt_vi_x + z$quad)
  if (is.finite(value)) value else -Inf
}

v07_fd_log_gradient <- function(sigma_g2, sigma_e2, y, X, K, h = 1e-5) {
  eta <- log(c(sigma_g2, sigma_e2))
  gradient <- numeric(2L)
  for (j in seq_len(2L)) {
    plus <- eta
    minus <- eta
    plus[[j]] <- plus[[j]] + h
    minus[[j]] <- minus[[j]] - h
    lp <- v07_component_loglik(exp(plus[[1L]]), exp(plus[[2L]]), y, X, K)
    lm <- v07_component_loglik(exp(minus[[1L]]), exp(minus[[2L]]), y, X, K)
    if (!is.finite(lp) || !is.finite(lm)) {
      return(Inf)
    }
    gradient[[j]] <- (lp - lm) / (2 * h)
  }
  sqrt(sum(gradient^2)) / length(y)
}

v07_is_distinct_interior <- function(r) {
  is.finite(r) && r > v07_endpoint_adjacency && r < 1 - v07_endpoint_adjacency
}

v07_classify_oracle <- function(y, X, K, reverse_kkt = FALSE) {
  n <- length(y)
  grid <- seq(0, 1, by = 0.0025)
  values <- vapply(
    grid,
    function(r) v07_profile_loglik(r, y = y, X = X, K = K),
    numeric(1L)
  )
  if (any(!is.finite(values))) {
    v07_stop("oracle grid contains a non-finite likelihood")
  }
  best_interior <- which.max(values[2:(length(grid) - 1L)]) + 1L
  interval <- grid[c(best_interior - 1L, best_interior + 1L)]
  refined <- stats::optimize(
    v07_profile_loglik,
    interval = interval,
    maximum = TRUE,
    tol = 1e-12,
    y = y,
    X = X,
    K = K
  )
  refined_is_distinct <- v07_is_distinct_interior(refined$maximum)
  interior_r <- if (refined_is_distinct) {
    refined$maximum
  } else {
    grid[[best_interior]]
  }
  interior_ll <- if (refined_is_distinct) {
    refined$objective
  } else {
    values[[best_interior]]
  }
  candidates_ll <- c(
    lower = values[[1L]],
    interior = interior_ll,
    upper = values[[length(values)]]
  )
  if (
    any(!is.finite(candidates_ll)) ||
      refined$objective + n * 1e-10 < values[[best_interior]]
  ) {
    return(list(
      class = "oracle_unresolved",
      ratio = NA_real_,
      sigma_g2 = NA_real_,
      sigma_e2 = NA_real_,
      loglik = max(candidates_ll),
      d0_per_observation = NA_real_,
      d1_per_observation = NA_real_,
      grid_ratio = grid[[which.max(values)]]
    ))
  }
  delta <- 1e-6
  d0 <- (v07_profile_loglik(delta, y, X, K) - candidates_ll[["lower"]]) /
    delta /
    n
  d1 <- (candidates_ll[["upper"]] - v07_profile_loglik(1 - delta, y, X, K)) /
    delta /
    n
  if (reverse_kkt) {
    lower_kkt <- d0 >= -1e-8
    upper_kkt <- d1 <= 1e-8
  } else {
    lower_kkt <- d0 <= 1e-8
    upper_kkt <- d1 >= -1e-8
  }
  tie_tol <- n * 1e-10
  best <- which.max(candidates_ll)
  endpoint_pair_tie <- abs(
    candidates_ll[["lower"]] - candidates_ll[["upper"]]
  ) <=
    tie_tol &&
    max(candidates_ll[c("lower", "upper")]) + tie_tol >=
      candidates_ll[["interior"]]
  lower_interior_tie <- refined_is_distinct &&
    abs(candidates_ll[["lower"]] - candidates_ll[["interior"]]) <= tie_tol
  upper_interior_tie <- refined_is_distinct &&
    abs(candidates_ll[["upper"]] - candidates_ll[["interior"]]) <= tie_tol
  class <- "oracle_unresolved"
  if (
    !endpoint_pair_tie && !lower_interior_tie &&
      candidates_ll[["lower"]] + tie_tol >=
        max(candidates_ll[c("interior", "upper")]) &&
      lower_kkt
  ) {
    class <- "lower_boundary"
    ratio <- 0
  } else if (
    !endpoint_pair_tie && !upper_interior_tie &&
      candidates_ll[["upper"]] + tie_tol >=
        max(candidates_ll[c("lower", "interior")]) &&
      upper_kkt
  ) {
    class <- "upper_boundary"
    ratio <- 1
  } else if (
    refined_is_distinct &&
      candidates_ll[["interior"]] - max(candidates_ll[c("lower", "upper")]) >
        tie_tol &&
      !lower_kkt &&
      !upper_kkt
  ) {
    class <- "interior_oracle"
    ratio <- interior_r
  } else {
    return(list(
      class = class,
      ratio = NA_real_,
      sigma_g2 = NA_real_,
      sigma_e2 = NA_real_,
      loglik = max(candidates_ll),
      d0_per_observation = d0,
      d1_per_observation = d1,
      grid_ratio = grid[[which.max(values)]]
    ))
  }
  H <- ratio * K + (1 - ratio) * diag(n)
  parts <- v07_reml_parts(H, y, X)
  t_hat <- parts$quad / parts$df
  list(
    class = class,
    ratio = ratio,
    sigma_g2 = ratio * t_hat,
    sigma_e2 = (1 - ratio) * t_hat,
    loglik = v07_profile_loglik(ratio, y, X, K),
    d0_per_observation = d0,
    d1_per_observation = d1,
    grid_ratio = grid[[which.max(values)]]
  )
}

v07_build_oracle_rows <- function(exchange) {
  oracle <- v07_classify_oracle(exchange$y, exchange$X, exchange$K)
  arms <- exchange$arms
  out <- arms
  out$oracle_class <- oracle$class
  out$oracle_ratio <- oracle$ratio
  out$oracle_sigma_g2 <- oracle$sigma_g2
  out$oracle_sigma_e2 <- oracle$sigma_e2
  out$oracle_arm_loglik <- mapply(
    v07_component_loglik,
    arms$estimate_sigma_g2,
    arms$estimate_sigma_e2,
    MoreArgs = list(y = exchange$y, X = exchange$X, K = exchange$K)
  )
  out$oracle_loglik <- oracle$loglik
  out$objective_gap_per_observation <- abs(
    out$oracle_arm_loglik - oracle$loglik
  ) /
    length(exchange$y)
  out$oracle_fd_log_gradient_norm <- mapply(
    v07_fd_log_gradient,
    arms$estimate_sigma_g2,
    arms$estimate_sigma_e2,
    MoreArgs = list(y = exchange$y, X = exchange$X, K = exchange$K)
  )
  out$lower_derivative_per_observation <- oracle$d0_per_observation
  out$upper_derivative_per_observation <- oracle$d1_per_observation
  ratio_ok <- abs(arms$estimate_ratio - oracle$ratio) <=
    1e-8 + 1e-5 * abs(oracle$ratio)
  sg_ok <- abs(arms$estimate_sigma_g2 - oracle$sigma_g2) <=
    1e-8 + 1e-5 * abs(oracle$sigma_g2)
  se_ok <- abs(arms$estimate_sigma_e2 - oracle$sigma_e2) <=
    1e-8 + 1e-5 * abs(oracle$sigma_e2)
  out$interior_agreement <- oracle$class == "interior_oracle" &
    arms$converged &
    arms$estimate_sigma_g2 > 0 &
    arms$estimate_sigma_e2 > 0 &
    ratio_ok &
    sg_ok &
    se_ok &
    out$objective_gap_per_observation <= 1e-8 &
    out$oracle_fd_log_gradient_norm <= 1e-8
  out$dataset_files_digest <- exchange$seal$digest
  out <- out[v07_oracle_columns]
  attr(out, "v07_raw_tokens") <- exchange$arm_tokens
  v07_assert_names(out, v07_oracle_columns, "oracle output")
  failed <- !arms$converged
  always_finite <- c(
    "oracle_loglik",
    "lower_derivative_per_observation",
    "upper_derivative_per_observation"
  )
  if (any(vapply(out[always_finite], function(x) any(!is.finite(x)), logical(1L)))) {
    v07_stop("independent oracle produced a non-finite dataset diagnostic")
  }
  arm_diagnostics <- c(
    "oracle_arm_loglik",
    "objective_gap_per_observation",
    "oracle_fd_log_gradient_norm"
  )
  if (any(!failed) && any(vapply(
    out[arm_diagnostics],
    function(x) any(!is.finite(x[!failed])),
    logical(1L)
  ))) {
    v07_stop("independent oracle produced a non-finite successful-arm diagnostic")
  }
  out
}

v07_format_token <- function(x) {
  if (is.logical(x)) {
    return(ifelse(x, "true", "false"))
  }
  if (is.numeric(x)) {
    if (is.nan(x) || is.na(x)) {
      return("NaN")
    }
    if (is.infinite(x)) {
      return(if (x > 0) "Inf" else "-Inf")
    }
    if (x == 0) {
      return("0")
    }
    return(sprintf("%.17g", x))
  }
  as.character(x)
}

v07_write_oracle_table <- function(x, path) {
  raw_tokens <- attr(x, "v07_raw_tokens")
  if (is.null(raw_tokens) ||
      nrow(raw_tokens) != nrow(x) ||
      ncol(raw_tokens) != length(v07_arm_columns)) {
    v07_stop("oracle output is missing the byte-exact raw arm tokens")
  }
  con <- file(path, open = "wb")
  on.exit(close(con), add = TRUE)
  writeLines(paste(v07_oracle_columns, collapse = "\t"), con, sep = "\n")
  for (i in seq_len(nrow(x))) {
    suffix <- vapply(
      x[i, (length(v07_arm_columns) + 1L):length(v07_oracle_columns), drop = FALSE],
      function(value) v07_format_token(value[[1L]]),
      character(1L)
    )
    writeLines(
      paste(c(raw_tokens[i, ], suffix), collapse = "\t"),
      con,
      sep = "\n"
    )
  }
  invisible(path)
}

v07_write_create_once <- function(x, output) {
  sidecar <- paste0(output, ".sha256")
  if (file.exists(output) || file.exists(sidecar)) {
    v07_stop("refusing to overwrite create-once output or sidecar: ", output)
  }
  parent <- dirname(output)
  if (!dir.exists(parent)) {
    dir.create(parent, recursive = TRUE, showWarnings = FALSE)
  }
  if (!dir.exists(parent)) {
    v07_stop("cannot create output directory: ", parent)
  }
  tmp <- tempfile(paste0(".", basename(output), "."), tmpdir = parent)
  on.exit(unlink(tmp), add = TRUE)
  v07_write_oracle_table(x, tmp)
  if (file.exists(output) || !file.rename(tmp, output)) {
    v07_stop("atomic create-once output failed: ", output)
  }
  lock <- data.frame(
    sha256 = v07_sha256_file(output),
    file = basename(output),
    stringsAsFactors = FALSE
  )
  lock_tmp <- tempfile(paste0(".", basename(sidecar), "."), tmpdir = parent)
  on.exit(unlink(lock_tmp), add = TRUE)
  utils::write.table(
    lock,
    lock_tmp,
    sep = "\t",
    quote = FALSE,
    row.names = FALSE
  )
  if (file.exists(sidecar) || !file.rename(lock_tmp, sidecar)) {
    unlink(output)
    v07_stop("atomic create-once sidecar failed: ", sidecar)
  }
  invisible(output)
}

v07_verify_output_sidecar <- function(output) {
  sidecar <- paste0(output, ".sha256")
  if (!file.exists(output) || !file.exists(sidecar)) {
    v07_stop("oracle output or create-once sidecar is missing")
  }
  lock <- v07_read_tsv(sidecar)
  v07_assert_names(lock, c("sha256", "file"), "oracle sidecar")
  if (
    nrow(lock) != 1L ||
      lock$file[[1L]] != basename(output) ||
      !grepl("^[0-9a-f]{64}$", lock$sha256[[1L]]) ||
      lock$sha256[[1L]] != v07_sha256_file(output)
  ) {
    v07_stop("oracle output sidecar mismatch")
  }
  invisible(TRUE)
}

v07_compare_output <- function(actual, expected, tolerance = 1e-12) {
  v07_assert_names(actual, v07_oracle_columns, "saved oracle output")
  if (nrow(actual) != nrow(expected)) {
    v07_stop("oracle output row-count mismatch")
  }
  actual_tokens <- attr(actual, "v07_tokens")
  expected_tokens <- attr(expected, "v07_raw_tokens")
  if (!is.null(actual_tokens) && !is.null(expected_tokens) &&
      !identical(
        actual_tokens[, seq_along(v07_arm_columns), drop = FALSE],
        expected_tokens
      )) {
    v07_stop("oracle output changed or reordered byte-exact raw arm fields")
  }
  numeric <- names(expected)[vapply(expected, is.numeric, logical(1L))]
  logical <- names(expected)[vapply(expected, is.logical, logical(1L))]
  character <- setdiff(names(expected), c(numeric, logical))
  undefined_if_unresolved <- c(
    "oracle_ratio",
    "oracle_sigma_g2",
    "oracle_sigma_e2"
  )
  for (field in numeric) {
    actual_value <- actual[[field]]
    expected_value <- expected[[field]]
    allowed_na <- field %in%
      undefined_if_unresolved &
      expected$oracle_class == "oracle_unresolved"
    if (
      any(is.na(actual_value) != is.na(expected_value)) ||
        any(!is.finite(actual_value[!allowed_na])) ||
        any(
          abs(actual_value[!allowed_na] - expected_value[!allowed_na]) >
            tolerance
        )
    ) {
      v07_stop("oracle output numeric mismatch in ", field)
    }
  }
  for (field in logical) {
    value <- tolower(as.character(actual[[field]]))
    if (
      !identical(value == "true", expected[[field]]) ||
        any(!value %in% c("true", "false"))
    ) {
      v07_stop("oracle output logical mismatch in ", field)
    }
  }
  for (field in character) {
    if (
      !identical(as.character(actual[[field]]), as.character(expected[[field]]))
    ) {
      v07_stop("oracle output character mismatch in ", field)
    }
  }
  invisible(TRUE)
}

v07_holdout_verify_seal <- function(dataset_dir) {
  lock_path <- file.path(dataset_dir, "files.sha256.tsv")
  v07_verify_output_sidecar(lock_path)
  lock <- v07_read_tsv(lock_path)
  v07_assert_names(lock, c("relative_path", "sha256"), "files.sha256.tsv")
  if (nrow(lock) != length(v07_holdout_files) || anyDuplicated(lock$relative_path) ||
      !identical(lock$relative_path, v07_holdout_files)) {
    v07_stop("doc47 sealed file set or order mismatch")
  }
  actual_files <- sort(basename(list.files(dataset_dir, full.names = TRUE)))
  expected_files <- sort(c(
    v07_holdout_files, paste0(v07_holdout_files, ".sha256"),
    "files.sha256.tsv", "files.sha256.tsv.sha256"
  ))
  if (!identical(actual_files, expected_files)) {
    v07_stop("doc47 dataset file set mismatch")
  }
  if (!all(grepl("^[0-9a-f]{64}$", lock$sha256))) {
    v07_stop("doc47 file lock contains an invalid SHA-256")
  }
  actual <- vapply(
    v07_holdout_files,
    function(x) {
      path <- file.path(dataset_dir, x)
      v07_verify_output_sidecar(path)
      v07_sha256_file(path)
    },
    character(1L)
  )
  if (!identical(unname(actual), lock$sha256)) {
    v07_stop("doc47 sealed file hash mismatch")
  }
  list(lock = lock, digest = v07_sha256_file(lock_path))
}

v07_holdout_read_metadata <- function(path, candidate_seal) {
  x <- v07_read_tsv(path)
  v07_assert_names(x, c("key", "value"), "doc47 metadata.tsv")
  if (nrow(x) != length(v07_holdout_metadata_keys) || anyDuplicated(x$key) ||
      !identical(x$key, v07_holdout_metadata_keys) || any(!nzchar(x$value))) {
    v07_stop("doc47 metadata key set, order, or value mismatch")
  }
  out <- stats::setNames(x$value, x$key)
  if (!identical(out[["schema_version"]], v07_holdout_schema) ||
      !identical(out[["candidate_id"]], v07_holdout_candidate_id) ||
      !identical(out[["doc46_commit"]], v07_holdout_doc46[["commit"]]) ||
      !identical(out[["doc46_sha256"]], v07_holdout_doc46[["sha256"]]) ||
      !identical(out[["doc47_commit"]], v07_holdout_doc47[["commit"]]) ||
      !identical(out[["doc47_sha256"]], v07_holdout_doc47[["sha256"]]) ||
      !identical(
        out[["julia_boundary_impl_commit"]],
        v07_holdout_julia_implementation_commit
      )) {
    v07_stop("doc47 frozen schema, candidate, document, or Julia identity mismatch")
  }
  sealed_fields <- c(
    "candidate_id", "doc46_commit", "doc46_sha256", "doc47_commit",
    "doc47_sha256", "julia_boundary_impl_commit", "r_boundary_impl_commit",
    "discovery_digest", "discovery_equivalence_sha256", "discovery_timing_sha256",
    "discovery_selection_sha256", "holdout_manifest_sha256", "execution_commit",
    "r_oracle_sha256"
  )
  if (!identical(
    unname(out[sealed_fields]),
    unname(candidate_seal$values[sealed_fields])
  ) ||
      !identical(out[["candidate_seal_sha256"]], candidate_seal$digest) ||
      !identical(out[["driver_sha256"]], candidate_seal$values[["boundary_driver_sha256"]])) {
    v07_stop("doc47 packet metadata does not match the candidate seal")
  }
  if (!identical(out[["relationship_source"]], v07_holdout_relationship[["source"]]) ||
      !identical(out[["relationship_method"]], v07_holdout_relationship[["method"]]) ||
      !identical(
        out[["allele_frequency_source"]],
        v07_holdout_relationship[["allele_frequency_source"]]
      ) ||
      !identical(out[["relationship_scale"]], v07_holdout_relationship[["scale"]]) ||
      !identical(out[["ridge"]], v07_holdout_relationship[["ridge"]])) {
    v07_stop("doc47 frozen genomic construction or scale metadata mismatch")
  }
  hash_keys <- c(
    "marker_hash", "id_hash", "kernel_hash", "precision_hash", "doc46_sha256",
    "doc47_sha256",
    "discovery_digest", "discovery_equivalence_sha256", "discovery_timing_sha256",
    "discovery_selection_sha256", "candidate_seal_sha256",
    "holdout_manifest_sha256", "driver_sha256", "r_oracle_sha256"
  )
  commit_keys <- c(
    "doc46_commit", "doc47_commit", "julia_boundary_impl_commit",
    "r_boundary_impl_commit", "execution_commit"
  )
  invalid_hashes <- hash_keys[!grepl("^[0-9a-f]{64}$", out[hash_keys])]
  invalid_commits <- commit_keys[!grepl("^[0-9a-f]{40}$", out[commit_keys])]
  if (length(invalid_hashes) || length(invalid_commits)) {
    v07_stop(
      "doc47 metadata contains an invalid hash or commit: ",
      paste(c(invalid_hashes, invalid_commits), collapse = ", ")
    )
  }
  numeric <- suppressWarnings(as.numeric(out[c("seed", "n", "p", "m", "ridge")]))
  if (any(!is.finite(numeric)) || numeric[[2L]] < 2 || numeric[[3L]] < 1 ||
      numeric[[3L]] >= numeric[[2L]] || numeric[[4L]] < 1 || numeric[[5L]] != 0.01) {
    v07_stop("doc47 metadata contains invalid n/p/m/ridge values")
  }
  out
}

v07_holdout_canon_float <- function(value) {
  value <- suppressWarnings(as.numeric(value))
  if (length(value) != 1L || !is.finite(value)) "NA" else sprintf("%.17g", value)
}

v07_holdout_result_digest <- function(fit) {
  fit <- as.list(fit)
  route <- as.character(fit[["route"]])
  if (!route %in% c("default_ai", "boundary_candidate")) {
    v07_stop("unknown fit route in scientific-result digest")
  }
  default <- identical(route, "default_ai")
  logical <- tolower(as.character(fit[["converged"]]))
  if (!logical %in% c("true", "false")) {
    v07_stop("fit converged field is invalid in scientific-result digest")
  }
  value <- function(name) v07_holdout_canon_float(fit[[name]])
  record <- c(
    digest_version = if (default) "default_ai_result_v1" else "scientific_result_v1",
    status = if (default) as.character(fit[["optimizer_status"]]) else as.character(fit[["boundary_status"]]),
    reason = as.character(fit[["termination_reason"]]),
    converged = logical,
    termination = as.character(fit[["optimizer_status"]]),
    profile_ratio = value("profile_ratio"),
    numerical_ratio = value("numerical_ratio"),
    t_hat = value("profile_t_hat"),
    profile_loglik = value("profile_loglik"),
    d0 = value("lower_derivative_per_observation"),
    d1 = value("upper_derivative_per_observation"),
    sigma_g2 = value("sigma_g2"),
    sigma_e2 = value("sigma_e2"),
    marker_hash = as.character(fit[["marker_hash"]]),
    id_hash = as.character(fit[["id_hash"]]),
    kernel_hash = as.character(fit[["kernel_hash"]]),
    precision_hash = as.character(fit[["precision_hash"]]),
    relationship_source = as.character(fit[["relationship_source"]]),
    relationship_method = as.character(fit[["relationship_method"]]),
    allele_frequency_source = as.character(fit[["allele_frequency_source"]]),
    ridge = value("ridge"),
    relationship_scale = as.character(fit[["relationship_scale"]])
  )
  if (!identical(names(record), v07_holdout_result_fields) ||
      any(grepl("[\t\r\n]", record))) {
    v07_stop("scientific-result digest preimage is invalid")
  }
  lines <- paste0(names(record), "=", unname(record), "\n", collapse = "")
  v07_sha256_raw(charToRaw(enc2utf8(lines)))
}

v07_holdout_validate_fits <- function(fits, metadata) {
  v07_assert_names(fits, v07_holdout_fit_columns, "doc47 fits.tsv")
  if (nrow(fits) != 2L ||
      !identical(as.character(fits$route), c("default_ai", "boundary_candidate"))) {
    v07_stop("doc47 fits.tsv must contain default_ai then boundary_candidate")
  }
  seed <- suppressWarnings(as.numeric(metadata[["seed"]]))
  expected_order <- if (seed %% 2 == 1) {
    "default_ai>boundary_candidate"
  } else {
    "boundary_candidate>default_ai"
  }
  if (any(as.character(fits$timed_order) != expected_order)) {
    v07_stop("doc47 fits.tsv timing order mismatch")
  }
  for (field in c(
    "cell_id", "seed", "marker_hash", "id_hash", "kernel_hash", "precision_hash",
    "relationship_source", "relationship_method", "allele_frequency_source",
    "ridge", "relationship_scale"
  )) {
    if (any(as.character(fits[[field]]) != metadata[[field]])) {
      v07_stop("doc47 fits.tsv/metadata mismatch in ", field)
    }
  }
  if (any(!grepl("^[0-9a-f]{64}$", fits$result_digest)) ||
      any(vapply(seq_len(nrow(fits)), function(index) {
        !identical(
          v07_holdout_result_digest(fits[index, , drop = FALSE]),
          as.character(fits$result_digest[[index]])
        )
      }, logical(1L)))) {
    v07_stop("doc47 fits.tsv scientific-result digest mismatch")
  }
  logical <- tolower(as.character(fits$converged))
  if (any(!logical %in% c("true", "false"))) {
    v07_stop("doc47 fits.tsv converged must contain TRUE or FALSE")
  }
  fits$converged <- logical == "true"
  numeric_fields <- c(
    "iterations", "sigma_g2", "sigma_e2", "numerical_ratio", "profile_ratio",
    "profile_t_hat", "boundary_epsilon", "profile_loglik",
    "lower_derivative_per_observation", "upper_derivative_per_observation",
    "objective", "ai_score_norm", "fd_log_gradient_norm", "runtime_seconds"
  )
  for (field in numeric_fields) fits[[field]] <- suppressWarnings(as.numeric(fits[[field]]))
  if (any(!is.finite(fits$iterations)) || any(fits$iterations < -1) ||
      any(fits$iterations != floor(fits$iterations)) ||
      any(!is.finite(fits$runtime_seconds)) || any(fits$runtime_seconds < 0) ||
      any(!is.finite(fits$boundary_epsilon)) ||
      any(fits$boundary_epsilon != v07_holdout_epsilon)) {
    v07_stop("doc47 fits.tsv contains an invalid counter, runtime, or epsilon")
  }
  for (index in seq_len(nrow(fits))) {
    error_class <- as.character(fits$error_class[[index]])
    if (!identical(error_class, "none")) {
      if (!identical(as.character(fits$termination_reason[[index]]), error_class)) {
        v07_stop("doc47 failed fit termination reason/error class mismatch")
      }
      if (!identical(as.character(fits$optimizer_status[[index]]), "exception") ||
          !identical(as.character(fits$boundary_status[[index]]), "exception") ||
          fits$converged[[index]]) {
        v07_stop("doc47 failed fit row semantic mismatch")
      }
      failed_fields <- c(
        "sigma_g2", "sigma_e2", "numerical_ratio", "profile_ratio",
        "profile_t_hat", "profile_loglik", "objective", "ai_score_norm",
        "fd_log_gradient_norm", "lower_derivative_per_observation",
        "upper_derivative_per_observation"
      )
      if (any(vapply(fits[index, failed_fields, drop = FALSE], function(x) {
        !is.na(x[[1L]])
      }, logical(1L)))) {
        v07_stop("doc47 failed fit row retained scientific values")
      }
    }
  }
  if (identical(as.character(fits$error_class[[1L]]), "none") &&
      !identical(as.character(fits$boundary_status[[1L]]), "not_classified")) {
    v07_stop("doc47 default fit must be not_classified")
  }
  if (identical(as.character(fits$error_class[[1L]]), "none")) {
    default_status <- as.character(fits$optimizer_status[[1L]])
    if (!default_status %in% c("converged", "not_converged")) {
      v07_stop("doc47 default optimizer status is invalid")
    }
    if (!identical(as.character(fits$termination_reason[[1L]]), default_status)) {
      v07_stop("doc47 default termination reason/status mismatch")
    }
    if (!identical(fits$converged[[1L]], default_status == "converged")) {
      v07_stop("doc47 default convergence/status mismatch")
    }
  }
  default_missing <- c(
    "profile_ratio", "profile_t_hat", "profile_loglik",
    "lower_derivative_per_observation", "upper_derivative_per_observation"
  )
  if (identical(as.character(fits$error_class[[1L]]), "none") &&
      any(vapply(fits[1L, default_missing, drop = FALSE],
    function(x) !is.na(x[[1L]]), logical(1L)))) {
    v07_stop("doc47 default fit contains classified profile fields")
  }
  allowed <- c(
    "boundary_lower", "boundary_upper", "interior", "interior_rescued",
    "boundary_unresolved"
  )
  status <- as.character(fits$boundary_status[[2L]])
  if (!identical(as.character(fits$error_class[[2L]]), "none")) return(fits)
  if (!status %in% allowed) v07_stop("doc47 candidate boundary_status is invalid")
  expected <- switch(status,
    boundary_lower = c("boundary_lower", "boundary_lower", "true"),
    boundary_upper = c("boundary_upper", "boundary_upper", "true"),
    interior = c("ai_interior", "converged", "true"),
    interior_rescued = c("profile_interior", "interior_rescued", "true"),
    boundary_unresolved = c(NA_character_, "boundary_unresolved", "false")
  )
  if (is.na(expected[[1L]])) {
    if (!nzchar(as.character(fits$termination_reason[[2L]]))) {
      v07_stop("doc47 unresolved candidate termination reason is empty")
    }
  } else if (!identical(
    as.character(fits$termination_reason[[2L]]), expected[[1L]]
  )) {
    v07_stop("doc47 candidate termination reason mismatch")
  }
  if (!identical(as.character(fits$optimizer_status[[2L]]), expected[[2L]])) {
    v07_stop("doc47 candidate optimizer status mismatch")
  }
  if (!identical(fits$converged[[2L]], expected[[3L]] == "true")) {
    v07_stop("doc47 candidate convergence/status mismatch")
  }
  resolved <- status != "boundary_unresolved"
  candidate_fields <- c(
    "sigma_g2", "sigma_e2", "numerical_ratio", "profile_ratio",
    "profile_t_hat", "profile_loglik", "lower_derivative_per_observation",
    "upper_derivative_per_observation", "objective", "ai_score_norm",
    "fd_log_gradient_norm"
  )
  if (resolved && any(!is.finite(unlist(fits[2L, candidate_fields, drop = FALSE])))) {
    v07_stop("resolved doc47 candidate contains a non-finite field")
  }
  if (resolved && (!fits$converged[[2L]] || fits$sigma_g2[[2L]] <= 0 ||
      fits$sigma_e2[[2L]] <= 0 || fits$numerical_ratio[[2L]] <= 0 ||
      fits$numerical_ratio[[2L]] >= 1)) {
    v07_stop("resolved doc47 candidate violates the positive numerical contract")
  }
  if (status == "boundary_unresolved" && fits$converged[[2L]]) {
    v07_stop("unresolved doc47 candidate cannot be converged")
  }
  if (status == "boundary_lower" && (fits$profile_ratio[[2L]] != 0 ||
      fits$numerical_ratio[[2L]] != v07_holdout_epsilon)) {
    v07_stop("lower-boundary scientific/numerical ratio mismatch")
  }
  if (status == "boundary_upper" && (fits$profile_ratio[[2L]] != 1 ||
      fits$numerical_ratio[[2L]] != (1 - v07_holdout_epsilon))) {
    v07_stop("upper-boundary scientific/numerical ratio mismatch")
  }
  fits
}

v07_read_holdout_exchange <- function(
  dataset_dir,
  candidate_seal_path,
  r_repo,
  oracle_path = v07_oracle_source_path
) {
  dataset_dir <- normalizePath(dataset_dir, mustWork = TRUE)
  candidate_seal <- v07_holdout_read_candidate_seal(
    candidate_seal_path, r_repo, oracle_path
  )
  seal <- v07_holdout_verify_seal(dataset_dir)
  metadata <- v07_holdout_read_metadata(
    file.path(dataset_dir, "metadata.tsv"), candidate_seal
  )
  y_frame <- v07_read_tsv(file.path(dataset_dir, "y.tsv"))
  v07_assert_names(y_frame, c("row", "y"), "doc47 y.tsv")
  ids_frame <- v07_read_tsv(file.path(dataset_dir, "ids.tsv"))
  v07_assert_names(ids_frame, c("row", "id"), "doc47 ids.tsv")
  X_frame <- v07_read_tsv(file.path(dataset_dir, "X.tsv"))
  K_frame <- v07_read_tsv(file.path(dataset_dir, "K.tsv"))
  Q_frame <- v07_read_tsv(file.path(dataset_dir, "Q.tsv"))
  n <- as.integer(metadata[["n"]]); p <- as.integer(metadata[["p"]])
  if (!identical(as.integer(y_frame$row), seq_len(nrow(y_frame))) ||
      !identical(as.integer(ids_frame$row), seq_len(nrow(ids_frame))) ||
      !identical(as.integer(X_frame$row), seq_len(nrow(X_frame))) ||
      !identical(as.integer(K_frame$row), seq_len(nrow(K_frame))) ||
      !identical(as.integer(Q_frame$row), seq_len(nrow(Q_frame)))) {
    v07_stop("doc47 y/ids/X/K/Q row index drift")
  }
  y <- suppressWarnings(as.numeric(y_frame$y))
  ids <- as.character(ids_frame$id)
  X <- v07_numeric_matrix(X_frame[-1L], "doc47 X.tsv")
  K <- v07_numeric_matrix(K_frame[-1L], "doc47 K.tsv")
  Q <- v07_numeric_matrix(Q_frame[-1L], "doc47 Q.tsv")
  if (length(y) != n || any(!is.finite(y)) || length(ids) != n ||
      anyNA(ids) || any(!nzchar(ids)) || anyDuplicated(ids) ||
      nrow(X) != n || ncol(X) != p ||
      nrow(K) != n || ncol(K) != n ||
      nrow(Q) != n || ncol(Q) != n ||
      !identical(colnames(X), paste0("x", seq_len(p))) ||
      !identical(colnames(K), paste0("k", seq_len(n))) ||
      !identical(colnames(Q), paste0("q", seq_len(n)))) {
    v07_stop("doc47 y/ids/X/K/Q schema or dimension mismatch")
  }
  if (qr(X)$rank != p || max(abs(K - t(K))) > 1e-12 ||
      max(abs(Q - t(Q))) > 1e-12) {
    v07_stop("doc47 X rank or K/Q symmetry check failed")
  }
  tryCatch(chol(K), error = function(e) v07_stop("doc47 K is not positive definite"))
  tryCatch(chol(Q), error = function(e) v07_stop("doc47 Q is not positive definite"))
  if (max(abs(Q %*% K - diag(n))) > v07_holdout_inverse_tolerance) {
    v07_stop("doc47 Q*K identity exceeds the frozen tolerance")
  }
  computed <- c(
    id_hash = v07_id_fingerprint(ids),
    kernel_hash = v07_matrix_fingerprint("K_lambda", K, ids),
    precision_hash = v07_matrix_fingerprint("Q_lambda", Q, ids)
  )
  if (!identical(unname(computed), unname(metadata[names(computed)]))) {
    v07_stop("doc47 ID, kernel, or precision fingerprint mismatch")
  }
  fits <- v07_holdout_validate_fits(
    v07_read_tsv(file.path(dataset_dir, "fits.tsv")), metadata
  )
  list(
    y = y, ids = ids, X = X, K = K, Q = Q, fits = fits,
    metadata = metadata, seal = seal, candidate_seal = candidate_seal
  )
}

v07_build_holdout_oracle <- function(exchange) {
  oracle <- v07_classify_oracle(exchange$y, exchange$X, exchange$K)
  class <- c(
    lower_boundary = "boundary_lower", upper_boundary = "boundary_upper",
    interior_oracle = "interior_oracle", oracle_unresolved = "oracle_unresolved"
  )[[oracle$class]]
  t_hat <- oracle$sigma_g2 + oracle$sigma_e2
  if (class == "boundary_lower") {
    sg <- v07_holdout_epsilon * t_hat; se <- (1 - v07_holdout_epsilon) * t_hat
  } else if (class == "boundary_upper") {
    sg <- (1 - v07_holdout_epsilon) * t_hat; se <- v07_holdout_epsilon * t_hat
  } else {
    sg <- oracle$sigma_g2; se <- oracle$sigma_e2
  }
  data.frame(
    cell_id = exchange$metadata[["cell_id"]],
    seed = as.numeric(exchange$metadata[["seed"]]),
    packet_files_lock_sha256 = exchange$seal$digest,
    candidate_seal_sha256 = exchange$candidate_seal$digest,
    candidate_id = exchange$metadata[["candidate_id"]],
    doc46_commit = exchange$metadata[["doc46_commit"]],
    doc46_sha256 = exchange$metadata[["doc46_sha256"]],
    doc47_commit = exchange$metadata[["doc47_commit"]],
    doc47_sha256 = exchange$metadata[["doc47_sha256"]],
    julia_boundary_impl_commit = exchange$metadata[["julia_boundary_impl_commit"]],
    r_boundary_impl_commit = exchange$metadata[["r_boundary_impl_commit"]],
    r_oracle_sha256 = exchange$metadata[["r_oracle_sha256"]],
    marker_hash = exchange$metadata[["marker_hash"]],
    id_hash = exchange$metadata[["id_hash"]],
    kernel_hash = exchange$metadata[["kernel_hash"]],
    precision_hash = exchange$metadata[["precision_hash"]],
    default_result_digest = exchange$fits$result_digest[[1L]],
    candidate_result_digest = exchange$fits$result_digest[[2L]],
    oracle_class = class,
    oracle_profile_ratio = oracle$ratio,
    oracle_t_hat = t_hat,
    oracle_profile_loglik = oracle$loglik,
    oracle_lower_derivative_per_observation = oracle$d0_per_observation,
    oracle_upper_derivative_per_observation = oracle$d1_per_observation,
    oracle_sigma_g2_numerical = sg,
    oracle_sigma_e2_numerical = se,
    check.names = FALSE
  )[v07_holdout_oracle_columns]
}

v07_write_holdout_oracle <- function(x, output) {
  v07_assert_names(x, v07_holdout_oracle_columns, "doc47 oracle output")
  sidecar <- paste0(output, ".sha256")
  claim <- paste0(output, ".create-once-claim")
  dir.create(dirname(output), recursive = TRUE, showWarnings = FALSE)
  if (!dir.create(claim, showWarnings = FALSE)) {
    v07_stop("refusing to overwrite or race create-once output: ", output)
  }
  linked_output <- FALSE
  linked_sidecar <- FALSE
  staged_sha256 <- NULL
  on.exit({
    if (linked_output && !linked_sidecar && file.exists(output) &&
        !is.null(staged_sha256) &&
        identical(v07_sha256_file(output), staged_sha256)) {
      unlink(output)
    }
    unlink(claim, recursive = TRUE)
  }, add = TRUE)
  if (file.exists(output) || file.exists(sidecar)) {
    v07_stop("refusing to overwrite create-once output or sidecar: ", output)
  }
  staged_output <- file.path(claim, basename(output))
  staged_sidecar <- file.path(claim, basename(sidecar))
  utils::write.table(x, staged_output, sep = "\t", quote = FALSE, row.names = FALSE,
    na = "NaN")
  staged_sha256 <- v07_sha256_file(staged_output)
  lock <- data.frame(
    sha256 = staged_sha256,
    file = basename(output)
  )
  utils::write.table(lock, staged_sidecar, sep = "\t", quote = FALSE,
    row.names = FALSE)
  if (!isTRUE(suppressWarnings(file.link(staged_output, output)))) {
    v07_stop("atomic exclusive doc47 oracle output link failed")
  }
  linked_output <- TRUE
  if (!isTRUE(suppressWarnings(file.link(staged_sidecar, sidecar)))) {
    v07_stop("atomic exclusive doc47 oracle sidecar link failed")
  }
  linked_sidecar <- TRUE
  invisible(output)
}

v07_verify_holdout_oracle <- function(output, expected, tolerance = 1e-12) {
  v07_verify_output_sidecar(output)
  actual <- v07_read_tsv(output)
  v07_assert_names(actual, v07_holdout_oracle_columns, "saved doc47 oracle output")
  if (nrow(actual) != 1L) {
    v07_stop("doc47 oracle row-count mismatch")
  }
  numeric <- grep("^oracle_(?!class$)", v07_holdout_oracle_columns,
    value = TRUE, perl = TRUE)
  character <- setdiff(v07_holdout_oracle_columns, numeric)
  for (field in character) {
    if (!identical(as.character(actual[[field]]), as.character(expected[[field]]))) {
      v07_stop("doc47 oracle binding mismatch in ", field)
    }
  }
  for (field in numeric) {
    a <- suppressWarnings(as.numeric(actual[[field]])); e <- expected[[field]]
    if (any(is.na(a) != is.na(e)) ||
        any(abs(a[is.finite(e)] - e[is.finite(e)]) > tolerance)) {
      v07_stop("doc47 oracle numeric mismatch in ", field)
    }
  }
  invisible(TRUE)
}

v07_cli_value <- function(args, flag) {
  hit <- which(args == flag)
  if (length(hit) != 1L || hit == length(args)) {
    v07_stop("missing or repeated CLI flag: ", flag)
  }
  args[[hit + 1L]]
}

v07_oracle_main <- function(args = commandArgs(trailingOnly = TRUE)) {
  if (!length(args)) {
    v07_stop(paste(
      "usage: oracle|verify|holdout-oracle|holdout-verify|selftest",
      "[--dataset DIR] [--output FILE] [--seal FILE] [--r-repo DIR]"
    ))
  }
  mode <- args[[1L]]
  if (identical(mode, "selftest")) {
    return(v07_selftest())
  }
  if (!mode %in% c("oracle", "verify", "holdout-oracle", "holdout-verify")) {
    v07_stop("unknown mode: ", mode)
  }
  dataset <- v07_cli_value(args, "--dataset")
  output <- v07_cli_value(args, "--output")
  if (mode %in% c("holdout-oracle", "holdout-verify")) {
    seal <- v07_cli_value(args, "--seal")
    r_repo <- v07_cli_value(args, "--r-repo")
    exchange <- v07_read_holdout_exchange(dataset, seal, r_repo)
    expected <- v07_build_holdout_oracle(exchange)
    if (mode == "holdout-oracle") {
      v07_write_holdout_oracle(expected, output)
    } else {
      v07_verify_holdout_oracle(output, expected)
    }
    return(invisible(TRUE))
  }
  exchange <- v07_read_exchange(dataset)
  expected <- v07_build_oracle_rows(exchange)
  if (mode == "oracle") {
    v07_write_create_once(expected, output)
  } else {
    v07_verify_output_sidecar(output)
    v07_compare_output(v07_read_tsv(output), expected)
  }
  invisible(TRUE)
}

v07_selftest <- function() {
  # Independent in-memory tests-of-the-tests. The testthat suite exercises the
  # sealed exchange and mutation surface more extensively.
  if (!identical(
    v07_holdout_exchange_schema_sha256(),
    "2472abefc1323ac6cea778b7070f1e0a8e3a8860eeac2c6bddbe7ddf4e44c813"
  )) {
    v07_stop("selftest doc47 exchange-schema digest drift")
  }
  launcher <- match("launcher_sha256", v07_holdout_seal_keys)
  if (!identical(
    v07_holdout_seal_keys[launcher + seq_len(2L)],
    c("genomic_source_sha256", "r_oracle_sha256")
  )) {
    v07_stop("selftest doc47 candidate-seal order drift")
  }
  set.seed(1)
  y <- stats::rnorm(8)
  K <- crossprod(matrix(stats::rnorm(64), 8, 8)) / 8 + diag(8) * 0.1
  X <- matrix(1, 8, 1)
  interior <- v07_classify_oracle(y, X, K)
  if (interior$class != "interior_oracle") {
    v07_stop("selftest interior oracle unexpectedly unresolved")
  }
  set.seed(99)
  y_boundary <- stats::rnorm(8)
  A <- matrix(stats::rnorm(64), 8, 8)
  K_boundary <- crossprod(A) / 8 + diag(8) * 0.05
  X_boundary <- matrix(1, 8, 1)
  boundary <- v07_classify_oracle(y_boundary, X_boundary, K_boundary)
  reversed <- v07_classify_oracle(
    y_boundary,
    X_boundary,
    K_boundary,
    reverse_kkt = TRUE
  )
  if (
    !grepl("boundary", boundary$class) ||
      identical(reversed$class, boundary$class)
  ) {
    v07_stop("selftest failed to detect reversed endpoint KKT sign")
  }
  value <- v07_component_loglik(0.4, 0.6, y, X, K)
  gradient <- v07_fd_log_gradient(0.4, 0.6, y, X, K)
  if (!is.finite(value) || !is.finite(gradient)) {
    v07_stop("selftest produced a non-finite result")
  }
  message("V07_GENOMIC_BOUNDARY_ORACLE_SELFTEST_PASS")
  invisible(TRUE)
}

if (sys.nframe() == 0L) {
  v07_oracle_main()
}
