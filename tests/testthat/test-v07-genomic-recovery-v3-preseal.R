preseal_tool <- testthat::test_path(
  "..",
  "..",
  "tools",
  "v07_genomic_recovery_v3_preseal.R"
)
testthat::skip_if_not(
  file.exists(preseal_tool),
  "repository-only recovery-v3 pre-seal tool is unavailable"
)
source(normalizePath(preseal_tool, mustWork = TRUE), local = TRUE)

v3p_test_hash <- function(letter = "a") paste(rep(letter, 64L), collapse = "")

v3p_test_d0f_adjudication_receipt <- function(
  verdict = "PASS",
  stage_decision = "COMPLETE",
  schema_version = v3p_d0f_adjudication_schema,
  stage = "d0f"
) {
  values <- setNames(
    rep(v3p_test_hash("a"), length(v3p_d0f_adjudication_columns)),
    v3p_d0f_adjudication_columns
  )
  values[c(
    "schema_version",
    "stage",
    "verdict",
    "stage_decision",
    "attempt_max_diff",
    "summary_max_diff"
  )] <- c(schema_version, stage, verdict, stage_decision, "0", "0")
  values[c(
    "r_driver_commit",
    "r_recomputer_commit",
    "julia_replay_commit"
  )] <- paste(rep("b", 40L), collapse = "")
  values[paste0(v3p_reviewers, "_review_path")] <- file.path(
    "postrun_receipts",
    paste0(v3p_reviewers, ".tsv")
  )
  out <- as.data.frame(as.list(values), stringsAsFactors = FALSE)
  out[v3p_d0f_adjudication_columns]
}

v3p_test_d0_manifest <- function() {
  rows <- lapply(seq_len(nrow(v07d_cells)), function(i) {
    cell <- v07d_cells[i, ]
    offset <- 7101:7148
    data.frame(
      tier = "pilot",
      cell_id = cell$cell_id,
      cell_index = cell$cell_index,
      seed_offset = offset,
      seed = 2027120000 + 10000 * cell$cell_index + offset,
      n = cell$n,
      m = cell$m,
      truth_sigma_g2 = cell$truth_ratio,
      truth_sigma_e2 = 1 - cell$truth_ratio,
      truth_ratio = cell$truth_ratio,
      ridge = 0.01,
      regime = "synthetic_test_only",
      stringsAsFactors = FALSE
    )
  })
  out <- do.call(rbind, rows)
  rownames(out) <- NULL
  out[v07d_manifest_columns]
}

v3p_test_d0_diagnostics <- function(manifest = v3p_test_d0_manifest()) {
  out <- data.frame(
    cell_id = manifest$cell_id,
    cell_index = manifest$cell_index,
    seed = manifest$seed,
    n = manifest$n,
    m = manifest$m,
    truth_ratio = manifest$truth_ratio,
    retained_m = pmax(1L, manifest$m - 1L),
    ridge = manifest$ridge,
    scale_denominator = 1,
    marker_hash = v3p_test_hash("a"),
    id_hash = v3p_test_hash("b"),
    kernel_hash = v3p_test_hash("c"),
    precision_hash = v3p_test_hash("d"),
    k_replay_max_abs = 0,
    qk_max_abs = 0,
    eigen_min = 0.01,
    eigen_max = 2,
    eigen_mean = 1,
    eigen_sd_population = 0.2,
    eigen_cv_population = 0.2,
    effective_rank = manifest$n - 1,
    information_r020 = 10,
    se_info_r020 = 1 / sqrt(10),
    information_r050 = 12,
    se_info_r050 = 1 / sqrt(12),
    information_r080 = 10,
    se_info_r080 = 1 / sqrt(10),
    scientific_ratio = manifest$truth_ratio,
    absolute_ratio_error = 0,
    boundary_status = "interior",
    predicted_lower_probability = 0,
    predicted_upper_probability = 0,
    stringsAsFactors = FALSE
  )
  out[v07d_diagnostic_columns]
}

v3p_test_results <- function(n, estimate) {
  data.frame(
    attempted = TRUE,
    status = "success",
    error_class = "none",
    converged = TRUE,
    boundary_status = "interior",
    boundary_reason = "ai_interior",
    boundary_epsilon = 1e-7,
    scientific_sigma_g2 = estimate,
    scientific_sigma_e2 = 1 - estimate,
    scientific_ratio = estimate,
    fitted_total_variance = 1,
    numerical_sigma_g2 = estimate,
    numerical_sigma_e2 = 1 - estimate,
    numerical_ratio = estimate,
    profile_loglik = -1,
    lower_derivative_per_observation = 1,
    upper_derivative_per_observation = -1,
    iterations = 2,
    objective = 1,
    gradient_norm = 0,
    runtime_seconds = rep(0.1, n),
    peak_rss_mb = rep(100, n),
    scale_denominator = 1,
    eigen_cv_population = rep(0.5, n),
    effective_rank = rep(50, n),
    information_r020 = rep(400, n),
    se_info_r020 = rep(0.05, n),
    information_r050 = rep(625, n),
    se_info_r050 = rep(0.04, n),
    information_r080 = rep(400, n),
    se_info_r080 = rep(0.05, n),
    relationship_source = "markers",
    relationship_method = "vanraden1",
    allele_frequency_source = "sample",
    relationship_scale = "K_lambda",
    route = "ordinary_auto_genomic",
    r_implementation_commit = paste(rep("a", 40L), collapse = ""),
    julia_implementation_commit = paste(rep("b", 40L), collapse = ""),
    driver_commit = paste(rep("c", 40L), collapse = ""),
    preseal_sha256 = v3p_test_hash("e"),
    stringsAsFactors = FALSE
  )[v3p_result_columns]
}

v3p_test_fail_rows <- function(
  attempts,
  rows,
  unresolved = TRUE,
  finite_boundary_evidence = TRUE
) {
  attempts$status[rows] <- "fit_error"
  attempts$error_class[rows] <- if (unresolved) {
    "boundary_resolution_failed"
  } else {
    "fit_failed"
  }
  attempts$converged[rows] <- FALSE
  required_na <- c(
    "scientific_sigma_g2",
    "scientific_sigma_e2",
    "scientific_ratio",
    "fitted_total_variance",
    "numerical_sigma_g2",
    "numerical_sigma_e2",
    "numerical_ratio",
    "iterations",
    "objective",
    "gradient_norm"
  )
  for (field in required_na) {
    attempts[[field]][rows] <- NA_real_
  }
  if (unresolved) {
    attempts$boundary_status[rows] <- "boundary_unresolved"
    attempts$boundary_reason[rows] <- "profile_unresolved"
    attempts$boundary_epsilon[rows] <- v3p_boundary_epsilon
    evidence <- c(
      "profile_loglik",
      "lower_derivative_per_observation",
      "upper_derivative_per_observation"
    )
    if (finite_boundary_evidence) {
      attempts$profile_loglik[rows] <- -12
      attempts$lower_derivative_per_observation[rows] <- 0
      attempts$upper_derivative_per_observation[rows] <- 0
    } else {
      for (field in evidence) {
        attempts[[field]][rows] <- NA_real_
      }
    }
  } else {
    attempts$boundary_status[rows] <- NA_character_
    attempts$boundary_reason[rows] <- NA_character_
    attempts$boundary_epsilon[rows] <- NA_real_
    attempts$profile_loglik[rows] <- NA_real_
    attempts$lower_derivative_per_observation[rows] <- NA_real_
    attempts$upper_derivative_per_observation[rows] <- NA_real_
  }
  attempts
}

v3p_test_d0f <- function() {
  d0 <- v3p_test_d0_manifest()
  diagnostics <- v3p_test_d0_diagnostics(d0)
  fixed <- v3p_d0f_fixed_panels(d0, diagnostics)
  manifest <- v3p_d0f_phenotype_manifest(fixed)
  centered <- rep(seq(-0.015, 0.015, length.out = 8L), nrow(fixed))
  panel_shift <- rep(rep(seq(-0.01, 0.01, length.out = 24L), each = 8L), 3L)
  estimates <- 0.5 + centered + panel_shift
  attempts <- cbind(manifest, v3p_test_results(nrow(manifest), estimates))
  attempts <- attempts[v3p_d0f_attempt_columns]
  list(
    d0 = d0,
    diagnostics = diagnostics,
    fixed = fixed,
    manifest = manifest,
    attempts = attempts
  )
}

v3p_test_d1 <- function() {
  manifest <- v3p_d1_manifest()
  centered <- rep(seq(-0.003, 0.003, length.out = 48L), 12L)
  results <- v3p_test_results(nrow(manifest), 0.5 + centered)
  attempts <- cbind(
    manifest,
    retained_m = manifest$m,
    marker_hash = v3p_test_hash("a"),
    id_hash = v3p_test_hash("b"),
    kernel_hash = v3p_test_hash("c"),
    precision_hash = v3p_test_hash("d"),
    results
  )
  attempts <- attempts[v3p_d1_attempt_columns]
  list(manifest = manifest, attempts = attempts)
}

