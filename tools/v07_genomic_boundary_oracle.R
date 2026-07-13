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

# Frozen doc-46 holdout exchange.  This is deliberately separate from the
# doc-45 localization exchange above: the holdout packet contains exactly the
# unchanged AI fit and the sealed boundary-aware candidate, not optimizer arms.
v07_holdout_schema <- "v07-genomic-boundary-holdout-v1"
v07_holdout_candidate_id <- "doc46_boundary_v1"
v07_holdout_epsilon <- 1e-7
v07_holdout_doc46 <- c(
  commit = "fe96a147be23d74c5331eb37cd8b681ecce77be6",
  sha256 = "283ab00bab3da925f0ac2916959efacaa7fb711c5da4dce09dd49ea568eef030"
)
v07_holdout_files <- c("K.tsv", "X.tsv", "fits.tsv", "metadata.tsv", "y.tsv")
v07_holdout_metadata_keys <- c(
  "schema_version", "candidate_id", "cell_id", "seed", "n", "p", "m",
  "ridge", "marker_hash", "id_hash", "kernel_hash", "doc46_commit",
  "doc46_sha256", "julia_boundary_impl_commit", "r_boundary_impl_commit",
  "discovery_digest", "discovery_candidate_seal_sha256",
  "candidate_seal_sha256", "holdout_manifest_sha256", "execution_commit",
  "driver_sha256", "r_oracle_sha256"
)
v07_holdout_fit_columns <- c(
  "cell_id", "seed", "route", "converged", "termination_reason",
  "iterations", "sigma_g2", "sigma_e2", "numerical_ratio", "profile_ratio",
  "profile_t_hat", "boundary_status", "boundary_epsilon", "profile_loglik",
  "lower_derivative_per_observation", "upper_derivative_per_observation",
  "objective", "ai_score_norm", "fd_log_gradient_norm", "runtime_seconds",
  "marker_hash", "id_hash", "kernel_hash"
)
v07_holdout_oracle_columns <- c(
  "cell_id", "seed", "oracle_class", "oracle_profile_ratio", "oracle_t_hat",
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
  lock <- v07_read_tsv(lock_path)
  v07_assert_names(lock, c("relative_path", "sha256"), "files.sha256.tsv")
  if (nrow(lock) != length(v07_holdout_files) || anyDuplicated(lock$relative_path) ||
      !identical(lock$relative_path, v07_holdout_files)) {
    v07_stop("doc46 sealed file set or order mismatch")
  }
  actual_files <- sort(basename(list.files(dataset_dir, full.names = TRUE)))
  expected_files <- sort(c(v07_holdout_files, "files.sha256.tsv"))
  if (!identical(actual_files, expected_files)) {
    v07_stop("doc46 dataset file set mismatch")
  }
  if (!all(grepl("^[0-9a-f]{64}$", lock$sha256))) {
    v07_stop("doc46 file lock contains an invalid SHA-256")
  }
  actual <- vapply(
    v07_holdout_files,
    function(x) v07_sha256_file(file.path(dataset_dir, x)),
    character(1L)
  )
  if (!identical(unname(actual), lock$sha256)) {
    v07_stop("doc46 sealed file hash mismatch")
  }
  list(lock = lock, digest = v07_sha256_file(lock_path))
}

v07_holdout_read_metadata <- function(path) {
  x <- v07_read_tsv(path)
  v07_assert_names(x, c("key", "value"), "doc46 metadata.tsv")
  if (nrow(x) != length(v07_holdout_metadata_keys) || anyDuplicated(x$key) ||
      !identical(x$key, v07_holdout_metadata_keys) || any(!nzchar(x$value))) {
    v07_stop("doc46 metadata key set, order, or value mismatch")
  }
  out <- stats::setNames(x$value, x$key)
  if (!identical(out[["schema_version"]], v07_holdout_schema) ||
      !identical(out[["candidate_id"]], v07_holdout_candidate_id) ||
      !identical(out[["doc46_commit"]], v07_holdout_doc46[["commit"]]) ||
      !identical(out[["doc46_sha256"]], v07_holdout_doc46[["sha256"]])) {
    v07_stop("doc46 frozen schema, candidate, or document identity mismatch")
  }
  hash_keys <- c(
    "marker_hash", "id_hash", "kernel_hash", "doc46_sha256",
    "discovery_digest", "discovery_candidate_seal_sha256",
    "candidate_seal_sha256", "holdout_manifest_sha256", "driver_sha256",
    "r_oracle_sha256"
  )
  commit_keys <- c(
    "doc46_commit", "julia_boundary_impl_commit", "r_boundary_impl_commit",
    "execution_commit"
  )
  if (any(!grepl("^[0-9a-f]{64}$", out[hash_keys])) ||
      any(!grepl("^[0-9a-f]{40}$", out[commit_keys]))) {
    v07_stop("doc46 metadata contains an invalid hash or commit")
  }
  if (!is.null(v07_oracle_source_path) &&
      out[["r_oracle_sha256"]] != v07_sha256_file(v07_oracle_source_path)) {
    v07_stop("doc46 metadata r_oracle_sha256 does not match this oracle")
  }
  numeric <- suppressWarnings(as.numeric(out[c("seed", "n", "p", "m", "ridge")]))
  if (any(!is.finite(numeric)) || numeric[[2L]] < 2 || numeric[[3L]] < 1 ||
      numeric[[3L]] >= numeric[[2L]] || numeric[[4L]] < 1 || numeric[[5L]] != 0.01) {
    v07_stop("doc46 metadata contains invalid n/p/m/ridge values")
  }
  out
}

