#!/usr/bin/env Rscript

# Independent base-R reconstruction and operational adjudication for the
# recovery-v3 D0F and D1 stages. This tool never loads hsquared, never calls a
# package genomic-construction helper, and never fits the official model. It
# reconstructs p, W, k, G, K_lambda, and Q_lambda from immutable packet bytes;
# the independent Julia replay owns the second fitted-route calculation.

v3r_abort <- function(...) stop(sprintf(...), call. = FALSE)

v3r_decode_command_path <- function(path) {
  gsub("~+~", " ", path, fixed = TRUE)
}

v3r_script_path <- function() {
  frames <- sys.frames()
  paths <- vapply(frames, function(frame) {
    value <- frame$ofile
    if (is.null(value)) "" else as.character(value)
  }, character(1L))
  hits <- paths[basename(paths) == "v07_genomic_recovery_v3_recompute.R"]
  if (length(hits)) {
    return(normalizePath(tail(hits, 1L), winslash = "/", mustWork = TRUE))
  }
  args <- commandArgs(FALSE)
  file_arg <- sub("^--file=", "", grep("^--file=", args, value = TRUE))
  if (length(file_arg) == 1L) {
    return(normalizePath(
      v3r_decode_command_path(file_arg), winslash = "/", mustWork = TRUE
    ))
  }
  v3r_abort("cannot locate the recovery-v3 base-R recomputer")
}

v3r_load_contract <- function() {
  target <- parent.frame()
  if (!exists("v3p_stage_preseal_keys", envir = target, inherits = TRUE)) {
    source(
      file.path(dirname(v3r_script_path()), "v07_genomic_recovery_v3_preseal.R"),
      local = target
    )
  }
  invisible(TRUE)
}

v3r_load_contract()

v3r_schema <- "v07-genomic-recovery-v3-adjudication-2"
v3r_review_schema <- "v07-genomic-recovery-v3-postrun-review-2"
v3r_route_lineage_schema <- "v07-genomic-recovery-v3-route-lineage-1"
v3r_route_lineage_columns <- c(
  "schema_version", "stage", "evidence_kind", "route", "group_kind",
  "group_id", "source_attempt_count", "source_inventory_sha256"
)
v3r_packet_primaries <- c(
  "markers.tsv", "ids.tsv", "phenotype.tsv", "truth.tsv",
  "packet_files_lock.tsv"
)
v3r_corpus_columns <- c("relative_path", "sha256")
v3r_packet_lock_columns <- c("file", "sha256")
v3r_batch_schema <- "v07-genomic-recovery-v3-base-r-batch-plan-1"
v3r_batch_columns <- c(
  "schema_version", "output_root", "stage", "corpus_lock_sha256",
  "batch_id", "batch_rank", "group", "seed"
)
v3r_truth_provenance_columns <- c(
  "packet_schema_version", "truth_schema_version", "scale_denominator",
  "relationship_source", "relationship_method", "allele_frequency_source",
  "relationship_scale", "preseal_sha256", "r_implementation_commit",
  "julia_implementation_commit", "driver_commit"
)
v3r_d1_construction_columns <- c(
  "retained_m", "marker_hash", "id_hash", "kernel_hash", "precision_hash"
)
v3r_native_hash_columns <- c(
  "base_r_kernel_hash", "base_r_precision_hash"
)
v3r_review_columns <- c(
  "schema_version", "stage", "reviewer", "verdict", "stage_decision",
  "preseal_sha256",
  "corpus_lock_sha256", "manifest_sha256", "base_r_inventory_sha256",
  "julia_replay_inventory_sha256", "r_summary_sha256",
  "julia_summary_sha256", "route_lineage_sha256", "r_driver_commit", "r_recomputer_commit",
  "julia_replay_commit", "reviewed_at_utc"
)
v3r_receipt_columns <- c(
  "schema_version", "stage", "verdict", "stage_decision",
  "attempt_max_diff", "summary_max_diff",
  "preseal_sha256", "corpus_lock_sha256", "manifest_sha256",
  "r_driver_commit", "r_recomputer_commit", "julia_replay_commit",
  "r_driver_sha256", "r_recomputer_sha256", "julia_replay_sha256",
  "base_r_inventory_sha256", "julia_replay_inventory_sha256",
  "r_summary_sha256", "julia_summary_sha256", "route_lineage_sha256",
  "adjudication_key_sha256",
  unlist(lapply(v3p_reviewers, function(x) {
    c(paste0(x, "_review_path"), paste0(x, "_review_sha256"))
  }), use.names = FALSE)
)

v3r_option <- function(args, key, default = NULL) {
  prefix <- paste0("--", key, "=")
  hits <- args[startsWith(args, prefix)]
  if (length(hits) > 1L) v3r_abort("option --%s occurs more than once", key)
  if (!length(hits)) return(default)
  sub(prefix, "", hits[[1L]], fixed = TRUE)
}

v3r_required <- function(args, key) {
  value <- v3r_option(args, key)
  if (is.null(value) || !nzchar(value)) v3r_abort("--%s is required", key)
  value
}

v3r_stage <- function(value) {
  if (length(value) != 1L || !value %in% c("d0f", "d1")) {
    v3r_abort("stage must be d0f or d1")
  }
  value
}

v3r_assert_execution_context <- function(
  host = NULL,
  cluster = Sys.getenv("SLURM_CLUSTER_NAME", unset = ""),
  environment = Sys.getenv(c(
    "GITHUB_ACTIONS", "CI", "SLURM_JOB_ID", "OPENBLAS_NUM_THREADS",
    "JULIA_NUM_THREADS", "OMP_NUM_THREADS", "MKL_NUM_THREADS",
    "VECLIB_MAXIMUM_THREADS", "NUMEXPR_NUM_THREADS"
  ), unset = "")
) {
  if (identical(tolower(environment[["GITHUB_ACTIONS"]]), "true") ||
      identical(tolower(environment[["CI"]]), "true")) {
    v3r_abort("recovery-v3 recomputation is forbidden on GitHub Actions or CI")
  }
  if (is.null(host)) {
    host <- strsplit(Sys.info()[["nodename"]], ".", fixed = TRUE)[[1L]][[1L]]
  } else {
    host <- strsplit(host, ".", fixed = TRUE)[[1L]][[1L]]
  }
  host <- tolower(host)
  cluster <- tolower(cluster)
  admitted <- c("fir", "nibi", "rorqual", "trillium", "narval")
  job_id <- unname(environment["SLURM_JOB_ID"])
  if (!length(job_id) || is.na(job_id)) job_id <- ""
  live_allocation <- cluster %in% admitted &&
    length(job_id) == 1L && grepl("^[1-9][0-9]*$", job_id)
  if (!identical(host, "totoro") && !live_allocation) {
    v3r_abort(
      "recovery-v3 recomputation requires Totoro or a live admitted DRAC SLURM allocation"
    )
  }
  threads <- environment[c(
    "OPENBLAS_NUM_THREADS", "JULIA_NUM_THREADS", "OMP_NUM_THREADS",
    "MKL_NUM_THREADS", "VECLIB_MAXIMUM_THREADS", "NUMEXPR_NUM_THREADS"
  )]
  if (threads[["OPENBLAS_NUM_THREADS"]] != "1" ||
      threads[["JULIA_NUM_THREADS"]] != "1" ||
      any(nzchar(threads) & threads != "1")) {
    v3r_abort("recovery-v3 recomputation threads are not pinned to one")
  }
  invisible(TRUE)
}

v3r_canonical_dir <- function(path, label) {
  if (
    length(path) != 1L || is.na(path) || !grepl("^/", path) ||
      !dir.exists(path) || v07d_has_symlink_component(path)
  ) {
    v3r_abort("%s must be an absolute existing symlink-free directory", label)
  }
  observed <- normalizePath(path, winslash = "/", mustWork = TRUE)
  if (!identical(observed, path)) v3r_abort("%s must be canonical", label)
  observed
}

v3r_canonical_file <- function(path, label, must_exist = TRUE) {
  if (
    length(path) != 1L || is.na(path) || !grepl("^/", path) ||
      v07d_has_symlink_component(dirname(path)) ||
      (file.exists(path) && v07d_has_symlink_component(path))
  ) {
    v3r_abort("%s must be an absolute symlink-free path", label)
  }
  parent <- normalizePath(dirname(path), winslash = "/", mustWork = TRUE)
  canonical <- file.path(parent, basename(path))
  if (!identical(canonical, path)) v3r_abort("%s must be canonical", label)
  if (must_exist && (!file.exists(path) || isTRUE(file.info(path)$isdir))) {
    v3r_abort("%s does not exist as a regular file", label)
  }
  canonical
}

v3r_verify_pair <- function(path, expected = NULL) {
  digest <- v07d_verify_pair(path, expected)
  if (file.info(path)$size <= 0) v3r_abort("empty primary is not admissible: %s", path)
  invisible(digest)
}

v3r_read_tsv <- function(path, columns, verify = TRUE, all_character = FALSE) {
  if (verify) v3r_verify_pair(path)
  bytes <- readBin(path, what = "raw", n = file.info(path)$size)
  if (!length(bytes) || tail(bytes, 1L) != as.raw(10L) ||
      any(bytes == as.raw(13L)) || any(bytes == as.raw(0L))) {
    v3r_abort("TSV is not canonical LF text: %s", path)
  }
  value <- utils::read.delim(
    path, sep = "\t", quote = "", comment.char = "", check.names = FALSE,
    stringsAsFactors = FALSE, na.strings = c("NA", "NaN"),
    colClasses = if (all_character) "character" else NA
  )
  v3p_require_schema(value, columns, basename(path))
  value
}

v3r_hardlink_once <- function(path, bytes, temporary_parent) {
  if (file.exists(path)) v3r_abort("create-once path exists: %s", path)
  temporary_parent <- v3r_canonical_dir(temporary_parent, "temporary parent")
  tmp <- tempfile(".v3r-", tmpdir = temporary_parent)
  con <- file(tmp, open = "wb")
  closed <- FALSE
  on.exit({
    if (!closed) close(con)
    unlink(tmp)
  }, add = TRUE)
  writeBin(bytes, con)
  close(con)
  closed <- TRUE
  link <- Sys.which("ln")
  if (!nzchar(link)) v3r_abort("POSIX ln is required for create-once claims")
  status <- system2(
    link, c(shQuote(tmp), shQuote(path)), stdout = FALSE, stderr = FALSE
  )
  if (status != 0L) v3r_abort("exclusive create-once claim failed: %s", path)
  unlink(tmp)
  invisible(path)
}

