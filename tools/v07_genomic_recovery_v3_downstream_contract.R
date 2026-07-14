#!/usr/bin/env Rscript

# Pure recovery-v3 D2-D4 downstream contract.  This file performs no fitting,
# RNG, seed consumption, filesystem writes, or campaign admission.  It derives
# decisions only from canonical summaries and exposes deterministic validators,
# locks, manifests, summaries, and parity checks for later operational tools.

v3c_abort <- function(...) stop(sprintf(...), call. = FALSE)

v3c_script_path <- function() {
  paths <- vapply(sys.frames(), function(frame) {
    if (is.null(frame$ofile)) "" else as.character(frame$ofile)
  }, character(1L))
  hit <- paths[basename(paths) == "v07_genomic_recovery_v3_downstream_contract.R"]
  if (length(hit)) return(normalizePath(tail(hit, 1L), winslash = "/", mustWork = TRUE))
  arg <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  if (length(arg) == 1L) {
    return(normalizePath(
      gsub("~+~", " ", arg, fixed = TRUE), winslash = "/", mustWork = TRUE
    ))
  }
  v3c_abort("cannot locate downstream contract tool")
}

v3c_loaded_path <- v3c_script_path()
v3c_imports <- base::new.env(parent = base::baseenv())
for (package in base::c("stats", "utils")) {
  for (name in base::getNamespaceExports(package)) {
    base::assign(name, base::getExportedValue(package, name), envir = v3c_imports)
  }
}
base::lockEnvironment(v3c_imports, bindings = TRUE)
v3c_contract <- base::new.env(parent = v3c_imports)

v3c_load_dependencies <- function() {
  if (base::isTRUE(v3c_contract$loaded)) return(base::invisible(TRUE))
  root <- dirname(v3c_loaded_path)
  base::source(
    file.path(root, "v07_genomic_recovery_v3_state_machine.R"), local = v3c_contract
  )
  base::source(
    file.path(root, "v07_genomic_recovery_v3_preseal.R"), local = v3c_contract
  )
  v3c_contract$loaded <- TRUE
  base::lockEnvironment(v3c_contract, bindings = TRUE)
  invisible(TRUE)
}

v3c_load_dependencies()
v3_cell_table <- v3c_contract$v3_cell_table
v3_manifest <- v3c_contract$v3_manifest
v3_d1_manifest <- v3c_contract$v3_d1_manifest
v3_d2_next_cells <- v3c_contract$v3_d2_next_cells
v3_d3_manifest <- v3c_contract$v3_d3_manifest
v3_d4_manifest <- v3c_contract$v3_d4_manifest
v3_validate_decisions <- v3c_contract$v3_validate_decisions
v3p_d1_summary_columns <- v3c_contract$v3p_d1_summary_columns
v3_original_pairs <- v3c_contract$v3_original_pairs
v3_ratio_levels <- v3c_contract$v3_ratio_levels
v3_decision <- v3c_contract$v3_decision

v3c_manifest_columns <- c(
  "stage", "cell_id", "cell_index", "seed_offset", "seed", "n", "m",
  "marker_ratio", "marker_ratio_code", "truth_sigma_g2", "truth_sigma_e2",
  "truth_ratio", "ridge"
)

v3c_attempt_columns <- c(
  v3c_manifest_columns, "retained_m", "marker_hash", "id_hash", "kernel_hash",
  "precision_hash", v3c_contract$v3p_result_columns,
  "manifest_sha256", "corpus_lock_sha256"
)

v3c_pilot_summary_columns <- v3p_d1_summary_columns

v3c_confirmation_summary_columns <- c(
  "stage", "cell_id", "cell_index", "n", "m", "marker_ratio", "truth_ratio",
  "n_expected", "n_attempted", "n_converged", "n_bias_rows", "n_interior",
  "n_interior_rescued", "n_boundary_lower", "n_boundary_upper", "n_unresolved",
  "n_error", "convergence_rate",
  "wilson_lower", "wilson_upper", "target", "truth", "mean_estimate", "bias",
  "mcse", "bias_ci_lower", "bias_ci_upper", "margin", "rmse", "mcse_rmse",
  "empirical_sd", "summary_nonfinite",
  "target_bias_pass", "cell_convergence_pass", "cell_wilson_pass", "target_pass",
  "cell_pass", "cell_status", "median_runtime_seconds", "p95_runtime_seconds",
  "median_peak_rss_mb", "p95_peak_rss_mb", "rms_se_info",
  "empirical_sd_over_rms_se_info", "observed_boundary_lower",
  "observed_boundary_upper", "mcse_boundary_lower", "mcse_boundary_upper",
  "mean_spectral_cv", "mean_effective_rank", "triplet_id", "triplet_pass",
  "campaign_pass", "stage_decision", "failure_classes"
)

v3c_predecessor_lock_columns <- c(
  "stage", "sequence_index", "role", "source_stage", "source_batch",
  "source_root", "adjudication_receipt_sha256", "preseal_sha256",
  "manifest_sha256", "corpus_lock_sha256", "r_summary_sha256",
  "julia_summary_sha256", "r_validator_sha256", "julia_validator_sha256"
)

v3c_pilot_decision_lock_columns <- c(
  "stage", "sequence_index", "source_stage", "source_batch", "selection_role",
  "cell_id", "eligible", "required_n", "required_n_source_target",
  "source_summary_sha256"
)

v3c_hex64 <- function(x) {
  length(x) == 1L && !is.na(x) && grepl("^[0-9a-f]{64}$", x)
}

v3c_require_schema <- function(x, columns, label) {
  if (!is.data.frame(x) || !identical(names(x), columns)) {
    v3c_abort("%s schema or column order drift", label)
  }
  invisible(x)
}

v3c_plain_table <- function(x) {
  out <- as.data.frame(lapply(x, unname), check.names = FALSE, stringsAsFactors = FALSE)
  names(out) <- names(x); rownames(out) <- NULL
  out
}

v3c_table_exact <- function(x, y) {
  if (!identical(names(x), names(y)) || nrow(x) != nrow(y)) return(FALSE)
  all(vapply(names(x), function(field) {
    a <- unname(x[[field]]); b <- unname(y[[field]])
    if (is.numeric(a) && is.numeric(b)) {
      identical(is.na(a), is.na(b)) && identical(is.infinite(a), is.infinite(b)) &&
        all(abs(a[is.finite(a)] - b[is.finite(b)]) <= 1e-12)
    } else identical(a, b)
  }, logical(1L)))
}

v3c_bool <- function(x, label) {
  if (!is.logical(x) || anyNA(x)) v3c_abort("%s must be nonmissing logical", label)
  x
}

v3c_stage <- function(stage) {
  if (length(stage) != 1L || !stage %in% c("d2", "d3", "d4")) {
    v3c_abort("stage must be d2, d3, or d4")
  }
  stage
}

v3c_margin <- function(target, truth) {
  ifelse(target == "ratio", 0.02, 0.05 * truth)
}

v3c_wilson <- function(k, n) {
  if (!n) return(c(lower = NA_real_, upper = NA_real_))
  z <- stats::qnorm(0.975)
  p <- k / n
  denom <- 1 + z^2 / n
  center <- (p + z^2 / (2 * n)) / denom
  half <- z * sqrt(p * (1 - p) / n + z^2 / (4 * n^2)) / denom
  c(lower = center - half, upper = center + half)
}

v3c_metrics <- function(estimate, truth, margin, sizing = FALSE) {
  if (length(estimate) < 2L || any(!is.finite(estimate))) {
    return(c(
      mean_estimate = NA_real_, bias = NA_real_, mcse = NA_real_,
      bias_ci_lower = NA_real_, bias_ci_upper = NA_real_,
      empirical_sd = NA_real_, rmse = NA_real_, mcse_rmse = NA_real_,
      pilot_sd_upper = NA_real_, required_n_raw = NA_real_, target_futile = NA_real_
    ))
  }
  error <- estimate - truth
  empirical_sd <- stats::sd(estimate)
  mcse <- empirical_sd / sqrt(length(estimate))
  tcrit <- stats::qt(0.975, length(estimate) - 1L)
  squared <- error^2
  rmse <- sqrt(mean(squared))
  mcse_rmse <- if (rmse == 0) {
    if (all(squared == 0)) 0 else NA_real_
  } else {
    stats::sd(squared) / (2 * rmse * sqrt(length(estimate)))
  }
  sd_upper <- empirical_sd * sqrt(
    (length(estimate) - 1) / stats::qchisq(0.05, length(estimate) - 1)
  )
  lower <- mean(error) - tcrit * mcse
  upper <- mean(error) + tcrit * mcse
  required <- if (sizing) ceiling((1.96 * sd_upper / (margin / 2))^2) else NA_real_
  c(
    mean_estimate = mean(estimate), bias = mean(error), mcse = mcse,
    bias_ci_lower = lower, bias_ci_upper = upper, empirical_sd = empirical_sd,
    rmse = rmse, mcse_rmse = mcse_rmse, pilot_sd_upper = sd_upper,
    required_n_raw = required,
    target_futile = if (sizing) as.numeric(lower >= margin || upper <= -margin) else NA_real_
  )
}