v07_holdout_validate_fits <- function(fits, metadata) {
  v07_assert_names(fits, v07_holdout_fit_columns, "doc46 fits.tsv")
  if (nrow(fits) != 2L ||
      !identical(as.character(fits$route), c("default_ai", "boundary_candidate"))) {
    v07_stop("doc46 fits.tsv must contain default_ai then boundary_candidate")
  }
  for (field in c("cell_id", "seed", "marker_hash", "id_hash", "kernel_hash")) {
    if (any(as.character(fits[[field]]) != metadata[[field]])) {
      v07_stop("doc46 fits.tsv/metadata mismatch in ", field)
    }
  }
  logical <- tolower(as.character(fits$converged))
  if (any(!logical %in% c("true", "false"))) {
    v07_stop("doc46 fits.tsv converged must contain TRUE or FALSE")
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
    v07_stop("doc46 fits.tsv contains an invalid counter, runtime, or epsilon")
  }
  if (!identical(as.character(fits$boundary_status[[1L]]), "not_classified")) {
    v07_stop("doc46 default fit must be not_classified")
  }
  default_missing <- c(
    "profile_ratio", "profile_t_hat", "profile_loglik",
    "lower_derivative_per_observation", "upper_derivative_per_observation"
  )
  if (any(vapply(fits[1L, default_missing, drop = FALSE],
    function(x) !is.na(x[[1L]]), logical(1L)))) {
    v07_stop("doc46 default fit contains classified profile fields")
  }
  allowed <- c(
    "boundary_lower", "boundary_upper", "interior", "interior_rescued",
    "boundary_unresolved"
  )
  status <- as.character(fits$boundary_status[[2L]])
  if (!status %in% allowed) v07_stop("doc46 candidate boundary_status is invalid")
  resolved <- status != "boundary_unresolved"
  candidate_fields <- c(
    "sigma_g2", "sigma_e2", "numerical_ratio", "profile_ratio",
    "profile_t_hat", "profile_loglik", "lower_derivative_per_observation",
    "upper_derivative_per_observation", "objective", "ai_score_norm",
    "fd_log_gradient_norm"
  )
  if (resolved && any(!is.finite(unlist(fits[2L, candidate_fields, drop = FALSE])))) {
    v07_stop("resolved doc46 candidate contains a non-finite field")
  }
  if (resolved && (!fits$converged[[2L]] || fits$sigma_g2[[2L]] <= 0 ||
      fits$sigma_e2[[2L]] <= 0 || fits$numerical_ratio[[2L]] <= 0 ||
      fits$numerical_ratio[[2L]] >= 1)) {
    v07_stop("resolved doc46 candidate violates the positive numerical contract")
  }
  if (status == "boundary_unresolved" && fits$converged[[2L]]) {
    v07_stop("unresolved doc46 candidate cannot be converged")
  }
  if (status == "boundary_lower" && (fits$profile_ratio[[2L]] != 0 ||
      abs(fits$numerical_ratio[[2L]] - v07_holdout_epsilon) > 1e-15)) {
    v07_stop("lower-boundary scientific/numerical ratio mismatch")
  }
  if (status == "boundary_upper" && (fits$profile_ratio[[2L]] != 1 ||
      abs(fits$numerical_ratio[[2L]] - (1 - v07_holdout_epsilon)) > 1e-15)) {
    v07_stop("upper-boundary scientific/numerical ratio mismatch")
  }
  fits
}

