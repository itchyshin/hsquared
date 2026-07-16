#!/usr/bin/env Rscript

# Official recovery-v3 D0F/D1 packet generator and ordinary-form R driver.
# This file is source-safe. Its selftest is synthetic and consumes no official
# seed. Heavy execution is admitted only by an exact stage preseal on Totoro or
# an allowed DRAC cluster, never on GitHub Actions.

v3d_abort <- function(...) stop(sprintf(...), call. = FALSE)

v3d_contract_abort <- function(...) {
  condition <- simpleError(sprintf(...))
  class(condition) <- c("v3d_contract_error", class(condition))
  stop(condition)
}

v3d_or <- function(value, default) {
  if (is.null(value) || !length(value)) default else value
}

v3d_script_path <- function() {
  frames <- sys.frames()
  paths <- vapply(frames, function(frame) {
    if (is.null(frame$ofile)) "" else as.character(frame$ofile)
  }, character(1L))
  hit <- paths[basename(paths) == "v07_genomic_recovery_v3.R"]
  if (length(hit)) {
    return(normalizePath(tail(hit, 1L), winslash = "/", mustWork = TRUE))
  }
  arg <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  if (length(arg)) {
    arg <- gsub("~+~", " ", arg[[1L]], fixed = TRUE)
    return(normalizePath(arg, winslash = "/", mustWork = TRUE))
  }
  v3d_abort("cannot locate recovery-v3 driver")
}

v3d_loaded_path <- v3d_script_path()

v3d_load_preseal <- function() {
  target <- parent.frame()
  if (!exists("v3p_validate_stage_preseal", envir = target, inherits = TRUE)) {
    source(
      file.path(dirname(v3d_loaded_path), "v07_genomic_recovery_v3_preseal.R"),
      local = target
    )
  }
  invisible(TRUE)
}

v3d_load_preseal()

v3d_schema <- "v07-genomic-recovery-v3-stage-preseal-3"
v3d_packet_schema <- "v07-genomic-recovery-v3-packet-1"
v3d_truth_schema <- "v07-genomic-recovery-v3-truth-1"
v3d_route <- "ordinary_auto_genomic"
v3d_component_ratio_tolerance <- 1e-12
v3d_d0_corpus_root <-
  "/home/snakagaw/hsq_work/v07-genomic-recovery-v2-offset7101"
v3d_truth_provenance_columns <- c(
  "packet_schema_version", "truth_schema_version", "scale_denominator",
  "relationship_source", "relationship_method", "allele_frequency_source",
  "relationship_scale", "preseal_sha256", "r_implementation_commit",
  "julia_implementation_commit", "driver_commit"
)
v3d_packet_primaries <- c(
  "markers.tsv", "ids.tsv", "phenotype.tsv", "truth.tsv",
  "packet_files_lock.tsv"
)
v3d_corpus_columns <- c("relative_path", "sha256")

v3d_declared_numerical_ratio <- function(declared, sigma_g2, sigma_e2) {
  values <- suppressWarnings(as.numeric(c(declared, sigma_g2, sigma_e2)))
  if (length(values) != 3L || any(!is.finite(values))) {
    v3d_contract_abort("numerical ratio declaration or components are nonfinite")
  }
  total <- values[[2L]] + values[[3L]]
  if (!is.finite(total) || total <= 0) {
    v3d_contract_abort("numerical variance-component total is not positive finite")
  }
  component_ratio <- values[[2L]] / total
  if (
    values[[1L]] < 0 || values[[1L]] > 1 ||
      abs(values[[1L]] - component_ratio) > v3d_component_ratio_tolerance
  ) {
    v3d_contract_abort(
      "engine-declared numerical ratio differs from its components beyond %.17g",
      v3d_component_ratio_tolerance
    )
  }
  values[[1L]]
}

v3d_option_map <- function(args) {
  out <- list()
  i <- 1L
  while (i <= length(args)) {
    token <- args[[i]]
    if (!startsWith(token, "--")) v3d_abort("unexpected positional argument: %s", token)
    token <- substring(token, 3L)
    if (grepl("=", token, fixed = TRUE)) {
      pair <- strsplit(token, "=", fixed = TRUE)[[1L]]
      key <- pair[[1L]]
      value <- paste(pair[-1L], collapse = "=")
    } else {
      key <- token
      i <- i + 1L
      if (i > length(args) || startsWith(args[[i]], "--")) {
        v3d_abort("missing value for --%s", key)
      }
      value <- args[[i]]
    }
    if (!nzchar(key) || !nzchar(value) || !is.null(out[[key]])) {
      v3d_abort("empty or duplicate long option: --%s", key)
    }
    out[[key]] <- value
    i <- i + 1L
  }
  out
}

v3d_required <- function(options, key) {
  value <- options[[key]]
  if (is.null(value) || length(value) != 1L || !nzchar(value)) {
    v3d_abort("--%s is required", key)
  }
  value
}

v3d_stage <- function(value) {
  value <- tolower(value)
  if (!value %in% c("d0f", "d1")) v3d_abort("--stage must be d0f or d1")
  value
}

v3d_int <- function(value, label, lower = NULL, upper = NULL) {
  if (!grepl("^[0-9]+$", value)) v3d_abort("%s must be an integer", label)
  out <- as.integer(value)
  if (is.na(out) || (!is.null(lower) && out < lower) ||
      (!is.null(upper) && out > upper)) {
    v3d_abort("%s is outside its admitted range", label)
  }
  out
}

v3d_assert_execution_context <- function(
  host = NULL,
  cluster = Sys.getenv("SLURM_CLUSTER_NAME", unset = ""),
  environment = Sys.getenv(c(
    "GITHUB_ACTIONS", "CI", "SLURM_JOB_ID", "OPENBLAS_NUM_THREADS", "JULIA_NUM_THREADS",
    "OMP_NUM_THREADS", "MKL_NUM_THREADS", "VECLIB_MAXIMUM_THREADS",
    "NUMEXPR_NUM_THREADS"
  ), unset = "")
) {
  if (identical(tolower(environment[["GITHUB_ACTIONS"]]), "true") ||
      identical(tolower(environment[["CI"]]), "true")) {
    v3d_abort("official recovery-v3 compute is forbidden on GitHub Actions or CI")
  }
  if (is.null(host)) {
    host <- tolower(strsplit(Sys.info()[["nodename"]], ".", fixed = TRUE)[[1L]][[1L]])
  } else {
    host <- tolower(strsplit(host, ".", fixed = TRUE)[[1L]][[1L]])
  }
  cluster <- tolower(cluster)
  drac <- c("fir", "nibi", "rorqual", "trillium", "narval")
  is_totoro <- identical(host, "totoro")
  job_id <- unname(environment["SLURM_JOB_ID"])
  if (!length(job_id) || is.na(job_id)) job_id <- ""
  is_drac_allocation <- cluster %in% drac &&
    length(job_id) == 1L && grepl("^[0-9]+$", job_id)
  if (!is_totoro && !is_drac_allocation) {
    v3d_abort("official recovery-v3 compute requires Totoro or a live admitted DRAC SLURM allocation")
  }
  threads <- environment[c(
    "OPENBLAS_NUM_THREADS", "JULIA_NUM_THREADS", "OMP_NUM_THREADS",
    "MKL_NUM_THREADS", "VECLIB_MAXIMUM_THREADS", "NUMEXPR_NUM_THREADS"
  )]
  if (threads[["OPENBLAS_NUM_THREADS"]] != "1" ||
      threads[["JULIA_NUM_THREADS"]] != "1" ||
      any(nzchar(threads) & threads != "1")) {
    v3d_abort("official recovery-v3 threads are not pinned to one")
  }
  invisible(TRUE)
}

v3d_new_root <- function(path, other_roots = character()) {
  if (!startsWith(path, "/") || path != sub("/+$", "", path) ||
      file.exists(path) || dir.exists(path)) {
    v3d_abort("output root must be an absent normalized absolute path")
  }
  parent <- dirname(path)
  if (!dir.exists(parent) || v07d_has_symlink_component(parent)) {
    v3d_abort("output-root parent must be an existing symlink-free directory")
  }
  expected <- file.path(normalizePath(parent, winslash = "/", mustWork = TRUE), basename(path))
  if (path != expected) v3d_abort("output root is not canonical")
  nested <- function(a, b) a == b || startsWith(paste0(a, "/"), paste0(b, "/")) ||
    startsWith(paste0(b, "/"), paste0(a, "/"))
  for (other in other_roots) {
    other <- normalizePath(other, winslash = "/", mustWork = TRUE)
    if (nested(path, other)) v3d_abort("output root is nested with a repository or corpus root")
  }
  path
}