v3r_write_once <- function(path, object, temporary_parent = NULL) {
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  path <- v3r_canonical_file(path, "create-once output", must_exist = FALSE)
  if (file.exists(path) || file.exists(paste0(path, ".sha256"))) {
    v3r_abort("create-once output primary/sidecar already exists: %s", path)
  }
  if (is.null(temporary_parent)) temporary_parent <- dirname(path)
  text <- v07d_tsv_text(object)
  v3r_hardlink_once(path, charToRaw(enc2utf8(text)), temporary_parent)
  digest <- v07d_sha256(path)
  v3r_hardlink_once(
    paste0(path, ".sha256"),
    charToRaw(sprintf("%s  %s\n", digest, basename(path))),
    temporary_parent
  )
  invisible(digest)
}

v3r_hash_text <- function(text) {
  v07d_sha256_raw(charToRaw(enc2utf8(text)))
}

v3r_same_text_table <- function(left, right) {
  if (!identical(names(left), names(right)) || nrow(left) != nrow(right)) {
    return(FALSE)
  }
  all(vapply(names(left), function(field) {
    x <- as.character(left[[field]])
    y <- as.character(right[[field]])
    x[is.na(x)] <- "NA"
    y[is.na(y)] <- "NA"
    identical(x, y)
  }, logical(1L)))
}

v3r_expected_tool_context <- function() {
  script <- v3r_script_path()
  r_root <- normalizePath(file.path(dirname(script), ".."), winslash = "/")
  julia_root <- normalizePath(file.path(r_root, "..", "HSquared.jl"), winslash = "/")
  list(
    r_driver_path = file.path(r_root, "tools", "v07_genomic_recovery_v3.R"),
    r_recomputer_path = script,
    julia_replay_path = file.path(
      julia_root, "sim", "phase2_v07_genomic_recovery_v3_stage_replay.jl"
    ),
    d0_recomputer_path = file.path(
      r_root, "tools", "v07_genomic_recovery_v3_d0_recompute.R"
    ),
    r_driver_root = r_root, r_recomputer_root = r_root,
    r_auto_route_root = r_root, julia_replay_root = julia_root,
    julia_candidate_root = julia_root
  )
}

v3r_preseal_values <- function(path) {
  x <- v3r_read_tsv(path, c("key", "value"), all_character = TRUE)
  if (!identical(as.character(x$key), v3p_stage_preseal_keys)) {
    v3r_abort("stage preseal key membership or order drift")
  }
  value <- as.character(x$value)
  value[is.na(value)] <- "NA"
  names(value) <- x$key
  list(table = x, value = value, sha256 = v07d_sha256(path))
}

v3r_validate_preseal_postrun <- function(root, stage, runtime_phase) {
  path <- file.path(root, "stage_preseal.tsv")
  preseal <- v3r_preseal_values(path)
  if (preseal$value[["stage"]] != stage || preseal$value[["output_root"]] != root) {
    v3r_abort("stage preseal stage/root drift")
  }
  v3p_validate_stage_preseal(
    preseal$table, v3r_expected_tool_context(), include_preseal = TRUE,
    bootstrap_materialized = identical(stage, "d0f"), tree_scope = "runtime",
    runtime_phase = runtime_phase
  )
  preseal
}

v3r_manifest_columns <- function(stage) {
  if (stage == "d0f") v3p_d0f_phenotype_columns else v3p_d1_columns
}

v3r_attempt_columns <- function(stage) {
  if (stage == "d0f") v3p_d0f_attempt_columns else v3p_d1_attempt_columns
}

v3r_truth_columns <- function(stage) {
  c(
    v3r_manifest_columns(stage),
    if (stage == "d1") v3r_d1_construction_columns else character(),
    v3r_truth_provenance_columns
  )
}

v3r_group <- function(row, stage) {
  as.character(row[[if (stage == "d0f") "design_id" else "cell_id"]][[1L]])
}

v3r_seed <- function(row) sprintf("%.0f", as.numeric(row$seed[[1L]]))

v3r_attempt_path <- function(root, stage, row) {
  file.path(root, "attempts", stage, v3r_group(row, stage), paste0(v3r_seed(row), ".tsv"))
}

v3r_packet_dir <- function(root, stage, row) {
  file.path(root, "packets", stage, v3r_group(row, stage), v3r_seed(row))
}

v3r_recompute_path <- function(root, stage, row) {
  file.path(
    root, "base_r_recompute", stage, v3r_group(row, stage),
    paste0(v3r_seed(row), ".tsv")
  )
}

v3r_julia_path <- function(root, stage, row) {
  file.path(
    root, "julia_replay", stage, v3r_group(row, stage),
    paste0(v3r_seed(row), ".tsv")
  )
}

v3r_find_row <- function(manifest, stage, group, seed) {
  key_group <- if (stage == "d0f") manifest$design_id else manifest$cell_id
  hits <- which(as.character(key_group) == group & as.numeric(manifest$seed) == seed)
  if (length(hits) != 1L) v3r_abort("group/seed is not exactly one manifest member")
  manifest[hits, , drop = FALSE]
}

v3r_expected_official_paths <- function(root, stage, manifest) {
  paths <- c(
    file.path(root, "stage_preseal.tsv"),
    file.path(root, paste0(stage, "_manifest.tsv"))
  )
  for (i in seq_len(nrow(manifest))) {
    row <- manifest[i, , drop = FALSE]
    paths <- c(
      paths, v3r_attempt_path(root, stage, row),
      file.path(v3r_packet_dir(root, stage, row), v3r_packet_primaries)
    )
  }
  paths
}

v3r_inventory <- function(root, paths) {
  paths <- sort(unique(paths))
  if (!length(paths) || any(!startsWith(paths, paste0(root, "/")))) {
    v3r_abort("inventory paths must be nonempty children of the stage root")
  }
  for (path in paths) v3r_verify_pair(path)
  data.frame(
    relative_path = substring(paths, nchar(root) + 2L),
    sha256 = vapply(paths, v07d_sha256, character(1L)),
    stringsAsFactors = FALSE
  )
}

v3r_inventory_sha256 <- function(inventory) {
  v3p_require_schema(inventory, v3r_corpus_columns, "inventory")
  v3r_hash_text(v07d_tsv_text(inventory))
}

v3r_verify_exact_tree <- function(root, expected_primaries, label) {
  root <- v3r_canonical_dir(root, label)
  expected <- unname(sort(c(
    substring(expected_primaries, nchar(root) + 2L),
    paste0(substring(expected_primaries, nchar(root) + 2L), ".sha256")
  )))
  v07d_verify_tree_membership(root, expected, label)
  for (path in expected_primaries) v3r_verify_pair(path)
  invisible(TRUE)
}

v3r_verify_corpus <- function(root, stage, manifest) {
  path <- file.path(root, "stage_corpus_lock.tsv")
  lock <- v3r_read_tsv(path, v3r_corpus_columns, all_character = TRUE)
  expected_paths <- v3r_expected_official_paths(root, stage, manifest)
  expected <- v3r_inventory(root, expected_paths)
  if (
    anyDuplicated(lock$relative_path) ||
      !identical(as.character(lock$relative_path), expected$relative_path) ||
      !identical(as.character(lock$sha256), expected$sha256)
  ) {
    v3r_abort("official corpus lock differs from the exact current corpus")
  }
  attempt_paths <- vapply(seq_len(nrow(manifest)), function(i) {
    v3r_attempt_path(root, stage, manifest[i, , drop = FALSE])
  }, character(1L))
  packet_paths <- unlist(lapply(seq_len(nrow(manifest)), function(i) {
    file.path(
      v3r_packet_dir(root, stage, manifest[i, , drop = FALSE]),
      v3r_packet_primaries
    )
  }), use.names = FALSE)
  v3r_verify_exact_tree(file.path(root, "attempts"), attempt_paths, "attempt tree")
  v3r_verify_exact_tree(file.path(root, "packets"), packet_paths, "packet tree")
  list(table = lock, path = path, sha256 = v07d_sha256(path))
}

v3r_read_stage <- function(
  root, stage, validate_deployment = TRUE, runtime_phase = "base_r"
) {
  root <- v3r_canonical_dir(root, "stage output root")
  stage <- v3r_stage(stage)
  preseal <- if (validate_deployment) {
    v3r_validate_preseal_postrun(root, stage, runtime_phase)
  } else {
    v3r_preseal_values(file.path(root, "stage_preseal.tsv"))
  }
  manifest_path <- file.path(root, paste0(stage, "_manifest.tsv"))
  manifest <- v3r_read_tsv(manifest_path, v3r_manifest_columns(stage))
  manifest <- if (stage == "d0f") {
    fixed <- unique(manifest[v3p_d0f_fixed_columns])
    v3p_validate_d0f_phenotype_manifest(manifest, fixed)
  } else {
    v3p_validate_d1_manifest(manifest)
  }
  if (v07d_sha256(manifest_path) != preseal$value[["manifest_sha256"]]) {
    v3r_abort("manifest differs from preseal binding")
  }
  corpus <- v3r_verify_corpus(root, stage, manifest)
  list(
    root = root, stage = stage, preseal = preseal, manifest = manifest,
    manifest_path = manifest_path, corpus = corpus,
    binding = list(
      preseal_sha256 = preseal$sha256,
      manifest_sha256 = preseal$value[["manifest_sha256"]],
      corpus_lock_sha256 = corpus$sha256,
      r_auto_route_commit = preseal$value[["r_auto_route_commit"]],
      julia_candidate_commit = preseal$value[["julia_candidate_commit"]],
      r_driver_commit = preseal$value[["r_driver_commit"]],
      julia_replay_commit = preseal$value[["julia_replay_commit"]],
      julia_replay_sha256 = preseal$value[["julia_replay_sha256"]]
    )
  )
}

