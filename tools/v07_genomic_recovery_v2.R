#!/usr/bin/env Rscript

# Fail-closed end-to-end R -> Julia recovery-v2 campaign driver.  Source-safe:
# main runs only when this file is invoked directly.

v07_schema <- "v07-genomic-recovery-v2"
v07_r_auto_route_commit <- "1082d84f4269d4f79fdc248558ec56b8f710b8d2"
v07_r_oracle_commit <- "05ba8aed1c19a7971eeaaf3199fd1afe7d899561"
v07_julia_candidate_commit <- "fc9d39df650b20aa09d769d9f9528eed1b606f1e"
v07_julia_holdout_commit <- "fe5987c2dc5002d3b41910a0356554a8f4d7e359"
v07_holdout_checkpoint_commit <- "6e31575777d12263702ae1f6b28c315ade3f6705"
v07_boundary_bindings <- c(
  candidate_seal_sha256 = "e82e023957514621083df6ea7424cc2d14159aa43e9b567122a6edf944cfb724",
  holdout_gate_sha256 = "5d60afc5df62706444149544d5c4aa2d0e1a684d213d594a44a1e7eea622d5c1",
  holdout_timing_sha256 = "098b02ae95083f793de5605c85dbba6db2126cbf1daf4c5d53891969afe8c097",
  summary_files_lock_sha256 = "4f895bbaab54dd15781ac031de8e3053d1e02eabedbec7ae19da97dca6ee873a",
  holdout_checkpoint_doc_sha256 = "51307db4cc977125e21bb764bbdf8a021a2b8a5c38584dd98da26d4029ecfb3f",
  holdout_checklog_sha256 = "3a25ff9423aecd158e0361ff34016f38b810c0fb530d65a0d2c02dbce24c6e83"
)
v07_r_recomputer_sha256 <- "331a6a52ee823a635072668fc286aa73c93404efb80c75e6df3ea4a5b60538e9"
v07_julia_recomputer_sha256 <- "908c090a727ae96fed348affab314ae349526dfe865c7b6cc174178df632fc4c"
v07_expected_environment <- c(
  host = "totoro",
  cpu_model = "AMD EPYC 9655 96-Core Processor",
  machine = "x86_64-linux-gnu",
  kernel = "Linux",
  arch = "x86_64",
  julia_version = "1.10.10",
  r_version = "R version 4.5.3 (2026-03-11) -- \"Reassured Reassurer\"",
  julia_num_threads = "1", openblas_num_threads = "1",
  omp_num_threads = "1", veclib_maximum_threads = "1"
)
v07_resolved_statuses <- c(
  "boundary_lower", "boundary_upper", "interior", "interior_rescued"
)
v07_ridge <- 0.01
v07_boundary_epsilon <- 1e-7
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
  "scientific_ratio", "profile_t_hat", "numerical_sigma_g2",
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
v07_seal_keys <- c(
  "schema_version", "driver_commit", "julia_execution_commit",
  "r_selected_tree", "julia_selected_tree", "driver_sha256", "launcher_sha256",
  "doc48_sha256", "r_auto_route_commit", "r_oracle_commit",
  "julia_candidate_commit", "julia_holdout_commit", "holdout_checkpoint_commit",
  "candidate_seal_sha256", "holdout_gate_sha256", "holdout_timing_sha256",
  "summary_files_lock_sha256", "holdout_checkpoint_doc_sha256",
  "holdout_checklog_sha256", "r_recomputer_sha256",
  "julia_recomputer_sha256", "driver_root", "r_root", "julia_root", "host",
  "cpu_model", "machine", "kernel", "arch", "julia_version", "r_version",
  "julia_num_threads", "openblas_num_threads", "omp_num_threads",
  "veclib_maximum_threads", "seed_formula", "pilot_offsets",
  "confirmation_offsets", "excluded_offsets", "ridge", "relationship_method",
  "allele_frequency_source", "relationship_scale", "boundary_epsilon",
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
  on_drac_compute <- nzchar(Sys.getenv("SLURM_JOB_ID"))
  if (!on_totoro && !on_drac_compute) {
    v07_abort("recovery-v2 may run only on Totoro or inside a DRAC SLURM job")
  }
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

v07_create_seal <- function(out_dir, driver_root, r_root, julia_root, driver_commit,
                            julia_execution_commit) {
  if (file.exists(out_dir) || dir.exists(out_dir)) v07_abort("OUT must be absent before seal")
  v07_assert_compute_host()
  roots <- v07_assert_separate_roots(driver_root, r_root, julia_root)
  if (!v07_hex40(driver_commit) || !v07_hex40(julia_execution_commit)) {
    v07_abort("driver and Julia execution commits must be full SHA-1 values")
  }
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
    roots, env,
    seed_formula = "2027120000+10000*cell_index+offset",
    pilot_offsets = "7001:7048", confirmation_offsets = "8001:10000",
    excluded_offsets = "1:48,1001:3000,5001:5048,6001:6048",
    ridge = "0.01", relationship_method = "vanraden1",
    allele_frequency_source = "sample", relationship_scale = "K_lambda",
    boundary_epsilon = "1e-07", resolved_statuses = paste(v07_resolved_statuses, collapse = ","),
    output_absent_before_seal = "true"
  )
  if (!identical(names(values), v07_seal_keys)) v07_abort("internal seal writer/key drift")
  dir.create(out_dir, recursive = FALSE)
  seal <- data.frame(key = names(values), value = unname(values), stringsAsFactors = FALSE)
  v07_write_once(v07_seal_path(out_dir), v07_tsv_text(seal))
  invisible(seal)
}

