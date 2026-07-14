#!/usr/bin/env Rscript

# Pure, source-safe pre-seal tooling for recovery-v3 D0F and D1. This file may
# construct and validate manifests and synthetic summaries, but it deliberately
# contains no marker draw, phenotype draw, Julia RNG, fit call, campaign seal,
# or command that can launch official recovery seeds.

v3p_abort <- function(...) stop(sprintf(...), call. = FALSE)

v3p_decode_command_path <- function(path) {
  gsub("~+~", " ", path, fixed = TRUE)
}

v3p_script_path <- function() {
  frames <- sys.frames()
  paths <- vapply(frames, function(frame) {
    value <- frame$ofile
    if (is.null(value)) "" else as.character(value)
  }, character(1L))
  hits <- paths[basename(paths) == "v07_genomic_recovery_v3_preseal.R"]
  if (length(hits)) {
    return(normalizePath(tail(hits, 1L), winslash = "/", mustWork = TRUE))
  }
  args <- commandArgs(FALSE)
  file_arg <- sub("^--file=", "", grep("^--file=", args, value = TRUE))
  if (length(file_arg)) {
    file_arg <- v3p_decode_command_path(file_arg[[1L]])
    return(normalizePath(file_arg, winslash = "/", mustWork = TRUE))
  }
  v3p_abort("cannot locate the recovery-v3 pre-seal tool")
}

v3p_loaded_path <- v3p_script_path()

v3p_source_seed_lock <- function(path, envir) {
  path <- normalizePath(path, winslash = "/", mustWork = TRUE)
  expressions <- parse(path, keep.source = TRUE)
  is_source_capture <- vapply(expressions, function(expression) {
    is.call(expression) && identical(as.character(expression[[1L]]), "<-") &&
      identical(as.character(expression[[2L]]), "v07s_loaded_source_path")
  }, logical(1L))
  if (sum(is_source_capture) != 1L) {
    v3p_abort("seed-lock source-path contract drift")
  }
  assign("v07s_loaded_source_path", path, envir = envir)
  for (expression in expressions[!is_source_capture]) {
    eval(expression, envir = envir)
  }
  invisible(TRUE)
}

v3p_load_dependencies <- function() {
  root <- dirname(v3p_script_path())
  target <- parent.frame()
  if (!exists("v3_d1_manifest", envir = target, inherits = TRUE)) {
    sys.source(
      file.path(root, "v07_genomic_recovery_v3_state_machine.R"),
      envir = target
    )
  }
  if (!exists("v07d_verify_corpus", envir = target, inherits = TRUE)) {
    sys.source(
      file.path(root, "v07_genomic_recovery_v3_d0_recompute.R"),
      envir = target
    )
  }
  if (!exists("v07s_validate_spaces", envir = target, inherits = TRUE)) {
    v3p_source_seed_lock(
      file.path(root, "v07_genomic_recovery_v3_seed_lock.R"), target
    )
  }
  invisible(TRUE)
}

v3p_load_dependencies()

v3p_hex40 <- function(x) {
  length(x) == 1L && !is.na(x) && grepl("^[0-9a-f]{40}$", x)
}

v3p_hex64 <- function(x) {
  length(x) == 1L && !is.na(x) && grepl("^[0-9a-f]{64}$", x)
}

v3p_bool <- function(x, field) {
  if (is.logical(x) && !anyNA(x)) return(x)
  value <- as.character(x)
  if (anyNA(value) || any(!value %in% c("true", "false"))) {
    v3p_abort("invalid logical value in %s", field)
  }
  value == "true"
}

v3p_num <- function(x, field, finite = TRUE) {
  value <- suppressWarnings(as.numeric(x))
  canonical_na <- is.na(x) | (!is.na(x) & as.character(x) == "NA")
  bad <- is.na(value) & !canonical_na
  if (any(bad) || (finite && any(!is.finite(value)))) {
    v3p_abort("invalid numeric value in %s", field)
  }
  value
}

v3p_same_numeric <- function(x, y, tolerance = 0) {
  x <- suppressWarnings(as.numeric(x))
  y <- suppressWarnings(as.numeric(y))
  if (length(x) != length(y)) return(FALSE)
  both_na <- is.na(x) & is.na(y)
  if (any(xor(is.na(x), is.na(y)))) return(FALSE)
  finite <- !both_na
  all(abs(x[finite] - y[finite]) <= tolerance)
}

v3p_require_schema <- function(x, columns, label) {
  if (!is.data.frame(x) || !identical(names(x), columns)) {
    v3p_abort("%s schema or column order drift", label)
  }
  invisible(x)
}

v3p_real_dir <- function(path, label) {
  if (!dir.exists(path) || v07d_has_symlink_component(path)) {
    v3p_abort("%s must be an existing real directory", label)
  }
  normalizePath(path, winslash = "/", mustWork = TRUE)
}

v3p_write_once <- function(root, name, object) {
  root <- v3p_real_dir(root, "pre-seal output root")
  if (
    length(name) != 1L || is.na(name) || !nzchar(name) ||
      basename(name) != name || name %in% c(".", "..")
  ) {
    v3p_abort("create-once output name must be one safe basename")
  }
  v07d_write_once(file.path(root, name), v07d_tsv_text(object))
}

v3p_environment_keys <- c(
  "stage", "host", "r_version", "r_rng_kind", "r_normal_kind",
  "r_sample_kind", "julia_version", "openblas_num_threads",
  "julia_num_threads", "max_workers"
)

v3p_environment_manifest <- function(values) {
  if (is.null(names(values)) || !setequal(names(values), v3p_environment_keys)) {
    v3p_abort("environment values must cover every frozen key")
  }
  out <- data.frame(
    key = v3p_environment_keys,
    value = as.character(values[v3p_environment_keys]),
    stringsAsFactors = FALSE
  )
  v3p_validate_environment(out)
}

v3p_validate_environment <- function(x) {
  v3p_require_schema(x, c("key", "value"), "environment manifest")
  if (
    !identical(as.character(x$key), v3p_environment_keys) ||
      anyNA(x$value) || any(!nzchar(x$value))
  ) {
    v3p_abort("environment key membership or value drift")
  }
  value <- setNames(as.character(x$value), x$key)
  workers <- suppressWarnings(as.integer(value[["max_workers"]]))
  if (
    !value[["stage"]] %in% c("d0f", "d1") ||
      !value[["host"]] %in% c(
        "totoro", "fir", "nibi", "rorqual", "trillium", "narval"
      ) ||
      value[["r_rng_kind"]] != "Mersenne-Twister" ||
      value[["r_normal_kind"]] != "Inversion" ||
      value[["r_sample_kind"]] != "Rejection" ||
      value[["openblas_num_threads"]] != "1" ||
      value[["julia_num_threads"]] != "1" ||
      is.na(workers) || workers < 1L || workers > 96L
  ) {
    v3p_abort("environment stage, host, RNG, thread, or worker contract drift")
  }
  x
}

v3p_normalize_host <- function() {
  allowed <- c("totoro", "fir", "nibi", "rorqual", "trillium", "narval")
  cluster <- tolower(Sys.getenv("SLURM_CLUSTER_NAME", unset = ""))
  if (cluster %in% allowed) return(cluster)
  host <- tolower(strsplit(Sys.info()[["nodename"]], ".", fixed = TRUE)[[1L]][[1L]])
  matched <- allowed[vapply(
    allowed, function(prefix) startsWith(host, prefix), logical(1L)
  )]
  if (length(matched) != 1L) {
    v3p_abort("live host is not Totoro or an admitted DRAC cluster")
  }
  matched[[1L]]
}

v3p_capture_live_environment <- function(stage, max_workers) {
  thread_vars <- c(
    "OPENBLAS_NUM_THREADS", "JULIA_NUM_THREADS", "OMP_NUM_THREADS",
    "MKL_NUM_THREADS", "VECLIB_MAXIMUM_THREADS", "NUMEXPR_NUM_THREADS"
  )
  thread_values <- Sys.getenv(thread_vars, unset = "")
  if (
    thread_values[["OPENBLAS_NUM_THREADS"]] != "1" ||
      thread_values[["JULIA_NUM_THREADS"]] != "1" ||
      any(nzchar(thread_values) & thread_values != "1")
  ) {
    v3p_abort("live process thread variables are not pinned to one")
  }
  julia <- Sys.which("julia")
  if (!nzchar(julia)) v3p_abort("Julia is required for live environment admission")
  code <- paste(
    "using LinearAlgebra;",
    "print(VERSION, '\\t', BLAS.get_num_threads(), '\\t', Threads.nthreads())"
  )
  observed <- system2(
    julia,
    c("--startup-file=no", "--history-file=no", "-e", shQuote(code)),
    stdout = TRUE, stderr = TRUE
  )
  status <- attr(observed, "status")
  if ((!is.null(status) && status != 0L) || length(observed) != 1L) {
    v3p_abort("cannot query live Julia version, BLAS threads, and Julia threads")
  }
  julia_state <- strsplit(trimws(observed[[1L]]), "\t", fixed = TRUE)[[1L]]
  if (
    length(julia_state) != 3L || julia_state[[2L]] != "1" ||
      julia_state[[3L]] != "1"
  ) {
    v3p_abort("live Julia BLAS or Julia thread count is not one")
  }
  kind <- RNGkind()
  v3p_environment_manifest(c(
    stage = stage,
    host = v3p_normalize_host(),
    r_version = as.character(getRversion()),
    r_rng_kind = kind[[1L]],
    r_normal_kind = kind[[2L]],
    r_sample_kind = kind[[3L]],
    julia_version = julia_state[[1L]],
    openblas_num_threads = thread_values[["OPENBLAS_NUM_THREADS"]],
    julia_num_threads = julia_state[[3L]],
    max_workers = as.character(max_workers)
  ))
}

v3p_validate_environment_live <- function(x) {
  x <- v3p_validate_environment(x)
  value <- setNames(as.character(x$value), x$key)
  live <- v3p_capture_live_environment(
    value[["stage"]], as.integer(value[["max_workers"]])
  )
  if (!identical(as.character(x$value), as.character(live$value))) {
    v3p_abort("environment manifest differs from live host or toolchain state")
  }
  x
}

v3p_stage_preseal_keys <- c(
  "schema_version", "stage", "doc49_sha256", "cell_table_sha256",
  "manifest_sha256", "environment_manifest_sha256", "d0_output_root",
  "d0_adjudication_receipt_sha256", "d0_diagnostics_sha256",
  "d0f_adjudication_root", "d0f_adjudication_receipt_sha256",
  "historical_seed_lock_sha256",
  "d0f_fixed_panel_manifest_sha256", "d0f_bootstrap_indices_sha256",
  "fisher_receipt_sha256", "noether_receipt_sha256",
  "hopper_receipt_sha256", "grace_receipt_sha256", "rose_receipt_sha256",
  "r_driver_commit", "r_recomputer_commit", "julia_replay_commit",
  "r_auto_route_commit", "julia_candidate_commit", "r_driver_sha256",
  "r_recomputer_sha256", "julia_replay_sha256", "d0_recomputer_sha256",
  "output_root", "official_route", "replay_route", "packet_schema_version",
  "truth_schema_version", "relationship_source", "relationship_method",
  "allele_frequency_source", "relationship_scale", "ridge",
  "boundary_epsilon", "boundary_kkt_tolerance",
  "output_subtrees_absent_before_preseal"
)

v3p_cell_table_columns <- c(
  "cell_id", "cell_index", "n", "m", "marker_ratio",
  "marker_ratio_code", "truth_sigma_g2", "truth_sigma_e2", "truth_ratio",
  "ridge"
)

v3p_cell_table <- function() {
  out <- v3_cell_table[v3p_cell_table_columns]
  out$truth_sigma_e2 <- unname(c(`0.2` = 0.8, `0.5` = 0.5, `0.8` = 0.2)[
    as.character(out$truth_ratio)
  ])
  out
}

v3p_validate_cell_table <- function(x) {
  v3p_require_schema(x, v3p_cell_table_columns, "canonical cell table")
  expected <- v3p_cell_table()
  if (!identical(as.character(x$cell_id), as.character(expected$cell_id))) {
    v3p_abort("canonical cell-table membership or order drift")
  }
  numeric <- setdiff(v3p_cell_table_columns, c("cell_id", "marker_ratio_code"))
  for (field in numeric) {
    tolerance <- if (field == "marker_ratio") 1e-12 else 0
    if (!v3p_same_numeric(x[[field]], expected[[field]], tolerance)) {
      v3p_abort("canonical cell-table mismatch in %s", field)
    }
  }
  if (!identical(
    as.character(x$marker_ratio_code), as.character(expected$marker_ratio_code)
  )) {
    v3p_abort("canonical cell-table marker-ratio code drift")
  }
  x
}

v3p_review_columns <- c(
  "reviewer", "verdict", "doc49_sha256", "r_driver_commit",
  "r_recomputer_commit", "julia_replay_commit", "r_auto_route_commit",
  "julia_candidate_commit"
)
v3p_reviewers <- c("fisher", "noether", "hopper", "grace", "rose")
v3p_d0f_blocked_root <-
  "/home/snakagaw/hsq_work/v07-genomic-recovery-v3-d0f-official-0a9d882-1a538212"