v3r_packet_files <- function(packet) {
  actual <- sort(list.files(packet, all.files = TRUE, no.. = TRUE))
  expected <- sort(c(v3r_packet_primaries, paste0(v3r_packet_primaries, ".sha256")))
  if (!identical(actual, expected)) v3r_abort("packet file-set drift")
  if (any(vapply(
    file.path(packet, actual), v07d_has_symlink_component, logical(1L)
  ))) {
    v3r_abort("packet contains a symlinked member")
  }
  for (name in v3r_packet_primaries) v3r_verify_pair(file.path(packet, name))
  lock <- v3r_read_tsv(
    file.path(packet, "packet_files_lock.tsv"), v3r_packet_lock_columns,
    verify = FALSE, all_character = TRUE
  )
  if (!identical(as.character(lock$file), v3r_packet_primaries[1:4])) {
    v3r_abort("packet inner lock membership/order drift")
  }
  observed <- vapply(
    file.path(packet, v3r_packet_primaries[1:4]), v07d_sha256, character(1L)
  )
  if (!identical(as.character(lock$sha256), unname(observed))) {
    v3r_abort("packet inner lock hash drift")
  }
  invisible(TRUE)
}

v3r_read_marker_packet <- function(path, ids, n) {
  x <- v3r_read_tsv(path, columns = names(v07d_read_tsv(path, verify = FALSE)))
  if (
    ncol(x) < 2L || names(x)[[1L]] != "id" || nrow(x) != n ||
      !identical(as.character(x$id), ids)
  ) {
    v3r_abort("marker packet dimensions or ID order drift")
  }
  marker_names <- names(x)[-1L]
  if (
    anyDuplicated(marker_names) ||
      any(!grepl("^m[0-9]{6}$", marker_names))
  ) {
    v3r_abort("marker names are not canonical and unique")
  }
  M <- suppressWarnings(matrix(
    as.numeric(as.matrix(x[-1L])), nrow = n, ncol = length(marker_names),
    dimnames = list(ids, marker_names)
  ))
  if (anyNA(M) || any(!M %in% c(0, 1, 2))) {
    v3r_abort("marker packet contains a non-hard-call dosage")
  }
  if (any(vapply(seq_len(ncol(M)), function(j) {
    length(unique(M[, j])) < 2L
  }, logical(1L)))) {
    v3r_abort("retained marker packet contains a monomorphic column")
  }
  list(M = M, marker_names = marker_names)
}

v3r_spectrum <- function(K, n) {
  C <- v07d_helmert(n)
  values <- eigen(
    (crossprod(C, K %*% C) + t(crossprod(C, K %*% C))) / 2,
    symmetric = TRUE, only.values = TRUE
  )$values
  values <- sort(as.numeric(values))
  if (length(values) != n - 1L || any(!is.finite(values)) || any(values <= 0)) {
    v3r_abort("projected kernel has nonpositive or nonfinite eigenvalues")
  }
  mean_value <- mean(values)
  sd_population <- sqrt(mean((values - mean_value)^2))
  information <- lapply(c(0.2, 0.5, 0.8), function(ratio) {
    v07d_information(values, ratio)
  })
  list(
    values = values, cv = sd_population / mean_value,
    effective_rank = sum(values)^2 / sum(values^2),
    information = vapply(information, `[[`, numeric(1L), "information"),
    se = vapply(information, `[[`, numeric(1L), "se_info")
  )
}

v3r_manifest_equal <- function(truth, row, columns) {
  numeric_fields <- c(
    "design_index", "panel_rank", "panel_source_seed", "phenotype_rank",
    "cell_index", "seed_offset", "seed", "n", "m", "marker_ratio",
    "retained_m", "truth_sigma_g2", "truth_sigma_e2", "truth_ratio",
    "ridge"
  )
  for (field in columns) {
    left <- as.character(truth[[field]])
    right <- as.character(row[[field]])
    equal <- if (field %in% numeric_fields) {
      left_numeric <- suppressWarnings(as.numeric(left))
      right_numeric <- suppressWarnings(as.numeric(right))
      tolerance <- if (field == "marker_ratio") 1e-12 else 0
      is.finite(left_numeric) && is.finite(right_numeric) &&
        abs(left_numeric - right_numeric) <= tolerance
    } else {
      identical(left, right)
    }
    if (!isTRUE(equal)) {
      v3r_abort("truth/manifest mismatch in %s", field)
    }
  }
  invisible(TRUE)
}

v3r_reconstruct_packet <- function(root, stage, row, preseal, preseal_sha256) {
  packet <- v3r_packet_dir(root, stage, row)
  packet <- v3r_canonical_dir(packet, "packet directory")
  v3r_packet_files(packet)
  n <- as.integer(row$n[[1L]])
  ids <- v3r_read_tsv(file.path(packet, "ids.tsv"), c("index", "id"), FALSE)
  if (
    nrow(ids) != n || !identical(as.integer(ids$index), seq_len(n)) ||
      anyNA(ids$id) || any(!nzchar(ids$id)) || anyDuplicated(ids$id)
  ) {
    v3r_abort("packet ID order/denominator drift")
  }
  id_order <- as.character(ids$id)
  markers <- v3r_read_marker_packet(
    file.path(packet, "markers.tsv"), id_order, n
  )
  phenotype <- v3r_read_tsv(
    file.path(packet, "phenotype.tsv"), c("index", "id", "y"), FALSE
  )
  y <- suppressWarnings(as.numeric(phenotype$y))
  if (
    nrow(phenotype) != n ||
      !identical(as.integer(phenotype$index), seq_len(n)) ||
      !identical(as.character(phenotype$id), id_order) ||
      any(!is.finite(y))
  ) {
    v3r_abort("packet phenotype order/denominator drift")
  }
  truth <- v3r_read_tsv(
    file.path(packet, "truth.tsv"), v3r_truth_columns(stage), FALSE
  )
  if (nrow(truth) != 1L) v3r_abort("truth packet must contain exactly one row")
  v3r_manifest_equal(truth, row, v3r_manifest_columns(stage))
  retained_m <- ncol(markers$M)
  if (
    as.integer(truth$retained_m) != retained_m || retained_m < 1L ||
      retained_m > as.integer(row$m[[1L]])
  ) {
    v3r_abort("truth retained-marker count drift")
  }
  p <- colSums(markers$M) / (2 * n)
  W <- sweep(markers$M, 2L, 2 * p, "-")
  k <- 2 * sum(p * (1 - p))
  if (!is.finite(k) || k <= 0) v3r_abort("nonpositive VanRaden denominator")
  G <- tcrossprod(W) / k
  K <- G
  diag(K) <- diag(K) + 0.01
  Q <- solve(K)
  qk <- max(abs(Q %*% K - diag(n)))
  K_profile <- solve(Q)
  K_profile <- (K_profile + t(K_profile)) / 2
  k_replay <- max(abs(K - K_profile))
  if (!is.finite(qk) || !is.finite(k_replay) || qk > 1e-10 || k_replay > 1e-10) {
    v3r_abort("independent K/Q reconstruction exceeds 1e-10")
  }
  if (abs(as.numeric(truth$scale_denominator) - k) > 1e-10) {
    v3r_abort("truth VanRaden denominator drift")
  }
  native_hashes <- c(
    marker_hash = v07d_marker_fingerprint(
      markers$M, id_order, markers$marker_names
    ),
    id_hash = v07d_id_fingerprint(id_order),
    kernel_hash = v07d_matrix_fingerprint("K_lambda", K, id_order),
    precision_hash = v07d_matrix_fingerprint("Q_lambda", Q, id_order)
  )
  for (field in c("marker_hash", "id_hash")) {
    if (!identical(as.character(truth[[field]]), native_hashes[[field]])) {
      v3r_abort("truth packet %s drift", field)
    }
  }
  for (field in c("kernel_hash", "precision_hash")) {
    if (!v3p_hex64(as.character(truth[[field]]))) {
      v3r_abort("truth packet %s is not a valid Julia-native fingerprint", field)
    }
  }
  hashes <- c(
    native_hashes[c("marker_hash", "id_hash")],
    kernel_hash = as.character(truth$kernel_hash),
    precision_hash = as.character(truth$precision_hash)
  )
  required_truth <- c(
    packet_schema_version = "v07-genomic-recovery-v3-packet-1",
    truth_schema_version = "v07-genomic-recovery-v3-truth-1",
    relationship_source = "markers", relationship_method = "vanraden1",
    allele_frequency_source = "sample", relationship_scale = "K_lambda",
    preseal_sha256 = preseal_sha256,
    r_implementation_commit = preseal[["r_auto_route_commit"]],
    julia_implementation_commit = preseal[["julia_candidate_commit"]],
    driver_commit = preseal[["r_driver_commit"]]
  )
  for (field in names(required_truth)) {
    if (!identical(as.character(truth[[field]]), required_truth[[field]])) {
      v3r_abort("truth provenance drift in %s", field)
    }
  }
  list(
    M = markers$M, ids = id_order, marker_names = markers$marker_names,
    y = y, p = p, W = W, k = k, G = G, K = K, Q = Q,
    retained_m = retained_m, hashes = hashes, native_hashes = native_hashes,
    spectrum = v3r_spectrum(K_profile, n), truth = truth,
    qk_max_abs = qk, k_replay_max_abs = k_replay
  )
}

