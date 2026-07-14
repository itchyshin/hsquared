downstream_tool <- testthat::test_path(
  "..",
  "..",
  "tools",
  "v07_genomic_recovery_v3_downstream_contract.R"
)
testthat::skip_if_not(
  file.exists(downstream_tool),
  "repository-only recovery-v3 downstream contract is unavailable"
)
source(normalizePath(downstream_tool, mustWork = TRUE), local = TRUE)
v3c_load_dependencies()

v3ct_h64 <- function(x) paste(rep(x, 64L), collapse = "")
v3ct_h40 <- function(x) paste(rep(x, 40L), collapse = "")
v3ct_binding <- function() {
  list(
    preseal_sha256 = v3ct_h64("b"),
    manifest_sha256 = v3ct_h64("a"),
    corpus_lock_sha256 = v3ct_h64("c"),
    r_auto_route_commit = v3ct_h40("1"),
    julia_candidate_commit = v3ct_h40("2"),
    r_driver_commit = v3ct_h40("3"),
    julia_replay_commit = v3ct_h40("4"),
    julia_replay_sha256 = v3ct_h64("d"),
    r_recomputer_commit = v3ct_h40("5"),
    r_recomputer_sha256 = v3ct_h64("e")
  )
}

v3ct_write_pair <- function(path, value) {
  if (is.data.frame(value)) {
    old <- options(digits = 17)
    on.exit(options(old), add = TRUE)
    utils::write.table(
      value,
      path,
      sep = "\t",
      row.names = FALSE,
      quote = FALSE,
      na = "NA",
      fileEncoding = "UTF-8"
    )
  } else {
    writeLines(value, path, useBytes = TRUE)
  }
  sha <- v3c_sha256(path)
  writeLines(
    paste0(sha, "  ", basename(path)),
    paste0(path, ".sha256"),
    useBytes = TRUE
  )
  sha
}

v3ct_evidence_source <- function(stage, manifest, summary, tag = stage) {
  root <- tempfile(paste0("v3c-", tag, "-"))
  dir.create(root)
  validators <- v3c_fixture_validators(stage)
  r_validator <- validators[["r_validator"]]
  julia_validator <- validators[["julia_validator"]]
  r_validator_sha <- v3c_verify_pair(r_validator, "R validator")
  julia_validator_sha <- v3c_verify_pair(julia_validator, "Julia validator")
  manifest_sha <- v3ct_write_pair(
    file.path(root, paste0(stage, "_manifest.tsv")),
    manifest
  )
  corpus_sha <- v3ct_write_pair(
    file.path(root, "stage_corpus_lock.tsv"),
    data.frame(key = "attempt_inventory", value = v3ct_h64("9"))
  )
  r_summary_sha <- v3ct_write_pair(
    file.path(root, paste0(stage, "_summary_r.tsv")),
    summary
  )
  julia_summary_sha <- v3ct_write_pair(
    file.path(root, paste0(stage, "_summary_julia.tsv")),
    summary
  )
  preseal <- data.frame(
    key = c(
      "stage",
      "manifest_sha256",
      "r_recomputer_sha256",
      "julia_replay_sha256",
      "r_recomputer_commit",
      "julia_replay_commit",
      "output_root"
    ),
    value = c(
      stage,
      manifest_sha,
      r_validator_sha,
      julia_validator_sha,
      "2cb5308801efcd74ffac9b4b60c44c0356c7c0ea",
      "f7ff83855c4b4d14aad39516f37b7c1b5994b7ae",
      root
    ),
    stringsAsFactors = FALSE
  )
  preseal_sha <- v3ct_write_pair(file.path(root, "stage_preseal.tsv"), preseal)
  receipt <- data.frame(
    schema_version = "v07-genomic-recovery-v3-adjudication-1",
    stage = stage,
    verdict = "PASS",
    stage_decision = v3c_stage_decision_pilot(summary),
    preseal_sha256 = preseal_sha,
    manifest_sha256 = manifest_sha,
    corpus_lock_sha256 = corpus_sha,
    r_summary_sha256 = r_summary_sha,
    julia_summary_sha256 = julia_summary_sha,
    r_recomputer_sha256 = r_validator_sha,
    julia_replay_sha256 = julia_validator_sha,
    r_recomputer_commit = "2cb5308801efcd74ffac9b4b60c44c0356c7c0ea",
    julia_replay_commit = "f7ff83855c4b4d14aad39516f37b7c1b5994b7ae",
    stringsAsFactors = FALSE
  )
  v3ct_write_pair(file.path(root, "stage_adjudication_receipt.tsv"), receipt)
  list(
    root = root,
    r_validator = r_validator,
    julia_validator = julia_validator
  )
}

v3ct_fail_rows <- function(x, rows, error = "synthetic_fit_error") {
  x$converged[rows] <- FALSE
  x$status[rows] <- "fit_error"
  x$error_class[rows] <- error
  x$boundary_status[rows] <- NA_character_
  for (field in c(
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
    "gradient_norm"
  )) {
    x[[field]][rows] <- NA_real_
  }
  x$boundary_reason[rows] <- NA_character_
  x$boundary_epsilon[rows] <- NA_real_
  x
}