v3c_validate_manifest <- function(manifest, stage = unique(manifest$stage)) {
  stage <- v3c_stage(stage)
  v3c_require_schema(manifest, v3c_manifest_columns, "downstream manifest")
  if (!nrow(manifest) || any(manifest$stage != stage) || anyDuplicated(manifest$seed)) {
    v3c_abort("downstream manifest stage or seed membership drift")
  }
  observed_ids <- unique(manifest$cell_id)
  if (!all(observed_ids %in% v3_cell_table$cell_id)) {
    v3c_abort("downstream manifest contains unknown or duplicated cells")
  }
  cells <- v3_cell_table[v3_cell_table$cell_id %in% observed_ids, , drop = FALSE]
  counts <- table(manifest$cell_id)
  if (stage == "d2" && any(counts != 48L)) {
    v3c_abort("D2 manifest must contain exactly 48 attempts per cell")
  }
  if (stage %in% c("d3", "d4") && any(counts < 200L | counts > 2000L)) {
    v3c_abort("confirmation manifest counts must be inside 200:2000")
  }
  if (stage %in% c("d3", "d4")) {
    selected <- unique(manifest[c("cell_id", "n", "m", "truth_ratio")])
    triplet_key <- paste(selected$n, selected$m, sep = "\r")
    if (nrow(selected) != 9L || length(unique(triplet_key)) != 3L ||
        any(vapply(split(selected$truth_ratio, triplet_key), function(x) {
          !identical(sort(as.numeric(x)), c(0.2, 0.5, 0.8))
        }, logical(1L)))) {
      v3c_abort("D3/D4 manifest must contain exactly three complete truth triplets")
    }
    if (stage == "d4") {
      observed_pairs <- unique(selected[c("n", "m")])
      observed_pairs <- observed_pairs[order(observed_pairs$n, observed_pairs$m), , drop = FALSE]
      expected_pairs <- v3_original_pairs[order(v3_original_pairs$n, v3_original_pairs$m), , drop = FALSE]
      rownames(observed_pairs) <- rownames(expected_pairs) <- NULL
      if (!identical(observed_pairs, expected_pairs)) {
        v3c_abort("D4 manifest does not contain the exact original-cell campaign")
      }
    }
  }
  expected <- v3_manifest(
    stage, cells,
    if (stage %in% c("d3", "d4")) setNames(as.integer(counts[cells$cell_id]), cells$cell_id)
  )
  if (!v3c_table_exact(manifest, expected)) {
    v3c_abort("downstream manifest differs from canonical state-machine rows or order")
  }
  manifest
}

v3c_validate_attempts <- function(manifest, attempts, binding) {
  manifest <- v3c_validate_manifest(manifest)
  v3c_require_schema(attempts, v3c_attempt_columns, "downstream attempts")
  if (!is.list(binding) ||
      !identical(names(binding), v3c_contract$v3p_attempt_binding_names)) {
    v3c_abort("attempt binding schema or digest drift")
  }
  key <- paste(attempts$stage, attempts$cell_id, attempts$seed, sep = "\r")
  mkey <- paste(manifest$stage, manifest$cell_id, manifest$seed, sep = "\r")
  if (nrow(attempts) != nrow(manifest) || anyDuplicated(key) || !setequal(key, mkey)) {
    v3c_abort("attempts do not equal the exact manifest denominator")
  }
  attempts <- attempts[match(mkey, key), , drop = FALSE]
  rownames(attempts) <- NULL
  for (field in v3c_manifest_columns) {
    if (!identical(attempts[[field]], manifest[[field]])) {
      v3c_abort("attempt/manifest mismatch in %s", field)
    }
  }
  hashes <- c("marker_hash", "id_hash", "kernel_hash", "precision_hash")
  if (any(attempts$retained_m < 1L | attempts$retained_m > attempts$m) ||
      any(!vapply(unlist(attempts[hashes]), v3c_hex64, logical(1L))) ||
      any(attempts$manifest_sha256 != binding$manifest_sha256) ||
      any(attempts$corpus_lock_sha256 != binding$corpus_lock_sha256)) {
    v3c_abort("attempt construction or corpus provenance drift")
  }
  v3c_contract$v3p_validate_results(
    attempts, manifest, v3c_manifest_columns, toupper(unique(manifest$stage)),
    binding, "ordinary_auto_genomic"
  )
}

v3c_failure_classes <- function(x) {
  tab <- table(as.character(x), useNA = "ifany")
  tab <- tab[order(names(tab))]
  paste(paste(names(tab), as.integer(tab), sep = "="), collapse = ";")
}

v3c_cell_counts <- function(x) {
  good <- x$converged
  finite <- good & is.finite(x$scientific_sigma_g2) &
    is.finite(x$scientific_sigma_e2) & is.finite(x$scientific_ratio) &
    is.finite(x$se_info_r050)
  resolved <- c(
    lower = sum(good & x$boundary_status == "boundary_lower"),
    upper = sum(good & x$boundary_status == "boundary_upper"),
    interior = sum(good & x$boundary_status == "interior"),
    interior_rescued = sum(good & x$boundary_status == "interior_rescued")
  )
  unresolved <- sum(!good & !is.na(x$boundary_status) &
    x$boundary_status == "boundary_unresolved")
  error <- sum(!good) - unresolved
  if (sum(resolved) + unresolved + error != nrow(x)) {
    v3c_abort("attempt outcome counts do not equal the denominator")
  }
  list(finite = finite, resolved = resolved, unresolved = unresolved, error = error)
}

v3c_validate_summary_identity <- function(x, id, edge_only = FALSE) {
  cell <- v3_cell_table[v3_cell_table$cell_id == id, , drop = FALSE]
  if (nrow(cell) != 1L || (edge_only && !cell$truth_ratio %in% c(0.2, 0.8))) {
    v3c_abort("summary contains an unknown or inadmissible cell")
  }
  exact <- c("cell_index", "n", "m")
  numeric <- c("marker_ratio", "truth_ratio")
  if (any(vapply(exact, function(field) {
      any(as.numeric(x[[field]]) != as.numeric(cell[[field]]))
    }, logical(1L))) || any(vapply(numeric, function(field) {
      any(abs(as.numeric(x[[field]]) - as.numeric(cell[[field]])) > 1e-12)
    }, logical(1L)))) {
    v3c_abort("summary cell identity differs from the frozen cell table")
  }
  truth <- c(
    sigma_g2 = cell$truth_sigma_g2[[1L]], sigma_e2 = cell$truth_sigma_e2[[1L]],
    ratio = cell$truth_ratio[[1L]]
  )[x$target]
  margin <- v3c_margin(x$target, truth)
  if (anyNA(truth) || any(abs(x$truth - truth) > 1e-12) ||
      any(abs(x$margin - margin) > 1e-12)) {
    v3c_abort("summary truth or margin differs from the frozen target contract")
  }
  invisible(TRUE)
}

v3c_summary_nonfinite_expected <- function(x, pilot = TRUE) {
  target_fields <- c(
    "mean_estimate", "bias", "mcse", "bias_ci_lower", "bias_ci_upper",
    "rmse", "mcse_rmse", "empirical_sd"
  )
  if (pilot) target_fields <- c(target_fields, "pilot_sd_upper", "required_n_raw")
  diagnostic_fields <- c(
    "median_runtime_seconds", "p95_runtime_seconds", "median_peak_rss_mb",
    "p95_peak_rss_mb", "rms_se_info", "empirical_sd_over_rms_se_info",
    if (pilot) c("predicted_boundary_lower", "predicted_boundary_upper") else character(),
    "observed_boundary_lower", "observed_boundary_upper", "mcse_boundary_lower",
    "mcse_boundary_upper", "mean_spectral_cv", "mean_effective_rank"
  )
  any(!is.finite(unlist(x[c(target_fields, diagnostic_fields)], use.names = FALSE)))
}

v3c_validate_pilot_summary <- function(summary, manifest = NULL) {
  v3c_require_schema(summary, v3c_pilot_summary_columns, "canonical D2 summary")
  if (!nrow(summary) || any(summary$stage != "d2") || anyDuplicated(
      paste(summary$cell_id, summary$target, sep = "\r"))) {
    v3c_abort("canonical D2 summary membership drift")
  }
  for (field in c(
    "low_convergence", "summary_nonfinite", "precision_blocked",
    "futility_stopped", "target_futile", "cell_eligible"
  )) v3c_bool(summary[[field]], field)
  if (!is.null(manifest)) {
    manifest <- v3c_validate_manifest(manifest, "d2")
    if (!setequal(unique(summary$cell_id), unique(manifest$cell_id))) {
      v3c_abort("D2 summary cells differ from manifest")
    }
  }
  for (id in unique(summary$cell_id)) {
    x <- summary[summary$cell_id == id, , drop = FALSE]
    v3c_validate_summary_identity(x, id, edge_only = TRUE)
    if (nrow(x) != 3L || !setequal(x$target, c("sigma_g2", "sigma_e2", "ratio")) ||
        any(x$n_expected != 48L) || any(x$n_attempted != 48L) ||
        length(unique(x$required_n)) != 1L || length(unique(x$cell_status)) != 1L ||
        length(unique(x$cell_eligible)) != 1L ||
        any(vapply(x[c(
          "low_convergence", "summary_nonfinite", "precision_blocked", "futility_stopped"
        )], function(z) length(unique(z)) != 1L, logical(1L))) ||
        any(x$n_converged + x$n_unresolved + x$n_error != 48L)) {
      v3c_abort("canonical D2 summary cell rows are inconsistent")
    }
    low_expected <- unique(x$n_converged) < 46L
    required_raw <- suppressWarnings(as.numeric(x$required_n_raw))
    required_expected <- if (all(is.finite(required_raw))) {
      max(200, max(required_raw))
    } else Inf
    precision_expected <- is.finite(required_expected) && required_expected > 2000L
    target_futile <- x$bias_ci_lower >= x$margin | x$bias_ci_upper <= -x$margin
    target_futile[is.na(target_futile)] <- FALSE
    futility_expected <- any(target_futile)
    nonfinite_expected <- v3c_summary_nonfinite_expected(x, pilot = TRUE)
    if (unique(x$low_convergence) != low_expected ||
        unique(x$summary_nonfinite) != nonfinite_expected ||
        any(x$target_futile != target_futile) ||
        unique(x$precision_blocked) != precision_expected ||
        unique(x$futility_stopped) != futility_expected ||
        !(isTRUE(all.equal(unique(x$required_n), required_expected)))) {
      v3c_abort("D2 sizing or reason fields differ from canonical calculations")
    }
    status <- unique(x$cell_status)
    expected <- if (unique(x$low_convergence)) "STOP_LOW_PILOT_CONVERGENCE" else if (
      unique(x$precision_blocked)) "PRECISION_BLOCKER" else if (
      unique(x$futility_stopped)) "FUTILITY_STOP" else "ELIGIBLE"
    if (status != expected || unique(x$cell_eligible) != (status == "ELIGIBLE")) {
      v3c_abort("D2 status precedence or eligibility drift")
    }
  }
  invisible(summary)
}

