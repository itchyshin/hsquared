#!/usr/bin/env Rscript

# Independent base-R recomputation for recovery-v2. This file deliberately
# does not source the campaign driver, load hsquared, or call package genomic
# construction helpers. Julia's versioned binary fingerprint encoder is not
# reimplemented here: fingerprints are shape-checked, while p/k/K/Q and QK=I
# are reconstructed numerically from each sealed marker packet.

v07r_manifest_columns <- c(
  "tier", "cell_id", "cell_index", "seed_offset", "seed", "n", "m",
  "truth_sigma_g2", "truth_sigma_e2", "truth_ratio", "ridge", "regime"
)
v07r_attempt_columns <- c(
  "tier", "cell_id", "cell_index", "seed_offset", "seed", "n", "m",
  "truth_sigma_g2", "truth_sigma_e2", "truth_ratio", "ridge", "attempted",
  "status", "error_class", "converged", "boundary_status", "boundary_reason",
  "boundary_epsilon", "scientific_sigma_g2", "scientific_sigma_e2",
  "scientific_ratio", "profile_t_hat", "numerical_sigma_g2",
  "numerical_sigma_e2", "numerical_ratio", "profile_loglik",
  "lower_derivative_per_observation", "upper_derivative_per_observation",
  "iterations", "objective", "gradient_norm", "runtime_seconds", "peak_rss_mb",
  "relationship_source", "relationship_method", "allele_frequency_source",
  "relationship_scale", "scale_denominator", "marker_hash", "id_hash",
  "kernel_hash", "precision_hash", "route", "r_implementation_commit",
  "julia_implementation_commit", "driver_commit", "seal_sha256"
)
v07r_summary_columns <- c(
  "tier", "cell_id", "n_expected", "n_attempted", "n_converged",
  "n_bias_rows", "n_interior", "n_interior_rescued", "n_boundary_lower",
  "n_boundary_upper", "n_unresolved", "n_error", "n_resolved_valid",
  "convergence_rate", "wilson_lower", "wilson_upper",
  "target", "truth", "mean_estimate", "bias", "mcse", "pilot_sd_upper",
  "bias_ci_lower", "bias_ci_upper", "margin", "target_pass",
  "required_n_raw", "required_n", "cell_status", "campaign_status",
  "failure_classes"
)
v07r_truth_columns <- c(
  "cell_id", "seed", "n", "requested_m", "retained_m", "truth_sigma_g2",
  "truth_sigma_e2", "truth_ratio", "ridge", "scale_denominator"
)
v07r_packet_primaries <- c(
  "markers.tsv", "ids.tsv", "phenotype.tsv", "truth.tsv", "packet_files_lock.tsv"
)
v07r_expected_cells <- c(
  "n120_m600_r020", "n120_m600_r050", "n120_m600_r080",
  "n300_m150_r020", "n300_m150_r050", "n300_m150_r080",
  "n300_m1000_r020", "n300_m1000_r050", "n300_m1000_r080"
)
v07r_resolved <- c("boundary_lower", "boundary_upper", "interior", "interior_rescued")
v07r_reason <- c(
  boundary_lower = "boundary_lower", boundary_upper = "boundary_upper",
  interior = "ai_interior", interior_rescued = "profile_interior"
)
v07r_ridge <- 0.01
v07r_boundary_epsilon <- 1e-7
v07r_qk_tolerance <- 1e-10
v07r_schema <- "v07-genomic-recovery-v2"
v07r_r_implementation <- "1082d84f4269d4f79fdc248558ec56b8f710b8d2"
v07r_julia_implementation <- "fc9d39df650b20aa09d769d9f9528eed1b606f1e"
v07r_seed_base <- 2027120000
v07r_cells <- data.frame(
  cell_id = v07r_expected_cells, cell_index = 1:9,
  n = rep(c(120L, 300L, 300L), each = 3L),
  m = rep(c(600L, 150L, 1000L), each = 3L),
  truth_ratio = rep(c(0.2, 0.5, 0.8), 3L), stringsAsFactors = FALSE
)
v07r_cells$truth_sigma_g2 <- v07r_cells$truth_ratio
v07r_cells$truth_sigma_e2 <- 1 - v07r_cells$truth_ratio

v07r_abort <- function(...) stop(sprintf(...), call. = FALSE)
v07r_hex64 <- function(x) !is.na(x) && grepl("^[0-9a-f]{64}$", x)