v3r_recompute_row <- function(root, stage, row, preseal, preseal_sha256) {
  packet <- v3r_reconstruct_packet(root, stage, row, preseal, preseal_sha256)
  attempt <- v3r_read_tsv(
    v3r_attempt_path(root, stage, row), v3r_attempt_columns(stage)
  )
  if (nrow(attempt) != 1L) v3r_abort("official attempt must contain one row")
  v3r_manifest_equal(attempt, row, v3r_manifest_columns(stage))
  if (stage == "d1") {
    construction <- c(
      retained_m = packet$retained_m, unname(packet$hashes)
    )
    names(construction) <- v3r_d1_construction_columns
    for (field in names(construction)) {
      actual <- as.character(attempt[[field]])
      expected <- as.character(construction[[field]])
      if (!identical(actual, expected)) {
        v3r_abort("official attempt construction drift in %s", field)
      }
    }
  }
  spectral <- c(
    eigen_cv_population = packet$spectrum$cv,
    effective_rank = packet$spectrum$effective_rank,
    information_r020 = packet$spectrum$information[[1L]],
    se_info_r020 = packet$spectrum$se[[1L]],
    information_r050 = packet$spectrum$information[[2L]],
    se_info_r050 = packet$spectrum$se[[2L]],
    information_r080 = packet$spectrum$information[[3L]],
    se_info_r080 = packet$spectrum$se[[3L]]
  )
  if (
    abs(as.numeric(attempt$scale_denominator) - packet$k) > 1e-10 ||
      any(abs(as.numeric(unlist(attempt[names(spectral)])) - spectral) > 1e-10)
  ) {
    v3r_abort("official attempt construction/spectral diagnostics drift")
  }
  required <- c(
    relationship_source = "markers", relationship_method = "vanraden1",
    allele_frequency_source = "sample", relationship_scale = "K_lambda",
    route = "ordinary_auto_genomic",
    r_implementation_commit = preseal[["r_auto_route_commit"]],
    julia_implementation_commit = preseal[["julia_candidate_commit"]],
    driver_commit = preseal[["r_driver_commit"]],
    preseal_sha256 = preseal_sha256
  )
  for (field in names(required)) {
    if (!identical(as.character(attempt[[field]]), required[[field]])) {
      v3r_abort("official attempt provenance drift in %s", field)
    }
  }
  # Independently reconstructed fields replace their source copies. Fitted
  # scientific/numerical fields remain the official source evidence and are
  # checked against the independent Julia replay during adjudication.
  attempt$scale_denominator <- packet$k
  for (field in names(spectral)) attempt[[field]] <- spectral[[field]]
  if (stage == "d1") {
    attempt$retained_m <- packet$retained_m
    for (field in names(packet$hashes)) attempt[[field]] <- packet$hashes[[field]]
  }
  attempt$base_r_kernel_hash <- packet$native_hashes[["kernel_hash"]]
  attempt$base_r_precision_hash <- packet$native_hashes[["precision_hash"]]
  attempt[c(v3r_attempt_columns(stage), v3r_native_hash_columns)]
}

v3r_recompute_one <- function(root, stage, group, seed) {
  state <- v3r_read_stage(root, stage, runtime_phase = "base_r")
  seed <- suppressWarnings(as.numeric(seed))
  if (!is.finite(seed) || seed != floor(seed)) v3r_abort("seed must be an integer")
  row <- v3r_find_row(state$manifest, stage, group, seed)
  out <- v3r_recompute_path(state$root, stage, row)
  dir.create(dirname(out), recursive = TRUE, showWarnings = FALSE)
  v3r_canonical_dir(dirname(out), "base-R recomputation parent")
  if (file.exists(out) || file.exists(paste0(out, ".sha256"))) {
    v3r_abort("base-R target primary/sidecar is not absent")
  }
  value <- v3r_recompute_row(
    state$root, stage, row, state$preseal$value, state$preseal$sha256
  )
  v3r_write_once(out, value, temporary_parent = dirname(state$root))
  message(sprintf(
    "wrote base-R %s recomputation group=%s seed=%.0f sha256=%s",
    stage, group, seed, v07d_sha256(out)
  ))
  invisible(value)
}

v3r_manifest_keys <- function(manifest, stage) {
  data.frame(
    group = as.character(manifest[[if (stage == "d0f") "design_id" else "cell_id"]]),
    seed = vapply(seq_len(nrow(manifest)), function(i) {
      v3r_seed(manifest[i, , drop = FALSE])
    }, character(1L)), stringsAsFactors = FALSE
  )
}

v3r_pair_state <- function(path) {
  sidecar <- paste0(path, ".sha256")
  link_exists <- function(candidate) {
    target <- Sys.readlink(candidate)
    !is.na(target) && nzchar(target)
  }
  primary_exists <- file.exists(path) || link_exists(path)
  sidecar_exists <- file.exists(sidecar) || link_exists(sidecar)
  if (!primary_exists && !sidecar_exists) return("missing")
  if (!primary_exists || !sidecar_exists) {
    v3r_abort("partial primary/sidecar output pair: %s", path)
  }
  info <- file.info(c(path, sidecar))
  if (anyNA(info$isdir) || any(info$isdir) || any(vapply(
    c(path, sidecar), v07d_has_symlink_component, logical(1L)
  ))) {
    v3r_abort("nonregular or symlinked output pair: %s", path)
  }
  v3r_verify_pair(path)
  "complete"
}

v3r_missing_manifest_indices <- function(state) {
  which(vapply(seq_len(nrow(state$manifest)), function(i) {
    row <- state$manifest[i, , drop = FALSE]
    identical(v3r_pair_state(
      v3r_recompute_path(state$root, state$stage, row)
    ), "missing")
  }, logical(1L)))
}

v3r_build_batch_plan <- function(state, batch_size, indices = NULL) {
  batch_size <- suppressWarnings(as.numeric(batch_size))
  if (length(batch_size) != 1L || !is.finite(batch_size) ||
      batch_size != floor(batch_size) || batch_size < 1L) {
    v3r_abort("batch size must be a positive integer")
  }
  if (is.null(indices)) indices <- v3r_missing_manifest_indices(state)
  indices <- suppressWarnings(as.integer(indices))
  if (anyNA(indices) || any(indices < 1L) ||
      any(indices > nrow(state$manifest)) || anyDuplicated(indices)) {
    v3r_abort("batch-plan indices must be unique manifest members")
  }
  indices <- sort(indices)
  if (!length(indices)) v3r_abort("no missing base-R recomputations to plan")
  keys <- v3r_manifest_keys(state$manifest[indices, , drop = FALSE], state$stage)
  batch_id <- sprintf("b%04d", ceiling(seq_along(indices) / batch_size))
  data.frame(
    schema_version = v3r_batch_schema, output_root = state$root,
    stage = state$stage, corpus_lock_sha256 = state$corpus$sha256,
    batch_id = batch_id,
    batch_rank = as.integer(ave(seq_along(indices), batch_id, FUN = seq_along)),
    group = keys$group, seed = keys$seed, stringsAsFactors = FALSE
  )[v3r_batch_columns]
}

v3r_external_batch_path <- function(path, root, must_exist = TRUE) {
  path <- v3r_canonical_file(path, "external batch plan", must_exist)
  if (identical(path, root) || startsWith(path, paste0(root, "/"))) {
    v3r_abort("batch plan must remain outside the evidence root")
  }
  path
}

v3r_read_batch_plan <- function(state, path) {
  path <- v3r_external_batch_path(path, state$root)
  digest_before <- v3r_verify_pair(path)
  plan <- v3r_read_tsv(path, v3r_batch_columns)
  digest_after <- v3r_verify_pair(path)
  if (!identical(digest_before, digest_after)) {
    v3r_abort("batch-plan bytes changed while being authenticated")
  }
  if (!nrow(plan)) v3r_abort("batch plan must contain at least one row")
  fixed <- list(
    schema_version = v3r_batch_schema, output_root = state$root,
    stage = state$stage, corpus_lock_sha256 = state$corpus$sha256
  )
  for (field in names(fixed)) {
    if (anyNA(plan[[field]]) ||
        !all(as.character(plan[[field]]) == fixed[[field]])) {
      v3r_abort("batch plan %s binding drift", field)
    }
  }
  if (anyNA(plan$batch_id) ||
      any(!grepl("^b[0-9]{4,}$", plan$batch_id)) ||
      anyNA(plan$group) || any(!nzchar(plan$group))) {
    v3r_abort("batch plan identifiers are not canonical")
  }
  ranks <- suppressWarnings(as.numeric(plan$batch_rank))
  seeds <- suppressWarnings(as.numeric(plan$seed))
  if (any(!is.finite(ranks)) || any(ranks != floor(ranks)) || any(ranks < 1L) ||
      any(!is.finite(seeds)) || any(seeds != floor(seeds))) {
    v3r_abort("batch plan ranks/seeds must be finite integers")
  }
  keys <- v3r_manifest_keys(state$manifest, state$stage)
  manifest_key <- paste(keys$group, keys$seed, sep = "\r")
  plan_key <- paste(as.character(plan$group), sprintf("%.0f", seeds), sep = "\r")
  indices <- match(plan_key, manifest_key)
  if (anyNA(indices)) v3r_abort("batch plan contains an unknown manifest member")
  if (anyDuplicated(plan_key)) {
    v3r_abort("batch plan contains a duplicate manifest member")
  }
  if (!identical(indices, sort(indices))) {
    v3r_abort("batch plan members are not in canonical manifest order")
  }
  batches <- unique(as.character(plan$batch_id))
  if (!identical(batches, sort(batches))) {
    v3r_abort("batch identifiers are not in canonical order")
  }
  for (batch in batches) {
    hits <- which(plan$batch_id == batch)
    if (!identical(as.integer(ranks[hits]), seq_along(hits))) {
      v3r_abort("batch ranks are not consecutive from one")
    }
  }
  attr(plan, "manifest_indices") <- indices
  plan
}

v3r_validate_batch_plan_missing <- function(state, plan) {
  observed <- attr(plan, "manifest_indices")
  if (is.null(observed)) v3r_abort("batch plan has not been authenticated")
  expected <- v3r_missing_manifest_indices(state)
  if (!identical(as.integer(observed), as.integer(expected))) {
    v3r_abort("batch-plan union differs from the missing manifest denominator")
  }
  invisible(TRUE)
}

v3r_write_batch_plan <- function(root, stage, path, batch_size) {
  state <- v3r_read_stage(root, stage, runtime_phase = "base_r")
  path <- v3r_external_batch_path(path, state$root, must_exist = FALSE)
  if (file.exists(path) || file.exists(paste0(path, ".sha256"))) {
    v3r_abort("external batch-plan primary/sidecar already exists")
  }
  plan <- v3r_build_batch_plan(state, batch_size)
  v3r_write_once(path, plan, temporary_parent = dirname(path))
  message(sprintf(
    "wrote base-R batch plan rows=%d batches=%d sha256=%s",
    nrow(plan), length(unique(plan$batch_id)), v07d_sha256(path)
  ))
  invisible(plan)
}

v3r_validate_batch_plan <- function(root, stage, path) {
  state <- v3r_read_stage(root, stage, runtime_phase = "base_r")
  plan <- v3r_read_batch_plan(state, path)
  v3r_validate_batch_plan_missing(state, plan)
  message(sprintf(
    "validated base-R batch-plan union rows=%d batches=%d",
    nrow(plan), length(unique(plan$batch_id))
  ))
  invisible(plan)
}

v3r_authenticate_batch_plan <- function(
  root, stage, path, stage_reader = v3r_read_stage
) {
  state <- stage_reader(root, stage, runtime_phase = "base_r")
  plan <- v3r_read_batch_plan(state, path)
  planned <- attr(plan, "manifest_indices")
  missing <- v3r_missing_manifest_indices(state)
  if (length(setdiff(missing, planned))) {
    v3r_abort("resumed batch plan does not cover every currently missing row")
  }
  message(sprintf(
    "authenticated resumable base-R batch plan rows=%d remaining=%d batches=%d",
    nrow(plan), length(missing), length(unique(plan$batch_id))
  ))
  invisible(plan)
}