v3c_validate_d1_summary <- function(summary) {
  v3c_require_schema(summary, v3p_d1_summary_columns, "canonical D1 summary")
  expected_ids <- v3_cell_table$cell_id[v3_cell_table$truth_ratio == 0.5]
  if (nrow(summary) != 36L || !setequal(unique(summary$cell_id), expected_ids) ||
      any(summary$stage != "d1") || anyDuplicated(
        paste(summary$cell_id, summary$target, sep = "\r"))) {
    v3c_abort("canonical D1 summary membership drift")
  }
  for (field in c(
    "low_convergence", "summary_nonfinite", "precision_blocked",
    "futility_stopped", "target_futile", "cell_eligible"
  )) v3c_bool(summary[[field]], field)
  for (id in unique(summary$cell_id)) {
    x <- summary[summary$cell_id == id, , drop = FALSE]
    v3c_validate_summary_identity(x, id)
    if (nrow(x) != 3L || !setequal(x$target, c("sigma_g2", "sigma_e2", "ratio")) ||
        any(x$n_expected != 48L) || any(x$n_attempted != 48L) ||
        length(unique(x$required_n)) != 1L || length(unique(x$cell_status)) != 1L ||
        length(unique(x$cell_eligible)) != 1L ||
        any(vapply(x[c(
          "low_convergence", "summary_nonfinite", "precision_blocked", "futility_stopped"
        )], function(z) length(unique(z)) != 1L, logical(1L))) ||
        any(x$n_converged + x$n_unresolved + x$n_error != 48L)) {
      v3c_abort("canonical D1 summary cell rows are inconsistent")
    }
    required_raw <- suppressWarnings(as.numeric(x$required_n_raw))
    required_expected <- if (all(is.finite(required_raw))) {
      max(200, max(required_raw))
    } else Inf
    low_expected <- unique(x$n_converged) < 46L
    precision_expected <- is.finite(required_expected) && required_expected > 2000L
    target_futile <- x$bias_ci_lower >= x$margin | x$bias_ci_upper <= -x$margin
    target_futile[is.na(target_futile)] <- FALSE
    futility_expected <- any(target_futile)
    nonfinite_expected <- v3c_summary_nonfinite_expected(x, pilot = TRUE)
    status <- if (low_expected) "STOP_LOW_PILOT_CONVERGENCE" else if (
      precision_expected) "PRECISION_BLOCKER" else if (
      futility_expected) "FUTILITY_STOP" else "ELIGIBLE"
    if (unique(x$low_convergence) != low_expected ||
        unique(x$summary_nonfinite) != nonfinite_expected ||
        any(x$target_futile != target_futile) ||
        unique(x$precision_blocked) != precision_expected ||
        unique(x$futility_stopped) != futility_expected ||
        !(isTRUE(all.equal(unique(x$required_n), required_expected))) ||
        unique(x$cell_status) != status || unique(x$cell_eligible) != (status == "ELIGIBLE")) {
      v3c_abort("D1 sizing, status, or reason fields differ from canonical calculations")
    }
  }
  invisible(summary)
}

v3c_validate_confirmation_summary <- function(summary, manifest = NULL) {
  v3c_require_schema(
    summary, v3c_confirmation_summary_columns, "canonical confirmation summary"
  )
  stage <- unique(summary$stage)
  if (length(stage) != 1L || !stage %in% c("d3", "d4") || anyDuplicated(
      paste(summary$cell_id, summary$target, sep = "\r"))) {
    v3c_abort("confirmation summary stage or membership drift")
  }
  for (field in c(
    "summary_nonfinite",
    "target_bias_pass", "cell_convergence_pass", "cell_wilson_pass",
    "target_pass", "cell_pass", "triplet_pass", "campaign_pass"
  )) v3c_bool(summary[[field]], field)
  if (!is.null(manifest)) {
    manifest <- v3c_validate_manifest(manifest, stage)
    if (!setequal(unique(summary$cell_id), unique(manifest$cell_id))) {
      v3c_abort("confirmation summary cells differ from manifest")
    }
  }
  for (id in unique(summary$cell_id)) {
    x <- summary[summary$cell_id == id, , drop = FALSE]
    v3c_validate_summary_identity(x, id)
    expected_triplet_id <- sprintf("n%04d_m%04d", unique(x$n), unique(x$m))
    if (nrow(x) != 3L || !setequal(x$target, c("sigma_g2", "sigma_e2", "ratio")) ||
        length(expected_triplet_id) != 1L || any(x$triplet_id != expected_triplet_id) ||
        any(x$n_attempted != x$n_expected) || length(unique(x$cell_status)) != 1L ||
        length(unique(x$cell_pass)) != 1L ||
        length(unique(x$summary_nonfinite)) != 1L ||
        length(unique(x$convergence_rate)) != 1L || length(unique(x$wilson_lower)) != 1L) {
      v3c_abort("confirmation summary cell rows are inconsistent")
    }
    bias_pass <- is.finite(x$bias_ci_lower) & is.finite(x$bias_ci_upper) &
      x$bias_ci_lower > -x$margin & x$bias_ci_upper < x$margin
    convergence_pass <- unique(x$convergence_rate) >= 0.95
    wilson_pass <- unique(x$wilson_lower) >= 0.90
    expected_wilson <- v3c_wilson(unique(x$n_converged), unique(x$n_expected))
    if (any(x$n_converged + x$n_unresolved + x$n_error != x$n_expected) ||
        any(abs(x$convergence_rate - x$n_converged / x$n_expected) > 1e-12) ||
        any(abs(x$wilson_lower - expected_wilson[[1L]]) > 1e-12) ||
        any(abs(x$wilson_upper - expected_wilson[[2L]]) > 1e-12)) {
      v3c_abort("confirmation denominator or Wilson calculation drift")
    }
    expected_pass <- all(bias_pass) && convergence_pass && wilson_pass
    nonfinite_expected <- v3c_summary_nonfinite_expected(x, pilot = FALSE)
    status <- if (!convergence_pass) "FAIL_CONVERGENCE" else if (!wilson_pass) {
      "FAIL_WILSON_LOWER"
    } else if (!all(bias_pass)) "FAIL_BIAS_EQUIVALENCE" else "PASS"
    if (unique(x$summary_nonfinite) != nonfinite_expected ||
        !identical(x$target_bias_pass, bias_pass) ||
        any(x$cell_convergence_pass != convergence_pass) ||
        any(x$cell_wilson_pass != wilson_pass) ||
        any(x$target_pass != (bias_pass & convergence_pass & wilson_pass)) ||
        unique(x$cell_pass) != expected_pass || unique(x$cell_status) != status) {
      v3c_abort("confirmation strict gate or status drift")
    }
  }
  triplet_cells <- unique(summary[c("triplet_id", "cell_id", "truth_ratio")])
  if (length(unique(triplet_cells$triplet_id)) != 3L ||
      any(vapply(split(triplet_cells$truth_ratio, triplet_cells$triplet_id), function(x) {
        !identical(sort(as.numeric(x)), c(0.2, 0.5, 0.8))
      }, logical(1L)))) {
    v3c_abort("confirmation summary does not contain three complete truth triplets")
  }
  triplets <- unique(summary[c("triplet_id", "cell_id", "cell_pass")])
  expected_triplet <- ave(triplets$cell_pass, triplets$triplet_id, FUN = all)
  row_triplet <- expected_triplet[match(
    paste(summary$triplet_id, summary$cell_id, sep = "\r"),
    paste(triplets$triplet_id, triplets$cell_id, sep = "\r")
  )]
  campaign <- all(expected_triplet)
  expected_decision <- if (any(summary$summary_nonfinite)) {
    "RECOMPUTATION_BLOCKER"
  } else if (campaign) paste0(toupper(stage), "_PASS") else paste0(toupper(stage), "_FAIL")
  if (any(summary$triplet_pass != as.logical(row_triplet)) ||
      any(summary$campaign_pass != campaign) ||
      any(summary$stage_decision != expected_decision)) {
    v3c_abort("confirmation triplet, campaign, or stage decision drift")
  }
  invisible(summary)
}

