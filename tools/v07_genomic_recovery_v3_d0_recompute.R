#!/usr/bin/env Rscript

# Independent base-R D0 spectral replay for recovery-v3. This source-safe tool
# does not load hsquared, source a campaign driver, or fit any phenotype.

v07d_fixed_hashes <- c(
  pilot_manifest.tsv = "1264e87eeea10bf8dd9d6197a0f2ef865a2cd541e085bde22a655730ef894f61",
  pilot_corpus_lock.tsv = "04f128168747aecab4847848de4498ebfb6efdf4aafb742d2e6f828e0d15c084",
  campaign_seal.tsv = "4a921c039426faa400648752ec59bd3f049939098ec4f42b6faafc9e845b324c"
)
v07d_manifest_columns <- c(
  "tier",
  "cell_id",
  "cell_index",
  "seed_offset",
  "seed",
  "n",
  "m",
  "truth_sigma_g2",
  "truth_sigma_e2",
  "truth_ratio",
  "ridge",
  "regime"
)
v07d_attempt_columns <- c(
  "tier",
  "cell_id",
  "cell_index",
  "seed_offset",
  "seed",
  "n",
  "m",
  "truth_sigma_g2",
  "truth_sigma_e2",
  "truth_ratio",
  "ridge",
  "attempted",
  "status",
  "error_class",
  "converged",
  "boundary_status",
  "boundary_reason",
  "boundary_epsilon",
  "scientific_sigma_g2",
  "scientific_sigma_e2",
  "scientific_ratio",
  "fitted_total_variance",
  "numerical_sigma_g2",
  "numerical_sigma_e2",
  "numerical_ratio",
  "profile_loglik",
  "lower_derivative_per_observation",
  "upper_derivative_per_observation",
  "iterations",
  "objective",
  "gradient_norm",
  "runtime_seconds",
  "peak_rss_mb",
  "relationship_source",
  "relationship_method",
  "allele_frequency_source",
  "relationship_scale",
  "scale_denominator",
  "marker_hash",
  "id_hash",
  "kernel_hash",
  "precision_hash",
  "route",
  "r_implementation_commit",
  "julia_implementation_commit",
  "driver_commit",
  "seal_sha256"
)
v07d_truth_columns <- c(
  "cell_id",
  "seed",
  "n",
  "requested_m",
  "retained_m",
  "truth_sigma_g2",
  "truth_sigma_e2",
  "truth_ratio",
  "ridge",
  "scale_denominator"
)
v07d_packet_primaries <- c(
  "markers.tsv",
  "ids.tsv",
  "phenotype.tsv",
  "truth.tsv",
  "packet_files_lock.tsv"
)
v07d_eigen_columns <- c("cell_id", "seed", "eigen_index", "eigenvalue")
v07d_diagnostic_columns <- c(
  "cell_id",
  "cell_index",
  "seed",
  "n",
  "m",
  "truth_ratio",
  "retained_m",
  "ridge",
  "scale_denominator",
  "marker_hash",
  "id_hash",
  "kernel_hash",
  "precision_hash",
  "k_replay_max_abs",
  "qk_max_abs",
  "eigen_min",
  "eigen_max",
  "eigen_mean",
  "eigen_sd_population",
  "eigen_cv_population",
  "effective_rank",
  "information_r020",
  "se_info_r020",
  "information_r050",
  "se_info_r050",
  "information_r080",
  "se_info_r080",
  "scientific_ratio",
  "absolute_ratio_error",
  "boundary_status",
  "predicted_lower_probability",
  "predicted_upper_probability"
)
v07d_native_hash_columns <- c(
  "cell_id",
  "seed",
  "marker_hash_base_r",
  "id_hash_base_r",
  "kernel_hash_base_r",
  "precision_hash_base_r"
)
v07d_summary_columns <- c(
  "cell_id",
  "bootstrap_sha256",
  "cell_index",
  "n",
  "m",
  "truth_ratio",
  "n_packets",
  "empirical_sd_ratio",
  "rms_se_info",
  "c_c",
  "c_c_bootstrap_lower",
  "c_c_bootstrap_upper",
  "spearman_se_info_abs_error",
  "mean_predicted_lower_probability",
  "mean_predicted_upper_probability",
  "observed_lower_count",
  "observed_upper_count",
  "observed_lower_proportion",
  "observed_upper_proportion",
  "observed_lower_mcse",
  "observed_upper_mcse",
  "mean_spectral_cv",
  "mean_effective_rank"
)
v07d_bootstrap_columns <- c(
  "cell_id",
  "bootstrap_rep",
  sprintf("index_%02d", seq_len(48L))
)
v07d_cells <- data.frame(
  cell_id = c(
    "n120_m600_r020",
    "n120_m600_r050",
    "n120_m600_r080",
    "n300_m150_r020",
    "n300_m150_r050",
    "n300_m150_r080",
    "n300_m1000_r020",
    "n300_m1000_r050",
    "n300_m1000_r080"
  ),
  cell_index = seq_len(9L),
  n = rep(c(120, 300, 300), each = 3L),
  m = rep(c(600, 150, 1000), each = 3L),
  truth_ratio = rep(c(0.2, 0.5, 0.8), 3L),
  stringsAsFactors = FALSE
)
v07d_ridge <- 0.01
v07d_qk_tolerance <- 1e-10
v07d_replay_tolerance <- 1e-10

v07d_abort <- function(...) stop(sprintf(...), call. = FALSE)
v07d_hex64 <- function(x) {
  length(x) == 1L && !is.na(x) && grepl("^[0-9a-f]{64}$", x)
}
v07d_is_symlink <- function(path) {
  link <- Sys.readlink(path)
  !is.na(link) && nzchar(link)
}

v07d_has_symlink_component <- function(path) {
  current <- path.expand(path)
  if (!startsWith(current, "/")) {
    current <- file.path(getwd(), current)
  }
  repeat {
    if (v07d_is_symlink(current)) {
      return(TRUE)
    }
    parent <- dirname(current)
    if (identical(parent, current)) {
      break
    }
    current <- parent
  }
  FALSE
}

v07d_is_regular_file <- function(path) {
  test_command <- Sys.which("test")
  if (!nzchar(test_command)) {
    v07d_abort("POSIX test command is required for regular-file admission")
  }
  vapply(
    path,
    function(value) {
      status <- suppressWarnings(system2(
        test_command,
        c("-f", shQuote(value)),
        stdout = FALSE,
        stderr = FALSE
      ))
      identical(as.integer(status), 0L)
    },
    logical(1L),
    USE.NAMES = FALSE
  )
}

