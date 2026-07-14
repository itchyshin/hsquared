#!/usr/bin/env Rscript

# Create-once adaptive planning for recovery-v3.  The only currently admitted
# transition is a fully validated D1 final tree -> the first deterministic D2
# batch.  Decisions are derived from the canonical D1 summary; callers cannot
# supply eligibility or required-N values.  D2-D4 numerics remain unavailable.

v3a_abort <- function(...) stop(sprintf(...), call. = FALSE)

v3a_script_path <- function() {
  paths <- base::vapply(base::sys.frames(), function(frame) {
    if (base::is.null(frame$ofile)) "" else base::as.character(frame$ofile)
  }, base::character(1L))
  hit <- paths[base::basename(paths) == "v07_genomic_recovery_v3_admission.R"]
  if (base::length(hit)) {
    return(base::normalizePath(
      hit[[base::length(hit)]], winslash = "/", mustWork = TRUE
    ))
  }
  arg <- base::sub(
    "^--file=", "",
    base::grep("^--file=", base::commandArgs(FALSE), value = TRUE)
  )
  if (base::length(arg) == 1L) {
    return(base::normalizePath(
      base::gsub("~+~", " ", arg, fixed = TRUE),
      winslash = "/", mustWork = TRUE
    ))
  }
  v3a_abort("cannot locate admission tool")
}

v3a_loaded_path <- v3a_script_path()
v3a_imports <- base::new.env(parent = base::baseenv())
for (package in base::c("stats", "utils")) {
  for (name in base::getNamespaceExports(package)) {
    base::assign(
      name, base::getExportedValue(package, name), envir = v3a_imports
    )
  }
}
base::lockEnvironment(v3a_imports, bindings = TRUE)
base::lockBinding("v3a_imports", base::environment())
v3a_contract <- base::new.env(parent = v3a_imports)
base::lockBinding("v3a_contract", base::environment())

v3a_load_contract <- function() {
  if (isTRUE(v3a_contract$loaded)) return(invisible(TRUE))
  tool_dir <- dirname(v3a_loaded_path)
  base::source(
    file.path(tool_dir, "v07_genomic_recovery_v3_state_machine.R"),
    local = v3a_contract
  )
  base::source(
    file.path(tool_dir, "v07_genomic_recovery_v3_preseal.R"),
    local = v3a_contract
  )
  v3a_contract$loaded <- TRUE
  base::lockEnvironment(v3a_contract, bindings = TRUE)
  invisible(TRUE)
}

v3a_hex64 <- function(x) {
  length(x) == 1L && !is.na(x) && grepl("^[0-9a-f]{64}$", x)
}

v3a_sha256 <- function(path) {
  if (!file.exists(path) || isTRUE(file.info(path)$isdir) || nzchar(Sys.readlink(path))) {
    v3a_abort("missing, nonregular, or symlinked file: %s", path)
  }
  command <- if (nzchar(Sys.which("shasum"))) "shasum" else "sha256sum"
  if (!nzchar(Sys.which(command))) v3a_abort("no SHA-256 command is available")
  args <- if (command == "shasum") c("-a", "256", shQuote(path)) else shQuote(path)
  out <- base::system2(command, args, stdout = TRUE, stderr = TRUE)
  if (!is.null(attr(out, "status")) || !length(out)) {
    v3a_abort("SHA-256 command failed for %s", path)
  }
  hash <- strsplit(out[[1L]], "[[:space:]]+")[[1L]][[1L]]
  if (!v3a_hex64(hash)) v3a_abort("invalid SHA-256 output for %s", path)
  hash
}

v3a_verify_pair <- function(path) {
  sidecar <- paste0(path, ".sha256")
  if (!file.exists(sidecar) || isTRUE(file.info(sidecar)$isdir) || nzchar(Sys.readlink(sidecar))) {
    v3a_abort("missing, nonregular, or symlinked SHA-256 sidecar: %s", sidecar)
  }
  observed <- v3a_sha256(path)
  line <- readLines(sidecar, warn = FALSE)
  expected <- sprintf("%s  %s", observed, basename(path))
  if (length(line) != 1L || !identical(line, expected)) {
    v3a_abort("SHA-256 sidecar mismatch for %s", path)
  }
  observed
}