v3c_fixture_d2_summary <- function(manifest, attempts, binding) {
  manifest <- v3c_validate_manifest(manifest, "d2")
  attempts <- v3c_validate_attempts(manifest, attempts, binding)
  rows <- lapply(unique(manifest$cell_id), function(id) {
    m <- manifest[manifest$cell_id == id, , drop = FALSE]
    x <- attempts[attempts$cell_id == id, , drop = FALSE]
    count <- v3c_cell_counts(x)
    nconv <- sum(count$finite)
    wilson <- v3c_wilson(nconv, nrow(x))
    metrics <- list(
      sigma_g2 = v3c_metrics(x$scientific_sigma_g2[count$finite], m$truth_sigma_g2[[1L]],
        0.05 * m$truth_sigma_g2[[1L]], TRUE),
      sigma_e2 = v3c_metrics(x$scientific_sigma_e2[count$finite], m$truth_sigma_e2[[1L]],
        0.05 * m$truth_sigma_e2[[1L]], TRUE),
      ratio = v3c_metrics(x$scientific_ratio[count$finite], m$truth_ratio[[1L]], 0.02, TRUE)
    )
    required_raw <- vapply(metrics, `[[`, numeric(1L), "required_n_raw")
    required <- if (all(is.finite(required_raw))) max(200, max(required_raw)) else Inf
    low <- nconv < 46L
    rms_se <- sqrt(mean(x$se_info_r050[count$finite]^2))
    ratio_sd <- stats::sd(x$scientific_ratio[count$finite])
    predicted_lower <- mean(stats::pnorm(-m$truth_ratio[[1L]] / x$se_info_r050))
    predicted_upper <- mean(
      1 - stats::pnorm((1 - m$truth_ratio[[1L]]) / x$se_info_r050)
    )
    nonfinite <- !(
      all(is.finite(unlist(metrics))) && is.finite(rms_se) &&
        is.finite(ratio_sd) && is.finite(ratio_sd / rms_se) &&
        all(is.finite(x$se_info_r050)) && is.finite(predicted_lower) &&
        is.finite(predicted_upper) && all(is.finite(x$runtime_seconds)) &&
        all(is.finite(x$peak_rss_mb)) && all(is.finite(x$eigen_cv_population)) &&
        all(is.finite(x$effective_rank))
    )
    precision <- is.finite(required) && required > 2000L
    futile <- any(vapply(metrics, `[[`, numeric(1L), "target_futile") == 1, na.rm = TRUE)
    if (!low && nonfinite) v3c_abort("RECOMPUTATION_BLOCKER: nonfinite admitted D2 summary")
    status <- if (low) "STOP_LOW_PILOT_CONVERGENCE" else if (precision) {
      "PRECISION_BLOCKER"
    } else if (futile) "FUTILITY_STOP" else "ELIGIBLE"
    eligible <- status == "ELIGIBLE"
    do.call(rbind, lapply(names(metrics), function(target) {
      z <- metrics[[target]]
      truth <- switch(target, sigma_g2 = m$truth_sigma_g2[[1L]],
        sigma_e2 = m$truth_sigma_e2[[1L]], ratio = m$truth_ratio[[1L]])
      margin <- v3c_margin(target, truth)
      data.frame(
        stage = "d2", cell_id = id, cell_index = m$cell_index[[1L]], n = m$n[[1L]],
        m = m$m[[1L]], marker_ratio = m$marker_ratio[[1L]], truth_ratio = m$truth_ratio[[1L]],
        n_expected = nrow(m), n_attempted = nrow(x), n_converged = nconv,
        n_bias_rows = nconv, n_interior = count$resolved[["interior"]],
        n_interior_rescued = count$resolved[["interior_rescued"]],
        n_boundary_lower = count$resolved[["lower"]],
        n_boundary_upper = count$resolved[["upper"]],
        n_unresolved = count$unresolved, n_error = count$error,
        convergence_rate = nconv / nrow(x), wilson_lower = wilson[[1L]],
        wilson_upper = wilson[[2L]], target = target, truth = truth,
        mean_estimate = z[["mean_estimate"]], bias = z[["bias"]], mcse = z[["mcse"]],
        bias_ci_lower = z[["bias_ci_lower"]], bias_ci_upper = z[["bias_ci_upper"]],
        margin = margin, rmse = z[["rmse"]], mcse_rmse = z[["mcse_rmse"]],
        empirical_sd = z[["empirical_sd"]],
        pilot_sd_upper = z[["pilot_sd_upper"]], required_n_raw = z[["required_n_raw"]],
        required_n = required, low_convergence = low, summary_nonfinite = nonfinite,
        precision_blocked = precision, futility_stopped = futile,
        target_futile = isTRUE(z[["target_futile"]] == 1), cell_eligible = eligible,
        cell_status = status,
        median_runtime_seconds = stats::median(x$runtime_seconds),
        p95_runtime_seconds = unname(stats::quantile(x$runtime_seconds, 0.95)),
        median_peak_rss_mb = stats::median(x$peak_rss_mb),
        p95_peak_rss_mb = unname(stats::quantile(x$peak_rss_mb, 0.95)),
        rms_se_info = rms_se, empirical_sd_over_rms_se_info = ratio_sd / rms_se,
        predicted_boundary_lower = predicted_lower,
        predicted_boundary_upper = predicted_upper,
        observed_boundary_lower = count$resolved[["lower"]] / nrow(x),
        observed_boundary_upper = count$resolved[["upper"]] / nrow(x),
        mcse_boundary_lower = sqrt(
          (count$resolved[["lower"]] / nrow(x)) *
            (1 - count$resolved[["lower"]] / nrow(x)) / nrow(x)
        ),
        mcse_boundary_upper = sqrt(
          (count$resolved[["upper"]] / nrow(x)) *
            (1 - count$resolved[["upper"]] / nrow(x)) / nrow(x)
        ),
        mean_spectral_cv = mean(x$eigen_cv_population),
        mean_effective_rank = mean(x$effective_rank),
        failure_classes = v3c_failure_classes(x$error_class),
        stringsAsFactors = FALSE
      )
    }))
  })
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  out <- out[v3c_pilot_summary_columns]
  v3c_validate_pilot_summary(out, manifest)
  out
}

v3c_fixture_confirmation_summary <- function(manifest, attempts, binding) {
  stage <- unique(manifest$stage)
  if (length(stage) != 1L || !stage %in% c("d3", "d4")) {
    v3c_abort("confirmation summary requires D3 or D4")
  }
  manifest <- v3c_validate_manifest(manifest, stage)
  attempts <- v3c_validate_attempts(manifest, attempts, binding)
  rows <- lapply(unique(manifest$cell_id), function(id) {
    m <- manifest[manifest$cell_id == id, , drop = FALSE]
    x <- attempts[attempts$cell_id == id, , drop = FALSE]
    count <- v3c_cell_counts(x)
    nconv <- sum(count$finite)
    wilson <- v3c_wilson(nconv, nrow(x))
    metrics <- list(
      sigma_g2 = v3c_metrics(x$scientific_sigma_g2[count$finite], m$truth_sigma_g2[[1L]],
        0.05 * m$truth_sigma_g2[[1L]]),
      sigma_e2 = v3c_metrics(x$scientific_sigma_e2[count$finite], m$truth_sigma_e2[[1L]],
        0.05 * m$truth_sigma_e2[[1L]]),
      ratio = v3c_metrics(x$scientific_ratio[count$finite], m$truth_ratio[[1L]], 0.02)
    )
    rms_se <- sqrt(mean(x$se_info_r050[count$finite]^2))
    ratio_sd <- stats::sd(x$scientific_ratio[count$finite])
    summary_nonfinite <- !(
      all(is.finite(unlist(metrics)[!grepl("pilot_sd_upper|required_n_raw|target_futile",
        names(unlist(metrics)))])) && is.finite(rms_se) && is.finite(ratio_sd) &&
        is.finite(ratio_sd / rms_se) && all(is.finite(x$runtime_seconds)) &&
        all(is.finite(x$peak_rss_mb)) && all(is.finite(x$eigen_cv_population)) &&
        all(is.finite(x$effective_rank))
    )
    if (summary_nonfinite) {
      v3c_abort("RECOMPUTATION_BLOCKER: nonfinite admitted confirmation summary")
    }
    convergence_pass <- nconv / nrow(x) >= 0.95
    wilson_pass <- is.finite(wilson[[1L]]) && wilson[[1L]] >= 0.90
    bias_pass <- vapply(names(metrics), function(target) {
      z <- metrics[[target]]
      truth <- switch(target, sigma_g2 = m$truth_sigma_g2[[1L]],
        sigma_e2 = m$truth_sigma_e2[[1L]], ratio = m$truth_ratio[[1L]])
      margin <- v3c_margin(target, truth)
      is.finite(z[["bias_ci_lower"]]) && is.finite(z[["bias_ci_upper"]]) &&
        z[["bias_ci_lower"]] > -margin && z[["bias_ci_upper"]] < margin
    }, logical(1L))
    cell_pass <- convergence_pass && wilson_pass && all(bias_pass)
    status <- if (!convergence_pass) "FAIL_CONVERGENCE" else if (!wilson_pass) {
      "FAIL_WILSON_LOWER"
    } else if (!all(bias_pass)) "FAIL_BIAS_EQUIVALENCE" else "PASS"
    do.call(rbind, lapply(names(metrics), function(target) {
      z <- metrics[[target]]
      truth <- switch(target, sigma_g2 = m$truth_sigma_g2[[1L]],
        sigma_e2 = m$truth_sigma_e2[[1L]], ratio = m$truth_ratio[[1L]])
      margin <- v3c_margin(target, truth)
      data.frame(
        stage = stage, cell_id = id, cell_index = m$cell_index[[1L]], n = m$n[[1L]],
        m = m$m[[1L]], marker_ratio = m$marker_ratio[[1L]], truth_ratio = m$truth_ratio[[1L]],
        n_expected = nrow(m), n_attempted = nrow(x), n_converged = nconv,
        n_bias_rows = nconv, n_interior = count$resolved[["interior"]],
        n_interior_rescued = count$resolved[["interior_rescued"]],
        n_boundary_lower = count$resolved[["lower"]],
        n_boundary_upper = count$resolved[["upper"]], n_unresolved = count$unresolved,
        n_error = count$error, convergence_rate = nconv / nrow(x),
        wilson_lower = wilson[[1L]], wilson_upper = wilson[[2L]], target = target,
        truth = truth, mean_estimate = z[["mean_estimate"]], bias = z[["bias"]],
        mcse = z[["mcse"]], bias_ci_lower = z[["bias_ci_lower"]],
        bias_ci_upper = z[["bias_ci_upper"]], margin = margin, rmse = z[["rmse"]],
        mcse_rmse = z[["mcse_rmse"]], empirical_sd = z[["empirical_sd"]],
        summary_nonfinite = summary_nonfinite,
        target_bias_pass = bias_pass[[target]],
        cell_convergence_pass = convergence_pass, cell_wilson_pass = wilson_pass,
        target_pass = bias_pass[[target]] && convergence_pass && wilson_pass,
        cell_pass = cell_pass, cell_status = status,
        median_runtime_seconds = stats::median(x$runtime_seconds),
        p95_runtime_seconds = unname(stats::quantile(x$runtime_seconds, 0.95)),
        median_peak_rss_mb = stats::median(x$peak_rss_mb),
        p95_peak_rss_mb = unname(stats::quantile(x$peak_rss_mb, 0.95)),
        rms_se_info = rms_se, empirical_sd_over_rms_se_info = ratio_sd / rms_se,
        observed_boundary_lower = count$resolved[["lower"]] / nrow(x),
        observed_boundary_upper = count$resolved[["upper"]] / nrow(x),
        mcse_boundary_lower = sqrt(
          (count$resolved[["lower"]] / nrow(x)) *
            (1 - count$resolved[["lower"]] / nrow(x)) / nrow(x)
        ),
        mcse_boundary_upper = sqrt(
          (count$resolved[["upper"]] / nrow(x)) *
            (1 - count$resolved[["upper"]] / nrow(x)) / nrow(x)
        ),
        mean_spectral_cv = mean(x$eigen_cv_population),
        mean_effective_rank = mean(x$effective_rank),
        triplet_id = sprintf("n%04d_m%04d", m$n[[1L]], m$m[[1L]]),
        triplet_pass = NA, campaign_pass = NA, stage_decision = NA_character_,
        failure_classes = v3c_failure_classes(x$error_class), stringsAsFactors = FALSE
      )
    }))
  })
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  cells <- unique(out[c("triplet_id", "cell_id", "cell_pass")])
  triplet_status <- tapply(cells$cell_pass, cells$triplet_id, all)
  out$triplet_pass <- unname(triplet_status[out$triplet_id])
  out$campaign_pass <- all(triplet_status)
  out$stage_decision <- if (any(out$summary_nonfinite)) {
    "RECOMPUTATION_BLOCKER"
  } else if (all(triplet_status)) paste0(toupper(stage), "_PASS") else {
    paste0(toupper(stage), "_FAIL")
  }
  out <- out[v3c_confirmation_summary_columns]
  v3c_validate_confirmation_summary(out, manifest)
  out
}

