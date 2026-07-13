#!/usr/bin/env Rscript

# Fail-closed end-to-end R -> Julia recovery-v2 campaign driver.  Source-safe:
# main runs only when this file is invoked directly.

v07_schema <- "v07-genomic-recovery-v2"
v07_r_auto_route_commit <- "10efc7c58e94da230cbb224b8d2f0698e2550665"
v07_r_oracle_commit <- "05ba8aed1c19a7971eeaaf3199fd1afe7d899561"
v07_julia_candidate_commit <- "fc9d39df650b20aa09d769d9f9528eed1b606f1e"
v07_julia_holdout_commit <- "fe5987c2dc5002d3b41910a0356554a8f4d7e359"
v07_holdout_checkpoint_commit <- "6e31575777d12263702ae1f6b28c315ade3f6705"
v07_boundary_bindings <- c(
  candidate_seal_sha256 = "e82e023957514621083df6ea7424cc2d14159aa43e9b567122a6edf944cfb724",
  holdout_gate_sha256 = "5d60afc5df62706444149544d5c4aa2d0e1a684d213d594a44a1e7eea622d5c1",
  holdout_timing_sha256 = "098b02ae95083f793de5605c85dbba6db2126cbf1daf4c5d53891969afe8c097",
  summary_files_lock_sha256 = "4f895bbaab54dd15781ac031de8e3053d1e02eabedbec7ae19da97dca6ee873a",
  holdout_checkpoint_doc_sha256 = "b410f01a8309b1a7887d0c272d9e1c8ac8b38310f08e7c598cd08e1adcb0b707",
  holdout_checklog_sha256 = "3a25ff9423aecd158e0361ff34016f38b810c0fb530d65a0d2c02dbce24c6e83"
)
v07_r_recomputer_sha256 <- "f449ea8d91969a3e006129ddcb33de7367472c7926e18f7844e951004f4336e0"
v07_julia_recomputer_sha256 <- "7cd15783f00336baff77dd4317f6724e0705ca4fb97396b403761c67b54040f9"
v07_expected_environment <- c(
  host = "totoro",
  cpu_model = "AMD EPYC 9655 96-Core Processor",
  machine = "x86_64-linux-gnu",
  kernel = "Linux",
  arch = "x86_64",
  julia_version = "1.10.10",
  r_version = "R version 4.5.3 (2026-03-11)",
  julia_num_threads = "1", openblas_num_threads = "1",
  omp_num_threads = "1", veclib_maximum_threads = "1"
)
v07_resolved_statuses <- c(
  "boundary_lower", "boundary_upper", "interior", "interior_rescued"
)
v07_ridge <- 0.01
v07_boundary_epsilon <- 1e-7
v07_boundary_kkt_tolerance <- 1e-8
v07_seed_base <- 2027120000
v07_reserved_offsets <- list(
  historical_pilot = 1:48,
  historical_confirmation = 1001:3000,
  spent_holdout = 5001:5048,
  spent_boundary_holdout = 6001:6048,
  recovery_pilot = 7001:7048,
  recovery_confirmation = 8001:10000
)

v07_cells <- data.frame(
  cell_id = c(
    "n120_m600_r020", "n120_m600_r050", "n120_m600_r080",
    "n300_m150_r020", "n300_m150_r050", "n300_m150_r080",
    "n300_m1000_r020", "n300_m1000_r050", "n300_m1000_r080"
  ),
  cell_index = 1:9,
  n = rep(c(120L, 300L, 300L), each = 3L),
  m = rep(c(600L, 150L, 1000L), each = 3L),
  truth_ratio = rep(c(0.2, 0.5, 0.8), 3L),
  regime = rep(c("marker_rich_n120", "marker_limited", "marker_rich_n300"), each = 3L),
  stringsAsFactors = FALSE
)
v07_cells$truth_sigma_g2 <- v07_cells$truth_ratio
v07_cells$truth_sigma_e2 <- 1 - v07_cells$truth_ratio

v07_manifest_columns <- c(
  "tier", "cell_id", "cell_index", "seed_offset", "seed", "n", "m",
  "truth_sigma_g2", "truth_sigma_e2", "truth_ratio", "ridge", "regime"
)
v07_attempt_columns <- c(
  "tier", "cell_id", "cell_index", "seed_offset", "seed", "n", "m",
  "truth_sigma_g2", "truth_sigma_e2", "truth_ratio", "ridge", "attempted",
  "status", "error_class", "converged", "boundary_status", "boundary_reason",
  "boundary_epsilon", "scientific_sigma_g2", "scientific_sigma_e2",
  "scientific_ratio", "fitted_total_variance", "numerical_sigma_g2",
  "numerical_sigma_e2", "numerical_ratio", "profile_loglik",
  "lower_derivative_per_observation", "upper_derivative_per_observation",
  "iterations", "objective",
  "gradient_norm", "runtime_seconds", "peak_rss_mb", "relationship_source",
  "relationship_method", "allele_frequency_source", "relationship_scale",
  "scale_denominator", "marker_hash", "id_hash", "kernel_hash",
  "precision_hash", "route", "r_implementation_commit",
  "julia_implementation_commit", "driver_commit", "seal_sha256"
)
v07_summary_columns <- c(
  "tier", "cell_id", "n_expected", "n_attempted", "n_converged",
  "n_bias_rows", "n_interior", "n_interior_rescued", "n_boundary_lower",
  "n_boundary_upper", "n_unresolved", "n_error", "n_resolved_valid",
  "convergence_rate", "wilson_lower", "wilson_upper",
  "target", "truth", "mean_estimate", "bias", "mcse", "pilot_sd_upper",
  "bias_ci_lower", "bias_ci_upper", "margin", "target_pass",
  "required_n_raw", "required_n", "cell_status", "campaign_status",
  "failure_classes"
)
v07_corpus_columns <- c("relative_path", "sha256")
v07_receipt_columns <- c(
  "tier", "seal_sha256", "corpus_lock_sha256", "driver_summary_sha256",
  "base_r_summary_sha256", "julia_summary_sha256", "r_recomputer_sha256",
  "julia_recomputer_sha256", "campaign_status"
)
v07_review_columns <- c(
  "schema_version", "reviewer", "verdict", "r_execution_commit",
  "julia_execution_commit", "reviewed_at_utc"
)
v07_admission_columns <- c(
  "schema_version", "r_execution_commit", "julia_execution_commit",
  "fisher_review_sha256", "fisher_review_path", "grace_review_sha256",
  "grace_review_path", "rose_review_sha256", "rose_review_path",
  "reviewed_at_utc"
)
v07_seal_keys <- c(
  "schema_version", "driver_commit", "julia_execution_commit",
  "r_selected_tree", "julia_selected_tree", "driver_sha256", "launcher_sha256",
  "doc48_sha256", "r_auto_route_commit", "r_oracle_commit",
  "julia_candidate_commit", "julia_holdout_commit", "holdout_checkpoint_commit",
  "candidate_seal_sha256", "holdout_gate_sha256", "holdout_timing_sha256",
  "summary_files_lock_sha256", "holdout_checkpoint_doc_sha256",
  "holdout_checklog_sha256", "r_recomputer_sha256",
  "julia_recomputer_sha256", "admission_receipt_sha256", "admission_receipt_path",
  "output_root", "driver_root", "r_root", "julia_root", "host",
  "cpu_model", "machine", "kernel", "arch", "julia_version", "r_version",
  "julia_num_threads", "openblas_num_threads", "omp_num_threads",
  "veclib_maximum_threads", "seed_formula", "pilot_offsets",
  "confirmation_offsets", "excluded_offsets", "ridge", "relationship_method",
  "allele_frequency_source", "relationship_scale", "boundary_epsilon",
  "boundary_kkt_tolerance",
  "resolved_statuses", "output_absent_before_seal"
)

`%||%` <- function(x, y) if (is.null(x) || !length(x)) y else x
v07_abort <- function(...) stop(sprintf(...), call. = FALSE)
v07_hex40 <- function(x) length(x) == 1L && grepl("^[0-9a-f]{40}$", x)
v07_hex64 <- function(x) length(x) == 1L && grepl("^[0-9a-f]{64}$", x)

v07_option <- function(args, key, default = NULL) {
  prefix <- paste0("--", key, "=")
  hit <- args[startsWith(args, prefix)]
  if (!length(hit)) return(default)
  if (length(hit) != 1L) v07_abort("option --%s must occur exactly once", key)
  sub(prefix, "", hit[[1L]], fixed = TRUE)
}

v07_system <- function(command, args = character()) {
  out <- system2(command, args, stdout = TRUE, stderr = TRUE)
  status <- attr(out, "status") %||% 0L
  if (status != 0L) v07_abort("command failed (%s): %s", command, paste(out, collapse = "\n"))
  out
}

v07_sha256 <- function(path) {
  if (!file.exists(path) || isTRUE(file.info(path)$isdir)) {
    v07_abort("cannot hash missing regular file: %s", path)
  }
  if (nzchar(Sys.which("shasum"))) {
    out <- v07_system("shasum", c("-a", "256", shQuote(path)))
  } else if (nzchar(Sys.which("sha256sum"))) {
    out <- v07_system("sha256sum", shQuote(path))
  } else {
    v07_abort("neither shasum nor sha256sum is available")
  }
  hash <- strsplit(out[[1L]], "[[:space:]]+")[[1L]][[1L]]
  if (!v07_hex64(hash)) v07_abort("invalid SHA-256 output for %s", path)
  hash
}

v07_realpath <- function(path) normalizePath(path, winslash = "/", mustWork = TRUE)
v07_is_symlink <- function(path) {
  link <- Sys.readlink(path)
  !is.na(link) & nzchar(link)
}

v07_git <- function(root, ...) {
  v07_system("git", c("-C", shQuote(root), ...))
}

v07_assert_git <- function(root, commit, label) {
  root <- v07_realpath(root)
  if (!identical(v07_git(root, "rev-parse", "HEAD")[[1L]], commit)) {
    v07_abort("%s checkout is not at frozen commit %s", label, commit)
  }
  if (length(v07_git(root, "status", "--porcelain"))) {
    v07_abort("%s checkout is dirty", label)
  }
  invisible(root)
}

v07_git_object <- function(root, revision, path) {
  out <- v07_git(root, "rev-parse", paste0(revision, ":", path))
  if (length(out) != 1L || !grepl("^[0-9a-f]{40}$", out[[1L]])) {
    v07_abort("could not resolve git object %s:%s", revision, path)
  }
  out[[1L]]
}

v07_assert_selected_tree <- function(root, selected_commit, path, label) {
  v07_git(root, "merge-base", "--is-ancestor", selected_commit, "HEAD")
  selected <- v07_git_object(root, selected_commit, path)
  current <- v07_git_object(root, "HEAD", path)
  if (!identical(selected, current)) {
    v07_abort("%s implementation tree differs from selected commit %s", label, selected_commit)
  }
  selected
}