v07r_option <- function(args, key, default = NULL) {
  prefix <- paste0("--", key, "=")
  hit <- args[startsWith(args, prefix)]
  if (!length(hit)) return(default)
  if (length(hit) != 1L) v07r_abort("option --%s must occur once", key)
  sub(prefix, "", hit[[1L]], fixed = TRUE)
}

v07r_system <- function(command, args) {
  out <- system2(command, args, stdout = TRUE, stderr = TRUE)
  status <- attr(out, "status"); if (is.null(status)) status <- 0L
  if (status != 0L) v07r_abort("command failed: %s", paste(out, collapse = "\n"))
  out
}

v07r_sha256 <- function(path) {
  if (!file.exists(path) || isTRUE(file.info(path)$isdir)) v07r_abort("missing regular file: %s", path)
  out <- if (nzchar(Sys.which("shasum"))) {
    v07r_system("shasum", c("-a", "256", shQuote(path)))
  } else if (nzchar(Sys.which("sha256sum"))) {
    v07r_system("sha256sum", shQuote(path))
  } else v07r_abort("no SHA-256 command is available")
  hash <- strsplit(out[[1L]], "[[:space:]]+")[[1L]][[1L]]
  if (!v07r_hex64(hash)) v07r_abort("invalid SHA-256 output")
  hash
}

v07r_verify_pair <- function(path) {
  sidecar <- paste0(path, ".sha256")
  if (!file.exists(path) || !file.exists(sidecar)) v07r_abort("missing/orphan file pair: %s", path)
  expected <- sprintf("%s  %s", v07r_sha256(path), basename(path))
  if (!identical(readLines(sidecar, warn = FALSE), expected)) v07r_abort("sidecar mismatch: %s", path)
  invisible(TRUE)
}

v07r_read_tsv <- function(path, columns = NULL) {
  v07r_verify_pair(path)
  x <- utils::read.delim(path, sep = "\t", quote = "", comment.char = "",
    stringsAsFactors = FALSE, check.names = FALSE, na.strings = c("NA", "NaN"))
  if (!is.null(columns) && !identical(names(x), columns)) v07r_abort("schema drift in %s", path)
  x
}

v07r_format <- function(x) {
  if (length(x) != 1L) v07r_abort("non-scalar TSV field")
  if (is.na(x)) return("NA")
  if (is.logical(x)) return(if (x) "true" else "false")
  if (is.numeric(x)) {
    if (is.nan(x)) return("NaN")
    if (is.infinite(x)) return(if (x > 0) "Inf" else "-Inf")
    return(sprintf("%.17g", x))
  }
  out <- enc2utf8(as.character(x)); if (grepl("[\t\r\n]", out)) v07r_abort("invalid TSV string")
  out
}

v07r_tsv_text <- function(x) {
  rows <- if (!nrow(x)) character() else vapply(seq_len(nrow(x)), function(i) {
    paste(vapply(x[i, , drop = FALSE], v07r_format, character(1L)), collapse = "\t")
  }, character(1L))
  paste0(paste(c(paste(names(x), collapse = "\t"), rows), collapse = "\n"), "\n")
}

v07r_hardlink_once <- function(path, bytes) {
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  if (file.exists(path)) v07r_abort("create-once path exists: %s", path)
  tmp <- tempfile(".v07r-", tmpdir = dirname(path)); con <- file(tmp, "wb"); closed <- FALSE
  on.exit({ if (!closed) close(con); unlink(tmp) })
  writeBin(bytes, con); close(con); closed <- TRUE
  if (!file.link(tmp, path)) v07r_abort("exclusive hard-link claim failed: %s", path)
  unlink(tmp); invisible(path)
}

v07r_write_once <- function(path, text) {
  if (file.exists(path) || file.exists(paste0(path, ".sha256"))) v07r_abort("create-once output exists")
  v07r_hardlink_once(path, charToRaw(enc2utf8(text)))
  digest <- v07r_sha256(path)
  v07r_hardlink_once(paste0(path, ".sha256"),
    charToRaw(sprintf("%s  %s\n", digest, basename(path))))
  invisible(digest)
}

v07r_bool <- function(x, field) {
  token <- tolower(as.character(x)); if (any(!token %in% c("true", "false"))) v07r_abort("%s is not Boolean", field)
  token == "true"
}

v07r_num <- function(x, field) {
  y <- suppressWarnings(as.numeric(x)); if (any(is.na(y) & !is.na(x))) v07r_abort("%s is nonnumeric", field)
  y
}