v3c_decisions_from_summary <- function(summary, stage) {
  if (stage == "d1") {
    v3c_validate_d1_summary(summary)
  } else if (stage == "d2") {
    v3c_validate_pilot_summary(summary)
  } else {
    v3c_abort("pilot decisions may derive only from D1 or D2 summaries")
  }
  ids <- unique(summary$cell_id)
  rows <- lapply(ids, function(id) {
    x <- summary[summary$cell_id == id, , drop = FALSE]
    eligible <- unique(x$cell_eligible)
    required <- unique(suppressWarnings(as.numeric(x$required_n)))
    if (nrow(x) != 3L || !setequal(x$target, c("sigma_g2", "sigma_e2", "ratio")) ||
        length(eligible) != 1L || !is.logical(eligible) || is.na(eligible) ||
        length(required) != 1L || length(unique(x$cell_status)) != 1L) {
      v3c_abort("canonical %s summary decision rows are inconsistent", toupper(stage))
    }
    if (eligible && (!is.finite(required) || required < 200L || required > 2000L ||
        required != floor(required) || unique(x$cell_status) != "ELIGIBLE")) {
      v3c_abort("canonical eligible decision is internally inconsistent")
    }
    data.frame(
      stage = stage, cell_id = id, eligible = eligible,
      required_n = if (is.finite(required)) required else NA_real_, stringsAsFactors = FALSE
    )
  })
  out <- do.call(rbind, rows)
  v3_validate_decisions(out, stage)
  out
}

v3c_fixture_expected_manifest <- function(stage, d1_summary, d2_summary = NULL) {
  stage <- v3c_stage(stage)
  d1 <- v3c_decisions_from_summary(d1_summary, "d1")
  d2 <- if (is.null(d2_summary)) data.frame(
    stage = character(), cell_id = character(), eligible = logical(), required_n = integer()
  ) else v3c_decisions_from_summary(d2_summary, "d2")
  out <- switch(stage,
    d2 = {
      cells <- v3_d2_next_cells(d1, d2)
      if (!nrow(cells)) v3c_abort("canonical pilot summaries admit no further D2 batch")
      v3_manifest("d2", cells)
    },
    d3 = v3_d3_manifest(d1, d2),
    d4 = v3_d4_manifest(d1, d2)
  )
  v3c_validate_manifest(out, stage)
}

v3c_sha256 <- function(path) {
  path <- normalizePath(path, mustWork = TRUE)
  command <- Sys.which("shasum")
  args <- c("-a", "256", shQuote(path))
  if (!nzchar(command)) {
    command <- Sys.which("sha256sum")
    args <- shQuote(path)
  }
  if (!nzchar(command)) v3c_abort("no SHA-256 command is available")
  output <- system2(command, args, stdout = TRUE, stderr = TRUE)
  if (!length(output) || !v3c_hex64(substr(output[[1L]], 1L, 64L))) {
    v3c_abort("could not compute SHA-256 for %s", path)
  }
  substr(output[[1L]], 1L, 64L)
}

v3c_verify_pair <- function(path, label) {
  if (!file.exists(path) || isTRUE(file.info(path)$isdir)) {
    v3c_abort("%s primary is missing", label)
  }
  sidecar <- paste0(path, ".sha256")
  if (!file.exists(sidecar) || isTRUE(file.info(sidecar)$isdir)) {
    v3c_abort("%s SHA-256 sidecar is missing", label)
  }
  line <- readLines(sidecar, warn = FALSE)
  if (length(line) != 1L) v3c_abort("%s SHA-256 sidecar is malformed", label)
  declared <- strsplit(trimws(line), "[[:space:]]+")[[1L]][[1L]]
  actual <- v3c_sha256(path)
  if (!v3c_hex64(declared) || declared != actual) {
    v3c_abort("%s SHA-256 sidecar does not match bytes", label)
  }
  actual
}

v3c_read_tsv_pair <- function(path, columns = NULL, label = basename(path)) {
  sha <- v3c_verify_pair(path, label)
  table <- utils::read.delim(
    path, sep = "\t", header = TRUE, check.names = FALSE,
    stringsAsFactors = FALSE, na.strings = "NA"
  )
  if (!is.null(columns)) v3c_require_schema(table, columns, label)
  list(table = table, sha256 = sha)
}

v3c_default_validators <- function(stage) {
  repo <- dirname(dirname(v3c_loaded_path))
  sibling <- file.path(dirname(repo), "HSquared.jl")
  if (stage == "d2") {
    v3c_abort(paste(
      "real D2 history authentication is unavailable until dedicated validators land:",
      "tools/v07_genomic_recovery_v3_downstream_recompute.R --mode=validate-final",
      "and HSquared.jl/sim/phase2_v07_genomic_recovery_v3_downstream_replay.jl",
      "--mode=validate-final, each with a SHA-256 sidecar and preseal/receipt binding"
    ))
  }
  paths <- c(
    r_validator = file.path(repo, "tools", "v07_genomic_recovery_v3_recompute.R"),
    julia_validator = file.path(
      sibling, "sim", "phase2_v07_genomic_recovery_v3_stage_replay.jl"
    )
  )
  vapply(paths, normalizePath, character(1L), winslash = "/", mustWork = TRUE)
}

v3c_fixture_validators <- function(stage) {
  if (stage == "d1") return(v3c_default_validators(stage))
  repo <- dirname(dirname(v3c_loaded_path))
  sibling <- file.path(dirname(repo), "HSquared.jl")
  paths <- c(
    r_validator = v3c_loaded_path,
    julia_validator = file.path(
      sibling, "sim", "phase2_v07_genomic_recovery_v3_confirm_replay.jl"
    )
  )
  vapply(paths, normalizePath, character(1L), winslash = "/", mustWork = TRUE)
}

v3c_source <- function(
  root, stage, r_validator = NULL, julia_validator = NULL, independent = TRUE
) {
  expected <- if (independent) v3c_default_validators(stage) else {
    v3c_fixture_validators(stage)
  }
  if (!is.list(root) && length(root) == 1L) {
    root <- list(
      root = root, r_validator = expected[["r_validator"]],
      julia_validator = expected[["julia_validator"]]
    )
  }
  if (!is.list(root) || !identical(names(root), c("root", "r_validator", "julia_validator"))) {
    v3c_abort("evidence source must bind root, R validator, and Julia validator")
  }
  paths <- vapply(root, function(x) {
    if (length(x) != 1L || !is.character(x) || !nzchar(x) || !startsWith(x, "/")) {
      v3c_abort("evidence source paths must be nonempty absolute paths")
    }
    normalizePath(x, mustWork = TRUE)
  }, character(1L))
  if (!isTRUE(file.info(paths[["root"]])$isdir)) v3c_abort("evidence root is not a directory")
  if (!identical(unname(paths[c("r_validator", "julia_validator")]), unname(expected))) {
    v3c_abort("caller-selected validator paths cannot authenticate campaign evidence")
  }
  as.list(paths)
}