v3p_test_binding <- function() {
  list(
    preseal_sha256 = v3p_test_hash("e"),
    manifest_sha256 = v3p_test_hash("f"),
    corpus_lock_sha256 = v3p_test_hash("a"),
    r_auto_route_commit = paste(rep("a", 40L), collapse = ""),
    julia_candidate_commit = paste(rep("b", 40L), collapse = ""),
    r_driver_commit = paste(rep("c", 40L), collapse = ""),
    julia_replay_commit = paste(rep("d", 40L), collapse = ""),
    julia_replay_sha256 = v3p_test_hash("b")
  )
}

v3p_test_julia_replay <- function(attempts) {
  binding <- v3p_test_binding()
  attempts$route <- "julia_profile_replay"
  attempts$driver_commit <- binding$julia_replay_commit
  out <- cbind(
    attempts[setdiff(names(attempts), "preseal_sha256")],
    source_r_attempt_sha256 = v3p_test_hash("a"),
    source_r_max_abs_difference = 0,
    replay_julia_commit = binding$julia_replay_commit,
    replay_driver_sha256 = binding$julia_replay_sha256,
    manifest_sha256 = binding$manifest_sha256,
    preseal_sha256 = binding$preseal_sha256,
    corpus_lock_sha256 = binding$corpus_lock_sha256
  )
  out[c(setdiff(names(attempts), "preseal_sha256"), v3p_replay_binding_columns)]
}

v3p_test_pair <- function(path, object) {
  text <- if (is.data.frame(object)) {
    v07d_tsv_text(object)
  } else {
    as.character(object)
  }
  v07d_write_once(path, text)
}

v3p_test_tsv_hash <- function(object) {
  path <- tempfile("v3p-tsv-hash-")
  on.exit(unlink(c(path, paste0(path, ".sha256"))), add = TRUE)
  v3p_test_pair(path, object)
}

v3p_test_git <- function(root, ...) {
  out <- system2(
    Sys.which("git"),
    c("-C", root, ...),
    stdout = TRUE,
    stderr = TRUE
  )
  status <- attr(out, "status")
  if (!is.null(status) && status != 0L) {
    stop(paste(out, collapse = "\n"))
  }
  out
}

v3p_test_validate_stage <- function(...) {
  env <- environment(v3p_validate_stage_preseal)
  old_d0 <- get(
    "v3p_validate_frozen_d0_artifacts",
    envir = env,
    inherits = FALSE
  )
  old_live <- get(
    "v3p_validate_environment_live",
    envir = env,
    inherits = FALSE
  )
  old_d0f_final <- get(
    "v3p_validate_d0f_final_tree",
    envir = env,
    inherits = FALSE
  )
  assign(
    "v3p_validate_frozen_d0_artifacts",
    function(root, receipt_hash, diagnostics_hash) {
      root <- v3p_canonical_path(root, "synthetic D0 replay root", TRUE)
      v3p_verify_pair(
        file.path(root, "receipt", "d0-check-log.md"),
        receipt_hash,
        "synthetic D0 receipt"
      )
      diagnostics_path <- file.path(
        root,
        "r",
        "d0_packet_diagnostics_base_r.tsv"
      )
      v3p_verify_pair(
        diagnostics_path,
        diagnostics_hash,
        "synthetic D0 diagnostics"
      )
      list(root = root, diagnostics_path = diagnostics_path)
    },
    envir = env
  )
  assign(
    "v3p_validate_environment_live",
    function(x) v3p_validate_environment(x),
    envir = env
  )
  assign(
    "v3p_validate_d0f_final_tree",
    function(root) invisible(TRUE),
    envir = env
  )
  on.exit(
    assign(
      "v3p_validate_frozen_d0_artifacts",
      old_d0,
      envir = env
    ),
    add = TRUE
  )
  on.exit(
    assign("v3p_validate_environment_live", old_live, envir = env),
    add = TRUE
  )
  on.exit(
    assign(
      "v3p_validate_d0f_final_tree",
      old_d0f_final,
      envir = env
    ),
    add = TRUE
  )
  v3p_validate_stage_preseal(...)
}