v07r_packet_dir <- function(out_dir, tier, cell_id, seed) {
  file.path(out_dir, "packets", tier, cell_id, sprintf("%d", as.integer(seed)))
}

v07r_assert_real_child <- function(path, root, label) {
  real_root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  real_path <- normalizePath(path, winslash = "/", mustWork = TRUE)
  if (!startsWith(paste0(real_path, "/"), paste0(real_root, "/")) || nzchar(Sys.readlink(path))) {
    v07r_abort("%s escapes the real output tree or is a symlink", label)
  }
  invisible(real_path)
}

v07r_validate_packet <- function(out_dir, tier, manifest_row, attempt_row) {
  root <- v07r_packet_dir(out_dir, tier, manifest_row$cell_id, manifest_row$seed)
  v07r_assert_real_child(root, out_dir, "packet directory")
  exact <- sort(c(v07r_packet_primaries, paste0(v07r_packet_primaries, ".sha256")))
  if (!identical(sort(list.files(root, all.files = TRUE, no.. = TRUE)), exact)) {
    v07r_abort("packet file set drift for %s/%s", manifest_row$cell_id, manifest_row$seed)
  }
  invisible(lapply(file.path(root, v07r_packet_primaries), v07r_verify_pair))
  lock <- v07r_read_tsv(file.path(root, "packet_files_lock.tsv"), c("file", "sha256"))
  data_files <- v07r_packet_primaries[1:4]
  hashes <- unname(vapply(file.path(root, data_files), v07r_sha256, character(1L)))
  if (!identical(as.character(lock$file), data_files) || !identical(as.character(lock$sha256), hashes)) {
    v07r_abort("packet lock mismatch")
  }

  markers <- v07r_read_tsv(file.path(root, "markers.tsv"))
  ids <- v07r_read_tsv(file.path(root, "ids.tsv"), c("index", "id"))
  phenotype <- v07r_read_tsv(file.path(root, "phenotype.tsv"), c("index", "id", "y"))
  truth <- v07r_read_tsv(file.path(root, "truth.tsv"), v07r_truth_columns)
  if (nrow(truth) != 1L) v07r_abort("truth packet must have one row")
  n <- as.integer(manifest_row$n)
  marker_names <- names(markers)[-1L]
  if (!identical(names(markers)[[1L]], "id") || !length(marker_names) ||
      anyDuplicated(marker_names) || any(!nzchar(marker_names)) ||
      any(!grepl("^m[0-9]{6}$", marker_names)) ||
      nrow(markers) != n || nrow(ids) != n || nrow(phenotype) != n || ncol(markers) < 2L) {
    v07r_abort("packet dimensions disagree with manifest")
  }
  if (!identical(as.integer(ids$index), seq_len(n)) ||
      !identical(as.integer(phenotype$index), seq_len(n)) ||
      !identical(as.character(markers[[1L]]), as.character(ids$id)) ||
      !identical(as.character(phenotype$id), as.character(ids$id)) ||
      anyDuplicated(ids$id) || anyNA(ids$id)) v07r_abort("packet ID/order alignment failed")
  y <- v07r_num(phenotype$y, "phenotype y"); if (any(!is.finite(y))) v07r_abort("nonfinite phenotype")
  M <- as.matrix(markers[-1L]); storage.mode(M) <- "numeric"
  if (any(!is.finite(M)) || any(!M %in% c(0, 1, 2))) v07r_abort("invalid marker dosage")
  if (any(apply(M, 2L, function(z) length(unique(z)) <= 1L))) v07r_abort("retained marker is monomorphic")
  p <- colMeans(M) / 2; k <- 2 * sum(p * (1 - p))
  if (!is.finite(k) || k <= 0) v07r_abort("nonpositive VanRaden denominator")
  W <- sweep(M, 2L, 2 * p, "-"); K <- tcrossprod(W) / k + v07r_ridge * diag(n)
  if (max(abs(K - t(K))) > 1e-12 || inherits(try(chol(K), silent = TRUE), "try-error")) {
    v07r_abort("reconstructed K is not symmetric positive definite")
  }
  Q <- solve(K); qk_error <- max(abs(Q %*% K - diag(n)))
  if (!is.finite(qk_error) || qk_error > v07r_qk_tolerance) v07r_abort("reconstructed QK identity failed")

  fields <- c("cell_id", "seed", "n", "truth_sigma_g2", "truth_sigma_e2", "truth_ratio", "ridge")
  for (field in fields) if (!identical(as.character(truth[[field]]), as.character(manifest_row[[field]]))) {
    v07r_abort("packet truth/manifest mismatch in %s", field)
  }
  if (as.integer(truth$requested_m) != as.integer(manifest_row$m) ||
      as.integer(truth$retained_m) != ncol(M) ||
      abs(as.numeric(truth$scale_denominator) - k) > 1e-12 ||
      (identical(as.character(attempt_row$status), "success") &&
        abs(as.numeric(attempt_row$scale_denominator) - k) > 1e-12)) {
    v07r_abort("packet construction/truth mismatch")
  }
  invisible(list(p = p, k = k, K = K, Q = Q, qk_error = qk_error))
}