v3c_validate_final_d1 <- function(root, validator) {
  command <- file.path(R.home("bin"), "Rscript")
  output <- suppressWarnings(system2(command, c(
    shQuote(validator), "--mode=validate-final",
    shQuote(paste0("--output-root=", root)), "--stage=d1"
  ), stdout = TRUE, stderr = TRUE))
  status <- attr(output, "status")
  if (!is.null(status) && status != 0L) {
    v3c_abort(
      "D1 final tree failed independent frozen-validator reconstruction: %s",
      paste(tail(output, 3L), collapse = " | ")
    )
  }
  invisible(TRUE)
}

v3c_stage_decision_pilot <- function(summary) {
  if ("summary_nonfinite" %in% names(summary) && any(summary$summary_nonfinite)) {
    return("RECOMPUTATION_BLOCKER")
  }
  cells <- unique(summary[c("cell_id", "cell_status")])
  counts <- table(as.character(cells$cell_status))
  counts <- counts[order(names(counts))]
  paste(paste(names(counts), as.integer(counts), sep = "="), collapse = ";")
}

v3c_read_evidence_root_core <- function(source, stage, independent) {
  if (!stage %in% c("d1", "d2")) v3c_abort("pilot evidence stage must be d1 or d2")
  source <- v3c_source(source, stage, independent = independent)
  root <- source$root
  preseal <- v3c_read_tsv_pair(file.path(root, "stage_preseal.tsv"), c("key", "value"),
    paste(toupper(stage), "preseal"))
  manifest <- v3c_read_tsv_pair(file.path(root, paste0(stage, "_manifest.tsv")),
    v3c_manifest_columns, paste(toupper(stage), "manifest"))
  corpus <- v3c_read_tsv_pair(file.path(root, "stage_corpus_lock.tsv"), NULL,
    paste(toupper(stage), "corpus lock"))
  r_summary <- v3c_read_tsv_pair(file.path(root, paste0(stage, "_summary_r.tsv")),
    v3c_pilot_summary_columns, paste(toupper(stage), "R summary"))
  julia_summary <- v3c_read_tsv_pair(file.path(root, paste0(stage, "_summary_julia.tsv")),
    v3c_pilot_summary_columns, paste(toupper(stage), "Julia summary"))
  receipt <- v3c_read_tsv_pair(file.path(root, "stage_adjudication_receipt.tsv"), NULL,
    paste(toupper(stage), "adjudication receipt"))
  r_validator_sha <- v3c_verify_pair(source$r_validator, "R validator")
  julia_validator_sha <- v3c_verify_pair(source$julia_validator, "Julia validator")
  if (stage == "d1") {
    v3c_validate_d1_summary(r_summary$table)
    v3c_validate_d1_summary(julia_summary$table)
    v3c_parity(list(r_summary$table, julia_summary$table), v3c_pilot_summary_columns,
      c("stage", "cell_id", "target"))
    expected_manifest <- v3_d1_manifest()
  } else {
    v3c_validate_pilot_summary(r_summary$table, manifest$table)
    v3c_validate_pilot_summary(julia_summary$table, manifest$table)
    v3c_summary_parity(r_summary$table, julia_summary$table)
    expected_manifest <- NULL
  }
  if (!is.null(expected_manifest)) {
    if (!v3c_table_exact(manifest$table, expected_manifest)) {
      v3c_abort("D1 manifest differs from the exact state-machine manifest")
    }
  }
  p <- preseal$table
  if (anyDuplicated(p$key)) v3c_abort("stage preseal has duplicate keys")
  pv <- setNames(as.character(p$value), as.character(p$key))
  required_preseal <- c("stage", "manifest_sha256", "r_recomputer_sha256",
    "julia_replay_sha256", "r_recomputer_commit", "julia_replay_commit", "output_root")
  frozen_commits <- c(
    r_recomputer_commit = "2cb5308801efcd74ffac9b4b60c44c0356c7c0ea",
    julia_replay_commit = "f7ff83855c4b4d14aad39516f37b7c1b5994b7ae"
  )
  if (!all(required_preseal %in% names(pv)) || pv[["stage"]] != stage ||
      normalizePath(pv[["output_root"]], mustWork = TRUE) != root ||
      pv[["manifest_sha256"]] != manifest$sha256 ||
      pv[["r_recomputer_sha256"]] != r_validator_sha ||
      pv[["julia_replay_sha256"]] != julia_validator_sha ||
      (stage == "d1" && any(pv[names(frozen_commits)] != frozen_commits))) {
    v3c_abort("stage preseal does not bind the exact root, manifest, or validators")
  }
  rr <- receipt$table
  required_receipt <- c(
    "schema_version", "stage", "verdict", "stage_decision", "preseal_sha256",
    "manifest_sha256", "corpus_lock_sha256", "r_summary_sha256",
    "julia_summary_sha256", "r_recomputer_sha256", "julia_replay_sha256",
    "r_recomputer_commit", "julia_replay_commit"
  )
  if (nrow(rr) != 1L || !all(required_receipt %in% names(rr)) ||
      rr$stage[[1L]] != stage || rr$verdict[[1L]] != "PASS" ||
      rr$stage_decision[[1L]] != v3c_stage_decision_pilot(r_summary$table) ||
      rr$preseal_sha256[[1L]] != preseal$sha256 ||
      rr$manifest_sha256[[1L]] != manifest$sha256 ||
      rr$corpus_lock_sha256[[1L]] != corpus$sha256 ||
      rr$r_summary_sha256[[1L]] != r_summary$sha256 ||
      rr$julia_summary_sha256[[1L]] != julia_summary$sha256 ||
      rr$r_recomputer_sha256[[1L]] != r_validator_sha ||
      rr$julia_replay_sha256[[1L]] != julia_validator_sha ||
      (stage == "d1" && any(as.character(rr[1L, names(frozen_commits)]) != frozen_commits))) {
    v3c_abort("adjudication receipt does not bind exact PASS evidence bytes")
  }
  if (stage == "d1" && independent) v3c_validate_final_d1(root, source$r_validator)
  list(
    stage = stage, root = root, preseal_sha256 = preseal$sha256,
    manifest = manifest$table, manifest_sha256 = manifest$sha256,
    corpus_lock_sha256 = corpus$sha256, summary = r_summary$table,
    r_summary_sha256 = r_summary$sha256, julia_summary_sha256 = julia_summary$sha256,
    receipt_sha256 = receipt$sha256, r_validator_sha256 = r_validator_sha,
    julia_validator_sha256 = julia_validator_sha
  )
}

v3c_read_evidence_root <- function(source, stage) {
  v3c_read_evidence_root_core(source, stage, independent = TRUE)
}

v3c_fixture_read_evidence_root <- function(source, stage) {
  v3c_read_evidence_root_core(source, stage, independent = FALSE)
}

v3c_selection_roles <- function(d1, d2, cells) {
  ladder <- character()
  for (ratio in v3_ratio_levels) {
    interiors <- v3_cell_table[
      abs(v3_cell_table$marker_ratio - ratio) < 1e-12 & v3_cell_table$truth_ratio == 0.5,
      , drop = FALSE
    ]
    interiors <- interiors[order(interiors$n), , drop = FALSE]
    eligible_n <- interiors$n[vapply(interiors$cell_id, function(id) {
      z <- v3_decision(d1, id); !is.null(z) && isTRUE(z$eligible)
    }, logical(1L))]
    for (n in eligible_n) {
      edges <- v3_cell_table[
        abs(v3_cell_table$marker_ratio - ratio) < 1e-12 & v3_cell_table$n == n &
          v3_cell_table$truth_ratio %in% c(0.2, 0.8), , drop = FALSE
      ]
      ed <- lapply(edges$cell_id, v3_decision, decisions = d2)
      present <- !vapply(ed, is.null, logical(1L))
      if (!all(present)) { ladder <- c(ladder, edges$cell_id); break }
      if (all(vapply(ed, function(z) isTRUE(z$eligible), logical(1L)))) break
    }
  }
  broad <- unlist(lapply(seq_len(nrow(v3_original_pairs)), function(i) {
    pair <- v3_original_pairs[i, ]
    v3_cell_table$cell_id[v3_cell_table$n == pair$n & v3_cell_table$m == pair$m &
      v3_cell_table$truth_ratio %in% c(0.2, 0.8)]
  }), use.names = FALSE)
  roles <- vapply(cells$cell_id, function(id) {
    hit <- c(if (id %in% ladder) "ladder", if (id %in% broad) "broad")
    if (!length(hit)) v3c_abort("D2 cell has no reconstructed selection role")
    paste(sort(hit), collapse = "+")
  }, character(1L))
  setNames(roles, cells$cell_id)
}