v07_assert_separate_roots <- function(driver_root, r_root, julia_root) {
  roots <- vapply(list(driver_root, r_root, julia_root), v07_realpath, character(1L))
  if (anyDuplicated(roots)) v07_abort("driver, R, and Julia roots must be distinct")
  for (i in seq_along(roots)) for (j in seq_along(roots)) if (i != j) {
    if (startsWith(paste0(roots[[i]], "/"), paste0(roots[[j]], "/"))) {
      v07_abort("driver, R, and Julia roots must not be nested")
    }
  }
  names(roots) <- c("driver_root", "r_root", "julia_root")
  roots
}

v07_is_nested <- function(path, root) {
  identical(path, root) || startsWith(paste0(path, "/"), paste0(root, "/"))
}

v07_assert_new_output_root <- function(out_dir, roots) {
  if (!grepl("^/", out_dir) || !identical(sub("/+$", "", out_dir), out_dir)) {
    v07_abort("OUT must be an absolute normalized path without a trailing slash")
  }
  if (file.exists(out_dir) || dir.exists(out_dir) || v07_is_symlink(out_dir)) {
    v07_abort("OUT must be absent before seal")
  }
  parent <- dirname(out_dir)
  if (!dir.exists(parent) || v07_is_symlink(parent)) {
    v07_abort("OUT parent must be an existing real directory")
  }
  real_parent <- v07_realpath(parent)
  expected <- file.path(real_parent, basename(out_dir))
  if (!identical(out_dir, expected)) v07_abort("OUT must be canonical and may not traverse symlinks")
  for (root in roots) {
    if (v07_is_nested(out_dir, root) || v07_is_nested(root, out_dir)) {
      v07_abort("OUT and checkout roots must not be nested")
    }
  }
  out_dir
}

v07_assert_output_root <- function(out_dir, roots, expected) {
  if (!dir.exists(out_dir) || v07_is_symlink(out_dir) ||
      !identical(v07_realpath(out_dir), expected) || !identical(out_dir, expected)) {
    v07_abort("output root differs from the canonical sealed path")
  }
  for (root in roots) {
    if (v07_is_nested(expected, root) || v07_is_nested(root, expected)) {
      v07_abort("sealed output and checkout roots must not be nested")
    }
  }
  invisible(expected)
}

v07_cpu_model <- function() {
  if (file.exists("/proc/cpuinfo")) {
    x <- readLines("/proc/cpuinfo", warn = FALSE)
    hit <- sub("^[^:]+:[[:space:]]*", "", grep("^model name", x, value = TRUE)[1L])
    if (length(hit) && !is.na(hit)) return(hit)
  }
  Sys.info()[["machine"]]
}

v07_julia_environment <- function(julia_root) {
  julia <- Sys.which("julia")
  if (!nzchar(julia)) v07_abort("julia is not on PATH")
  code <- "print(join((VERSION, Sys.MACHINE, Sys.KERNEL, Sys.ARCH), '\\t'))"
  out <- v07_system(julia, c("--project=" %+% shQuote(julia_root), "-e", shQuote(code)))
  fields <- strsplit(out[[1L]], "\t", fixed = TRUE)[[1L]]
  if (length(fields) != 4L) v07_abort("could not read the exact Julia environment")
  stats::setNames(fields, c("julia_version", "machine", "kernel", "arch"))
}

`%+%` <- function(a, b) paste0(a, b)

v07_assert_compute_host <- function() {
  if (identical(Sys.getenv("V07_RECOVERY_TESTING"), "true")) return(invisible(TRUE))
  host <- tolower(Sys.info()[["nodename"]] %||% "")
  on_totoro <- identical(host, "totoro") || startsWith(host, "totoro.")
  if (!on_totoro) v07_abort("this frozen recovery-v2 campaign may run only on Totoro")
  invisible(TRUE)
}

v07_runtime_environment <- function(julia_root) {
  julia <- v07_julia_environment(julia_root)
  c(
    host = strsplit(tolower(Sys.info()[["nodename"]]), ".", fixed = TRUE)[[1L]][[1L]],
    cpu_model = v07_cpu_model(),
    machine = julia[["machine"]],
    kernel = julia[["kernel"]],
    arch = julia[["arch"]],
    julia_version = julia[["julia_version"]],
    r_version = R.version.string,
    julia_num_threads = Sys.getenv("JULIA_NUM_THREADS"),
    openblas_num_threads = Sys.getenv("OPENBLAS_NUM_THREADS"),
    omp_num_threads = Sys.getenv("OMP_NUM_THREADS"),
    veclib_maximum_threads = Sys.getenv("VECLIB_MAXIMUM_THREADS")
  )
}

v07_assert_environment <- function(julia_root) {
  actual <- v07_runtime_environment(julia_root)
  if (!identical(unname(actual), unname(v07_expected_environment))) {
    bad <- names(actual)[actual != v07_expected_environment]
    v07_abort("runtime environment differs from frozen Totoro seal: %s", paste(bad, collapse = ", "))
  }
  actual
}

v07_format <- function(x) {
  if (length(x) != 1L) v07_abort("TSV fields must be scalar")
  if (is.na(x)) return("NA")
  if (is.logical(x)) return(if (x) "true" else "false")
  if (is.numeric(x)) {
    if (!is.finite(x)) return(if (is.nan(x)) "NaN" else if (x > 0) "Inf" else "-Inf")
    return(sprintf("%.17g", x))
  }
  out <- enc2utf8(as.character(x))
  if (grepl("[\t\r\n]", out)) v07_abort("TSV string contains a delimiter")
  out
}

v07_tsv_text <- function(x) {
  if (!is.data.frame(x)) v07_abort("TSV input must be a data frame")
  header <- paste(names(x), collapse = "\t")
  rows <- if (!nrow(x)) character() else vapply(seq_len(nrow(x)), function(i) {
    paste(vapply(x[i, , drop = FALSE], v07_format, character(1L)), collapse = "\t")
  }, character(1L))
  paste0(paste(c(header, rows), collapse = "\n"), "\n")
}

v07_hardlink_once <- function(path, bytes) {
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  if (file.exists(path)) v07_abort("create-once path already exists: %s", path)
  tmp <- tempfile(".v07-write-", tmpdir = dirname(path))
  con <- file(tmp, open = "wb")
  closed <- FALSE
  on.exit({ if (!closed) close(con); unlink(tmp) }, add = TRUE)
  writeBin(bytes, con)
  close(con); closed <- TRUE
  if (!file.link(tmp, path)) v07_abort("exclusive hard-link claim failed: %s", path)
  unlink(tmp)
  invisible(path)
}

v07_write_once <- function(path, text) {
  sidecar <- paste0(path, ".sha256")
  if (xor(file.exists(path), file.exists(sidecar))) {
    v07_abort("orphan primary/sidecar before write: %s", path)
  }
  if (file.exists(path)) v07_abort("create-once output already exists: %s", path)
  v07_hardlink_once(path, charToRaw(enc2utf8(text)))
  digest <- v07_sha256(path)
  v07_hardlink_once(sidecar, charToRaw(sprintf("%s  %s\n", digest, basename(path))))
  invisible(digest)
}

v07_verify_pair <- function(path) {
  sidecar <- paste0(path, ".sha256")
  if (!file.exists(path) || !file.exists(sidecar)) v07_abort("missing/orphan file pair: %s", path)
  line <- readLines(sidecar, warn = FALSE)
  expected <- sprintf("%s  %s", v07_sha256(path), basename(path))
  if (!identical(line, expected)) v07_abort("checksum sidecar mismatch: %s", path)
  invisible(TRUE)
}

v07_read_tsv <- function(path, columns) {
  v07_verify_pair(path)
  x <- utils::read.delim(path, sep = "\t", quote = "", comment.char = "",
    stringsAsFactors = FALSE, check.names = FALSE, na.strings = c("NA", "NaN"))
  if (!identical(names(x), columns)) v07_abort("schema drift in %s", path)
  x
}

v07_seal_path <- function(out_dir) file.path(out_dir, "campaign_seal.tsv")

v07_read_seal <- function(out_dir) {
  x <- v07_read_tsv(v07_seal_path(out_dir), c("key", "value"))
  if (!identical(x$key, v07_seal_keys) || anyDuplicated(x$key)) v07_abort("seal key/order drift")
  stats::setNames(as.character(x$value), x$key)
}

v07_assert_recomputer <- function(path, digest, language) {
  if (!v07_hex64(digest)) v07_abort("%s recovery-v2 recomputer is not sealed", language)
  if (!identical(v07_sha256(path), digest)) v07_abort("%s recomputer digest drift", language)
  code <- paste(readLines(path, warn = FALSE), collapse = "\n")
  required <- c("pilot_sd_upper", "wilson_lower", "required_n", "bias_ci_lower")
  if (any(!vapply(required, grepl, logical(1L), x = code, fixed = TRUE))) {
    v07_abort("%s recomputer lacks frozen G5 summary fields", language)
  }
  invisible(TRUE)
}

v07_assert_holdout_checkpoint <- function(julia_root) {
  paths <- c(
    holdout_checkpoint_doc_sha256 = file.path(julia_root, "docs", "dev-log",
      "recovery-checkpoints", "2026-07-13-v07-genomic-boundary-performance-holdout.md"),
    holdout_checklog_sha256 = file.path(julia_root, "docs", "dev-log", "check-log.d",
      "2026-07-13-v07-genomic-boundary-performance-holdout.md")
  )
  for (key in names(paths)) {
    if (!identical(v07_sha256(paths[[key]]), v07_boundary_bindings[[key]])) {
      v07_abort("durable predecessor evidence drift in %s", key)
    }
  }
  invisible(TRUE)
}

v07_assert_external_pair <- function(path, label) {
  if (is.null(path) || !grepl("^/", path) || v07_is_symlink(path) ||
      !file.exists(path) || !file.exists(paste0(path, ".sha256")) ||
      !identical(v07_realpath(path), path)) {
    v07_abort("%s must be an absolute canonical primary/sidecar pair", label)
  }
  v07_verify_pair(path)
  invisible(path)
}

v07_read_review <- function(path, reviewer, driver_commit, julia_execution_commit) {
  v07_assert_external_pair(path, paste(reviewer, "review receipt"))
  x <- v07_read_tsv(path, v07_review_columns)
  if (nrow(x) != 1L ||
      !identical(x$schema_version, "v07-genomic-recovery-v2-review-1") ||
      !identical(x$reviewer, reviewer) || !identical(x$verdict, "CLEAN") ||
      !identical(x$r_execution_commit, driver_commit) ||
      !identical(x$julia_execution_commit, julia_execution_commit) ||
      !grepl("^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$", x$reviewed_at_utc)) {
    v07_abort("%s review does not attest CLEAN for the exact execution commits", reviewer)
  }
  invisible(x)
}

