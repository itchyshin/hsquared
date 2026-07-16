#!/usr/bin/env Rscript

# Opt-in, zero-fit integration rehearsal for the recovery-v3 D0F -> D1
# adjudication lifecycle. The rehearsal deliberately uses synthetic seed spaces
# and synthetic authenticated attempt/packet evidence. It exercises the real
# summary, lineage, review, adjudication, exact-retry, and final-tree code in
# fresh `Rscript --vanilla` workers.
#
# The one explicit test seam is clean-deployment/preseal validation: a temporary
# root cannot reproduce Totoro's frozen D0 and clean deployed git topology. The
# worker therefore validates the preseal pair and manifest binding, then bypasses
# only the live deployment projection. D1 still calls the production
# `v3p_validate_successful_d0f_adjudication()` against the exact synthetic D0F
# PASS/COMPLETE receipt. No finalizer or `v3r_expected_final()` function is
# replaced. For tractability over roughly 18,000 tiny files, the harness swaps
# only the SHA-256 and regular-file command-line backends for byte-/semantics-
# equivalent R implementations; all digests, sidecars, and admission outcomes
# remain production-compatible.

v3s_abort <- function(...) stop(sprintf(...), call. = FALSE)

v3s_option <- function(args, key, default = NULL) {
  prefix <- paste0("--", key, "=")
  hits <- args[startsWith(args, prefix)]
  if (length(hits) > 1L) {
    v3s_abort("option --%s occurs more than once", key)
  }
  if (!length(hits)) {
    return(default)
  }
  sub(prefix, "", hits[[1L]], fixed = TRUE)
}

v3s_required <- function(args, key) {
  value <- v3s_option(args, key)
  if (is.null(value) || !nzchar(value)) {
    v3s_abort("--%s is required", key)
  }
  value
}

v3s_script_path <- function() {
  args <- commandArgs(FALSE)
  file_arg <- sub("^--file=", "", grep("^--file=", args, value = TRUE))
  if (length(file_arg) != 1L) {
    v3s_abort("cannot locate synthetic lifecycle tool")
  }
  normalizePath(
    gsub("~+~", " ", file_arg, fixed = TRUE),
    winslash = "/",
    mustWork = TRUE
  )
}

v3s_tool_path <- v3s_script_path()
v3s_r_root <- normalizePath(
  file.path(dirname(v3s_tool_path), ".."),
  winslash = "/",
  mustWork = TRUE
)
v3s_core_path <- file.path(
  v3s_r_root,
  "tools",
  "v07_genomic_recovery_v3_recompute.R"
)
sys.source(v3s_core_path, envir = .GlobalEnv)

v3s_tool_hashes <- function() {
  julia_root <- normalizePath(
    file.path(v3s_r_root, "..", "HSquared.jl"),
    winslash = "/",
    mustWork = TRUE
  )
  paths <- c(
    r_driver_sha256 = file.path(
      v3s_r_root,
      "tools",
      "v07_genomic_recovery_v3.R"
    ),
    r_recomputer_sha256 = v3s_core_path,
    julia_replay_sha256 = file.path(
      julia_root,
      "sim",
      "phase2_v07_genomic_recovery_v3_stage_replay.jl"
    )
  )
  vapply(paths, v07d_sha256, character(1L))
}

if (!requireNamespace("openssl", quietly = TRUE)) {
  v3s_abort("the opt-in synthetic lifecycle requires the openssl R package")
}
v07d_sha256_raw <- function(bytes) {
  if (!is.raw(bytes)) {
    v3s_abort("SHA-256 preimage must be raw")
  }
  unclass(as.character(openssl::sha256(bytes)))
}
v07d_sha256 <- function(path) {
  if (!file.exists(path) || isTRUE(file.info(path)$isdir)) {
    v3s_abort("missing regular file: %s", path)
  }
  size <- file.info(path)$size
  bytes <- readBin(path, what = "raw", n = size)
  v07d_sha256_raw(bytes)
}
v07d_is_regular_file <- function(path) {
  info <- file.info(path)
  exists <- file.exists(path)
  exists[is.na(exists)] <- FALSE
  isdir <- info$isdir
  isdir[is.na(isdir)] <- TRUE
  link <- Sys.readlink(path)
  exists & !isdir & (is.na(link) | !nzchar(link))
}