v3p_d0f_adjudication_schema <- "v07-genomic-recovery-v3-adjudication-1"
v3p_d0f_adjudication_columns <- c(
  "schema_version", "stage", "verdict", "stage_decision",
  "attempt_max_diff", "summary_max_diff",
  "preseal_sha256", "corpus_lock_sha256", "manifest_sha256",
  "r_driver_commit", "r_recomputer_commit", "julia_replay_commit",
  "r_driver_sha256", "r_recomputer_sha256", "julia_replay_sha256",
  "base_r_inventory_sha256", "julia_replay_inventory_sha256",
  "r_summary_sha256", "julia_summary_sha256",
  unlist(lapply(v3p_reviewers, function(x) {
    c(paste0(x, "_review_path"), paste0(x, "_review_sha256"))
  }), use.names = FALSE)
)

v3p_canonical_path <- function(path, label, directory = FALSE) {
  if (
    length(path) != 1L || is.na(path) || !nzchar(path) ||
      !startsWith(path, "/") || v07d_has_symlink_component(path) ||
      (directory && !dir.exists(path)) ||
      (!directory && (!file.exists(path) || isTRUE(file.info(path)$isdir)))
  ) {
    v3p_abort("%s is not an existing canonical plain path", label)
  }
  canonical <- normalizePath(path, winslash = "/", mustWork = TRUE)
  if (!identical(path, canonical)) {
    v3p_abort("%s textual path is not canonical", label)
  }
  canonical
}

v3p_verify_pair <- function(path, expected_hash, label) {
  path <- v3p_canonical_path(path, label)
  sidecar <- paste0(path, ".sha256")
  v3p_canonical_path(sidecar, paste(label, "sidecar"))
  if (!all(v07d_is_regular_file(c(path, sidecar)))) {
    v3p_abort("%s primary/sidecar is not a regular-file pair", label)
  }
  size <- file.info(c(path, sidecar))$size
  if (anyNA(size) || any(size <= 0)) {
    v3p_abort("%s primary/sidecar must both be nonempty", label)
  }
  v07d_verify_pair(path, expected_hash)
  invisible(path)
}

v3p_roots_nonnested <- function(left, right, left_label, right_label) {
  left <- paste0(v3p_canonical_path(left, left_label, TRUE), "/")
  right <- paste0(v3p_canonical_path(right, right_label, TRUE), "/")
  if (identical(left, right) || startsWith(left, right) || startsWith(right, left)) {
    v3p_abort("%s and %s must be distinct and nonnested", left_label, right_label)
  }
  invisible(TRUE)
}

v3p_validate_d0_receipt_root <- function(root, expected_hash) {
  if (
    !identical(
      root,
      "/home/snakagaw/hsq_work/v07-genomic-recovery-v3-d0-official-cdb33dc-4c5e54de"
    ) ||
      !identical(
        expected_hash,
        "190b6546fab8caeec24683c4f7bee8063ada671c220852c9372e5db194b2886a"
      )
  ) {
    v3p_abort("official D0 root or adjudication receipt hash differs from doc 49")
  }
  root <- v3p_canonical_path(root, "official D0 replay root", TRUE)
  path <- file.path(root, "receipt", "d0-check-log.md")
  v3p_verify_pair(path, expected_hash, "official D0 receipt")
  invisible(root)
}

v3p_validate_frozen_d0_artifacts <- function(
  root, receipt_hash, diagnostics_hash
) {
  root <- v3p_validate_d0_receipt_root(root, receipt_hash)
  if (!identical(
    diagnostics_hash,
    "7c1cbc165df90e844bd4fdc7fc6ffb6dcbb8343c0d5ca9e7a588e4ca6d48c370"
  )) {
    v3p_abort("official D0 diagnostics hash differs from doc 49")
  }
  diagnostics_path <- file.path(root, "r", "d0_packet_diagnostics_base_r.tsv")
  v3p_verify_pair(
    diagnostics_path, diagnostics_hash, "official D0 base-R diagnostics"
  )
  list(root = root, diagnostics_path = diagnostics_path)
}

v3p_validate_successful_d0f_adjudication <- function(
  root, expected_hash = NULL, d1_root = NULL
) {
  root <- v3p_canonical_path(root, "fresh D0F adjudication root", TRUE)
  if (identical(root, v3p_d0f_blocked_root)) {
    v3p_abort("blocked unadjudicated D0F root cannot admit D1")
  }
  if (!is.null(d1_root)) {
    v3p_roots_nonnested(
      root, d1_root, "fresh D0F adjudication root", "D1 stage root"
    )
  }
  path <- file.path(root, "stage_adjudication_receipt.tsv")
  if (is.null(expected_hash)) {
    if (!file.exists(path) || isTRUE(file.info(path)$isdir)) {
      v3p_abort("fresh D0F adjudication receipt primary is missing")
    }
    expected_hash <- v07d_sha256(path)
  }
  if (!v3p_hex64(expected_hash)) {
    v3p_abort("fresh D0F adjudication receipt hash is invalid")
  }
  v3p_verify_pair(path, expected_hash, "fresh D0F adjudication receipt")
  receipt <- v07d_read_tsv(
    path, v3p_d0f_adjudication_columns, verify = FALSE
  )
  if (
    nrow(receipt) != 1L ||
      receipt$schema_version[[1L]] != v3p_d0f_adjudication_schema ||
      receipt$stage[[1L]] != "d0f" || receipt$verdict[[1L]] != "PASS" ||
      receipt$stage_decision[[1L]] != "COMPLETE"
  ) {
    v3p_abort("D0F receipt is not one adjudicated PASS/COMPLETE d0f row")
  }
  attempt_diff <- suppressWarnings(as.numeric(receipt$attempt_max_diff[[1L]]))
  summary_diff <- suppressWarnings(as.numeric(receipt$summary_max_diff[[1L]]))
  if (
    !is.finite(attempt_diff) || attempt_diff < 0 || attempt_diff > 1e-10 ||
      !is.finite(summary_diff) || summary_diff < 0 || summary_diff > 1e-10
  ) {
    v3p_abort("D0F adjudication parity maximum exceeds 1e-10")
  }
  hash_columns <- grep("_sha256$", names(receipt), value = TRUE)
  commit_columns <- grep("_commit$", names(receipt), value = TRUE)
  if (
    any(!vapply(unlist(receipt[hash_columns], use.names = FALSE),
      v3p_hex64, logical(1L))) ||
      any(!vapply(unlist(receipt[commit_columns], use.names = FALSE),
        v3p_hex40, logical(1L)))
  ) {
    v3p_abort("D0F adjudication receipt provenance is invalid")
  }
  expected_review_paths <- file.path(
    "postrun_receipts", paste0(v3p_reviewers, ".tsv")
  )
  if (!identical(
    unname(as.character(unlist(
      receipt[paste0(v3p_reviewers, "_review_path")], use.names = FALSE
    ))),
    expected_review_paths
  )) {
    v3p_abort("D0F adjudication receipt review paths are invalid")
  }
  v3p_validate_d0f_final_tree(root)
  list(root = root, receipt_path = path, receipt_sha256 = expected_hash)
}

v3p_validate_d0f_final_tree <- function(root) {
  target <- environment(v3p_validate_d0f_final_tree)
  if (!exists("v3r_validate_final", envir = target, inherits = FALSE)) {
    sys.source(
      file.path(dirname(v3p_loaded_path), "v07_genomic_recovery_v3_recompute.R"),
      envir = target
    )
  }
  get("v3r_validate_final", envir = target, inherits = FALSE)(root, "d0f")
  invisible(TRUE)
}

v3p_git_clean <- function(root) {
  root <- v3p_canonical_path(root, "deployed git root", TRUE)
  git <- Sys.which("git")
  status <- system2(
    git, c("-C", shQuote(root), "status", "--porcelain"),
    stdout = TRUE, stderr = TRUE
  )
  exit <- attr(status, "status")
  if ((!is.null(exit) && exit != 0L) || length(status)) {
    v3p_abort("deployed implementation worktree is dirty")
  }
  invisible(root)
}

v3p_git_ancestor <- function(root, ancestor, descendant, label) {
  root <- v3p_canonical_path(root, paste(label, "git root"), TRUE)
  git <- Sys.which("git")
  status <- system2(
    git,
    c(
      "-C", shQuote(root), "merge-base", "--is-ancestor",
      shQuote(ancestor), shQuote(descendant)
    ),
    stdout = FALSE, stderr = FALSE
  )
  if (status != 0L) {
    v3p_abort("%s candidate commit is not an ancestor of the deployed tool commit", label)
  }
  invisible(TRUE)
}

v3p_git_unchanged <- function(root, from, to, paths, label) {
  root <- v3p_canonical_path(root, paste(label, "git root"), TRUE)
  prefix <- paste0(root, "/")
  paths <- vapply(paths, function(path) {
    path <- v3p_canonical_path(path, paste(label, "surface"), file.info(path)$isdir)
    if (!startsWith(path, prefix)) {
      v3p_abort("%s surface is outside its deployed git root", label)
    }
    substring(path, nchar(prefix) + 1L)
  }, character(1L))
  git <- Sys.which("git")
  status <- system2(
    git,
    c(
      "-C", shQuote(root), "diff", "--quiet", shQuote(from), shQuote(to),
      "--", shQuote(paths)
    ),
    stdout = FALSE, stderr = FALSE
  )
  if (status != 0L) {
    v3p_abort("%s changed between candidate and deployed commits", label)
  }
  invisible(TRUE)
}

v3p_git_head <- function(root) {
  root <- v3p_canonical_path(root, "deployed git root", TRUE)
  git <- Sys.which("git")
  if (!nzchar(git)) v3p_abort("git is required for deployed commit admission")
  head <- system2(git, c("-C", shQuote(root), "rev-parse", "HEAD"), stdout = TRUE)
  status <- attr(head, "status")
  if (!is.null(status) && status != 0L) v3p_abort("cannot read deployed git HEAD")
  head <- trimws(head[[1L]])
  if (!v3p_hex40(head)) v3p_abort("deployed git HEAD is invalid")
  head
}

v3p_verify_tool_at_commit <- function(root, path, commit, expected_hash, label) {
  root <- v3p_canonical_path(root, paste(label, "git root"), TRUE)
  path <- v3p_verify_pair(path, expected_hash, label)
  prefix <- paste0(root, "/")
  if (!startsWith(path, prefix)) {
    v3p_abort("%s is outside its deployed git root", label)
  }
  relative <- substring(path, nchar(prefix) + 1L)
  git <- Sys.which("git")
  tmp <- tempfile("v3p-git-blob-")
  on.exit(unlink(tmp), add = TRUE)
  status <- system2(
    git,
    c("-C", shQuote(root), "show", shQuote(paste0(commit, ":", relative))),
    stdout = tmp,
    stderr = FALSE
  )
  if (status != 0L || !file.exists(tmp) || v07d_sha256(tmp) != expected_hash) {
    v3p_abort("%s bytes are not the exact committed tool", label)
  }
  invisible(path)
}

v3p_preseal_names <- function(stage, include_preseal = TRUE) {
  common <- c(
    "doc49.md", "cell_table.tsv", "historical_seed_lock.tsv",
    paste0(stage, "_manifest.tsv"), "environment_manifest.tsv",
    file.path("receipts", paste0(v3p_reviewers, ".tsv"))
  )
  if (stage == "d0f") {
    common <- c(
      common, "d0f_fixed_panel_manifest.tsv", "d0f_bootstrap_indices.tsv"
    )
  }
  if (include_preseal) common <- c(common, "stage_preseal.tsv")
  common
}

v3p_verify_preseal_tree <- function(root, stage, include_preseal) {
  root <- v3p_canonical_path(root, "stage output root", TRUE)
  primaries <- v3p_preseal_names(stage, include_preseal)
  expected_files <- sort(c(primaries, paste0(primaries, ".sha256")))
  expected <- sort(c("receipts", expected_files))
  actual <- sort(list.files(
    root, recursive = TRUE, all.files = TRUE, include.dirs = TRUE,
    no.. = TRUE
  ))
  if (!identical(actual, expected)) {
    v3p_abort("preseal input tree has missing, additional, nested, or special members")
  }
  files <- file.path(root, expected_files)
  if (!all(v07d_is_regular_file(files))) {
    v3p_abort("preseal input tree contains a non-regular file")
  }
  primaries <- file.path(root, primaries)
  size <- file.info(primaries)$size
  if (anyNA(size) || any(size <= 0)) {
    v3p_abort("preseal input tree contains an empty required primary")
  }
  invisible(TRUE)
}

v3p_validate_review <- function(path, expected_hash, reviewer, values) {
  v3p_verify_pair(path, expected_hash, paste(reviewer, "review receipt"))
  x <- v07d_read_tsv(path, v3p_review_columns, verify = FALSE)
  if (
    nrow(x) != 1L || x$reviewer[[1L]] != reviewer ||
      x$verdict[[1L]] != "CLEAN" ||
      x$doc49_sha256[[1L]] != values[["doc49_sha256"]] ||
      x$r_driver_commit[[1L]] != values[["r_driver_commit"]] ||
      x$r_recomputer_commit[[1L]] != values[["r_recomputer_commit"]] ||
      x$julia_replay_commit[[1L]] != values[["julia_replay_commit"]] ||
      x$r_auto_route_commit[[1L]] != values[["r_auto_route_commit"]] ||
      x$julia_candidate_commit[[1L]] != values[["julia_candidate_commit"]]
  ) {
    v3p_abort("%s review receipt does not bind the exact preseal plan", reviewer)
  }
  invisible(x)
}