v07d_real_dir <- function(path, label) {
  if (!dir.exists(path) || v07d_has_symlink_component(path)) {
    v07d_abort("%s must be an existing real directory", label)
  }
  normalizePath(path, winslash = "/", mustWork = TRUE)
}

v07d_require_separate_roots <- function(input_root, output_root) {
  input <- paste0(v07d_real_dir(input_root, "D0 corpus root"), "/")
  output <- paste0(v07d_real_dir(output_root, "D0 output root"), "/")
  if (
    identical(input, output) ||
      startsWith(input, output) ||
      startsWith(output, input)
  ) {
    v07d_abort("D0 corpus and output roots must be separate and non-nested")
  }
  invisible(c(
    input_root = sub("/$", "", input),
    output_root = sub("/$", "", output)
  ))
}

v07d_option <- function(args, key, default = NULL) {
  prefix <- paste0("--", key, "=")
  hit <- args[startsWith(args, prefix)]
  if (!length(hit)) {
    return(default)
  }
  if (length(hit) != 1L) {
    v07d_abort("option --%s must occur exactly once", key)
  }
  sub(prefix, "", hit[[1L]], fixed = TRUE)
}

v07d_system <- function(command, args) {
  out <- system2(command, args, stdout = TRUE, stderr = TRUE)
  status <- attr(out, "status")
  if (is.null(status)) {
    status <- 0L
  }
  if (status != 0L) {
    v07d_abort("command failed: %s", paste(out, collapse = "\n"))
  }
  out
}

v07d_sha256 <- function(path) {
  if (!file.exists(path) || isTRUE(file.info(path)$isdir)) {
    v07d_abort("missing regular file: %s", path)
  }
  out <- if (nzchar(Sys.which("shasum"))) {
    v07d_system("shasum", c("-a", "256", shQuote(path)))
  } else if (nzchar(Sys.which("sha256sum"))) {
    v07d_system("sha256sum", shQuote(path))
  } else {
    v07d_abort("no SHA-256 command is available")
  }
  hash <- strsplit(out[[1L]], "[[:space:]]+")[[1L]][[1L]]
  if (!v07d_hex64(hash)) {
    v07d_abort("invalid SHA-256 output for %s", path)
  }
  hash
}

v07d_sha256_raw <- function(bytes) {
  if (!is.raw(bytes)) {
    v07d_abort("SHA-256 preimage must be raw")
  }
  path <- tempfile("v07d-sha256-")
  on.exit(unlink(path), add = TRUE)
  con <- file(path, open = "wb")
  writeBin(bytes, con)
  close(con)
  v07d_sha256(path)
}

v07d_u64_raw <- function(value) {
  if (
    length(value) != 1L ||
      !is.finite(value) ||
      value < 0 ||
      value != floor(value) ||
      value > 2^53
  ) {
    v07d_abort("cannot canonically encode a non-UInt64-sized value")
  }
  out <- raw(8L)
  for (index in seq_len(8L)) {
    out[[index]] <- as.raw(value %% 256)
    value <- floor(value / 256)
  }
  out
}

v07d_string_raw <- function(value) {
  if (length(value) != 1L || is.na(value)) {
    v07d_abort("cannot canonically encode a missing or non-scalar string")
  }
  bytes <- charToRaw(enc2utf8(as.character(value)))
  c(v07d_u64_raw(length(bytes)), bytes)
}

v07d_strings_raw <- function(values) {
  values <- as.character(values)
  if (anyNA(values)) {
    v07d_abort("cannot canonically encode missing strings")
  }
  c(
    v07d_u64_raw(length(values)),
    unlist(lapply(values, v07d_string_raw), use.names = FALSE)
  )
}

v07d_float64_raw <- function(values) {
  values <- as.numeric(values)
  if (any(!is.finite(values))) {
    v07d_abort("cannot canonically encode non-finite Float64 values")
  }
  values[values == 0] <- 0
  writeBin(values, raw(), size = 8L, endian = "little")
}

v07d_provenance_prefix <- function(kind) {
  c(
    charToRaw("HSquared-provenance-v1"),
    as.raw(0),
    charToRaw(enc2utf8(kind)),
    as.raw(0)
  )
}

v07d_id_fingerprint <- function(ids) {
  v07d_sha256_raw(c(v07d_provenance_prefix("id_order"), v07d_strings_raw(ids)))
}

v07d_marker_fingerprint <- function(M, ids, marker_names) {
  M <- as.matrix(M)
  if (
    length(ids) != nrow(M) ||
      length(marker_names) != ncol(M) ||
      anyDuplicated(marker_names)
  ) {
    v07d_abort("marker fingerprint dimensions or names are invalid")
  }
  bytes <- c(
    v07d_provenance_prefix("markers"),
    v07d_u64_raw(nrow(M)),
    v07d_u64_raw(ncol(M)),
    v07d_strings_raw(ids),
    as.raw(1),
    v07d_strings_raw(marker_names),
    v07d_float64_raw(M)
  )
  v07d_sha256_raw(bytes)
}

v07d_matrix_fingerprint <- function(kind, matrix, ids) {
  matrix <- as.matrix(matrix)
  if (nrow(matrix) != ncol(matrix) || length(ids) != nrow(matrix)) {
    v07d_abort("%s fingerprint dimensions do not match the ID order", kind)
  }
  bytes <- c(
    v07d_provenance_prefix(kind),
    v07d_u64_raw(nrow(matrix)),
    v07d_u64_raw(ncol(matrix)),
    v07d_strings_raw(ids),
    v07d_strings_raw(ids),
    v07d_float64_raw(matrix)
  )
  v07d_sha256_raw(bytes)
}

v07d_verify_pair <- function(path, expected_hash = NULL) {
  sidecar <- paste0(path, ".sha256")
  if (
    !file.exists(path) ||
      !file.exists(sidecar) ||
      !v07d_is_regular_file(path) ||
      !v07d_is_regular_file(sidecar) ||
      v07d_has_symlink_component(path) ||
      v07d_has_symlink_component(sidecar)
  ) {
    v07d_abort("missing, orphaned, or symlinked file pair: %s", path)
  }
  digest <- v07d_sha256(path)
  if (!is.null(expected_hash) && !identical(digest, expected_hash)) {
    v07d_abort("frozen SHA-256 mismatch: %s", path)
  }
  expected <- sprintf("%s  %s", digest, basename(path))
  if (!identical(readLines(sidecar, warn = FALSE), expected)) {
    v07d_abort("sidecar mismatch: %s", path)
  }
  invisible(digest)
}