v07r_attempt_path <- function(out_dir, tier, cell_id, seed) {
  file.path(out_dir, "attempts", tier, cell_id, sprintf("%d.tsv", as.integer(seed)))
}

v07r_validate_manifest <- function(manifest, tier) {
  if (any(manifest$tier != tier)) v07r_abort("manifest tier drift")
  counts <- table(factor(manifest$cell_id, levels = v07r_expected_cells))
  if (any(counts == 0L) || (tier == "pilot" && any(counts != 48L)) ||
      (tier == "confirm" && any(counts < 200L | counts > 2000L))) {
    v07r_abort("manifest cell denominator drift")
  }
  expected_cell <- rep(v07r_expected_cells, times = as.integer(counts))
  if (!identical(as.character(manifest$cell_id), expected_cell)) v07r_abort("manifest cell/order drift")
  cell_match <- match(manifest$cell_id, v07r_cells$cell_id)
  expected_offset <- unlist(lapply(as.integer(counts), function(n) {
    if (tier == "pilot") 7001:7048 else 8001:(8000L + n)
  }), use.names = FALSE)
  numeric <- c("cell_index", "seed_offset", "seed", "n", "m", "truth_sigma_g2",
    "truth_sigma_e2", "truth_ratio", "ridge")
  for (field in numeric) manifest[[field]] <- v07r_num(manifest[[field]], field)
  if (!identical(as.integer(manifest$cell_index), v07r_cells$cell_index[cell_match]) ||
      !identical(as.integer(manifest$seed_offset), as.integer(expected_offset)) ||
      !identical(as.numeric(manifest$seed),
        v07r_seed_base + 10000 * manifest$cell_index + manifest$seed_offset) ||
      !identical(as.integer(manifest$n), v07r_cells$n[cell_match]) ||
      !identical(as.integer(manifest$m), v07r_cells$m[cell_match]) ||
      any(abs(manifest$truth_sigma_g2 - v07r_cells$truth_sigma_g2[cell_match]) > 0) ||
      any(abs(manifest$truth_sigma_e2 - v07r_cells$truth_sigma_e2[cell_match]) > 0) ||
      any(abs(manifest$truth_ratio - v07r_cells$truth_ratio[cell_match]) > 0) ||
      any(manifest$ridge != v07r_ridge) || anyDuplicated(manifest$seed)) {
    v07r_abort("manifest scientific/seed contract drift")
  }
  manifest
}

v07r_validate_seal <- function(out_dir) {
  path <- file.path(out_dir, "campaign_seal.tsv")
  seal <- v07r_read_tsv(path, c("key", "value"))
  if (anyDuplicated(seal$key)) v07r_abort("duplicate campaign seal key")
  values <- stats::setNames(as.character(seal$value), seal$key)
  required <- c("schema_version", "r_auto_route_commit", "julia_candidate_commit",
    "relationship_method", "allele_frequency_source", "relationship_scale", "ridge",
    "boundary_epsilon", "driver_commit", "julia_execution_commit",
    "r_selected_tree", "julia_selected_tree", "r_recomputer_sha256",
    "julia_recomputer_sha256", "output_absent_before_seal")
  if (any(!required %in% names(values)) ||
      !identical(values[["schema_version"]], v07r_schema) ||
      !identical(values[["r_auto_route_commit"]], v07r_r_implementation) ||
      !identical(values[["julia_candidate_commit"]], v07r_julia_implementation) ||
      !identical(values[["relationship_method"]], "vanraden1") ||
      !identical(values[["allele_frequency_source"]], "sample") ||
      !identical(values[["relationship_scale"]], "K_lambda") ||
      as.numeric(values[["ridge"]]) != v07r_ridge ||
      as.numeric(values[["boundary_epsilon"]]) != v07r_boundary_epsilon ||
      any(!grepl("^[0-9a-f]{40}$", values[c("driver_commit", "julia_execution_commit",
        "r_selected_tree", "julia_selected_tree")])) ||
      any(!grepl("^[0-9a-f]{64}$", values[c("r_recomputer_sha256",
        "julia_recomputer_sha256")])) ||
      !identical(values[["output_absent_before_seal"]], "true")) {
    v07r_abort("campaign seal contract drift")
  }
  list(values = values, sha256 = v07r_sha256(path))
}