v3p_validate_stage_preseal <- function(
  x, context, include_preseal = TRUE, bootstrap_reps = 10000L
) {
  v3p_require_schema(x, c("key", "value"), "recovery-v3 stage preseal")
  if (!identical(as.character(x$key), v3p_stage_preseal_keys)) {
    v3p_abort("recovery-v3 stage preseal key membership or value drift")
  }
  raw_value <- as.character(x$value)
  names(raw_value) <- x$key
  d0f_only <- c(
    "d0f_fixed_panel_manifest_sha256", "d0f_bootstrap_indices_sha256"
  )
  d1_only <- c(
    "d0f_adjudication_root", "d0f_adjudication_receipt_sha256"
  )
  stage <- raw_value[["stage"]]
  allowed_na <- if (identical(stage, "d1")) d0f_only else d1_only
  if (
    any(is.na(raw_value[setdiff(names(raw_value), allowed_na)])) ||
      any(!is.na(raw_value) & !nzchar(raw_value)) ||
      (identical(stage, "d1") &&
        !all(is.na(raw_value[d0f_only]) | raw_value[d0f_only] == "NA")) ||
      (identical(stage, "d0f") &&
        !all(is.na(raw_value[d1_only]) | raw_value[d1_only] == "NA"))
  ) {
    v3p_abort("recovery-v3 stage preseal key membership or value drift")
  }
  raw_value[is.na(raw_value)] <- "NA"
  value <- raw_value
  if (
    value[["schema_version"]] != "v07-genomic-recovery-v3-stage-preseal-2" ||
      !value[["stage"]] %in% c("d0f", "d1") ||
      value[["official_route"]] != "ordinary_auto_genomic" ||
      value[["replay_route"]] != "julia_profile_replay" ||
      value[["packet_schema_version"]] != "v07-genomic-recovery-v3-packet-1" ||
      value[["truth_schema_version"]] != "v07-genomic-recovery-v3-truth-1" ||
      value[["relationship_source"]] != "markers" ||
      value[["relationship_method"]] != "vanraden1" ||
      value[["allele_frequency_source"]] != "sample" ||
      value[["relationship_scale"]] != "K_lambda" ||
      value[["ridge"]] != "0.01" ||
      value[["boundary_epsilon"]] != "1e-07" ||
      value[["boundary_kkt_tolerance"]] != "1e-08"
  ) {
    v3p_abort("recovery-v3 stage preseal scientific contract drift")
  }
  absent <- v3p_bool(
    value[["output_subtrees_absent_before_preseal"]],
    "output_subtrees_absent_before_preseal"
  )
  if (!absent) v3p_abort("output subtrees were not absent before presealing")
  commits <- c(
    "r_driver_commit", "r_recomputer_commit", "julia_replay_commit",
    "r_auto_route_commit", "julia_candidate_commit"
  )
  hashes <- c(
    "doc49_sha256", "cell_table_sha256", "manifest_sha256",
    "environment_manifest_sha256", "d0_adjudication_receipt_sha256",
    "d0_diagnostics_sha256", "historical_seed_lock_sha256",
    paste0(v3p_reviewers, "_receipt_sha256"),
    "r_driver_sha256", "r_recomputer_sha256", "julia_replay_sha256",
    "d0_recomputer_sha256"
  )
  if (
    any(!vapply(value[commits], v3p_hex40, logical(1L))) ||
      any(!vapply(value[hashes], v3p_hex64, logical(1L))) ||
      (value[["stage"]] == "d0f" && any(!vapply(
        value[c(
          "d0f_fixed_panel_manifest_sha256", "d0f_bootstrap_indices_sha256"
        )],
        v3p_hex64,
        logical(1L)
      ))) ||
      (value[["stage"]] == "d1" && any(value[c(
        "d0f_fixed_panel_manifest_sha256", "d0f_bootstrap_indices_sha256"
      )] != "NA")) ||
      (value[["stage"]] == "d1" &&
        !v3p_hex64(value[["d0f_adjudication_receipt_sha256"]])) ||
      (value[["stage"]] == "d0f" && any(value[d1_only] != "NA"))
  ) {
    v3p_abort("recovery-v3 stage preseal commit or digest binding is invalid")
  }
  root <- v3p_canonical_path(value[["output_root"]], "stage output root", TRUE)
  d0_artifacts <- v3p_validate_frozen_d0_artifacts(
    value[["d0_output_root"]], value[["d0_adjudication_receipt_sha256"]],
    value[["d0_diagnostics_sha256"]]
  )
  d0 <- d0_artifacts$root
  v3p_roots_nonnested(root, d0, "stage output root", "official D0 replay root")
  if (value[["stage"]] == "d1") {
    v3p_validate_successful_d0f_adjudication(
      value[["d0f_adjudication_root"]],
      value[["d0f_adjudication_receipt_sha256"]],
      root
    )
  }
  v3p_verify_preseal_tree(root, value[["stage"]], include_preseal)

  paths <- c(
    doc49_sha256 = "doc49.md", cell_table_sha256 = "cell_table.tsv",
    historical_seed_lock_sha256 = "historical_seed_lock.tsv",
    manifest_sha256 = paste0(value[["stage"]], "_manifest.tsv"),
    environment_manifest_sha256 = "environment_manifest.tsv"
  )
  for (key in names(paths)) {
    v3p_verify_pair(file.path(root, paths[[key]]), value[[key]], key)
  }
  cell_table <- v07d_read_tsv(
    file.path(root, "cell_table.tsv"), v3p_cell_table_columns, verify = FALSE
  )
  v3p_validate_cell_table(cell_table)
  seed_lock_path <- file.path(root, "historical_seed_lock.tsv")
  seed_lock <- v07s_read_lock(seed_lock_path)
  proposed_seeds <- v07s_expand_v3()
  v07s_validate_spaces(seed_lock, proposed_seeds)
  if (value[["stage"]] == "d0f") {
    v3p_validate_bootstrap_seed_space(seed_lock_path, proposed_seeds)
  }
  environment <- v07d_read_tsv(
    file.path(root, "environment_manifest.tsv"), c("key", "value"),
    verify = FALSE
  )
  v3p_validate_environment_live(environment)
  environment_value <- setNames(environment$value, environment$key)
  if (environment_value[["stage"]] != value[["stage"]]) {
    v3p_abort("environment stage differs from the preseal")
  }
  manifest_path <- file.path(root, paste0(value[["stage"]], "_manifest.tsv"))
  if (value[["stage"]] == "d0f") {
    fixed_path <- file.path(root, "d0f_fixed_panel_manifest.tsv")
    bootstrap_path <- file.path(root, "d0f_bootstrap_indices.tsv")
    v3p_verify_pair(
      fixed_path, value[["d0f_fixed_panel_manifest_sha256"]],
      "D0F fixed-panel manifest"
    )
    v3p_verify_pair(
      bootstrap_path, value[["d0f_bootstrap_indices_sha256"]],
      "D0F bootstrap manifest"
    )
    fixed <- v07d_read_tsv(
      fixed_path, v3p_d0f_fixed_columns, verify = FALSE
    )
    diagnostics_path <- d0_artifacts$diagnostics_path
    diagnostics_hash <- v07d_verify_pair(diagnostics_path)
    if (
      diagnostics_hash != value[["d0_diagnostics_sha256"]] ||
        !startsWith(diagnostics_path, paste0(d0, "/"))
    ) {
      v3p_abort("D0 diagnostics are not bound inside the official D0 root")
    }
    diagnostics <- v07d_read_tsv(
      diagnostics_path, v07d_diagnostic_columns, verify = FALSE
    )
    v3p_validate_d0f_fixed_panels(fixed, diagnostics)
    manifest <- v07d_read_tsv(
      manifest_path, v3p_d0f_phenotype_columns, verify = FALSE
    )
    v3p_validate_d0f_phenotype_manifest(manifest, fixed)
    bootstrap <- v07d_read_tsv(
      bootstrap_path, v3p_d0f_bootstrap_columns, verify = FALSE
    )
    v3p_validate_d0f_bootstrap(bootstrap, bootstrap_reps)
  } else {
    manifest <- v07d_read_tsv(
      manifest_path, v3p_d1_columns, verify = FALSE
    )
    v3p_validate_d1_manifest(manifest)
  }
  for (reviewer in v3p_reviewers) {
    v3p_validate_review(
      file.path(root, "receipts", paste0(reviewer, ".tsv")),
      value[[paste0(reviewer, "_receipt_sha256")]], reviewer, value
    )
  }
  roots <- vapply(
    c("r_driver", "r_recomputer", "julia_replay", "r_auto_route", "julia_candidate"),
    function(name) v3p_canonical_path(
      context[[paste0(name, "_root")]], paste(name, "deployed git root"), TRUE
    ),
    character(1L)
  )
  if (
    !identical(roots[["r_driver"]], roots[["r_recomputer"]]) ||
      !identical(roots[["r_driver"]], roots[["r_auto_route"]]) ||
      !identical(roots[["julia_replay"]], roots[["julia_candidate"]])
  ) {
    v3p_abort("candidate and deployed tool roots do not identify the two exact repositories")
  }
  for (root_i in unique(roots)) v3p_git_clean(root_i)
  commit_map <- c(
    r_driver = "r_driver_commit", r_recomputer = "r_recomputer_commit",
    julia_replay = "julia_replay_commit"
  )
  for (name in names(commit_map)) {
    observed <- v3p_git_head(context[[paste0(name, "_root")]])
    if (observed != value[[commit_map[[name]]]]) {
      v3p_abort("%s deployed commit differs from the preseal", name)
    }
  }
  v3p_git_ancestor(
    roots[["r_driver"]], value[["r_auto_route_commit"]],
    value[["r_driver_commit"]], "R driver"
  )
  v3p_git_ancestor(
    roots[["r_recomputer"]], value[["r_auto_route_commit"]],
    value[["r_recomputer_commit"]], "R recomputer"
  )
  v3p_git_ancestor(
    roots[["julia_replay"]], value[["julia_candidate_commit"]],
    value[["julia_replay_commit"]], "Julia replay"
  )
  r_surfaces <- file.path(
    roots[["r_driver"]], c("R", "DESCRIPTION", "NAMESPACE")
  )
  julia_surfaces <- file.path(
    roots[["julia_replay"]], c("src", "ext", "Project.toml", "Manifest.toml")
  )
  r_surfaces <- r_surfaces[file.exists(r_surfaces)]
  julia_surfaces <- julia_surfaces[file.exists(julia_surfaces)]
  if (!length(r_surfaces) || !length(julia_surfaces)) {
    v3p_abort("candidate implementation surfaces are absent")
  }
  v3p_git_unchanged(
    roots[["r_driver"]], value[["r_auto_route_commit"]],
    value[["r_driver_commit"]], r_surfaces, "R candidate implementation"
  )
  v3p_git_unchanged(
    roots[["julia_replay"]], value[["julia_candidate_commit"]],
    value[["julia_replay_commit"]], julia_surfaces,
    "Julia candidate implementation"
  )
  for (tool in c("r_driver", "r_recomputer", "julia_replay")) {
    v3p_verify_tool_at_commit(
      context[[paste0(tool, "_root")]], context[[paste0(tool, "_path")]],
      value[[paste0(tool, "_commit")]], value[[paste0(tool, "_sha256")]],
      paste(tool, "tool")
    )
  }
  v3p_verify_tool_at_commit(
    roots[["r_recomputer"]], context[["d0_recomputer_path"]],
    value[["r_recomputer_commit"]], value[["d0_recomputer_sha256"]],
    "D0 recomputer tool"
  )
  if (include_preseal) {
    preseal_path <- file.path(root, "stage_preseal.tsv")
    v3p_verify_pair(preseal_path, v07d_sha256(preseal_path), "stage preseal")
    observed <- v07d_read_tsv(
      preseal_path, c("key", "value"), verify = FALSE
    )
    observed_value <- as.character(observed$value)
    observed_value[is.na(observed_value)] <- "NA"
    expected_value <- as.character(x$value)
    expected_value[is.na(expected_value)] <- "NA"
    if (!identical(as.character(observed$key), as.character(x$key)) ||
        !identical(observed_value, expected_value)) {
      v3p_abort("stage_preseal.tsv bytes do not encode the validated preseal")
    }
  }
  x
}

v3p_d0f_designs <- data.frame(
  design_id = c("d0f_n0120_m0600", "d0f_n0300_m0150", "d0f_n0300_m1000"),
  design_index = 1:3,
  source_cell_id = c(
    "n120_m600_r050", "n300_m150_r050", "n300_m1000_r050"
  ),
  n = c(120L, 300L, 300L),
  m = c(600L, 150L, 1000L),
  marker_ratio = c(5, 0.5, 10 / 3),
  stringsAsFactors = FALSE
)

v3p_d0f_fixed_columns <- c(
  "stage", "design_id", "design_index", "source_cell_id", "panel_rank",
  "panel_source_seed", "n", "m", "marker_ratio", "truth_sigma_g2",
  "truth_sigma_e2", "truth_ratio", "ridge", "retained_m",
  "marker_hash", "id_hash", "kernel_hash", "precision_hash"
)

v3p_d0f_phenotype_columns <- c(
  "stage", "design_id", "design_index", "panel_id", "panel_rank",
  "source_cell_id", "panel_source_seed", "phenotype_rank", "seed", "n",
  "m", "marker_ratio", "retained_m", "truth_sigma_g2", "truth_sigma_e2",
  "truth_ratio", "ridge", "marker_hash", "id_hash",
  "kernel_hash", "precision_hash"
)