v07_write_review <- function(path, reviewer, verdict, driver_commit,
                             julia_execution_commit, reviewed_at_utc) {
  if (is.null(path) || length(path) != 1L || !grepl("^/", path) ||
      file.exists(path) || file.exists(paste0(path, ".sha256")) ||
      !dir.exists(dirname(path)) || v07_is_symlink(dirname(path)) ||
      !identical(file.path(v07_realpath(dirname(path)), basename(path)), path)) {
    v07_abort("new review path must be absent beneath a canonical real parent")
  }
  if (is.null(reviewer) || length(reviewer) != 1L ||
      is.null(verdict) || length(verdict) != 1L ||
      !reviewer %in% c("Fisher", "Grace", "Rose") || !verdict %in% c("CLEAN", "BLOCKED") ||
      !v07_hex40(driver_commit) || !v07_hex40(julia_execution_commit) ||
      is.null(reviewed_at_utc) || length(reviewed_at_utc) != 1L ||
      !grepl("^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$", reviewed_at_utc)) {
    v07_abort("review requires a known reviewer/verdict, two full commits, and an ISO UTC time")
  }
  x <- data.frame(
    schema_version = "v07-genomic-recovery-v2-review-1", reviewer = reviewer,
    verdict = verdict, r_execution_commit = driver_commit,
    julia_execution_commit = julia_execution_commit,
    reviewed_at_utc = reviewed_at_utc, stringsAsFactors = FALSE
  )
  v07_write_once(path, v07_tsv_text(x))
  invisible(x)
}

v07_read_admission <- function(path, driver_commit, julia_execution_commit) {
  v07_assert_external_pair(path, "execution admission receipt")
  x <- v07_read_tsv(path, v07_admission_columns)
  if (nrow(x) != 1L ||
      !identical(x$schema_version, "v07-genomic-recovery-v2-admission-2") ||
      !identical(x$r_execution_commit, driver_commit) ||
      !identical(x$julia_execution_commit, julia_execution_commit) ||
      !grepl("^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$", x$reviewed_at_utc)) {
    v07_abort("execution admission receipt does not bind the exact execution commits")
  }
  for (reviewer in c("fisher", "grace", "rose")) {
    receipt_path <- x[[paste0(reviewer, "_review_path")]]
    receipt_hash <- x[[paste0(reviewer, "_review_sha256")]]
    label <- c(fisher = "Fisher", grace = "Grace", rose = "Rose")[[reviewer]]
    v07_read_review(receipt_path, label, driver_commit, julia_execution_commit)
    if (!identical(v07_sha256(receipt_path), receipt_hash)) {
      v07_abort("%s review receipt differs from admission", reviewer)
    }
  }
  invisible(x)
}

v07_write_admission <- function(path, driver_commit, julia_execution_commit,
                                fisher_review, grace_review, rose_review,
                                reviewed_at_utc) {
  if (is.null(path) || !grepl("^/", path) || file.exists(path) ||
      file.exists(paste0(path, ".sha256")) || !dir.exists(dirname(path)) ||
      v07_is_symlink(dirname(path)) ||
      !identical(file.path(v07_realpath(dirname(path)), basename(path)), path)) {
    v07_abort("new admission path must be absent beneath a canonical real parent")
  }
  if (!v07_hex40(driver_commit) || !v07_hex40(julia_execution_commit) ||
      is.null(reviewed_at_utc) || length(reviewed_at_utc) != 1L ||
      !grepl("^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$", reviewed_at_utc)) {
    v07_abort("admission requires two full commits and an ISO UTC review time")
  }
  reviews <- c(fisher = fisher_review, grace = grace_review, rose = rose_review)
  for (reviewer in names(reviews)) {
    label <- c(fisher = "Fisher", grace = "Grace", rose = "Rose")[[reviewer]]
    v07_read_review(reviews[[reviewer]], label,
      driver_commit, julia_execution_commit)
  }
  x <- data.frame(
    schema_version = "v07-genomic-recovery-v2-admission-2",
    r_execution_commit = driver_commit, julia_execution_commit = julia_execution_commit,
    fisher_review_sha256 = v07_sha256(fisher_review), fisher_review_path = fisher_review,
    grace_review_sha256 = v07_sha256(grace_review), grace_review_path = grace_review,
    rose_review_sha256 = v07_sha256(rose_review), rose_review_path = rose_review,
    reviewed_at_utc = reviewed_at_utc, stringsAsFactors = FALSE
  )
  v07_write_once(path, v07_tsv_text(x))
  invisible(x)
}

v07_create_seal <- function(out_dir, driver_root, r_root, julia_root, driver_commit,
                            julia_execution_commit, admission_receipt) {
  v07_assert_compute_host()
  roots <- v07_assert_separate_roots(driver_root, r_root, julia_root)
  output_root <- v07_assert_new_output_root(out_dir, roots)
  if (!v07_hex40(driver_commit) || !v07_hex40(julia_execution_commit)) {
    v07_abort("driver and Julia execution commits must be full SHA-1 values")
  }
  v07_read_admission(admission_receipt, driver_commit, julia_execution_commit)
  v07_assert_git(roots[["driver_root"]], driver_commit, "driver")
  v07_assert_git(roots[["r_root"]], driver_commit, "R execution")
  v07_assert_git(roots[["julia_root"]], julia_execution_commit, "Julia execution")
  r_selected_tree <- v07_assert_selected_tree(
    roots[["r_root"]], v07_r_auto_route_commit, "R", "R auto-route"
  )
  julia_selected_tree <- v07_assert_selected_tree(
    roots[["julia_root"]], v07_julia_candidate_commit, "src", "Julia candidate"
  )
  v07_assert_holdout_checkpoint(roots[["julia_root"]])
  env <- v07_assert_environment(roots[["julia_root"]])
  driver <- file.path(roots[["driver_root"]], "tools", "v07_genomic_recovery_v2.R")
  launcher <- file.path(roots[["driver_root"]], "tools", "run-v07-genomic-recovery-v2.sh")
  doc48 <- file.path(roots[["driver_root"]], "docs", "design", "48-v07-genomic-recovery-v2.md")
  r_recomputer <- file.path(roots[["r_root"]], "tools", "v07_genomic_recovery_v2_recompute.R")
  julia_recomputer <- file.path(roots[["julia_root"]], "sim", "phase2_v07_genomic_recovery_v2_recompute.jl")
  v07_assert_recomputer(r_recomputer, v07_r_recomputer_sha256, "base-R")
  v07_assert_recomputer(julia_recomputer, v07_julia_recomputer_sha256, "Julia")
  values <- c(
    schema_version = v07_schema, driver_commit = driver_commit,
    julia_execution_commit = julia_execution_commit,
    r_selected_tree = r_selected_tree, julia_selected_tree = julia_selected_tree,
    driver_sha256 = v07_sha256(driver), launcher_sha256 = v07_sha256(launcher),
    doc48_sha256 = v07_sha256(doc48), r_auto_route_commit = v07_r_auto_route_commit,
    r_oracle_commit = v07_r_oracle_commit, julia_candidate_commit = v07_julia_candidate_commit,
    julia_holdout_commit = v07_julia_holdout_commit,
    holdout_checkpoint_commit = v07_holdout_checkpoint_commit,
    v07_boundary_bindings,
    r_recomputer_sha256 = v07_r_recomputer_sha256,
    julia_recomputer_sha256 = v07_julia_recomputer_sha256,
    admission_receipt_sha256 = v07_sha256(admission_receipt),
    admission_receipt_path = admission_receipt,
    output_root = output_root, roots, env,
    seed_formula = "2027120000+10000*cell_index+offset",
    pilot_offsets = "7001:7048", confirmation_offsets = "8001:10000",
    excluded_offsets = "1:48,1001:3000,5001:5048,6001:6048",
    ridge = "0.01", relationship_method = "vanraden1",
    allele_frequency_source = "sample", relationship_scale = "K_lambda",
    boundary_epsilon = "1e-07", boundary_kkt_tolerance = "1e-08",
    resolved_statuses = paste(v07_resolved_statuses, collapse = ","),
    output_absent_before_seal = "true"
  )
  if (!identical(names(values), v07_seal_keys)) v07_abort("internal seal writer/key drift")
  dir.create(out_dir, recursive = FALSE)
  v07_assert_output_root(out_dir, roots, output_root)
  seal <- data.frame(key = names(values), value = unname(values), stringsAsFactors = FALSE)
  v07_write_once(v07_seal_path(out_dir), v07_tsv_text(seal))
  invisible(seal)
}

v07_assert_bound_state <- function(out_dir, driver_root, r_root, julia_root) {
  seal <- v07_read_seal(out_dir)
  roots <- v07_assert_separate_roots(driver_root, r_root, julia_root)
  v07_assert_output_root(out_dir, roots, seal[["output_root"]])
  if (!identical(unname(roots), unname(seal[names(roots)]))) v07_abort("checkout path differs from seal")
  v07_assert_git(roots[["driver_root"]], seal[["driver_commit"]], "driver")
  v07_assert_git(roots[["r_root"]], seal[["driver_commit"]], "R execution")
  v07_assert_git(roots[["julia_root"]], seal[["julia_execution_commit"]], "Julia execution")
  if (!identical(v07_assert_selected_tree(roots[["r_root"]], v07_r_auto_route_commit,
      "R", "R auto-route"), seal[["r_selected_tree"]]) ||
      !identical(v07_assert_selected_tree(roots[["julia_root"]], v07_julia_candidate_commit,
      "src", "Julia candidate"), seal[["julia_selected_tree"]])) {
    v07_abort("selected implementation tree binding differs from seal")
  }
  v07_assert_holdout_checkpoint(roots[["julia_root"]])
  sealed_files <- c(
    driver_sha256 = file.path(roots[["driver_root"]], "tools", "v07_genomic_recovery_v2.R"),
    launcher_sha256 = file.path(roots[["driver_root"]], "tools", "run-v07-genomic-recovery-v2.sh"),
    doc48_sha256 = file.path(roots[["driver_root"]], "docs", "design", "48-v07-genomic-recovery-v2.md"),
    r_recomputer_sha256 = file.path(roots[["r_root"]], "tools", "v07_genomic_recovery_v2_recompute.R"),
    julia_recomputer_sha256 = file.path(roots[["julia_root"]], "sim", "phase2_v07_genomic_recovery_v2_recompute.jl")
  )
  for (key in names(sealed_files)) {
    if (!identical(v07_sha256(sealed_files[[key]]), seal[[key]])) {
      v07_abort("%s bytes differ from seal", key)
    }
  }
  v07_read_admission(seal[["admission_receipt_path"]], seal[["driver_commit"]],
    seal[["julia_execution_commit"]])
  if (!identical(v07_sha256(seal[["admission_receipt_path"]]), seal[["admission_receipt_sha256"]])) {
    v07_abort("execution admission receipt differs from seal")
  }
  v07_assert_environment(roots[["julia_root"]])
  invisible(list(seal = seal, roots = roots))
}