v07d_directory_closure <- function(files) {
  dirs <- ""
  current <- unique(dirname(files))
  while (length(current)) {
    current <- setdiff(current, c(".", ""))
    if (!length(current)) {
      break
    }
    dirs <- c(dirs, current)
    current <- unique(dirname(current))
  }
  sort(unique(dirs))
}

v07d_verify_tree_membership <- function(root, expected_files, label) {
  root <- v07d_real_dir(root, label)
  observed_files <- sort(list.files(
    root,
    recursive = TRUE,
    full.names = FALSE,
    all.files = TRUE,
    no.. = TRUE,
    include.dirs = FALSE
  ))
  observed_dirs <- sort(list.dirs(root, recursive = TRUE, full.names = FALSE))
  if (
    !identical(observed_files, sort(expected_files)) ||
      !identical(observed_dirs, v07d_directory_closure(expected_files))
  ) {
    v07d_abort("%s has a missing or additional file/directory member", label)
  }
  full_paths <- file.path(root, observed_files)
  if (any(!v07d_is_regular_file(full_paths))) {
    v07d_abort("%s contains a non-regular file", label)
  }
  invisible(TRUE)
}

v07d_read_tsv <- function(path, columns = NULL, verify = TRUE) {
  if (verify) {
    v07d_verify_pair(path)
  }
  out <- utils::read.delim(
    path,
    sep = "\t",
    quote = "",
    comment.char = "",
    check.names = FALSE,
    stringsAsFactors = FALSE,
    na.strings = c("NA", "NaN")
  )
  if (!is.null(columns) && !identical(names(out), columns)) {
    v07d_abort("schema drift in %s", path)
  }
  out
}

v07d_format <- function(x) {
  if (length(x) != 1L) {
    v07d_abort("non-scalar TSV field")
  }
  if (is.na(x)) {
    return("NA")
  }
  if (is.logical(x)) {
    return(if (x) "true" else "false")
  }
  if (is.numeric(x)) {
    if (is.nan(x)) {
      return("NaN")
    }
    if (is.infinite(x)) {
      return(if (x > 0) "Inf" else "-Inf")
    }
    return(sprintf("%.17g", x))
  }
  out <- enc2utf8(as.character(x))
  if (grepl("[\t\r\n]", out)) {
    v07d_abort("invalid TSV string")
  }
  out
}

v07d_tsv_text <- function(x) {
  rows <- if (!nrow(x)) {
    character()
  } else {
    vapply(
      seq_len(nrow(x)),
      function(i) {
        paste(
          vapply(x[i, , drop = FALSE], v07d_format, character(1L)),
          collapse = "\t"
        )
      },
      character(1L)
    )
  }
  paste0(
    paste(c(paste(names(x), collapse = "\t"), rows), collapse = "\n"),
    "\n"
  )
}

v07d_hardlink_once <- function(path, bytes) {
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  if (file.exists(path)) {
    v07d_abort("create-once path exists: %s", path)
  }
  tmp <- tempfile(".v07d-", tmpdir = dirname(path))
  con <- file(tmp, open = "wb")
  closed <- FALSE
  on.exit({
    if (!closed) {
      close(con)
    }
    unlink(tmp)
  })
  writeBin(bytes, con)
  close(con)
  closed <- TRUE
  if (!file.link(tmp, path)) {
    v07d_abort("exclusive hard-link claim failed: %s", path)
  }
  unlink(tmp)
  invisible(path)
}

v07d_write_once <- function(path, text) {
  if (file.exists(path) || file.exists(paste0(path, ".sha256"))) {
    v07d_abort("create-once output exists: %s", path)
  }
  v07d_hardlink_once(path, charToRaw(enc2utf8(text)))
  digest <- v07d_sha256(path)
  v07d_hardlink_once(
    paste0(path, ".sha256"),
    charToRaw(sprintf("%s  %s\n", digest, basename(path)))
  )
  invisible(digest)
}

v07d_bootstrap_table <- function(reps = 10000L) {
  if (length(reps) != 1L || is.na(reps) || reps < 1 || reps != floor(reps)) {
    v07d_abort("bootstrap replicate count must be a positive integer")
  }
  had_seed <- exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  old_seed <- if (had_seed) get(".Random.seed", envir = .GlobalEnv) else NULL
  old_rng <- RNGkind()
  on.exit(
    {
      do.call(RNGkind, as.list(old_rng))
      if (had_seed) {
        assign(".Random.seed", old_seed, envir = .GlobalEnv)
      } else if (exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)) {
        rm(".Random.seed", envir = .GlobalEnv)
      }
    },
    add = TRUE
  )
  RNGkind(
    kind = "Mersenne-Twister",
    normal.kind = "Inversion",
    sample.kind = "Rejection"
  )
  pieces <- lapply(seq_len(nrow(v07d_cells)), function(cell_index) {
    set.seed(2030000000L + cell_index)
    indices <- matrix(
      sample.int(48L, reps * 48L, replace = TRUE),
      nrow = reps,
      byrow = TRUE
    )
    out <- data.frame(
      cell_id = v07d_cells$cell_id[[cell_index]],
      bootstrap_rep = seq_len(reps),
      stringsAsFactors = FALSE
    )
    for (j in seq_len(48L)) {
      out[[sprintf("index_%02d", j)]] <- indices[, j]
    }
    out
  })
  out <- do.call(rbind, pieces)
  rownames(out) <- NULL
  out[v07d_bootstrap_columns]
}

v07d_write_bootstrap <- function(out_dir) {
  out_dir <- v07d_real_dir(out_dir, "bootstrap output directory")
  path <- file.path(out_dir, "d0_bootstrap_indices.tsv")
  digest <- v07d_write_once(path, v07d_tsv_text(v07d_bootstrap_table()))
  message(sprintf("D0 bootstrap indices: PASS (%s)", digest))
  invisible(digest)
}