v3p_d1_columns <- c(
  "stage", "cell_id", "cell_index", "seed_offset", "seed", "n", "m",
  "marker_ratio", "marker_ratio_code", "truth_sigma_g2",
  "truth_sigma_e2", "truth_ratio", "ridge"
)

v3p_validate_d0_diagnostics <- function(manifest, diagnostics) {
  manifest <- v07d_validate_manifest(manifest)
  v3p_require_schema(diagnostics, v07d_diagnostic_columns, "D0 diagnostics")
  key <- function(x) paste(x$cell_id, sprintf("%.0f", x$seed), sep = "\r")
  if (
    nrow(diagnostics) != 432L || anyDuplicated(key(diagnostics)) ||
      !identical(key(diagnostics), key(manifest))
  ) {
    v3p_abort("D0 diagnostic membership or order differs from immutable manifest")
  }
  match_cell <- match(diagnostics$cell_id, v07d_cells$cell_id)
  numeric_fields <- c(
    "cell_index", "seed", "n", "m", "truth_ratio", "retained_m", "ridge"
  )
  for (field in numeric_fields) {
    diagnostics[[field]] <- v3p_num(diagnostics[[field]], field)
  }
  if (
    anyNA(match_cell) ||
      any(diagnostics$cell_index != manifest$cell_index) ||
      any(diagnostics$n != manifest$n) || any(diagnostics$m != manifest$m) ||
      any(diagnostics$truth_ratio != manifest$truth_ratio) ||
      any(diagnostics$ridge != 0.01) || any(diagnostics$retained_m < 1) ||
      any(diagnostics$retained_m > diagnostics$m)
  ) {
    v3p_abort("D0 diagnostic scientific contract drift")
  }
  hashes <- c("marker_hash", "id_hash", "kernel_hash", "precision_hash")
  if (any(!vapply(unlist(diagnostics[hashes]), v3p_hex64, logical(1L)))) {
    v3p_abort("D0 diagnostic fingerprint is invalid")
  }
  diagnostics
}

v3p_d0f_fixed_panels <- function(manifest, diagnostics) {
  manifest <- v07d_validate_manifest(manifest)
  diagnostics <- v3p_validate_d0_diagnostics(manifest, diagnostics)
  rows <- lapply(seq_len(nrow(v3p_d0f_designs)), function(i) {
    design <- v3p_d0f_designs[i, , drop = FALSE]
    source <- diagnostics[
      diagnostics$cell_id == design$source_cell_id,
      ,
      drop = FALSE
    ]
    source <- source[order(source$seed), , drop = FALSE]
    if (nrow(source) != 48L) v3p_abort("D0F source cell is incomplete")
    source <- source[seq_len(24L), , drop = FALSE]
    data.frame(
      stage = "d0f",
      design_id = design$design_id,
      design_index = design$design_index,
      source_cell_id = design$source_cell_id,
      panel_rank = seq_len(24L),
      panel_source_seed = source$seed,
      n = design$n,
      m = design$m,
      marker_ratio = design$marker_ratio,
      truth_sigma_g2 = 0.5,
      truth_sigma_e2 = 0.5,
      truth_ratio = 0.5,
      ridge = 0.01,
      retained_m = source$retained_m,
      marker_hash = source$marker_hash,
      id_hash = source$id_hash,
      kernel_hash = source$kernel_hash,
      precision_hash = source$precision_hash,
      stringsAsFactors = FALSE
    )
  })
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  out <- out[v3p_d0f_fixed_columns]
  v3p_validate_d0f_fixed_panels(out, diagnostics)
}

v3p_d0f_fixed_panels_from_corpus <- function(input_root) {
  corpus <- v07d_verify_corpus(input_root)
  selected <- unlist(lapply(v3p_d0f_designs$source_cell_id, function(cell) {
    rows <- corpus$manifest[corpus$manifest$cell_id == cell, , drop = FALSE]
    order <- order(rows$seed)[seq_len(24L)]
    split(rows[order, , drop = FALSE], seq_len(24L))
  }), recursive = FALSE)
  replay <- lapply(selected, function(row) {
    v07d_replay_packet(corpus$root, row)$diagnostics
  })
  diagnostics <- do.call(rbind, replay)
  # The selector validates all 432 D0 rows. Reuse the already verified corpus
  # while replaying the remaining packets only for immutable membership.
  all_replay <- lapply(seq_len(nrow(corpus$manifest)), function(i) {
    hit <- paste(corpus$manifest$cell_id[[i]], corpus$manifest$seed[[i]])
    selected_hit <- paste(diagnostics$cell_id, diagnostics$seed)
    at <- match(hit, selected_hit)
    if (!is.na(at)) diagnostics[at, , drop = FALSE] else
      v07d_replay_packet(corpus$root, corpus$manifest[i, , drop = FALSE])$diagnostics
  })
  v3p_d0f_fixed_panels(corpus$manifest, do.call(rbind, all_replay))
}

v3p_validate_d0f_fixed_panels <- function(x, diagnostics = NULL) {
  v3p_require_schema(x, v3p_d0f_fixed_columns, "D0F fixed-panel manifest")
  if (
    nrow(x) != 72L || anyNA(x) || any(x$stage != "d0f") ||
      anyDuplicated(paste(x$design_id, x$panel_rank, sep = "\r"))
  ) {
    v3p_abort("D0F fixed-panel denominator, stage, or key drift")
  }
  expected_design <- rep(v3p_d0f_designs$design_id, each = 24L)
  expected_rank <- rep(seq_len(24L), 3L)
  design <- v3p_d0f_designs[match(x$design_id, v3p_d0f_designs$design_id), ]
  if (
    anyNA(design$design_id) ||
      !identical(as.character(x$design_id), expected_design) ||
      !identical(as.integer(x$panel_rank), expected_rank) ||
      any(as.integer(x$design_index) != design$design_index) ||
      any(as.character(x$source_cell_id) != design$source_cell_id) ||
      any(as.integer(x$n) != design$n) || any(as.integer(x$m) != design$m) ||
      any(abs(as.numeric(x$marker_ratio) - design$marker_ratio) > 1e-12) ||
      any(as.numeric(x$truth_ratio) != 0.5) ||
      any(as.numeric(x$truth_sigma_g2) != 0.5) ||
      any(as.numeric(x$truth_sigma_e2) != 0.5) ||
      any(as.numeric(x$ridge) != 0.01) || any(as.integer(x$retained_m) < 1) ||
      any(as.integer(x$retained_m) > as.integer(x$m)) ||
      anyDuplicated(as.numeric(x$panel_source_seed))
  ) {
    v3p_abort("D0F fixed-panel scientific contract drift")
  }
  hashes <- c("marker_hash", "id_hash", "kernel_hash", "precision_hash")
  if (any(!vapply(unlist(x[hashes]), v3p_hex64, logical(1L)))) {
    v3p_abort("D0F fixed-panel fingerprint is invalid")
  }
  for (id in v3p_d0f_designs$design_id) {
    seeds <- as.numeric(x$panel_source_seed[x$design_id == id])
    if (!identical(seeds, sort(seeds))) {
      v3p_abort("D0F panels are not the 24 smallest ordered source seeds")
    }
  }
  if (!is.null(diagnostics)) {
    for (i in seq_len(nrow(v3p_d0f_designs))) {
      design <- v3p_d0f_designs[i, ]
      expected_seeds <- sort(as.numeric(
        diagnostics$seed[diagnostics$cell_id == design$source_cell_id]
      ))
      observed_seeds <- as.numeric(
        x$panel_source_seed[x$design_id == design$design_id]
      )
      if (
        length(expected_seeds) != 48L ||
          !identical(observed_seeds, expected_seeds[seq_len(24L)])
      ) {
        v3p_abort("D0F fixed panels are not the 24 smallest D0 source seeds")
      }
    }
    diagnostics <- diagnostics[
      paste(diagnostics$cell_id, diagnostics$seed) %in%
        paste(x$source_cell_id, x$panel_source_seed),
      ,
      drop = FALSE
    ]
    at <- match(
      paste(x$source_cell_id, x$panel_source_seed),
      paste(diagnostics$cell_id, diagnostics$seed)
    )
    if (anyNA(at)) v3p_abort("D0F fixed panel is absent from D0 diagnostics")
    for (field in c("retained_m", hashes)) {
      if (!identical(as.character(x[[field]]), as.character(diagnostics[[field]][at]))) {
        v3p_abort("D0F fixed-panel %s differs from immutable D0 diagnostics", field)
      }
    }
  }
  x
}

v3p_d0f_phenotype_seed <- function(design_index, panel_rank, phenotype_rank) {
  seed <- v07s_d0f_retry_phenotype_base + 100000 * as.double(design_index) +
    1000 * as.double(panel_rank) + as.double(phenotype_rank)
  if (
    any(!is.finite(seed)) || any(seed != floor(seed)) || any(seed < 1) ||
      any(seed > .Machine$integer.max)
  ) {
    v3p_abort("D0F phenotype seed is outside R integer range")
  }
  as.integer(seed)
}

v3p_d0f_phenotype_manifest <- function(fixed_panels) {
  fixed_panels <- v3p_validate_d0f_fixed_panels(fixed_panels)
  rows <- lapply(seq_len(nrow(fixed_panels)), function(i) {
    panel <- fixed_panels[i, , drop = FALSE]
    rank <- seq_len(8L)
    data.frame(
      stage = "d0f",
      design_id = panel$design_id,
      design_index = panel$design_index,
      panel_id = sprintf("%s_p%02d", panel$design_id, panel$panel_rank),
      panel_rank = panel$panel_rank,
      phenotype_rank = rank,
      source_cell_id = panel$source_cell_id,
      panel_source_seed = panel$panel_source_seed,
      seed = v3p_d0f_phenotype_seed(panel$design_index, panel$panel_rank, rank),
      n = panel$n,
      m = panel$m,
      marker_ratio = panel$marker_ratio,
      truth_sigma_g2 = panel$truth_sigma_g2,
      truth_sigma_e2 = panel$truth_sigma_e2,
      truth_ratio = panel$truth_ratio,
      ridge = panel$ridge,
      retained_m = panel$retained_m,
      marker_hash = panel$marker_hash,
      id_hash = panel$id_hash,
      kernel_hash = panel$kernel_hash,
      precision_hash = panel$precision_hash,
      stringsAsFactors = FALSE
    )
  })
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  out <- out[v3p_d0f_phenotype_columns]
  v3p_validate_d0f_phenotype_manifest(out, fixed_panels)
}

v3p_validate_d0f_phenotype_manifest <- function(x, fixed_panels) {
  fixed_panels <- v3p_validate_d0f_fixed_panels(fixed_panels)
  v3p_require_schema(x, v3p_d0f_phenotype_columns, "D0F phenotype manifest")
  if (
    nrow(x) != 576L || anyNA(x) || any(x$stage != "d0f") ||
      anyDuplicated(x$seed) ||
      anyDuplicated(paste(x$panel_id, x$phenotype_rank, sep = "\r"))
  ) {
    v3p_abort("D0F phenotype denominator, stage, or seed collision")
  }
  panel_key <- paste(fixed_panels$design_id, fixed_panels$panel_rank, sep = "\r")
  at <- match(paste(x$design_id, x$panel_rank, sep = "\r"), panel_key)
  if (anyNA(at)) v3p_abort("D0F phenotype references an unknown fixed panel")
  # Expansion is panel-major and phenotype-minor.
  expected_rank <- rep(seq_len(8L), nrow(fixed_panels))
  expected_seed <- v3p_d0f_phenotype_seed(
    x$design_index, x$panel_rank, x$phenotype_rank
  )
  if (
    !identical(as.integer(x$phenotype_rank), expected_rank) ||
      !identical(as.integer(x$seed), expected_seed)
  ) {
    v3p_abort("D0F phenotype rank, order, or exact seed mapping drift")
  }
  shared <- c(
    "design_index", "source_cell_id", "panel_source_seed", "n", "m",
    "marker_ratio", "truth_sigma_g2", "truth_sigma_e2", "truth_ratio",
    "ridge", "retained_m", "marker_hash", "id_hash", "kernel_hash",
    "precision_hash"
  )
  for (field in shared) {
    if (!identical(as.character(x[[field]]), as.character(fixed_panels[[field]][at]))) {
      v3p_abort("D0F phenotype/fixed-panel mismatch in %s", field)
    }
  }
  x
}

v3p_d0f_bootstrap_seed <- function(design_index) {
  seed <- v07s_d0f_retry_bootstrap_base + as.double(design_index)
  if (
    any(!is.finite(seed)) || any(seed != floor(seed)) || any(seed < 1) ||
      any(seed > .Machine$integer.max)
  ) {
    v3p_abort("D0F bootstrap seed is outside R integer range")
  }
  as.integer(seed)
}

v3p_d0f_bootstrap_columns <- c(
  "design_id", "design_index", "bootstrap_rep", "panel_slot", "panel_rank",
  sprintf("phenotype_%02d", seq_len(8L))
)

v3p_validate_bootstrap_seed_space <- function(
  lock_path = v07s_default_lock(),
  proposed = v07s_expand_v3()
) {
  seeds <- v3p_d0f_bootstrap_seed(v3p_d0f_designs$design_index)
  if (
    length(seeds) != 3L || anyDuplicated(seeds) ||
      any(seeds < 1L) || any(seeds > .Machine$integer.max)
  ) {
    v3p_abort("D0F bootstrap seeds are not three unique in-range integers")
  }
  lock <- v07s_read_lock(lock_path)
  spaces <- v07s_validate_spaces(lock, proposed)
  fitted <- c(as.numeric(spaces$historical$seed), as.numeric(spaces$proposed$seed))
  overlap <- intersect(as.numeric(seeds), fitted)
  if (length(overlap)) {
    v3p_abort("D0F bootstrap seed overlaps a historical or v3 fitted seed")
  }
  invisible(seeds)
}

