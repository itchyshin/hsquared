#!/usr/bin/env Rscript

# Independent base-R closed-domain REML oracle for the frozen v0.7 genomic
# optimizer-localization study. This developer tool deliberately does not load
# hsquared or call any package construction or fitting helper.

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
v07_sealed_files <- c("y.tsv", "X.tsv", "K.tsv", "metadata.tsv", "arms.tsv")
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
  tryCatch(
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
}

v07_verify_seal <- function(dataset_dir) {
  lock_path <- file.path(dataset_dir, "files.sha256.tsv")
  lock <- v07_read_tsv(lock_path)
  v07_assert_names(lock, c("file", "sha256"), "files.sha256.tsv")
  if (nrow(lock) != length(v07_sealed_files) || anyDuplicated(lock$file)) {
    v07_stop("files.sha256.tsv must contain each sealed file exactly once")
  }
  if (!identical(lock$file, v07_sealed_files)) {
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
    if (any(!is.finite(value))) {
      v07_stop("arms.tsv has non-finite numeric field: ", field)
    }
    arms[[field]] <- value
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
    any(vapply(
      arms[integer_fields],
      function(x) any(x < 0 | x != floor(x)),
      logical(1L)
    ))
  ) {
    v07_stop("arms.tsv contains an invalid counter")
  }
  if (
    any(!arms$cap %in% c(100, 1000)) ||
      any(!arms$em_warmup %in% c(0, 5)) ||
      any(arms$start_sigma_g2 <= 0 | arms$start_sigma_e2 <= 0) ||
      any(arms$estimate_sigma_g2 < 0 | arms$estimate_sigma_e2 < 0) ||
      any(arms$estimate_ratio < 0 | arms$estimate_ratio > 1) ||
      any(arms$smallest_component < 0) ||
      any(arms$runtime_seconds < 0 | arms$peak_rss_mb < 0)
  ) {
    v07_stop("arms.tsv contains a value outside the frozen domain")
  }
  logical_value <- tolower(as.character(arms$converged))
  if (any(!logical_value %in% c("true", "false"))) {
    v07_stop("arms.tsv converged must contain only TRUE or FALSE")
  }
  arms$converged <- logical_value == "true"
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
  v07_assert_names(y_frame, "y", "y.tsv")
  y <- as.numeric(y_frame$y)
  if (any(!is.finite(y))) {
    v07_stop("y.tsv contains non-finite or nonnumeric values")
  }
  X <- v07_numeric_matrix(
    v07_read_tsv(file.path(dataset_dir, "X.tsv")),
    "X.tsv"
  )
  K <- v07_numeric_matrix(
    v07_read_tsv(file.path(dataset_dir, "K.tsv")),
    "K.tsv"
  )
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
  arms <- v07_validate_arms(
    v07_read_tsv(file.path(dataset_dir, "arms.tsv")),
    metadata
  )
  list(y = y, X = X, K = K, metadata = metadata, arms = arms, seal = seal)
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
  endpoint_tie <- any(
    abs(candidates_ll[c("lower", "upper")] - max(candidates_ll)) <= tie_tol
  ) &&
    names(candidates_ll)[[best]] == "interior"
  endpoint_pair_tie <- abs(
    candidates_ll[["lower"]] - candidates_ll[["upper"]]
  ) <=
    tie_tol &&
    max(candidates_ll[c("lower", "upper")]) + tie_tol >=
      candidates_ll[["interior"]]
  class <- "oracle_unresolved"
  if (
    !endpoint_tie &&
      !endpoint_pair_tie &&
      candidates_ll[["lower"]] - max(candidates_ll[c("interior", "upper")]) >
        tie_tol &&
      lower_kkt
  ) {
    class <- "lower_boundary"
    ratio <- 0
  } else if (
    !endpoint_tie &&
      !endpoint_pair_tie &&
      candidates_ll[["upper"]] - max(candidates_ll[c("lower", "interior")]) >
        tie_tol &&
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
  out$oracle_arm_loglik <- vapply(
    arms$estimate_ratio,
    function(r) v07_profile_loglik(r, exchange$y, exchange$X, exchange$K),
    numeric(1L)
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
  v07_assert_names(out, v07_oracle_columns, "oracle output")
  if (
    any(
      !is.finite(as.matrix(out[c(
        "oracle_arm_loglik",
        "oracle_loglik",
        "objective_gap_per_observation",
        "oracle_fd_log_gradient_norm",
        "lower_derivative_per_observation",
        "upper_derivative_per_observation"
      )]))
    )
  ) {
    v07_stop("independent oracle produced a non-finite diagnostic")
  }
  out
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
  utils::write.table(
    x,
    tmp,
    sep = "\t",
    quote = FALSE,
    row.names = FALSE,
    na = "NA"
  )
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

v07_cli_value <- function(args, flag) {
  hit <- which(args == flag)
  if (length(hit) != 1L || hit == length(args)) {
    v07_stop("missing or repeated CLI flag: ", flag)
  }
  args[[hit + 1L]]
}

v07_oracle_main <- function(args = commandArgs(trailingOnly = TRUE)) {
  if (!length(args)) {
    v07_stop("usage: oracle|verify|selftest [--dataset DIR] [--output FILE]")
  }
  mode <- args[[1L]]
  if (identical(mode, "selftest")) {
    return(v07_selftest())
  }
  if (!mode %in% c("oracle", "verify")) {
    v07_stop("unknown mode: ", mode)
  }
  dataset <- v07_cli_value(args, "--dataset")
  output <- v07_cli_value(args, "--output")
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