v07_assert_bound_state <- function(out_dir, driver_root, r_root, julia_root) {
  seal <- v07_read_seal(out_dir)
  roots <- v07_assert_separate_roots(driver_root, r_root, julia_root)
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
    scientific_ratio = NA_real_, profile_t_hat = NA_real_, numerical_sigma_g2 = NA_real_,
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
    # The selected Julia implementation constructs resolved endpoint numerical
    # components from exact profile t_hat; their sum retains that total. The
    # interior and rescued representations are independently profile-parity gated.
    pt <- as.numeric(ng + ne)
    boundary_evidence <- c(boundary$profile_loglik,
      boundary$lower_derivative_per_observation,
      boundary$upper_derivative_per_observation)
    if (!is.finite(pr) || !is.finite(pt) || pt < 0 || pr < 0 || pr > 1 ||
        any(!is.finite(boundary_evidence))) v07_abort("invalid_scientific_profile")
    prov <- fit$result$relationship_provenance
    hashes <- c(prov$marker_content_fingerprint, prov$id_order_fingerprint,
      prov$kernel_fingerprint, prov$precision_fingerprint)
    if (any(!vapply(hashes, v07_hex64, logical(1L)))) v07_abort("invalid_provenance_hash")
    result[names(result)] <- result[names(result)]
    result$status <- "success"; result$error_class <- "none"; result$converged <- TRUE
    result$boundary_status <- boundary$status; result$boundary_reason <- boundary$reason
    result$boundary_epsilon <- boundary$boundary_epsilon
    result$scientific_sigma_g2 <- pr * pt; result$scientific_sigma_e2 <- (1 - pr) * pt
    result$scientific_ratio <- pr; result$profile_t_hat <- pt
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

v07_run_one <- function(out_dir, driver_root, r_root, julia_root, tier, cell_id, seed) {
  v07_assert_compute_host()
  bound <- v07_assert_bound_state(out_dir, driver_root, r_root, julia_root)
  manifest <- v07_read_tsv(file.path(out_dir, paste0(tier, "_manifest.tsv")), v07_manifest_columns)
  seed <- as.numeric(seed)
  hit <- manifest$cell_id == cell_id & manifest$seed == seed
  if (sum(hit) != 1L) v07_abort("requested cell/seed is not exactly one manifest row")
  path <- v07_attempt_path(out_dir, tier, cell_id, seed)
  if (file.exists(path) || file.exists(paste0(path, ".sha256"))) v07_abort("attempt already exists")
  row <- v07_fit_one(manifest[hit, , drop = FALSE], bound$roots[["r_root"]], bound$roots[["julia_root"]])
  packet <- attr(row, "packet"); attr(row, "packet") <- NULL
  v07_write_packet(out_dir, tier, cell_id, seed, packet)
  row$driver_commit <- bound$seal[["driver_commit"]]
  row$seal_sha256 <- v07_sha256(v07_seal_path(out_dir))
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
    "scientific_sigma_g2", "scientific_sigma_e2", "scientific_ratio", "profile_t_hat",
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
    is.finite(attempts$profile_t_hat) & attempts$profile_t_hat >= 0
  if (any(good & !evidence)) v07_abort("successful fit lacks finite boundary evidence")
  lower <- good & attempts$boundary_status == "boundary_lower"
  upper <- good & attempts$boundary_status == "boundary_upper"
  if (any(attempts$scientific_ratio[lower] != 0) || any(attempts$scientific_sigma_g2[lower] != 0) ||
      any(attempts$scientific_ratio[upper] != 1) || any(attempts$scientific_sigma_e2[upper] != 0)) {
    v07_abort("resolved endpoint is not represented on the scientific boundary")
  }
  if (any(good & abs(attempts$scientific_sigma_g2 - attempts$scientific_ratio * attempts$profile_t_hat) > 1e-12) ||
      any(good & abs(attempts$scientific_sigma_e2 - (1 - attempts$scientific_ratio) * attempts$profile_t_hat) > 1e-12)) {
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
  do.call(rbind, rows)
}

v07_wilson <- function(k, n) {
  z <- stats::qnorm(0.975); phat <- k / n; den <- 1 + z^2 / n
  center <- (phat + z^2 / (2 * n)) / den
  half <- z * sqrt(phat * (1 - phat) / n + z^2 / (4 * n^2)) / den
  c(center - half, center + half)
}

v07_failure_classes <- function(x) {
  tab <- sort(table(x)); paste(sprintf("%s=%d", names(tab), as.integer(tab)), collapse = ";")
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
    same <- is.na(a) == is.na(b) & (is.na(a) | (is.finite(a) & is.finite(b) & abs(a - b) <= tolerance))
    if (!all(same)) v07_abort("summary mismatch in %s", field)
  }
  other <- setdiff(v07_summary_columns, numeric)
  for (field in other) if (!identical(as.character(x[[field]]), as.character(y[[field]]))) {
    v07_abort("summary mismatch in %s", field)
  }
  invisible(TRUE)
}

v07_write_summary <- function(out_dir, driver_root, r_root, julia_root, tier) {
  v07_assert_compute_host(); v07_assert_bound_state(out_dir, driver_root, r_root, julia_root)
  manifest <- v07_read_tsv(file.path(out_dir, paste0(tier, "_manifest.tsv")), v07_manifest_columns)
  attempts <- v07_read_attempts(out_dir, manifest, tier)
  summary <- v07_summarize(attempts, manifest, tier)
  v07_write_once(file.path(out_dir, paste0(tier, "_summary_driver_r.tsv")), v07_tsv_text(summary))
  invisible(summary)
}

v07_adjudicate_summaries <- function(out_dir, driver_root, r_root, julia_root, tier) {
  v07_assert_compute_host(); v07_assert_bound_state(out_dir, driver_root, r_root, julia_root)
  driver <- v07_read_tsv(file.path(out_dir, paste0(tier, "_summary_driver_r.tsv")), v07_summary_columns)
  base_r <- v07_read_tsv(file.path(out_dir, paste0(tier, "_summary_base_r.tsv")), v07_summary_columns)
  julia <- v07_read_tsv(file.path(out_dir, paste0(tier, "_summary_julia.tsv")), v07_summary_columns)
  v07_compare_summary(driver, base_r, tolerance = 1e-10)
  v07_compare_summary(driver, julia, tolerance = 1e-10)
  invisible(driver)
}

v07_write_confirmation_manifest <- function(out_dir, driver_root, r_root, julia_root) {
  v07_assert_compute_host(); v07_assert_bound_state(out_dir, driver_root, r_root, julia_root)
  pilot <- v07_read_tsv(file.path(out_dir, "pilot_manifest.tsv"), v07_manifest_columns)
  summary <- v07_adjudicate_summaries(out_dir, driver_root, r_root, julia_root, "pilot")
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

v07_verify_tree <- function(out_dir, driver_root, r_root, julia_root) {
  v07_assert_bound_state(out_dir, driver_root, r_root, julia_root)
  top <- sort(list.files(out_dir, recursive = FALSE, all.files = TRUE, no.. = TRUE))
  allowed_top <- c(
    "attempts", "packets", "campaign_seal.tsv", "campaign_seal.tsv.sha256",
    "pilot_manifest.tsv", "pilot_manifest.tsv.sha256",
    "confirm_manifest.tsv", "confirm_manifest.tsv.sha256",
    "pilot_summary_driver_r.tsv", "pilot_summary_driver_r.tsv.sha256",
    "pilot_summary_base_r.tsv", "pilot_summary_base_r.tsv.sha256",
    "pilot_summary_julia.tsv", "pilot_summary_julia.tsv.sha256",
    "confirm_summary_driver_r.tsv", "confirm_summary_driver_r.tsv.sha256",
    "confirm_summary_base_r.tsv", "confirm_summary_base_r.tsv.sha256",
    "confirm_summary_julia.tsv", "confirm_summary_julia.tsv.sha256"
  )
  if (any(!top %in% allowed_top)) v07_abort("unexpected top-level campaign output")
  files <- list.files(out_dir, recursive = TRUE, full.names = TRUE, all.files = TRUE, no.. = TRUE)
  primaries <- files[!file.info(files)$isdir & !endsWith(files, ".sha256")]
  sidecars <- files[!file.info(files)$isdir & endsWith(files, ".sha256")]
  if (!identical(sort(paste0(primaries, ".sha256")), sort(sidecars))) v07_abort("orphan/additional sidecar in output tree")
  invisible(lapply(primaries, v07_verify_pair))
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
  message("v0.7 genomic recovery-v2 selftest: PASS (no campaign seal created)")
  invisible(TRUE)
}

v07_main <- function(args = commandArgs(trailingOnly = TRUE)) {
  mode <- v07_option(args, "mode")
  if (identical(mode, "selftest")) return(v07_selftest())
  out <- v07_option(args, "out-dir")
  driver <- v07_option(args, "driver-root"); r_root <- v07_option(args, "r-root")
  julia <- v07_option(args, "julia-root")
  if (any(vapply(list(mode, out, driver, r_root, julia), is.null, logical(1L)))) {
    v07_abort("mode, out-dir, driver-root, r-root, and julia-root are required")
  }
  if (mode == "seal") {
    v07_create_seal(out, driver, r_root, julia, v07_option(args, "driver-commit"),
      v07_option(args, "julia-execution-commit"))
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
    v07_verify_tree(out, driver, r_root, julia)
  } else v07_abort("unknown mode: %s", mode)
}

if (sys.nframe() == 0L) v07_main()