# These bases are reserved only inside this fresh process. They are deliberately
# disjoint from every official/retired recovery-v3 Retry space and are never
# passed to a fit. Bootstrap construction uses only the synthetic base below.
v3s_d1_seed_base <- 1100000000L
v3s_d0f_phenotype_base <- 1110000000L
v3s_d0f_bootstrap_base <- 1120000000L
assign("v3_seed_base", v3s_d1_seed_base, envir = .GlobalEnv)
assign(
  "v07s_d0f_retry_phenotype_base",
  v3s_d0f_phenotype_base,
  envir = .GlobalEnv
)
assign(
  "v07s_d0f_retry_bootstrap_base",
  v3s_d0f_bootstrap_base,
  envir = .GlobalEnv
)

v3s_enable_projection_seam <- function() {
  assign(
    "v3r_validate_preseal_postrun",
    function(root, stage, runtime_phase) {
      root <- v3r_canonical_dir(root, "synthetic stage output root")
      preseal <- v3r_preseal_values(file.path(root, "stage_preseal.tsv"))
      if (
        !identical(preseal$value[["stage"]], stage) ||
          !identical(preseal$value[["output_root"]], root)
      ) {
        v3r_abort("synthetic stage preseal stage/root drift")
      }
      if (identical(stage, "d1")) {
        v3p_validate_successful_d0f_adjudication(
          preseal$value[["d0f_adjudication_root"]],
          preseal$value[["d0f_adjudication_receipt_sha256"]],
          root
        )
      }
      preseal
    },
    envir = .GlobalEnv
  )
  invisible(TRUE)
}

v3s_enable_projection_seam()

v3s_hex <- function(text, n = 64L) {
  digest <- v3r_hash_text(text)
  if (n == 64L) digest else substr(digest, 1L, n)
}

v3s_git_head <- function(root) {
  out <- system2(
    Sys.which("git"),
    c("-C", shQuote(root), "rev-parse", "HEAD"),
    stdout = TRUE,
    stderr = TRUE
  )
  if (
    !is.null(attr(out, "status")) ||
      length(out) != 1L ||
      !grepl("^[0-9a-f]{40}$", out)
  ) {
    v3s_abort("cannot read git HEAD for %s", root)
  }
  out[[1L]]
}

v3s_write <- function(path, value, root) {
  # Synthetic input materialization is single-process and occurs only in a new
  # empty root, so avoid thousands of POSIX `ln` subprocesses here. Production
  # summary/review/receipt outputs below still use `v3r_write_once()` unchanged.
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  sidecar <- paste0(path, ".sha256")
  if (file.exists(path) || file.exists(sidecar)) {
    v3s_abort("synthetic create-once path already exists: %s", path)
  }
  bytes <- charToRaw(enc2utf8(v07d_tsv_text(value)))
  con <- file(path, open = "wb")
  on.exit(close(con), add = TRUE)
  writeBin(bytes, con)
  close(con)
  on.exit(NULL, add = FALSE)
  digest <- v07d_sha256_raw(bytes)
  sidecar_bytes <- charToRaw(sprintf("%s  %s\n", digest, basename(path)))
  con <- file(sidecar, open = "wb")
  on.exit(close(con), add = TRUE)
  writeBin(sidecar_bytes, con)
  close(con)
  on.exit(NULL, add = FALSE)
  invisible(path)
}