v07_manifest <- function(tier, required = NULL) {
  if (!tier %in% c("pilot", "confirm")) v07_abort("tier must be pilot or confirm")
  rows <- list(); at <- 0L
  for (i in seq_len(nrow(v07_cells))) {
    count <- if (tier == "pilot") 48L else as.integer(required[[v07_cells$cell_id[[i]]]])
    offsets <- if (tier == "pilot") 7001:7048 else 8001:(8000L + count)
    for (offset in offsets) {
      at <- at + 1L
      cell <- v07_cells[i, ]
      rows[[at]] <- data.frame(
        tier = tier, cell_id = cell$cell_id, cell_index = cell$cell_index,
        seed_offset = offset, seed = v07_seed_base + 10000L * cell$cell_index + offset,
        n = cell$n, m = cell$m, truth_sigma_g2 = cell$truth_sigma_g2,
        truth_sigma_e2 = cell$truth_sigma_e2, truth_ratio = cell$truth_ratio,
        ridge = v07_ridge, regime = cell$regime, stringsAsFactors = FALSE
      )
    }
  }
  out <- do.call(rbind, rows); rownames(out) <- NULL
  if (!identical(names(out), v07_manifest_columns)) v07_abort("manifest schema drift")
  out
}

v07_validate_disjoint_seeds <- function(pilot, confirm = NULL) {
  if (!all(pilot$seed_offset == rep(7001:7048, times = 9L))) v07_abort("pilot offset drift")
  if (!is.null(confirm)) {
    if (length(intersect(pilot$seed, confirm$seed))) v07_abort("pilot/confirmation seed overlap")
    if (any(confirm$seed_offset < 8001 | confirm$seed_offset > 10000)) v07_abort("confirmation offset drift")
  }
  all_offsets <- unlist(v07_reserved_offsets[1:4], use.names = FALSE)
  if (any(pilot$seed_offset %in% all_offsets) || (!is.null(confirm) && any(confirm$seed_offset %in% all_offsets))) {
    v07_abort("recovery manifest overlaps a reserved historical seed block")
  }
  invisible(TRUE)
}

v07_write_pilot_manifest <- function(out_dir, driver_root, r_root, julia_root) {
  v07_assert_compute_host(); v07_assert_bound_state(out_dir, driver_root, r_root, julia_root)
  manifest <- v07_manifest("pilot"); v07_validate_disjoint_seeds(manifest)
  v07_write_once(file.path(out_dir, "pilot_manifest.tsv"), v07_tsv_text(manifest))
  invisible(manifest)
}

v07_peak_rss_mb <- function() {
  if (file.exists("/proc/self/status")) {
    x <- grep("^VmHWM:", readLines("/proc/self/status", warn = FALSE), value = TRUE)
    if (length(x)) return(as.numeric(gsub("[^0-9]", "", x[[1L]])) / 1024)
  }
  NA_real_
}

v07_fit_call <- function(M, dat) {
  # The exact ordinary call is load-bearing: no engine or target control.
  hsquared::hsquared(
    y ~ genomic(1 | id, markers = M),
    data = dat,
    family = stats::gaussian(),
    REML = TRUE
  )
}

v07_fit_one <- function(manifest_row, r_root, julia_root) {
  start <- proc.time()[["elapsed"]]
  packet <- NULL
  base <- as.list(manifest_row[1L, , drop = FALSE])
  result <- c(base[setdiff(v07_manifest_columns, "regime")], list(
    attempted = TRUE, status = "fit_error", error_class = "unclassified_error",
    converged = FALSE, boundary_status = NA_character_, boundary_reason = NA_character_,
    boundary_epsilon = NA_real_, scientific_sigma_g2 = NA_real_, scientific_sigma_e2 = NA_real_,
    scientific_ratio = NA_real_, fitted_total_variance = NA_real_, numerical_sigma_g2 = NA_real_,
    numerical_sigma_e2 = NA_real_, numerical_ratio = NA_real_, profile_loglik = NA_real_,
    lower_derivative_per_observation = NA_real_, upper_derivative_per_observation = NA_real_,
    iterations = NA_real_, objective = NA_real_, gradient_norm = NA_real_,
    runtime_seconds = NA_real_, peak_rss_mb = NA_real_,
    relationship_source = NA_character_, relationship_method = NA_character_,
    allele_frequency_source = NA_character_, relationship_scale = NA_character_,
    scale_denominator = NA_real_, marker_hash = NA_character_, id_hash = NA_character_,
    kernel_hash = NA_character_, precision_hash = NA_character_, route = "ordinary_auto_genomic",
    r_implementation_commit = v07_r_auto_route_commit,
    julia_implementation_commit = v07_julia_candidate_commit,
    driver_commit = NA_character_, seal_sha256 = NA_character_
  ))
  tryCatch({
    if (!requireNamespace("pkgload", quietly = TRUE)) v07_abort("pkgload is required")
    Sys.setenv(HSQUARED_JULIA_PROJECT = julia_root)
    pkgload::load_all(r_root, quiet = TRUE, export_all = FALSE, helpers = FALSE)
    RNGkind("Mersenne-Twister", "Inversion", "Rejection")
    set.seed(as.integer(manifest_row$seed))
    n <- as.integer(manifest_row$n); m <- as.integer(manifest_row$m)
    pi <- stats::runif(m, 0.05, 0.5)
    M <- matrix(stats::rbinom(n * m, 2L, rep(pi, each = n)), nrow = n, ncol = m)
    keep <- apply(M, 2L, function(x) length(unique(x)) > 1L)
    M <- M[, keep, drop = FALSE]
    if (!ncol(M)) v07_abort("all_markers_monomorphic")
    ids <- sprintf("g%06d", seq_len(n)); rownames(M) <- ids
    colnames(M) <- sprintf("m%06d", which(keep))
    p <- colMeans(M) / 2; W <- sweep(M, 2L, 2 * p, "-")
    k <- 2 * sum(p * (1 - p)); if (!is.finite(k) || k <= 0) v07_abort("nonpositive_vanraden_denominator")
    K <- tcrossprod(W) / k + v07_ridge * diag(n)
    L <- t(chol(K))
    u <- sqrt(manifest_row$truth_sigma_g2) * as.numeric(L %*% stats::rnorm(n))
    epsilon <- sqrt(manifest_row$truth_sigma_e2) * stats::rnorm(n)
    dat <- data.frame(y = u + epsilon, id = ids, stringsAsFactors = FALSE)
    packet <- list(
      markers = data.frame(id = ids, M, check.names = FALSE),
      ids = data.frame(index = seq_len(n), id = ids, stringsAsFactors = FALSE),
      phenotype = data.frame(index = seq_len(n), id = ids, y = dat$y, stringsAsFactors = FALSE),
      truth = data.frame(
        cell_id = manifest_row$cell_id, seed = manifest_row$seed, n = n,
        requested_m = m, retained_m = ncol(M), truth_sigma_g2 = manifest_row$truth_sigma_g2,
        truth_sigma_e2 = manifest_row$truth_sigma_e2, truth_ratio = manifest_row$truth_ratio,
        ridge = v07_ridge, scale_denominator = k, stringsAsFactors = FALSE
      )
    )
    fit <- v07_fit_call(M, dat)
    boundary <- fit$result$genomic_boundary
    if (is.null(boundary)) v07_abort("missing_boundary_status")
    # Preserve unresolved boundary evidence as a classified failed attempt.
    result$boundary_status <- boundary$status
    result$boundary_reason <- boundary$reason
    result$boundary_epsilon <- boundary$boundary_epsilon
    result$profile_loglik <- boundary$profile_loglik
    result$lower_derivative_per_observation <- boundary$lower_derivative_per_observation
    result$upper_derivative_per_observation <- boundary$upper_derivative_per_observation
    if (identical(boundary$status, "boundary_unresolved")) v07_abort("boundary_unresolved")
    if (!boundary$status %in% v07_resolved_statuses) v07_abort("unknown_boundary_status")
    if (!isTRUE(fit$result$converged)) v07_abort("fit_result_not_converged")
    pr <- as.numeric(boundary$profile_ratio)
    vc <- hsquared::variance_components(fit)
    ng <- vc$estimate[vc$component == "genomic"]
    ne <- vc$estimate[vc$component == "residual"]
    if (length(ng) != 1L || length(ne) != 1L) v07_abort("variance_component_schema")
    # The preregistered scientific endpoint combines the profile-resolved ratio
    # with the fitted numerical total. It is not a separately profile-fitted total.
    fitted_total <- as.numeric(ng + ne)
    boundary_evidence <- c(boundary$profile_loglik,
      boundary$lower_derivative_per_observation,
      boundary$upper_derivative_per_observation)
    if (!is.finite(pr) || !is.finite(fitted_total) || fitted_total <= 0 || pr < 0 || pr > 1 ||
        any(!is.finite(boundary_evidence))) v07_abort("invalid_scientific_profile")
    prov <- fit$result$relationship_provenance
    hashes <- c(prov$marker_content_fingerprint, prov$id_order_fingerprint,
      prov$kernel_fingerprint, prov$precision_fingerprint)
    if (any(!vapply(hashes, v07_hex64, logical(1L)))) v07_abort("invalid_provenance_hash")
    result[names(result)] <- result[names(result)]
    result$status <- "success"; result$error_class <- "none"; result$converged <- TRUE
    result$boundary_status <- boundary$status; result$boundary_reason <- boundary$reason
    result$boundary_epsilon <- boundary$boundary_epsilon
    result$scientific_sigma_g2 <- pr * fitted_total
    result$scientific_sigma_e2 <- (1 - pr) * fitted_total
    result$scientific_ratio <- pr; result$fitted_total_variance <- fitted_total
    result$numerical_sigma_g2 <- as.numeric(ng); result$numerical_sigma_e2 <- as.numeric(ne)
    result$numerical_ratio <- as.numeric(boundary$numerical_ratio)
    result$profile_loglik <- as.numeric(boundary$profile_loglik)
    result$lower_derivative_per_observation <- as.numeric(boundary$lower_derivative_per_observation)
    result$upper_derivative_per_observation <- as.numeric(boundary$upper_derivative_per_observation)
    result$iterations <- fit$result$diagnostics$iterations %||% NA_real_
    result$objective <- if (!is.null(fit$result$loglik)) -as.numeric(fit$result$loglik) else NA_real_
    result$gradient_norm <- fit$result$diagnostics$gradient_norm %||% NA_real_
    result$relationship_source <- prov$relationship_source
    result$relationship_method <- prov$relationship_method
    result$allele_frequency_source <- prov$allele_frequency_source
    result$relationship_scale <- prov$relationship_scale
    result$scale_denominator <- prov$scale_denominator
    result$marker_hash <- hashes[[1L]]; result$id_hash <- hashes[[2L]]
    result$kernel_hash <- hashes[[3L]]; result$precision_hash <- hashes[[4L]]
  }, error = function(e) {
    result$error_class <<- gsub("[^a-z0-9]+", "_", tolower(conditionMessage(e)))
    result$error_class <<- substr(gsub("^_|_$", "", result$error_class), 1L, 120L)
  })
  result$runtime_seconds <- proc.time()[["elapsed"]] - start
  result$peak_rss_mb <- v07_peak_rss_mb()
  out <- as.data.frame(result, stringsAsFactors = FALSE, check.names = FALSE)
  out <- out[v07_attempt_columns]
  attr(out, "packet") <- packet
  out
}