v3r_locked_digest <- function(state, path) {
  relative <- substring(path, nchar(state$root) + 2L)
  hits <- which(as.character(state$corpus$table$relative_path) == relative)
  if (length(hits) != 1L) {
    v3r_abort(
      "row input is not exactly one authenticated corpus-lock member: %s", path
    )
  }
  expected <- as.character(state$corpus$table$sha256[[hits]])
  if (!v3p_hex64(expected)) v3r_abort("corpus-lock digest is not canonical")
  expected
}

v3r_reverify_row_inputs <- function(state, row) {
  paths <- c(
    v3r_attempt_path(state$root, state$stage, row),
    file.path(v3r_packet_dir(state$root, state$stage, row), v3r_packet_primaries)
  )
  for (path in paths) v3r_verify_pair(path, v3r_locked_digest(state, path))
  invisible(TRUE)
}

v3r_recompute_batch <- function(
  root, stage, path, batch_id, stage_reader = v3r_read_stage,
  row_recomputer = v3r_recompute_row, writer = v3r_write_once
) {
  # Expensive preseal/manifest/full-corpus validation happens once per batch.
  # Each row is then reauthenticated against the retained corpus-lock map.
  state <- stage_reader(root, stage, runtime_phase = "base_r")
  plan <- v3r_read_batch_plan(state, path)
  if (length(batch_id) != 1L || is.na(batch_id) ||
      !grepl("^b[0-9]{4,}$", batch_id)) {
    v3r_abort("batch-id is not canonical")
  }
  hits <- which(as.character(plan$batch_id) == batch_id)
  if (!length(hits)) v3r_abort("batch-id is not present in the batch plan")
  indices <- attr(plan, "manifest_indices")[hits]
  rows <- state$manifest[indices, , drop = FALSE]
  targets <- vapply(seq_len(nrow(rows)), function(i) {
    v3r_recompute_path(state$root, state$stage, rows[i, , drop = FALSE])
  }, character(1L))
  # Validate every target before the first write. Complete prefixes are skipped;
  # partial pairs abort the whole batch before it can extend that prefix.
  target_state <- vapply(targets, v3r_pair_state, character(1L))
  complete <- which(target_state == "complete")
  if (length(complete) &&
      !identical(unname(complete), seq_along(complete))) {
    v3r_abort("existing base-R outputs are not a complete resumable prefix")
  }
  for (i in complete) {
    row <- rows[i, , drop = FALSE]
    v3r_reverify_row_inputs(state, row)
    expected <- row_recomputer(
      state$root, state$stage, row, state$preseal$value, state$preseal$sha256
    )
    observed <- rawToChar(readBin(
      targets[[i]], what = "raw", n = file.info(targets[[i]])$size
    ))
    if (!identical(observed, v07d_tsv_text(expected))) {
      v3r_abort("resumable base-R output differs from fresh recomputation")
    }
  }
  missing <- which(target_state == "missing")
  for (i in missing) {
    row <- rows[i, , drop = FALSE]
    v3r_reverify_row_inputs(state, row)
    value <- row_recomputer(
      state$root, state$stage, row, state$preseal$value, state$preseal$sha256
    )
    dir.create(dirname(targets[[i]]), recursive = TRUE, showWarnings = FALSE)
    v3r_canonical_dir(dirname(targets[[i]]), "base-R recomputation parent")
    writer(targets[[i]], value, temporary_parent = dirname(state$root))
    message(sprintf(
      "wrote base-R %s recomputation batch=%s group=%s seed=%s sha256=%s",
      state$stage, batch_id, v3r_group(row, state$stage), v3r_seed(row),
      v07d_sha256(targets[[i]])
    ))
  }
  invisible(list(
    batch_id = batch_id, planned = nrow(rows), written = length(missing),
    already_complete = nrow(rows) - length(missing)
  ))
}

v3r_recompute_paths <- function(state, kind = c("base_r", "julia")) {
  kind <- match.arg(kind)
  vapply(seq_len(nrow(state$manifest)), function(i) {
    row <- state$manifest[i, , drop = FALSE]
    if (kind == "base_r") {
      v3r_recompute_path(state$root, state$stage, row)
    } else {
      v3r_julia_path(state$root, state$stage, row)
    }
  }, character(1L))
}

v3r_read_rows <- function(state, kind = c("official", "base_r", "julia")) {
  kind <- match.arg(kind)
  paths <- switch(
    kind,
    official = vapply(seq_len(nrow(state$manifest)), function(i) {
      v3r_attempt_path(
        state$root, state$stage, state$manifest[i, , drop = FALSE]
      )
    }, character(1L)),
    base_r = v3r_recompute_paths(state, "base_r"),
    julia = v3r_recompute_paths(state, "julia")
  )
  if (kind != "official") {
    v3r_verify_exact_tree(
      file.path(state$root, if (kind == "base_r") "base_r_recompute" else "julia_replay"),
      paths, paste(kind, "tree")
    )
  }
  columns <- if (kind == "julia") {
    c(
      setdiff(v3r_attempt_columns(state$stage), "preseal_sha256"),
      v3p_replay_binding_columns
    )
  } else if (kind == "base_r") {
    c(v3r_attempt_columns(state$stage), v3r_native_hash_columns)
  } else {
    v3r_attempt_columns(state$stage)
  }
  rows <- lapply(paths, v3r_read_tsv, columns = columns)
  if (any(vapply(rows, nrow, integer(1L)) != 1L)) {
    v3r_abort("%s output does not contain exactly one row per manifest member", kind)
  }
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  if (kind == "base_r") {
    if (any(!vapply(unlist(out[v3r_native_hash_columns]), v3p_hex64, logical(1L)))) {
      v3r_abort("base-R native K/Q fingerprint provenance drift")
    }
    out <- out[v3r_attempt_columns(state$stage)]
  }
  list(table = out, paths = paths)
}

v3r_route_for_kind <- function(kind) {
  if (identical(kind, "julia")) {
    "julia_profile_replay"
  } else if (kind %in% c("official", "base_r")) {
    "ordinary_auto_genomic"
  } else {
    v3r_abort("unknown admitted evidence kind: %s", kind)
  }
}

v3r_evidence_class <- function(kind) {
  c(paste0("v3r_", kind, "_evidence"), "v3r_admitted_evidence")
}

v3r_new_admitted_evidence <- function(rows, kind, stage) {
  route <- v3r_route_for_kind(kind)
  stage <- v3r_stage(stage)
  if (!is.data.frame(rows) || !nrow(rows) || !"route" %in% names(rows)) {
    v3r_abort("admitted evidence requires a nonempty routed data frame")
  }
  observed <- unique(as.character(rows$route))
  if (length(observed) != 1L || !identical(observed, route)) {
    v3r_abort("admitted evidence route does not match its route-specific kind")
  }
  group_field <- if (identical(stage, "d0f")) "design_id" else "cell_id"
  if (!group_field %in% names(rows)) {
    v3r_abort("admitted evidence lacks its summary grouping field")
  }
  envelope <- new.env(parent = emptyenv())
  envelope$rows <- rows
  envelope$kind <- kind
  envelope$route <- route
  envelope$stage <- stage
  envelope$group_field <- group_field
  envelope$row_sha256 <- v3r_hash_text(v07d_tsv_text(rows))
  class(envelope) <- v3r_evidence_class(kind)
  lockEnvironment(envelope, bindings = TRUE)
  envelope
}

v3r_validate_evidence_envelope <- function(value, expected_kind, state = NULL) {
  fields <- c(
    "rows", "kind", "route", "stage", "group_field", "row_sha256"
  )
  if (!is.environment(value) || !environmentIsLocked(value) ||
      !identical(class(value), v3r_evidence_class(expected_kind)) ||
      !all(vapply(fields, bindingIsLocked, logical(1L), env = value)) ||
      !identical(value$kind, expected_kind)) {
    v3r_abort("admitted evidence class/kind binding was forged or mutated")
  }
  if (!identical(value$stage, v3r_stage(value$stage)) ||
      !is.null(state) && !identical(value$stage, state$stage)) {
    v3r_abort("admitted evidence stage does not match summary stage")
  }
  route <- v3r_route_for_kind(expected_kind)
  expected_group <- if (identical(value$stage, "d0f")) {
    "design_id"
  } else {
    "cell_id"
  }
  if (!identical(value$route, route) ||
      !identical(value$group_field, expected_group) ||
      !is.data.frame(value$rows) || !nrow(value$rows) ||
      !"route" %in% names(value$rows) ||
      any(as.character(value$rows$route) != route) ||
      !expected_group %in% names(value$rows) ||
      !identical(
        value$row_sha256,
        v3r_hash_text(v07d_tsv_text(value$rows))
      )) {
    v3r_abort("admitted evidence route binding was forged or mutated")
  }
  value$rows
}

v3r_evidence_rows <- function(value, state = NULL) {
  UseMethod("v3r_evidence_rows")
}

v3r_evidence_rows.v3r_official_evidence <- function(value, state = NULL) {
  v3r_validate_evidence_envelope(value, "official", state)
}

v3r_evidence_rows.v3r_base_r_evidence <- function(value, state = NULL) {
  v3r_validate_evidence_envelope(value, "base_r", state)
}

v3r_evidence_rows.v3r_julia_evidence <- function(value, state = NULL) {
  v3r_validate_evidence_envelope(value, "julia", state)
}

v3r_evidence_rows.default <- function(value, state = NULL) {
  if (!inherits(value, "v3r_admitted_evidence")) {
    v3r_abort("summary reconstruction requires admitted evidence, not raw rows")
  }
  v3r_abort("admitted evidence class/kind binding was forged or mutated")
}

v3r_project_julia_performance <- function(julia, official) {
  julia_rows <- v3r_evidence_rows(julia)
  official_rows <- v3r_evidence_rows(official)
  keys <- c("stage", if (identical(julia$stage, "d0f")) "design_id" else "cell_id", "seed")
  if (!identical(julia_rows[keys], official_rows[keys])) {
    v3r_abort("Julia performance projection key order differs from official evidence")
  }
  julia_rows$runtime_seconds <- official_rows$runtime_seconds
  julia_rows$peak_rss_mb <- official_rows$peak_rss_mb
  v3r_new_admitted_evidence(julia_rows, "julia", julia$stage)
}