v3s_fixture_binding <- function() {
  list(
    preseal_sha256 = v3s_hex("fixture-preseal"),
    manifest_sha256 = v3s_hex("fixture-manifest"),
    corpus_lock_sha256 = v3s_hex("fixture-corpus"),
    r_auto_route_commit = v3s_hex("fixture-r-auto", 40L),
    julia_candidate_commit = v3s_hex("fixture-julia", 40L),
    r_driver_commit = v3s_hex("fixture-r-driver", 40L),
    julia_replay_commit = v3s_hex("fixture-julia-replay", 40L),
    julia_replay_sha256 = v3s_hex("fixture-julia-replay-bytes")
  )
}

v3s_parity_fixture <- function(stage) {
  binding <- v3s_fixture_binding()
  if (identical(stage, "d0f")) {
    v3p_d0f_summary_parity_fixture(binding)
  } else if (identical(stage, "d1")) {
    v3p_d1_summary_parity_fixture(binding)
  } else {
    v3s_abort("synthetic stage must be d0f or d1")
  }
}

v3s_write_preseal_inputs <- function(root, stage, fixture) {
  v3s_write(
    file.path(root, "doc49.md"),
    data.frame(note = "synthetic lifecycle only", stringsAsFactors = FALSE),
    root
  )
  v3s_write(file.path(root, "cell_table.tsv"), v3p_cell_table(), root)
  v3s_write(
    file.path(root, "historical_seed_lock.tsv"),
    data.frame(
      note = "synthetic bases 1100000000/1110000000/1120000000",
      stringsAsFactors = FALSE
    ),
    root
  )
  v3s_write(
    file.path(root, "environment_manifest.tsv"),
    data.frame(
      key = c("scope", "stage"),
      value = c("synthetic_lifecycle", stage),
      stringsAsFactors = FALSE
    ),
    root
  )
  v3s_write(
    file.path(root, paste0(stage, "_manifest.tsv")),
    fixture$manifest,
    root
  )
  for (reviewer in v3p_reviewers) {
    v3s_write(
      file.path(root, "receipts", paste0(reviewer, ".tsv")),
      data.frame(
        reviewer = reviewer,
        verdict = "SYNTHETIC_INPUT",
        stringsAsFactors = FALSE
      ),
      root
    )
  }
  if (identical(stage, "d0f")) {
    fixed <- unique(fixture$manifest[v3p_d0f_fixed_columns])
    v3s_write(file.path(root, "d0f_fixed_panel_manifest.tsv"), fixed, root)
  }
  invisible(TRUE)
}