v3a_tsv <- function(x) {
  con <- textConnection("text", "w", local = TRUE)
  on.exit(close(con), add = TRUE)
  utils::write.table(x, con, sep = "\t", row.names = FALSE, quote = FALSE, na = "NA")
  paste0(paste(text, collapse = "\n"), "\n")
}

v3a_write_once <- function(root, name, x) {
  v3a_load_contract()
  if (!dir.exists(root) || v3a_contract$v07d_has_symlink_component(root)) {
    v3a_abort("output root must be an existing real directory")
  }
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  path <- file.path(root, name)
  sidecar <- paste0(path, ".sha256")
  if (file.exists(path) || file.exists(sidecar)) {
    v3a_abort("create-once output already exists: %s", path)
  }
  tmp <- tempfile(paste0(".", name, "."), tmpdir = root)
  side_tmp <- tempfile(paste0(".", name, ".sha256."), tmpdir = root)
  primary_created <- FALSE
  sidecar_created <- FALSE
  complete <- FALSE
  on.exit({
    unlink(c(tmp, side_tmp))
    if (!complete) {
      if (sidecar_created) unlink(sidecar)
      if (primary_created) unlink(path)
    }
  }, add = TRUE)
  con <- file(tmp, open = "wb")
  writeChar(v3a_tsv(x), con, eos = NULL, useBytes = TRUE)
  close(con)
  link <- Sys.which("ln")
  if (!nzchar(link)) v3a_abort("POSIX ln is required for create-once claims")
  status <- base::system2(
    link, c(shQuote(tmp), shQuote(path)), stdout = FALSE, stderr = FALSE
  )
  if (status != 0L) v3a_abort("exclusive create-once claim failed: %s", path)
  primary_created <- TRUE
  unlink(tmp)
  hash <- v3a_sha256(path)
  writeLines(sprintf("%s  %s", hash, basename(path)), side_tmp, useBytes = TRUE)
  status <- base::system2(
    link, c(shQuote(side_tmp), shQuote(sidecar)), stdout = FALSE, stderr = FALSE
  )
  if (status != 0L) v3a_abort("exclusive create-once claim failed: %s", sidecar)
  sidecar_created <- TRUE
  unlink(side_tmp)
  observed <- v3a_verify_pair(path)
  complete <- TRUE
  observed
}

v3a_claim_empty_root <- function(root) {
  members <- list.files(root, all.files = TRUE, no.. = TRUE)
  if (length(members)) v3a_abort("D2 plan root must be empty before admission claim")
  claim <- file.path(root, ".v3a-admission-claim")
  tmp <- tempfile(".v3a-admission-claim-", tmpdir = dirname(root))
  on.exit(unlink(tmp), add = TRUE)
  writeLines(sprintf("pid=%s", Sys.getpid()), tmp, useBytes = TRUE)
  link <- Sys.which("ln")
  if (!nzchar(link)) v3a_abort("POSIX ln is required for admission claims")
  status <- base::system2(
    link, c(shQuote(tmp), shQuote(claim)), stdout = FALSE, stderr = FALSE
  )
  if (status != 0L) v3a_abort("exclusive D2 plan-root claim failed")
  unlink(tmp)
  claim
}

v3a_validate_final <- function(root, r_root) {
  recomputer <- file.path(r_root, "tools", "v07_genomic_recovery_v3_recompute.R")
  if (!file.exists(recomputer)) v3a_abort("D1 final-tree validator is unavailable")
  out <- suppressWarnings(base::system2(
    file.path(R.home("bin"), "Rscript"),
    c("--vanilla", shQuote(recomputer), "--mode=validate-final",
      paste0("--output-root=", shQuote(root)), "--stage=d1"),
    stdout = TRUE, stderr = TRUE
  ))
  if (!is.null(attr(out, "status"))) {
    v3a_abort("D1 final-tree validation failed: %s", paste(out, collapse = "\n"))
  }
  invisible(TRUE)
}