v07d_read_bootstrap <- function(path, expected_hash = NULL, reps = 10000L) {
  digest <- v07d_verify_pair(path, expected_hash)
  out <- v07d_read_tsv(path, v07d_bootstrap_columns, verify = FALSE)
  expected_rows <- nrow(v07d_cells) * reps
  if (nrow(out) != expected_rows || anyNA(out)) {
    v07d_abort("bootstrap index denominator or missingness drift")
  }
  expected_cell <- rep(v07d_cells$cell_id, each = reps)
  expected_rep <- rep(seq_len(reps), times = nrow(v07d_cells))
  indices <- as.matrix(out[grep("^index_", names(out))])
  storage.mode(indices) <- "numeric"
  if (
    !identical(as.character(out$cell_id), expected_cell) ||
      !identical(as.integer(out$bootstrap_rep), expected_rep) ||
      any(indices != floor(indices)) ||
      any(indices < 1 | indices > 48)
  ) {
    v07d_abort("bootstrap index membership, order, or range drift")
  }
  attr(out, "sha256") <- digest
  out
}

v07d_expected_corpus_paths <- function(manifest) {
  paths <- "pilot_manifest.tsv"
  for (i in seq_len(nrow(manifest))) {
    cell <- manifest$cell_id[[i]]
    seed <- sprintf("%.0f", manifest$seed[[i]])
    paths <- c(
      paths,
      file.path("attempts", "pilot", cell, paste0(seed, ".tsv")),
      file.path("packets", "pilot", cell, seed, v07d_packet_primaries)
    )
  }
  sort(paths)
}

v07d_validate_manifest <- function(manifest) {
  expected_cell <- rep(v07d_cells$cell_id, each = 48L)
  cell_match <- match(manifest$cell_id, v07d_cells$cell_id)
  numeric <- c(
    "cell_index",
    "seed_offset",
    "seed",
    "n",
    "m",
    "truth_sigma_g2",
    "truth_sigma_e2",
    "truth_ratio",
    "ridge"
  )
  for (field in numeric) {
    manifest[[field]] <- as.numeric(manifest[[field]])
  }
  if (
    nrow(manifest) != 432L ||
      anyNA(cell_match) ||
      !identical(as.character(manifest$tier), rep("pilot", 432L)) ||
      !identical(as.character(manifest$cell_id), expected_cell) ||
      !identical(
        as.integer(manifest$cell_index),
        v07d_cells$cell_index[cell_match]
      ) ||
      !identical(
        as.integer(manifest$seed_offset),
        rep(7101:7148, times = 9L)
      ) ||
      !identical(
        manifest$seed,
        2027120000 + 10000 * manifest$cell_index + manifest$seed_offset
      ) ||
      !identical(
        as.integer(manifest$n),
        as.integer(v07d_cells$n[cell_match])
      ) ||
      !identical(
        as.integer(manifest$m),
        as.integer(v07d_cells$m[cell_match])
      ) ||
      any(manifest$truth_ratio != v07d_cells$truth_ratio[cell_match]) ||
      any(manifest$truth_sigma_g2 != manifest$truth_ratio) ||
      any(manifest$truth_sigma_e2 != 1 - manifest$truth_ratio) ||
      any(manifest$ridge != v07d_ridge) ||
      anyDuplicated(manifest$seed)
  ) {
    v07d_abort("frozen D0 manifest scientific or seed contract drift")
  }
  manifest
}

v07d_verify_corpus <- function(root) {
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  if (v07d_is_symlink(root)) {
    v07d_abort("D0 corpus root may not be a symlink")
  }
  for (name in names(v07d_fixed_hashes)) {
    v07d_verify_pair(file.path(root, name), v07d_fixed_hashes[[name]])
  }
  manifest <- v07d_validate_manifest(v07d_read_tsv(
    file.path(root, "pilot_manifest.tsv"),
    v07d_manifest_columns,
    verify = FALSE
  ))
  lock <- v07d_read_tsv(
    file.path(root, "pilot_corpus_lock.tsv"),
    c("relative_path", "sha256"),
    verify = FALSE
  )
  expected_paths <- v07d_expected_corpus_paths(manifest)
  if (
    !identical(as.character(lock$relative_path), expected_paths) ||
      anyDuplicated(lock$relative_path) ||
      any(!vapply(lock$sha256, v07d_hex64, logical(1L)))
  ) {
    v07d_abort("D0 corpus lock membership, order, or digest schema drift")
  }
  for (i in seq_len(nrow(lock))) {
    path <- file.path(root, lock$relative_path[[i]])
    v07d_verify_pair(path, lock$sha256[[i]])
  }
  attempt_root <- file.path(root, "attempts", "pilot")
  expected_attempts <- expected_paths[startsWith(expected_paths, "attempts/")]
  expected_attempts <- sort(c(
    sub("^attempts/pilot/", "", expected_attempts),
    paste0(sub("^attempts/pilot/", "", expected_attempts), ".sha256")
  ))
  v07d_verify_tree_membership(
    attempt_root,
    expected_attempts,
    "attempt tree"
  )
  packet_root <- file.path(root, "packets", "pilot")
  expected_packets <- expected_paths[startsWith(expected_paths, "packets/")]
  expected_packets <- sort(c(
    sub("^packets/pilot/", "", expected_packets),
    paste0(sub("^packets/pilot/", "", expected_packets), ".sha256")
  ))
  v07d_verify_tree_membership(packet_root, expected_packets, "packet tree")
  invisible(list(root = root, manifest = manifest, lock = lock))
}

v07d_helmert <- function(n) {
  if (length(n) != 1L || n < 2 || n != floor(n)) {
    v07d_abort("invalid Helmert dimension")
  }
  C <- matrix(0, nrow = n, ncol = n - 1L)
  for (j in seq_len(n - 1L)) {
    scale <- sqrt(j * (j + 1))
    C[seq_len(j), j] <- 1 / scale
    C[j + 1L, j] <- -j / scale
  }
  C
}

v07d_information <- function(values, ratio) {
  d <- (values - 1) / (ratio * values + 1 - ratio)
  centered <- d - mean(d)
  raw <- 0.5 * sum(centered^2)
  threshold <- 64 * .Machine$double.eps * max(1, sum(d^2))
  if (!is.finite(raw) || raw <= threshold) {
    return(c(information = 0, se_info = Inf))
  }
  c(information = raw, se_info = 1 / sqrt(raw))
}