v3s_preseal_row <- function(root, stage, d0f = NULL) {
  julia_root <- normalizePath(
    file.path(v3s_r_root, "..", "HSquared.jl"),
    winslash = "/",
    mustWork = TRUE
  )
  context <- v3r_expected_tool_context()
  context$r_recomputer_path <- normalizePath(
    v3s_core_path,
    winslash = "/",
    mustWork = TRUE
  )
  tool_hashes <- v3s_tool_hashes()
  values <- setNames(
    rep("NA", length(v3p_stage_preseal_keys)),
    v3p_stage_preseal_keys
  )
  values[c(
    "schema_version",
    "stage",
    "output_root",
    "official_route",
    "replay_route",
    "packet_schema_version",
    "truth_schema_version",
    "relationship_source",
    "relationship_method",
    "allele_frequency_source",
    "relationship_scale",
    "ridge",
    "boundary_epsilon",
    "boundary_kkt_tolerance",
    "output_subtrees_absent_before_preseal"
  )] <- c(
    "v07-genomic-recovery-v3-stage-preseal-3",
    stage,
    root,
    "ordinary_auto_genomic",
    "julia_profile_replay",
    "v07-genomic-recovery-v3-packet-1",
    "v07-genomic-recovery-v3-truth-1",
    "markers",
    "vanraden1",
    "sample",
    "K_lambda",
    "0.01",
    "1e-07",
    "1e-08",
    "true"
  )
  paths <- c(
    doc49_sha256 = "doc49.md",
    cell_table_sha256 = "cell_table.tsv",
    manifest_sha256 = paste0(stage, "_manifest.tsv"),
    environment_manifest_sha256 = "environment_manifest.tsv",
    historical_seed_lock_sha256 = "historical_seed_lock.tsv"
  )
  for (key in names(paths)) {
    values[[key]] <- v07d_sha256(file.path(root, paths[[key]]))
  }
  for (reviewer in v3p_reviewers) {
    values[[paste0(reviewer, "_receipt_sha256")]] <- v07d_sha256(
      file.path(root, "receipts", paste0(reviewer, ".tsv"))
    )
  }
  values[c(
    "r_driver_commit",
    "r_recomputer_commit",
    "r_auto_route_commit"
  )] <- v3s_git_head(v3s_r_root)
  values[c("julia_replay_commit", "julia_candidate_commit")] <-
    v3s_git_head(julia_root)
  values[names(tool_hashes)] <- tool_hashes
  values[["d0_recomputer_sha256"]] <- v07d_sha256(context$d0_recomputer_path)
  values[["d0_output_root"]] <- dirname(root)
  values[["d0_adjudication_receipt_sha256"]] <- v3s_hex("synthetic-d0")
  values[["d0_diagnostics_sha256"]] <- v3s_hex("synthetic-d0-diagnostics")
  if (identical(stage, "d0f")) {
    values[["d0f_fixed_panel_manifest_sha256"]] <- v07d_sha256(
      file.path(root, "d0f_fixed_panel_manifest.tsv")
    )
    values[["d0f_bootstrap_seed_base"]] <- format(
      v3s_d0f_bootstrap_base,
      scientific = FALSE
    )
    values[["d0f_bootstrap_indices_absent_before_preseal"]] <- "true"
  } else {
    if (is.null(d0f)) {
      v3s_abort("D1 preseal requires exact synthetic D0F")
    }
    values[["d0f_adjudication_root"]] <- d0f$root
    values[["d0f_adjudication_receipt_sha256"]] <- d0f$receipt_sha256
  }
  data.frame(
    key = names(values),
    value = unname(values),
    stringsAsFactors = FALSE
  )
}

v3s_write_official_evidence <- function(root, stage, fixture, binding) {
  fixture <- if (identical(stage, "d0f")) {
    v3p_d0f_summary_parity_fixture(binding)
  } else {
    v3p_d1_summary_parity_fixture(binding)
  }
  if (
    !v3r_same_text_table(
      fixture$manifest,
      v3r_read_tsv(
        file.path(root, paste0(stage, "_manifest.tsv")),
        v3r_manifest_columns(stage)
      )
    )
  ) {
    v3s_abort("synthetic manifest changed after presealing")
  }
  for (i in seq_len(nrow(fixture$manifest))) {
    row <- fixture$manifest[i, , drop = FALSE]
    v3s_write(
      v3r_attempt_path(root, stage, row),
      fixture$attempts[i, , drop = FALSE],
      root
    )
    packet <- v3r_packet_dir(root, stage, row)
    for (name in v3r_packet_primaries) {
      v3s_write(
        file.path(packet, name),
        data.frame(
          member = name,
          synthetic = TRUE,
          stringsAsFactors = FALSE
        ),
        root
      )
    }
  }
  fixture
}