v3p_d0f_bootstrap_manifest <- function(reps = 10000L) {
  if (length(reps) != 1L || is.na(reps) || reps < 1L || reps != floor(reps)) {
    v3p_abort("D0F bootstrap replicate count must be a positive integer")
  }
  had_seed <- exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  old_seed <- if (had_seed) get(".Random.seed", envir = .GlobalEnv) else NULL
  old_kind <- RNGkind()
  on.exit({
    do.call(RNGkind, as.list(old_kind))
    if (had_seed) {
      assign(".Random.seed", old_seed, envir = .GlobalEnv)
    } else if (exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)) {
      rm(".Random.seed", envir = .GlobalEnv)
    }
  }, add = TRUE)
  RNGkind("Mersenne-Twister", "Inversion", "Rejection")
  rows <- lapply(seq_len(nrow(v3p_d0f_designs)), function(i) {
    design <- v3p_d0f_designs[i, ]
    set.seed(v3p_d0f_bootstrap_seed(design$design_index))
    nrows <- reps * 24L
    panel <- sample.int(24L, nrows, replace = TRUE)
    phenotype <- matrix(
      sample.int(8L, nrows * 8L, replace = TRUE),
      nrow = nrows
    )
    out <- data.frame(
      design_id = rep(design$design_id, nrows),
      design_index = rep(design$design_index, nrows),
      bootstrap_rep = rep(seq_len(reps), each = 24L),
      panel_slot = rep(seq_len(24L), reps),
      panel_rank = panel,
      phenotype,
      check.names = FALSE,
      stringsAsFactors = FALSE
    )
    names(out) <- v3p_d0f_bootstrap_columns
    out
  })
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  v3p_validate_d0f_bootstrap(out, reps = reps, reproduce = FALSE)
}

v3p_validate_d0f_bootstrap <- function(x, reps = 10000L, reproduce = TRUE) {
  v3p_require_schema(x, v3p_d0f_bootstrap_columns, "D0F bootstrap manifest")
  expected_design <- rep(v3p_d0f_designs$design_id, each = reps * 24L)
  expected_index <- rep(v3p_d0f_designs$design_index, each = reps * 24L)
  expected_rep <- rep(rep(seq_len(reps), each = 24L), 3L)
  expected_slot <- rep(seq_len(24L), reps * 3L)
  phenotype_fields <- grep("^phenotype_", names(x), value = TRUE)
  values_panel <- suppressWarnings(as.integer(x$panel_rank))
  values_phenotype <- suppressWarnings(as.integer(unlist(x[phenotype_fields])))
  if (
    nrow(x) != 3L * reps * 24L || anyNA(x) ||
      !identical(as.character(x$design_id), expected_design) ||
      !identical(as.integer(x$design_index), expected_index) ||
      !identical(as.integer(x$bootstrap_rep), expected_rep) ||
      !identical(as.integer(x$panel_slot), expected_slot) ||
      any(values_panel < 1L | values_panel > 24L) ||
      any(values_phenotype < 1L | values_phenotype > 8L)
  ) {
    v3p_abort("D0F bootstrap membership, order, or index range drift")
  }
  if (reproduce) {
    expected <- v3p_d0f_bootstrap_manifest(reps)
    if (!identical(x, expected)) {
      v3p_abort("D0F bootstrap differs from the frozen base-R RNG manifest")
    }
  }
  x
}

v3p_d1_manifest <- function() {
  out <- v3_d1_manifest()
  out <- out[v3p_d1_columns]
  v3p_validate_d1_manifest(out)
}

v3p_validate_d1_manifest <- function(x) {
  v3p_require_schema(x, v3p_d1_columns, "D1 manifest")
  expected <- v3_d1_manifest()[v3p_d1_columns]
  if (nrow(x) != 576L || anyNA(x) || anyDuplicated(x$seed)) {
    v3p_abort("D1 manifest denominator or exact seed uniqueness drift")
  }
  numeric <- c(
    "cell_index", "seed_offset", "seed", "n", "m", "marker_ratio",
    "truth_sigma_g2", "truth_sigma_e2", "truth_ratio", "ridge"
  )
  for (field in numeric) {
    if (!v3p_same_numeric(x[[field]], expected[[field]], 0)) {
      v3p_abort("D1 manifest mismatch in %s", field)
    }
  }
  for (field in setdiff(v3p_d1_columns, numeric)) {
    if (!identical(as.character(x[[field]]), as.character(expected[[field]]))) {
      v3p_abort("D1 manifest mismatch in %s", field)
    }
  }
  x
}

v3p_result_columns <- c(
  "attempted", "status", "error_class", "converged", "boundary_status",
  "boundary_reason", "boundary_epsilon", "scientific_sigma_g2",
  "scientific_sigma_e2", "scientific_ratio", "fitted_total_variance",
  "numerical_sigma_g2", "numerical_sigma_e2", "numerical_ratio",
  "profile_loglik", "lower_derivative_per_observation",
  "upper_derivative_per_observation", "iterations", "objective",
  "gradient_norm", "runtime_seconds", "peak_rss_mb", "scale_denominator",
  "eigen_cv_population", "effective_rank", "information_r020",
  "se_info_r020", "information_r050", "se_info_r050", "information_r080",
  "se_info_r080", "relationship_source", "relationship_method",
  "allele_frequency_source", "relationship_scale", "route",
  "r_implementation_commit", "julia_implementation_commit", "driver_commit",
  "preseal_sha256"
)
v3p_boundary_epsilon <- 1e-7
v3p_boundary_kkt_tolerance <- 1e-8

v3p_d0f_attempt_columns <- c(v3p_d0f_phenotype_columns, v3p_result_columns)
v3p_d1_attempt_columns <- c(
  v3p_d1_columns, "retained_m", "marker_hash", "id_hash", "kernel_hash",
  "precision_hash", v3p_result_columns
)
v3p_replay_binding_columns <- c(
  "source_r_attempt_sha256", "source_r_max_abs_difference",
  "replay_julia_commit", "replay_driver_sha256", "manifest_sha256",
  "preseal_sha256", "corpus_lock_sha256"
)

v3p_attempt_binding_names <- c(
  "preseal_sha256", "manifest_sha256", "corpus_lock_sha256",
  "r_auto_route_commit", "julia_candidate_commit", "r_driver_commit",
  "julia_replay_commit", "julia_replay_sha256"
)

v3p_validate_attempt_binding <- function(binding) {
  if (!is.list(binding) || !identical(names(binding), v3p_attempt_binding_names)) {
    v3p_abort("attempt binding schema or order drift")
  }
  hashes <- c(
    "preseal_sha256", "manifest_sha256", "corpus_lock_sha256",
    "julia_replay_sha256"
  )
  commits <- c(
    "r_auto_route_commit", "julia_candidate_commit", "r_driver_commit",
    "julia_replay_commit"
  )
  if (
    any(!vapply(binding[hashes], v3p_hex64, logical(1L))) ||
      any(!vapply(binding[commits], v3p_hex40, logical(1L)))
  ) {
    v3p_abort("attempt binding contains a forged commit or digest")
  }
  binding
}

v3p_canonical_na <- function(x) {
  if (is.numeric(x)) return(is.na(x) & !is.nan(x))
  is.na(x) | (!is.na(x) & as.character(x) == "NA")
}

v3p_validate_unsuccessful_results <- function(attempts, success, label) {
  failed <- which(!success)
  if (!length(failed)) return(invisible(TRUE))
  required_na <- c(
    "scientific_sigma_g2", "scientific_sigma_e2", "scientific_ratio",
    "fitted_total_variance", "numerical_sigma_g2", "numerical_sigma_e2",
    "numerical_ratio", "iterations", "objective", "gradient_norm"
  )
  if (any(vapply(required_na, function(field) {
    !all(v3p_canonical_na(attempts[[field]][failed]))
  }, logical(1L)))) {
    v3p_abort("%s unsuccessful result retains scientific or optimizer output", label)
  }
  status <- as.character(attempts$boundary_status[failed])
  reason <- as.character(attempts$boundary_reason[failed])
  evidence_fields <- c(
    "profile_loglik", "lower_derivative_per_observation",
    "upper_derivative_per_observation"
  )
  for (i in seq_along(failed)) {
    row <- failed[[i]]
    unresolved <- !is.na(status[[i]]) && status[[i]] == "boundary_unresolved"
    if (unresolved) {
      evidence <- vapply(
        evidence_fields,
        function(field) suppressWarnings(as.numeric(attempts[[field]][[row]])),
        numeric(1L)
      )
      evidence_na <- vapply(
        evidence_fields,
        function(field) v3p_canonical_na(attempts[[field]][[row]]),
        logical(1L)
      )
      epsilon <- suppressWarnings(as.numeric(attempts$boundary_epsilon[[row]]))
      if (
        is.na(reason[[i]]) || !nzchar(reason[[i]]) || reason[[i]] == "NA" ||
          !is.finite(epsilon) || epsilon != v3p_boundary_epsilon ||
          !(all(evidence_na) || all(is.finite(evidence)))
      ) {
        v3p_abort("%s unresolved failure has malformed boundary evidence", label)
      }
    } else {
      ordinary_fields <- c(
        "boundary_status", "boundary_reason", "boundary_epsilon",
        evidence_fields
      )
      if (any(vapply(ordinary_fields, function(field) {
        !v3p_canonical_na(attempts[[field]][[row]])
      }, logical(1L)))) {
        v3p_abort("%s ordinary failure retains boundary evidence", label)
      }
    }
  }
  invisible(TRUE)
}

v3p_validate_results <- function(
  attempts, manifest, manifest_columns, label,
  binding, expected_route = "ordinary_auto_genomic"
) {
  binding <- v3p_validate_attempt_binding(binding)
  shared <- manifest_columns
  for (field in shared) {
    if (!identical(as.character(attempts[[field]]), as.character(manifest[[field]]))) {
      v3p_abort("%s attempt/manifest mismatch in %s", label, field)
    }
  }
  attempted <- v3p_bool(attempts$attempted, "attempted")
  converged <- v3p_bool(attempts$converged, "converged")
  if (any(!attempted)) v3p_abort("%s attempted denominator was altered", label)
  status <- as.character(attempts$status)
  error_class <- as.character(attempts$error_class)
  if (
    anyNA(status) || any(!status %in% c("success", "fit_error")) ||
      anyNA(error_class) || any(!nzchar(error_class))
  ) {
    v3p_abort("%s status or convergence contract drift", label)
  }
  success <- status == "success"
  if (
    any(success != converged) ||
      any(success & error_class != "none") ||
      any(!success & error_class == "none")
  ) {
    v3p_abort("%s status or convergence contract drift", label)
  }
  v3p_validate_unsuccessful_results(attempts, success, label)
  numeric <- c(
    "scientific_sigma_g2", "scientific_sigma_e2", "scientific_ratio",
    "fitted_total_variance", "numerical_sigma_g2", "numerical_sigma_e2",
    "numerical_ratio", "profile_loglik", "lower_derivative_per_observation",
    "upper_derivative_per_observation", "iterations", "objective",
    "gradient_norm", "runtime_seconds", "peak_rss_mb", "scale_denominator",
    "eigen_cv_population", "effective_rank", "information_r020",
    "se_info_r020", "information_r050", "se_info_r050", "information_r080",
    "se_info_r080"
  )
  for (field in numeric) attempts[[field]] <- v3p_num(attempts[[field]], field, FALSE)
  boundary_status <- as.character(attempts$boundary_status)
  boundary_reason <- as.character(attempts$boundary_reason)
  lower <- success & !is.na(boundary_status) & boundary_status == "boundary_lower"
  upper <- success & !is.na(boundary_status) & boundary_status == "boundary_upper"
  interior <- success & !is.na(boundary_status) &
    boundary_status %in% c("interior", "interior_rescued")
  reasons <- c(
    boundary_lower = "boundary_lower", boundary_upper = "boundary_upper",
    interior = "ai_interior", interior_rescued = "profile_interior"
  )
  if (
    any(success & !is.finite(attempts$scientific_sigma_g2)) ||
      any(success & !is.finite(attempts$scientific_sigma_e2)) ||
      any(success & !is.finite(attempts$scientific_ratio)) ||
      any(success & !is.finite(attempts$fitted_total_variance)) ||
      any(success & attempts$fitted_total_variance < 0) ||
      any(success & abs(
        attempts$scientific_sigma_g2 + attempts$scientific_sigma_e2 -
          attempts$fitted_total_variance
      ) > 1e-10) ||
      any(success & abs(
        attempts$scientific_sigma_g2 /
          attempts$fitted_total_variance - attempts$scientific_ratio
      ) > 1e-10) ||
      any(success & !boundary_status %in% c(
        "boundary_lower", "boundary_upper", "interior", "interior_rescued"
      )) ||
      any(!is.finite(attempts$runtime_seconds) |
        attempts$runtime_seconds < 0) ||
      any(!is.finite(attempts$peak_rss_mb) |
        attempts$peak_rss_mb < 0) ||
      any(!is.finite(attempts$eigen_cv_population) |
        attempts$eigen_cv_population < 0) ||
      any(!is.finite(attempts$effective_rank) |
        attempts$effective_rank <= 0) ||
      any(!is.finite(attempts$information_r020) |
        !is.finite(attempts$information_r050) |
        !is.finite(attempts$information_r080) |
        !is.finite(attempts$se_info_r020) |
        !is.finite(attempts$se_info_r050) |
        !is.finite(attempts$se_info_r080)) ||
      any(success & (!is.finite(attempts$profile_loglik) |
        !is.finite(attempts$lower_derivative_per_observation) |
        !is.finite(attempts$upper_derivative_per_observation))) ||
      any(success & (!is.finite(attempts$boundary_epsilon) |
        attempts$boundary_epsilon != v3p_boundary_epsilon)) ||
      any(success & (is.na(boundary_reason) |
        boundary_reason != unname(reasons[boundary_status]))) ||
      any(lower & attempts$lower_derivative_per_observation >
        v3p_boundary_kkt_tolerance) ||
      any(upper & attempts$upper_derivative_per_observation <
        -v3p_boundary_kkt_tolerance) ||
      any(interior & !(attempts$lower_derivative_per_observation >
        v3p_boundary_kkt_tolerance & attempts$upper_derivative_per_observation <
        -v3p_boundary_kkt_tolerance)) ||
      any(attempts$scientific_ratio[lower] != 0) ||
      any(attempts$scientific_ratio[upper] != 1) ||
      any(attempts$numerical_ratio[lower] != v3p_boundary_epsilon) ||
      any(attempts$numerical_ratio[upper] != 1 - v3p_boundary_epsilon) ||
      any(attempts$scientific_ratio[interior] <= 0 |
        attempts$scientific_ratio[interior] >= 1) ||
      any(as.character(attempts$route) != expected_route) ||
      any(as.character(attempts$relationship_source) != "markers") ||
      any(as.character(attempts$relationship_method) != "vanraden1") ||
      any(as.character(attempts$allele_frequency_source) != "sample") ||
      any(as.character(attempts$relationship_scale) != "K_lambda")
  ) {
    v3p_abort("%s successful result has malformed scientific output", label)
  }
  commits <- c(
    "r_implementation_commit", "julia_implementation_commit", "driver_commit"
  )
  expected_driver_commit <- switch(
    expected_route,
    ordinary_auto_genomic = binding[["r_driver_commit"]],
    julia_profile_replay = binding[["julia_replay_commit"]],
    v3p_abort("unsupported expected attempt route")
  )
  if (
    any(!vapply(unlist(attempts[commits]), v3p_hex40, logical(1L))) ||
      any(attempts$preseal_sha256 != binding[["preseal_sha256"]]) ||
      any(attempts$r_implementation_commit != binding[["r_auto_route_commit"]]) ||
      any(attempts$julia_implementation_commit !=
        binding[["julia_candidate_commit"]]) ||
      any(attempts$driver_commit != expected_driver_commit)
  ) {
    v3p_abort("%s attempt provenance binding is invalid", label)
  }
  attempts$attempted <- attempted
  attempts$converged <- converged
  attempts
}