v3c_evidence_history_core <- function(
  stage, d1_source, d2_sources = list(), independent = TRUE
) {
  stage <- v3c_stage(stage)
  if (!is.list(d2_sources)) v3c_abort("D2 predecessor sources must be an ordered list")
  reader <- if (independent) v3c_read_evidence_root else v3c_fixture_read_evidence_root
  d1_entry <- reader(d1_source, "d1")
  d1_decisions <- v3c_decisions_from_summary(d1_entry$summary, "d1")
  d2_summary <- NULL
  d2_decisions <- data.frame(
    stage = character(), cell_id = character(), eligible = logical(), required_n = integer()
  )
  entries <- list(list(evidence = d1_entry, sequence_index = 0L,
    source_batch = "d1", roles = setNames(rep("interior_pilot",
      length(unique(d1_entry$summary$cell_id))), unique(d1_entry$summary$cell_id))))
  roots <- d1_entry$root
  for (i in seq_along(d2_sources)) {
    entry <- reader(d2_sources[[i]], "d2")
    if (entry$root %in% roots) v3c_abort("predecessor evidence roots must be distinct")
    expected <- v3c_fixture_expected_manifest("d2", d1_entry$summary, d2_summary)
    if (!v3c_table_exact(entry$manifest, expected)) {
      v3c_abort("D2 predecessor roots are missing, reordered, or out of sequence")
    }
    cells <- unique(expected[c("cell_id", "n", "m", "truth_ratio")])
    roles <- v3c_selection_roles(d1_decisions, d2_decisions, cells)
    entries[[length(entries) + 1L]] <- list(
      evidence = entry, sequence_index = as.integer(i),
      source_batch = sprintf("d2_batch_%03d", i), roles = roles
    )
    d2_summary <- if (is.null(d2_summary)) entry$summary else rbind(d2_summary, entry$summary)
    d2_decisions <- v3c_decisions_from_summary(d2_summary, "d2")
    roots <- c(roots, entry$root)
  }
  if (stage %in% c("d3", "d4") && !length(d2_sources)) {
    v3c_abort("D3/D4 require every adjudicated D2 batch root")
  }
  list(
    entries = entries, d1_summary = d1_entry$summary, d2_summary = d2_summary,
    evidence_eligible = isTRUE(independent), fixture_only = !isTRUE(independent)
  )
}

v3c_evidence_history <- function(stage, d1_source, d2_sources = list()) {
  v3c_evidence_history_core(stage, d1_source, d2_sources, independent = TRUE)
}

v3c_fixture_evidence_history <- function(stage, d1_source, d2_sources = list()) {
  v3c_evidence_history_core(stage, d1_source, d2_sources, independent = FALSE)
}

v3c_expected_manifest <- function(stage, d1_source, d2_sources = list()) {
  history <- v3c_evidence_history(stage, d1_source, d2_sources)
  v3c_fixture_expected_manifest(stage, history$d1_summary, history$d2_summary)
}

v3c_history_expected_manifest <- function(stage, history) {
  stage <- v3c_stage(stage)
  if (!is.list(history) || !all(c("d1_summary", "d2_summary") %in% names(history))) {
    v3c_abort("summary generation requires a reconstructed predecessor history")
  }
  v3c_fixture_expected_manifest(stage, history$d1_summary, history$d2_summary)
}

v3c_require_history_manifest <- function(
  manifest, stage, history, allow_fixture = FALSE
) {
  eligible <- if (allow_fixture) isTRUE(history$fixture_only) else {
    isTRUE(history$evidence_eligible)
  }
  if (!eligible) {
    v3c_abort("history is not eligible for this operational or fixture-only path")
  }
  expected <- v3c_history_expected_manifest(stage, history)
  if (!v3c_table_exact(manifest, expected)) {
    v3c_abort("stage manifest is not the exact next manifest from predecessor history")
  }
  expected
}

v3c_fixture_d2_summary_from_history <- function(manifest, attempts, binding, history) {
  v3c_require_history_manifest(manifest, "d2", history, allow_fixture = TRUE)
  v3c_fixture_d2_summary(manifest, attempts, binding)
}

v3c_d2_summary <- function(
  manifest, attempts, binding, d1_source, d2_sources = list()
) {
  history <- v3c_evidence_history("d2", d1_source, d2_sources)
  v3c_require_history_manifest(manifest, "d2", history)
  v3c_fixture_d2_summary(manifest, attempts, binding)
}

v3c_fixture_confirmation_summary_from_history <- function(
  manifest, attempts, binding, history
) {
  stage <- unique(manifest$stage)
  if (length(stage) != 1L || !stage %in% c("d3", "d4")) {
    v3c_abort("confirmation summary requires D3 or D4")
  }
  v3c_require_history_manifest(manifest, stage, history, allow_fixture = TRUE)
  v3c_fixture_confirmation_summary(manifest, attempts, binding)
}

v3c_confirmation_summary <- function(
  manifest, attempts, binding, d1_source, d2_sources
) {
  stage <- unique(manifest$stage)
  if (length(stage) != 1L || !stage %in% c("d3", "d4")) {
    v3c_abort("confirmation summary requires D3 or D4")
  }
  history <- v3c_evidence_history(stage, d1_source, d2_sources)
  v3c_require_history_manifest(manifest, stage, history)
  v3c_fixture_confirmation_summary(manifest, attempts, binding)
}

v3c_predecessor_lock_from_history <- function(stage, history) {
  rows <- lapply(history$entries, function(x) {
    e <- x$evidence
    data.frame(
      stage = stage, sequence_index = x$sequence_index,
      role = paste(sort(unique(unname(x$roles))), collapse = ","),
      source_stage = e$stage, source_batch = x$source_batch, source_root = e$root,
      adjudication_receipt_sha256 = e$receipt_sha256, preseal_sha256 = e$preseal_sha256,
      manifest_sha256 = e$manifest_sha256, corpus_lock_sha256 = e$corpus_lock_sha256,
      r_summary_sha256 = e$r_summary_sha256, julia_summary_sha256 = e$julia_summary_sha256,
      r_validator_sha256 = e$r_validator_sha256,
      julia_validator_sha256 = e$julia_validator_sha256, stringsAsFactors = FALSE
    )
  })
  out <- do.call(rbind, rows); rownames(out) <- NULL
  out[v3c_predecessor_lock_columns]
}

v3c_predecessor_lock <- function(stage, d1_source, d2_sources = list()) {
  v3c_predecessor_lock_from_history(
    stage, v3c_evidence_history(stage, d1_source, d2_sources)
  )
}

v3c_validate_predecessor_lock <- function(observed, ...) {
  v3c_require_schema(observed, v3c_predecessor_lock_columns, "predecessor lock")
  expected <- v3c_predecessor_lock(...)
  if (!identical(observed, expected)) v3c_abort("predecessor lock differs from exact evidence")
  invisible(TRUE)
}

v3c_pilot_decision_lock_from_history <- function(stage, history) {
  rows <- lapply(history$entries, function(entry) {
    e <- entry$evidence
    decisions <- v3c_decisions_from_summary(e$summary, e$stage)
    source_targets <- vapply(decisions$cell_id, function(id) {
      x <- e$summary[e$summary$cell_id == id, , drop = FALSE]
      raw <- suppressWarnings(as.numeric(x$required_n_raw))
      if (!all(is.finite(raw))) "nonfinite" else paste(sort(x$target[raw == max(raw)]), collapse = "+")
    }, character(1L))
    data.frame(
      stage = stage, sequence_index = entry$sequence_index, source_stage = e$stage,
      source_batch = entry$source_batch,
      selection_role = unname(entry$roles[decisions$cell_id]),
      cell_id = decisions$cell_id, eligible = decisions$eligible,
      required_n = decisions$required_n,
      required_n_source_target = source_targets,
      source_summary_sha256 = e$r_summary_sha256, stringsAsFactors = FALSE
    )
  })
  out <- do.call(rbind, rows); rownames(out) <- NULL
  out[v3c_pilot_decision_lock_columns]
}

v3c_pilot_decision_lock <- function(stage, d1_source, d2_sources = list()) {
  v3c_pilot_decision_lock_from_history(
    stage, v3c_evidence_history(stage, d1_source, d2_sources)
  )
}

v3c_validate_pilot_decision_lock <- function(observed, ...) {
  v3c_require_schema(observed, v3c_pilot_decision_lock_columns, "pilot decision lock")
  expected <- v3c_pilot_decision_lock(...)
  if (!identical(observed, expected)) {
    v3c_abort("pilot decision lock differs from authenticated evidence projection")
  }
  invisible(TRUE)
}

v3c_parity <- function(tables, columns, keys, tolerance = 1e-10) {
  if (length(tables) < 2L) v3c_abort("parity requires at least two tables")
  tables <- lapply(tables, function(x) {
    v3c_require_schema(x, columns, "parity table")
    x[do.call(order, x[keys]), , drop = FALSE]
  })
  reference <- tables[[1L]]
  max_diff <- 0
  for (candidate in tables[-1L]) {
    if (nrow(candidate) != nrow(reference)) v3c_abort("parity row-count drift")
    for (field in columns) {
      x <- reference[[field]]
      y <- candidate[[field]]
      if (is.numeric(x) && is.numeric(y)) {
        if (!identical(is.na(x), is.na(y)) ||
            !identical(is.infinite(x), is.infinite(y)) ||
            any(sign(x[is.infinite(x)]) != sign(y[is.infinite(y)]))) {
          v3c_abort("numeric parity shape drift in %s", field)
        }
        finite <- is.finite(x) & is.finite(y)
        diff <- if (any(finite)) max(abs(x[finite] - y[finite])) else 0
        if (!is.finite(diff) || diff > tolerance) v3c_abort("numeric parity drift in %s", field)
        max_diff <- max(max_diff, diff)
      } else if (!identical(x, y)) {
        v3c_abort("exact parity drift in %s", field)
      }
    }
  }
  max_diff
}

v3c_attempt_parity <- function(..., tolerance = 1e-10) {
  v3c_parity(list(...), v3c_attempt_columns, c("stage", "cell_id", "seed"), tolerance)
}

v3c_summary_parity <- function(..., tolerance = 1e-10) {
  tables <- list(...)
  stage <- unique(tables[[1L]]$stage)
  if (length(stage) != 1L) v3c_abort("summary parity has mixed stages")
  columns <- if (stage == "d2") v3c_pilot_summary_columns else {
    if (!stage %in% c("d3", "d4")) v3c_abort("summary parity stage is unsupported")
    v3c_confirmation_summary_columns
  }
  v3c_parity(tables, columns, c("stage", "cell_id", "target"), tolerance)
}