v3s_write_recomputations <- function(state, attempts) {
  native <- c(
    base_r_kernel_hash = v3s_hex("synthetic-native-kernel"),
    base_r_precision_hash = v3s_hex("synthetic-native-precision")
  )
  for (i in seq_len(nrow(state$manifest))) {
    row <- state$manifest[i, , drop = FALSE]
    base <- attempts[i, , drop = FALSE]
    base$base_r_kernel_hash <- native[[1L]]
    base$base_r_precision_hash <- native[[2L]]
    base <- base[c(v3r_attempt_columns(state$stage), v3r_native_hash_columns)]
    v3s_write(
      v3r_recompute_path(
        state$root,
        state$stage,
        row
      ),
      base,
      state$root
    )

    official_path <- v3r_attempt_path(state$root, state$stage, row)
    julia <- attempts[
      i,
      setdiff(
        v3r_attempt_columns(state$stage),
        "preseal_sha256"
      ),
      drop = FALSE
    ]
    julia$route <- "julia_profile_replay"
    julia$driver_commit <- state$binding$julia_replay_commit
    julia$source_r_attempt_sha256 <- v07d_sha256(official_path)
    julia$source_r_max_abs_difference <- 0
    julia$replay_julia_commit <- state$binding$julia_replay_commit
    julia$replay_driver_sha256 <- state$binding$julia_replay_sha256
    julia$manifest_sha256 <- state$binding$manifest_sha256
    julia$preseal_sha256 <- state$binding$preseal_sha256
    julia$corpus_lock_sha256 <- state$binding$corpus_lock_sha256
    julia <- julia[c(
      setdiff(v3r_attempt_columns(state$stage), "preseal_sha256"),
      v3p_replay_binding_columns
    )]
    v3s_write(
      v3r_julia_path(
        state$root,
        state$stage,
        row
      ),
      julia,
      state$root
    )
  }
  invisible(TRUE)
}

v3s_materialize_root <- function(root, stage, d0f = NULL) {
  dir.create(root, recursive = TRUE, showWarnings = FALSE)
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  fixture <- v3s_parity_fixture(stage)
  v3s_write_preseal_inputs(root, stage, fixture)
  preseal <- v3s_preseal_row(root, stage, d0f)
  v3s_write(file.path(root, "stage_preseal.tsv"), preseal, root)
  preseal_sha256 <- v07d_sha256(file.path(root, "stage_preseal.tsv"))
  preseal_values <- setNames(as.character(preseal$value), preseal$key)
  binding <- list(
    preseal_sha256 = preseal_sha256,
    manifest_sha256 = preseal_values[["manifest_sha256"]],
    corpus_lock_sha256 = v3s_hex("provisional-corpus"),
    r_auto_route_commit = preseal_values[["r_auto_route_commit"]],
    julia_candidate_commit = preseal_values[["julia_candidate_commit"]],
    r_driver_commit = preseal_values[["r_driver_commit"]],
    julia_replay_commit = preseal_values[["julia_replay_commit"]],
    julia_replay_sha256 = preseal_values[["julia_replay_sha256"]]
  )
  fixture <- v3s_write_official_evidence(root, stage, fixture, binding)
  if (identical(stage, "d0f")) {
    v3s_write(
      file.path(root, "d0f_bootstrap_indices.tsv"),
      fixture$bootstrap,
      root
    )
  }
  manifest <- fixture$manifest
  corpus <- v3r_inventory(
    root,
    v3r_expected_official_paths(
      root,
      stage,
      manifest
    )
  )
  v3s_write(file.path(root, "stage_corpus_lock.tsv"), corpus, root)
  state <- v3r_read_stage(root, stage, validate_deployment = FALSE)
  fixture <- if (identical(stage, "d0f")) {
    v3p_d0f_summary_parity_fixture(state$binding)
  } else {
    v3p_d1_summary_parity_fixture(state$binding)
  }
  v3s_write_recomputations(state, fixture$attempts)
  list(root = root, state = state, fixture = fixture)
}