v3d_text_once <- function(root, name, text) {
  root <- v3p_canonical_path(root, "output root", TRUE)
  if (length(name) != 1L || basename(name) != name || name %in% c(".", "..")) {
    v3d_abort("create-once name is unsafe")
  }
  if (!is.character(text) || length(text) != 1L || !nzchar(text) ||
      !endsWith(text, "\n") || grepl("\r", text, fixed = TRUE)) {
    v3d_abort("create-once text must be nonempty canonical LF text")
  }
  v07d_write_once(file.path(root, name), text)
}

v3d_copy_pair <- function(source, destination) {
  v07d_verify_pair(source)
  if (!v07d_is_regular_file(source) || v07d_has_symlink_component(source)) {
    v3d_abort("copy source is not a regular symlink-free primary")
  }
  v07d_write_once(destination, readChar(source, file.info(source)$size, useBytes = TRUE))
}

v3d_write_review <- function(
  path, reviewer, verdict, doc49_sha256, r_driver_commit,
  r_recomputer_commit, julia_replay_commit, r_auto_route_commit,
  julia_candidate_commit, r_driver_sha256, r_recomputer_sha256,
  julia_replay_sha256
) {
  reviewer <- tolower(reviewer)
  verdict <- toupper(verdict)
  if (!reviewer %in% v3p_reviewers) v3d_abort("reviewer is not admitted")
  if (!verdict %in% c("CLEAN", "BLOCKED")) v3d_abort("verdict must be CLEAN or BLOCKED")
  if (file.exists(path) || file.exists(paste0(path, ".sha256"))) {
    v3d_abort("review primary or sidecar already exists")
  }
  hashes <- c(
    doc49_sha256, r_driver_sha256, r_recomputer_sha256,
    julia_replay_sha256
  )
  commits <- c(
    r_driver_commit, r_recomputer_commit, julia_replay_commit,
    r_auto_route_commit, julia_candidate_commit
  )
  if (any(!vapply(hashes, v3p_hex64, logical(1L))) ||
      any(!vapply(commits, v3p_hex40, logical(1L)))) {
    v3d_abort("review contains an invalid digest or commit")
  }
  row <- data.frame(
    reviewer = reviewer, verdict = verdict, doc49_sha256 = doc49_sha256,
    r_driver_commit = r_driver_commit,
    r_recomputer_commit = r_recomputer_commit,
    julia_replay_commit = julia_replay_commit,
    r_auto_route_commit = r_auto_route_commit,
    julia_candidate_commit = julia_candidate_commit,
    r_driver_sha256 = r_driver_sha256,
    r_recomputer_sha256 = r_recomputer_sha256,
    julia_replay_sha256 = julia_replay_sha256,
    stringsAsFactors = FALSE
  )[v3p_review_columns]
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  v07d_write_once(path, v07d_tsv_text(row))
  invisible(row)
}

v3d_prepare_stage <- function(
  output_root, stage, driver_root, r_root, julia_root, receipt_root,
  max_workers, d0f_adjudication_root = NULL
) {
  v3d_assert_execution_context()
  stage <- v3d_stage(stage)
  max_workers <- v3d_int(as.character(max_workers), "max workers", 1L, 96L)
  roots <- vapply(
    c(driver_root, r_root, julia_root, v3d_d0_corpus_root),
    normalizePath, character(1L), winslash = "/", mustWork = TRUE
  )
  doc <- file.path(r_root, "docs", "design", "49-v07-genomic-recovery-v3-sample-size-ladder.md")
  cell <- file.path(r_root, "docs", "design", "v07_genomic_recovery_v3_cell_table.tsv")
  seed_lock <- file.path(r_root, "docs", "design", "historical_seed_lock.tsv")
  if (!all(file.exists(c(doc, cell, seed_lock)))) v3d_abort("deployed design inputs are absent")
  proposed_seeds <- v07s_expand_v3()
  v07s_validate_spaces(v07s_read_lock(seed_lock), proposed_seeds)
  if (stage == "d0f") {
    v3p_validate_bootstrap_seed_space(seed_lock, proposed_seeds)
  }
  if (stage == "d1") {
    if (is.null(d0f_adjudication_root)) {
      v3d_abort("D1 prepare requires --d0f-adjudication-root")
    }
    d0f <- v3p_validate_successful_d0f_adjudication(d0f_adjudication_root)
    roots <- c(roots, d0f$root)
  } else if (!is.null(d0f_adjudication_root)) {
    v3d_abort("D0F prepare does not accept --d0f-adjudication-root")
  }
  v3d_new_root(output_root, roots)
  receipt_root <- normalizePath(receipt_root, winslash = "/", mustWork = TRUE)
  dir.create(output_root)
  on_error <- TRUE
  on.exit(if (on_error) unlink(output_root, recursive = TRUE, force = TRUE), add = TRUE)
  dir.create(file.path(output_root, "receipts"))
  v07d_write_once(file.path(output_root, "doc49.md"), paste0(paste(readLines(doc, warn = FALSE), collapse = "\n"), "\n"))
  v07d_write_once(file.path(output_root, "cell_table.tsv"), readChar(cell, file.info(cell)$size, useBytes = TRUE))
  v07d_write_once(file.path(output_root, "historical_seed_lock.tsv"), readChar(seed_lock, file.info(seed_lock)$size, useBytes = TRUE))
  for (reviewer in v3p_reviewers) {
    source <- file.path(receipt_root, paste0(reviewer, ".tsv"))
    v3d_copy_pair(source, file.path(output_root, "receipts", basename(source)))
  }
  if (stage == "d1") {
    manifest <- v3p_d1_manifest()
  } else {
    d0 <- v3p_validate_frozen_d0_artifacts(
      "/home/snakagaw/hsq_work/v07-genomic-recovery-v3-d0-official-cdb33dc-4c5e54de",
      "190b6546fab8caeec24683c4f7bee8063ada671c220852c9372e5db194b2886a",
      "7c1cbc165df90e844bd4fdc7fc6ffb6dcbb8343c0d5ca9e7a588e4ca6d48c370"
    )
    corpus <- v07d_verify_corpus(v3d_d0_corpus_root)
    diagnostics <- v07d_read_tsv(
      d0$diagnostics_path, v07d_diagnostic_columns, verify = FALSE
    )
    fixed <- v3p_d0f_fixed_panels(corpus$manifest, diagnostics)
    manifest <- v3p_d0f_phenotype_manifest(fixed)
    v3p_write_once(output_root, "d0f_fixed_panel_manifest.tsv", fixed)
  }
  v3p_write_once(output_root, paste0(stage, "_manifest.tsv"), manifest)
  RNGkind("Mersenne-Twister", "Inversion", "Rejection")
  environment <- v3p_capture_live_environment(stage, max_workers)
  v3p_write_once(output_root, "environment_manifest.tsv", environment)
  v3p_verify_preseal_tree(output_root, stage, FALSE)
  on_error <- FALSE
  invisible(manifest)
}

v3d_context <- function(driver_root, r_root, julia_root) {
  driver_root <- normalizePath(driver_root, winslash = "/", mustWork = TRUE)
  r_root <- normalizePath(r_root, winslash = "/", mustWork = TRUE)
  julia_root <- normalizePath(julia_root, winslash = "/", mustWork = TRUE)
  list(
    r_driver_path = file.path(driver_root, "tools", "v07_genomic_recovery_v3.R"),
    r_recomputer_path = file.path(r_root, "tools", "v07_genomic_recovery_v3_recompute.R"),
    julia_replay_path = file.path(
      julia_root, "sim", "phase2_v07_genomic_recovery_v3_stage_replay.jl"
    ),
    d0_recomputer_path = file.path(r_root, "tools", "v07_genomic_recovery_v3_d0_recompute.R"),
    r_driver_root = driver_root, r_recomputer_root = r_root,
    julia_replay_root = julia_root, r_auto_route_root = r_root,
    julia_candidate_root = julia_root
  )
}