v07r_read_campaign <- function(out_dir, tier) {
  if (!tier %in% c("pilot", "confirm")) v07r_abort("tier must be pilot or confirm")
  seal <- v07r_validate_seal(out_dir)
  manifest <- v07r_read_tsv(file.path(out_dir, paste0(tier, "_manifest.tsv")), v07r_manifest_columns)
  manifest <- v07r_validate_manifest(manifest, tier)
  key <- paste(manifest$cell_id, manifest$seed, sep = "\r")
  if (anyDuplicated(key)) v07r_abort("duplicate manifest key")
  paths <- vapply(seq_len(nrow(manifest)), function(i) {
    v07r_attempt_path(out_dir, tier, manifest$cell_id[[i]], manifest$seed[[i]])
  }, character(1L))
  actual <- sort(list.files(file.path(out_dir, "attempts", tier), "\\.tsv$", recursive = TRUE, full.names = TRUE))
  if (!all(file.exists(paths)) || !identical(sort(normalizePath(paths)), sort(normalizePath(actual)))) {
    v07r_abort("attempt file set differs from manifest")
  }
  sidecars <- sort(list.files(file.path(out_dir, "attempts", tier), "\\.tsv\\.sha256$", recursive = TRUE, full.names = TRUE))
  if (!identical(sidecars, sort(paste0(actual, ".sha256")))) v07r_abort("attempt sidecar set drift")
  packet_tier <- file.path(out_dir, "packets", tier)
  expected_cell_dirs <- file.path(packet_tier, v07r_expected_cells)
  actual_cell_dirs <- sort(list.dirs(packet_tier, recursive = FALSE, full.names = TRUE))
  if (!identical(sort(expected_cell_dirs), actual_cell_dirs) || any(nzchar(Sys.readlink(actual_cell_dirs)))) {
    v07r_abort("packet cell directory set/path drift")
  }
  expected_packet_dirs <- vapply(seq_len(nrow(manifest)), function(i) {
    v07r_packet_dir(out_dir, tier, manifest$cell_id[[i]], manifest$seed[[i]])
  }, character(1L))
  actual_packet_dirs <- sort(unlist(lapply(actual_cell_dirs, list.dirs,
    recursive = FALSE, full.names = TRUE), use.names = FALSE))
  if (!identical(sort(expected_packet_dirs), actual_packet_dirs) || any(nzchar(Sys.readlink(actual_packet_dirs)))) {
    v07r_abort("packet seed directory set/path drift")
  }
  rows <- lapply(paths, v07r_read_tsv, columns = v07r_attempt_columns)
  if (any(vapply(rows, nrow, integer(1L)) != 1L)) v07r_abort("attempt file is not one row")
  attempts <- do.call(rbind, rows); rownames(attempts) <- NULL
  akey <- paste(attempts$cell_id, attempts$seed, sep = "\r")
  if (!identical(akey, key)) v07r_abort("attempt order/key differs from manifest")
  shared <- c("tier", "cell_id", "cell_index", "seed_offset", "seed", "n", "m",
    "truth_sigma_g2", "truth_sigma_e2", "truth_ratio", "ridge")
  for (field in shared) if (!identical(as.character(attempts[[field]]), as.character(manifest[[field]]))) {
    v07r_abort("attempt/manifest mismatch in %s", field)
  }
  attempts$attempted <- v07r_bool(attempts$attempted, "attempted")
  attempts$converged <- v07r_bool(attempts$converged, "converged")
  if (any(!attempts$attempted)) v07r_abort("attempted denominator was altered")
  if (any(attempts$route != "ordinary_auto_genomic") ||
      any(attempts$r_implementation_commit != v07r_r_implementation) ||
      any(attempts$julia_implementation_commit != v07r_julia_implementation) ||
      any(attempts$driver_commit != seal$values[["driver_commit"]]) ||
      any(attempts$seal_sha256 != seal$sha256)) v07r_abort("attempt route/implementation/seal binding drift")
  numeric <- c("truth_sigma_g2", "truth_sigma_e2", "truth_ratio", "ridge",
    "scientific_sigma_g2", "scientific_sigma_e2", "scientific_ratio", "profile_t_hat",
    "numerical_sigma_g2", "numerical_sigma_e2", "numerical_ratio", "profile_loglik",
    "lower_derivative_per_observation", "upper_derivative_per_observation", "scale_denominator")
  for (field in numeric) attempts[[field]] <- v07r_num(attempts[[field]], field)
  good <- attempts$status == "success"
  if (any(good != attempts$converged)) v07r_abort("success/convergence mismatch")
  if (any(good & attempts$error_class != "none") || any(!good & attempts$error_class == "none")) {
    v07r_abort("status/error-class mismatch")
  }
  if (any(good & !attempts$boundary_status %in% v07r_resolved) ||
      any(good & attempts$boundary_reason != unname(v07r_reason[attempts$boundary_status])) ||
      any(good & attempts$boundary_epsilon != v07r_boundary_epsilon)) v07r_abort("boundary metadata mismatch")
  lower <- good & attempts$boundary_status == "boundary_lower"
  upper <- good & attempts$boundary_status == "boundary_upper"
  interior <- good & attempts$boundary_status %in% c("interior", "interior_rescued")
  if (any(attempts$scientific_ratio[lower] != 0) ||
      any(attempts$numerical_ratio[lower] != v07r_boundary_epsilon) ||
      any(attempts$scientific_ratio[upper] != 1) ||
      any(attempts$numerical_ratio[upper] != 1 - v07r_boundary_epsilon) ||
      any(attempts$scientific_ratio[interior] <= 0 | attempts$scientific_ratio[interior] >= 1)) {
    v07r_abort("status-specific endpoint ratio mismatch")
  }
  evidence <- is.finite(attempts$profile_loglik) &
    is.finite(attempts$lower_derivative_per_observation) &
    is.finite(attempts$upper_derivative_per_observation)
  if (any(good & !evidence)) v07r_abort("nonfinite boundary evidence")
  t_hat <- attempts$numerical_sigma_g2 + attempts$numerical_sigma_e2
  derived_g <- attempts$scientific_ratio * t_hat
  derived_e <- (1 - attempts$scientific_ratio) * t_hat
  if (any(good & (!is.finite(t_hat) | t_hat < 0)) ||
      any(good & abs(attempts$profile_t_hat - t_hat) > 1e-12) ||
      any(good & abs(attempts$scientific_sigma_g2 - derived_g) > 1e-12) ||
      any(good & abs(attempts$scientific_sigma_e2 - derived_e) > 1e-12)) {
    v07r_abort("scientific endpoint derivation mismatch")
  }
  for (field in c("marker_hash", "id_hash", "kernel_hash", "precision_hash")) {
    if (any(good & !vapply(attempts[[field]], v07r_hex64, logical(1L)))) v07r_abort("invalid %s", field)
  }
  for (i in seq_len(nrow(manifest))) v07r_validate_packet(out_dir, tier, manifest[i, ], attempts[i, ])
  list(manifest = manifest, attempts = attempts)
}