v3a_d1_decisions <- function(summary) {
  if (!identical(names(summary), v3a_contract$v3p_d1_summary_columns)) {
    v3a_abort("canonical D1 summary schema or column order drift")
  }
  ids <- unique(summary$cell_id)
  if (length(ids) != 12L || nrow(summary) != 36L) {
    v3a_abort("canonical D1 summary must contain 12 cells and three targets per cell")
  }
  rows <- lapply(ids, function(id) {
    x <- summary[summary$cell_id == id, , drop = FALSE]
    required <- suppressWarnings(as.numeric(x$required_n))
    eligible <- as.character(x$cell_eligible)
    if (nrow(x) != 3L || !setequal(x$target, c("sigma_g2", "sigma_e2", "ratio")) ||
        length(unique(eligible)) != 1L || !unique(eligible) %in% c("TRUE", "FALSE") ||
        length(unique(required)) != 1L || length(unique(x$cell_status)) != 1L) {
      v3a_abort("canonical D1 summary has inconsistent cell decision rows")
    }
    required <- unique(required)
    is_eligible <- identical(unique(eligible), "TRUE")
    status <- unique(as.character(x$cell_status))
    allowed <- c(
      "ELIGIBLE", "FUTILITY_STOP", "PRECISION_BLOCKER",
      "STOP_LOW_PILOT_CONVERGENCE"
    )
    if (!status %in% allowed) {
      v3a_abort("canonical D1 summary has an unknown cell status")
    }
    if (!identical(is_eligible, identical(status, "ELIGIBLE"))) {
      v3a_abort("canonical D1 eligibility and cell status disagree")
    }
    if (is_eligible && (!is.finite(required) || required < 200L || required > 2000L ||
        required != floor(required))) {
      v3a_abort("canonical D1 eligible decision has invalid required-N or status")
    }
    data.frame(
      stage = "d1", cell_id = id, eligible = is_eligible,
      required_n = if (is.finite(required)) required else NA_real_,
      stringsAsFactors = FALSE
    )
  })
  out <- do.call(rbind, rows)
  v3a_contract$v3_validate_decisions(out, "d1")
  out
}

v3a_read_d1_final <- function(root) {
  receipt_path <- file.path(root, "stage_adjudication_receipt.tsv")
  summary_path <- file.path(root, "d1_summary_r.tsv")
  receipt_sha <- v3a_verify_pair(receipt_path)
  summary_sha <- v3a_verify_pair(summary_path)
  receipt <- utils::read.delim(
    receipt_path, sep = "\t", check.names = FALSE, stringsAsFactors = FALSE
  )
  needed <- c("schema_version", "stage", "verdict", "stage_decision", "r_summary_sha256")
  if (nrow(receipt) != 1L || !all(needed %in% names(receipt)) ||
      receipt$schema_version != "v07-genomic-recovery-v3-adjudication-1" ||
      receipt$stage != "d1" || receipt$verdict != "PASS" ||
      !nzchar(receipt$stage_decision) ||
      !identical(receipt$r_summary_sha256, summary_sha)) {
    v3a_abort("D1 receipt does not bind the canonical PASS summary")
  }
  summary <- utils::read.delim(
    summary_path, sep = "\t", check.names = FALSE, stringsAsFactors = FALSE
  )
  by_cell <- unique(summary[c("cell_id", "cell_status")])
  counts <- table(as.character(by_cell$cell_status))
  counts <- counts[order(names(counts))]
  expected_decision <- paste(
    paste(names(counts), as.integer(counts), sep = "="), collapse = ";"
  )
  if (!identical(receipt$stage_decision, expected_decision)) {
    v3a_abort("D1 receipt stage decision differs from the canonical summary")
  }
  list(
    receipt_sha256 = receipt_sha, summary_sha256 = summary_sha,
    decisions = v3a_d1_decisions(summary)
  )
}