v07_attempt_path <- function(out_dir, tier, cell_id, seed) {
  file.path(out_dir, "attempts", tier, cell_id, sprintf("%d.tsv", as.integer(seed)))
}

v07_packet_dir <- function(out_dir, tier, cell_id, seed) {
  file.path(out_dir, "packets", tier, cell_id, sprintf("%d", as.integer(seed)))
}

v07_write_packet <- function(out_dir, tier, cell_id, seed, packet) {
  if (is.null(packet)) v07_abort("dataset construction failed before a reconstructable packet existed")
  root <- v07_packet_dir(out_dir, tier, cell_id, seed)
  if (file.exists(root) || dir.exists(root)) v07_abort("packet path already exists")
  dir.create(root, recursive = TRUE)
  objects <- packet[c("markers", "ids", "phenotype", "truth")]
  paths <- file.path(root, paste0(names(objects), ".tsv"))
  for (i in seq_along(paths)) v07_write_once(paths[[i]], v07_tsv_text(objects[[i]]))
  lock <- data.frame(file = basename(paths),
    sha256 = vapply(paths, v07_sha256, character(1L)), stringsAsFactors = FALSE)
  v07_write_once(file.path(root, "packet_files_lock.tsv"), v07_tsv_text(lock))
  invisible(root)
}

v07_verify_packet <- function(out_dir, tier, cell_id, seed) {
  root <- v07_packet_dir(out_dir, tier, cell_id, seed)
  primary <- c("markers.tsv", "ids.tsv", "phenotype.tsv", "truth.tsv", "packet_files_lock.tsv")
  expected <- sort(c(primary, paste0(primary, ".sha256")))
  if (!identical(sort(list.files(root, all.files = TRUE, no.. = TRUE)), expected)) {
    v07_abort("packet primary/sidecar file set drift")
  }
  lapply(file.path(root, primary), v07_verify_pair)
  lock <- v07_read_tsv(file.path(root, "packet_files_lock.tsv"), c("file", "sha256"))
  if (!identical(as.character(lock$file), primary[1:4]) ||
      !identical(as.character(lock$sha256), unname(vapply(file.path(root, primary[1:4]), v07_sha256, character(1L))))) {
    v07_abort("packet files lock mismatch")
  }
  invisible(TRUE)
}

v07_seed_output_state <- function(out_dir, tier, cell_id, seed) {
  attempt <- v07_attempt_path(out_dir, tier, cell_id, seed)
  attempt_files <- c(attempt, paste0(attempt, ".sha256"))
  attempt_present <- file.exists(attempt_files)
  if (all(attempt_present)) {
    v07_verify_pair(attempt)
  } else if (any(attempt_present)) {
    v07_abort("partial attempt primary/sidecar pair is tampered or orphaned")
  }
  attempt_complete <- all(attempt_present)

  packet <- v07_packet_dir(out_dir, tier, cell_id, seed)
  primary <- c("markers.tsv", "ids.tsv", "phenotype.tsv", "truth.tsv", "packet_files_lock.tsv")
  expected <- sort(c(primary, paste0(primary, ".sha256")))
  packet_complete <- FALSE
  packet_present <- dir.exists(packet) || file.exists(packet)
  if (packet_present) {
    if (!dir.exists(packet) || v07_is_symlink(packet)) v07_abort("seed packet path is not a real directory")
    actual <- sort(list.files(packet, all.files = TRUE, no.. = TRUE))
    if (length(setdiff(actual, expected))) v07_abort("interrupted seed packet contains an unexpected file")
    for (name in primary) {
      has_primary <- name %in% actual
      has_sidecar <- paste0(name, ".sha256") %in% actual
      if (has_sidecar && !has_primary) v07_abort("packet sidecar exists without its primary")
      if (has_primary && has_sidecar) v07_verify_pair(file.path(packet, name))
    }
    if (identical(actual, expected)) {
      v07_verify_packet(out_dir, tier, cell_id, seed)
      packet_complete <- TRUE
    }
  }

  if (attempt_complete && packet_complete) return("complete")
  if (!any(attempt_present) && !packet_present) return("absent")
  if (attempt_complete && !packet_present) {
    row <- v07_read_tsv(attempt, v07_attempt_columns)
    if (nrow(row) == 1L && identical(row$status, "fit_error") && row$error_class != "none") {
      return("terminal_prepacket_failure")
    }
    v07_abort("successful or malformed attempt exists without its packet")
  }
  if (attempt_complete && packet_present && !packet_complete) {
    v07_abort("immutable attempt exists with an incomplete packet")
  }
  "interrupted"
}

v07_clear_interrupted_seed <- function(out_dir, tier, cell_id, seed) {
  if (!identical(v07_seed_output_state(out_dir, tier, cell_id, seed), "interrupted")) {
    v07_abort("only a provably interrupted seed may be cleared")
  }
  attempt <- v07_attempt_path(out_dir, tier, cell_id, seed)
  packet <- v07_packet_dir(out_dir, tier, cell_id, seed)
  unlink(c(attempt, paste0(attempt, ".sha256")), force = TRUE)
  if (dir.exists(packet)) unlink(packet, recursive = TRUE, force = TRUE)
  if (!identical(v07_seed_output_state(out_dir, tier, cell_id, seed), "absent")) {
    v07_abort("interrupted seed cleanup did not restore an absent slot")
  }
  invisible(TRUE)
}

v07_run_one <- function(out_dir, driver_root, r_root, julia_root, tier, cell_id, seed) {
  v07_assert_compute_host()
  bound <- v07_assert_bound_state(out_dir, driver_root, r_root, julia_root)
  manifest <- v07_read_tsv(file.path(out_dir, paste0(tier, "_manifest.tsv")), v07_manifest_columns)
  seed <- as.numeric(seed)
  hit <- manifest$cell_id == cell_id & manifest$seed == seed
  if (sum(hit) != 1L) v07_abort("requested cell/seed is not exactly one manifest row")
  path <- v07_attempt_path(out_dir, tier, cell_id, seed)
  state <- v07_seed_output_state(out_dir, tier, cell_id, seed)
  if (state %in% c("complete", "terminal_prepacket_failure")) {
    return(invisible(v07_read_tsv(path, v07_attempt_columns)))
  }
  if (identical(state, "interrupted")) v07_clear_interrupted_seed(out_dir, tier, cell_id, seed)
  row <- v07_fit_one(manifest[hit, , drop = FALSE], bound$roots[["r_root"]], bound$roots[["julia_root"]])
  packet <- attr(row, "packet"); attr(row, "packet") <- NULL
  row$driver_commit <- bound$seal[["driver_commit"]]
  row$seal_sha256 <- v07_sha256(v07_seal_path(out_dir))
  if (!is.null(packet)) v07_write_packet(out_dir, tier, cell_id, seed, packet)
  v07_write_once(path, v07_tsv_text(row))
  invisible(row)
}

v07_as_numeric <- function(x, field) {
  out <- suppressWarnings(as.numeric(x)); bad <- is.na(out) & !is.na(x)
  if (any(bad)) v07_abort("%s contains nonnumeric values", field)
  out
}

v07_normalize_attempts <- function(x) {
  numeric <- c("cell_index", "seed_offset", "seed", "n", "m", "truth_sigma_g2",
    "truth_sigma_e2", "truth_ratio", "ridge", "boundary_epsilon",
    "scientific_sigma_g2", "scientific_sigma_e2", "scientific_ratio", "fitted_total_variance",
    "numerical_sigma_g2", "numerical_sigma_e2", "numerical_ratio", "profile_loglik",
    "lower_derivative_per_observation", "upper_derivative_per_observation", "iterations",
    "objective", "gradient_norm", "runtime_seconds", "peak_rss_mb", "scale_denominator")
  for (field in numeric) x[[field]] <- v07_as_numeric(x[[field]], field)
  for (field in c("attempted", "converged")) {
    z <- tolower(as.character(x[[field]])); if (any(!z %in% c("true", "false"))) v07_abort("%s must be true/false", field)
    x[[field]] <- z == "true"
  }
  x
}