v07r_wilson <- function(k, n) {
  z <- stats::qnorm(0.975); p <- k / n; d <- 1 + z^2 / n
  center <- (p + z^2 / (2 * n)) / d
  half <- z * sqrt(p * (1 - p) / n + z^2 / (4 * n^2)) / d
  c(center - half, center + half)
}

v07r_failure_classes <- function(x) {
  z <- sort(table(x)); paste(sprintf("%s=%d", names(z), as.integer(z)), collapse = ";")
}

v07r_summary <- function(manifest, attempts, tier) {
  specs <- list(
    list("sigma_g2", "scientific_sigma_g2", "truth_sigma_g2", function(x) 0.05 * x),
    list("sigma_e2", "scientific_sigma_e2", "truth_sigma_e2", function(x) 0.05 * x),
    list("ratio", "scientific_ratio", "truth_ratio", function(x) 0.02)
  )
  output <- list(); at <- 0L
  for (cell in unique(manifest$cell_id)) {
    cr <- attempts[attempts$cell_id == cell, , drop = FALSE]
    cm <- manifest[manifest$cell_id == cell, , drop = FALSE]
    good <- cr$converged; natt <- nrow(cm); nconv <- sum(good); rate <- nconv / natt
    wilson <- v07r_wilson(nconv, natt); targets <- list()
    for (j in seq_along(specs)) {
      spec <- specs[[j]]; values <- cr[[spec[[2L]]]][good]; truth <- unique(cr[[spec[[3L]]]])
      if (length(truth) != 1L) v07r_abort("truth mutation within cell")
      margin <- spec[[4L]](truth); mean_est <- bias <- mcse <- s_upper <- lo <- hi <- NA_real_
      required_raw <- Inf; pass <- FALSE
      if (length(values) >= 2L && all(is.finite(values))) {
        mean_est <- mean(values); bias <- mean_est - truth; s <- stats::sd(values); mcse <- s / sqrt(length(values))
        if (tier == "pilot") {
          s_upper <- s * sqrt((length(values) - 1) / stats::qchisq(0.05, length(values) - 1))
          required_raw <- ceiling((stats::qnorm(0.975) * s_upper / (margin / 2))^2)
        } else {
          critical <- stats::qt(0.975, length(values) - 1); lo <- bias - critical * mcse; hi <- bias + critical * mcse
          pass <- lo > -margin && hi < margin; required_raw <- 0
        }
      }
      targets[[j]] <- data.frame(target = spec[[1L]], truth = truth, mean_estimate = mean_est,
        bias = bias, mcse = mcse, pilot_sd_upper = s_upper, bias_ci_lower = lo,
        bias_ci_upper = hi, margin = margin, target_pass = pass,
        required_n_raw = required_raw, stringsAsFactors = FALSE)
    }
    targets <- do.call(rbind, targets); raw_max <- max(targets$required_n_raw)
    required_n <- if (is.finite(raw_max)) max(200, raw_max) else Inf
    status <- if (tier == "pilot" && nconv < 46L) "STOP_LOW_PILOT_CONVERGENCE" else
      if (tier == "pilot" && required_n > 2000) "PRECISION_BLOCKER" else
      if (tier == "pilot") "CONFIRMATION_ELIGIBLE" else
      if (all(targets$target_pass) && rate >= 0.95 && wilson[[1L]] >= 0.90) "PASS" else "FAIL"
    common <- data.frame(tier = tier, cell_id = cell, n_expected = nrow(cm),
      n_attempted = natt, n_converged = nconv, n_bias_rows = nconv,
      n_interior = sum(good & cr$boundary_status == "interior", na.rm = TRUE),
      n_interior_rescued = sum(good & cr$boundary_status == "interior_rescued", na.rm = TRUE),
      n_boundary_lower = sum(good & cr$boundary_status == "boundary_lower", na.rm = TRUE),
      n_boundary_upper = sum(good & cr$boundary_status == "boundary_upper", na.rm = TRUE),
      n_unresolved = sum(cr$boundary_status == "boundary_unresolved", na.rm = TRUE),
      n_error = sum(!good & (is.na(cr$boundary_status) | cr$boundary_status != "boundary_unresolved")),
      n_resolved_valid = nconv,
      convergence_rate = rate, wilson_lower = wilson[[1L]], wilson_upper = wilson[[2L]],
      stringsAsFactors = FALSE)
    classified <- sum(common[1L, c("n_interior", "n_interior_rescued", "n_boundary_lower",
      "n_boundary_upper", "n_unresolved", "n_error")])
    if (classified != natt) v07r_abort("status breakdown does not equal attempted denominator")
    tail <- data.frame(required_n = required_n, cell_status = status, campaign_status = NA_character_,
      failure_classes = v07r_failure_classes(cr$error_class), stringsAsFactors = FALSE)
    at <- at + 1L; output[[at]] <- cbind(common[rep(1L, 3L), ], targets, tail[rep(1L, 3L), ])
  }
  ans <- do.call(rbind, output); rownames(ans) <- NULL
  cell_status <- unique(ans[c("cell_id", "cell_status")])$cell_status
  campaign_status <- if (tier == "pilot" && any(cell_status == "STOP_LOW_PILOT_CONVERGENCE")) {
    "STOP_LOW_PILOT_CONVERGENCE"
  } else if (tier == "pilot" && any(cell_status == "PRECISION_BLOCKER")) {
    "PRECISION_BLOCKER"
  } else if (tier == "pilot") {
    "CONFIRMATION_ELIGIBLE"
  } else if (all(cell_status == "PASS")) {
    "PASS"
  } else "FAIL"
  ans$campaign_status <- campaign_status
  ans[v07r_summary_columns]
}