v3r_admit_rows <- function(state, kind, rows) {
  source_hash <- vapply(
    vapply(seq_len(nrow(state$manifest)), function(i) {
      v3r_attempt_path(
        state$root, state$stage, state$manifest[i, , drop = FALSE]
      )
    }, character(1L)),
    v07d_sha256, character(1L)
  )
  admitted <- if (kind == "julia") {
    v3p_admit_julia_replay(
      rows, state$manifest, state$stage, state$binding, source_hash
    )
  } else {
    switch(
      state$stage,
      d0f = v3p_admit_d0f_attempts(rows, state$manifest, state$binding),
      d1 = v3p_admit_d1_attempts(rows, state$manifest, state$binding)
    )
  }
  v3r_new_admitted_evidence(admitted, kind, state$stage)
}

v3r_expected_summary <- function(state, admitted) {
  UseMethod("v3r_expected_summary", admitted)
}

v3r_expected_summary_route <- function(state, admitted, julia = FALSE) {
  attempts <- v3r_evidence_rows(admitted, state)
  if (state$stage == "d0f") {
    bootstrap_path <- file.path(state$root, "d0f_bootstrap_indices.tsv")
    bootstrap <- v3r_read_tsv(
      bootstrap_path, v3p_d0f_bootstrap_columns
    )
    summary <- if (julia) {
      v3p_d0f_julia_summary
    } else {
      v3p_d0f_summary
    }
    summary(
      state$manifest, attempts, bootstrap,
      v07d_sha256(bootstrap_path), state$binding
    )
  } else {
    summary <- if (julia) {
      v3p_d1_julia_summary
    } else {
      v3p_d1_summary
    }
    summary(state$manifest, attempts, state$binding)
  }
}

v3r_expected_summary.v3r_official_evidence <- function(state, admitted) {
  v3r_expected_summary_route(state, admitted, julia = FALSE)
}

v3r_expected_summary.v3r_base_r_evidence <- function(state, admitted) {
  v3r_expected_summary_route(state, admitted, julia = FALSE)
}

v3r_expected_summary.v3r_julia_evidence <- function(state, admitted) {
  v3r_expected_summary_route(state, admitted, julia = TRUE)
}

v3r_expected_summary.default <- function(state, admitted) {
  v3r_evidence_rows(admitted, state)
}

v3r_summary_columns <- function(stage) {
  if (stage == "d0f") v3p_d0f_summary_columns else v3p_d1_summary_columns
}

v3r_summarize <- function(root, stage) {
  state <- v3r_read_stage(root, stage, runtime_phase = "r_summary")
  rows <- v3r_read_rows(state, "base_r")
  attempts <- v3r_admit_rows(state, "base_r", rows$table)
  summary <- v3r_expected_summary(state, attempts)
  path <- file.path(state$root, paste0(stage, "_summary_r.tsv"))
  v3r_write_once(path, summary)
  message(sprintf(
    "wrote base-R %s summary rows=%d sha256=%s",
    stage, nrow(summary), v07d_sha256(path)
  ))
  invisible(summary)
}

v3r_lineage_path <- function(root) file.path(root, "stage_route_lineage.tsv")

v3r_lineage_rows <- function(admitted, inventory_sha256) {
  rows <- v3r_evidence_rows(admitted)
  field <- admitted$group_field
  groups <- unique(as.character(rows[[field]]))
  counts <- table(factor(as.character(rows[[field]]), levels = groups))
  data.frame(
    schema_version = v3r_route_lineage_schema,
    stage = admitted$stage,
    evidence_kind = admitted$kind,
    route = admitted$route,
    group_kind = field,
    group_id = groups,
    source_attempt_count = as.integer(counts),
    source_inventory_sha256 = inventory_sha256,
    stringsAsFactors = FALSE
  )[v3r_route_lineage_columns]
}

v3r_expected_route_lineage <- function(state, evidence, adjudication) {
  admitted <- adjudication$admitted
  out <- do.call(rbind, list(
    v3r_lineage_rows(admitted$official, state$corpus$sha256),
    v3r_lineage_rows(admitted$base_r, evidence$base_r_inventory_sha256),
    v3r_lineage_rows(admitted$julia, evidence$julia_replay_inventory_sha256)
  ))
  rownames(out) <- NULL
  expected_kinds <- c("official", "base_r", "julia")
  expected_groups <- if (identical(state$stage, "d0f")) 3L else 12L
  kind_factor <- factor(out$evidence_kind, levels = expected_kinds)
  kind_counts <- table(kind_factor)
  weighted <- tapply(out$source_attempt_count, kind_factor, sum)
  if (any(as.integer(kind_counts) != expected_groups) ||
      any(as.integer(weighted) != nrow(state$manifest)) ||
      anyDuplicated(out[c("evidence_kind", "group_id")])) {
    v3r_abort("weighted route-lineage conservation failed")
  }
  out
}

v3r_validate_route_lineage <- function(state, evidence, adjudication) {
  observed <- evidence$route_lineage
  expected <- v3r_expected_route_lineage(state, evidence, adjudication)
  if (!v3r_same_text_table(observed, expected)) {
    v3r_abort("route-lineage artifact differs from admitted evidence")
  }
  invisible(expected)
}

v3r_write_route_lineage <- function(root, stage) {
  state <- v3r_read_stage(root, stage, runtime_phase = "lineage")
  evidence <- v3r_evidence(state, include_lineage = FALSE)
  adjudication <- v3r_adjudicate_tables(state, evidence)
  lineage <- v3r_expected_route_lineage(state, evidence, adjudication)
  path <- v3r_lineage_path(state$root)
  v3r_write_once(path, lineage, temporary_parent = dirname(state$root))
  message(sprintf(
    "wrote %s route lineage rows=%d sha256=%s",
    stage, nrow(lineage), v07d_sha256(path)
  ))
  invisible(lineage)
}

v3r_stage_decision <- function(summary, stage) {
  if (stage == "d0f") {
    status <- unique(as.character(summary$d0f_status))
    if (length(status) != 1L) v3r_abort("D0F summary has multiple corpus statuses")
    return(status)
  }
  by_cell <- unique(summary[c("cell_id", "cell_status")])
  counts <- table(as.character(by_cell$cell_status))
  counts <- counts[order(names(counts))]
  paste(paste(names(counts), as.integer(counts), sep = "="), collapse = ";")
}

v3r_evidence <- function(state, include_lineage = TRUE) {
  base <- v3r_read_rows(state, "base_r")
  julia <- v3r_read_rows(state, "julia")
  r_summary_path <- file.path(state$root, paste0(state$stage, "_summary_r.tsv"))
  j_summary_path <- file.path(state$root, paste0(state$stage, "_summary_julia.tsv"))
  columns <- v3r_summary_columns(state$stage)
  r_summary <- v3r_read_tsv(r_summary_path, columns)
  j_summary <- v3r_read_tsv(j_summary_path, columns)
  out <- list(
    base = base, julia = julia, r_summary = r_summary,
    j_summary = j_summary,
    base_r_inventory_sha256 = v3r_inventory_sha256(
      v3r_inventory(state$root, base$paths)
    ),
    julia_replay_inventory_sha256 = v3r_inventory_sha256(
      v3r_inventory(state$root, julia$paths)
    ),
    r_summary_sha256 = v07d_sha256(r_summary_path),
    julia_summary_sha256 = v07d_sha256(j_summary_path)
  )
  if (include_lineage) {
    path <- v3r_lineage_path(state$root)
    out$route_lineage <- v3r_read_tsv(
      path, v3r_route_lineage_columns, all_character = TRUE
    )
    out$route_lineage_sha256 <- v07d_sha256(path)
  }
  out
}

v3r_review_path <- function(root, reviewer) {
  file.path(root, "postrun_receipts", paste0(reviewer, ".tsv"))
}

v3r_review_row <- function(
  state, evidence, reviewer, verdict, stage_decision, reviewed_at_utc
) {
  reviewer <- tolower(reviewer)
  verdict <- toupper(verdict)
  if (!reviewer %in% v3p_reviewers || !verdict %in% c("CLEAN", "BLOCKED")) {
    v3r_abort("post-run review requires a known reviewer and CLEAN/BLOCKED verdict")
  }
  if (!grepl("^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$", reviewed_at_utc)) {
    v3r_abort("post-run review time must be an ISO UTC second")
  }
  data.frame(
    schema_version = v3r_review_schema, stage = state$stage,
    reviewer = reviewer, verdict = verdict, stage_decision = stage_decision,
    preseal_sha256 = state$preseal$sha256,
    corpus_lock_sha256 = state$corpus$sha256,
    manifest_sha256 = state$preseal$value[["manifest_sha256"]],
    base_r_inventory_sha256 = evidence$base_r_inventory_sha256,
    julia_replay_inventory_sha256 = evidence$julia_replay_inventory_sha256,
    r_summary_sha256 = evidence$r_summary_sha256,
    julia_summary_sha256 = evidence$julia_summary_sha256,
    route_lineage_sha256 = evidence$route_lineage_sha256,
    r_driver_commit = state$preseal$value[["r_driver_commit"]],
    r_recomputer_commit = state$preseal$value[["r_recomputer_commit"]],
    julia_replay_commit = state$preseal$value[["julia_replay_commit"]],
    reviewed_at_utc = reviewed_at_utc, stringsAsFactors = FALSE
  )[v3r_review_columns]
}

v3r_write_postrun_review <- function(
  root, stage, reviewer, verdict, receipt = NULL, reviewed_at_utc
) {
  state <- v3r_read_stage(root, stage, runtime_phase = "review")
  evidence <- v3r_evidence(state)
  adjudication <- v3r_adjudicate_tables(state, evidence)
  v3r_validate_route_lineage(state, evidence, adjudication)
  reviewer <- tolower(reviewer)
  expected_path <- v3r_review_path(state$root, reviewer)
  if (!is.null(receipt)) {
    receipt <- v3r_canonical_file(
      receipt, paste(reviewer, "post-run receipt"), must_exist = FALSE
    )
    if (!identical(receipt, expected_path)) {
      v3r_abort("post-run receipt path is not the canonical stage-root path")
    }
  }
  row <- v3r_review_row(
    state, evidence, reviewer, verdict,
    v3r_stage_decision(adjudication$summary, stage), reviewed_at_utc
  )
  v3r_write_once(expected_path, row, temporary_parent = dirname(state$root))
  message(sprintf(
    "wrote %s post-run review reviewer=%s verdict=%s sha256=%s",
    stage, reviewer, toupper(verdict), v07d_sha256(expected_path)
  ))
  invisible(row)
}