v3a_real_dir <- function(path, label) {
  v3a_load_contract()
  if (!dir.exists(path) || v3a_contract$v07d_has_symlink_component(path)) {
    v3a_abort("%s must be an existing real directory", label)
  }
  normalizePath(path, winslash = "/", mustWork = TRUE)
}

v3a_nested <- function(left, right) {
  identical(left, right) ||
    startsWith(left, paste0(right, "/")) ||
    startsWith(right, paste0(left, "/"))
}

v3a_prepare <- function(root, stage, d1_root) {
  v3a_load_contract()
  if (stage %in% c("d3", "d4")) {
    v3a_abort("D3/D4 remain blocked until canonical D2 summaries and numerics exist")
  }
  if (!identical(stage, "d2")) v3a_abort("adaptive stage must be d2")
  root <- v3a_real_dir(root, "D2 plan root")
  d1_root <- v3a_real_dir(d1_root, "D1 final root")
  r_root <- v3a_real_dir(
    dirname(dirname(v3a_loaded_path)), "deployed R repository root"
  )
  if (v3a_nested(root, d1_root)) {
    v3a_abort("D2 plan root and D1 final root must be distinct and nonnested")
  }
  if (v3a_nested(root, r_root)) {
    v3a_abort("D2 plan root and R repository root must be distinct and nonnested")
  }
  if (length(list.files(root, all.files = TRUE, no.. = TRUE))) {
    v3a_abort("D2 plan root must be empty before adaptive admission")
  }
  claim <- v3a_claim_empty_root(root)
  on.exit(unlink(claim), add = TRUE)
  v3a_validate_final(d1_root, r_root)
  d1 <- v3a_read_d1_final(d1_root)
  v3a_validate_final(d1_root, r_root)
  confirmed <- v3a_read_d1_final(d1_root)
  if (!identical(d1$receipt_sha256, confirmed$receipt_sha256) ||
      !identical(d1$summary_sha256, confirmed$summary_sha256) ||
      !identical(d1$decisions, confirmed$decisions)) {
    v3a_abort("D1 evidence changed during adaptive admission")
  }
  if (!identical(list.files(root, all.files = TRUE, no.. = TRUE), basename(claim))) {
    v3a_abort("D2 plan root changed during predecessor validation")
  }
  empty_d2 <- data.frame(
    stage = character(), cell_id = character(), eligible = logical(), required_n = integer()
  )
  cells <- v3a_contract$v3_d2_next_cells(d1$decisions, empty_d2)
  if (!nrow(cells)) v3a_abort("canonical D1 decisions admit no D2 batch")
  manifest <- v3a_contract$v3_manifest("d2", cells)
  if (length(intersect(manifest$seed, v3a_contract$v3_d1_manifest()$seed))) {
    v3a_abort("D2 manifest seed space overlaps D1")
  }
  outputs <- file.path(root, c(
    "d2_manifest.tsv", "d2_manifest.tsv.sha256",
    "adaptive_admission.tsv", "adaptive_admission.tsv.sha256"
  ))
  if (any(file.exists(outputs))) v3a_abort("adaptive output root is not create-once empty")
  created <- character()
  complete <- FALSE
  on.exit(if (!complete) unlink(created), add = TRUE)
  manifest_sha <- v3a_write_once(root, "d2_manifest.tsv", manifest)
  created <- c(created, outputs[1:2])
  admission <- data.frame(
    key = c(
      "schema_version", "stage", "numerics_executable",
      "predecessor_final_validated", "d1_root", "d1_receipt_sha256",
      "d1_summary_sha256", "state_machine_sha256", "manifest_sha256",
      "n_manifest_rows", "n_manifest_cells"
    ),
    value = c(
      "v07-genomic-recovery-v3-admission-2", "d2", "FALSE", "TRUE", d1_root,
      d1$receipt_sha256, d1$summary_sha256,
      v3a_sha256(file.path(dirname(v3a_loaded_path), "v07_genomic_recovery_v3_state_machine.R")),
      manifest_sha, nrow(manifest), length(unique(manifest$cell_id))
    ),
    stringsAsFactors = FALSE
  )
  v3a_write_once(root, "adaptive_admission.tsv", admission)
  created <- c(created, outputs[3:4])
  unlink(claim)
  expected <- sort(basename(outputs))
  observed <- sort(list.files(root, all.files = TRUE, no.. = TRUE))
  if (!identical(observed, expected)) {
    v3a_abort("adaptive output root contains missing or additional members")
  }
  complete <- TRUE
  invisible(list(manifest = manifest, admission = admission, decisions = d1$decisions))
}