v3p_admit_d0f_attempts <- function(
  attempts, manifest, binding, expected_route = "ordinary_auto_genomic"
) {
  manifest <- v3p_validate_d0f_phenotype_manifest(
    manifest,
    unique(manifest[c(
      "stage", "design_id", "design_index", "source_cell_id", "panel_rank",
      "panel_source_seed", "n", "m", "marker_ratio", "truth_sigma_g2",
      "truth_sigma_e2", "truth_ratio", "ridge", "retained_m",
      "marker_hash", "id_hash", "kernel_hash", "precision_hash"
    )])[v3p_d0f_fixed_columns]
  )
  v3p_require_schema(attempts, v3p_d0f_attempt_columns, "D0F attempts")
  key <- function(x) paste(x$design_id, x$panel_rank, x$phenotype_rank, x$seed, sep = "\r")
  if (
    nrow(attempts) != nrow(manifest) || anyDuplicated(key(attempts)) ||
      !identical(key(attempts), key(manifest))
  ) {
    v3p_abort("D0F attempt set is not exactly the manifest denominator")
  }
  v3p_validate_results(
    attempts, manifest, v3p_d0f_phenotype_columns, "D0F", binding,
    expected_route
  )
}

v3p_admit_d1_attempts <- function(
  attempts, manifest, binding, expected_route = "ordinary_auto_genomic"
) {
  manifest <- v3p_validate_d1_manifest(manifest)
  v3p_require_schema(attempts, v3p_d1_attempt_columns, "D1 attempts")
  key <- function(x) paste(x$cell_id, x$seed, sep = "\r")
  if (
    nrow(attempts) != nrow(manifest) || anyDuplicated(key(attempts)) ||
      !identical(key(attempts), key(manifest))
  ) {
    v3p_abort("D1 attempt set is not exactly the manifest denominator")
  }
  hashes <- c("marker_hash", "id_hash", "kernel_hash", "precision_hash")
  if (
    any(as.integer(attempts$retained_m) < 1L) ||
      any(as.integer(attempts$retained_m) > as.integer(attempts$m)) ||
      any(!vapply(unlist(attempts[hashes]), v3p_hex64, logical(1L)))
  ) {
    v3p_abort("D1 retained marker or fingerprint contract drift")
  }
  v3p_validate_results(
    attempts, manifest, v3p_d1_columns, "D1", binding, expected_route
  )
}

v3p_admit_julia_replay <- function(
  replay, manifest, stage, binding, source_attempt_sha256
) {
  binding <- v3p_validate_attempt_binding(binding)
  base_columns <- switch(
    stage,
    d0f = v3p_d0f_attempt_columns,
    d1 = v3p_d1_attempt_columns,
    v3p_abort("Julia replay stage must be d0f or d1")
  )
  v3p_require_schema(
    replay,
    c(setdiff(base_columns, "preseal_sha256"), v3p_replay_binding_columns),
    "Julia replay"
  )
  hashes <- c(
    "source_r_attempt_sha256", "replay_driver_sha256", "manifest_sha256",
    "preseal_sha256", "corpus_lock_sha256"
  )
  difference <- v3p_num(
    replay$source_r_max_abs_difference, "source_r_max_abs_difference"
  )
  if (
    any(difference > 1e-10) ||
      any(!vapply(unlist(replay[hashes]), v3p_hex64, logical(1L))) ||
      any(!vapply(replay$replay_julia_commit, v3p_hex40, logical(1L))) ||
      !identical(as.character(replay$source_r_attempt_sha256),
        as.character(source_attempt_sha256)) ||
      any(replay$replay_julia_commit != binding[["julia_replay_commit"]]) ||
      any(replay$replay_driver_sha256 != binding[["julia_replay_sha256"]]) ||
      any(replay$manifest_sha256 != binding[["manifest_sha256"]]) ||
      any(replay$preseal_sha256 != binding[["preseal_sha256"]]) ||
      any(replay$corpus_lock_sha256 != binding[["corpus_lock_sha256"]])
  ) {
    v3p_abort("Julia replay provenance or source parity binding is invalid")
  }
  projected <- replay[base_columns]
  switch(
    stage,
    d0f = v3p_admit_d0f_attempts(
      projected, manifest, binding, expected_route = "julia_profile_replay"
    ),
    d1 = v3p_admit_d1_attempts(
      projected, manifest, binding, expected_route = "julia_profile_replay"
    )
  )
}

v3p_adjudicate_attempts <- function(
  driver, base_r, julia, manifest, stage, binding, source_attempt_sha256
) {
  admitted <- switch(
    stage,
    d0f = list(
      driver = v3p_admit_d0f_attempts(driver, manifest, binding),
      base_r = v3p_admit_d0f_attempts(base_r, manifest, binding),
      julia = v3p_admit_julia_replay(
        julia, manifest, "d0f", binding, source_attempt_sha256
      ),
      columns = v3p_d0f_attempt_columns,
      key = c("design_id", "panel_rank", "phenotype_rank", "seed")
    ),
    d1 = list(
      driver = v3p_admit_d1_attempts(driver, manifest, binding),
      base_r = v3p_admit_d1_attempts(base_r, manifest, binding),
      julia = v3p_admit_julia_replay(
        julia, manifest, "d1", binding, source_attempt_sha256
      ),
      columns = v3p_d1_attempt_columns,
      key = c("cell_id", "seed")
    ),
    v3p_abort("attempt adjudication stage must be d0f or d1")
  )
  distinct <- c(
    "route", "r_implementation_commit", "julia_implementation_commit",
    "driver_commit", "preseal_sha256", "runtime_seconds", "peak_rss_mb"
  )
  compare <- setdiff(admitted$columns, distinct)
  v3p_compare_tables(
    admitted$driver[compare], admitted$base_r[compare], compare, admitted$key
  )
  v3p_compare_tables(
    admitted$driver[compare], admitted$julia[compare], compare, admitted$key
  )
  invisible(data.frame(stage = stage, verdict = "PASS", stringsAsFactors = FALSE))
}

v3p_wilson <- function(k, n) {
  if (!n) return(c(lower = NA_real_, upper = NA_real_))
  z <- stats::qnorm(0.975)
  p <- k / n
  denom <- 1 + z^2 / n
  center <- (p + z^2 / (2 * n)) / denom
  half <- z * sqrt(p * (1 - p) / n + z^2 / (4 * n^2)) / denom
  c(lower = center - half, upper = center + half)
}

v3p_target_metrics <- function(estimate, truth, margin) {
  n <- length(estimate)
  if (n < 2L || any(!is.finite(estimate))) {
    return(setNames(rep(NA_real_, 12L), c(
      "mean_estimate", "bias", "mcse_bias", "bias_lower", "bias_upper",
      "empirical_sd", "rmse", "mcse_rmse", "sd_upper", "required_n_raw",
      "required_n", "futile"
    )))
  }
  error <- estimate - truth
  bias <- mean(error)
  sd_estimate <- stats::sd(estimate)
  mcse <- sd_estimate / sqrt(n)
  tcrit <- stats::qt(0.975, n - 1L)
  squared <- error^2
  rmse <- sqrt(mean(squared))
  mcse_rmse <- if (rmse == 0) {
    if (all(squared == 0)) 0 else NA_real_
  } else {
    stats::sd(squared) / (2 * rmse * sqrt(n))
  }
  sd_upper <- sd_estimate * sqrt(
    (n - 1) / stats::qchisq(0.05, n - 1)
  )
  required_raw <- ceiling((1.96 * sd_upper / (margin / 2))^2)
  lower <- bias - tcrit * mcse
  upper <- bias + tcrit * mcse
  c(
    mean_estimate = mean(estimate), bias = bias,
    mcse_bias = mcse,
    bias_lower = lower,
    bias_upper = upper,
    empirical_sd = sd_estimate,
    rmse = rmse,
    mcse_rmse = mcse_rmse,
    sd_upper = sd_upper, required_n_raw = required_raw,
    required_n = required_raw,
    futile = as.numeric(lower >= margin || upper <= -margin)
  )
}

v3p_d1_summary_parity_fixture <- function(binding) {
  binding <- v3p_validate_attempt_binding(binding)
  manifest <- v3p_d1_manifest()
  replicate <- as.integer(manifest$seed_offset) - 100L
  interior_ratio <- 0.5 + (replicate - 24.5) * 1e-4
  ratio <- interior_ratio
  ratio[replicate == 1L] <- 0
  ratio[replicate == 2L] <- 1
  boundary <- ifelse(
    replicate == 1L, "boundary_lower",
    ifelse(
      replicate == 2L, "boundary_upper",
      ifelse(replicate == 3L, "interior_rescued", "interior")
    )
  )
  reason <- c(
    boundary_lower = "boundary_lower", boundary_upper = "boundary_upper",
    interior_rescued = "profile_interior", interior = "ai_interior"
  )[boundary]
  lower_derivative <- ifelse(boundary == "boundary_lower", 0, 1)
  upper_derivative <- ifelse(boundary == "boundary_upper", 0, -1)
  numerical_ratio <- ratio
  numerical_ratio[boundary == "boundary_lower"] <- v3p_boundary_epsilon
  numerical_ratio[boundary == "boundary_upper"] <- 1 - v3p_boundary_epsilon
  attempts <- cbind(
    manifest,
    retained_m = manifest$m,
    marker_hash = paste(rep("a", 64L), collapse = ""),
    id_hash = paste(rep("b", 64L), collapse = ""),
    kernel_hash = paste(rep("c", 64L), collapse = ""),
    precision_hash = paste(rep("d", 64L), collapse = ""),
    data.frame(
      attempted = TRUE, status = "success", error_class = "none",
      converged = TRUE, boundary_status = boundary,
      boundary_reason = unname(reason), boundary_epsilon = v3p_boundary_epsilon,
      scientific_sigma_g2 = ratio, scientific_sigma_e2 = 1 - ratio,
      scientific_ratio = ratio, fitted_total_variance = 1,
      numerical_sigma_g2 = numerical_ratio,
      numerical_sigma_e2 = 1 - numerical_ratio,
      numerical_ratio = numerical_ratio, profile_loglik = -1,
      lower_derivative_per_observation = lower_derivative,
      upper_derivative_per_observation = upper_derivative,
      iterations = 2, objective = 1, gradient_norm = 0,
      runtime_seconds = replicate, peak_rss_mb = 100 + replicate,
      scale_denominator = 1, eigen_cv_population = 0.5,
      effective_rank = 50, information_r020 = 100, se_info_r020 = 0.1,
      information_r050 = 100, se_info_r050 = 0.1,
      information_r080 = 100, se_info_r080 = 0.1,
      relationship_source = "markers", relationship_method = "vanraden1",
      allele_frequency_source = "sample", relationship_scale = "K_lambda",
      route = "ordinary_auto_genomic",
      r_implementation_commit = binding[["r_auto_route_commit"]],
      julia_implementation_commit = binding[["julia_candidate_commit"]],
      driver_commit = binding[["r_driver_commit"]],
      preseal_sha256 = binding[["preseal_sha256"]],
      stringsAsFactors = FALSE
    )
  )
  attempts <- attempts[v3p_d1_attempt_columns]
  list(
    manifest = manifest,
    attempts = v3p_admit_d1_attempts(attempts, manifest, binding),
    summary = v3p_d1_summary(manifest, attempts, binding)
  )
}