v07_validate_attempts <- function(attempts, manifest, tier) {
  attempts <- v07_normalize_attempts(attempts)
  if (anyDuplicated(paste(attempts$cell_id, attempts$seed))) v07_abort("duplicate attempt key")
  key <- function(x) paste(x$cell_id, x$seed, sep = "\r")
  if (!identical(sort(key(attempts)), sort(key(manifest)))) v07_abort("attempt set is not exactly the manifest denominator")
  manifest <- manifest[match(key(attempts), key(manifest)), , drop = FALSE]
  shared <- c("tier", "cell_id", "cell_index", "seed_offset", "seed", "n", "m",
    "truth_sigma_g2", "truth_sigma_e2", "truth_ratio", "ridge")
  for (field in shared) if (!identical(as.character(attempts[[field]]), as.character(manifest[[field]]))) {
    v07_abort("attempt/manifest mismatch in %s", field)
  }
  if (any(!attempts$attempted)) v07_abort("every manifest member must retain attempted=true")
  if (any(attempts$ridge != v07_ridge)) v07_abort("frozen ridge mutation")
  good <- attempts$status == "success"
  if (any(good != attempts$converged)) v07_abort("status/convergence mismatch")
  if (any(good & attempts$error_class != "none") || any(!good & attempts$error_class == "none")) {
    v07_abort("status/failure-class mismatch")
  }
  finite_science <- is.finite(attempts$scientific_sigma_g2) &
    is.finite(attempts$scientific_sigma_e2) & is.finite(attempts$scientific_ratio)
  if (any(good & !finite_science)) v07_abort("successful attempt lacks finite scientific estimates")
  if (any(good & !attempts$boundary_status %in% v07_resolved_statuses)) v07_abort("successful boundary status is unresolved")
  if (any(good & attempts$boundary_epsilon != v07_boundary_epsilon)) v07_abort("boundary epsilon drift")
  reason <- c(boundary_lower = "boundary_lower", boundary_upper = "boundary_upper",
    interior = "ai_interior", interior_rescued = "profile_interior")
  if (any(good & attempts$boundary_reason != unname(reason[attempts$boundary_status]))) {
    v07_abort("boundary status/reason mismatch")
  }
  evidence <- is.finite(attempts$profile_loglik) &
    is.finite(attempts$lower_derivative_per_observation) &
    is.finite(attempts$upper_derivative_per_observation) &
    is.finite(attempts$fitted_total_variance) & attempts$fitted_total_variance >= 0
  if (any(good & !evidence)) v07_abort("successful fit lacks finite boundary evidence")
  lower <- good & attempts$boundary_status == "boundary_lower"
  upper <- good & attempts$boundary_status == "boundary_upper"
  interior <- good & attempts$boundary_status %in% c("interior", "interior_rescued")
  if (any(lower & attempts$lower_derivative_per_observation > v07_boundary_kkt_tolerance) ||
      any(upper & attempts$upper_derivative_per_observation < -v07_boundary_kkt_tolerance) ||
      any(interior & !(attempts$lower_derivative_per_observation > v07_boundary_kkt_tolerance &
        attempts$upper_derivative_per_observation < -v07_boundary_kkt_tolerance))) {
    v07_abort("status-specific boundary KKT derivative signs mismatch")
  }
  if (any(attempts$scientific_ratio[lower] != 0) || any(attempts$scientific_sigma_g2[lower] != 0) ||
      any(attempts$scientific_ratio[upper] != 1) || any(attempts$scientific_sigma_e2[upper] != 0)) {
    v07_abort("resolved endpoint is not represented on the scientific boundary")
  }
  total <- attempts$numerical_sigma_g2 + attempts$numerical_sigma_e2
  if (any(good & (!is.finite(total) | total <= 0)) ||
      any(good & abs(attempts$numerical_ratio - attempts$numerical_sigma_g2 / total) > 1e-12) ||
      any(attempts$numerical_ratio[lower] != v07_boundary_epsilon) ||
      any(attempts$numerical_ratio[upper] != 1 - v07_boundary_epsilon) ||
      any(attempts$scientific_ratio[interior] <= 0 | attempts$scientific_ratio[interior] >= 1)) {
    v07_abort("status-specific numerical/scientific ratio mismatch")
  }
  if (any(good & abs(attempts$scientific_sigma_g2 - attempts$scientific_ratio * attempts$fitted_total_variance) > 1e-12) ||
      any(good & abs(attempts$scientific_sigma_e2 - (1 - attempts$scientific_ratio) * attempts$fitted_total_variance) > 1e-12)) {
    v07_abort("scientific components do not equal the frozen profile endpoint")
  }
  if (any(good & attempts$route != "ordinary_auto_genomic")) v07_abort("route mutation")
  if (any(attempts$r_implementation_commit != v07_r_auto_route_commit) ||
      any(attempts$julia_implementation_commit != v07_julia_candidate_commit) ||
      any(!vapply(attempts$driver_commit, v07_hex40, logical(1L))) ||
      any(!vapply(attempts$seal_sha256, v07_hex64, logical(1L)))) {
    v07_abort("implementation/seal provenance mutation")
  }
  if (any(good & (attempts$relationship_source != "markers" |
      attempts$relationship_method != "vanraden1" |
      attempts$allele_frequency_source != "sample" |
      attempts$relationship_scale != "K_lambda"))) v07_abort("relationship provenance mutation")
  for (field in c("marker_hash", "id_hash", "kernel_hash", "precision_hash")) {
    if (any(good & !vapply(attempts[[field]], v07_hex64, logical(1L)))) v07_abort("invalid %s", field)
  }
  for (n in unique(attempts$n[good])) {
    if (length(unique(attempts$id_hash[good & attempts$n == n])) != 1L) v07_abort("ID-order hash mutation")
  }
  if (any(!is.finite(attempts$runtime_seconds) | attempts$runtime_seconds < 0)) v07_abort("invalid runtime")
  attempts
}

v07_read_attempts <- function(out_dir, manifest, tier) {
  v07_verify_tier_layout(out_dir, manifest, tier)
  expected <- vapply(seq_len(nrow(manifest)), function(i) {
    v07_attempt_path(out_dir, tier, manifest$cell_id[[i]], manifest$seed[[i]])
  }, character(1L))
  actual <- sort(list.files(file.path(out_dir, "attempts", tier), pattern = "\\.tsv$", recursive = TRUE, full.names = TRUE))
  if (!identical(sort(v07_realpath(actual)), sort(v07_realpath(expected)))) v07_abort("attempt primary file set differs from manifest")
  sidecars <- sort(list.files(file.path(out_dir, "attempts", tier), pattern = "\\.tsv\\.sha256$", recursive = TRUE, full.names = TRUE))
  if (!identical(sort(sidecars), sort(paste0(actual, ".sha256")))) v07_abort("attempt sidecar set differs from primaries")
  rows <- lapply(expected, v07_read_tsv, columns = v07_attempt_columns)
  if (any(vapply(rows, nrow, integer(1L)) != 1L)) v07_abort("every attempt file must contain one row")
  for (i in seq_len(nrow(manifest))) {
    v07_verify_packet(out_dir, tier, manifest$cell_id[[i]], manifest$seed[[i]])
  }
  attempts <- do.call(rbind, rows)
  seal <- v07_read_seal(out_dir)
  seal_sha256 <- v07_sha256(v07_seal_path(out_dir))
  if (any(attempts$driver_commit != seal[["driver_commit"]]) ||
      any(attempts$seal_sha256 != seal_sha256)) {
    v07_abort("attempt provenance differs from the current campaign seal")
  }
  attempts
}

v07_wilson <- function(k, n) {
  z <- stats::qnorm(0.975); phat <- k / n; den <- 1 + z^2 / n
  center <- (phat + z^2 / (2 * n)) / den
  half <- z * sqrt(phat * (1 - phat) / n + z^2 / (4 * n^2)) / den
  c(center - half, center + half)
}

v07_failure_classes <- function(x) {
  tab <- table(x); tab <- tab[sort(names(tab))]
  paste(sprintf("%s=%d", names(tab), as.integer(tab)), collapse = ";")
}

v07_summarize <- function(attempts, manifest, tier) {
  attempts <- v07_validate_attempts(attempts, manifest, tier)
  out <- list(); at <- 0L
  specs <- list(
    list("sigma_g2", "scientific_sigma_g2", "truth_sigma_g2", function(x) 0.05 * x),
    list("sigma_e2", "scientific_sigma_e2", "truth_sigma_e2", function(x) 0.05 * x),
    list("ratio", "scientific_ratio", "truth_ratio", function(x) 0.02)
  )
  for (cell in v07_cells$cell_id) {
    cr <- attempts[attempts$cell_id == cell, , drop = FALSE]
    cm <- manifest[manifest$cell_id == cell, , drop = FALSE]
    n_attempted <- nrow(cm); good <- cr$converged
    n_converged <- sum(good); rate <- n_converged / n_attempted; wilson <- v07_wilson(n_converged, n_attempted)
    target_rows <- list()
    for (j in seq_along(specs)) {
      spec <- specs[[j]]; values <- cr[[spec[[2L]]]][good]; truth <- unique(cr[[spec[[3L]]]])
      if (length(truth) != 1L) v07_abort("truth mutation within cell")
      margin <- spec[[4L]](truth); mean_est <- bias <- mcse <- sd_upper <- lo <- hi <- NA_real_
      required_raw <- Inf; pass <- FALSE
      if (length(values) >= 2L && all(is.finite(values))) {
        mean_est <- mean(values); bias <- mean_est - truth; sdv <- stats::sd(values)
        mcse <- sdv / sqrt(length(values))
        if (tier == "pilot") {
          sd_upper <- sdv * sqrt((length(values) - 1) / stats::qchisq(0.05, length(values) - 1))
          required_raw <- ceiling((stats::qnorm(0.975) * sd_upper / (margin / 2))^2)
        } else {
          critical <- stats::qt(0.975, df = length(values) - 1)
          lo <- bias - critical * mcse; hi <- bias + critical * mcse
          pass <- lo > -margin && hi < margin
          required_raw <- 0
        }
      }
      target_rows[[j]] <- data.frame(
        target = spec[[1L]], truth = truth, mean_estimate = mean_est, bias = bias,
        mcse = mcse, pilot_sd_upper = sd_upper, bias_ci_lower = lo,
        bias_ci_upper = hi, margin = margin, target_pass = pass,
        required_n_raw = required_raw, stringsAsFactors = FALSE
      )
    }
    target_rows <- do.call(rbind, target_rows)
    raw_max <- max(target_rows$required_n_raw)
    required_n <- if (is.finite(raw_max)) max(200, raw_max) else Inf
    status <- if (tier == "pilot" && n_converged < 46L) {
      "STOP_LOW_PILOT_CONVERGENCE"
    } else if (tier == "pilot" && required_n > 2000) {
      "PRECISION_BLOCKER"
    } else if (tier == "pilot") {
      "CONFIRMATION_ELIGIBLE"
    } else if (all(target_rows$target_pass) && rate >= 0.95 && wilson[[1L]] >= 0.90) {
      "PASS"
    } else "FAIL"
    common <- data.frame(tier = tier, cell_id = cell, n_expected = nrow(cm),
      n_attempted = n_attempted, n_converged = n_converged, n_bias_rows = n_converged,
      n_interior = sum(good & cr$boundary_status == "interior", na.rm = TRUE),
      n_interior_rescued = sum(good & cr$boundary_status == "interior_rescued", na.rm = TRUE),
      n_boundary_lower = sum(good & cr$boundary_status == "boundary_lower", na.rm = TRUE),
      n_boundary_upper = sum(good & cr$boundary_status == "boundary_upper", na.rm = TRUE),
      n_unresolved = sum(cr$boundary_status == "boundary_unresolved", na.rm = TRUE),
      n_error = sum(!good & (is.na(cr$boundary_status) | cr$boundary_status != "boundary_unresolved")),
      n_resolved_valid = n_converged,
      convergence_rate = rate, wilson_lower = wilson[[1L]], wilson_upper = wilson[[2L]],
      stringsAsFactors = FALSE)
    classified <- sum(common[1L, c("n_interior", "n_interior_rescued", "n_boundary_lower",
      "n_boundary_upper", "n_unresolved", "n_error")])
    if (classified != n_attempted) v07_abort("status breakdown does not equal attempted denominator")
    tail <- data.frame(required_n = required_n, cell_status = status, campaign_status = NA_character_,
      failure_classes = v07_failure_classes(cr$error_class), stringsAsFactors = FALSE)
    at <- at + 1L; out[[at]] <- cbind(common[rep(1L, 3L), ], target_rows, tail[rep(1L, 3L), ])
  }
  ans <- do.call(rbind, out); rownames(ans) <- NULL
  cell_status <- unique(ans[c("cell_id", "cell_status")])$cell_status
  ans$campaign_status <- if (tier == "pilot" && any(cell_status == "STOP_LOW_PILOT_CONVERGENCE")) {
    "STOP_LOW_PILOT_CONVERGENCE"
  } else if (tier == "pilot" && any(cell_status == "PRECISION_BLOCKER")) {
    "PRECISION_BLOCKER"
  } else if (tier == "pilot") {
    "CONFIRMATION_ELIGIBLE"
  } else if (all(cell_status == "PASS")) "PASS" else "FAIL"
  ans[v07_summary_columns]
}