v07d_replay_packet <- function(root, manifest_row) {
  cell <- as.character(manifest_row$cell_id)
  seed <- sprintf("%.0f", manifest_row$seed)
  attempt_path <- file.path(
    root,
    "attempts",
    "pilot",
    cell,
    paste0(seed, ".tsv")
  )
  attempt <- v07d_read_tsv(attempt_path, v07d_attempt_columns, verify = FALSE)
  packet <- file.path(root, "packets", "pilot", cell, seed)
  markers <- v07d_read_tsv(file.path(packet, "markers.tsv"), verify = FALSE)
  ids <- v07d_read_tsv(
    file.path(packet, "ids.tsv"),
    c("index", "id"),
    verify = FALSE
  )
  truth <- v07d_read_tsv(
    file.path(packet, "truth.tsv"),
    v07d_truth_columns,
    verify = FALSE
  )
  if (
    nrow(attempt) != 1L ||
      nrow(truth) != 1L ||
      !identical(as.character(attempt$cell_id), cell) ||
      as.numeric(attempt$seed) != manifest_row$seed ||
      !identical(as.character(attempt$status), "success") ||
      !identical(tolower(as.character(attempt$converged)), "true") ||
      !identical(as.character(truth$cell_id), cell) ||
      as.numeric(truth$seed) != manifest_row$seed
  ) {
    v07d_abort("attempt/truth identity drift for %s/%s", cell, seed)
  }
  n <- as.integer(manifest_row$n)
  truth_ratio <- as.numeric(manifest_row$truth_ratio)
  truth_sigma_e2 <- 1 - truth_ratio
  if (
    as.integer(attempt$n) != n ||
      as.integer(attempt$m) != as.integer(manifest_row$m) ||
      abs(as.numeric(attempt$truth_sigma_g2) - truth_ratio) > 1e-12 ||
      abs(as.numeric(attempt$truth_sigma_e2) - truth_sigma_e2) > 1e-12 ||
      abs(as.numeric(attempt$truth_ratio) - truth_ratio) > 1e-12 ||
      abs(as.numeric(attempt$ridge) - v07d_ridge) > 1e-12 ||
      !identical(as.character(attempt$relationship_source), "markers") ||
      !identical(as.character(attempt$relationship_method), "vanraden1") ||
      !identical(as.character(attempt$allele_frequency_source), "sample") ||
      !identical(as.character(attempt$relationship_scale), "K_lambda") ||
      !identical(as.character(attempt$route), "ordinary_auto_genomic") ||
      !identical(
        as.character(attempt$seal_sha256),
        unname(v07d_fixed_hashes[["campaign_seal.tsv"]])
      ) ||
      as.integer(truth$n) != n ||
      as.integer(truth$requested_m) != as.integer(manifest_row$m) ||
      abs(as.numeric(truth$truth_sigma_g2) - truth_ratio) > 1e-12 ||
      abs(as.numeric(truth$truth_sigma_e2) - truth_sigma_e2) > 1e-12 ||
      abs(as.numeric(truth$truth_ratio) - truth_ratio) > 1e-12 ||
      abs(as.numeric(truth$ridge) - v07d_ridge) > 1e-12
  ) {
    v07d_abort("attempt/truth scientific contract drift for %s/%s", cell, seed)
  }
  if (
    !identical(names(markers)[[1L]], "id") ||
      anyDuplicated(names(markers)[-1L]) ||
      any(!grepl("^m[0-9]{6}$", names(markers)[-1L])) ||
      nrow(markers) != n ||
      nrow(ids) != n ||
      !identical(as.integer(ids$index), seq_len(n)) ||
      !identical(as.character(markers[[1L]]), as.character(ids$id)) ||
      anyDuplicated(ids$id)
  ) {
    v07d_abort("marker/ID alignment drift for %s/%s", cell, seed)
  }
  M <- as.matrix(markers[-1L])
  storage.mode(M) <- "numeric"
  if (
    !ncol(M) ||
      any(!is.finite(M)) ||
      any(!M %in% c(0, 1, 2)) ||
      any(apply(M, 2L, function(x) length(unique(x)) <= 1L))
  ) {
    v07d_abort("invalid retained marker panel for %s/%s", cell, seed)
  }
  p <- colMeans(M) / 2
  k <- 2 * sum(p * (1 - p))
  W <- sweep(M, 2L, 2 * p, "-")
  K <- tcrossprod(W) / k + v07d_ridge * diag(n)
  Q <- solve(K)
  K_profile_raw <- solve(Q)
  K_profile <- 0.5 * (K_profile_raw + t(K_profile_raw))
  k_error <- max(abs(K_profile - K))
  qk_error <- max(abs(Q %*% K - diag(n)))
  ids_vector <- as.character(ids$id)
  computed_hashes <- c(
    marker_hash = v07d_marker_fingerprint(
      M,
      ids_vector,
      names(markers)[-1L]
    ),
    id_hash = v07d_id_fingerprint(ids_vector),
    kernel_hash = v07d_matrix_fingerprint("K_lambda", K, ids_vector),
    precision_hash = v07d_matrix_fingerprint("Q_lambda", Q, ids_vector)
  )
  recorded_hashes <- vapply(
    attempt[names(computed_hashes)],
    function(x) as.character(x[[1L]]),
    character(1L)
  )
  # IDs and integer marker dosages have language-independent exact encodings.
  # K and Q are independently reconstructed in base R, but last-bit BLAS and
  # reduction differences make their raw Float64 hashes toolchain-specific.
  # Julia verifies the recorded K/Q hashes exactly; the R-Julia 1e-10 gates
  # adjudicate the independently reconstructed numerical values.
  exact_hashes <- c("marker_hash", "id_hash")
  hash_drift <- exact_hashes[
    computed_hashes[exact_hashes] != recorded_hashes[exact_hashes]
  ]
  if (length(hash_drift)) {
    v07d_abort(
      "independent packet fingerprint mismatch in %s for %s/%s",
      paste(hash_drift, collapse = ","),
      cell,
      seed
    )
  }
  if (
    as.integer(truth$retained_m) != ncol(M) ||
      abs(as.numeric(truth$scale_denominator) - k) > 1e-10 ||
      abs(as.numeric(attempt$scale_denominator) - k) > 1e-10 ||
      !is.finite(k_error) ||
      k_error > v07d_replay_tolerance ||
      !is.finite(qk_error) ||
      qk_error > v07d_qk_tolerance
  ) {
    v07d_abort("K/Q replay identity failed for %s/%s", cell, seed)
  }
  C <- v07d_helmert(n)
  K_perp <- crossprod(C, K_profile %*% C)
  K_perp <- 0.5 * (K_perp + t(K_perp))
  values <- sort(eigen(K_perp, symmetric = TRUE, only.values = TRUE)$values)
  if (length(values) != n - 1L || any(!is.finite(values)) || any(values <= 0)) {
    v07d_abort("projected kernel spectrum is not finite positive")
  }
  eigen_mean <- mean(values)
  eigen_sd <- sqrt(mean((values - eigen_mean)^2))
  info <- unlist(
    lapply(c(0.2, 0.5, 0.8), function(ratio) {
      v07d_information(values, ratio)
    }),
    use.names = FALSE
  )
  scientific_ratio <- as.numeric(attempt$scientific_ratio)
  truth_slot <- match(truth_ratio, c(0.2, 0.5, 0.8))
  se_truth <- info[2L * truth_slot]
  if (
    !is.finite(scientific_ratio) ||
      !attempt$boundary_status %in%
        c("boundary_lower", "boundary_upper", "interior", "interior_rescued")
  ) {
    v07d_abort("resolved ratio or boundary status drift")
  }
  diag <- data.frame(
    cell_id = cell,
    cell_index = as.integer(manifest_row$cell_index),
    seed = as.numeric(manifest_row$seed),
    n = n,
    m = as.integer(manifest_row$m),
    truth_ratio = truth_ratio,
    retained_m = ncol(M),
    ridge = v07d_ridge,
    scale_denominator = k,
    marker_hash = computed_hashes[["marker_hash"]],
    id_hash = computed_hashes[["id_hash"]],
    kernel_hash = recorded_hashes[["kernel_hash"]],
    precision_hash = recorded_hashes[["precision_hash"]],
    k_replay_max_abs = k_error,
    qk_max_abs = qk_error,
    eigen_min = min(values),
    eigen_max = max(values),
    eigen_mean = eigen_mean,
    eigen_sd_population = eigen_sd,
    eigen_cv_population = eigen_sd / eigen_mean,
    effective_rank = sum(values)^2 / sum(values^2),
    information_r020 = info[[1L]],
    se_info_r020 = info[[2L]],
    information_r050 = info[[3L]],
    se_info_r050 = info[[4L]],
    information_r080 = info[[5L]],
    se_info_r080 = info[[6L]],
    scientific_ratio = scientific_ratio,
    absolute_ratio_error = abs(scientific_ratio - truth_ratio),
    boundary_status = as.character(attempt$boundary_status),
    predicted_lower_probability = stats::pnorm(-truth_ratio / se_truth),
    predicted_upper_probability = stats::pnorm(
      (1 - truth_ratio) / se_truth,
      lower.tail = FALSE
    ),
    stringsAsFactors = FALSE
  )
  for (field in c("marker_hash", "id_hash", "kernel_hash", "precision_hash")) {
    if (!v07d_hex64(diag[[field]])) v07d_abort("invalid %s in attempt", field)
  }
  eigen_rows <- data.frame(
    cell_id = cell,
    seed = as.numeric(manifest_row$seed),
    eigen_index = seq_along(values),
    eigenvalue = values,
    stringsAsFactors = FALSE
  )
  list(
    eigenvalues = eigen_rows[v07d_eigen_columns],
    diagnostics = diag[v07d_diagnostic_columns],
    native_hashes = data.frame(
      cell_id = cell,
      seed = as.numeric(manifest_row$seed),
      marker_hash_base_r = computed_hashes[["marker_hash"]],
      id_hash_base_r = computed_hashes[["id_hash"]],
      kernel_hash_base_r = computed_hashes[["kernel_hash"]],
      precision_hash_base_r = computed_hashes[["precision_hash"]],
      stringsAsFactors = FALSE
    )[v07d_native_hash_columns]
  )
}