v07r_equal_numeric <- function(a, b, tolerance) {
  missing <- is.na(a) == is.na(b)
  equal <- is.na(a) | (is.finite(a) & is.finite(b) & abs(a - b) <= tolerance) |
    (is.infinite(a) & is.infinite(b) & sign(a) == sign(b))
  all(missing & equal)
}

v07r_compare <- function(x, y, tolerance = 1e-10) {
  if (!identical(names(x), v07r_summary_columns) || !identical(names(y), v07r_summary_columns)) v07r_abort("summary schema drift")
  key <- function(z) paste(z$tier, z$cell_id, z$target, sep = "\r")
  if (!identical(sort(key(x)), sort(key(y)))) v07r_abort("summary key mismatch")
  y <- y[match(key(x), key(y)), , drop = FALSE]
  numeric <- c("n_expected", "n_attempted", "n_converged", "n_bias_rows", "convergence_rate",
    "n_interior", "n_interior_rescued", "n_boundary_lower", "n_boundary_upper",
    "n_unresolved", "n_error", "n_resolved_valid",
    "wilson_lower", "wilson_upper", "truth", "mean_estimate", "bias", "mcse",
    "pilot_sd_upper", "bias_ci_lower", "bias_ci_upper", "margin", "required_n_raw", "required_n")
  for (field in numeric) if (!v07r_equal_numeric(as.numeric(x[[field]]), as.numeric(y[[field]]), tolerance)) {
    v07r_abort("summary mismatch in %s", field)
  }
  for (field in setdiff(v07r_summary_columns, numeric)) {
    if (!identical(as.character(x[[field]]), as.character(y[[field]]))) v07r_abort("summary mismatch in %s", field)
  }
  invisible(TRUE)
}