v3s_worker <- function(args) {
  action <- v3s_required(args, "action")
  root <- normalizePath(
    v3s_required(args, "output-root"),
    winslash = "/",
    mustWork = TRUE
  )
  stage <- v3r_stage(v3s_required(args, "stage"))
  execution_guard <- if (
    identical(
      Sys.getenv("HSQUARED_RETRY7_SYNTHETIC_LOCAL"),
      "true"
    )
  ) {
    function() invisible(TRUE)
  } else {
    v3r_assert_execution_context
  }
  common <- c(paste0("--output-root=", root), paste0("--stage=", stage))
  execution_guard()
  if (identical(action, "summarize-r")) {
    return(v3r_main(
      c("--mode=summarize", common),
      execution_guard = execution_guard
    ))
  }
  if (identical(action, "summarize-julia")) {
    state <- v3r_read_stage(root, stage, runtime_phase = "julia_summary")
    rows <- v3r_read_rows(state, "julia")
    admitted <- v3r_admit_rows(state, "julia", rows$table)
    summary <- v3r_expected_summary(state, admitted)
    path <- file.path(root, paste0(stage, "_summary_julia.tsv"))
    v3r_write_once(path, summary, temporary_parent = dirname(root))
    message(sprintf(
      "wrote synthetic Julia %s summary rows=%d sha256=%s",
      stage,
      nrow(summary),
      v07d_sha256(path)
    ))
    return(invisible(summary))
  }
  if (identical(action, "lineage")) {
    return(v3r_main(
      c("--mode=write-route-lineage", common),
      execution_guard = execution_guard
    ))
  }
  if (identical(action, "review")) {
    reviewer <- v3s_required(args, "reviewer")
    reviewed_at <- v3s_required(args, "reviewed-at-utc")
    return(v3r_main(
      c(
        "--mode=write-postrun-review",
        common,
        paste0("--reviewer=", reviewer),
        "--verdict=CLEAN",
        paste0("--reviewed-at-utc=", reviewed_at)
      ),
      execution_guard = execution_guard
    ))
  }
  if (identical(action, "adjudicate")) {
    return(v3r_main(
      c(
        "--mode=adjudicate",
        common
      ),
      execution_guard = execution_guard
    ))
  }
  if (identical(action, "validate-final")) {
    return(v3r_main(
      c(
        "--mode=validate-final",
        common
      ),
      execution_guard = execution_guard
    ))
  }
  v3s_abort("unknown worker action: %s", action)
}

v3s_worker_timeout_seconds <- function(
  value = Sys.getenv("HSQUARED_RETRY7_SYNTHETIC_WORKER_TIMEOUT_SECONDS", "900")
) {
  if (!grepl("^[1-9][0-9]*$", value)) {
    v3s_abort(
      "HSQUARED_RETRY7_SYNTHETIC_WORKER_TIMEOUT_SECONDS must be a positive whole number"
    )
  }
  seconds <- as.integer(value)
  if (is.na(seconds) || seconds > 3600L) {
    v3s_abort(
      "HSQUARED_RETRY7_SYNTHETIC_WORKER_TIMEOUT_SECONDS must be at most 3600"
    )
  }
  seconds
}

v3s_timeout_program <- function() {
  program <- Sys.which("timeout")
  if (!nzchar(program)) {
    v3s_abort("synthetic lifecycle requires GNU timeout for bounded workers")
  }
  program
}

v3s_run_worker <- function(
  root,
  stage,
  action,
  extra = character(),
  runner = system2,
  timeout_seconds = v3s_worker_timeout_seconds(),
  timeout_program = v3s_timeout_program()
) {
  command <- c(
    "--signal=TERM",
    "--kill-after=15s",
    as.character(timeout_seconds),
    file.path(R.home("bin"), "Rscript"),
    "--vanilla",
    shQuote(v3s_tool_path),
    "--mode=worker",
    paste0("--action=", action),
    shQuote(paste0("--output-root=", root)),
    paste0("--stage=", stage),
    extra
  )
  output <- runner(
    timeout_program,
    command,
    stdout = TRUE,
    stderr = TRUE
  )
  status <- attr(output, "status")
  if (!is.null(status) && status != 0L) {
    timeout_note <- if (identical(status, 124L)) {
      sprintf(
        "worker exceeded %d-second bound; no later worker was launched",
        timeout_seconds
      )
    } else {
      "worker failed; no later worker was launched"
    }
    v3s_abort(
      "synthetic worker failed action=%s stage=%s status=%d (%s)\n%s",
      action,
      stage,
      status,
      timeout_note,
      paste(output, collapse = "\n")
    )
  }
  message(paste(output, collapse = "\n"))
  invisible(output)
}