v3ct_downstream_preseal <- function(
  stage = "d2",
  root = tempdir(),
  k = 0L,
  predecessor_sha = v3ct_h64("6"),
  decision_sha = v3ct_h64("7")
) {
  hashes <- setNames(
    rep(v3ct_h64("a"), length(v3c_downstream_preseal_keys)),
    v3c_downstream_preseal_keys
  )
  values <- hashes
  values[c("schema_version", "stage")] <- c(
    v3c_downstream_preseal_schema,
    stage
  )
  values[c(
    "history_state",
    "history_batch_count",
    "current_sequence_index"
  )] <- c(
    if (stage == "d2") "ordered_prefix" else "terminal",
    as.character(k),
    if (stage == "d2") as.character(k + 1L) else "NA"
  )
  values[c("predecessor_lock_sha256", "pilot_decision_lock_sha256")] <-
    c(predecessor_sha, decision_sha)
  for (field in c(
    "downstream_contract_commit",
    "r_driver_commit",
    "r_recomputer_commit",
    "julia_replay_commit",
    "r_auto_route_commit",
    "julia_candidate_commit"
  )) {
    values[[field]] <- v3ct_h40("1")
  }
  values[c(
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
    normalizePath(root, mustWork = TRUE),
    "ordinary_auto_genomic",
    "julia_profile_replay",
    "v07-genomic-recovery-v3-packet-1",
    "v07-genomic-recovery-v3-truth-1",
    "markers",
    "vanraden1",
    "sample",
    "K_lambda",
    "0.01",
    "1e-7",
    "1e-8",
    "true"
  )
  data.frame(
    key = v3c_downstream_preseal_keys,
    value = unname(values[v3c_downstream_preseal_keys]),
    stringsAsFactors = FALSE
  )
}

v3ct_downstream_receipt <- function(stage = "d2") {
  values <- setNames(
    rep(v3ct_h64("b"), length(v3c_downstream_receipt_columns)),
    v3c_downstream_receipt_columns
  )
  values[c("schema_version", "stage", "verdict", "stage_decision")] <- c(
    v3c_downstream_receipt_schema,
    stage,
    "PASS",
    "ELIGIBLE=10"
  )
  for (field in c(
    "r_driver_commit",
    "r_recomputer_commit",
    "julia_replay_commit"
  )) {
    values[[field]] <- v3ct_h40("2")
  }
  values[c("attempt_max_abs_difference", "summary_max_abs_difference")] <- "0"
  as.data.frame(
    as.list(values[v3c_downstream_receipt_columns]),
    check.names = FALSE,
    stringsAsFactors = FALSE
  )
}

test_that("downstream schemas form a deterministic D2-D4 chain", {
  binding <- v3ct_binding()
  d1 <- v3c_fixture_d1_summary()
  d2_manifest <- v3c_fixture_expected_manifest("d2", d1)
  d2_attempts <- v3c_fixture_base_r_rows(d2_manifest, binding)
  d2_summary <- v3c_fixture_d2_summary(d2_manifest, d2_attempts, binding)
  d2_history <- list(
    d1_summary = d1,
    d2_summary = NULL,
    evidence_eligible = FALSE,
    fixture_only = TRUE
  )
  expect_identical(
    v3c_fixture_d2_summary_from_history(
      d2_manifest,
      d2_attempts,
      binding,
      d2_history
    ),
    d2_summary
  )
  expect_error(
    v3c_require_history_manifest(d2_manifest, "d2", d2_history),
    "not eligible"
  )
  late_cells <- v3_cell_table[
    v3_cell_table$n == 1200L & v3_cell_table$truth_ratio %in% c(0.2, 0.8),
    ,
    drop = FALSE
  ]
  late_manifest <- v3_manifest("d2", late_cells)
  expect_error(
    v3c_fixture_d2_summary_from_history(
      late_manifest,
      v3c_fixture_base_r_rows(late_manifest, binding),
      binding,
      d2_history
    ),
    "exact next manifest"
  )

  expect_identical(names(d2_manifest), v3c_manifest_columns)
  expect_identical(names(d2_attempts), v3c_base_r_columns)
  official_attempts <- v3c_fixture_official_attempts(d2_manifest, binding)
  expect_identical(names(official_attempts), v3c_official_attempt_columns)
  expect_false("corpus_lock_sha256" %in% names(official_attempts))
  expect_false("manifest_sha256" %in% names(official_attempts))
  expect_silent(v3c_validate_official_attempts(
    d2_manifest,
    official_attempts,
    binding
  ))
  julia_rows <- v3c_fixture_julia_replay_rows(d2_manifest, binding)
  expect_identical(names(julia_rows), v3c_julia_replay_columns)
  expect_silent(v3c_validate_base_r_rows(d2_manifest, d2_attempts, binding))
  expect_silent(v3c_validate_julia_replay_rows(
    d2_manifest,
    julia_rows,
    binding
  ))
  expect_equal(
    v3c_scientific_parity(official_attempts, d2_attempts, julia_rows),
    0
  )
  source_hashes <- rep(v3ct_h64("5"), nrow(official_attempts))
  expect_equal(
    v3c_validate_postlock_against_official(
      official_attempts,
      d2_attempts,
      source_hashes
    ),
    0
  )
  expect_equal(
    v3c_validate_postlock_against_official(
      official_attempts,
      julia_rows,
      source_hashes
    ),
    0
  )
  expect_true(any(julia_rows$runtime_seconds != d2_attempts$runtime_seconds))
  expect_true(any(julia_rows$route != d2_attempts$route))
  changed_science <- julia_rows
  changed_science$scientific_ratio[[1L]] <- changed_science$scientific_ratio[[
    1L
  ]] +
    2e-10
  expect_error(
    v3c_scientific_parity(official_attempts, d2_attempts, changed_science),
    "numeric parity drift"
  )
  bad_source <- d2_attempts
  bad_source$source_r_max_abs_difference[[1L]] <- 2e-10
  expect_error(
    v3c_validate_base_r_rows(d2_manifest, bad_source, binding),
    "source-attempt provenance"
  )
  bad_declared <- d2_attempts
  bad_declared$source_r_max_abs_difference[[1L]] <- 5e-11
  expect_error(
    v3c_validate_postlock_against_official(
      official_attempts,
      bad_declared,
      source_hashes
    ),
    "does not equal scientific parity"
  )
  cyclic_official <- official_attempts
  cyclic_official$corpus_lock_sha256 <- binding$corpus_lock_sha256
  expect_error(
    v3c_validate_official_attempts(d2_manifest, cyclic_official, binding),
    "schema or column order drift"
  )
  expect_identical(names(d2_summary), v3c_pilot_summary_columns)
  expect_equal(nrow(d2_manifest), 480L)
  expect_equal(length(unique(d2_manifest$cell_id)), 10L)
  expect_true(all(d2_summary$cell_eligible))
  expect_true(all(d2_summary$cell_status == "ELIGIBLE"))
  expect_true(all(d2_summary$required_n == 200L))
  expect_silent(v3c_validate_pilot_summary(d2_summary, d2_manifest))
  forged_sizing <- d2_summary
  forged_sizing$required_n[
    forged_sizing$cell_id == forged_sizing$cell_id[[1L]]
  ] <- 201
  expect_error(
    v3c_validate_pilot_summary(forged_sizing, d2_manifest),
    "sizing or reason fields"
  )
  forged_nonfinite <- d2_summary
  forged_nonfinite$summary_nonfinite[
    forged_nonfinite$cell_id == forged_nonfinite$cell_id[[1L]]
  ] <- TRUE
  expect_error(
    v3c_validate_pilot_summary(forged_nonfinite, d2_manifest),
    "sizing or reason fields"
  )

  d3_manifest <- v3c_fixture_expected_manifest("d3", d1, d2_summary)
  d4_manifest <- v3c_fixture_expected_manifest("d4", d1, d2_summary)
  d3_summary <- v3c_fixture_confirmation_summary(
    d3_manifest,
    v3c_fixture_base_r_rows(d3_manifest, binding),
    binding
  )
  d4_summary <- v3c_fixture_confirmation_summary(
    d4_manifest,
    v3c_fixture_base_r_rows(d4_manifest, binding),
    binding
  )
  expect_equal(nrow(d3_manifest), 1800L)
  expect_equal(nrow(d4_manifest), 1800L)
  expect_identical(names(d3_summary), v3c_confirmation_summary_columns)
  expect_true(all(d3_summary$cell_pass))
  expect_true(all(d4_summary$cell_pass))
  expect_true(all(d3_summary$cell_status == "PASS"))
  one_triplet_cells <- v3_cell_table[
    v3_cell_table$n == 120L & v3_cell_table$m == 600L,
    ,
    drop = FALSE
  ]
  one_triplet_required <- setNames(
    rep(200L, nrow(one_triplet_cells)),
    one_triplet_cells$cell_id
  )
  one_triplet_d3 <- v3_manifest("d3", one_triplet_cells, one_triplet_required)
  expect_silent(v3c_validate_manifest(one_triplet_d3, "d3"))
  one_triplet_summary <- v3c_fixture_confirmation_summary(
    one_triplet_d3,
    v3c_fixture_base_r_rows(one_triplet_d3, binding),
    binding
  )
  expect_identical(unique(one_triplet_summary$stage_decision), "D3_PASS")
  expect_identical(length(unique(one_triplet_summary$triplet_id)), 1L)
  one_triplet_d4 <- v3_manifest("d4", one_triplet_cells, one_triplet_required)
  expect_error(
    v3c_validate_manifest(one_triplet_d4, "d4"),
    "D4 must contain exactly three complete original truth triplets"
  )
  confirmation_history <- list(
    d1_summary = d1,
    d2_summary = d2_summary,
    evidence_eligible = FALSE,
    fixture_only = TRUE
  )
  expect_identical(
    v3c_fixture_confirmation_summary_from_history(
      d4_manifest,
      v3c_fixture_base_r_rows(d4_manifest, binding),
      binding,
      confirmation_history
    ),
    d4_summary
  )
  expect_error(
    v3c_fixture_confirmation_summary_from_history(
      d4_manifest,
      v3c_fixture_base_r_rows(d4_manifest, binding),
      binding,
      list(
        d1_summary = d1,
        d2_summary = NULL,
        evidence_eligible = FALSE,
        fixture_only = TRUE
      )
    ),
    "D2|selected|decision|manifest|eligible pilot"
  )
  expect_length(intersect(d2_manifest$seed, d3_manifest$seed), 0L)
  expect_length(intersect(d3_manifest$seed, d4_manifest$seed), 0L)

  bad_manifest <- d3_manifest
  bad_manifest$seed[[1L]] <- bad_manifest$seed[[1L]] + 1L
  expect_error(v3c_validate_manifest(bad_manifest, "d3"), "seed|canonical")
  reordered <- d2_manifest[c(2L, 1L, seq.int(3L, nrow(d2_manifest))), ]
  expect_error(v3c_validate_manifest(reordered, "d2"), "rows or order")
  standalone_d4 <- v3_manifest(
    "d4",
    v3_cell_table[
      v3_cell_table$cell_id == "n0120_m0600_q5000_r020",
      ,
      drop = FALSE
    ],
    setNames(200L, "n0120_m0600_q5000_r020")
  )
  expect_error(
    v3c_validate_manifest(standalone_d4, "d4"),
    "complete.*truth triplets"
  )
  expect_error(
    v3c_validate_base_r_rows(d2_manifest, d2_attempts[-1L, ], binding),
    "exact manifest denominator"
  )
  inconsistent <- d2_attempts
  inconsistent$scientific_sigma_g2[[1L]] <- inconsistent$scientific_sigma_g2[[
    1L
  ]] +
    0.01
  expect_error(
    v3c_validate_base_r_rows(d2_manifest, inconsistent, binding),
    "malformed scientific output|internally inconsistent"
  )
  bad_hash <- d2_attempts
  bad_hash$kernel_hash[[1L]] <- "not-a-hash"
  expect_error(
    v3c_validate_base_r_rows(d2_manifest, bad_hash, binding),
    "construction"
  )
  bad_kkt <- d2_attempts
  bad_kkt$lower_derivative_per_observation[[1L]] <- -1
  expect_error(
    v3c_validate_base_r_rows(d2_manifest, bad_kkt, binding),
    "malformed scientific output|KKT|derivative"
  )
  bad_scale <- d2_attempts
  bad_scale$relationship_scale[[1L]] <- "G"
  expect_error(
    v3c_validate_base_r_rows(d2_manifest, bad_scale, binding),
    "malformed scientific output|metadata|scale"
  )
})

test_that("downstream preseal, receipt, review, and lock schemas are exact", {
  root <- tempfile("v3c-lock-")
  dir.create(root)
  root <- normalizePath(root, mustWork = TRUE)
  predecessor <- as.data.frame(
    setNames(
      replicate(
        length(v3c_predecessor_lock_columns),
        "NA",
        simplify = FALSE
      ),
      v3c_predecessor_lock_columns
    ),
    stringsAsFactors = FALSE
  )
  predecessor$stage <- "d2"
  predecessor$sequence_index <- 0L
  predecessor$role <- "interior_pilot"
  predecessor$source_stage <- "d1"
  predecessor$source_batch <- "d1"
  predecessor$source_root <- "/canonical/d1"
  for (field in setdiff(
    v3c_predecessor_lock_columns,
    c(
      "stage",
      "sequence_index",
      "role",
      "source_stage",
      "source_batch",
      "source_root"
    )
  )) {
    predecessor[[field]] <- v3ct_h64("1")
  }
  decision <- as.data.frame(
    setNames(
      replicate(
        length(v3c_pilot_decision_lock_columns),
        "NA",
        simplify = FALSE
      ),
      v3c_pilot_decision_lock_columns
    ),
    stringsAsFactors = FALSE
  )
  decision$stage <- "d2"
  decision$sequence_index <- 0L
  decision$source_stage <- "d1"
  decision$source_batch <- "d1"
  decision$selection_role <- "interior_pilot"
  decision$cell_id <- "n0120_m0060_q0500_r050"
  decision$eligible <- TRUE
  decision$required_n <- 200L
  decision$required_n_source_target <- "ratio"
  decision$source_summary_sha256 <- v3ct_h64("2")
  predecessor_sha <- v3ct_write_pair(
    file.path(root, "predecessor_lock.tsv"),
    predecessor
  )
  decision_sha <- v3ct_write_pair(
    file.path(root, "pilot_decision_lock.tsv"),
    decision
  )
  preseal <- v3ct_downstream_preseal(
    "d2",
    root,
    0L,
    predecessor_sha,
    decision_sha
  )
  parsed <- v3c_validate_downstream_preseal(preseal, root)
  expect_identical(parsed$history_batch_count, 0L)
  expect_silent(v3c_read_downstream_locks(root, parsed))

  bad_index <- preseal
  bad_index$value[bad_index$key == "current_sequence_index"] <- "2"
  expect_error(v3c_validate_downstream_preseal(bad_index, root), "k[+]1")
  d3 <- v3ct_downstream_preseal("d3", root, 2L, predecessor_sha, decision_sha)
  expect_silent(v3c_validate_downstream_preseal(d3, root))
  d3_path <- file.path(root, "d3_preseal.tsv")
  v3ct_write_pair(d3_path, d3)
  d3_disk <- v3c_read_tsv_pair(
    d3_path,
    c("key", "value"),
    "D3 preseal"
  )$table
  expect_true(is.na(d3_disk$value[d3_disk$key == "current_sequence_index"]))
  expect_silent(v3c_validate_downstream_preseal(d3_disk, root))
  bad_terminal <- d3
  bad_terminal$value[bad_terminal$key == "current_sequence_index"] <- "3"
  expect_error(
    v3c_validate_downstream_preseal(bad_terminal, root),
    "terminal history"
  )
  alias_root <- tempfile("v3c-root-alias-")
  expect_true(file.symlink(root, alias_root))
  alias_preseal <- preseal
  alias_preseal$value[alias_preseal$key == "output_root"] <- alias_root
  expect_error(
    v3c_validate_downstream_preseal(alias_preseal, root),
    "output root drift"
  )

  forged <- predecessor
  forged$role <- "forged"
  v3ct_write_pair(file.path(root, "predecessor_lock.tsv"), forged)
  expect_error(v3c_read_downstream_locks(root, parsed), "preseal binding")

  receipt <- v3ct_downstream_receipt()
  expect_silent(v3c_validate_downstream_receipt(receipt, "d2"))
  reordered <- receipt[rev(names(receipt))]
  expect_error(
    v3c_validate_downstream_receipt(reordered, "d2"),
    "schema or column order"
  )
  blocker <- receipt
  blocker$stage_decision <- "RECOMPUTATION_BLOCKER"
  expect_error(v3c_validate_downstream_receipt(blocker, "d2"), "verdict drift")

  plan <- data.frame(
    reviewer = "hopper",
    verdict = "CLEAN",
    doc49_sha256 = v3ct_h64("1"),
    r_driver_commit = v3ct_h40("1"),
    r_recomputer_commit = v3ct_h40("2"),
    julia_replay_commit = v3ct_h40("3"),
    r_auto_route_commit = v3ct_h40("4"),
    julia_candidate_commit = v3ct_h40("5"),
    stringsAsFactors = FALSE
  )[v3c_plan_review_columns]
  expect_silent(v3c_validate_plan_review(plan))
  expect_error(
    v3c_validate_plan_review(plan[rev(names(plan))]),
    "schema or column order"
  )

  review <- data.frame(
    schema_version = v3c_postrun_review_schema,
    stage = "d2",
    reviewer = "fisher",
    verdict = "CLEAN",
    stage_decision = receipt$stage_decision,
    preseal_sha256 = receipt$preseal_sha256,
    predecessor_lock_sha256 = receipt$predecessor_lock_sha256,
    pilot_decision_lock_sha256 = receipt$pilot_decision_lock_sha256,
    manifest_sha256 = receipt$manifest_sha256,
    corpus_lock_sha256 = receipt$corpus_lock_sha256,
    base_r_inventory_sha256 = receipt$base_r_inventory_sha256,
    julia_inventory_sha256 = receipt$julia_inventory_sha256,
    r_summary_sha256 = receipt$r_summary_sha256,
    julia_summary_sha256 = receipt$julia_summary_sha256,
    r_driver_commit = receipt$r_driver_commit,
    r_recomputer_commit = receipt$r_recomputer_commit,
    julia_replay_commit = receipt$julia_replay_commit,
    reviewed_at_utc = "2026-07-14T12:00:00Z",
    stringsAsFactors = FALSE
  )[v3c_postrun_review_columns]
  expect_silent(v3c_validate_postrun_review(review, receipt))
  stale <- review
  stale$corpus_lock_sha256 <- v3ct_h64("f")
  expect_error(
    v3c_validate_postrun_review(stale, receipt),
    "exact adjudicated evidence"
  )
  stale_driver <- review
  stale_driver$r_driver_commit <- v3ct_h40("f")
  expect_error(
    v3c_validate_postrun_review(stale_driver, receipt),
    "exact adjudicated evidence"
  )
  expect_error(
    v3c_validate_postrun_review(review, receipt, "rose"),
    "identity or verdict"
  )
})

test_that("canonical pairs and declared Git blobs fail closed", {
  repo <- tempfile("v3c-git-")
  dir.create(repo)
  repo <- normalizePath(repo, mustWork = TRUE)
  v3c_git_run(repo, c("init", "--quiet"), "synthetic init")
  v3c_git_run(
    repo,
    c("config", "user.email", "synthetic@example.invalid"),
    "synthetic email"
  )
  v3c_git_run(repo, c("config", "user.name", "synthetic"), "synthetic name")
  primary <- file.path(repo, "validator.R")
  sha <- v3ct_write_pair(primary, "validator v1")
  expect_identical(v3c_verify_pair(primary, "synthetic validator"), sha)

  writeLines(paste0(sha, "  wrong-name trailing"), paste0(primary, ".sha256"))
  expect_error(v3c_verify_pair(primary, "synthetic validator"), "sidecar")
  writeLines(paste0(sha, "  ", basename(primary)), paste0(primary, ".sha256"))
  alias <- file.path(repo, "alias.R")
  expect_true(file.symlink(primary, alias))
  expect_error(
    v3c_verify_pair(alias, "synthetic alias"),
    "canonical plain file"
  )

  v3c_git_run(
    repo,
    c("add", "validator.R", "validator.R.sha256"),
    "synthetic add"
  )
  v3c_git_run(
    repo,
    c("commit", "--quiet", "-m", "validator"),
    "synthetic commit"
  )
  commit <- v3c_git_run(repo, c("rev-parse", "HEAD"), "synthetic head")[[1L]]
  expect_silent(v3c_verify_git_tool(
    repo,
    primary,
    commit,
    sha,
    "synthetic validator"
  ))
  expect_silent(v3c_require_git_head(repo, commit, "synthetic toolchain"))
  note <- file.path(repo, "note.txt")
  writeLines("tooling note", note)
  v3c_git_run(repo, c("add", "note.txt"), "synthetic note add")
  v3c_git_run(
    repo,
    c("commit", "--quiet", "-m", "note"),
    "synthetic note commit"
  )
  note_commit <- v3c_git_run(
    repo,
    c("rev-parse", "HEAD"),
    "synthetic note head"
  )[[1L]]
  expect_error(
    v3c_require_git_head(repo, commit, "synthetic toolchain"),
    "deployed HEAD"
  )
  expect_silent(v3c_require_git_unchanged(
    repo,
    commit,
    note_commit,
    primary,
    "synthetic implementation"
  ))
  new_sha <- v3ct_write_pair(primary, "validator v2")
  v3c_git_run(
    repo,
    c("add", "validator.R", "validator.R.sha256"),
    "synthetic changed add"
  )
  v3c_git_run(
    repo,
    c("commit", "--quiet", "-m", "changed validator"),
    "synthetic changed commit"
  )
  changed_commit <- v3c_git_run(
    repo,
    c("rev-parse", "HEAD"),
    "synthetic changed head"
  )[[1L]]
  expect_error(
    v3c_verify_git_tool(repo, primary, commit, new_sha, "synthetic validator"),
    "declared commit blob"
  )
  expect_error(
    v3c_require_git_unchanged(
      repo,
      commit,
      changed_commit,
      primary,
      "synthetic implementation"
    ),
    "Git verification failed"
  )
})

test_that("D2 pilot status precedence is low convergence then precision then futility", {
  binding <- v3ct_binding()
  d1 <- v3c_fixture_d1_summary()
  manifest <- v3c_fixture_expected_manifest("d2", d1)
  base <- v3c_fixture_base_r_rows(manifest, binding)
  id <- manifest$cell_id[[1L]]
  rows <- which(base$cell_id == id)

  low <- v3ct_fail_rows(base, rows[1:3])
  low_summary <- v3c_fixture_d2_summary(manifest, low, binding)
  low_cell <- low_summary[low_summary$cell_id == id, ]
  expect_true(all(low_cell$low_convergence))
  expect_true(all(low_cell$cell_status == "STOP_LOW_PILOT_CONVERGENCE"))
  expect_false(any(low_cell$cell_eligible))

  precision <- base
  delta <- seq(-0.18, 0.18, length.out = length(rows))
  precision$scientific_sigma_g2[rows] <- manifest$truth_sigma_g2[[1L]] + delta
  precision$scientific_sigma_e2[rows] <- manifest$truth_sigma_e2[[1L]] - delta
  precision$scientific_ratio[rows] <- precision$scientific_sigma_g2[rows]
  precision_summary <- v3c_fixture_d2_summary(manifest, precision, binding)
  precision_cell <- precision_summary[precision_summary$cell_id == id, ]
  expect_true(all(precision_cell$precision_blocked))
  expect_true(all(precision_cell$cell_status == "PRECISION_BLOCKER"))

  futile <- base
  futile$scientific_sigma_g2[rows] <- futile$scientific_sigma_g2[rows] + 0.03
  futile$scientific_sigma_e2[rows] <- futile$scientific_sigma_e2[rows] - 0.03
  futile$scientific_ratio[rows] <- futile$scientific_ratio[rows] + 0.03
  futile_summary <- v3c_fixture_d2_summary(manifest, futile, binding)
  futile_cell <- futile_summary[futile_summary$cell_id == id, ]
  expect_false(any(futile_cell$precision_blocked))
  expect_true(all(futile_cell$futility_stopped))
  expect_true(all(futile_cell$cell_status == "FUTILITY_STOP"))

  precedence <- v3ct_fail_rows(precision, rows[1:3])
  precedence_summary <- v3c_fixture_d2_summary(manifest, precedence, binding)
  expect_true(all(
    precedence_summary$cell_status[precedence_summary$cell_id == id] ==
      "STOP_LOW_PILOT_CONVERGENCE"
  ))

  one_success <- v3ct_fail_rows(base, rows[1:47])
  blocker_summary <- v3c_fixture_d2_summary(
    manifest,
    one_success,
    binding
  )
  expect_true(all(blocker_summary$summary_nonfinite[
    blocker_summary$cell_id == id
  ]))
  expect_match(
    v3c_stage_decision_pilot(blocker_summary),
    "STOP_LOW_PILOT_CONVERGENCE"
  )
  expect_true(all(
    blocker_summary$cell_status[blocker_summary$cell_id == id] ==
      "STOP_LOW_PILOT_CONVERGENCE"
  ))
  expect_false(any(blocker_summary$cell_eligible[
    blocker_summary$cell_id == id
  ]))
  expect_silent(v3c_decisions_from_summary(blocker_summary, "d2"))

  no_success <- v3ct_fail_rows(base, rows)
  no_success_summary <- v3c_fixture_d2_summary(manifest, no_success, binding)
  expect_true(all(no_success_summary$summary_nonfinite[
    no_success_summary$cell_id == id
  ]))
  expect_true(all(
    no_success_summary$cell_status[no_success_summary$cell_id == id] ==
      "STOP_LOW_PILOT_CONVERGENCE"
  ))
  expect_silent(v3c_decisions_from_summary(no_success_summary, "d2"))

  valid <- v3c_fixture_d2_summary(manifest, base, binding)
  for (field in c(
    "convergence_rate",
    "wilson_lower",
    "wilson_upper",
    "observed_boundary_lower",
    "observed_boundary_upper",
    "mcse_boundary_lower",
    "mcse_boundary_upper"
  )) {
    forged <- valid
    forged[[field]][forged$cell_id == id] <-
      forged[[field]][forged$cell_id == id] + 1e-4
    expect_error(
      v3c_validate_pilot_summary(forged, manifest),
      "convergence rate|Wilson|boundary proportion|MCSE"
    )
  }
  bad_count <- valid
  bad_count$n_interior[bad_count$cell_id == id] <-
    bad_count$n_interior[bad_count$cell_id == id] - 1L
  expect_error(
    v3c_validate_pilot_summary(bad_count, manifest),
    "denominator drift"
  )
  bad_failure_total <- valid
  bad_failure_total$failure_classes[
    bad_failure_total$cell_id == id
  ] <- "none=47"
  expect_error(
    v3c_validate_pilot_summary(bad_failure_total, manifest),
    "failure_classes totals"
  )
})

test_that("D3-D4 confirmation uses strict bias, convergence, and Wilson gates", {
  binding <- v3ct_binding()
  d1 <- v3c_fixture_d1_summary()
  d2m <- v3c_fixture_expected_manifest("d2", d1)
  d2s <- v3c_fixture_d2_summary(
    d2m,
    v3c_fixture_base_r_rows(d2m, binding),
    binding
  )
  manifest <- v3c_fixture_expected_manifest("d3", d1, d2s)
  base <- v3c_fixture_base_r_rows(manifest, binding)
  id <- manifest$cell_id[[1L]]
  rows <- which(base$cell_id == id)

  biased <- base
  biased$scientific_sigma_g2[rows] <- biased$scientific_sigma_g2[rows] + 0.03
  biased$scientific_sigma_e2[rows] <- biased$scientific_sigma_e2[rows] - 0.03
  biased$scientific_ratio[rows] <- biased$scientific_ratio[rows] + 0.03
  biased_summary <- v3c_fixture_confirmation_summary(manifest, biased, binding)
  expect_true(all(
    biased_summary$cell_status[biased_summary$cell_id == id] ==
      "FAIL_BIAS_EQUIVALENCE"
  ))

  low <- v3ct_fail_rows(base, rows[1:12])
  low_summary <- v3c_fixture_confirmation_summary(manifest, low, binding)
  low_cell <- low_summary[low_summary$cell_id == id, ]
  expect_equal(unique(low_cell$convergence_rate), 0.94)
  expect_false(any(low_cell$cell_convergence_pass))
  expect_true(all(low_cell$cell_status == "FAIL_CONVERGENCE"))

  forged <- biased_summary
  hit <- which(forged$cell_id == id & forged$target == "ratio")
  forged$bias_ci_lower[hit] <- -forged$margin[hit]
  forged$target_bias_pass[hit] <- TRUE
  expect_error(v3c_validate_confirmation_summary(forged), "strict gate")
  wrong_truth <- biased_summary
  wrong_truth$margin[[1L]] <- wrong_truth$margin[[1L]] * 2
  expect_error(
    v3c_validate_confirmation_summary(wrong_truth),
    "truth or margin"
  )
  wrong_stage <- biased_summary
  wrong_stage$stage_decision <- "D3_PASS"
  expect_error(
    v3c_validate_confirmation_summary(wrong_stage),
    "triplet, campaign, or stage decision"
  )
  wrong_triplet <- biased_summary
  wrong_triplet$triplet_id[wrong_triplet$cell_id == id] <- "caller_group"
  expect_error(
    v3c_validate_confirmation_summary(wrong_triplet),
    "cell rows are inconsistent"
  )
  for (field in c(
    "convergence_rate",
    "wilson_lower",
    "wilson_upper",
    "observed_boundary_lower",
    "observed_boundary_upper",
    "mcse_boundary_lower",
    "mcse_boundary_upper"
  )) {
    mutated <- biased_summary
    mutated[[field]][mutated$cell_id == id] <-
      mutated[[field]][mutated$cell_id == id] + 1e-4
    expect_error(
      v3c_validate_confirmation_summary(mutated),
      "convergence rate|Wilson|boundary proportion|MCSE"
    )
  }
  bad_total <- biased_summary
  bad_total$n_error[bad_total$cell_id == id] <- 1L
  expect_error(
    v3c_validate_confirmation_summary(bad_total),
    "denominator drift"
  )
  bad_failures <- biased_summary
  bad_failures$failure_classes[bad_failures$cell_id == id] <- "none=199"
  expect_error(
    v3c_validate_confirmation_summary(bad_failures),
    "failure_classes totals"
  )
})

test_that("predecessor and pilot-decision locks derive from authenticated bytes", {
  d1 <- v3c_fixture_d1_summary()
  forged_d1 <- d1
  forged_d1$required_n[forged_d1$cell_id == forged_d1$cell_id[[1L]]] <- 201
  expect_error(
    v3c_fixture_expected_manifest("d2", forged_d1),
    "D1 sizing, status, or reason fields"
  )
  binding <- v3ct_binding()
  d2m <- v3c_fixture_expected_manifest("d2", d1)
  d2s <- v3c_fixture_d2_summary(
    d2m,
    v3c_fixture_base_r_rows(d2m, binding),
    binding
  )
  d1_source <- v3ct_evidence_source("d1", v3_d1_manifest(), d1, "d1")
  d2_source <- v3ct_evidence_source("d2", d2m, d2s, "d2")
  history <- v3c_fixture_evidence_history("d3", d1_source, list(d2_source))
  lock <- v3c_predecessor_lock_from_history("d3", history)
  expect_identical(lock$sequence_index, 0:1)
  expect_identical(lock$source_batch, c("d1", "d2_batch_001"))
  expect_true(all(
    c("ladder", "broad") %in% strsplit(lock$role[[2L]], ",")[[1L]]
  ))
  expect_error(
    v3c_predecessor_lock("d3", d1_source, list(d2_source)),
    "independent frozen-validator reconstruction"
  )
  expect_error(
    v3c_read_evidence_root(d2_source, "d2"),
    "dedicated validators land"
  )
  expect_error(v3c_default_validators("d3"), "dedicated validators land")
  expect_error(v3c_default_validators("d4"), "dedicated validators land")
  caller_selected <- d1_source
  caller_selected$r_validator <- d2_source$r_validator
  expect_error(
    v3c_fixture_read_evidence_root(caller_selected, "d1"),
    "caller-selected validator paths"
  )
  internally_forged <- d1
  first_id <- internally_forged$cell_id[[1L]]
  internally_forged$required_n_raw[internally_forged$cell_id == first_id] <- 201
  internally_forged$required_n[internally_forged$cell_id == first_id] <- 201
  forged_source <- v3ct_evidence_source(
    "d1",
    v3_d1_manifest(),
    internally_forged,
    "forged-d1"
  )
  expect_silent(v3c_fixture_read_evidence_root(d1_source, "d1"))
  expect_silent(v3c_fixture_read_evidence_root(forged_source, "d1"))
  expect_error(
    v3c_read_evidence_root(forged_source, "d1"),
    "independent frozen-validator reconstruction"
  )
  expect_identical(
    v3c_fixture_expected_manifest("d3", history$d1_summary, history$d2_summary),
    v3c_fixture_expected_manifest("d3", d1, d2s)
  )
  changed <- lock
  changed$r_summary_sha256[[2L]] <- v3ct_h64("2")
  expect_false(identical(
    changed,
    v3c_predecessor_lock_from_history("d3", history)
  ))

  decisions <- v3c_pilot_decision_lock_from_history("d3", history)
  expect_true(all(
    decisions$required_n_source_target %in%
      c("ratio", "sigma_e2", "sigma_g2", "ratio+sigma_e2+sigma_g2")
  ))
  expect_true(any(decisions$selection_role == "broad+ladder"))
  expect_identical(
    decisions,
    v3c_pilot_decision_lock_from_history("d3", history)
  )
  forged <- decisions
  forged$eligible[[1L]] <- !forged$eligible[[1L]]
  expect_false(identical(
    forged,
    v3c_pilot_decision_lock_from_history("d3", history)
  ))

  writeLines("forged", file.path(d2_source$root, "d2_summary_r.tsv"))
  expect_error(
    v3c_fixture_evidence_history("d3", d1_source, list(d2_source)),
    "SHA-256 sidecar does not match bytes"
  )
})

test_that("typed attempt and summary parity fail on scientific mutations", {
  binding <- v3ct_binding()
  d1 <- v3c_fixture_d1_summary()
  manifest <- v3c_fixture_expected_manifest("d2", d1)
  attempts <- v3c_fixture_base_r_rows(manifest, binding)
  near <- attempts
  near$runtime_seconds[[1L]] <- near$runtime_seconds[[1L]] + 5e-11
  expect_lte(v3c_base_r_parity(attempts, near), 1e-10)
  far <- attempts
  far$runtime_seconds[[1L]] <- far$runtime_seconds[[1L]] + 2e-10
  expect_error(v3c_base_r_parity(attempts, far), "numeric parity drift")
  logical <- attempts
  logical$converged[[1L]] <- FALSE
  expect_error(v3c_base_r_parity(attempts, logical), "exact parity drift")

  summary <- v3c_fixture_d2_summary(manifest, attempts, binding)
  changed <- summary
  changed$bias[[1L]] <- changed$bias[[1L]] + 2e-10
  expect_error(v3c_summary_parity(summary, changed), "numeric parity drift")
})

test_that("ordered D2 history cannot omit or reorder an adjudicated ladder batch", {
  binding <- v3ct_binding()
  d1 <- v3c_fixture_d1_summary()
  d1_source <- v3ct_evidence_source("d1", v3_d1_manifest(), d1, "history-d1")
  first_manifest <- v3c_fixture_expected_manifest("d2", d1)
  first_attempts <- v3c_fixture_base_r_rows(first_manifest, binding)
  ladder_pair <- c(
    "n0120_m0060_q0500_r020",
    "n0120_m0060_q0500_r080",
    "n0300_m0150_q0500_r020",
    "n0300_m0150_q0500_r080"
  )
  for (id in ladder_pair) {
    rows <- which(first_attempts$cell_id == id)
    first_attempts <- v3ct_fail_rows(first_attempts, rows[1:3])
  }
  first_summary <- v3c_fixture_d2_summary(
    first_manifest,
    first_attempts,
    binding
  )
  first_source <- v3ct_evidence_source(
    "d2",
    first_manifest,
    first_summary,
    "history-d2-1"
  )
  second_manifest <- v3c_fixture_expected_manifest("d2", d1, first_summary)
  second_summary <- v3c_fixture_d2_summary(
    second_manifest,
    v3c_fixture_base_r_rows(second_manifest, binding),
    binding
  )
  second_source <- v3ct_evidence_source(
    "d2",
    second_manifest,
    second_summary,
    "history-d2-2"
  )
  history <- v3c_fixture_evidence_history(
    "d3",
    d1_source,
    list(first_source, second_source)
  )
  expect_true(history$d2_history_terminal)
  lock <- v3c_predecessor_lock_from_history("d3", history)
  expect_identical(lock$sequence_index, 0:2)
  expect_error(
    v3c_fixture_evidence_history("d3", d1_source, list(first_source)),
    "terminal ordered D2 history"
  )
  expect_error(
    v3c_fixture_evidence_history("d3", d1_source, list(second_source)),
    "missing, reordered, or out of sequence"
  )
  expect_error(
    v3c_fixture_evidence_history(
      "d3",
      d1_source,
      list(second_source, first_source)
    ),
    "missing, reordered, or out of sequence"
  )
})

test_that("downstream contract is source-safe and contains no execution surface", {
  text <- paste(readLines(downstream_tool, warn = FALSE), collapse = "\n")
  expect_false(grepl("set[.]seed|rnorm|runif|sample\\(", text))
  expect_false(grepl("writeLines|write[.]table|saveRDS|file[.]create", text))
  expect_false(grepl("JuliaCall|hsquared\\(", text))
  expect_message(v3c_selftest(), "downstream contract selftest: PASS")
})

test_that("module resolution ignores caller shadowing and source-order poison", {
  binding <- v3ct_binding()
  d1 <- v3c_fixture_d1_summary()
  d2m <- v3c_fixture_expected_manifest("d2", d1)
  d2s <- v3c_fixture_d2_summary(
    d2m,
    v3c_fixture_base_r_rows(d2m, binding),
    binding
  )
  expected <- v3c_fixture_expected_manifest("d4", d1, d2s)
  old <- v3_d4_manifest
  assign(
    "v3_d4_manifest",
    function(...) stop("CALLER_POISON"),
    envir = environment()
  )
  on.exit(assign("v3_d4_manifest", old, envir = environment()), add = TRUE)
  expect_identical(v3c_fixture_expected_manifest("d4", d1, d2s), expected)
})