v07_read_holdout_exchange <- function(dataset_dir) {
  dataset_dir <- normalizePath(dataset_dir, mustWork = TRUE)
  seal <- v07_holdout_verify_seal(dataset_dir)
  metadata <- v07_holdout_read_metadata(file.path(dataset_dir, "metadata.tsv"))
  y_frame <- v07_read_tsv(file.path(dataset_dir, "y.tsv"))
  v07_assert_names(y_frame, c("row", "y"), "doc46 y.tsv")
  X_frame <- v07_read_tsv(file.path(dataset_dir, "X.tsv"))
  K_frame <- v07_read_tsv(file.path(dataset_dir, "K.tsv"))
  n <- as.integer(metadata[["n"]]); p <- as.integer(metadata[["p"]])
  if (!identical(as.integer(y_frame$row), seq_len(nrow(y_frame))) ||
      !identical(as.integer(X_frame$row), seq_len(nrow(X_frame))) ||
      !identical(as.integer(K_frame$row), seq_len(nrow(K_frame)))) {
    v07_stop("doc46 y/X/K row index drift")
  }
  y <- suppressWarnings(as.numeric(y_frame$y))
  X <- v07_numeric_matrix(X_frame[-1L], "doc46 X.tsv")
  K <- v07_numeric_matrix(K_frame[-1L], "doc46 K.tsv")
  if (length(y) != n || any(!is.finite(y)) || nrow(X) != n || ncol(X) != p ||
      nrow(K) != n || ncol(K) != n ||
      !identical(colnames(X), paste0("x", seq_len(p))) ||
      !identical(colnames(K), paste0("k", seq_len(n)))) {
    v07_stop("doc46 y/X/K schema or dimension mismatch")
  }
  if (qr(X)$rank != p || max(abs(K - t(K))) > 1e-12) {
    v07_stop("doc46 X rank or K symmetry check failed")
  }
  tryCatch(chol(K), error = function(e) v07_stop("doc46 K is not positive definite"))
  fits <- v07_holdout_validate_fits(
    v07_read_tsv(file.path(dataset_dir, "fits.tsv")), metadata
  )
  list(y = y, X = X, K = K, fits = fits, metadata = metadata, seal = seal)
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
  v07_assert_names(x, v07_holdout_oracle_columns, "doc46 oracle output")
  sidecar <- paste0(output, ".sha256")
  if (file.exists(output) || file.exists(sidecar)) {
    v07_stop("refusing to overwrite create-once output or sidecar: ", output)
  }
  dir.create(dirname(output), recursive = TRUE, showWarnings = FALSE)
  tmp <- tempfile(paste0(".", basename(output), "."), tmpdir = dirname(output))
  on.exit(unlink(tmp), add = TRUE)
  utils::write.table(x, tmp, sep = "\t", quote = FALSE, row.names = FALSE,
    na = "NaN")
  if (file.exists(output) || !file.rename(tmp, output)) {
    v07_stop("atomic create-once doc46 oracle output failed")
  }
  lock <- data.frame(sha256 = v07_sha256_file(output), file = basename(output))
  lock_tmp <- tempfile(paste0(".", basename(sidecar), "."), tmpdir = dirname(output))
  on.exit(unlink(lock_tmp), add = TRUE)
  utils::write.table(lock, lock_tmp, sep = "\t", quote = FALSE, row.names = FALSE)
  if (file.exists(sidecar) || !file.rename(lock_tmp, sidecar)) {
    unlink(output); v07_stop("atomic create-once doc46 oracle sidecar failed")
  }
  invisible(output)
}

v07_verify_holdout_oracle <- function(output, expected, tolerance = 1e-12) {
  v07_verify_output_sidecar(output)
  actual <- v07_read_tsv(output)
  v07_assert_names(actual, v07_holdout_oracle_columns, "saved doc46 oracle output")
  if (nrow(actual) != 1L || !identical(as.character(actual$cell_id), expected$cell_id) ||
      !identical(as.character(actual$oracle_class), expected$oracle_class)) {
    v07_stop("doc46 oracle identity or class mismatch")
  }
  numeric <- setdiff(v07_holdout_oracle_columns, c("cell_id", "oracle_class"))
  for (field in numeric) {
    a <- suppressWarnings(as.numeric(actual[[field]])); e <- expected[[field]]
    if (any(is.na(a) != is.na(e)) ||
        any(abs(a[is.finite(e)] - e[is.finite(e)]) > tolerance)) {
      v07_stop("doc46 oracle numeric mismatch in ", field)
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
      "[--dataset DIR] [--output FILE]"
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
    exchange <- v07_read_holdout_exchange(dataset)
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