v3a_option <- function(args, key, required = FALSE, default = NULL) {
  prefix <- paste0("--", key, "=")
  hit <- args[startsWith(args, prefix)]
  if (length(hit) > 1L) v3a_abort("option --%s occurs more than once", key)
  if (!length(hit)) {
    if (required) v3a_abort("--%s is required", key)
    return(default)
  }
  sub(prefix, "", hit[[1L]], fixed = TRUE)
}

v3a_selftest <- function() {
  v3a_load_contract()
  suppressMessages(v3a_contract$v3_selftest())
  stopifnot(
    v3a_nested("/tmp/a/child", "/tmp/a"),
    v3a_nested("/tmp/a", "/tmp/a/child"),
    !v3a_nested("/tmp/a", "/tmp/ab")
  )
  candidate <- tempfile("v3a-selftest-")
  root <- file.path(
    normalizePath(dirname(candidate), winslash = "/"), basename(candidate)
  )
  dir.create(root)
  on.exit(unlink(root, recursive = TRUE), add = TRUE)
  object <- data.frame(key = "schema", value = "selftest")
  first <- v3a_write_once(root, "member.tsv", object)
  stopifnot(v3a_hex64(first), identical(v3a_verify_pair(
    file.path(root, "member.tsv")
  ), first))
  duplicate <- try(v3a_write_once(root, "member.tsv", object), silent = TRUE)
  stopifnot(inherits(duplicate, "try-error"))
  invisible(TRUE)
}

v3a_main <- function(args = commandArgs(trailingOnly = TRUE)) {
  v3a_verify_pair(v3a_loaded_path)
  v3a_load_contract()
  mode <- v3a_option(args, "mode", default = "selftest")
  if (mode == "selftest") return(v3a_selftest())
  if (mode != "prepare") v3a_abort("unknown mode: %s", mode)
  v3a_prepare(
    v3a_option(args, "output-root", TRUE), v3a_option(args, "stage", TRUE),
    v3a_option(args, "d1-root", TRUE)
  )
}

v3a_module_names <- base::c(
  "v3a_loaded_path", "v3a_imports", "v3a_contract", "v3a_abort", "v3a_script_path",
  "v3a_load_contract", "v3a_hex64", "v3a_sha256", "v3a_verify_pair",
  "v3a_tsv", "v3a_write_once", "v3a_claim_empty_root",
  "v3a_validate_final", "v3a_d1_decisions", "v3a_read_d1_final",
  "v3a_real_dir", "v3a_nested", "v3a_prepare", "v3a_option",
  "v3a_selftest", "v3a_main"
)
v3a_module_env <- base::new.env(parent = base::baseenv())
for (name in v3a_module_names) {
  value <- base::get(name, envir = base::environment(), inherits = FALSE)
  if (base::is.function(value)) base::environment(value) <- v3a_module_env
  base::assign(name, value, envir = v3a_module_env)
}
base::lockEnvironment(v3a_module_env, bindings = TRUE)
for (name in v3a_module_names) {
  if (base::is.function(v3a_module_env[[name]])) {
    base::assign(name, v3a_module_env[[name]], envir = base::environment())
  }
  if (!base::bindingIsLocked(name, base::environment())) {
    base::lockBinding(name, base::environment())
  }
}
base::lockBinding("v3a_module_names", base::environment())
base::lockBinding("v3a_module_env", base::environment())

v3a_module_env$v3a_load_contract()
if (base::sys.nframe() == 0L) v3a_module_env$v3a_main()