v3r_validate_review <- function(
  path, reviewer, state, evidence, stage_decision, clean = TRUE
) {
  path <- v3r_canonical_file(path, paste(reviewer, "post-run receipt"))
  if (!identical(path, v3r_review_path(state$root, reviewer))) {
    v3r_abort("%s post-run receipt is relocated", reviewer)
  }
  row <- v3r_read_tsv(path, v3r_review_columns, all_character = TRUE)
  expected <- v3r_review_row(
    state, evidence, reviewer, as.character(row$verdict),
    stage_decision, as.character(row$reviewed_at_utc)
  )
  if (!v3r_same_text_table(row, expected)) {
    v3r_abort("%s post-run receipt binding drift", reviewer)
  }
  if (clean && row$verdict != "CLEAN") {
    v3r_abort("%s post-run verdict is not CLEAN", reviewer)
  }
  list(path = path, sha256 = v07d_sha256(path), row = row)
}

v3r_numeric_max_diff <- function(left, right, fields) {
  max(c(0, vapply(fields, function(field) {
    x <- as.numeric(left[[field]])
    y <- as.numeric(right[[field]])
    if (length(x) != length(y) || any(xor(is.na(x), is.na(y)))) {
      v3r_abort("numeric parity shape/NA drift in %s", field)
    }
    both_infinite <- is.infinite(x) & is.infinite(y) & sign(x) == sign(y)
    if (any(xor(is.infinite(x), is.infinite(y))) ||
        any(is.infinite(x) & is.infinite(y) & !both_infinite)) {
      v3r_abort("numeric parity infinity drift in %s", field)
    }
    use <- !is.na(x) & !both_infinite
    if (!any(use)) 0 else max(abs(x[use] - y[use]))
  }, numeric(1L))))
}

v3r_mask_common_infinities <- function(tables) {
  if (length(tables) < 2L) v3r_abort("summary parity requires at least two tables")
  numeric_fields <- names(tables[[1L]])[vapply(
    tables[[1L]], is.numeric, logical(1L)
  )]
  for (field in numeric_fields) {
    values <- lapply(tables, function(x) as.numeric(x[[field]]))
    if (any(lengths(values) != length(values[[1L]]))) {
      v3r_abort("summary parity shape drift in %s", field)
    }
    for (row in seq_along(values[[1L]])) {
      infinite <- vapply(values, function(x) is.infinite(x[[row]]), logical(1L))
      if (!any(infinite)) next
      signs <- vapply(values, function(x) sign(x[[row]]), numeric(1L))
      if (!all(infinite) || length(unique(signs)) != 1L) {
        v3r_abort("summary parity infinity mask/sign drift in %s", field)
      }
      for (i in seq_along(tables)) tables[[i]][[field]][[row]] <- NA_real_
    }
  }
  tables
}

v3r_compare_summary_triplet <- function(driver, base_r, julia, stage) {
  numeric_fields <- names(driver)[vapply(driver, is.numeric, logical(1L))]
  maximum_difference <- max(
    v3r_numeric_max_diff(driver, base_r, numeric_fields),
    v3r_numeric_max_diff(driver, julia, numeric_fields)
  )
  if (!is.finite(maximum_difference) || maximum_difference > 1e-10) {
    v3r_abort("summary parity maximum difference exceeds 1e-10")
  }
  masked <- v3r_mask_common_infinities(list(driver, base_r, julia))
  v3p_adjudicate_summaries(masked[[1L]], masked[[2L]], masked[[3L]], stage)
  maximum_difference
}

v3r_adjudicate_tables <- function(state, evidence) {
  official <- v3r_read_rows(state, "official")
  source_hash <- vapply(official$paths, v07d_sha256, character(1L))
  v3p_adjudicate_attempts(
    official$table, evidence$base$table, evidence$julia$table,
    state$manifest, state$stage, state$binding, source_hash
  )
  official_admitted <- v3r_admit_rows(state, "official", official$table)
  base_admitted <- v3r_admit_rows(state, "base_r", evidence$base$table)
  julia_admitted <- v3r_admit_rows(state, "julia", evidence$julia$table)
  distinct <- c(
    "route", "r_implementation_commit", "julia_implementation_commit",
    "driver_commit", "preseal_sha256", "runtime_seconds", "peak_rss_mb"
  )
  compare <- setdiff(v3r_attempt_columns(state$stage), distinct)
  official_rows <- v3r_evidence_rows(official_admitted, state)
  base_rows <- v3r_evidence_rows(base_admitted, state)
  julia_rows <- v3r_evidence_rows(julia_admitted, state)
  numeric_attempt <- compare[vapply(
    official_rows[compare], is.numeric, logical(1L)
  )]
  attempt_max_diff <- max(
    v3r_numeric_max_diff(official_rows, base_rows, numeric_attempt),
    v3r_numeric_max_diff(official_rows, julia_rows, numeric_attempt)
  )
  if (!is.finite(attempt_max_diff) || attempt_max_diff > 1e-10) {
    v3r_abort("attempt parity maximum difference exceeds 1e-10")
  }
  driver <- v3r_expected_summary(state, official_admitted)
  base <- v3r_expected_summary(state, base_admitted)
  # Julia replay runtime/RSS are route diagnostics. Scientific summaries use
  # the official R performance fields, exactly as required by doc 49.
  julia_scientific <- v3r_project_julia_performance(
    julia_admitted, official_admitted
  )
  julia <- v3r_expected_summary(state, julia_scientific)
  summary_max_diff <- max(
    v3r_compare_summary_triplet(driver, base, julia, state$stage),
    v3r_compare_summary_triplet(
      driver, evidence$r_summary, evidence$j_summary, state$stage
    )
  )
  if (!is.finite(summary_max_diff) || summary_max_diff > 1e-10) {
    v3r_abort("summary parity maximum difference exceeds 1e-10")
  }
  list(
    summary = driver, attempt_max_diff = attempt_max_diff,
    summary_max_diff = summary_max_diff,
    admitted = list(
      official = official_admitted, base_r = base_admitted,
      julia = julia_scientific
    )
  )
}

v3r_verify_final_tree <- function(state, include_receipt = TRUE) {
  root <- state$root
  primaries <- file.path(
    root,
    v3p_preseal_names(
      state$stage, TRUE, bootstrap_materialized = identical(state$stage, "d0f")
    )
  )
  primaries <- c(
    primaries, file.path(root, "stage_corpus_lock.tsv"),
    vapply(seq_len(nrow(state$manifest)), function(i) {
      v3r_attempt_path(root, state$stage, state$manifest[i, , drop = FALSE])
    }, character(1L)),
    unlist(lapply(seq_len(nrow(state$manifest)), function(i) {
      file.path(
        v3r_packet_dir(root, state$stage, state$manifest[i, , drop = FALSE]),
        v3r_packet_primaries
      )
    }), use.names = FALSE),
    v3r_recompute_paths(state, "base_r"),
    v3r_recompute_paths(state, "julia"),
    file.path(root, paste0(state$stage, "_summary_r.tsv")),
    file.path(root, paste0(state$stage, "_summary_julia.tsv")),
    v3r_lineage_path(root),
    vapply(v3p_reviewers, function(reviewer) {
      v3r_review_path(root, reviewer)
    }, character(1L)),
    if (include_receipt) file.path(root, "stage_adjudication_receipt.tsv") else character()
  )
  expected <- unname(sort(c(
    substring(primaries, nchar(root) + 2L),
    paste0(substring(primaries, nchar(root) + 2L), ".sha256")
  )))
  v07d_verify_tree_membership(root, expected, "final stage tree")
  for (path in primaries) v3r_verify_pair(path)
  invisible(TRUE)
}

v3r_adjudication_key <- function(receipt_without_key) {
  if ("adjudication_key_sha256" %in% names(receipt_without_key)) {
    receipt_without_key <- receipt_without_key[
      setdiff(names(receipt_without_key), "adjudication_key_sha256")
    ]
  }
  receipt_without_key[] <- lapply(receipt_without_key, as.character)
  v3r_hash_text(v07d_tsv_text(receipt_without_key))
}

v3r_receipt_row <- function(
  state, evidence, reviews, summary, attempt_max_diff, summary_max_diff
) {
  review_values <- unlist(lapply(v3p_reviewers, function(reviewer) {
    c(
      file.path("postrun_receipts", paste0(reviewer, ".tsv")),
      reviews[[reviewer]]$sha256
    )
  }), use.names = FALSE)
  names(review_values) <- unlist(lapply(v3p_reviewers, function(reviewer) {
    c(paste0(reviewer, "_review_path"), paste0(reviewer, "_review_sha256"))
  }), use.names = FALSE)
  row <- c(
    schema_version = v3r_schema, stage = state$stage, verdict = "PASS",
    stage_decision = v3r_stage_decision(summary, state$stage),
    attempt_max_diff = sprintf("%.17g", attempt_max_diff),
    summary_max_diff = sprintf("%.17g", summary_max_diff),
    preseal_sha256 = state$preseal$sha256,
    corpus_lock_sha256 = state$corpus$sha256,
    manifest_sha256 = state$preseal$value[["manifest_sha256"]],
    r_driver_commit = state$preseal$value[["r_driver_commit"]],
    r_recomputer_commit = state$preseal$value[["r_recomputer_commit"]],
    julia_replay_commit = state$preseal$value[["julia_replay_commit"]],
    r_driver_sha256 = state$preseal$value[["r_driver_sha256"]],
    r_recomputer_sha256 = state$preseal$value[["r_recomputer_sha256"]],
    julia_replay_sha256 = state$preseal$value[["julia_replay_sha256"]],
    base_r_inventory_sha256 = evidence$base_r_inventory_sha256,
    julia_replay_inventory_sha256 = evidence$julia_replay_inventory_sha256,
    r_summary_sha256 = evidence$r_summary_sha256,
    julia_summary_sha256 = evidence$julia_summary_sha256,
    route_lineage_sha256 = evidence$route_lineage_sha256,
    review_values
  )
  key_source <- as.data.frame(as.list(row), stringsAsFactors = FALSE)
  adjudication_key_sha256 <- v3r_adjudication_key(key_source)
  row <- c(
    row[seq_len(match("route_lineage_sha256", names(row)))],
    adjudication_key_sha256 = adjudication_key_sha256,
    row[-seq_len(match("route_lineage_sha256", names(row)))]
  )
  out <- as.data.frame(as.list(row), stringsAsFactors = FALSE)
  out[v3r_receipt_columns]
}