v3d_preseal_values <- function(
  output_root, stage, context, r_auto_route_commit, julia_candidate_commit,
  d0f_adjudication_root = NULL
) {
  stage <- v3d_stage(stage)
  r_driver_commit <- v3p_git_head(context$r_driver_root)
  r_recomputer_commit <- v3p_git_head(context$r_recomputer_root)
  julia_replay_commit <- v3p_git_head(context$julia_replay_root)
  values <- setNames(rep("NA", length(v3p_stage_preseal_keys)), v3p_stage_preseal_keys)
  values[c(
    "schema_version", "stage", "d0_output_root", "output_root",
    "official_route", "replay_route", "packet_schema_version",
    "truth_schema_version", "relationship_source", "relationship_method",
    "allele_frequency_source", "relationship_scale", "ridge",
    "boundary_epsilon", "boundary_kkt_tolerance",
    "output_subtrees_absent_before_preseal"
  )] <- c(
    v3d_schema, stage,
    "/home/snakagaw/hsq_work/v07-genomic-recovery-v3-d0-official-cdb33dc-4c5e54de",
    output_root, v3d_route, "julia_profile_replay", v3d_packet_schema,
    v3d_truth_schema, "markers", "vanraden1", "sample", "K_lambda",
    "0.01", "1e-07", "1e-08", "true"
  )
  if (stage == "d1") {
    if (is.null(d0f_adjudication_root)) {
      v3d_abort("D1 preseal requires --d0f-adjudication-root")
    }
    d0f <- v3p_validate_successful_d0f_adjudication(
      d0f_adjudication_root, d1_root = output_root
    )
    values[c(
      "d0f_adjudication_root", "d0f_adjudication_receipt_sha256"
    )] <- c(d0f$root, d0f$receipt_sha256)
  } else if (!is.null(d0f_adjudication_root)) {
    v3d_abort("D0F preseal does not accept --d0f-adjudication-root")
  }
  path_keys <- c(
    doc49_sha256 = "doc49.md", cell_table_sha256 = "cell_table.tsv",
    manifest_sha256 = paste0(stage, "_manifest.tsv"),
    environment_manifest_sha256 = "environment_manifest.tsv",
    historical_seed_lock_sha256 = "historical_seed_lock.tsv"
  )
  values[names(path_keys)] <- vapply(
    file.path(output_root, path_keys), v07d_sha256, character(1L)
  )
  values[c(
    "d0_adjudication_receipt_sha256", "d0_diagnostics_sha256"
  )] <- c(
    "190b6546fab8caeec24683c4f7bee8063ada671c220852c9372e5db194b2886a",
    "7c1cbc165df90e844bd4fdc7fc6ffb6dcbb8343c0d5ca9e7a588e4ca6d48c370"
  )
  if (stage == "d0f") {
    values[["d0f_fixed_panel_manifest_sha256"]] <- v07d_sha256(
      file.path(output_root, "d0f_fixed_panel_manifest.tsv")
    )
    values[["d0f_bootstrap_seed_base"]] <- format(
      v07s_d0f_retry_bootstrap_base, scientific = FALSE
    )
    values[["d0f_bootstrap_indices_absent_before_preseal"]] <- "true"
  }
  values[paste0(v3p_reviewers, "_receipt_sha256")] <- vapply(
    file.path(output_root, "receipts", paste0(v3p_reviewers, ".tsv")),
    v07d_sha256, character(1L)
  )
  values[c(
    "r_driver_commit", "r_recomputer_commit", "julia_replay_commit",
    "r_auto_route_commit", "julia_candidate_commit"
  )] <- c(
    r_driver_commit, r_recomputer_commit, julia_replay_commit,
    r_auto_route_commit, julia_candidate_commit
  )
  values[c(
    "r_driver_sha256", "r_recomputer_sha256", "julia_replay_sha256",
    "d0_recomputer_sha256"
  )] <- vapply(c(
    context$r_driver_path, context$r_recomputer_path,
    context$julia_replay_path, context$d0_recomputer_path
  ), v07d_sha256, character(1L))
  data.frame(
    key = v3p_stage_preseal_keys,
    value = unname(values[v3p_stage_preseal_keys]),
    stringsAsFactors = FALSE
  )
}

v3d_write_preseal <- function(
  output_root, stage, driver_root, r_root, julia_root,
  r_auto_route_commit, julia_candidate_commit,
  d0f_adjudication_root = NULL
) {
  v3d_assert_execution_context()
  stage <- v3d_stage(stage)
  output_root <- v3p_canonical_path(output_root, "stage output root", TRUE)
  context <- v3d_context(driver_root, r_root, julia_root)
  preseal <- v3d_preseal_values(
    output_root, stage, context, r_auto_route_commit, julia_candidate_commit,
    d0f_adjudication_root
  )
  v3p_validate_stage_preseal(preseal, context, include_preseal = FALSE)
  v3p_write_once(output_root, "stage_preseal.tsv", preseal)
  v3p_validate_stage_preseal(preseal, context, include_preseal = TRUE)
  invisible(preseal)
}

v3d_read_preseal <- function(output_root, stage) {
  stage <- v3d_stage(stage)
  path <- file.path(output_root, "stage_preseal.tsv")
  v07d_verify_pair(path)
  x <- v07d_read_tsv(path, c("key", "value"), verify = FALSE)
  if (!identical(as.character(x$key), v3p_stage_preseal_keys)) {
    v3d_abort("stage preseal key/order drift")
  }
  value <- as.character(x$value)
  value[is.na(value)] <- "NA"
  names(value) <- x$key
  if (value[["schema_version"]] != v3d_schema || value[["stage"]] != stage ||
      value[["output_root"]] != output_root || value[["official_route"]] != v3d_route ||
      value[["packet_schema_version"]] != v3d_packet_schema ||
      value[["truth_schema_version"]] != v3d_truth_schema) {
    v3d_abort("stage preseal identity drift")
  }
  list(table = x, value = value, path = path, sha256 = v07d_sha256(path))
}

v3d_validate_bound_stage <- function(
  output_root, stage, driver_root, r_root, julia_root,
  bootstrap_materialized = TRUE, tree_scope = c("runtime", "pristine"),
  runtime_phase = "official"
) {
  v3d_assert_execution_context()
  tree_scope <- match.arg(tree_scope)
  output_root <- v3p_canonical_path(output_root, "stage output root", TRUE)
  stage <- v3d_stage(stage)
  preseal <- v3d_read_preseal(output_root, stage)
  value <- preseal$value
  context <- v3d_context(driver_root, r_root, julia_root)
  v3p_validate_stage_preseal(
    preseal$table, context, include_preseal = TRUE,
    bootstrap_materialized = stage == "d0f" && bootstrap_materialized,
    tree_scope = tree_scope, runtime_phase = runtime_phase
  )
  roots <- c(r = normalizePath(r_root, winslash = "/", mustWork = TRUE),
             julia = normalizePath(julia_root, winslash = "/", mustWork = TRUE))
  for (root in roots) v3p_git_clean(root)
  if (v3p_git_head(driver_root) != value[["r_driver_commit"]] ||
      v3p_git_head(r_root) != value[["r_recomputer_commit"]] ||
      v3p_git_head(julia_root) != value[["julia_replay_commit"]]) {
    v3d_abort("deployed commit differs from stage preseal")
  }
  v3p_git_ancestor(r_root, value[["r_auto_route_commit"]],
                   value[["r_driver_commit"]], "R driver")
  v3p_git_ancestor(julia_root, value[["julia_candidate_commit"]],
                   value[["julia_replay_commit"]], "Julia replay")
  v3p_git_unchanged(
    r_root, value[["r_auto_route_commit"]], value[["r_driver_commit"]],
    file.path(r_root, c("R", "DESCRIPTION", "NAMESPACE")),
    "R candidate implementation"
  )
  v3p_git_unchanged(
    julia_root, value[["julia_candidate_commit"]],
    value[["julia_replay_commit"]],
    file.path(julia_root, c("src", "ext", "Project.toml", "Manifest.toml")),
    "Julia candidate implementation"
  )
  tool_keys <- c(
    r_driver_path = "r_driver_sha256", r_recomputer_path = "r_recomputer_sha256",
    julia_replay_path = "julia_replay_sha256",
    d0_recomputer_path = "d0_recomputer_sha256"
  )
  for (name in names(tool_keys)) {
    v07d_verify_pair(context[[name]], value[[tool_keys[[name]]]])
  }
  inputs <- c(
    doc49_sha256 = "doc49.md", cell_table_sha256 = "cell_table.tsv",
    historical_seed_lock_sha256 = "historical_seed_lock.tsv",
    manifest_sha256 = paste0(stage, "_manifest.tsv"),
    environment_manifest_sha256 = "environment_manifest.tsv"
  )
  for (key in names(inputs)) {
    v07d_verify_pair(file.path(output_root, inputs[[key]]), value[[key]])
  }
  environment <- v07d_read_tsv(
    file.path(output_root, "environment_manifest.tsv"), c("key", "value"),
    verify = FALSE
  )
  v3p_validate_environment_live(environment)
  for (reviewer in v3p_reviewers) {
    v3p_validate_review(
      file.path(output_root, "receipts", paste0(reviewer, ".tsv")),
      value[[paste0(reviewer, "_receipt_sha256")]], reviewer, value
    )
  }
  v3p_validate_frozen_d0_artifacts(
    value[["d0_output_root"]], value[["d0_adjudication_receipt_sha256"]],
    value[["d0_diagnostics_sha256"]]
  )
  if (stage == "d1") {
    v3p_validate_successful_d0f_adjudication(
      value[["d0f_adjudication_root"]],
      value[["d0f_adjudication_receipt_sha256"]], output_root
    )
  }
  list(preseal = preseal, context = context)
}