v3s_complete_lifecycle <- function(root, stage, worker = v3s_run_worker) {
  worker(root, stage, "summarize-r")
  worker(root, stage, "summarize-julia")
  worker(root, stage, "lineage")
  for (i in seq_along(v3p_reviewers)) {
    reviewer <- v3p_reviewers[[i]]
    worker(
      root,
      stage,
      "review",
      c(
        paste0("--reviewer=", reviewer),
        sprintf("--reviewed-at-utc=2026-07-16T12:00:%02dZ", i)
      )
    )
  }
  worker(root, stage, "adjudicate")
  receipt_path <- file.path(root, "stage_adjudication_receipt.tsv")
  first_primary <- readBin(receipt_path, "raw", file.info(receipt_path)$size)
  first_sidecar <- readBin(
    paste0(receipt_path, ".sha256"),
    "raw",
    file.info(paste0(receipt_path, ".sha256"))$size
  )
  worker(root, stage, "adjudicate")
  if (
    !identical(
      first_primary,
      readBin(receipt_path, "raw", file.info(receipt_path)$size)
    ) ||
      !identical(
        first_sidecar,
        readBin(
          paste0(receipt_path, ".sha256"),
          "raw",
          file.info(paste0(receipt_path, ".sha256"))$size
        )
      )
  ) {
    v3s_abort("identical adjudication retry changed receipt bytes")
  }
  worker(root, stage, "validate-final")
  receipt <- v3r_read_tsv(
    receipt_path,
    v3r_receipt_columns,
    all_character = TRUE
  )
  preseal <- v3r_preseal_values(file.path(root, "stage_preseal.tsv"))
  tool_hashes <- v3s_tool_hashes()
  for (field in names(tool_hashes)) {
    if (
      !identical(preseal$value[[field]], tool_hashes[[field]]) ||
        !identical(receipt[[field]][[1L]], tool_hashes[[field]])
    ) {
      v3s_abort(
        "synthetic lifecycle %s does not bind actual %s bytes",
        stage,
        field
      )
    }
  }
  list(
    root = root,
    receipt = receipt,
    receipt_sha256 = v07d_sha256(receipt_path)
  )
}

v3s_validate_deployment <- function(r_root, julia_root) {
  r_root <- normalizePath(r_root, winslash = "/", mustWork = TRUE)
  julia_root <- normalizePath(julia_root, winslash = "/", mustWork = TRUE)
  expected_julia <- normalizePath(
    file.path(r_root, "..", "HSquared.jl"),
    winslash = "/",
    mustWork = TRUE
  )
  if (!identical(julia_root, expected_julia)) {
    v3s_abort("synthetic lifecycle requires sibling deployed twins")
  }
  v3p_git_clean(r_root)
  v3p_git_clean(julia_root)
  message(sprintf(
    "synthetic deployment check: PASS r_root=%s julia_root=%s",
    r_root,
    julia_root
  ))
  invisible(list(r_root = r_root, julia_root = julia_root))
}

v3s_worker_selftest <- function() {
  stopifnot(identical(v3s_worker_timeout_seconds("1"), 1L))
  for (value in c("0", "1.5", "3601", "not-a-number")) {
    error <- tryCatch(
      {
        v3s_worker_timeout_seconds(value)
        NULL
      },
      error = identity
    )
    stopifnot(inherits(error, "error"))
  }
  call <- NULL
  runner <- function(command, args, stdout, stderr) {
    call <<- list(
      command = command,
      args = args,
      stdout = stdout,
      stderr = stderr
    )
    structure("bounded worker", status = 124L)
  }
  error <- tryCatch(
    {
      v3s_run_worker(
        "/tmp/synthetic",
        "d0f",
        "summarize-r",
        runner = runner,
        timeout_seconds = 7L,
        timeout_program = "timeout"
      )
      NULL
    },
    error = identity
  )
  stopifnot(
    inherits(error, "error"),
    identical(call$command, "timeout"),
    identical(
      call$args[1:4],
      c(
        "--signal=TERM",
        "--kill-after=15s",
        "7",
        file.path(R.home("bin"), "Rscript")
      )
    ),
    grepl("no later worker was launched", conditionMessage(error), fixed = TRUE)
  )
  actions <- character()
  stop_worker <- function(root, stage, action, extra = character()) {
    actions <<- c(actions, action)
    v3s_abort("deliberate bounded-worker stop")
  }
  error <- tryCatch(
    {
      v3s_complete_lifecycle("/tmp/synthetic", "d0f", worker = stop_worker)
      NULL
    },
    error = identity
  )
  stopifnot(
    inherits(error, "error"),
    identical(actions, "summarize-r")
  )
  message("synthetic worker selftest: PASS")
  invisible(TRUE)
}