v3p_d1_summary_columns <- c(
  "stage", "cell_id", "cell_index", "n", "m", "marker_ratio",
  "truth_ratio", "n_expected", "n_attempted", "n_converged",
  "n_bias_rows", "n_interior", "n_interior_rescued", "n_boundary_lower",
  "n_boundary_upper", "n_unresolved", "n_error", "convergence_rate",
  "wilson_lower", "wilson_upper", "target", "truth", "mean_estimate",
  "bias", "mcse", "bias_ci_lower", "bias_ci_upper", "margin", "rmse",
  "mcse_rmse", "empirical_sd", "pilot_sd_upper", "required_n_raw",
  "required_n", "low_convergence", "summary_nonfinite",
  "precision_blocked", "futility_stopped", "target_futile",
  "cell_eligible", "cell_status",
  "median_runtime_seconds", "p95_runtime_seconds", "median_peak_rss_mb",
  "p95_peak_rss_mb", "rms_se_info", "empirical_sd_over_rms_se_info",
  "predicted_boundary_lower", "predicted_boundary_upper",
  "observed_boundary_lower", "observed_boundary_upper",
  "mcse_boundary_lower", "mcse_boundary_upper",
  "mean_spectral_cv", "mean_effective_rank", "failure_classes"
)

v3p_d1_summary <- function(manifest, attempts, binding) {
  manifest <- v3p_validate_d1_manifest(manifest)
  attempts <- v3p_admit_d1_attempts(attempts, manifest, binding)
  rows <- lapply(unique(manifest$cell_id), function(cell_id) {
    m <- manifest[manifest$cell_id == cell_id, , drop = FALSE]
    x <- attempts[attempts$cell_id == cell_id, , drop = FALSE]
    good <- x$converged
    finite <- good & is.finite(x$scientific_sigma_g2) &
      is.finite(x$scientific_sigma_e2) & is.finite(x$scientific_ratio) &
      is.finite(x$se_info_r050)
    nconv <- sum(finite)
    wilson <- v3p_wilson(nconv, nrow(x))
    targets <- list(
      sigma_g2 = list(value = x$scientific_sigma_g2[finite],
        truth = m$truth_sigma_g2[[1L]], margin = 0.05 * m$truth_sigma_g2[[1L]]),
      sigma_e2 = list(value = x$scientific_sigma_e2[finite],
        truth = m$truth_sigma_e2[[1L]], margin = 0.05 * m$truth_sigma_e2[[1L]]),
      ratio = list(value = x$scientific_ratio[finite],
        truth = m$truth_ratio[[1L]], margin = 0.02)
    )
    metrics <- lapply(targets, function(target) {
      v3p_target_metrics(target$value, target$truth, target$margin)
    })
    target_required <- vapply(
      metrics, function(value) value[["required_n_raw"]], numeric(1L)
    )
    futile <- vapply(metrics, function(value) value[["futile"]], numeric(1L))
    rms_se <- sqrt(mean(x$se_info_r050[finite]^2))
    ratio_sd <- stats::sd(x$scientific_ratio[finite])
    predicted_lower <- mean(stats::pnorm(-m$truth_ratio[[1L]] / x$se_info_r050))
    predicted_upper <- mean(
      1 - stats::pnorm((1 - m$truth_ratio[[1L]]) / x$se_info_r050)
    )
    required <- if (all(is.finite(target_required))) {
      max(200, max(target_required))
    } else {
      Inf
    }
    resolved <- c(
      interior = sum(good & x$boundary_status == "interior"),
      interior_rescued = sum(good & x$boundary_status == "interior_rescued"),
      boundary_lower = sum(good & x$boundary_status == "boundary_lower"),
      boundary_upper = sum(good & x$boundary_status == "boundary_upper")
    )
    unresolved <- sum(
      !good & !is.na(x$boundary_status) &
        x$boundary_status == "boundary_unresolved"
    )
    errors <- sum(
      !good & (is.na(x$boundary_status) |
        x$boundary_status != "boundary_unresolved")
    )
    class_table <- table(as.character(x$error_class), useNA = "ifany")
    class_table <- class_table[order(names(class_table))]
    failure_text <- paste(
      paste(names(class_table), as.integer(class_table), sep = "="),
      collapse = ";"
    )
    count_valid <- sum(resolved) + unresolved + errors == 48L
    summary_nonfinite <- !(
      all(is.finite(unlist(metrics))) && is.finite(rms_se) &&
        is.finite(ratio_sd) && is.finite(ratio_sd / rms_se) &&
        all(is.finite(x$se_info_r050)) &&
        is.finite(predicted_lower) && is.finite(predicted_upper) &&
        all(is.finite(x$runtime_seconds)) &&
        all(is.finite(x$peak_rss_mb)) &&
        all(is.finite(x$eigen_cv_population)) &&
        all(is.finite(x$effective_rank))
    )
    low_convergence <- nconv < 46L
    precision_blocked <- is.finite(required) && required > 2000L
    futility_stopped <- any(futile == 1, na.rm = TRUE)
    if (!count_valid || (!low_convergence && summary_nonfinite)) {
      v3p_abort("RECOMPUTATION_BLOCKER: admitted D1 summary invariant failed")
    }
    status <- if (low_convergence) {
      "STOP_LOW_PILOT_CONVERGENCE"
    } else if (precision_blocked) {
      "PRECISION_BLOCKER"
    } else if (futility_stopped) {
      "FUTILITY_STOP"
    } else {
      "ELIGIBLE"
    }
    eligible <- identical(status, "ELIGIBLE")
    do.call(rbind, lapply(names(targets), function(target_name) {
      metric <- metrics[[target_name]]
      data.frame(
        stage = "d1", cell_id = cell_id, cell_index = m$cell_index[[1L]],
        n = m$n[[1L]], m = m$m[[1L]], marker_ratio = m$marker_ratio[[1L]],
        truth_ratio = m$truth_ratio[[1L]], n_expected = nrow(m),
        n_attempted = nrow(x), n_converged = nconv, n_bias_rows = nconv,
        n_interior = resolved[["interior"]],
        n_interior_rescued = resolved[["interior_rescued"]],
        n_boundary_lower = resolved[["boundary_lower"]],
        n_boundary_upper = resolved[["boundary_upper"]],
        n_unresolved = unresolved, n_error = errors,
        convergence_rate = nconv / nrow(x),
        wilson_lower = wilson[[1L]], wilson_upper = wilson[[2L]],
        target = target_name, truth = targets[[target_name]]$truth,
        mean_estimate = metric[["mean_estimate"]], bias = metric[["bias"]],
        mcse = metric[["mcse_bias"]], bias_ci_lower = metric[["bias_lower"]],
        bias_ci_upper = metric[["bias_upper"]], margin = targets[[target_name]]$margin,
        rmse = metric[["rmse"]], mcse_rmse = metric[["mcse_rmse"]],
        empirical_sd = metric[["empirical_sd"]],
        pilot_sd_upper = metric[["sd_upper"]],
        required_n_raw = metric[["required_n_raw"]],
        required_n = required, low_convergence = low_convergence,
        summary_nonfinite = summary_nonfinite,
        precision_blocked = precision_blocked,
        futility_stopped = futility_stopped,
        target_futile = isTRUE(metric[["futile"]] == 1),
        cell_eligible = eligible,
        cell_status = status,
        median_runtime_seconds = stats::median(x$runtime_seconds),
        p95_runtime_seconds = unname(stats::quantile(x$runtime_seconds, 0.95)),
        median_peak_rss_mb = stats::median(x$peak_rss_mb),
        p95_peak_rss_mb = unname(stats::quantile(x$peak_rss_mb, 0.95)),
        rms_se_info = rms_se,
        empirical_sd_over_rms_se_info = ratio_sd / rms_se,
        predicted_boundary_lower = predicted_lower,
        predicted_boundary_upper = predicted_upper,
        observed_boundary_lower = resolved[["boundary_lower"]] / nrow(x),
        observed_boundary_upper = resolved[["boundary_upper"]] / nrow(x),
        mcse_boundary_lower = sqrt(
          (resolved[["boundary_lower"]] / nrow(x)) *
            (1 - resolved[["boundary_lower"]] / nrow(x)) / nrow(x)
        ),
        mcse_boundary_upper = sqrt(
          (resolved[["boundary_upper"]] / nrow(x)) *
            (1 - resolved[["boundary_upper"]] / nrow(x)) / nrow(x)
        ),
        mean_spectral_cv = mean(x$eigen_cv_population),
        mean_effective_rank = mean(x$effective_rank),
        failure_classes = failure_text, stringsAsFactors = FALSE
      )
    }))
  })
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  out <- out[v3p_d1_summary_columns]
  out$low_convergence <- v3p_bool(out$low_convergence, "low_convergence")
  out$summary_nonfinite <- v3p_bool(
    out$summary_nonfinite, "summary_nonfinite"
  )
  out$precision_blocked <- v3p_bool(
    out$precision_blocked, "precision_blocked"
  )
  out$futility_stopped <- v3p_bool(
    out$futility_stopped, "futility_stopped"
  )
  out$target_futile <- v3p_bool(out$target_futile, "target_futile")
  out$cell_eligible <- v3p_bool(out$cell_eligible, "cell_eligible")
  out
}

v3p_d0f_summary_columns <- c(
  "stage", "design_id", "design_index", "n", "m", "n_panels",
  "phenotypes_per_panel", "n_expected", "n_attempted", "n_converged",
  "n_interior", "n_interior_rescued", "n_boundary_lower",
  "n_boundary_upper", "n_unresolved", "n_error", "failure_classes",
  "convergence_rate", "d0f_status", "fit_blocker", "bootstrap_sha256",
  "variance_within",
  "variance_within_bootstrap_lower", "variance_within_bootstrap_upper",
  "variance_between", "variance_between_bootstrap_lower",
  "variance_between_bootstrap_upper", "mean_ratio", "mcse_mean_ratio",
  "empirical_sd_ratio", "boundary_lower_proportion",
  "boundary_upper_proportion", "mcse_boundary_lower",
  "mcse_boundary_upper", "median_runtime_seconds",
  "p95_runtime_seconds", "median_peak_rss_mb", "p95_peak_rss_mb"
)

v3p_d0f_components <- function(x) {
  panel <- split(x$scientific_ratio, x$panel_rank)
  if (length(panel) != 24L || any(lengths(panel) != 8L) ||
      any(!is.finite(unlist(panel)))) {
    v3p_abort("D0F variance decomposition requires eight finite fits per panel")
  }
  within <- mean(vapply(panel, stats::var, numeric(1L)))
  between <- stats::var(vapply(panel, mean, numeric(1L))) - within / 8
  c(v_within = within, v_between = between)
}

v3p_d0f_boot_components <- function(x, bootstrap_rows) {
  if (nrow(bootstrap_rows) != 24L ||
      !identical(as.integer(bootstrap_rows$panel_slot), seq_len(24L))) {
    v3p_abort("D0F bootstrap replicate does not contain 24 ordered panel slots")
  }
  resampled <- vector("list", 24L)
  for (slot in seq_len(24L)) {
    row <- bootstrap_rows[slot, , drop = FALSE]
    panel <- as.integer(row$panel_rank)
    phen_cols <- sprintf("phenotype_%02d", seq_len(8L))
    phen <- as.integer(row[phen_cols])
    source <- x[x$panel_rank == panel, , drop = FALSE]
    source <- source[order(source$phenotype_rank), , drop = FALSE]
    resampled[[slot]] <- source$scientific_ratio[phen]
  }
  within <- mean(vapply(resampled, stats::var, numeric(1L)))
  between <- stats::var(vapply(resampled, mean, numeric(1L))) - within / 8
  c(v_within = within, v_between = between)
}