v07_compare_summary <- function(x, y, tolerance = 1e-10) {
  if (!identical(names(x), v07_summary_columns) || !identical(names(y), v07_summary_columns)) {
    v07_abort("summary schema drift")
  }
  key <- function(z) paste(z$tier, z$cell_id, z$target, sep = "\r")
  if (!identical(sort(key(x)), sort(key(y)))) v07_abort("summary key mismatch")
  y <- y[match(key(x), key(y)), , drop = FALSE]
  numeric <- c("n_expected", "n_attempted", "n_converged", "n_bias_rows",
    "n_interior", "n_interior_rescued", "n_boundary_lower", "n_boundary_upper",
    "n_unresolved", "n_error", "n_resolved_valid",
    "convergence_rate", "wilson_lower", "wilson_upper", "truth", "mean_estimate",
    "bias", "mcse", "pilot_sd_upper", "bias_ci_lower", "bias_ci_upper", "margin",
    "required_n_raw", "required_n")
  for (field in numeric) {
    a <- as.numeric(x[[field]]); b <- as.numeric(y[[field]])
    same <- is.na(a) == is.na(b) & (is.na(a) |
      (is.finite(a) & is.finite(b) & abs(a - b) <= tolerance) |
      (is.infinite(a) & is.infinite(b) & sign(a) == sign(b)))
    if (!all(same)) v07_abort("summary mismatch in %s", field)
  }
  other <- setdiff(v07_summary_columns, numeric)
  for (field in other) if (!identical(as.character(x[[field]]), as.character(y[[field]]))) {
    v07_abort("summary mismatch in %s", field)
  }
  invisible(TRUE)
}

v07_corpus_lock_path <- function(out_dir, tier) file.path(out_dir, paste0(tier, "_corpus_lock.tsv"))
v07_receipt_path <- function(out_dir, tier) file.path(out_dir, paste0(tier, "_adjudication_receipt.tsv"))

v07_verify_tier_layout <- function(out_dir, manifest, tier) {
  cells <- unique(as.character(manifest$cell_id))
  for (kind in c("attempts", "packets")) {
    root <- file.path(out_dir, kind, tier)
    actual <- sort(list.dirs(root, recursive = FALSE, full.names = FALSE))
    if (!identical(actual, sort(cells))) v07_abort("%s/%s cell directory set drift", kind, tier)
    dirs <- file.path(root, actual)
    if (any(v07_is_symlink(dirs))) v07_abort("symlinked %s/%s cell directory", kind, tier)
  }
  for (cell in cells) {
    rows <- manifest[manifest$cell_id == cell, , drop = FALSE]
    attempt_root <- file.path(out_dir, "attempts", tier, cell)
    attempt_names <- sprintf("%d.tsv", as.integer(rows$seed))
    expected_attempt <- sort(c(attempt_names, paste0(attempt_names, ".sha256")))
    if (!identical(sort(list.files(attempt_root, all.files = TRUE, no.. = TRUE)), expected_attempt)) {
      v07_abort("attempt file set drift for %s/%s", tier, cell)
    }
    packet_root <- file.path(out_dir, "packets", tier, cell)
    expected_packet <- sort(sprintf("%d", as.integer(rows$seed)))
    actual_packet <- sort(list.dirs(packet_root, recursive = FALSE, full.names = FALSE))
    if (!identical(actual_packet, expected_packet)) v07_abort("packet directory set drift for %s/%s", tier, cell)
    packet_dirs <- file.path(packet_root, actual_packet)
    if (any(v07_is_symlink(packet_dirs))) v07_abort("symlinked packet directory for %s/%s", tier, cell)
  }
  invisible(TRUE)
}

v07_corpus_entries <- function(out_dir, manifest, tier) {
  v07_verify_tier_layout(out_dir, manifest, tier)
  paths <- file.path(out_dir, paste0(tier, "_manifest.tsv"))
  for (i in seq_len(nrow(manifest))) {
    paths <- c(paths,
      v07_attempt_path(out_dir, tier, manifest$cell_id[[i]], manifest$seed[[i]]),
      file.path(v07_packet_dir(out_dir, tier, manifest$cell_id[[i]], manifest$seed[[i]]),
        c("markers.tsv", "ids.tsv", "phenotype.tsv", "truth.tsv", "packet_files_lock.tsv")))
  }
  invisible(lapply(paths, v07_verify_pair))
  root <- v07_realpath(out_dir)
  real <- vapply(paths, v07_realpath, character(1L))
  prefix <- paste0(root, "/")
  if (any(!startsWith(real, prefix))) v07_abort("corpus path escapes output root")
  out <- data.frame(
    relative_path = substring(real, nchar(prefix) + 1L),
    sha256 = vapply(real, v07_sha256, character(1L)),
    stringsAsFactors = FALSE
  )
  out <- out[order(out$relative_path), v07_corpus_columns, drop = FALSE]
  if (anyDuplicated(out$relative_path)) v07_abort("duplicate corpus path")
  rownames(out) <- NULL
  out
}

v07_write_corpus_lock <- function(out_dir, manifest, tier) {
  lock <- v07_corpus_entries(out_dir, manifest, tier)
  path <- v07_corpus_lock_path(out_dir, tier)
  if (xor(file.exists(path), file.exists(paste0(path, ".sha256")))) {
    v07_abort("orphan corpus-lock primary/sidecar")
  }
  if (!file.exists(path)) v07_write_once(path, v07_tsv_text(lock))
  v07_verify_corpus_lock(out_dir, manifest, tier)
  invisible(lock)
}

v07_verify_corpus_lock <- function(out_dir, manifest, tier) {
  observed <- v07_read_tsv(v07_corpus_lock_path(out_dir, tier), v07_corpus_columns)
  expected <- v07_corpus_entries(out_dir, manifest, tier)
  if (!identical(observed, expected)) v07_abort("%s corpus differs from its sealed lock", tier)
  invisible(expected)
}

v07_write_summary <- function(out_dir, driver_root, r_root, julia_root, tier) {
  v07_assert_compute_host(); v07_assert_bound_state(out_dir, driver_root, r_root, julia_root)
  manifest <- v07_read_tsv(file.path(out_dir, paste0(tier, "_manifest.tsv")), v07_manifest_columns)
  attempts <- v07_read_attempts(out_dir, manifest, tier)
  v07_write_corpus_lock(out_dir, manifest, tier)
  summary <- v07_summarize(attempts, manifest, tier)
  v07_write_once(file.path(out_dir, paste0(tier, "_summary_driver_r.tsv")), v07_tsv_text(summary))
  invisible(summary)
}

v07_adjudicate_summaries <- function(out_dir, driver_root, r_root, julia_root, tier) {
  v07_assert_compute_host(); bound <- v07_assert_bound_state(out_dir, driver_root, r_root, julia_root)
  manifest <- v07_read_tsv(file.path(out_dir, paste0(tier, "_manifest.tsv")), v07_manifest_columns)
  attempts <- v07_read_attempts(out_dir, manifest, tier)
  v07_verify_corpus_lock(out_dir, manifest, tier)
  expected <- v07_summarize(attempts, manifest, tier)
  driver <- v07_read_tsv(file.path(out_dir, paste0(tier, "_summary_driver_r.tsv")), v07_summary_columns)
  base_r <- v07_read_tsv(file.path(out_dir, paste0(tier, "_summary_base_r.tsv")), v07_summary_columns)
  julia <- v07_read_tsv(file.path(out_dir, paste0(tier, "_summary_julia.tsv")), v07_summary_columns)
  v07_compare_summary(expected, driver, tolerance = 1e-10)
  v07_compare_summary(driver, base_r, tolerance = 1e-10)
  v07_compare_summary(driver, julia, tolerance = 1e-10)
  statuses <- unique(as.character(driver$campaign_status))
  if (length(statuses) != 1L) v07_abort("summary has multiple campaign statuses")
  summaries <- c(
    driver_summary_sha256 = v07_sha256(file.path(out_dir, paste0(tier, "_summary_driver_r.tsv"))),
    base_r_summary_sha256 = v07_sha256(file.path(out_dir, paste0(tier, "_summary_base_r.tsv"))),
    julia_summary_sha256 = v07_sha256(file.path(out_dir, paste0(tier, "_summary_julia.tsv")))
  )
  receipt <- data.frame(
    tier = tier,
    seal_sha256 = v07_sha256(v07_seal_path(out_dir)),
    corpus_lock_sha256 = v07_sha256(v07_corpus_lock_path(out_dir, tier)),
    driver_summary_sha256 = summaries[["driver_summary_sha256"]],
    base_r_summary_sha256 = summaries[["base_r_summary_sha256"]],
    julia_summary_sha256 = summaries[["julia_summary_sha256"]],
    r_recomputer_sha256 = bound$seal[["r_recomputer_sha256"]],
    julia_recomputer_sha256 = bound$seal[["julia_recomputer_sha256"]],
    campaign_status = statuses,
    stringsAsFactors = FALSE
  )
  receipt_path <- v07_receipt_path(out_dir, tier)
  if (xor(file.exists(receipt_path), file.exists(paste0(receipt_path, ".sha256")))) {
    v07_abort("orphan adjudication-receipt primary/sidecar")
  }
  if (!file.exists(receipt_path)) v07_write_once(receipt_path, v07_tsv_text(receipt))
  v07_verify_adjudication_receipt(out_dir, driver_root, r_root, julia_root, tier)
  invisible(driver)
}