v3d_materialize_bootstrap <- function(
  output_root, stage, driver_root, r_root, julia_root
) {
  v3d_assert_execution_context()
  stage <- v3d_stage(stage)
  if (stage != "d0f") v3d_abort("bootstrap materialization is D0F-only")
  v3d_validate_bound_stage(
    output_root, stage, driver_root, r_root, julia_root,
    bootstrap_materialized = FALSE, tree_scope = "pristine"
  )
  path <- file.path(output_root, "d0f_bootstrap_indices.tsv")
  if (file.exists(path) || file.exists(paste0(path, ".sha256"))) {
    v3d_abort("D0F bootstrap manifest already exists")
  }
  v3p_write_once(output_root, basename(path), v3p_d0f_bootstrap_manifest(10000L))
  v3d_validate_bound_stage(
    output_root, stage, driver_root, r_root, julia_root,
    bootstrap_materialized = TRUE, tree_scope = "pristine"
  )
  invisible(path)
}

v3d_manifest <- function(output_root, stage) {
  stage <- v3d_stage(stage)
  path <- file.path(output_root, paste0(stage, "_manifest.tsv"))
  if (stage == "d0f") {
    x <- v07d_read_tsv(path, v3p_d0f_phenotype_columns)
    fixed <- unique(x[c(
      "stage", "design_id", "design_index", "source_cell_id", "panel_rank",
      "panel_source_seed", "n", "m", "marker_ratio", "truth_sigma_g2",
      "truth_sigma_e2", "truth_ratio", "ridge", "retained_m",
      "marker_hash", "id_hash", "kernel_hash", "precision_hash"
    )])[v3p_d0f_fixed_columns]
    v3p_validate_d0f_phenotype_manifest(x, fixed)
  } else {
    x <- v07d_read_tsv(path, v3p_d1_columns)
    v3p_validate_d1_manifest(x)
  }
}

v3d_group <- function(row, stage) {
  as.character(row[[if (stage == "d0f") "design_id" else "cell_id"]])
}

v3d_attempt_path <- function(output_root, stage, row) {
  file.path(
    output_root, "attempts", stage, v3d_group(row, stage),
    paste0(sprintf("%.0f", as.numeric(row$seed)), ".tsv")
  )
}

v3d_packet_dir <- function(output_root, stage, row) {
  file.path(
    output_root, "packets", stage, v3d_group(row, stage),
    sprintf("%.0f", as.numeric(row$seed))
  )
}

v3d_target_state <- function(attempt_path, packet_path) {
  sidecar <- paste0(attempt_path, ".sha256")
  path_present <- function(path) {
    link <- Sys.readlink(path)
    file.exists(path) || dir.exists(path) || (!is.na(link) && nzchar(link))
  }
  raw_present <- c(
    attempt = path_present(attempt_path),
    attempt_sidecar = path_present(sidecar),
    packet = path_present(packet_path)
  )
  valid <- c(
    attempt = v07d_is_regular_file(attempt_path) &&
      !v07d_has_symlink_component(attempt_path),
    attempt_sidecar = v07d_is_regular_file(sidecar) &&
      !v07d_has_symlink_component(sidecar),
    packet = dir.exists(packet_path) &&
      !v07d_has_symlink_component(packet_path)
  )
  if (all(valid)) "complete" else if (!any(raw_present)) "absent" else "partial"
}

v3d_claim_root <- function(output_root) {
  file.path(dirname(output_root), paste0(".", basename(output_root), "-claims"))
}

v3d_acquire_claim <- function(output_root, stage, row) {
  claim <- file.path(
    v3d_claim_root(output_root), stage, v3d_group(row, stage),
    paste0(sprintf("%.0f", as.numeric(row$seed)), ".claim")
  )
  dir.create(dirname(claim), recursive = TRUE, showWarnings = FALSE)
  parent <- normalizePath(dirname(claim), winslash = "/", mustWork = TRUE)
  if (v07d_has_symlink_component(parent)) v3d_abort("worker claim parent is symlinked")
  claim <- file.path(parent, basename(claim))
  v07d_hardlink_once(claim, charToRaw("claimed\n"))
  claim
}

v3d_assert_no_stale_claims <- function(output_root) {
  root <- v3d_claim_root(output_root)
  if (!dir.exists(root) && !file.exists(root)) return(invisible(TRUE))
  if (!dir.exists(root) || v07d_has_symlink_component(root)) {
    v3d_abort("invalid external worker-claim root: %s", root)
  }
  members <- list.files(
    root, recursive = TRUE, all.files = TRUE, no.. = TRUE,
    include.dirs = TRUE, full.names = TRUE
  )
  files <- members[!dir.exists(members)]
  if (length(files)) {
    v3d_abort("stale or active external worker claim blocks quiescent phase: %s", files[[1L]])
  }
  invisible(TRUE)
}

v3d_truth_columns <- function(stage) {
  c(
    if (stage == "d0f") v3p_d0f_phenotype_columns else c(
      v3p_d1_columns, "retained_m", "marker_hash", "id_hash",
      "kernel_hash", "precision_hash"
    ),
    v3d_truth_provenance_columns
  )
}

v3d_verify_packet <- function(path, stage) {
  path <- v3p_canonical_path(path, "packet directory", TRUE)
  actual <- sort(list.files(path, all.files = TRUE, no.. = TRUE))
  expected <- sort(c(v3d_packet_primaries, paste0(v3d_packet_primaries, ".sha256")))
  if (!identical(actual, expected)) v3d_abort("packet file-set drift")
  for (name in v3d_packet_primaries) v07d_verify_pair(file.path(path, name))
  lock <- v07d_read_tsv(
    file.path(path, "packet_files_lock.tsv"), c("file", "sha256"),
    verify = FALSE
  )
  primary <- v3d_packet_primaries[1:4]
  if (!identical(as.character(lock$file), primary) ||
      !identical(as.character(lock$sha256), unname(vapply(
        file.path(path, primary), v07d_sha256, character(1L)
      )))) {
    v3d_abort("packet inner lock drift")
  }
  truth <- v07d_read_tsv(
    file.path(path, "truth.tsv"), v3d_truth_columns(stage), verify = FALSE
  )
  if (nrow(truth) != 1L) v3d_abort("packet truth must contain one row")
  invisible(TRUE)
}

v3d_write_packet <- function(output_root, stage, row, packet) {
  destination <- v3d_packet_dir(output_root, stage, row)
  if (file.exists(destination) || dir.exists(destination)) {
    v3d_abort("packet destination already exists")
  }
  parent <- dirname(destination)
  dir.create(parent, recursive = TRUE, showWarnings = FALSE)
  parent <- normalizePath(parent, winslash = "/", mustWork = TRUE)
  # Keep construction outside packets/: the whole tree is inspected only when
  # fan-out is quiescent, and no valid worker temp may resemble corpus drift.
  tmp <- tempfile(".v3d-packet-", tmpdir = dirname(output_root))
  dir.create(tmp)
  published <- FALSE
  on.exit(if (!published) unlink(tmp, recursive = TRUE, force = TRUE), add = TRUE)
  objects <- packet[c("markers", "ids", "phenotype", "truth")]
  for (name in names(objects)) {
    v07d_write_once(
      file.path(tmp, paste0(name, ".tsv")), v07d_tsv_text(objects[[name]])
    )
  }
  primary <- paste0(names(objects), ".tsv")
  lock <- data.frame(
    file = primary,
    sha256 = vapply(file.path(tmp, primary), v07d_sha256, character(1L)),
    stringsAsFactors = FALSE
  )
  v07d_write_once(
    file.path(tmp, "packet_files_lock.tsv"), v07d_tsv_text(lock)
  )
  if (!file.rename(tmp, destination)) v3d_abort("atomic packet publication failed")
  published <- TRUE
  v3d_verify_packet(destination, stage)
  invisible(destination)
}

v3d_peak_rss_mb <- function() {
  if (!file.exists("/proc/self/status")) return(NA_real_)
  hit <- grep("^VmHWM:", readLines("/proc/self/status", warn = FALSE), value = TRUE)
  if (!length(hit)) return(NA_real_)
  as.numeric(gsub("[^0-9]", "", hit[[1L]])) / 1024
}