v3p_d0f_summary <- function(
  manifest, attempts, bootstrap, bootstrap_sha256, binding
) {
  attempts <- v3p_admit_d0f_attempts(attempts, manifest, binding)
  bootstrap <- v3p_validate_d0f_bootstrap(
    bootstrap,
    reps = nrow(bootstrap) / (3L * 24L)
  )
  if (!v3p_hex64(bootstrap_sha256)) {
    v3p_abort("D0F summary bootstrap SHA-256 is invalid")
  }
  corpus_blocked <- any(!attempts$converged)
  corpus_status <- if (corpus_blocked) "D0F_FIT_BLOCKER" else "COMPLETE"
  rows <- lapply(v3p_d0f_designs$design_id, function(design_id) {
    x <- attempts[attempts$design_id == design_id, , drop = FALSE]
    good <- x$converged
    resolved <- c(
      interior = sum(good & x$boundary_status == "interior"),
      interior_rescued = sum(good & x$boundary_status == "interior_rescued"),
      boundary_lower = sum(good & x$boundary_status == "boundary_lower"),
      boundary_upper = sum(good & x$boundary_status == "boundary_upper")
    )
    unresolved <- sum(
      !good & !is.na(x$boundary_status) &
        x$boundary_status == "boundary_unresolved"
    )
    errors <- sum(
      !good & (is.na(x$boundary_status) |
        x$boundary_status != "boundary_unresolved")
    )
    if (sum(resolved) + unresolved + errors != nrow(x)) {
      v3p_abort("RECOMPUTATION_BLOCKER: D0F classification count invariant failed")
    }
    classes <- table(as.character(x$error_class), useNA = "ifany")
    classes <- classes[order(names(classes))]
    failure_text <- paste(
      paste(names(classes), as.integer(classes), sep = "="), collapse = ";"
    )
    observed <- c(v_within = NA_real_, v_between = NA_real_)
    boot <- matrix(NA_real_, nrow = 1L, ncol = 2L)
    mean_ratio <- mcse_mean <- empirical_sd <- NA_real_
    lower_prop <- upper_prop <- lower_mcse <- upper_mcse <- NA_real_
    if (!corpus_blocked) {
      observed <- v3p_d0f_components(x)
      b <- bootstrap[bootstrap$design_id == design_id, , drop = FALSE]
      reps <- unique(as.integer(b$bootstrap_rep))
      boot <- t(vapply(reps, function(rep) {
        v3p_d0f_boot_components(
          x, b[as.integer(b$bootstrap_rep) == rep, , drop = FALSE]
        )
      }, numeric(2L)))
      panel_means <- vapply(split(x$scientific_ratio, x$panel_rank), mean, numeric(1L))
      lower_panel <- vapply(
        split(x$boundary_status == "boundary_lower", x$panel_rank),
        mean, numeric(1L)
      )
      upper_panel <- vapply(
        split(x$boundary_status == "boundary_upper", x$panel_rank),
        mean, numeric(1L)
      )
      mean_ratio <- mean(x$scientific_ratio)
      mcse_mean <- stats::sd(panel_means) / sqrt(24)
      empirical_sd <- stats::sd(x$scientific_ratio)
      lower_prop <- mean(x$boundary_status == "boundary_lower")
      upper_prop <- mean(x$boundary_status == "boundary_upper")
      lower_mcse <- stats::sd(lower_panel) / sqrt(24)
      upper_mcse <- stats::sd(upper_panel) / sqrt(24)
    }
    within_lower <- within_upper <- between_lower <- between_upper <- NA_real_
    if (!corpus_blocked) {
      within_lower <- unname(stats::quantile(boot[, 1L], 0.025))
      within_upper <- unname(stats::quantile(boot[, 1L], 0.975))
      between_lower <- unname(stats::quantile(boot[, 2L], 0.025))
      between_upper <- unname(stats::quantile(boot[, 2L], 0.975))
    }
    design <- v3p_d0f_designs[v3p_d0f_designs$design_id == design_id, ]
    data.frame(
      stage = "d0f", design_id = design_id,
      design_index = design$design_index, n = design$n, m = design$m,
      n_panels = 24L, phenotypes_per_panel = 8L,
      n_expected = 192L, n_attempted = nrow(x), n_converged = sum(good),
      n_interior = resolved[["interior"]],
      n_interior_rescued = resolved[["interior_rescued"]],
      n_boundary_lower = resolved[["boundary_lower"]],
      n_boundary_upper = resolved[["boundary_upper"]],
      n_unresolved = unresolved, n_error = errors,
      failure_classes = failure_text,
      convergence_rate = mean(good), d0f_status = corpus_status,
      fit_blocker = corpus_blocked, bootstrap_sha256 = bootstrap_sha256,
      variance_within = observed[["v_within"]],
      variance_within_bootstrap_lower = within_lower,
      variance_within_bootstrap_upper = within_upper,
      variance_between = observed[["v_between"]],
      variance_between_bootstrap_lower = between_lower,
      variance_between_bootstrap_upper = between_upper,
      mean_ratio = mean_ratio, mcse_mean_ratio = mcse_mean,
      empirical_sd_ratio = empirical_sd,
      boundary_lower_proportion = lower_prop,
      boundary_upper_proportion = upper_prop,
      mcse_boundary_lower = lower_mcse, mcse_boundary_upper = upper_mcse,
      median_runtime_seconds = stats::median(x$runtime_seconds),
      p95_runtime_seconds = unname(stats::quantile(x$runtime_seconds, 0.95)),
      median_peak_rss_mb = stats::median(x$peak_rss_mb),
      p95_peak_rss_mb = unname(stats::quantile(x$peak_rss_mb, 0.95)),
      stringsAsFactors = FALSE
    )
  })
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  out <- out[v3p_d0f_summary_columns]
  out$fit_blocker <- v3p_bool(out$fit_blocker, "fit_blocker")
  out
}

v3p_d0f_summary_parity_fixture <- function(binding) {
  binding <- v3p_validate_attempt_binding(binding)
  hex <- function(letter) paste(rep(letter, 64L), collapse = "")

  d0_rows <- lapply(seq_len(nrow(v07d_cells)), function(i) {
    cell <- v07d_cells[i, ]
    offset <- 7101:7148
    data.frame(
      tier = "pilot", cell_id = cell$cell_id,
      cell_index = cell$cell_index, seed_offset = offset,
      seed = 2027120000 + 10000 * cell$cell_index + offset,
      n = cell$n, m = cell$m,
      truth_sigma_g2 = cell$truth_ratio,
      truth_sigma_e2 = 1 - cell$truth_ratio,
      truth_ratio = cell$truth_ratio, ridge = 0.01,
      regime = "synthetic_parity_only",
      stringsAsFactors = FALSE
    )
  })
  d0 <- do.call(rbind, d0_rows)
  rownames(d0) <- NULL
  d0 <- d0[v07d_manifest_columns]
  diagnostics <- data.frame(
    cell_id = d0$cell_id, cell_index = d0$cell_index, seed = d0$seed,
    n = d0$n, m = d0$m, truth_ratio = d0$truth_ratio,
    retained_m = pmax(1L, d0$m - 1L), ridge = d0$ridge,
    scale_denominator = 1, marker_hash = hex("a"), id_hash = hex("b"),
    kernel_hash = hex("c"), precision_hash = hex("d"),
    k_replay_max_abs = 0, qk_max_abs = 0,
    eigen_min = 0.01, eigen_max = 2, eigen_mean = 1,
    eigen_sd_population = 0.2, eigen_cv_population = 0.2,
    effective_rank = d0$n - 1L,
    information_r020 = 10, se_info_r020 = 1 / sqrt(10),
    information_r050 = 12, se_info_r050 = 1 / sqrt(12),
    information_r080 = 10, se_info_r080 = 1 / sqrt(10),
    scientific_ratio = d0$truth_ratio, absolute_ratio_error = 0,
    boundary_status = "interior", predicted_lower_probability = 0,
    predicted_upper_probability = 0,
    stringsAsFactors = FALSE
  )[v07d_diagnostic_columns]

  fixed <- v3p_d0f_fixed_panels(d0, diagnostics)
  manifest <- v3p_d0f_phenotype_manifest(fixed)
  centered <- rep(seq(-0.015, 0.015, length.out = 8L), nrow(fixed))
  panel_shift <- rep(
    rep(seq(-0.01, 0.01, length.out = 24L), each = 8L), 3L
  )
  estimates <- 0.5 + centered + panel_shift
  n <- nrow(manifest)
  results <- data.frame(
    attempted = TRUE, status = "success", error_class = "none",
    converged = TRUE, boundary_status = "interior",
    boundary_reason = "ai_interior", boundary_epsilon = v3p_boundary_epsilon,
    scientific_sigma_g2 = estimates, scientific_sigma_e2 = 1 - estimates,
    scientific_ratio = estimates, fitted_total_variance = 1,
    numerical_sigma_g2 = estimates, numerical_sigma_e2 = 1 - estimates,
    numerical_ratio = estimates, profile_loglik = -1,
    lower_derivative_per_observation = 1,
    upper_derivative_per_observation = -1, iterations = 2,
    objective = 1, gradient_norm = 0, runtime_seconds = rep(0.1, n),
    peak_rss_mb = rep(100, n), scale_denominator = 1,
    eigen_cv_population = rep(0.5, n), effective_rank = rep(50, n),
    information_r020 = rep(400, n), se_info_r020 = rep(0.05, n),
    information_r050 = rep(625, n), se_info_r050 = rep(0.04, n),
    information_r080 = rep(400, n), se_info_r080 = rep(0.05, n),
    relationship_source = "markers", relationship_method = "vanraden1",
    allele_frequency_source = "sample", relationship_scale = "K_lambda",
    route = "ordinary_auto_genomic",
    r_implementation_commit = binding[["r_auto_route_commit"]],
    julia_implementation_commit = binding[["julia_candidate_commit"]],
    driver_commit = binding[["r_driver_commit"]],
    preseal_sha256 = binding[["preseal_sha256"]],
    stringsAsFactors = FALSE
  )[v3p_result_columns]
  attempts <- cbind(manifest, results)[v3p_d0f_attempt_columns]
  attempts <- v3p_admit_d0f_attempts(attempts, manifest, binding)
  bootstrap <- v3p_d0f_bootstrap_manifest(5L)
  hash_root <- tempfile("v3p-d0f-parity-")
  dir.create(hash_root)
  on.exit(unlink(hash_root, recursive = TRUE, force = TRUE), add = TRUE)
  bootstrap_sha256 <- v3p_write_once(
    normalizePath(hash_root, winslash = "/", mustWork = TRUE),
    "bootstrap.tsv", bootstrap
  )
  list(
    manifest = manifest,
    attempts = attempts,
    bootstrap = bootstrap,
    summary = v3p_d0f_summary(
      manifest, attempts, bootstrap, bootstrap_sha256, binding
    )
  )
}

v3p_compare_tables <- function(left, right, columns, key, tolerance = 1e-10) {
  v3p_require_schema(left, columns, "left adjudication table")
  v3p_require_schema(right, columns, "right adjudication table")
  left_key <- do.call(paste, c(left[key], sep = "\r"))
  right_key <- do.call(paste, c(right[key], sep = "\r"))
  if (anyDuplicated(left_key) || anyDuplicated(right_key) ||
      !identical(left_key, right_key)) {
    v3p_abort("adjudication table key or order mismatch")
  }
  logical_fields <- names(left)[vapply(left, is.logical, logical(1L))]
  for (field in logical_fields) {
    l <- v3p_bool(left[[field]], field)
    r <- v3p_bool(right[[field]], field)
    if (!identical(l, r)) v3p_abort("summary mismatch in %s", field)
  }
  numeric_fields <- names(left)[vapply(left, is.numeric, logical(1L))]
  for (field in numeric_fields) {
    if (!v3p_same_numeric(left[[field]], right[[field]], tolerance)) {
      v3p_abort("summary mismatch in %s", field)
    }
  }
  character_fields <- setdiff(columns, c(logical_fields, numeric_fields))
  for (field in character_fields) {
    if (!identical(as.character(left[[field]]), as.character(right[[field]]))) {
      v3p_abort("summary mismatch in %s", field)
    }
  }
  invisible(TRUE)
}

v3p_adjudicate_summaries <- function(driver, base_r, julia, stage) {
  contract <- switch(
    stage,
    d0f = list(columns = v3p_d0f_summary_columns, key = c("stage", "design_id")),
    d1 = list(
      columns = v3p_d1_summary_columns,
      key = c("stage", "cell_id", "target")
    ),
    v3p_abort("adjudication stage must be d0f or d1")
  )
  v3p_compare_tables(driver, base_r, contract$columns, contract$key)
  v3p_compare_tables(driver, julia, contract$columns, contract$key)
  invisible(data.frame(stage = stage, verdict = "PASS", stringsAsFactors = FALSE))
}

v3p_admit_postrun <- function(...) {
  v3p_abort(
    "pre-seal tooling cannot admit postrun evidence; use the sealed operational adjudicator"
  )
}

v3p_selftest <- function() {
  d1 <- v3p_d1_manifest()
  stopifnot(nrow(d1) == 576L, !anyDuplicated(d1$seed))
  stopifnot(length(v3p_validate_bootstrap_seed_space()) == 3L)
  boot <- v3p_d0f_bootstrap_manifest(3L)
  stopifnot(nrow(boot) == 216L)
  changed <- boot
  changed$panel_rank[[1L]] <- if (changed$panel_rank[[1L]] == 24L) 23L else 24L
  stopifnot(inherits(
    try(v3p_validate_d0f_bootstrap(changed, 3L), silent = TRUE),
    "try-error"
  ))
  root <- tempfile("v3p-once-")
  dir.create(root)
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  on.exit(unlink(root, recursive = TRUE), add = TRUE)
  v3p_write_once(root, "synthetic.tsv", data.frame(x = 1L))
  stopifnot(inherits(
    try(v3p_write_once(root, "synthetic.tsv", data.frame(x = 2L)), silent = TRUE),
    "try-error"
  ))
  message("recovery-v3 D0F/D1 pre-seal selftest: PASS")
  invisible(TRUE)
}

v3p_main <- function(args = commandArgs(trailingOnly = TRUE)) {
  mode <- if (length(args)) args[[1L]] else "selftest"
  if (mode != "selftest") {
    v3p_abort("pre-seal tool exposes selftest only; official generation is disabled")
  }
  v3p_selftest()
}

if (sys.nframe() == 0L) v3p_main()