v07d_summarize <- function(diagnostics, bootstrap, bootstrap_sha256) {
  if (!v07d_hex64(bootstrap_sha256)) {
    v07d_abort("summary bootstrap SHA-256 is invalid")
  }
  output <- vector("list", nrow(v07d_cells))
  for (i in seq_len(nrow(v07d_cells))) {
    cell <- v07d_cells[i, ]
    x <- diagnostics[diagnostics$cell_id == cell$cell_id, , drop = FALSE]
    b <- bootstrap[bootstrap$cell_id == cell$cell_id, , drop = FALSE]
    if (
      nrow(x) != 48L ||
        nrow(b) != 10000L ||
        !identical(as.numeric(x$seed), sort(as.numeric(x$seed)))
    ) {
      v07d_abort("D0 cell packet/bootstrap denominator or order drift")
    }
    se_field <- c(
      `0.2` = "se_info_r020",
      `0.5` = "se_info_r050",
      `0.8` = "se_info_r080"
    )[[as.character(cell$truth_ratio)]]
    ratio <- x$scientific_ratio
    se_info <- x[[se_field]]
    rms_se <- sqrt(mean(se_info^2))
    c_c <- stats::sd(ratio) / rms_se
    indices <- as.matrix(b[grep("^index_", names(b))])
    boot <- apply(indices, 1L, function(index) {
      stats::sd(ratio[index]) / sqrt(mean(se_info[index]^2))
    })
    lower_count <- sum(x$boundary_status == "boundary_lower")
    upper_count <- sum(x$boundary_status == "boundary_upper")
    lower_prop <- lower_count / 48
    upper_prop <- upper_count / 48
    output[[i]] <- data.frame(
      cell_id = cell$cell_id,
      bootstrap_sha256 = bootstrap_sha256,
      cell_index = cell$cell_index,
      n = cell$n,
      m = cell$m,
      truth_ratio = cell$truth_ratio,
      n_packets = 48,
      empirical_sd_ratio = stats::sd(ratio),
      rms_se_info = rms_se,
      c_c = c_c,
      c_c_bootstrap_lower = unname(stats::quantile(boot, 0.025, type = 7)),
      c_c_bootstrap_upper = unname(stats::quantile(boot, 0.975, type = 7)),
      spearman_se_info_abs_error = stats::cor(
        se_info,
        x$absolute_ratio_error,
        method = "spearman"
      ),
      mean_predicted_lower_probability = mean(x$predicted_lower_probability),
      mean_predicted_upper_probability = mean(x$predicted_upper_probability),
      observed_lower_count = lower_count,
      observed_upper_count = upper_count,
      observed_lower_proportion = lower_prop,
      observed_upper_proportion = upper_prop,
      observed_lower_mcse = sqrt(lower_prop * (1 - lower_prop) / 48),
      observed_upper_mcse = sqrt(upper_prop * (1 - upper_prop) / 48),
      mean_spectral_cv = mean(x$eigen_cv_population),
      mean_effective_rank = mean(x$effective_rank),
      stringsAsFactors = FALSE
    )
  }
  out <- do.call(rbind, output)
  rownames(out) <- NULL
  out[v07d_summary_columns]
}