v3d_read_fixed_markers <- function(row) {
  cell <- as.character(row$source_cell_id)
  seed <- sprintf("%.0f", as.numeric(row$panel_source_seed))
  root <- file.path(v3d_d0_corpus_root, "packets", "pilot", cell, seed)
  for (name in v3d_packet_primaries) v07d_verify_pair(file.path(root, name))
  marker <- v07d_read_tsv(file.path(root, "markers.tsv"), verify = FALSE)
  ids <- v07d_read_tsv(
    file.path(root, "ids.tsv"), c("index", "id"), verify = FALSE
  )
  if (names(marker)[[1L]] != "id" || nrow(marker) != row$n ||
      !identical(as.character(marker[[1L]]), as.character(ids$id)) ||
      !identical(as.integer(ids$index), seq_len(row$n))) {
    v3d_abort("D0F fixed marker/ID alignment drift")
  }
  M <- as.matrix(marker[-1L]); storage.mode(M) <- "numeric"
  marker_names <- names(marker)[-1L]
  id <- as.character(ids$id)
  if (ncol(M) != row$retained_m || any(!M %in% c(0, 1, 2)) ||
      any(apply(M, 2L, function(x) length(unique(x)) <= 1L)) ||
      v07d_marker_fingerprint(M, id, marker_names) != row$marker_hash ||
      v07d_id_fingerprint(id) != row$id_hash) {
    v3d_abort("D0F fixed marker panel differs from presealed fingerprints")
  }
  list(M = M, ids = id, marker_names = marker_names)
}

v3d_draw_markers <- function(row) {
  n <- as.integer(row$n); m <- as.integer(row$m)
  frequencies <- stats::runif(m, 0.05, 0.5)
  M <- matrix(
    stats::rbinom(n * m, 2L, rep(frequencies, each = n)),
    nrow = n, ncol = m
  )
  keep <- apply(M, 2L, function(x) length(unique(x)) > 1L)
  M <- M[, keep, drop = FALSE]
  if (!ncol(M)) v3d_abort("all realised markers are monomorphic")
  list(
    M = M, ids = sprintf("g%06d", seq_len(n)),
    marker_names = sprintf("m%06d", which(keep))
  )
}

v3d_engine_construction <- function(M, ids, marker_names, julia_root) {
  if (!requireNamespace("JuliaCall", quietly = TRUE)) {
    v3d_abort("JuliaCall is required for exact engine construction")
  }
  setup <- get("hs_julia_setup", envir = asNamespace("hsquared"), inherits = FALSE)
  setup(julia_root)
  JuliaCall::julia_assign("hsq_v3_M", unname(M))
  JuliaCall::julia_assign("hsq_v3_ids", ids)
  JuliaCall::julia_assign("hsq_v3_marker_names", marker_names)
  JuliaCall::julia_command(paste(
    "hsq_v3_construction = HSquared._genomic_activation_construction(",
    "hsq_v3_M, hsq_v3_ids; marker_names=hsq_v3_marker_names, ridge=0.01);"
  ))
  provenance <- JuliaCall::julia_eval(paste(
    "Dict(String(k) => getfield(hsq_v3_construction.provenance, k)",
    " for k in keys(hsq_v3_construction.provenance))"
  ))
  list(
    K = as.matrix(JuliaCall::julia_eval("hsq_v3_construction.K")),
    Q = as.matrix(JuliaCall::julia_eval("hsq_v3_construction.Q")),
    provenance = provenance
  )
}

v3d_spectral <- function(Q) {
  K <- solve(Q); K <- 0.5 * (K + t(K))
  C <- v07d_helmert(nrow(K))
  projected <- crossprod(C, K %*% C)
  projected <- 0.5 * (projected + t(projected))
  values <- sort(eigen(projected, symmetric = TRUE, only.values = TRUE)$values)
  if (length(values) != nrow(K) - 1L || any(!is.finite(values)) || any(values <= 0)) {
    v3d_abort("projected kernel spectrum is not finite positive")
  }
  mean_value <- mean(values)
  info <- unlist(lapply(c(0.2, 0.5, 0.8), function(r) v07d_information(values, r)))
  list(
    eigen_cv_population = sqrt(mean((values - mean_value)^2)) / mean_value,
    effective_rank = sum(values)^2 / sum(values^2),
    information_r020 = info[[1L]], se_info_r020 = info[[2L]],
    information_r050 = info[[3L]], se_info_r050 = info[[4L]],
    information_r080 = info[[5L]], se_info_r080 = info[[6L]]
  )
}

v3d_fit_call <- function(M, dat) {
  hsquared::hsquared(
    y ~ genomic(1 | id, markers = M),
    data = dat,
    family = stats::gaussian(),
    REML = TRUE
  )
}

v3d_error_class <- function(error) {
  text <- tolower(conditionMessage(error))
  text <- gsub("[^a-z0-9]+", "_", text)
  text <- gsub("^_|_$", "", text)
  if (!nzchar(text)) text <- "unclassified_error"
  substr(text, 1L, 120L)
}

v3d_provenance_fields <- c(
  "relationship_source", "relationship_method", "allele_frequency_source",
  "relationship_scale"
)

v3d_validate_construction_provenance <- function(provenance, preseal, row_ridge) {
  for (field in v3d_provenance_fields) {
    observed <- provenance[[field]]
    expected <- preseal[[field]]
    if (is.null(observed) || is.null(expected) || length(observed) != 1L ||
        length(expected) != 1L || !identical(as.character(observed), as.character(expected))) {
      v3d_abort("construction provenance differs from preseal in %s", field)
    }
  }
  ridge <- suppressWarnings(as.numeric(provenance[["ridge"]]))
  preseal_ridge <- suppressWarnings(as.numeric(preseal[["ridge"]]))
  row_ridge <- suppressWarnings(as.numeric(row_ridge))
  k <- suppressWarnings(as.numeric(provenance[["scale_denominator"]]))
  if (length(ridge) != 1L || length(preseal_ridge) != 1L || length(row_ridge) != 1L ||
      any(!is.finite(c(ridge, preseal_ridge, row_ridge, k))) || k <= 0 ||
      !identical(ridge, preseal_ridge) || !identical(ridge, row_ridge)) {
    v3d_abort("construction ridge or scale denominator differs from preseal/manifest")
  }
  hash_fields <- c(
    marker_hash = "marker_content_fingerprint",
    id_hash = "id_order_fingerprint",
    kernel_hash = "kernel_fingerprint",
    precision_hash = "precision_fingerprint"
  )
  hashes <- setNames(vapply(hash_fields, function(field) {
    value <- provenance[[field]]
    if (is.null(value) || length(value) != 1L) "" else as.character(value)
  }, character(1L)), names(hash_fields))
  if (any(!vapply(hashes, v3p_hex64, logical(1L)))) {
    v3d_abort("engine construction returned an invalid fingerprint")
  }
  list(hashes = hashes, scale_denominator = k, ridge = ridge)
}

v3d_validate_fit_provenance <- function(fit_provenance, construction, preseal) {
  for (field in v3d_provenance_fields) {
    values <- c(
      fit = as.character(fit_provenance[[field]]),
      construction = as.character(construction[[field]]),
      preseal = as.character(preseal[[field]])
    )
    if (length(values) != 3L || anyNA(values) || !all(values == values[[1L]])) {
      v3d_abort("fit provenance differs from construction/preseal in %s", field)
    }
  }
  fit_numeric <- c(
    ridge = suppressWarnings(as.numeric(fit_provenance[["ridge"]])),
    scale_denominator = suppressWarnings(as.numeric(fit_provenance[["scale_denominator"]]))
  )
  construction_numeric <- c(
    ridge = suppressWarnings(as.numeric(construction[["ridge"]])),
    scale_denominator = suppressWarnings(as.numeric(construction[["scale_denominator"]]))
  )
  expected_numeric <- c(
    ridge = suppressWarnings(as.numeric(preseal[["ridge"]])),
    scale_denominator = construction_numeric[["scale_denominator"]]
  )
  if (length(fit_numeric) != 2L || length(construction_numeric) != 2L ||
      any(!is.finite(c(fit_numeric, construction_numeric, expected_numeric))) ||
      !identical(unname(fit_numeric), unname(construction_numeric)) ||
      !identical(unname(fit_numeric), unname(expected_numeric))) {
    v3d_abort("fit ridge or scale denominator differs from construction/preseal")
  }
  hash_fields <- c(
    marker_content_fingerprint = "marker_content_fingerprint",
    id_order_fingerprint = "id_order_fingerprint",
    kernel_fingerprint = "kernel_fingerprint",
    precision_fingerprint = "precision_fingerprint"
  )
  fit_hashes <- vapply(hash_fields, function(field) as.character(fit_provenance[[field]]), character(1L))
  construction_hashes <- vapply(hash_fields, function(field) as.character(construction[[field]]), character(1L))
  if (!identical(unname(fit_hashes), unname(construction_hashes))) {
    v3d_abort("fit fingerprints differ from packet construction")
  }
  invisible(TRUE)
}