v3r_review_paths <- function(root) {
  setNames(lapply(v3p_reviewers, function(reviewer) {
    v3r_review_path(root, reviewer)
  }), v3p_reviewers)
}

v3r_expected_final <- function(root, stage) {
  state <- v3r_read_stage(root, stage, runtime_phase = "final")
  evidence <- v3r_evidence(state)
  adjudication <- v3r_adjudicate_tables(state, evidence)
  v3r_validate_route_lineage(state, evidence, adjudication)
  summary <- adjudication$summary
  review_paths <- v3r_review_paths(state$root)
  decision <- v3r_stage_decision(summary, state$stage)
  reviews <- setNames(lapply(v3p_reviewers, function(reviewer) {
    v3r_validate_review(
      review_paths[[reviewer]], reviewer, state, evidence, decision
    )
  }), v3p_reviewers)
  list(
    state = state, evidence = evidence, summary = summary, reviews = reviews,
    receipt = v3r_receipt_row(
      state, evidence, reviews, summary, adjudication$attempt_max_diff,
      adjudication$summary_max_diff
    )
  )
}

v3r_ensure_exact_adjudication_receipt <- function(
  path, receipt, temporary_parent
) {
  sidecar <- paste0(path, ".sha256")
  primary_exists <- file.exists(path)
  sidecar_exists <- file.exists(sidecar)
  if (xor(primary_exists, sidecar_exists)) {
    v3r_abort("adjudication receipt primary/sidecar is orphaned")
  }
  if (!primary_exists) {
    v3r_write_once(path, receipt, temporary_parent = temporary_parent)
    return("created")
  }
  observed <- v3r_read_tsv(path, v3r_receipt_columns, all_character = TRUE)
  v3r_validate_receipt_row(observed, receipt)
  v3r_validate_exact_receipt_pair_bytes(path, receipt)
  "existing"
}

v3r_validate_exact_receipt_pair_bytes <- function(path, expected) {
  primary_expected <- charToRaw(enc2utf8(v07d_tsv_text(expected)))
  primary_observed <- readBin(
    path, what = "raw", n = file.info(path)$size
  )
  if (!identical(primary_observed, primary_expected)) {
    v3r_abort("adjudication receipt primary is not byte-identical")
  }
  digest <- v07d_sha256_raw(primary_expected)
  sidecar_path <- paste0(path, ".sha256")
  sidecar_expected <- charToRaw(sprintf(
    "%s  %s\n", digest, basename(path)
  ))
  sidecar_observed <- readBin(
    sidecar_path, what = "raw", n = file.info(sidecar_path)$size
  )
  if (!identical(sidecar_observed, sidecar_expected)) {
    v3r_abort("adjudication receipt sidecar is not byte-identical")
  }
  invisible(TRUE)
}

v3r_adjudicate <- function(root, stage) {
  final <- v3r_expected_final(root, stage)
  path <- file.path(final$state$root, "stage_adjudication_receipt.tsv")
  existing <- file.exists(path) && file.exists(paste0(path, ".sha256"))
  if (existing) {
    v3r_verify_final_tree(final$state, include_receipt = TRUE)
  } else if (!file.exists(path) && !file.exists(paste0(path, ".sha256"))) {
    v3r_verify_final_tree(final$state, include_receipt = FALSE)
  }
  status <- v3r_ensure_exact_adjudication_receipt(
    path, final$receipt, dirname(final$state$root)
  )
  v3r_verify_final_tree(final$state, include_receipt = TRUE)
  message(sprintf(
    "%s %s adjudication receipt decision=%s sha256=%s",
    if (identical(status, "created")) "wrote" else "verified existing",
    stage, final$receipt$stage_decision, v07d_sha256(path)
  ))
  invisible(final$receipt)
}

v3r_validate_receipt_row <- function(observed, expected) {
  v3p_require_schema(observed, v3r_receipt_columns, "adjudication receipt")
  v3p_require_schema(expected, v3r_receipt_columns, "expected adjudication receipt")
  if (nrow(observed) != 1L || observed$verdict != "PASS") {
    v3r_abort("adjudication receipt does not contain one PASS row")
  }
  attempt_diff <- suppressWarnings(as.numeric(observed$attempt_max_diff))
  summary_diff <- suppressWarnings(as.numeric(observed$summary_max_diff))
  if (
    !is.finite(attempt_diff) || attempt_diff < 0 || attempt_diff > 1e-10 ||
      !is.finite(summary_diff) || summary_diff < 0 || summary_diff > 1e-10
  ) {
    v3r_abort("adjudication receipt parity maximum exceeds 1e-10")
  }
  if (!v3p_hex64(observed$adjudication_key_sha256[[1L]]) ||
      !identical(
        observed$adjudication_key_sha256[[1L]],
        v3r_adjudication_key(observed)
      )) {
    v3r_abort("adjudication receipt key is invalid")
  }
  if (!v3r_same_text_table(observed, expected)) {
    v3r_abort("adjudication receipt differs from the current exact evidence")
  }
  invisible(TRUE)
}

v3r_validate_final <- function(root, stage) {
  root <- v3r_canonical_dir(root, "stage output root")
  receipt_path <- file.path(root, "stage_adjudication_receipt.tsv")
  observed <- v3r_read_tsv(
    receipt_path, v3r_receipt_columns, all_character = TRUE
  )
  if (nrow(observed) != 1L) v3r_abort("adjudication receipt must have one row")
  final <- v3r_expected_final(root, stage)
  v3r_validate_receipt_row(observed, final$receipt)
  v3r_validate_exact_receipt_pair_bytes(receipt_path, final$receipt)
  v3r_verify_final_tree(final$state)
  message(sprintf(
    "validated %s final receipt decision=%s sha256=%s",
    stage, observed$stage_decision, v07d_sha256(receipt_path)
  ))
  invisible(observed)
}

v3r_selftest <- function() {
  h64 <- function(x) paste(rep(x, 64L), collapse = "")
  h40 <- function(x) paste(rep(x, 40L), collapse = "")
  binding <- list(
    preseal_sha256 = h64("e"), manifest_sha256 = h64("f"),
    corpus_lock_sha256 = h64("a"), r_auto_route_commit = h40("a"),
    julia_candidate_commit = h40("b"), r_driver_commit = h40("c"),
    julia_replay_commit = h40("d"), julia_replay_sha256 = h64("b")
  )
  d1 <- v3p_d1_summary_parity_fixture(binding)
  stopifnot(
    nrow(d1$summary) == 36L,
    identical(v3r_stage_decision(d1$summary, "d1"), "ELIGIBLE=12")
  )
  changed <- d1$summary
  changed$mean_estimate[[1L]] <- changed$mean_estimate[[1L]] + 1e-5
  stopifnot(inherits(
    try(v3p_adjudicate_summaries(d1$summary, d1$summary, changed, "d1"),
      silent = TRUE),
    "try-error"
  ))
  d0f <- v3p_d0f_summary_parity_fixture(binding)
  stopifnot(nrow(d0f$summary) == 3L, v3r_stage_decision(d0f$summary, "d0f") == "COMPLETE")
  message("recovery-v3 base-R recomputation/adjudication selftest: PASS")
  invisible(TRUE)
}

v3r_main <- function(
  args = commandArgs(trailingOnly = TRUE),
  execution_guard = v3r_assert_execution_context
) {
  explicit_mode <- v3r_option(args, "mode")
  positional <- args[!startsWith(args, "--")]
  if (!is.null(explicit_mode) && length(positional)) {
    v3r_abort("select mode either positionally or with --mode, not both")
  }
  mode <- if (!is.null(explicit_mode)) {
    explicit_mode
  } else if (length(positional) == 1L) {
    positional[[1L]]
  } else if (!length(positional)) {
    "selftest"
  } else {
    v3r_abort("exactly one positional mode is allowed")
  }
  if (mode == "selftest") return(v3r_selftest())
  execution_guard()
  root <- v3r_required(args, "output-root")
  stage <- v3r_stage(v3r_required(args, "stage"))
  if (mode == "recompute-one") {
    group <- v3r_required(args, "group")
    seed <- v3r_required(args, "seed")
    return(v3r_recompute_one(
      root, stage, group, seed
    ))
  }
  if (mode == "write-batch-plan") {
    return(v3r_write_batch_plan(
      root, stage, v3r_required(args, "batch-plan"),
      v3r_required(args, "batch-size")
    ))
  }
  if (mode == "validate-batch-plan") {
    return(v3r_validate_batch_plan(
      root, stage, v3r_required(args, "batch-plan")
    ))
  }
  if (mode == "authenticate-batch-plan") {
    return(v3r_authenticate_batch_plan(
      root, stage, v3r_required(args, "batch-plan")
    ))
  }
  if (mode == "recompute-batch") {
    return(v3r_recompute_batch(
      root, stage, v3r_required(args, "batch-plan"),
      v3r_required(args, "batch-id")
    ))
  }
  if (mode == "summarize") return(v3r_summarize(root, stage))
  if (mode == "write-route-lineage") {
    return(v3r_write_route_lineage(root, stage))
  }
  if (mode == "write-postrun-review") {
    return(v3r_write_postrun_review(
      root, stage, v3r_required(args, "reviewer"),
      v3r_required(args, "verdict"), v3r_option(args, "receipt"),
      v3r_required(args, "reviewed-at-utc")
    ))
  }
  if (mode == "adjudicate") {
    return(v3r_adjudicate(root, stage))
  }
  if (mode == "validate-final") {
    return(v3r_validate_final(root, stage))
  }
  v3r_abort(
    paste(
      "mode must be selftest, recompute-one, write-batch-plan,",
      "validate-batch-plan, authenticate-batch-plan, recompute-batch, summarize,",
      "write-route-lineage, write-postrun-review, adjudicate, or validate-final"
    )
  )
}

if (sys.nframe() == 0L) v3r_main()