v3c_fixture_d1_summary <- function() {
  cells <- v3_cell_table[v3_cell_table$truth_ratio == 0.5, , drop = FALSE]
  rows <- do.call(rbind, lapply(seq_len(nrow(cells)), function(i) {
    x <- as.data.frame(setNames(
      replicate(length(v3p_d1_summary_columns), rep(NA_character_, 3L), simplify = FALSE),
      v3p_d1_summary_columns
    ), stringsAsFactors = FALSE)
    x$stage <- "d1"; x$cell_id <- cells$cell_id[[i]]; x$cell_index <- cells$cell_index[[i]]
    x$n <- cells$n[[i]]; x$m <- cells$m[[i]]; x$marker_ratio <- cells$marker_ratio[[i]]
    x$truth_ratio <- 0.5; x$target <- c("sigma_g2", "sigma_e2", "ratio")
    x$n_expected <- 48L; x$n_attempted <- 48L; x$n_converged <- 48L
    x$n_bias_rows <- 48L; x$n_interior <- 48L; x$n_interior_rescued <- 0L
    x$n_boundary_lower <- 0L; x$n_boundary_upper <- 0L
    x$n_unresolved <- 0L; x$n_error <- 0L; x$convergence_rate <- 1
    x$wilson_lower <- 0.925; x$wilson_upper <- 1
    x$truth <- c(cells$truth_sigma_g2[[i]], cells$truth_sigma_e2[[i]], 0.5)
    x$margin <- c(0.05 * cells$truth_sigma_g2[[i]],
      0.05 * cells$truth_sigma_e2[[i]], 0.02)
    x$mean_estimate <- x$truth; x$bias <- 0; x$mcse <- 0.001
    x$bias_ci_lower <- 0; x$bias_ci_upper <- 0; x$rmse <- 0.001
    x$mcse_rmse <- 0.0001; x$empirical_sd <- 0.01
    x$pilot_sd_upper <- 0.02; x$required_n_raw <- 100
    x$required_n <- 200; x$low_convergence <- FALSE; x$summary_nonfinite <- FALSE
    x$precision_blocked <- FALSE; x$futility_stopped <- FALSE; x$target_futile <- FALSE
    x$cell_eligible <- TRUE; x$cell_status <- "ELIGIBLE"
    x$median_runtime_seconds <- 1; x$p95_runtime_seconds <- 1.1
    x$median_peak_rss_mb <- 100; x$p95_peak_rss_mb <- 110
    x$rms_se_info <- 0.1; x$empirical_sd_over_rms_se_info <- 0.1
    x$predicted_boundary_lower <- 0; x$predicted_boundary_upper <- 0
    x$observed_boundary_lower <- 0; x$observed_boundary_upper <- 0
    x$mcse_boundary_lower <- 0; x$mcse_boundary_upper <- 0
    x$mean_spectral_cv <- 0.5; x$mean_effective_rank <- 50
    x$failure_classes <- "none=48"
    x
  }))
  rownames(rows) <- NULL
  logical <- c(
    "low_convergence", "summary_nonfinite", "precision_blocked",
    "futility_stopped", "target_futile", "cell_eligible"
  )
  character <- c("stage", "cell_id", "target", "cell_status", "failure_classes")
  numeric <- setdiff(v3p_d1_summary_columns, c(character, logical))
  rows[numeric] <- lapply(rows[numeric], as.numeric)
  rows[logical] <- lapply(rows[logical], as.logical)
  rows[v3p_d1_summary_columns]
}

v3c_fixture_attempts <- function(manifest, binding, shift = 0) {
  rank <- ave(manifest$seed, manifest$cell_id, FUN = seq_along)
  centered <- (rank - ave(rank, manifest$cell_id, FUN = function(x) mean(range(x)))) * 1e-5
  out <- cbind(
    manifest,
    data.frame(
      retained_m = manifest$m, marker_hash = paste(rep("1", 64L), collapse = ""),
      id_hash = paste(rep("2", 64L), collapse = ""),
      kernel_hash = paste(rep("3", 64L), collapse = ""),
      precision_hash = paste(rep("4", 64L), collapse = ""),
      attempted = TRUE, status = "success", error_class = "none", converged = TRUE,
      boundary_status = "interior", boundary_reason = "ai_interior",
      boundary_epsilon = v3c_contract$v3p_boundary_epsilon,
      scientific_sigma_g2 = manifest$truth_sigma_g2 + centered + shift,
      scientific_sigma_e2 = manifest$truth_sigma_e2 - centered - shift,
      scientific_ratio = manifest$truth_ratio + centered + shift,
      fitted_total_variance = 1,
      numerical_sigma_g2 = manifest$truth_sigma_g2 + centered + shift,
      numerical_sigma_e2 = manifest$truth_sigma_e2 - centered - shift,
      numerical_ratio = manifest$truth_ratio + centered + shift,
      profile_loglik = -1, lower_derivative_per_observation = 1,
      upper_derivative_per_observation = -1, iterations = 2,
      objective = 1, gradient_norm = 0,
      runtime_seconds = 1 + rank / 1000, peak_rss_mb = 100 + rank / 100,
      scale_denominator = 1, eigen_cv_population = 0.5, effective_rank = 50,
      information_r020 = 100, se_info_r020 = 0.1,
      information_r050 = 100, se_info_r050 = 0.1,
      information_r080 = 100, se_info_r080 = 0.1,
      relationship_source = "markers", relationship_method = "vanraden1",
      allele_frequency_source = "sample", relationship_scale = "K_lambda",
      route = "ordinary_auto_genomic",
      r_implementation_commit = binding$r_auto_route_commit,
      julia_implementation_commit = binding$julia_candidate_commit,
      driver_commit = binding$r_driver_commit,
      preseal_sha256 = binding$preseal_sha256,
      manifest_sha256 = binding$manifest_sha256,
      corpus_lock_sha256 = binding$corpus_lock_sha256,
      stringsAsFactors = FALSE
    )
  )
  out[v3c_attempt_columns]
}

v3c_selftest <- function() {
  v3c_load_dependencies()
  h <- function(x) paste(rep(x, 64L), collapse = "")
  c40 <- function(x) paste(rep(x, 40L), collapse = "")
  binding <- list(
    preseal_sha256 = h("b"), manifest_sha256 = h("a"), corpus_lock_sha256 = h("c"),
    r_auto_route_commit = c40("1"), julia_candidate_commit = c40("2"),
    r_driver_commit = c40("3"), julia_replay_commit = c40("4"),
    julia_replay_sha256 = h("d")
  )
  d1 <- v3c_fixture_d1_summary()
  d2m <- v3c_fixture_expected_manifest("d2", d1)
  d2a <- v3c_fixture_attempts(d2m, binding)
  d2s <- v3c_fixture_d2_summary(d2m, d2a, binding)
  stopifnot(all(d2s$cell_eligible), v3c_attempt_parity(d2a, d2a) == 0,
    v3c_summary_parity(d2s, d2s) == 0)
  d3m <- v3c_fixture_expected_manifest("d3", d1, d2s)
  d4m <- v3c_fixture_expected_manifest("d4", d1, d2s)
  d3s <- v3c_fixture_confirmation_summary(
    d3m, v3c_fixture_attempts(d3m, binding), binding
  )
  d4s <- v3c_fixture_confirmation_summary(
    d4m, v3c_fixture_attempts(d4m, binding), binding
  )
  stopifnot(all(d3s$cell_pass), all(d4s$cell_pass),
    !length(intersect(d2m$seed, d3m$seed)), !length(intersect(d3m$seed, d4m$seed)))
  bad <- d3s; bad$bias[[1L]] <- bad$bias[[1L]] + 1e-4
  stopifnot(inherits(try(v3c_summary_parity(d3s, bad), silent = TRUE), "try-error"))
  message("v0.7 genomic recovery-v3 downstream contract selftest: PASS")
  invisible(TRUE)
}

v3c_dependency_names <- base::c(
  "v3_cell_table", "v3_manifest", "v3_d1_manifest", "v3_d2_next_cells",
  "v3_d3_manifest", "v3_d4_manifest", "v3_validate_decisions",
  "v3p_d1_summary_columns", "v3_original_pairs", "v3_ratio_levels", "v3_decision"
)
v3c_module_names <- base::ls(
  envir = base::environment(), pattern = "^v3c_", all.names = TRUE
)
v3c_module_names <- base::setdiff(
  v3c_module_names, base::c("v3c_module_names", "v3c_module_env")
)
v3c_module_env <- base::new.env(parent = v3c_imports)
for (name in base::c(v3c_dependency_names, v3c_module_names)) {
  value <- base::get(name, envir = base::environment(), inherits = FALSE)
  if (base::is.function(value) && base::startsWith(name, "v3c_")) {
    base::environment(value) <- v3c_module_env
  }
  base::assign(name, value, envir = v3c_module_env)
}
base::lockEnvironment(v3c_module_env, bindings = TRUE)
for (name in v3c_module_names) {
  if (base::is.function(v3c_module_env[[name]])) {
    base::assign(name, v3c_module_env[[name]], envir = base::environment())
  }
  if (!base::bindingIsLocked(name, base::environment())) {
    base::lockBinding(name, base::environment())
  }
}
base::lockBinding("v3c_module_names", base::environment())
base::lockBinding("v3c_module_env", base::environment())

if (base::sys.nframe() == 0L) v3c_module_env$v3c_selftest()