v3s_orchestrate <- function(args) {
  v3s_validate_deployment(
    v3s_r_root,
    file.path(v3s_r_root, "..", "HSquared.jl")
  )
  workspace <- v3s_option(args, "workspace")
  if (is.null(workspace)) {
    workspace <- tempfile("v3-retry7-synthetic-")
  }
  dir.create(workspace, recursive = TRUE, showWarnings = FALSE)
  workspace <- normalizePath(workspace, winslash = "/", mustWork = TRUE)
  if (length(list.files(workspace, all.files = TRUE, no.. = TRUE))) {
    v3s_abort("synthetic workspace must be empty: %s", workspace)
  }
  d0f_root <- file.path(workspace, "d0f")
  d1_root <- file.path(workspace, "d1")
  d0f_materialized <- v3s_materialize_root(d0f_root, "d0f")
  stopifnot(nrow(d0f_materialized$state$manifest) == 576L)
  d0f <- v3s_complete_lifecycle(d0f_root, "d0f")
  if (
    !identical(d0f$receipt$verdict, "PASS") ||
      !identical(d0f$receipt$stage_decision, "COMPLETE")
  ) {
    v3s_abort("synthetic D0F did not adjudicate PASS/COMPLETE")
  }

  dir.create(d1_root, recursive = TRUE, showWarnings = FALSE)
  d1_root <- normalizePath(d1_root, winslash = "/", mustWork = TRUE)
  v3p_validate_successful_d0f_adjudication(
    d0f$root,
    d0f$receipt_sha256,
    d1_root
  )
  d1_materialized <- v3s_materialize_root(d1_root, "d1", d0f)
  stopifnot(nrow(d1_materialized$state$manifest) == 576L)
  d1 <- v3s_complete_lifecycle(d1_root, "d1")
  if (
    !identical(d1$receipt$verdict, "PASS") ||
      !identical(d1$receipt$stage_decision, "ELIGIBLE=12")
  ) {
    v3s_abort("synthetic D1 did not adjudicate PASS/ELIGIBLE=12")
  }
  message(sprintf(
    paste(
      "recovery-v3 synthetic lifecycle: PASS",
      "workspace=%s",
      "d0f_receipt_sha256=%s",
      "d1_receipt_sha256=%s",
      sep = "\n"
    ),
    workspace,
    d0f$receipt_sha256,
    d1$receipt_sha256
  ))
  invisible(list(workspace = workspace, d0f = d0f, d1 = d1))
}

v3s_main <- function(args = commandArgs(trailingOnly = TRUE)) {
  mode <- v3s_option(args, "mode", "orchestrate")
  if (identical(mode, "worker")) {
    return(v3s_worker(args))
  }
  if (identical(mode, "orchestrate")) {
    return(v3s_orchestrate(args))
  }
  if (identical(mode, "deployment-check")) {
    return(v3s_validate_deployment(
      v3s_required(args, "r-root"),
      v3s_required(args, "julia-root")
    ))
  }
  if (identical(mode, "worker-selftest")) {
    return(v3s_worker_selftest())
  }
  v3s_abort(
    "mode must be worker, orchestrate, deployment-check, or worker-selftest"
  )
}

if (sys.nframe() == 0L) {
  v3s_main()
}