v3p_test_preseal_fixture <- function(write_preseal = TRUE, nested = FALSE) {
  base <- tempfile("v3p-preseal-fixture-")
  dir.create(base)
  base <- normalizePath(base, winslash = "/", mustWork = TRUE)
  d0_root <- file.path(base, "d0")
  d0f_adjudication_root <- file.path(base, "d0f-adjudicated")
  stage_root <- if (nested) {
    file.path(d0_root, "stage")
  } else {
    file.path(base, "stage")
  }
  git_root <- file.path(base, "deployed")
  dir.create(file.path(d0_root, "receipt"), recursive = TRUE)
  dir.create(file.path(d0_root, "r"), recursive = TRUE)
  dir.create(d0f_adjudication_root)
  dir.create(file.path(stage_root, "receipts"), recursive = TRUE)
  dir.create(git_root)
  d0_root <- normalizePath(d0_root, winslash = "/", mustWork = TRUE)
  d0f_adjudication_root <- normalizePath(
    d0f_adjudication_root,
    winslash = "/",
    mustWork = TRUE
  )
  stage_root <- normalizePath(stage_root, winslash = "/", mustWork = TRUE)
  git_root <- normalizePath(git_root, winslash = "/", mustWork = TRUE)

  d0_receipt <- file.path(d0_root, "receipt", "d0-check-log.md")
  d0_receipt_hash <- v3p_test_pair(d0_receipt, "synthetic D0 receipt\n")
  d0_diagnostics <- file.path(
    d0_root,
    "r",
    "d0_packet_diagnostics_base_r.tsv"
  )
  d0_diagnostics_hash <- v3p_test_pair(
    d0_diagnostics,
    "synthetic D0 diagnostics\n"
  )
  d0f_adjudication_path <- file.path(
    d0f_adjudication_root,
    "stage_adjudication_receipt.tsv"
  )
  d0f_adjudication_hash <- v3p_test_pair(
    d0f_adjudication_path,
    v3p_test_d0f_adjudication_receipt()
  )

  tool_names <- c(
    r_driver = "tools/v07_genomic_recovery_v3.R",
    r_recomputer = "tools/v07_genomic_recovery_v3_preseal.R",
    julia_replay = "sim/phase2_v07_genomic_recovery_v3_stage_replay.jl",
    d0_recomputer = "tools/v07_genomic_recovery_v3_d0_recompute.R"
  )
  tool_paths <- file.path(git_root, unname(tool_names))
  names(tool_paths) <- names(tool_names)
  for (name in names(tool_paths)) {
    v3p_test_pair(tool_paths[[name]], paste0("synthetic ", name, " tool\n"))
  }
  dir.create(file.path(git_root, "R"))
  dir.create(file.path(git_root, "src"))
  dir.create(file.path(git_root, "ext"))
  writeLines("synthetic R surface", file.path(git_root, "R", "surface.R"))
  writeLines(
    "synthetic Julia surface",
    file.path(git_root, "src", "surface.jl")
  )
  writeLines("synthetic extension", file.path(git_root, "ext", "surface.jl"))
  for (name in c("DESCRIPTION", "NAMESPACE", "Project.toml", "Manifest.toml")) {
    writeLines(paste("synthetic", name), file.path(git_root, name))
  }
  v3p_test_git(git_root, "init", "--quiet")
  v3p_test_git(git_root, "config", "user.email", "v3p@example.invalid")
  v3p_test_git(git_root, "config", "user.name", "v3p synthetic")
  v3p_test_git(git_root, "add", "--force", ".")
  v3p_test_git(git_root, "commit", "--quiet", "-m", "synthetic-tools")
  commit <- trimws(v3p_test_git(git_root, "rev-parse", "HEAD")[[1L]])

  doc_hash <- v3p_test_pair(
    file.path(stage_root, "doc49.md"),
    "synthetic doc49\n"
  )
  cell_hash <- v3p_test_pair(
    file.path(stage_root, "cell_table.tsv"),
    v3p_cell_table()
  )
  lock_hash <- v3p_test_pair(
    file.path(stage_root, "historical_seed_lock.tsv"),
    v07s_expected_lock
  )
  manifest_hash <- v3p_test_pair(
    file.path(stage_root, "d1_manifest.tsv"),
    v3p_d1_manifest()
  )
  environment <- v3p_environment_manifest(c(
    stage = "d1",
    host = "totoro",
    r_version = as.character(getRversion()),
    r_rng_kind = "Mersenne-Twister",
    r_normal_kind = "Inversion",
    r_sample_kind = "Rejection",
    julia_version = "1.10.0",
    openblas_num_threads = "1",
    julia_num_threads = "1",
    max_workers = "16"
  ))
  environment_hash <- v3p_test_pair(
    file.path(stage_root, "environment_manifest.tsv"),
    environment
  )

  review_hashes <- setNames(character(length(v3p_reviewers)), v3p_reviewers)
  for (reviewer in v3p_reviewers) {
    receipt <- data.frame(
      reviewer = reviewer,
      verdict = "CLEAN",
      doc49_sha256 = doc_hash,
      r_driver_commit = commit,
      r_recomputer_commit = commit,
      julia_replay_commit = commit,
      r_auto_route_commit = commit,
      julia_candidate_commit = commit,
      stringsAsFactors = FALSE
    )[v3p_review_columns]
    review_hashes[[reviewer]] <- v3p_test_pair(
      file.path(stage_root, "receipts", paste0(reviewer, ".tsv")),
      receipt
    )
  }

  values <- setNames(
    rep("NA", length(v3p_stage_preseal_keys)),
    v3p_stage_preseal_keys
  )
  values[c(
    "schema_version",
    "stage",
    "d0_output_root",
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
    "d1",
    d0_root,
    stage_root,
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
  values[c(
    "doc49_sha256",
    "cell_table_sha256",
    "manifest_sha256",
    "environment_manifest_sha256",
    "d0_adjudication_receipt_sha256",
    "d0_diagnostics_sha256",
    "d0f_adjudication_receipt_sha256",
    "historical_seed_lock_sha256"
  )] <- c(
    doc_hash,
    cell_hash,
    manifest_hash,
    environment_hash,
    d0_receipt_hash,
    d0_diagnostics_hash,
    d0f_adjudication_hash,
    lock_hash
  )
  values[["d0f_adjudication_root"]] <- d0f_adjudication_root
  values[paste0(v3p_reviewers, "_receipt_sha256")] <- review_hashes
  values[c(
    "r_driver_commit",
    "r_recomputer_commit",
    "julia_replay_commit",
    "r_auto_route_commit",
    "julia_candidate_commit"
  )] <- commit
  values[c(
    "r_driver_sha256",
    "r_recomputer_sha256",
    "julia_replay_sha256",
    "d0_recomputer_sha256"
  )] <- vapply(tool_paths, v07d_sha256, character(1L))
  preseal <- data.frame(
    key = v3p_stage_preseal_keys,
    value = unname(values[v3p_stage_preseal_keys]),
    stringsAsFactors = FALSE
  )
  if (write_preseal) {
    v3p_test_pair(file.path(stage_root, "stage_preseal.tsv"), preseal)
  }
  context <- list(
    r_driver_path = tool_paths[["r_driver"]],
    r_recomputer_path = tool_paths[["r_recomputer"]],
    julia_replay_path = tool_paths[["julia_replay"]],
    d0_recomputer_path = tool_paths[["d0_recomputer"]],
    r_driver_root = git_root,
    r_recomputer_root = git_root,
    julia_replay_root = git_root,
    r_auto_route_root = git_root,
    julia_candidate_root = git_root
  )
  list(
    base = base,
    stage_root = stage_root,
    d0_root = d0_root,
    d0f_adjudication_root = d0f_adjudication_root,
    d0f_adjudication_path = d0f_adjudication_path,
    git_root = git_root,
    preseal = preseal,
    context = context,
    tool_paths = tool_paths
  )
}

test_that("D0F selects exact fixed panels and maps all phenotype seeds", {
  fixture <- v3p_test_d0f()
  expect_equal(nrow(fixture$fixed), 72L)
  expect_equal(nrow(fixture$manifest), 576L)
  expect_identical(
    fixture$fixed$panel_source_seed,
    unlist(
      lapply(v3p_d0f_designs$source_cell_id, function(cell) {
        sort(fixture$d0$seed[fixture$d0$cell_id == cell])[1:24]
      }),
      use.names = FALSE
    )
  )
  expect_identical(
    fixture$manifest$seed,
    v3p_d0f_phenotype_seed(
      fixture$manifest$design_index,
      fixture$manifest$panel_rank,
      fixture$manifest$phenotype_rank
    )
  )
  expect_true(all(fixture$manifest$seed > v07s_d0f_retry_phenotype_base))
  expect_length(
    intersect(fixture$manifest$seed, v07s_expand_retired_d0f()$seed),
    0L
  )
  expect_length(intersect(fixture$manifest$seed, fixture$d0$seed), 0L)

  wrong_hash <- fixture$fixed
  wrong_hash$marker_hash[[1L]] <- v3p_test_hash("e")
  expect_error(
    v3p_validate_d0f_fixed_panels(wrong_hash, fixture$diagnostics),
    "differs from immutable D0 diagnostics"
  )

  too_many_diagnostic_markers <- fixture$diagnostics
  too_many_diagnostic_markers$retained_m[[1L]] <-
    too_many_diagnostic_markers$m[[1L]] + 1L
  expect_error(
    v3p_validate_d0_diagnostics(
      v3p_test_d0_manifest(),
      too_many_diagnostic_markers
    ),
    "scientific contract drift"
  )
  too_many_panel_markers <- fixture$fixed
  too_many_panel_markers$retained_m[[1L]] <-
    too_many_panel_markers$m[[1L]] + 1L
  expect_error(
    v3p_validate_d0f_fixed_panels(too_many_panel_markers),
    "scientific contract drift"
  )

  duplicate_seed <- fixture$manifest
  duplicate_seed$seed[[2L]] <- duplicate_seed$seed[[1L]]
  expect_error(
    v3p_validate_d0f_phenotype_manifest(duplicate_seed, fixture$fixed),
    "seed collision"
  )
})

test_that("D0F bootstrap is exact, two-level, and restores RNG state", {
  set.seed(617L)
  before_seed <- .Random.seed
  before_kind <- RNGkind()
  bootstrap <- v3p_d0f_bootstrap_manifest(4L)
  expect_identical(.Random.seed, before_seed)
  expect_identical(RNGkind(), before_kind)
  expect_equal(nrow(bootstrap), 288L)
  expect_identical(names(bootstrap), v3p_d0f_bootstrap_columns)
  expect_silent(v3p_validate_d0f_bootstrap(bootstrap, 4L))
  seeds <- v3p_validate_bootstrap_seed_space()
  expect_identical(seeds, as.integer(2039000001:2039000003))
  expect_identical(anyDuplicated(seeds), 0L)
  expect_length(
    intersect(
      seeds,
      v07s_d0f_bootstrap_seeds(v07s_d0f_retired_bootstrap_base)
    ),
    0L
  )
  expect_length(
    intersect(
      seeds,
      v07s_d0f_bootstrap_seeds(v07s_d0f_retired_retry_bootstrap_base)
    ),
    0L
  )
  expect_length(
    intersect(
      seeds,
      v07s_d0f_bootstrap_seeds(v07s_d0f_retired_retry2_bootstrap_base)
    ),
    0L
  )
  expect_length(
    intersect(
      seeds,
      v07s_d0f_bootstrap_seeds(v07s_d0f_retired_retry3_bootstrap_base)
    ),
    0L
  )
  proposed <- v07s_expand_v3()
  proposed$seed[[1L]] <- seeds[[1L]]
  expect_error(
    v3p_validate_bootstrap_seed_space(proposed = proposed),
    "overlaps a historical or v3 fitted seed"
  )

  panel <- bootstrap
  panel$panel_rank[[1L]] <- if (panel$panel_rank[[1L]] == 24L) 23L else 24L
  expect_error(v3p_validate_d0f_bootstrap(panel, 4L), "frozen base-R RNG")
  bad_index <- bootstrap
  bad_index$phenotype_01[[1L]] <- 9L
  expect_error(v3p_validate_d0f_bootstrap(bad_index, 4L), "index range")
})

test_that("committed cell table admits rounded marker ratio only", {
  path <- testthat::test_path(
    "..",
    "..",
    "docs",
    "design",
    "v07_genomic_recovery_v3_cell_table.tsv"
  )
  actual <- utils::read.delim(
    path,
    header = TRUE,
    sep = "\t",
    quote = "",
    comment.char = "",
    check.names = FALSE,
    stringsAsFactors = FALSE,
    na.strings = "NA"
  )
  expect_silent(v3p_validate_cell_table(actual))
  rounded <- actual
  rounded$marker_ratio[[4L]] <- rounded$marker_ratio[[4L]] + 2e-12
  expect_error(v3p_validate_cell_table(rounded), "marker_ratio")
  identity <- actual
  identity$cell_index[[1L]] <- identity$cell_index[[1L]] + 1e-12
  expect_error(v3p_validate_cell_table(identity), "cell_index")
})

test_that("D1 manifest is the exact 12-cell, 48-seed frozen ladder", {
  manifest <- v3p_d1_manifest()
  expect_equal(nrow(manifest), 576L)
  expect_equal(length(unique(manifest$cell_id)), 12L)
  expect_identical(unname(as.integer(table(manifest$cell_id))), rep(48L, 12L))
  expect_equal(unique(manifest$truth_ratio), 0.5)
  expect_equal(unique(manifest$seed_offset), 101:148)

  wrong_stage <- manifest
  wrong_stage$stage[[1L]] <- "d2"
  expect_error(v3p_validate_d1_manifest(wrong_stage), "mismatch in stage")
  wrong_cell <- manifest
  wrong_cell$cell_id[[1L]] <- "unknown"
  expect_error(v3p_validate_d1_manifest(wrong_cell), "mismatch in cell_id")
  collision <- manifest
  collision$seed[[2L]] <- collision$seed[[1L]]
  expect_error(v3p_validate_d1_manifest(collision), "uniqueness")
})

test_that("attempt admission fails closed on membership, truth, and booleans", {
  d0f <- v3p_test_d0f()
  binding <- v3p_test_binding()
  expect_silent(v3p_admit_d0f_attempts(d0f$attempts, d0f$manifest, binding))

  missing <- d0f$attempts[-1L, ]
  expect_error(
    v3p_admit_d0f_attempts(missing, d0f$manifest, binding),
    "exactly the manifest denominator"
  )
  extra <- rbind(d0f$attempts, d0f$attempts[1L, ])
  expect_error(
    v3p_admit_d0f_attempts(extra, d0f$manifest, binding),
    "exactly the manifest denominator"
  )
  duplicate <- d0f$attempts
  duplicate[2L, v3p_d0f_phenotype_columns] <-
    duplicate[1L, v3p_d0f_phenotype_columns]
  expect_error(
    v3p_admit_d0f_attempts(duplicate, d0f$manifest, binding),
    "exactly the manifest denominator"
  )
  truth <- d0f$attempts
  truth$truth_ratio[[1L]] <- 0.8
  expect_error(
    v3p_admit_d0f_attempts(truth, d0f$manifest, binding),
    "truth_ratio"
  )

  malformed <- d0f$attempts
  malformed$attempted <- as.character(malformed$attempted)
  malformed$attempted[[1L]] <- "yes"
  expect_error(
    v3p_admit_d0f_attempts(malformed, d0f$manifest, binding),
    "invalid logical"
  )
  attempted_false <- d0f$attempts
  attempted_false$attempted[[1L]] <- FALSE
  expect_error(
    v3p_admit_d0f_attempts(attempted_false, d0f$manifest, binding),
    "denominator"
  )
  converged_false <- d0f$attempts
  converged_false$converged[[1L]] <- FALSE
  expect_error(
    v3p_admit_d0f_attempts(converged_false, d0f$manifest, binding),
    "status or convergence"
  )
  wrong_route <- d0f$attempts
  wrong_route$route[[1L]] <- "fallback"
  expect_error(
    v3p_admit_d0f_attempts(wrong_route, d0f$manifest, binding),
    "malformed scientific"
  )
  for (value in c(NA_real_, NaN, Inf)) {
    bad_gradient <- d0f$attempts
    bad_gradient$gradient_norm[[1L]] <- value
    expect_error(
      v3p_admit_d0f_attempts(bad_gradient, d0f$manifest, binding),
      "malformed scientific"
    )
  }

  d1 <- v3p_test_d1()
  too_many_markers <- d1$attempts
  too_many_markers$retained_m[[1L]] <- too_many_markers$m[[1L]] + 1L
  expect_error(
    v3p_admit_d1_attempts(too_many_markers, d1$manifest, binding),
    "retained marker"
  )
})

test_that("attempt admission preserves declared endpoints and rejects component drift", {
  fixture <- v3p_test_d0f()
  binding <- v3p_test_binding()
  lower <- fixture$attempts
  lower_component <- 9.9999999999999982e-08
  lower$boundary_status[[1L]] <- "boundary_lower"
  lower$boundary_reason[[1L]] <- "boundary_lower"
  lower$scientific_sigma_g2[[1L]] <- 0
  lower$scientific_sigma_e2[[1L]] <- 1
  lower$scientific_ratio[[1L]] <- 0
  lower$numerical_sigma_g2[[1L]] <- lower_component
  lower$numerical_sigma_e2[[1L]] <- 1 - lower_component
  lower$numerical_ratio[[1L]] <- 1e-7
  lower$lower_derivative_per_observation[[1L]] <- 0
  lower$upper_derivative_per_observation[[1L]] <- -1
  expect_silent(v3p_admit_d0f_attempts(lower, fixture$manifest, binding))

  upper <- fixture$attempts
  upper_declared <- 1 - 1e-7
  upper_component <- 0.99999989999999994
  upper$boundary_status[[1L]] <- "boundary_upper"
  upper$boundary_reason[[1L]] <- "boundary_upper"
  upper$scientific_sigma_g2[[1L]] <- 1
  upper$scientific_sigma_e2[[1L]] <- 0
  upper$scientific_ratio[[1L]] <- 1
  upper$numerical_sigma_g2[[1L]] <- upper_component
  upper$numerical_sigma_e2[[1L]] <- 1 - upper_component
  upper$numerical_ratio[[1L]] <- upper_declared
  upper$lower_derivative_per_observation[[1L]] <- 1
  upper$upper_derivative_per_observation[[1L]] <- 0
  expect_silent(v3p_admit_d0f_attempts(upper, fixture$manifest, binding))

  just_outside <- lower
  just_outside$numerical_sigma_g2[[1L]] <- 1e-7 + 2e-12
  just_outside$numerical_sigma_e2[[1L]] <- 1 - (1e-7 + 2e-12)
  expect_error(
    v3p_admit_d0f_attempts(just_outside, fixture$manifest, binding),
    "malformed scientific"
  )
  substantive <- upper
  substantive$numerical_sigma_g2[[1L]] <- upper_declared - 1e-8
  substantive$numerical_sigma_e2[[1L]] <- 1 - (upper_declared - 1e-8)
  expect_error(
    v3p_admit_d0f_attempts(substantive, fixture$manifest, binding),
    "malformed scientific"
  )
})

test_that("unsuccessful attempts obey the exact frozen NA and boundary convention", {
  fixture <- v3p_test_d1()
  binding <- v3p_test_binding()
  unresolved <- v3p_test_fail_rows(fixture$attempts, 1L)
  expect_silent(v3p_admit_d1_attempts(unresolved, fixture$manifest, binding))
  unresolved_na <- v3p_test_fail_rows(
    fixture$attempts,
    1L,
    finite_boundary_evidence = FALSE
  )
  expect_silent(v3p_admit_d1_attempts(unresolved_na, fixture$manifest, binding))
  ordinary <- v3p_test_fail_rows(fixture$attempts, 1L, unresolved = FALSE)
  expect_silent(v3p_admit_d1_attempts(ordinary, fixture$manifest, binding))

  mutations <- list(
    scientific_sigma_g2 = 0.5,
    fitted_total_variance = 1,
    numerical_ratio = 0.5,
    iterations = 2,
    boundary_epsilon = 2e-7,
    boundary_reason = NA_character_,
    profile_loglik = NA_real_
  )
  for (field in names(mutations)) {
    changed <- unresolved
    changed[[field]][[1L]] <- mutations[[field]]
    expect_error(
      v3p_admit_d1_attempts(changed, fixture$manifest, binding),
      "unsuccessful|unresolved failure",
      info = paste("malformed unresolved field", field)
    )
  }
  changed <- unresolved
  changed$scientific_ratio[[1L]] <- NaN
  expect_error(
    v3p_admit_d1_attempts(changed, fixture$manifest, binding),
    "unsuccessful"
  )
  changed <- ordinary
  changed$profile_loglik[[1L]] <- -1
  expect_error(
    v3p_admit_d1_attempts(changed, fixture$manifest, binding),
    "ordinary failure"
  )
  changed <- ordinary
  changed$status[[1L]] <- "timeout"
  expect_error(
    v3p_admit_d1_attempts(changed, fixture$manifest, binding),
    "status or convergence"
  )
})

test_that("D1 summaries implement frozen sizing and three-way adjudication", {
  fixture <- v3p_test_d1()
  binding <- v3p_test_binding()
  expect_silent(v3p_admit_d1_attempts(
    fixture$attempts,
    fixture$manifest,
    binding
  ))
  summary <- v3p_d1_summary(fixture$manifest, fixture$attempts, binding)
  expect_identical(names(summary), v3p_d1_summary_columns)
  expect_equal(nrow(summary), 36L)
  expect_true(all(summary$n_expected == 48L))
  expect_true(all(summary$n_attempted == 48L))
  expect_true(all(summary$n_converged == 48L))
  expect_true(all(summary$cell_eligible))
  julia <- v3p_test_julia_replay(fixture$attempts)
  expect_silent(v3p_adjudicate_attempts(
    fixture$attempts,
    fixture$attempts,
    julia,
    fixture$manifest,
    "d1",
    binding,
    rep(v3p_test_hash("a"), nrow(fixture$attempts))
  ))
  expect_silent(v3p_adjudicate_summaries(summary, summary, summary, "d1"))

  changed_fingerprint <- julia
  changed_fingerprint$marker_hash[[1L]] <- v3p_test_hash("e")
  expect_error(
    v3p_adjudicate_attempts(
      fixture$attempts,
      fixture$attempts,
      changed_fingerprint,
      fixture$manifest,
      "d1",
      binding,
      rep(v3p_test_hash("a"), nrow(fixture$attempts))
    ),
    "summary mismatch in marker_hash"
  )
  changed_truth <- fixture$attempts
  changed_truth$truth_sigma_g2[[1L]] <- 0.8
  expect_error(
    v3p_admit_d1_attempts(changed_truth, fixture$manifest, binding),
    "truth_sigma_g2"
  )
  changed_summary <- summary
  changed_summary$bias[[1L]] <- changed_summary$bias[[1L]] + 1e-4
  expect_error(
    v3p_adjudicate_summaries(summary, summary, changed_summary, "d1"),
    "summary mismatch in bias"
  )
  malformed_summary <- summary
  malformed_summary$cell_eligible <- as.character(
    malformed_summary$cell_eligible
  )
  malformed_summary$cell_eligible[[1L]] <- "maybe"
  expect_error(
    v3p_adjudicate_summaries(summary, summary, malformed_summary, "d1"),
    "summary mismatch in cell_eligible|invalid logical"
  )
})

test_that("attempt and Julia replay provenance bindings reject every forgery", {
  fixture <- v3p_test_d1()
  binding <- v3p_test_binding()
  attempt_fields <- c(
    r_implementation_commit = paste(rep("9", 40L), collapse = ""),
    julia_implementation_commit = paste(rep("8", 40L), collapse = ""),
    driver_commit = paste(rep("7", 40L), collapse = ""),
    preseal_sha256 = v3p_test_hash("6")
  )
  for (field in names(attempt_fields)) {
    changed <- fixture$attempts
    changed[[field]][[1L]] <- attempt_fields[[field]]
    expect_error(
      v3p_admit_d1_attempts(changed, fixture$manifest, binding),
      "provenance binding is invalid",
      info = paste("attempt provenance mutation", field)
    )
  }
  ordinary_wrong_driver <- fixture$attempts
  ordinary_wrong_driver$driver_commit[[1L]] <- binding$julia_replay_commit
  expect_error(
    v3p_admit_d1_attempts(
      ordinary_wrong_driver,
      fixture$manifest,
      binding
    ),
    "provenance binding is invalid"
  )

  replay <- v3p_test_julia_replay(fixture$attempts)
  source_hashes <- rep(v3p_test_hash("a"), nrow(replay))
  replay_fields <- c(
    source_r_attempt_sha256 = v3p_test_hash("9"),
    replay_julia_commit = paste(rep("8", 40L), collapse = ""),
    replay_driver_sha256 = v3p_test_hash("7"),
    manifest_sha256 = v3p_test_hash("6"),
    preseal_sha256 = v3p_test_hash("5"),
    corpus_lock_sha256 = v3p_test_hash("4")
  )
  for (field in names(replay_fields)) {
    changed <- replay
    changed[[field]][[1L]] <- replay_fields[[field]]
    expect_error(
      v3p_admit_julia_replay(
        changed,
        fixture$manifest,
        "d1",
        binding,
        source_hashes
      ),
      "provenance or source parity binding is invalid",
      info = paste("Julia replay provenance mutation", field)
    )
  }
  changed_difference <- replay
  changed_difference$source_r_max_abs_difference[[1L]] <- 1e-6
  expect_error(
    v3p_admit_julia_replay(
      changed_difference,
      fixture$manifest,
      "d1",
      binding,
      source_hashes
    ),
    "provenance or source parity binding is invalid"
  )
  replay_wrong_driver <- replay
  replay_wrong_driver$driver_commit[[1L]] <- binding$r_driver_commit
  expect_error(
    v3p_admit_julia_replay(
      replay_wrong_driver,
      fixture$manifest,
      "d1",
      binding,
      source_hashes
    ),
    "provenance binding is invalid"
  )
})

test_that("shared D1 summary parity fixture pins cross-twin semantics", {
  parity <- v3p_d1_summary_parity_fixture(v3p_test_binding())
  summary <- parity$summary
  expect_identical(
    v3p_test_tsv_hash(summary),
    "945ab4576b534420688190f6649d83cc476d3dfb0e4b6e56b35af1b1d5cb8087"
  )
  expected_first <- list(
    stage = "d1",
    cell_id = "n0120_m0060_q0500_r050",
    cell_index = 2L,
    n = 120L,
    m = 60L,
    marker_ratio = 0.5,
    truth_ratio = 0.5,
    n_expected = 48L,
    n_attempted = 48L,
    n_converged = 48L,
    n_bias_rows = 48L,
    n_interior = 45L,
    n_interior_rescued = 1L,
    n_boundary_lower = 1L,
    n_boundary_upper = 1L,
    n_unresolved = 0L,
    n_error = 0L,
    convergence_rate = 1,
    wilson_lower = 0.925899870333882,
    wilson_upper = 1,
    target = "sigma_g2",
    truth = 0.5,
    mean_estimate = 0.500095833333333,
    bias = 9.58333333333353e-05,
    mcse = 0.0148884905772755,
    bias_ci_lower = -0.0298559463492557,
    bias_ci_upper = 0.0300476130159223,
    margin = 0.025,
    rmse = 0.102070393907832,
    mcse_rmse = 0.0356952880225288,
    empirical_sd = 0.103150488511407,
    pilot_sd_upper = 0.12449065181588,
    required_n_raw = 382,
    required_n = 596,
    low_convergence = FALSE,
    summary_nonfinite = FALSE,
    precision_blocked = FALSE,
    futility_stopped = FALSE,
    target_futile = FALSE,
    cell_eligible = TRUE,
    cell_status = "ELIGIBLE",
    median_runtime_seconds = 24.5,
    p95_runtime_seconds = 45.65,
    median_peak_rss_mb = 124.5,
    p95_peak_rss_mb = 145.65,
    rms_se_info = 0.1,
    empirical_sd_over_rms_se_info = 1.03150488511407,
    predicted_boundary_lower = 2.86651571879194e-07,
    predicted_boundary_upper = 2.86651571923535e-07,
    observed_boundary_lower = 0.0208333333333333,
    observed_boundary_upper = 0.0208333333333333,
    mcse_boundary_lower = 0.0206151772344408,
    mcse_boundary_upper = 0.0206151772344408,
    mean_spectral_cv = 0.5,
    mean_effective_rank = 50,
    failure_classes = "none=48"
  )
  expect_identical(names(expected_first), v3p_d1_summary_columns)
  expect_equal(as.list(summary[1L, ]), expected_first, tolerance = 1e-14)
  expect_equal(nrow(summary), 36L)
  expect_true(all(summary$cell_status == "ELIGIBLE"))
  expect_true(all(summary$required_n == summary$required_n[[1L]]))
  expect_true(all(summary$required_n_raw == ceiling(summary$required_n_raw)))
  expect_true(all(summary$failure_classes == "none=48"))
  first <- summary[summary$cell_id == summary$cell_id[[1L]], ]
  expect_true(all(first$n_interior == 45L))
  expect_true(all(first$n_interior_rescued == 1L))
  expect_true(all(first$n_boundary_lower == 1L))
  expect_true(all(first$n_boundary_upper == 1L))
  expect_true(all(first$median_runtime_seconds == 24.5))
  expect_true(all(first$observed_boundary_lower == 1 / 48))
  expect_true(all(first$observed_boundary_upper == 1 / 48))
  expect_true(all(!first$low_convergence))
  expect_true(all(!first$summary_nonfinite))
  expect_true(all(!first$precision_blocked))
  expect_true(all(!first$futility_stopped))
})

test_that("D1 status precedence and independent reason flags stay fail closed", {
  downstream <- new.env(parent = globalenv())
  source(
    normalizePath(
      testthat::test_path(
        "..",
        "..",
        "tools",
        "v07_genomic_recovery_v3_downstream_contract.R"
      ),
      mustWork = TRUE
    ),
    local = downstream
  )
  fixture <- v3p_test_d1()
  binding <- v3p_test_binding()
  first_cell <- which(
    fixture$attempts$cell_id == fixture$manifest$cell_id[[1L]]
  )

  failed <- first_cell[1:3]
  low <- v3p_test_fail_rows(fixture$attempts, failed)
  low_summary <- v3p_d1_summary(fixture$manifest, low, binding)
  low_first <- low_summary[low_summary$cell_id == low_summary$cell_id[[1L]], ]
  expect_true(all(low_first$cell_status == "STOP_LOW_PILOT_CONVERGENCE"))
  expect_true(all(low_first$low_convergence))
  expect_true(all(!low_first$summary_nonfinite))
  expect_true(all(!low_first$precision_blocked))
  expect_true(all(!low_first$futility_stopped))
  expect_true(all(!low_first$target_futile))
  expect_true(all(!low_first$cell_eligible))
  expect_true(all(low_first$n_unresolved == 3L))
  expect_true(all(low_first$n_error == 0L))

  for (n_success in 0:1) {
    failed <- if (n_success == 0L) first_cell else first_cell[-1L]
    sparse <- v3p_test_fail_rows(fixture$attempts, failed)
    sparse_summary <- v3p_d1_summary(fixture$manifest, sparse, binding)
    sparse_first <- sparse_summary[
      sparse_summary$cell_id == sparse_summary$cell_id[[1L]],
    ]
    expect_true(all(sparse_first$cell_status == "STOP_LOW_PILOT_CONVERGENCE"))
    expect_true(all(sparse_first$low_convergence))
    expect_true(all(sparse_first$summary_nonfinite))
    expect_true(all(!sparse_first$precision_blocked))
    expect_true(all(!sparse_first$futility_stopped))
    expect_true(all(!sparse_first$target_futile))
    expect_true(all(!sparse_first$cell_eligible))
    expect_true(all(sparse_first$n_converged == n_success))
    expect_true(all(sparse_first$n_bias_rows == n_success))
    expect_silent(downstream$v3c_validate_d1_summary(sparse_summary))
    expect_silent(downstream$v3c_decisions_from_summary(sparse_summary, "d1"))
  }

  precision <- fixture$attempts
  wide <- rep(c(0.3, 0.7), length.out = length(first_cell))
  precision$scientific_ratio[first_cell] <- wide
  precision$scientific_sigma_g2[first_cell] <- wide
  precision$scientific_sigma_e2[first_cell] <- 1 - wide
  precision$numerical_ratio[first_cell] <- wide
  precision$numerical_sigma_g2[first_cell] <- wide
  precision$numerical_sigma_e2[first_cell] <- 1 - wide
  precision_summary <- v3p_d1_summary(fixture$manifest, precision, binding)
  precision_first <- precision_summary[
    precision_summary$cell_id == precision_summary$cell_id[[1L]],
  ]
  expect_true(all(precision_first$cell_status == "PRECISION_BLOCKER"))
  expect_true(all(precision_first$precision_blocked))

  futile <- fixture$attempts
  futile$scientific_ratio[first_cell] <- 0.55
  futile$scientific_sigma_g2[first_cell] <- 0.55
  futile$scientific_sigma_e2[first_cell] <- 0.45
  futile$numerical_ratio[first_cell] <- 0.55
  futile$numerical_sigma_g2[first_cell] <- 0.55
  futile$numerical_sigma_e2[first_cell] <- 0.45
  futile_summary <- v3p_d1_summary(fixture$manifest, futile, binding)
  futile_first <- futile_summary[
    futile_summary$cell_id == futile_summary$cell_id[[1L]],
  ]
  expect_true(all(futile_first$cell_status == "FUTILITY_STOP"))
  expect_true(all(futile_first$futility_stopped))

  nonfinite <- fixture$attempts
  nonfinite$se_info_r050[first_cell] <- 0
  expect_error(
    v3p_d1_summary(fixture$manifest, nonfinite, binding),
    "RECOMPUTATION_BLOCKER"
  )
  missing_se <- fixture$attempts
  missing_se$se_info_r050[first_cell[[1L]]] <- NA_real_
  expect_error(
    v3p_d1_summary(fixture$manifest, missing_se, binding),
    "malformed scientific output"
  )
  expect_false("recomputation_passed" %in% names(formals(v3p_d1_summary)))
  expect_error(v3p_admit_postrun(), "cannot admit postrun evidence")
})

test_that("D0F decomposition preserves negative between-panel variance", {
  fixture <- v3p_test_d0f()
  binding <- v3p_test_binding()
  centered <- rep(seq(-0.015, 0.015, length.out = 8L), 72L)
  fixture$attempts$scientific_ratio <- 0.5 + centered
  fixture$attempts$scientific_sigma_g2 <- 0.5 + centered
  fixture$attempts$scientific_sigma_e2 <- 0.5 - centered
  fixture$attempts$numerical_ratio <- 0.5 + centered
  fixture$attempts$numerical_sigma_g2 <- 0.5 + centered
  fixture$attempts$numerical_sigma_e2 <- 0.5 - centered
  bootstrap <- v3p_d0f_bootstrap_manifest(5L)
  summary <- v3p_d0f_summary(
    fixture$manifest,
    fixture$attempts,
    bootstrap,
    v3p_test_hash("f"),
    binding
  )
  expect_identical(names(summary), v3p_d0f_summary_columns)
  expect_equal(nrow(summary), 3L)
  expect_true(all(summary$variance_between < 0))
  expect_true(all(summary$d0f_status == "COMPLETE"))
  expect_true(all(!summary$fit_blocker))
  expect_silent(v3p_adjudicate_summaries(summary, summary, summary, "d0f"))

  changed <- summary
  changed$variance_between[[1L]] <- changed$variance_between[[1L]] + 1e-4
  expect_error(
    v3p_adjudicate_summaries(summary, changed, summary, "d0f"),
    "summary mismatch in variance_between"
  )
})

test_that("shared D0F summary parity fixture pins all typed fields", {
  parity <- v3p_d0f_summary_parity_fixture(v3p_test_binding())
  expect_identical(
    names(parity),
    c("manifest", "attempts", "bootstrap", "summary")
  )
  expect_equal(
    vapply(parity, nrow, integer(1L)),
    c(manifest = 576L, attempts = 576L, bootstrap = 360L, summary = 3L)
  )
  expect_identical(names(parity$manifest), v3p_d0f_phenotype_columns)
  expect_identical(names(parity$attempts), v3p_d0f_attempt_columns)
  expect_identical(names(parity$bootstrap), v3p_d0f_bootstrap_columns)
  expect_identical(names(parity$summary), v3p_d0f_summary_columns)
  expect_identical(
    v3p_test_tsv_hash(parity$manifest),
    "81f1f9547b2f190f8b54df1a44120967a5a71de5efcdfe7cc356d94fb8af69ec"
  )
  expect_identical(
    v3p_test_tsv_hash(parity$attempts),
    "f584604239cc6f11eb9ab002afa61be98dac8493715b4f741ac9ebde5787cbc6"
  )
  expect_identical(
    v3p_test_tsv_hash(parity$bootstrap),
    "0bd4293d14c76df136432ad098df6145cffa67c53ea0649091b1aafe648eb5e9"
  )
  expect_identical(
    v3p_test_tsv_hash(parity$summary),
    "f8af5c3312c9883e82109d49496e4054cc718ecdbfcddd0a136dfa6635a49b07"
  )
  expect_true(is.character(parity$summary$d0f_status))
  expect_true(is.logical(parity$summary$fit_blocker))
  expect_true(is.numeric(parity$summary$variance_within))
  expect_true(all(parity$summary$d0f_status == "COMPLETE"))
  expect_true(all(!parity$summary$fit_blocker))

  numeric_mutation <- parity$summary
  numeric_mutation$variance_within[[1L]] <-
    numeric_mutation$variance_within[[1L]] + 1e-4
  expect_error(
    v3p_adjudicate_summaries(
      parity$summary,
      numeric_mutation,
      parity$summary,
      "d0f"
    ),
    "summary mismatch in variance_within"
  )
  character_mutation <- parity$summary
  character_mutation$d0f_status[[1L]] <- "D0F_FIT_BLOCKER"
  expect_error(
    v3p_adjudicate_summaries(
      parity$summary,
      character_mutation,
      parity$summary,
      "d0f"
    ),
    "summary mismatch in d0f_status"
  )
  logical_mutation <- parity$summary
  logical_mutation$fit_blocker[[1L]] <- TRUE
  expect_error(
    v3p_adjudicate_summaries(
      parity$summary,
      logical_mutation,
      parity$summary,
      "d0f"
    ),
    "summary mismatch in fit_blocker"
  )
})

test_that("one D0F failure blocks all three decompositions without subsetting", {
  fixture <- v3p_test_d0f()
  binding <- v3p_test_binding()
  failed <- v3p_test_fail_rows(fixture$attempts, 1L)
  bootstrap <- v3p_d0f_bootstrap_manifest(3L)
  summary <- v3p_d0f_summary(
    fixture$manifest,
    failed,
    bootstrap,
    v3p_test_hash("f"),
    binding
  )
  expect_true(all(summary$d0f_status == "D0F_FIT_BLOCKER"))
  expect_true(all(summary$fit_blocker))
  unavailable <- c(
    "variance_within",
    "variance_within_bootstrap_lower",
    "variance_within_bootstrap_upper",
    "variance_between",
    "variance_between_bootstrap_lower",
    "variance_between_bootstrap_upper",
    "mean_ratio",
    "mcse_mean_ratio",
    "empirical_sd_ratio",
    "boundary_lower_proportion",
    "boundary_upper_proportion",
    "mcse_boundary_lower",
    "mcse_boundary_upper"
  )
  expect_true(all(is.na(unlist(summary[unavailable]))))
  expect_equal(sum(summary$n_attempted), 576L)
  expect_equal(sum(summary$n_converged), 575L)
  expect_equal(sum(summary$n_unresolved), 1L)
  expect_true(all(is.finite(summary$median_runtime_seconds)))
  expect_true(all(is.finite(summary$median_peak_rss_mb)))
})

test_that("environment, lowercase booleans, and create-once gates fail closed", {
  expect_identical(
    v3p_decode_command_path("/tmp/Github~+~Local/tool.R"),
    "/tmp/Github Local/tool.R"
  )
  environment <- v3p_environment_manifest(c(
    stage = "d1",
    host = "totoro",
    r_version = as.character(getRversion()),
    r_rng_kind = "Mersenne-Twister",
    r_normal_kind = "Inversion",
    r_sample_kind = "Rejection",
    julia_version = "1.10.0",
    openblas_num_threads = "1",
    julia_num_threads = "1",
    max_workers = "16"
  ))
  expect_identical(environment$key, v3p_environment_keys)
  forged_live <- environment
  forged_live$value[forged_live$key == "r_version"] <- "0.0.0"
  expect_silent(v3p_validate_environment(forged_live))
  expect_error(
    v3p_validate_environment_live(forged_live),
    "live|thread|host|toolchain"
  )
  expect_identical(v3p_bool(c("true", "false"), "x"), c(TRUE, FALSE))
  expect_error(v3p_bool(c("TRUE", "FALSE"), "x"), "invalid logical")
  workers <- environment
  workers$value[workers$key == "max_workers"] <- "97"
  expect_error(v3p_validate_environment(workers), "contract drift")
  root <- tempfile("v3p-test-once-")
  dir.create(root)
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  on.exit(unlink(root, recursive = TRUE), add = TRUE)
  expect_true(v3p_hex64(v3p_write_once(root, "manifest.tsv", environment)))
  expect_error(
    v3p_write_once(root, "manifest.tsv", environment),
    "create-once output exists"
  )
  expect_error(
    v3p_write_once(root, "../escape.tsv", environment),
    "safe basename"
  )

  link <- tempfile("v3p-link-")
  expect_true(file.symlink(root, link))
  on.exit(unlink(link), add = TRUE)
  expect_error(v3p_write_once(link, "x.tsv", environment), "real directory")
})

test_that("stage preseal verifies the exact existing tree and provenance", {
  fixture <- v3p_test_preseal_fixture()
  on.exit(unlink(fixture$base, recursive = TRUE), add = TRUE)
  expect_length(v3p_stage_preseal_keys, 42L)
  diagnostics_at <- match(
    "d0_diagnostics_sha256",
    v3p_stage_preseal_keys
  )
  expect_identical(
    v3p_stage_preseal_keys[c(diagnostics_at - 1L, diagnostics_at)],
    c("d0_adjudication_receipt_sha256", "d0_diagnostics_sha256")
  )
  expect_identical(
    v3p_stage_preseal_keys[c(diagnostics_at + 1L, diagnostics_at + 2L)],
    c("d0f_adjudication_root", "d0f_adjudication_receipt_sha256")
  )
  expect_identical(
    v3p_review_columns,
    c(
      "reviewer",
      "verdict",
      "doc49_sha256",
      "r_driver_commit",
      "r_recomputer_commit",
      "julia_replay_commit",
      "r_auto_route_commit",
      "julia_candidate_commit"
    )
  )
  expect_silent(v3p_test_validate_stage(
    fixture$preseal,
    fixture$context
  ))
})

test_that("D0F preseal tree excludes bootstrap until post-seal materialization", {
  root <- tempfile("v3p-bootstrap-order-")
  dir.create(root)
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  on.exit(unlink(root, recursive = TRUE), add = TRUE)
  dir.create(file.path(root, "receipts"))
  for (name in v3p_preseal_names("d0f", include_preseal = TRUE)) {
    v3p_test_pair(file.path(root, name), data.frame(x = 1))
  }
  expect_silent(v3p_verify_preseal_tree(
    root, "d0f", include_preseal = TRUE, bootstrap_materialized = FALSE
  ))
  v3p_test_pair(
    file.path(root, "d0f_bootstrap_indices.tsv"),
    data.frame(x = 1)
  )
  expect_error(
    v3p_verify_preseal_tree(
      root, "d0f", include_preseal = TRUE, bootstrap_materialized = FALSE
    ),
    "additional"
  )
  expect_silent(v3p_verify_preseal_tree(
    root, "d0f", include_preseal = TRUE, bootstrap_materialized = TRUE
  ))
})

test_that("D1 preseal requires one exact successful fresh-D0F adjudication", {
  valid <- v3p_test_preseal_fixture(write_preseal = FALSE)
  on.exit(unlink(valid$base, recursive = TRUE), add = TRUE)
  expected_hash <- v07d_sha256(valid$d0f_adjudication_path)
  env <- environment(v3p_validate_successful_d0f_adjudication)
  old_final <- get("v3p_validate_d0f_final_tree", envir = env, inherits = FALSE)
  assign(
    "v3p_validate_d0f_final_tree",
    function(root) invisible(TRUE),
    envir = env
  )
  on.exit(
    assign("v3p_validate_d0f_final_tree", old_final, envir = env),
    add = TRUE
  )
  expect_silent(v3p_validate_successful_d0f_adjudication(
    valid$d0f_adjudication_root,
    expected_hash,
    valid$stage_root
  ))
  expect_silent(v3p_test_validate_stage(
    valid$preseal,
    valid$context,
    include_preseal = FALSE
  ))

  missing_primary <- v3p_test_preseal_fixture(write_preseal = FALSE)
  on.exit(unlink(missing_primary$base, recursive = TRUE), add = TRUE)
  unlink(missing_primary$d0f_adjudication_path)
  expect_error(
    v3p_validate_successful_d0f_adjudication(
      missing_primary$d0f_adjudication_root,
      v3p_test_hash("a")
    ),
    "canonical plain path|primary is missing"
  )

  missing_sidecar <- v3p_test_preseal_fixture(write_preseal = FALSE)
  on.exit(unlink(missing_sidecar$base, recursive = TRUE), add = TRUE)
  unlink(paste0(missing_sidecar$d0f_adjudication_path, ".sha256"))
  expect_error(
    v3p_validate_successful_d0f_adjudication(
      missing_sidecar$d0f_adjudication_root,
      v07d_sha256(missing_sidecar$d0f_adjudication_path)
    ),
    "sidecar"
  )

  wrong_hash <- v3p_test_preseal_fixture(write_preseal = FALSE)
  on.exit(unlink(wrong_hash$base, recursive = TRUE), add = TRUE)
  expect_error(
    v3p_validate_successful_d0f_adjudication(
      wrong_hash$d0f_adjudication_root,
      v3p_test_hash("0")
    ),
    "hash mismatch|SHA-256"
  )

  blocked <- v3p_test_preseal_fixture(write_preseal = FALSE)
  on.exit(unlink(blocked$base, recursive = TRUE), add = TRUE)
  old_blocked_root <- v3p_d0f_blocked_root
  assign(
    "v3p_d0f_blocked_root",
    blocked$d0f_adjudication_root,
    envir = environment(v3p_validate_successful_d0f_adjudication)
  )
  on.exit(
    assign(
      "v3p_d0f_blocked_root",
      old_blocked_root,
      envir = environment(v3p_validate_successful_d0f_adjudication)
    ),
    add = TRUE
  )
  expect_error(
    v3p_validate_successful_d0f_adjudication(
      blocked$d0f_adjudication_root,
      v07d_sha256(blocked$d0f_adjudication_path)
    ),
    "blocked unadjudicated D0F root"
  )
  blocked_alias <- file.path(
    dirname(blocked$d0f_adjudication_root),
    "stage",
    "..",
    "d0f-adjudicated"
  )
  expect_error(
    v3p_validate_successful_d0f_adjudication(
      blocked_alias,
      v07d_sha256(blocked$d0f_adjudication_path)
    ),
    "canonical plain path|textual path is not canonical"
  )

  nested_root <- file.path(valid$stage_root, "nested-d0f")
  dir.create(nested_root)
  nested_path <- file.path(nested_root, "stage_adjudication_receipt.tsv")
  nested_hash <- v3p_test_pair(
    nested_path,
    v3p_test_d0f_adjudication_receipt()
  )
  expect_error(
    v3p_validate_successful_d0f_adjudication(
      normalizePath(nested_root, winslash = "/", mustWork = TRUE),
      nested_hash,
      valid$stage_root
    ),
    "distinct and nonnested"
  )
})

test_that("a forged receipt-only D0F root cannot admit D1", {
  forged <- v3p_test_preseal_fixture(write_preseal = FALSE)
  on.exit(unlink(forged$base, recursive = TRUE), add = TRUE)
  expect_error(
    v3p_validate_d0f_final_tree(forged$d0f_adjudication_root),
    "missing|file-set|tree|preseal"
  )
})

test_that("live preseal validation executes exact seed-space admission", {
  env <- environment(v07s_read_lock)
  old_lock <- get("v07s_expected_lock", envir = env, inherits = FALSE)
  collision <- old_lock[1L, , drop = FALSE]
  collision$contract_id <- "synthetic_live_collision"
  collision$source_docs <- "test"
  collision$formula_kind <- "exact"
  collision$seed_base <- as.character(v07s_expand_v3()$seed[[1L]])
  collision$cell_indices <- "0"
  collision$offset_start <- "0"
  collision$offset_end <- "0"
  collision$disposition <- "spent"
  assign("v07s_expected_lock", rbind(old_lock, collision), envir = env)
  on.exit(assign("v07s_expected_lock", old_lock, envir = env), add = TRUE)
  fixture <- v3p_test_preseal_fixture(write_preseal = FALSE)
  on.exit(unlink(fixture$base, recursive = TRUE), add = TRUE)
  expect_error(
    v3p_test_validate_stage(
      fixture$preseal,
      fixture$context,
      include_preseal = FALSE
    ),
    "overlap|collision|intersects"
  )
})

test_that("D1 rejects non-PASS, non-COMPLETE, and unadjudicated D0F receipts", {
  cases <- list(
    non_pass = list(verdict = "BLOCKED"),
    non_complete = list(stage_decision = "D0F_FIT_BLOCKER"),
    unadjudicated = list(
      schema_version = "v07-genomic-recovery-v3-adjudication-draft"
    ),
    wrong_stage = list(stage = "d1")
  )
  for (name in names(cases)) {
    fixture <- v3p_test_preseal_fixture(write_preseal = FALSE)
    on.exit(unlink(fixture$base, recursive = TRUE), add = TRUE)
    unlink(c(
      fixture$d0f_adjudication_path,
      paste0(fixture$d0f_adjudication_path, ".sha256")
    ))
    receipt <- do.call(v3p_test_d0f_adjudication_receipt, cases[[name]])
    hash <- v3p_test_pair(fixture$d0f_adjudication_path, receipt)
    expect_error(
      v3p_validate_successful_d0f_adjudication(
        fixture$d0f_adjudication_root,
        hash
      ),
      "not one adjudicated PASS/COMPLETE d0f row",
      info = name
    )
  }
})

test_that("stage preseal hard-freezes D0 and both candidate commits", {
  fixture <- v3p_test_preseal_fixture(write_preseal = FALSE)
  on.exit(unlink(fixture$base, recursive = TRUE), add = TRUE)
  expect_error(
    v3p_validate_d0_receipt_root(
      fixture$d0_root,
      v07d_sha256(file.path(fixture$d0_root, "receipt", "d0-check-log.md"))
    ),
    "differs from doc 49"
  )

  receipt_path <- file.path(fixture$stage_root, "receipts", "rose.tsv")
  receipt <- v07d_read_tsv(receipt_path, v3p_review_columns, verify = FALSE)
  unlink(c(receipt_path, paste0(receipt_path, ".sha256")))
  receipt$r_auto_route_commit[[1L]] <- paste(rep("a", 40L), collapse = "")
  receipt_hash <- v3p_test_pair(receipt_path, receipt)
  fixture$preseal$value[
    fixture$preseal$key == "rose_receipt_sha256"
  ] <- receipt_hash
  expect_error(
    v3p_test_validate_stage(
      fixture$preseal,
      fixture$context,
      include_preseal = FALSE
    ),
    "does not bind the exact preseal plan"
  )
  commit <- fixture$preseal$value[
    fixture$preseal$key == "r_driver_commit"
  ]
  expect_error(
    v3p_git_ancestor(
      fixture$git_root,
      paste(rep("0", 40L), collapse = ""),
      commit,
      "synthetic R"
    ),
    "not an ancestor"
  )

  diagnostics_mutation <- fixture$preseal
  diagnostics_mutation$value[
    diagnostics_mutation$key == "d0_diagnostics_sha256"
  ] <- v3p_test_hash("0")
  expect_error(
    v3p_test_validate_stage(
      diagnostics_mutation,
      fixture$context,
      include_preseal = FALSE
    ),
    "hash mismatch|SHA-256"
  )
})

test_that("candidate-to-deployed implementation surfaces cannot drift", {
  fixture <- v3p_test_preseal_fixture(write_preseal = FALSE)
  on.exit(unlink(fixture$base, recursive = TRUE), add = TRUE)
  before <- v3p_git_head(fixture$git_root)
  writeLines(
    c("synthetic R surface", "functional drift"),
    file.path(fixture$git_root, "R", "surface.R")
  )
  v3p_test_git(fixture$git_root, "add", "R/surface.R")
  v3p_test_git(
    fixture$git_root,
    "commit",
    "--quiet",
    "-m",
    "synthetic-drift"
  )
  after <- v3p_git_head(fixture$git_root)
  expect_silent(v3p_git_unchanged(
    fixture$git_root,
    before,
    after,
    file.path(fixture$git_root, c("DESCRIPTION", "NAMESPACE")),
    "unchanged R metadata"
  ))
  expect_error(
    v3p_git_unchanged(
      fixture$git_root,
      before,
      after,
      file.path(fixture$git_root, "R"),
      "R candidate implementation"
    ),
    "changed between candidate and deployed commits"
  )
})

test_that("stage preseal rejects extra directories and special files", {
  extra <- v3p_test_preseal_fixture()
  on.exit(unlink(extra$base, recursive = TRUE), add = TRUE)
  dir.create(file.path(extra$stage_root, "attempts"))
  expect_error(
    v3p_test_validate_stage(extra$preseal, extra$context),
    "missing, additional, nested, or special"
  )

  fifo <- v3p_test_preseal_fixture()
  on.exit(unlink(fifo$base, recursive = TRUE), add = TRUE)
  status <- system2(
    Sys.which("mkfifo"),
    file.path(fifo$stage_root, "unexpected")
  )
  expect_identical(status, 0L)
  expect_error(
    v3p_test_validate_stage(fifo$preseal, fifo$context),
    "missing, additional, nested, or special"
  )
})

test_that("stage preseal rejects symlink sidecars and noncanonical roots", {
  symlinked <- v3p_test_preseal_fixture()
  on.exit(unlink(symlinked$base, recursive = TRUE), add = TRUE)
  sidecar <- file.path(symlinked$stage_root, "doc49.md.sha256")
  unlink(sidecar)
  expect_true(file.symlink(
    file.path(symlinked$stage_root, "cell_table.tsv.sha256"),
    sidecar
  ))
  expect_error(
    v3p_test_validate_stage(symlinked$preseal, symlinked$context),
    "non-regular|canonical plain path|symlinked"
  )

  noncanonical <- v3p_test_preseal_fixture(write_preseal = FALSE)
  on.exit(unlink(noncanonical$base, recursive = TRUE), add = TRUE)
  at <- match("output_root", noncanonical$preseal$key)
  noncanonical$preseal$value[[at]] <- paste0(
    dirname(noncanonical$stage_root),
    "/stage/../stage"
  )
  expect_error(
    v3p_test_validate_stage(
      noncanonical$preseal,
      noncanonical$context,
      include_preseal = FALSE
    ),
    "textual path is not canonical"
  )
})

test_that("stage preseal rejects nested roots and forged pair hashes", {
  nested <- v3p_test_preseal_fixture(nested = TRUE)
  on.exit(unlink(nested$base, recursive = TRUE), add = TRUE)
  expect_error(
    v3p_test_validate_stage(nested$preseal, nested$context),
    "distinct and nonnested"
  )

  forged <- v3p_test_preseal_fixture(write_preseal = FALSE)
  on.exit(unlink(forged$base, recursive = TRUE), add = TRUE)
  forged$preseal$value[forged$preseal$key == "doc49_sha256"] <-
    v3p_test_hash("0")
  expect_error(
    v3p_test_validate_stage(
      forged$preseal,
      forged$context,
      include_preseal = FALSE
    ),
    "SHA-256 mismatch"
  )
})

test_that("stage preseal rejects empty primaries and dirty deployed worktrees", {
  empty <- v3p_test_preseal_fixture(write_preseal = FALSE)
  on.exit(unlink(empty$base, recursive = TRUE), add = TRUE)
  path <- file.path(empty$stage_root, "doc49.md")
  unlink(c(path, paste0(path, ".sha256")))
  empty_hash <- v3p_test_pair(path, "")
  empty$preseal$value[empty$preseal$key == "doc49_sha256"] <- empty_hash
  expect_error(
    v3p_test_validate_stage(
      empty$preseal,
      empty$context,
      include_preseal = FALSE
    ),
    "empty required primary|must both be nonempty"
  )

  dirty <- v3p_test_preseal_fixture(write_preseal = FALSE)
  on.exit(unlink(dirty$base, recursive = TRUE), add = TRUE)
  writeLines("dirty", file.path(dirty$git_root, "undeclared.txt"))
  expect_error(
    v3p_test_validate_stage(
      dirty$preseal,
      dirty$context,
      include_preseal = FALSE
    ),
    "worktree is dirty"
  )
})

test_that("stage preseal binds deployed bytes to the exact Git commit", {
  fixture <- v3p_test_preseal_fixture(write_preseal = FALSE)
  on.exit(unlink(fixture$base, recursive = TRUE), add = TRUE)
  path <- fixture$tool_paths[["r_driver"]]
  unlink(c(path, paste0(path, ".sha256")))
  changed_hash <- v3p_test_pair(path, "changed synthetic R driver\n")
  fixture$preseal$value[
    fixture$preseal$key == "r_driver_sha256"
  ] <- changed_hash
  relative <- "tools/v07_genomic_recovery_v3.R"
  v3p_test_git(
    fixture$git_root,
    "update-index",
    "--assume-unchanged",
    relative,
    paste0(relative, ".sha256")
  )
  expect_error(
    v3p_test_validate_stage(
      fixture$preseal,
      fixture$context,
      include_preseal = FALSE
    ),
    "not the exact committed tool"
  )
})