v07d_replay <- function(input_root, bootstrap_path, bootstrap_hash = NULL) {
  corpus <- v07d_verify_corpus(input_root)
  bootstrap <- v07d_read_bootstrap(bootstrap_path, bootstrap_hash)
  pieces <- lapply(seq_len(nrow(corpus$manifest)), function(i) {
    v07d_replay_packet(corpus$root, corpus$manifest[i, , drop = FALSE])
  })
  eigenvalues <- do.call(rbind, lapply(pieces, `[[`, "eigenvalues"))
  diagnostics <- do.call(rbind, lapply(pieces, `[[`, "diagnostics"))
  native_hashes <- do.call(rbind, lapply(pieces, `[[`, "native_hashes"))
  rownames(eigenvalues) <- NULL
  rownames(diagnostics) <- NULL
  rownames(native_hashes) <- NULL
  if (
    nrow(eigenvalues) != 103248L ||
      nrow(diagnostics) != 432L ||
      nrow(native_hashes) != 432L
  ) {
    v07d_abort("D0 replay output denominator drift")
  }
  summary <- v07d_summarize(
    diagnostics,
    bootstrap,
    attr(bootstrap, "sha256", exact = TRUE)
  )
  list(
    eigenvalues = eigenvalues,
    diagnostics = diagnostics,
    native_hashes = native_hashes,
    summary = summary
  )
}

v07d_write_replay <- function(
  input_root,
  out_dir,
  bootstrap_path,
  bootstrap_hash = NULL
) {
  roots <- v07d_require_separate_roots(input_root, out_dir)
  input_root <- unname(roots[["input_root"]])
  out_dir <- unname(roots[["output_root"]])
  result <- v07d_replay(input_root, bootstrap_path, bootstrap_hash)
  paths <- c(
    eigenvalues = file.path(out_dir, "d0_eigenvalues_base_r.tsv"),
    diagnostics = file.path(out_dir, "d0_packet_diagnostics_base_r.tsv"),
    native_hashes = file.path(out_dir, "d0_native_fingerprints_base_r.tsv"),
    summary = file.path(out_dir, "d0_summary_base_r.tsv")
  )
  if (any(file.exists(c(paths, paste0(paths, ".sha256"))))) {
    v07d_abort("one or more create-once D0 output paths already exist")
  }
  hashes <- c(
    eigenvalues = v07d_write_once(
      paths[["eigenvalues"]],
      v07d_tsv_text(result$eigenvalues)
    ),
    diagnostics = v07d_write_once(
      paths[["diagnostics"]],
      v07d_tsv_text(result$diagnostics)
    ),
    native_hashes = v07d_write_once(
      paths[["native_hashes"]],
      v07d_tsv_text(result$native_hashes)
    ),
    summary = v07d_write_once(paths[["summary"]], v07d_tsv_text(result$summary))
  )
  message(sprintf(
    "independent base-R D0 replay: PASS (432 packets; 103248 eigenvalues; %s)",
    hashes[["summary"]]
  ))
  invisible(result)
}

v07d_equal_numeric <- function(x, y, tolerance = 1e-10) {
  same_missing <- is.na(x) == is.na(y) & is.nan(x) == is.nan(y)
  same <- (is.na(x) & is.na(y)) |
    (is.finite(x) & is.finite(y) & abs(x - y) <= tolerance) |
    (is.infinite(x) & is.infinite(y) & sign(x) == sign(y))
  all(same_missing & same)
}

v07d_compare_table <- function(x, y, columns, numeric, tolerance = 1e-10) {
  if (
    !identical(names(x), columns) ||
      !identical(names(y), columns) ||
      nrow(x) != nrow(y)
  ) {
    v07d_abort("D0 comparison schema or denominator mismatch")
  }
  for (field in numeric) {
    if (!is.numeric(x[[field]]) || !is.numeric(y[[field]])) {
      v07d_abort("D0 comparison nonnumeric field: %s", field)
    }
    if (
      !v07d_equal_numeric(
        x[[field]],
        y[[field]],
        tolerance
      )
    ) {
      v07d_abort("D0 comparison mismatch in %s", field)
    }
  }
  for (field in setdiff(columns, numeric)) {
    if (!identical(as.character(x[[field]]), as.character(y[[field]]))) {
      v07d_abort("D0 comparison mismatch in %s", field)
    }
  }
  invisible(TRUE)
}

v07d_validate_native_hashes <- function(
  native,
  diagnostics,
  expected_rows = 432L
) {
  if (
    !identical(names(native), v07d_native_hash_columns) ||
      nrow(native) != expected_rows ||
      nrow(diagnostics) != expected_rows
  ) {
    v07d_abort("base-R native fingerprint schema or denominator mismatch")
  }
  native_key <- paste(native$cell_id, native$seed, sep = "\r")
  diagnostic_key <- paste(diagnostics$cell_id, diagnostics$seed, sep = "\r")
  hash_fields <- grep("_hash_base_r$", names(native), value = TRUE)
  if (
    anyDuplicated(native_key) ||
      !identical(native_key, diagnostic_key) ||
      any(
        !vapply(
          unlist(native[hash_fields], use.names = FALSE),
          v07d_hex64,
          logical(1L)
        )
      ) ||
      !identical(native$marker_hash_base_r, diagnostics$marker_hash) ||
      !identical(native$id_hash_base_r, diagnostics$id_hash)
  ) {
    v07d_abort("base-R native fingerprint membership or exact-hash drift")
  }
  invisible(TRUE)
}