v3d_fit_one <- function(
  row, stage, preseal, r_root, julia_root,
  fit_fun = v3d_fit_call, construction_fun = v3d_engine_construction,
  fixed_panel_fun = v3d_read_fixed_markers, rss_fun = v3d_peak_rss_mb,
  vc_fun = hsquared::variance_components
) {
  started <- proc.time()[["elapsed"]]
  if (!requireNamespace("pkgload", quietly = TRUE)) v3d_abort("pkgload is required")
  Sys.setenv(HSQUARED_JULIA_PROJECT = julia_root)
  pkgload::load_all(r_root, quiet = TRUE, export_all = FALSE, helpers = FALSE)
  RNGkind("Mersenne-Twister", "Inversion", "Rejection")
  set.seed(as.integer(row$seed))
  panel <- if (stage == "d0f") fixed_panel_fun(row) else v3d_draw_markers(row)
  M <- panel$M; ids <- panel$ids; marker_names <- panel$marker_names
  rownames(M) <- ids; colnames(M) <- marker_names
  phenotype_rng <- get(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  construction <- construction_fun(M, ids, marker_names, julia_root)
  assign(".Random.seed", phenotype_rng, envir = .GlobalEnv)
  provenance <- construction$provenance
  validated_provenance <- v3d_validate_construction_provenance(
    provenance, preseal, row$ridge
  )
  getp <- function(name) as.character(provenance[[name]])
  hashes <- validated_provenance$hashes
  if (stage == "d0f" && any(hashes != unlist(row[names(hashes)], use.names = FALSE))) {
    v3d_abort("D0F engine construction differs from the fixed-panel manifest")
  }
  spectral <- v3d_spectral(construction$Q)
  k <- validated_provenance$scale_denominator
  if (!is.finite(k) || k <= 0 || ncol(M) < 1L || ncol(M) > row$m) {
    v3d_abort("invalid retained marker construction")
  }
  u <- sqrt(as.numeric(row$truth_sigma_g2)) *
    as.numeric(t(chol(construction$K)) %*% stats::rnorm(row$n))
  epsilon <- sqrt(as.numeric(row$truth_sigma_e2)) * stats::rnorm(row$n)
  dat <- data.frame(y = u + epsilon, id = ids, stringsAsFactors = FALSE)
  manifest_columns <- if (stage == "d0f") v3p_d0f_phenotype_columns else v3p_d1_columns
  result <- as.list(row[manifest_columns])
  if (stage == "d1") {
    result <- c(result, list(
      retained_m = ncol(M), marker_hash = hashes[["marker_hash"]],
      id_hash = hashes[["id_hash"]], kernel_hash = hashes[["kernel_hash"]],
      precision_hash = hashes[["precision_hash"]]
    ))
  }
  result <- c(result, list(
    attempted = TRUE, status = "fit_error", error_class = "unclassified_error",
    converged = FALSE, boundary_status = NA_character_,
    boundary_reason = NA_character_, boundary_epsilon = NA_real_,
    scientific_sigma_g2 = NA_real_, scientific_sigma_e2 = NA_real_,
    scientific_ratio = NA_real_, fitted_total_variance = NA_real_,
    numerical_sigma_g2 = NA_real_, numerical_sigma_e2 = NA_real_,
    numerical_ratio = NA_real_, profile_loglik = NA_real_,
    lower_derivative_per_observation = NA_real_,
    upper_derivative_per_observation = NA_real_, iterations = NA_real_,
    objective = NA_real_, gradient_norm = NA_real_, runtime_seconds = NA_real_,
    peak_rss_mb = NA_real_, scale_denominator = k,
    eigen_cv_population = spectral$eigen_cv_population,
    effective_rank = spectral$effective_rank,
    information_r020 = spectral$information_r020,
    se_info_r020 = spectral$se_info_r020,
    information_r050 = spectral$information_r050,
    se_info_r050 = spectral$se_info_r050,
    information_r080 = spectral$information_r080,
    se_info_r080 = spectral$se_info_r080,
    relationship_source = getp("relationship_source"),
    relationship_method = getp("relationship_method"),
    allele_frequency_source = getp("allele_frequency_source"),
    relationship_scale = getp("relationship_scale"), route = v3d_route,
    r_implementation_commit = preseal[["r_auto_route_commit"]],
    julia_implementation_commit = preseal[["julia_candidate_commit"]],
    driver_commit = preseal[["r_driver_commit"]],
    preseal_sha256 = preseal[["preseal_sha256"]]
  ))
  fit_error <- NULL
  fit <- tryCatch(
    fit_fun(M, dat),
    error = function(error) {
      fit_error <<- error
      NULL
    }
  )
  if (is.null(fit_error)) {
    boundary <- fit$result$genomic_boundary
    if (is.null(boundary)) v3d_contract_abort("missing boundary payload")
    result$boundary_status <- as.character(boundary$status)
    result$boundary_reason <- as.character(boundary$reason)
    result$boundary_epsilon <- as.numeric(boundary$boundary_epsilon)
    result$profile_loglik <- as.numeric(boundary$profile_loglik)
    result$lower_derivative_per_observation <-
      as.numeric(boundary$lower_derivative_per_observation)
    result$upper_derivative_per_observation <-
      as.numeric(boundary$upper_derivative_per_observation)
    if (identical(result$boundary_status, "boundary_unresolved")) {
      fit_error <- simpleError("boundary_unresolved")
    } else {
      if (length(result$boundary_status) != 1L ||
          !result$boundary_status %in% c(
            "boundary_lower", "boundary_upper", "interior", "interior_rescued"
          )) {
        v3d_contract_abort("unknown resolved boundary status")
      }
      if (!isTRUE(fit$result$converged)) {
        fit_error <- simpleError("fit_result_not_converged")
      } else tryCatch({
        profile_ratio <- as.numeric(boundary$profile_ratio)
        vc <- vc_fun(fit)
        ng <- vc$estimate[vc$component == "genomic"]
        ne <- vc$estimate[vc$component == "residual"]
        if (length(ng) != 1L || length(ne) != 1L) {
          v3d_contract_abort("resolved variance-component schema is malformed")
        }
        total <- as.numeric(ng + ne)
        if (length(profile_ratio) != 1L || !is.finite(profile_ratio) ||
            length(total) != 1L || !is.finite(total) || total <= 0 ||
            profile_ratio < 0 || profile_ratio > 1) {
          v3d_contract_abort("resolved scientific profile is malformed")
        }
        fit_prov <- fit$result$relationship_provenance
        v3d_validate_fit_provenance(fit_prov, provenance, preseal)
        result$status <- "success"; result$error_class <- "none"
        result$converged <- TRUE
        result$scientific_sigma_g2 <- profile_ratio * total
        result$scientific_sigma_e2 <- (1 - profile_ratio) * total
        result$scientific_ratio <- profile_ratio
        result$fitted_total_variance <- total
        result$numerical_sigma_g2 <- as.numeric(ng)
        result$numerical_sigma_e2 <- as.numeric(ne)
        result$numerical_ratio <- v3d_declared_numerical_ratio(
          boundary$numerical_ratio,
          result$numerical_sigma_g2,
          result$numerical_sigma_e2
        )
        result$iterations <- v3d_or(fit$result$diagnostics$iterations, NA_real_)
        result$objective <- if (is.null(fit$result$loglik)) NA_real_ else
          -as.numeric(fit$result$loglik)
        gradient_norm <- suppressWarnings(as.numeric(
          fit$result$diagnostics$gradient_norm
        ))
        if (length(gradient_norm) != 1L || !is.finite(gradient_norm)) {
          v3d_contract_abort(
            "successful genomic fit is missing a finite AI score norm"
          )
        }
        result$gradient_norm <- gradient_norm
      }, error = function(error) {
        if (inherits(error, "v3d_contract_error")) stop(error)
        v3d_contract_abort(
          "resolved fit payload failed contract validation: %s",
          conditionMessage(error)
        )
      })
    }
  }
  if (!is.null(fit_error)) {
    result$status <- "fit_error"; result$converged <- FALSE
    result$error_class <- v3d_error_class(fit_error)
    if (!identical(result$boundary_status, "boundary_unresolved")) {
      result$boundary_status <- NA_character_
      result$boundary_reason <- NA_character_
      result$boundary_epsilon <- NA_real_
      result$profile_loglik <- NA_real_
      result$lower_derivative_per_observation <- NA_real_
      result$upper_derivative_per_observation <- NA_real_
    }
    for (field in c(
      "scientific_sigma_g2", "scientific_sigma_e2", "scientific_ratio",
      "fitted_total_variance", "numerical_sigma_g2", "numerical_sigma_e2",
      "numerical_ratio", "iterations", "objective", "gradient_norm"
    )) result[[field]] <- NA_real_
  }
  result$runtime_seconds <- proc.time()[["elapsed"]] - started
  result$peak_rss_mb <- as.numeric(rss_fun())
  if (!is.finite(result$peak_rss_mb) || result$peak_rss_mb < 0) {
    v3d_abort("peak RSS is unavailable or invalid")
  }
  attempt_columns <- if (stage == "d0f") v3p_d0f_attempt_columns else v3p_d1_attempt_columns
  attempt <- as.data.frame(result, stringsAsFactors = FALSE, check.names = FALSE)
  attempt <- attempt[attempt_columns]
  truth_base <- if (stage == "d0f") {
    as.list(row[v3p_d0f_phenotype_columns])
  } else {
    c(as.list(row[v3p_d1_columns]), list(
      retained_m = ncol(M), marker_hash = hashes[["marker_hash"]],
      id_hash = hashes[["id_hash"]], kernel_hash = hashes[["kernel_hash"]],
      precision_hash = hashes[["precision_hash"]]
    ))
  }
  truth <- c(truth_base, list(
    packet_schema_version = v3d_packet_schema,
    truth_schema_version = v3d_truth_schema, scale_denominator = k,
    relationship_source = "markers", relationship_method = "vanraden1",
    allele_frequency_source = "sample", relationship_scale = "K_lambda",
    preseal_sha256 = preseal[["preseal_sha256"]],
    r_implementation_commit = preseal[["r_auto_route_commit"]],
    julia_implementation_commit = preseal[["julia_candidate_commit"]],
    driver_commit = preseal[["r_driver_commit"]]
  ))
  truth <- as.data.frame(truth, stringsAsFactors = FALSE, check.names = FALSE)
  truth <- truth[v3d_truth_columns(stage)]
  packet <- list(
    markers = data.frame(id = ids, M, check.names = FALSE),
    ids = data.frame(index = seq_len(nrow(M)), id = ids, stringsAsFactors = FALSE),
    phenotype = data.frame(
      index = seq_len(nrow(M)), id = ids, y = dat$y,
      stringsAsFactors = FALSE
    ),
    truth = truth
  )
  list(attempt = attempt, packet = packet)
}

v3d_attempt_binding <- function(value, preseal_sha256) {
  list(
    preseal_sha256 = preseal_sha256,
    manifest_sha256 = value[["manifest_sha256"]],
    corpus_lock_sha256 = paste(rep("0", 64L), collapse = ""),
    r_auto_route_commit = value[["r_auto_route_commit"]],
    julia_candidate_commit = value[["julia_candidate_commit"]],
    r_driver_commit = value[["r_driver_commit"]],
    julia_replay_commit = value[["julia_replay_commit"]],
    julia_replay_sha256 = value[["julia_replay_sha256"]]
  )
}

v3d_validate_attempt <- function(attempt, manifest, stage, binding) {
  expected <- if (stage == "d0f") v3p_d0f_attempt_columns else v3p_d1_attempt_columns
  if (!identical(names(attempt), expected) || nrow(attempt) != 1L || nrow(manifest) != 1L) {
    v3d_abort("single-attempt schema or denominator drift")
  }
  manifest_columns <- if (stage == "d0f") v3p_d0f_phenotype_columns else v3p_d1_columns
  v3p_validate_results(
    attempt, manifest, manifest_columns,
    sprintf("%s single attempt", toupper(stage)), binding
  )
}

v3d_phase_state <- function(output_root, stage, manifest, require_complete = FALSE) {
  base_names <- v3p_preseal_names(
    stage, TRUE, bootstrap_materialized = identical(stage, "d0f")
  )
  expected_files <- c(base_names, paste0(base_names, ".sha256"))
  lock <- file.path(output_root, "stage_corpus_lock.tsv")
  lock_present <- c(
    v07d_is_regular_file(lock) && !v07d_has_symlink_component(lock),
    v07d_is_regular_file(paste0(lock, ".sha256")) &&
      !v07d_has_symlink_component(paste0(lock, ".sha256"))
  )
  if (xor(lock_present[[1L]], lock_present[[2L]])) v3d_abort("orphan corpus-lock pair")
  path_present <- function(path) {
    link <- Sys.readlink(path)
    file.exists(path) || dir.exists(path) || (!is.na(link) && nzchar(link))
  }
  raw_lock <- c(path_present(lock), path_present(paste0(lock, ".sha256")))
  if (any(raw_lock) && !all(lock_present)) v3d_abort("invalid corpus-lock pair")
  if (all(lock_present)) {
    expected_files <- c(
      expected_files, "stage_corpus_lock.tsv", "stage_corpus_lock.tsv.sha256"
    )
  }
  complete <- logical(nrow(manifest))
  root <- normalizePath(output_root, winslash = "/", mustWork = TRUE)
  relative <- function(path) substring(path, nchar(root) + 2L)
  for (i in seq_len(nrow(manifest))) {
    row <- manifest[i, , drop = FALSE]
    attempt <- v3d_attempt_path(output_root, stage, row)
    packet <- v3d_packet_dir(output_root, stage, row)
    state <- v3d_target_state(attempt, packet)
    if (state == "partial") v3d_abort("partial attempt/packet publication")
    if (state == "complete") {
      v07d_verify_pair(attempt)
      v3d_verify_packet(packet, stage)
      complete[[i]] <- TRUE
      packet_files <- file.path(packet, v3d_packet_primaries)
      expected_files <- c(
        expected_files, relative(attempt), relative(paste0(attempt, ".sha256")),
        relative(packet_files), relative(paste0(packet_files, ".sha256"))
      )
    }
  }
  v07d_verify_tree_membership(output_root, expected_files, "official stage corpus")
  observed_dirs <- list.dirs(output_root, recursive = TRUE, full.names = TRUE)
  if (any(vapply(observed_dirs, v07d_has_symlink_component, logical(1L)))) {
    v3d_abort("official stage corpus contains a symlinked directory")
  }
  if (require_complete && !all(complete)) v3d_abort("manifest denominator is incomplete")
  if (any(lock_present) && !all(complete)) v3d_abort("corpus lock exists before completion")
  list(n_complete = sum(complete), n_expected = nrow(manifest), locked = all(lock_present))
}

v3d_run_one <- function(
  output_root, stage, group, seed, driver_root, r_root, julia_root,
  fit_fun = v3d_fit_call, construction_fun = v3d_engine_construction,
  fixed_panel_fun = v3d_read_fixed_markers, rss_fun = v3d_peak_rss_mb,
  bound_fun = v3d_validate_bound_stage
) {
  stage <- v3d_stage(stage)
  bound <- bound_fun(
    output_root, stage, driver_root, r_root, julia_root
  )
  manifest <- v3d_manifest(output_root, stage)
  lock <- file.path(output_root, "stage_corpus_lock.tsv")
  if (file.exists(lock) || file.exists(paste0(lock, ".sha256"))) {
    v3d_abort("stage corpus is already locked")
  }
  seed <- as.numeric(seed)
  hit <- vapply(seq_len(nrow(manifest)), function(i) {
    v3d_group(manifest[i, , drop = FALSE], stage) == group && manifest$seed[[i]] == seed
  }, logical(1L))
  if (sum(hit) != 1L) v3d_abort("requested group/seed is not exactly one manifest member")
  row <- manifest[hit, , drop = FALSE]
  attempt_path <- v3d_attempt_path(output_root, stage, row)
  packet_path <- v3d_packet_dir(output_root, stage, row)
  target_state <- v3d_target_state(attempt_path, packet_path)
  if (target_state == "complete") {
    v07d_verify_pair(attempt_path)
    v3d_verify_packet(packet_path, stage)
    return(invisible(v07d_read_tsv(
      attempt_path,
      if (stage == "d0f") v3p_d0f_attempt_columns else v3p_d1_attempt_columns
    )))
  }
  if (target_state == "partial") v3d_abort("target has a partial attempt/packet publication")

  # The claim lives beside the stage corpus. It serializes duplicate targets
  # without exposing a legitimate worker temp to corpus membership checks.
  claim <- v3d_acquire_claim(output_root, stage, row)
  on.exit(unlink(claim), add = TRUE)
  if (v3d_target_state(attempt_path, packet_path) != "absent") {
    v3d_abort("target changed after worker claim")
  }
  generated <- v3d_fit_one(
    row, stage,
    c(bound$preseal$value, preseal_sha256 = bound$preseal$sha256),
    r_root, julia_root, fit_fun, construction_fun, fixed_panel_fun, rss_fun
  )
  binding <- v3d_attempt_binding(bound$preseal$value, bound$preseal$sha256)
  v3d_validate_attempt(generated$attempt, manifest[hit, , drop = FALSE], stage, binding)
  v3d_write_packet(output_root, stage, row, generated$packet)
  v07d_write_once(attempt_path, v07d_tsv_text(generated$attempt))
  v07d_verify_pair(attempt_path)
  v3d_verify_packet(packet_path, stage)
  invisible(generated$attempt)
}

v3d_corpus_entries <- function(output_root, stage, manifest) {
  v3d_phase_state(output_root, stage, manifest, require_complete = TRUE)
  paths <- c(
    file.path(output_root, "stage_preseal.tsv"),
    file.path(output_root, paste0(stage, "_manifest.tsv"))
  )
  for (i in seq_len(nrow(manifest))) {
    row <- manifest[i, , drop = FALSE]
    paths <- c(
      paths, v3d_attempt_path(output_root, stage, row),
      file.path(v3d_packet_dir(output_root, stage, row), v3d_packet_primaries)
    )
  }
  for (path in paths) v07d_verify_pair(path)
  root <- normalizePath(output_root, winslash = "/", mustWork = TRUE)
  real <- vapply(paths, normalizePath, character(1L), winslash = "/", mustWork = TRUE)
  if (any(!startsWith(real, paste0(root, "/")))) v3d_abort("corpus member escapes output root")
  out <- data.frame(
    relative_path = substring(real, nchar(root) + 2L),
    sha256 = vapply(real, v07d_sha256, character(1L)),
    stringsAsFactors = FALSE
  )
  out <- out[order(out$relative_path), v3d_corpus_columns, drop = FALSE]
  rownames(out) <- NULL
  if (anyDuplicated(out$relative_path)) v3d_abort("duplicate corpus-lock path")
  out
}

v3d_lock_corpus <- function(
  output_root, stage, driver_root, r_root, julia_root
) {
  v3d_assert_no_stale_claims(output_root)
  v3d_validate_bound_stage(output_root, stage, driver_root, r_root, julia_root)
  manifest <- v3d_manifest(output_root, stage)
  path <- file.path(output_root, "stage_corpus_lock.tsv")
  if (file.exists(path) || file.exists(paste0(path, ".sha256"))) {
    v3d_abort("stage corpus lock already exists")
  }
  entries <- v3d_corpus_entries(output_root, stage, manifest)
  v07d_write_once(path, v07d_tsv_text(entries))
  state <- v3d_phase_state(output_root, stage, manifest, require_complete = TRUE)
  if (!state$locked) v3d_abort("corpus lock publication failed")
  invisible(entries)
}

v3d_verify_phase <- function(
  output_root, stage, driver_root, r_root, julia_root
) {
  v3d_assert_no_stale_claims(output_root)
  v3d_validate_bound_stage(
    output_root, stage, driver_root, r_root, julia_root,
    runtime_phase = "locked"
  )
  manifest <- v3d_manifest(output_root, stage)
  state <- v3d_phase_state(output_root, stage, manifest)
  if (state$locked) {
    observed <- v07d_read_tsv(
      file.path(output_root, "stage_corpus_lock.tsv"), v3d_corpus_columns
    )
    expected <- v3d_corpus_entries(output_root, stage, manifest)
    if (!identical(observed, expected)) v3d_abort("locked corpus differs from current corpus")
  }
  invisible(state)
}

v3d_selftest <- function() {
  options <- v3d_option_map(c("--mode=selftest", "--stage", "d1"))
  stopifnot(options$mode == "selftest", options$stage == "d1")
  code <- paste(deparse(body(v3d_fit_call)), collapse = "\n")
  fit_hits <- gregexpr("hsquared::hsquared", code, fixed = TRUE)[[1L]]
  stopifnot(
    sum(fit_hits > 0L) == 1L,
    !grepl("engine_control|hs_control|target[[:space:]]*=", code)
  )
  environment <- c(
    GITHUB_ACTIONS = "false", CI = "false", OPENBLAS_NUM_THREADS = "1",
    JULIA_NUM_THREADS = "1", OMP_NUM_THREADS = "1", MKL_NUM_THREADS = "1",
    VECLIB_MAXIMUM_THREADS = "1", NUMEXPR_NUM_THREADS = "1"
  )
  v3d_assert_execution_context(host = "totoro", environment = environment)
  bad <- environment; bad[["GITHUB_ACTIONS"]] <- "true"
  stopifnot(inherits(try(
    v3d_assert_execution_context(host = "totoro", environment = bad),
    silent = TRUE
  ), "try-error"))
  root <- tempfile("v3d-selftest-"); dir.create(root)
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  on.exit(unlink(root, recursive = TRUE, force = TRUE), add = TRUE)
  review <- file.path(root, "fisher.tsv")
  v3d_write_review(
    review, "fisher", "CLEAN", paste(rep("a", 64L), collapse = ""),
    paste(rep("a", 40L), collapse = ""), paste(rep("b", 40L), collapse = ""),
    paste(rep("c", 40L), collapse = ""), paste(rep("d", 40L), collapse = ""),
    paste(rep("e", 40L), collapse = ""), paste(rep("a", 64L), collapse = ""),
    paste(rep("b", 64L), collapse = ""), paste(rep("c", 64L), collapse = "")
  )
  v07d_verify_pair(review)
  stopifnot(inherits(try(v3d_write_review(
    review, "fisher", "CLEAN", paste(rep("a", 64L), collapse = ""),
    paste(rep("a", 40L), collapse = ""), paste(rep("b", 40L), collapse = ""),
    paste(rep("c", 40L), collapse = ""), paste(rep("d", 40L), collapse = ""),
    paste(rep("e", 40L), collapse = ""), paste(rep("a", 64L), collapse = ""),
    paste(rep("b", 64L), collapse = ""), paste(rep("c", 64L), collapse = "")
  ), silent = TRUE), "try-error"))
  r_root <- dirname(dirname(v3d_loaded_path))
  context <- v3d_context(
    r_root, r_root,
    normalizePath(file.path(r_root, "..", "HSquared.jl"), winslash = "/", mustWork = TRUE)
  )
  stopifnot(
    identical(basename(context$r_recomputer_path), "v07_genomic_recovery_v3_recompute.R"),
    !identical(context$r_recomputer_path, context$d0_recomputer_path)
  )
  message("v0.7 genomic recovery-v3 official driver selftest: PASS (synthetic only)")
  invisible(TRUE)
}

v3d_main <- function(args = commandArgs(trailingOnly = TRUE)) {
  options <- v3d_option_map(args)
  mode <- v3d_required(options, "mode")
  if (mode == "selftest") return(v3d_selftest())
  if (mode == "write-review") {
    return(v3d_write_review(
      v3d_required(options, "path"), v3d_required(options, "reviewer"),
      v3d_required(options, "verdict"), v3d_required(options, "doc49-sha256"),
      v3d_required(options, "r-driver-commit"),
      v3d_required(options, "r-recomputer-commit"),
      v3d_required(options, "julia-replay-commit"),
      v3d_required(options, "r-auto-route-commit"),
      v3d_required(options, "julia-candidate-commit"),
      v3d_required(options, "r-driver-sha256"),
      v3d_required(options, "r-recomputer-sha256"),
      v3d_required(options, "julia-replay-sha256")
    ))
  }
  output_root <- v3d_required(options, "output-root")
  stage <- v3d_stage(v3d_required(options, "stage"))
  driver_root <- v3d_required(options, "driver-root")
  r_root <- v3d_required(options, "r-root")
  julia_root <- v3d_required(options, "julia-root")
  if (mode == "prepare-stage") {
    v3d_prepare_stage(
      output_root, stage, driver_root, r_root, julia_root,
      v3d_required(options, "receipt-root"),
      v3d_required(options, "max-workers"),
      options[["d0f-adjudication-root"]]
    )
  } else if (mode == "write-preseal") {
    v3d_write_preseal(
      output_root, stage, driver_root, r_root, julia_root,
      v3d_required(options, "r-auto-route-commit"),
      v3d_required(options, "julia-candidate-commit"),
      options[["d0f-adjudication-root"]]
    )
  } else if (mode == "materialize-bootstrap") {
    v3d_materialize_bootstrap(
      output_root, stage, driver_root, r_root, julia_root
    )
  } else if (mode == "run-one") {
    v3d_run_one(
      output_root, stage, v3d_required(options, "group"),
      v3d_required(options, "seed"), driver_root, r_root, julia_root
    )
  } else if (mode == "verify-phase") {
    v3d_verify_phase(output_root, stage, driver_root, r_root, julia_root)
  } else if (mode == "lock-corpus") {
    v3d_lock_corpus(output_root, stage, driver_root, r_root, julia_root)
  } else {
    v3d_abort("unknown --mode: %s", mode)
  }
}

if (sys.nframe() == 0L) v3d_main()