v07_verify_adjudication_receipt <- function(out_dir, driver_root, r_root, julia_root, tier) {
  bound <- v07_assert_bound_state(out_dir, driver_root, r_root, julia_root)
  manifest <- v07_read_tsv(file.path(out_dir, paste0(tier, "_manifest.tsv")), v07_manifest_columns)
  attempts <- v07_read_attempts(out_dir, manifest, tier)
  v07_verify_corpus_lock(out_dir, manifest, tier)
  expected <- v07_summarize(attempts, manifest, tier)
  summaries <- list(
    driver = v07_read_tsv(file.path(out_dir, paste0(tier, "_summary_driver_r.tsv")), v07_summary_columns),
    base_r = v07_read_tsv(file.path(out_dir, paste0(tier, "_summary_base_r.tsv")), v07_summary_columns),
    julia = v07_read_tsv(file.path(out_dir, paste0(tier, "_summary_julia.tsv")), v07_summary_columns)
  )
  v07_compare_summary(expected, summaries$driver)
  v07_compare_summary(summaries$driver, summaries$base_r)
  v07_compare_summary(summaries$driver, summaries$julia)
  status <- unique(as.character(summaries$driver$campaign_status))
  if (length(status) != 1L) v07_abort("summary has multiple campaign statuses")
  observed <- v07_read_tsv(v07_receipt_path(out_dir, tier), v07_receipt_columns)
  if (nrow(observed) != 1L) v07_abort("adjudication receipt must have one row")
  expected_receipt <- data.frame(
    tier = tier,
    seal_sha256 = v07_sha256(v07_seal_path(out_dir)),
    corpus_lock_sha256 = v07_sha256(v07_corpus_lock_path(out_dir, tier)),
    driver_summary_sha256 = v07_sha256(file.path(out_dir, paste0(tier, "_summary_driver_r.tsv"))),
    base_r_summary_sha256 = v07_sha256(file.path(out_dir, paste0(tier, "_summary_base_r.tsv"))),
    julia_summary_sha256 = v07_sha256(file.path(out_dir, paste0(tier, "_summary_julia.tsv"))),
    r_recomputer_sha256 = bound$seal[["r_recomputer_sha256"]],
    julia_recomputer_sha256 = bound$seal[["julia_recomputer_sha256"]],
    campaign_status = status,
    stringsAsFactors = FALSE
  )
  if (!identical(observed, expected_receipt)) v07_abort("adjudication receipt/current corpus mismatch")
  invisible(summaries$driver)
}

v07_write_confirmation_manifest <- function(out_dir, driver_root, r_root, julia_root) {
  v07_assert_compute_host(); v07_assert_bound_state(out_dir, driver_root, r_root, julia_root)
  pilot <- v07_read_tsv(file.path(out_dir, "pilot_manifest.tsv"), v07_manifest_columns)
  summary <- v07_verify_adjudication_receipt(out_dir, driver_root, r_root, julia_root, "pilot")
  if (any(summary$cell_status != "CONFIRMATION_ELIGIBLE")) {
    v07_abort("whole campaign stops: at least one pilot cell is ineligible")
  }
  req <- tapply(as.numeric(summary$required_n), summary$cell_id, unique)
  if (any(lengths(req) != 1L) || any(!is.finite(unlist(req))) || any(unlist(req) > 2000)) {
    v07_abort("whole campaign stops: invalid or >2000 confirmation requirement")
  }
  manifest <- v07_manifest("confirm", req); v07_validate_disjoint_seeds(pilot, manifest)
  v07_write_once(file.path(out_dir, "confirm_manifest.tsv"), v07_tsv_text(manifest))
  invisible(manifest)
}

v07_pair_names <- function(name) c(name, paste0(name, ".sha256"))

v07_stage_top <- function(stage) {
  if (is.null(stage) || length(stage) != 1L) v07_abort("verification stage is required")
  sealed <- v07_pair_names("campaign_seal.tsv")
  pilot_manifest <- c(sealed, v07_pair_names("pilot_manifest.tsv"))
  pilot_complete <- c(pilot_manifest, "attempts", "packets",
    unlist(lapply(c("pilot_summary_driver_r.tsv", "pilot_summary_base_r.tsv",
      "pilot_summary_julia.tsv", "pilot_corpus_lock.tsv", "pilot_adjudication_receipt.tsv"), v07_pair_names)))
  confirm_manifest <- c(pilot_complete, v07_pair_names("confirm_manifest.tsv"))
  confirm_complete <- c(confirm_manifest,
    unlist(lapply(c("confirm_summary_driver_r.tsv", "confirm_summary_base_r.tsv",
      "confirm_summary_julia.tsv", "confirm_corpus_lock.tsv", "confirm_adjudication_receipt.tsv"), v07_pair_names)))
  stages <- list(sealed = sealed, pilot_manifest = pilot_manifest,
    pilot_complete = pilot_complete, confirm_manifest = confirm_manifest,
    confirm_complete = confirm_complete)
  if (is.null(stages[[stage]])) v07_abort("unknown verification stage: %s", stage)
  sort(unname(stages[[stage]]))
}

v07_verify_tree <- function(out_dir, driver_root, r_root, julia_root, stage) {
  v07_assert_bound_state(out_dir, driver_root, r_root, julia_root)
  top <- sort(list.files(out_dir, recursive = FALSE, all.files = TRUE, no.. = TRUE))
  expected_top <- v07_stage_top(stage)
  if (!identical(top, expected_top)) v07_abort("campaign tree does not exactly match stage %s", stage)
  top_paths <- file.path(out_dir, top)
  if (any(v07_is_symlink(top_paths))) v07_abort("symlinked top-level campaign entry")
  if (stage %in% c("pilot_complete", "confirm_manifest", "confirm_complete")) {
    expected_tiers <- if (stage == "confirm_complete") c("confirm", "pilot") else "pilot"
    for (kind in c("attempts", "packets")) {
      tiers <- sort(list.dirs(file.path(out_dir, kind), recursive = FALSE, full.names = FALSE))
      if (!identical(tiers, sort(expected_tiers))) v07_abort("%s tier directory set differs from stage %s", kind, stage)
      if (any(v07_is_symlink(file.path(out_dir, kind, tiers)))) v07_abort("symlinked campaign tier directory")
    }
  }
  files <- list.files(out_dir, recursive = TRUE, full.names = TRUE, all.files = TRUE, no.. = TRUE)
  primaries <- files[!file.info(files)$isdir & !endsWith(files, ".sha256")]
  sidecars <- files[!file.info(files)$isdir & endsWith(files, ".sha256")]
  if (!identical(sort(paste0(primaries, ".sha256")), sort(sidecars))) v07_abort("orphan/additional sidecar in output tree")
  invisible(lapply(primaries, v07_verify_pair))
  pilot <- NULL
  if (stage != "sealed") {
    pilot <- v07_read_tsv(file.path(out_dir, "pilot_manifest.tsv"), v07_manifest_columns)
    v07_validate_disjoint_seeds(pilot)
  }
  if (stage %in% c("pilot_complete", "confirm_manifest", "confirm_complete")) {
    v07_verify_adjudication_receipt(out_dir, driver_root, r_root, julia_root, "pilot")
  }
  if (stage %in% c("confirm_manifest", "confirm_complete")) {
    confirm <- v07_read_tsv(file.path(out_dir, "confirm_manifest.tsv"), v07_manifest_columns)
    v07_validate_disjoint_seeds(pilot, confirm)
  }
  if (stage == "confirm_complete") {
    v07_verify_adjudication_receipt(out_dir, driver_root, r_root, julia_root, "confirm")
  }
  invisible(TRUE)
}

v07_selftest <- function() {
  pilot <- v07_manifest("pilot")
  stopifnot(nrow(pilot) == 432L, identical(pilot$seed_offset, rep(7001:7048, 9L)))
  code <- paste(deparse(body(v07_fit_call)), collapse = "\n")
  stopifnot(grepl("hsquared::hsquared", code, fixed = TRUE),
    !grepl("hs_control", code, fixed = TRUE), !grepl("engine_control", code, fixed = TRUE))
  root <- tempfile("v07-selftest-"); dir.create(root); on.exit(unlink(root, recursive = TRUE))
  path <- file.path(root, "once.tsv"); v07_write_once(path, "x\n"); v07_verify_pair(path)
  failed <- inherits(try(v07_write_once(path, "y\n"), silent = TRUE), "try-error")
  stopifnot(failed, v07_hex64(v07_r_recomputer_sha256), v07_hex64(v07_julia_recomputer_sha256))
  if (.Platform$OS.type != "windows") {
    contested <- file.path(root, "contested.tsv")
    jobs <- lapply(1:2, function(i) parallel::mcparallel(
      !inherits(try(v07_write_once(contested, sprintf("writer%d\n", i)), silent = TRUE), "try-error")
    ))
    wins <- unlist(parallel::mccollect(jobs), use.names = FALSE)
    stopifnot(sum(wins) == 1L, file.exists(contested), file.exists(paste0(contested, ".sha256")))
  }
  message("v0.7 genomic recovery-v2 selftest: PASS (no campaign seal created)")
  invisible(TRUE)
}

v07_main <- function(args = commandArgs(trailingOnly = TRUE)) {
  mode <- v07_option(args, "mode")
  if (identical(mode, "selftest")) return(v07_selftest())
  if (identical(mode, "review")) {
    return(v07_write_review(v07_option(args, "path"), v07_option(args, "reviewer"),
      v07_option(args, "verdict"), v07_option(args, "driver-commit"),
      v07_option(args, "julia-execution-commit"), v07_option(args, "reviewed-at-utc")))
  }
  if (identical(mode, "admission")) {
    return(v07_write_admission(v07_option(args, "path"), v07_option(args, "driver-commit"),
      v07_option(args, "julia-execution-commit"), v07_option(args, "fisher-review"),
      v07_option(args, "grace-review"), v07_option(args, "rose-review"),
      v07_option(args, "reviewed-at-utc")))
  }
  out <- v07_option(args, "out-dir")
  driver <- v07_option(args, "driver-root"); r_root <- v07_option(args, "r-root")
  julia <- v07_option(args, "julia-root")
  if (any(vapply(list(mode, out, driver, r_root, julia), is.null, logical(1L)))) {
    v07_abort("mode, out-dir, driver-root, r-root, and julia-root are required")
  }
  if (mode == "seal") {
    v07_create_seal(out, driver, r_root, julia, v07_option(args, "driver-commit"),
      v07_option(args, "julia-execution-commit"), v07_option(args, "admission-receipt"))
  } else if (mode == "pilot-manifest") {
    v07_write_pilot_manifest(out, driver, r_root, julia)
  } else if (mode == "confirmation-manifest") {
    v07_write_confirmation_manifest(out, driver, r_root, julia)
  } else if (mode == "run-one") {
    v07_run_one(out, driver, r_root, julia, v07_option(args, "tier"),
      v07_option(args, "cell-id"), v07_option(args, "seed"))
  } else if (mode == "summarize") {
    v07_write_summary(out, driver, r_root, julia, v07_option(args, "tier"))
  } else if (mode == "adjudicate") {
    v07_adjudicate_summaries(out, driver, r_root, julia, v07_option(args, "tier"))
  } else if (mode == "verify") {
    v07_verify_tree(out, driver, r_root, julia, v07_option(args, "stage"))
  } else v07_abort("unknown mode: %s", mode)
}

if (sys.nframe() == 0L) v07_main()