v07r_recompute <- function(out_dir, tier) {
  campaign <- v07r_read_campaign(out_dir, tier)
  summary <- v07r_summary(campaign$manifest, campaign$attempts, tier)
  path <- file.path(out_dir, paste0(tier, "_summary_base_r.tsv"))
  v07r_write_once(path, v07r_tsv_text(summary))
  message(sprintf("independent base-R %s recomputation: PASS (%d rows)", tier, nrow(summary)))
  invisible(summary)
}

v07r_verify_summary <- function(out_dir, tier) {
  campaign <- v07r_read_campaign(out_dir, tier)
  expected <- v07r_summary(campaign$manifest, campaign$attempts, tier)
  observed <- v07r_read_tsv(file.path(out_dir, paste0(tier, "_summary_base_r.tsv")), v07r_summary_columns)
  v07r_compare(expected, observed); invisible(expected)
}

v07r_selftest <- function() {
  stopifnot(abs(v07r_wilson(48, 48)[[1L]] - 0.9258998703338824) < 1e-12)
  s_upper <- 1 * sqrt(47 / stats::qchisq(0.05, 47))
  stopifnot(abs(s_upper - 1.206883783222356) < 1e-12)
  root <- tempfile("v07r-selftest-"); dir.create(root); on.exit(unlink(root, recursive = TRUE))
  path <- file.path(root, "once.tsv"); v07r_write_once(path, "x\n"); v07r_verify_pair(path)
  stopifnot(inherits(try(v07r_write_once(path, "y\n"), silent = TRUE), "try-error"))
  message("v0.7 recovery-v2 independent base-R recomputer selftest: PASS")
  invisible(TRUE)
}

v07r_main <- function(args = commandArgs(trailingOnly = TRUE)) {
  mode <- v07r_option(args, "mode", "recompute")
  if (mode == "selftest") return(v07r_selftest())
  out_dir <- v07r_option(args, "out-dir"); tier <- v07r_option(args, "tier")
  if (is.null(out_dir) || is.null(tier)) v07r_abort("out-dir and tier are required")
  if (mode == "recompute") return(v07r_recompute(out_dir, tier))
  if (mode == "verify") return(v07r_verify_summary(out_dir, tier))
  if (mode == "compare") {
    other <- v07r_option(args, "other-summary"); if (is.null(other)) v07r_abort("other-summary is required")
    lhs <- v07r_read_tsv(file.path(out_dir, paste0(tier, "_summary_base_r.tsv")), v07r_summary_columns)
    rhs <- v07r_read_tsv(other, v07r_summary_columns); return(v07r_compare(lhs, rhs))
  }
  v07r_abort("unknown mode: %s", mode)
}

if (sys.nframe() == 0L) v07r_main()