v07d_compare_outputs <- function(
  r_dir,
  julia_dir,
  bootstrap_path,
  bootstrap_sha256,
  tolerance = 1e-10
) {
  r_dir <- v07d_real_dir(r_dir, "base-R D0 output directory")
  julia_dir <- v07d_real_dir(julia_dir, "Julia D0 output directory")
  bootstrap <- v07d_read_bootstrap(bootstrap_path, bootstrap_sha256)
  sealed_bootstrap <- attr(bootstrap, "sha256", exact = TRUE)
  native <- v07d_read_tsv(
    file.path(r_dir, "d0_native_fingerprints_base_r.tsv"),
    v07d_native_hash_columns
  )
  r_diagnostics <- v07d_read_tsv(
    file.path(r_dir, "d0_packet_diagnostics_base_r.tsv"),
    v07d_diagnostic_columns
  )
  v07d_validate_native_hashes(native, r_diagnostics)
  specs <- list(
    eigenvalues = list(
      r = "d0_eigenvalues_base_r.tsv",
      julia = "d0_eigenvalues_julia.tsv",
      columns = v07d_eigen_columns,
      character = "cell_id"
    ),
    diagnostics = list(
      r = "d0_packet_diagnostics_base_r.tsv",
      julia = "d0_packet_spectrum_julia.tsv",
      columns = v07d_diagnostic_columns,
      character = c(
        "cell_id",
        "marker_hash",
        "id_hash",
        "kernel_hash",
        "precision_hash",
        "boundary_status"
      )
    ),
    summary = list(
      r = "d0_summary_base_r.tsv",
      julia = "d0_cell_summary_julia.tsv",
      columns = v07d_summary_columns,
      character = c("cell_id", "bootstrap_sha256")
    )
  )
  maxima <- vapply(
    names(specs),
    function(name) {
      spec <- specs[[name]]
      left <- v07d_read_tsv(file.path(r_dir, spec$r), spec$columns)
      right <- v07d_read_tsv(file.path(julia_dir, spec$julia), spec$columns)
      if (
        identical(name, "summary") &&
          (any(left$bootstrap_sha256 != sealed_bootstrap) ||
            any(right$bootstrap_sha256 != sealed_bootstrap))
      ) {
        v07d_abort("D0 summary is not bound to the sealed bootstrap SHA-256")
      }
      numeric <- setdiff(spec$columns, spec$character)
      v07d_compare_table(left, right, spec$columns, numeric, tolerance)
      max(vapply(
        numeric,
        function(field) {
          x <- as.numeric(left[[field]])
          y <- as.numeric(right[[field]])
          finite <- is.finite(x) & is.finite(y)
          if (!any(finite)) 0 else max(abs(x[finite] - y[finite]))
        },
        numeric(1L)
      ))
    },
    numeric(1L)
  )
  message(sprintf(
    paste0(
      "independent R-Julia D0 comparison: PASS ",
      "(eigenvalues=%.17g; diagnostics=%.17g; summary=%.17g)"
    ),
    maxima[["eigenvalues"]],
    maxima[["diagnostics"]],
    maxima[["summary"]]
  ))
  invisible(maxima)
}

v07d_selftest <- function() {
  C <- v07d_helmert(6L)
  stopifnot(
    max(abs(crossprod(C) - diag(5L))) < 1e-14,
    max(abs(crossprod(C, rep(1, 6L)))) < 1e-14,
    is.infinite(v07d_information(rep(1, 5L), 0.5)[["se_info"]])
  )
  bootstrap <- v07d_bootstrap_table(3L)
  stopifnot(
    nrow(bootstrap) == 27L,
    identical(names(bootstrap), v07d_bootstrap_columns),
    all(as.matrix(bootstrap[grep("^index_", names(bootstrap))]) %in% 1:48)
  )
  root <- tempfile("v07d-selftest-")
  dir.create(root)
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  on.exit(unlink(root, recursive = TRUE), add = TRUE)
  path <- file.path(root, "once.tsv")
  v07d_write_once(path, "x\n")
  v07d_verify_pair(path)
  stopifnot(inherits(
    try(v07d_write_once(path, "y\n"), silent = TRUE),
    "try-error"
  ))
  left <- data.frame(cell_id = "x", seed = 1, eigen_index = 1, eigenvalue = 2)
  right <- left
  v07d_compare_table(
    left,
    right,
    v07d_eigen_columns,
    c("seed", "eigen_index", "eigenvalue")
  )
  right$eigenvalue <- 3
  stopifnot(inherits(
    try(
      v07d_compare_table(
        left,
        right,
        v07d_eigen_columns,
        c("seed", "eigen_index", "eigenvalue")
      ),
      silent = TRUE
    ),
    "try-error"
  ))
  message("recovery-v3 independent base-R D0 selftest: PASS")
  invisible(TRUE)
}

v07d_main <- function(args = commandArgs(trailingOnly = TRUE)) {
  mode <- v07d_option(args, "mode", "selftest")
  if (mode == "selftest") {
    return(v07d_selftest())
  }
  if (mode == "compare") {
    r_dir <- v07d_option(args, "r-dir")
    julia_dir <- v07d_option(args, "julia-dir")
    bootstrap <- v07d_option(args, "bootstrap")
    bootstrap_hash <- v07d_option(args, "bootstrap-sha256")
    if (
      is.null(r_dir) ||
        is.null(julia_dir) ||
        is.null(bootstrap) ||
        is.null(bootstrap_hash)
    ) {
      v07d_abort(
        paste0(
          "--r-dir, --julia-dir, --bootstrap, and ",
          "--bootstrap-sha256 are required"
        )
      )
    }
    return(v07d_compare_outputs(
      r_dir,
      julia_dir,
      bootstrap,
      bootstrap_hash
    ))
  }
  out_dir <- v07d_option(args, "out-dir")
  if (is.null(out_dir)) {
    v07d_abort("--out-dir is required")
  }
  if (mode == "bootstrap") {
    return(v07d_write_bootstrap(out_dir))
  }
  if (mode == "recompute") {
    input_root <- v07d_option(args, "input-root")
    bootstrap <- v07d_option(
      args,
      "bootstrap",
      file.path(out_dir, "d0_bootstrap_indices.tsv")
    )
    bootstrap_hash <- v07d_option(args, "bootstrap-sha256")
    if (is.null(input_root) || is.null(bootstrap_hash)) {
      v07d_abort("--input-root and --bootstrap-sha256 are required")
    }
    return(v07d_write_replay(input_root, out_dir, bootstrap, bootstrap_hash))
  }
  v07d_abort("mode must be selftest, bootstrap, recompute, or compare")
}

if (sys.nframe() == 0L) {
  v07d_main()
}
