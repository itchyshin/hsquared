tool <- testthat::test_path("..", "..", "tools", "v07_genomic_recovery_v2.R")
testthat::skip_if_not(
  file.exists(tool),
  "repository-only v0.7 recovery-v2 campaign tools are unavailable in the built package"
)
tool <- normalizePath(tool, mustWork = TRUE)
source(tool, local = TRUE)
recompute_tool <- testthat::test_path("..", "..", "tools", "v07_genomic_recovery_v2_recompute.R")
recompute_tool <- normalizePath(recompute_tool, mustWork = TRUE)
source(recompute_tool, local = TRUE)

v07_test_hash <- function(x) paste(rep(x, 64L), collapse = "")

v07_test_attempts <- function() {
  manifest <- v07_manifest("pilot")
  within <- ave(seq_len(nrow(manifest)), manifest$cell_id, FUN = seq_along)
  delta <- (within - mean(1:48)) / 10000
  x <- manifest[setdiff(v07_manifest_columns, "regime")]
  x$attempted <- TRUE
  x$status <- "success"
  x$error_class <- "none"
  x$converged <- TRUE
  x$boundary_status <- "interior"
  x$boundary_reason <- "ai_interior"
  x$boundary_epsilon <- v07_boundary_epsilon
  x$scientific_sigma_g2 <- x$truth_sigma_g2 + delta
  x$scientific_sigma_e2 <- x$truth_sigma_e2 - delta
  x$scientific_ratio <- x$scientific_sigma_g2
  x$fitted_total_variance <- 1
  x$numerical_sigma_g2 <- x$scientific_sigma_g2
  x$numerical_sigma_e2 <- x$scientific_sigma_e2
  x$numerical_ratio <- x$scientific_ratio
  x$profile_loglik <- -100
  x$lower_derivative_per_observation <- 0.1
  x$upper_derivative_per_observation <- -0.1
  x$iterations <- 8
  x$objective <- 100
  x$gradient_norm <- 1e-9
  x$runtime_seconds <- 1
  x$peak_rss_mb <- 100
  x$relationship_source <- "markers"
  x$relationship_method <- "vanraden1"
  x$allele_frequency_source <- "sample"
  x$relationship_scale <- "K_lambda"
  x$scale_denominator <- 10
  x$marker_hash <- v07_test_hash("a")
  x$id_hash <- ifelse(x$n == 120, v07_test_hash("b"), v07_test_hash("c"))
  x$kernel_hash <- v07_test_hash("d")
  x$precision_hash <- v07_test_hash("e")
  x$route <- "ordinary_auto_genomic"
  x$r_implementation_commit <- v07_r_auto_route_commit
  x$julia_implementation_commit <- v07_julia_candidate_commit
  x$driver_commit <- paste(rep("f", 40L), collapse = "")
  x$seal_sha256 <- v07_test_hash("f")
  list(manifest = manifest, attempts = x[v07_attempt_columns])
}

test_that("the preregistered manifests use only the fresh disjoint blocks", {
  pilot <- v07_manifest("pilot")
  expect_equal(nrow(pilot), 9L * 48L)
  expect_identical(pilot$seed_offset, rep(7201:7248, times = 9L))
  expect_identical(
    pilot$seed,
    v07_seed_base + 10000L * pilot$cell_index + pilot$seed_offset
  )

  required <- stats::setNames(rep(200L, 9L), v07_cells$cell_id)
  confirm <- v07_manifest("confirm", required)
  expect_equal(nrow(confirm), 1800L)
  expect_true(all(confirm$seed_offset >= 8001 & confirm$seed_offset <= 8200))
  expect_invisible(v07_validate_disjoint_seeds(pilot, confirm))
  expect_true(all(7001:7048 %in% v07_reserved_offsets$failed_environment_pilot))
  expect_true(all(7101:7148 %in% v07_reserved_offsets$failed_adjudication_pilot))
  retired <- pilot
  retired$seed_offset <- rep(7101:7148, times = 9L)
  retired$seed <- v07_seed_base + 10000L * retired$cell_index + retired$seed_offset
  expect_error(v07_validate_disjoint_seeds(retired), "pilot offset drift")
  expect_error(v07r_validate_manifest(retired, "pilot"), "manifest scientific/seed contract drift")
  expect_identical(v07_expected_environment[["juliacall_version"]], "0.17.6")
  expect_identical(v07_expected_environment[["pkgload_version"]], "1.5.1")
  expect_identical(
    v07_expected_environment[["juliacall_source_commit"]],
    "947d1f3aaba5fec0f5cf61394869a5a47ffa7551"
  )
  expect_true(v07_hex64(
    v07_expected_environment[["juliacall_installed_tree_sha256"]]
  ))

  overlap <- confirm
  overlap$seed[[1L]] <- pilot$seed[[1L]]
  expect_error(v07_validate_disjoint_seeds(pilot, overlap), "overlap")
})

test_that("the fit call is the ordinary public formula with no route control", {
  code <- paste(deparse(body(v07_fit_call)), collapse = "\n")
  expect_match(code, "hsquared::hsquared", fixed = TRUE)
  expect_match(code, "genomic(1 | id, markers = M)", fixed = TRUE)
  expect_match(code, "REML = TRUE", fixed = TRUE)
  expect_false(grepl("hs_control", code, fixed = TRUE))
  expect_false(grepl("engine_control", code, fixed = TRUE))
  expect_false(grepl("target", code, fixed = TRUE))
})

test_that("create-once outputs use an exclusive hard link and sealed sidecar", {
  root <- tempfile("v07-create-once-"); dir.create(root)
  withr::defer(unlink(root, recursive = TRUE))
  path <- file.path(root, "one.tsv")
  digest <- v07_write_once(path, "a\tb\n1\t2\n")
  expect_match(digest, "^[0-9a-f]{64}$")
  expect_invisible(v07_verify_pair(path))
  expect_error(v07_write_once(path, "changed\n"), "already exists")

  writeLines("bad", paste0(path, ".sha256"))
  expect_error(v07_verify_pair(path), "checksum")
  unlink(path)
  expect_error(v07_verify_pair(path), "missing/orphan")

  orphan <- file.path(root, "orphan.tsv")
  writeLines("orphan", paste0(orphan, ".sha256"))
  expect_error(v07_write_once(orphan, "x\n"), "orphan")
})

test_that("directory-tree hashes bind installed bridge bytes", {
  root <- tempfile("v07-tree-"); dir.create(root)
  withr::defer(unlink(root, recursive = TRUE))
  writeLines("one", file.path(root, "a"))
  dir.create(file.path(root, "nested"))
  writeLines("two", file.path(root, "nested", "b"))
  first <- v07_tree_sha256(root)
  expect_true(v07_hex64(first))
  expect_identical(v07_tree_sha256(root), first)
  writeLines("changed", file.path(root, "nested", "b"))
  expect_false(identical(v07_tree_sha256(root), first))
})

test_that("concurrent writers produce exactly one immutable winner", {
  skip_on_os("windows")
  root <- tempfile("v07-concurrent-"); dir.create(root)
  withr::defer(unlink(root, recursive = TRUE))
  path <- file.path(root, "one.tsv")
  jobs <- lapply(1:2, function(i) parallel::mcparallel(
    !inherits(try(v07_write_once(path, sprintf("writer%d\n", i)), silent = TRUE), "try-error")
  ))
  wins <- unlist(parallel::mccollect(jobs), use.names = FALSE)
  expect_equal(sum(wins), 1L)
  expect_invisible(v07_verify_pair(path))
})

test_that("admission requires three immutable exact-commit CLEAN review receipts", {
  root <- tempfile("v07-reviews-"); dir.create(root)
  root <- normalizePath(root, winslash = "/")
  withr::defer(unlink(root, recursive = TRUE))
  r_commit <- paste(rep("a", 40L), collapse = "")
  j_commit <- paste(rep("b", 40L), collapse = "")
  reviewed <- "2026-07-13T20:00:00Z"
  clean <- file.path(root, paste0(tolower(c("Fisher", "Grace", "Rose")), ".tsv"))
  for (i in seq_along(clean)) {
    v07_write_review(clean[[i]], c("Fisher", "Grace", "Rose")[[i]], "CLEAN",
      r_commit, j_commit, reviewed)
  }
  admission <- file.path(root, "admission.tsv")
  expect_invisible(v07_write_admission(admission, r_commit, j_commit,
    clean[[1L]], clean[[2L]], clean[[3L]], reviewed))
  expect_invisible(v07_read_admission(admission, r_commit, j_commit))

  missing <- file.path(root, "missing.tsv")
  expect_error(v07_read_review(missing, "Fisher", r_commit, j_commit), "primary/sidecar")
  blocked <- file.path(root, "blocked.tsv")
  v07_write_review(blocked, "Rose", "BLOCKED", r_commit, j_commit, reviewed)
  expect_error(v07_read_review(blocked, "Rose", r_commit, j_commit), "does not attest CLEAN")
  mismatched <- file.path(root, "mismatched.tsv")
  v07_write_review(mismatched, "Grace", "CLEAN", paste(rep("c", 40L), collapse = ""),
    j_commit, reviewed)
  expect_error(v07_read_review(mismatched, "Grace", r_commit, j_commit), "exact execution commits")

  writeLines("mutated", clean[[1L]])
  expect_error(v07_read_admission(admission, r_commit, j_commit), "checksum")
})

test_that("reconstructable packets have an exact locked file set", {
  root <- tempfile("v07-packet-"); dir.create(root)
  withr::defer(unlink(root, recursive = TRUE))
  packet <- list(
    markers = data.frame(id = c("a", "b"), m000001 = c(0, 2)),
    ids = data.frame(index = 1:2, id = c("a", "b")),
    phenotype = data.frame(index = 1:2, id = c("a", "b"), y = c(1, 2)),
    truth = data.frame(cell_id = "fixture", seed = 1, n = 2, requested_m = 1,
      retained_m = 1, truth_sigma_g2 = 0.5, truth_sigma_e2 = 0.5,
      truth_ratio = 0.5, ridge = 0.01, scale_denominator = 0.5)
  )
  v07_write_packet(root, "pilot", "fixture", 1, packet)
  expect_invisible(v07_verify_packet(root, "pilot", "fixture", 1))
  writeLines("orphan", file.path(v07_packet_dir(root, "pilot", "fixture", 1), "extra.tsv.sha256"))
  expect_error(v07_verify_packet(root, "pilot", "fixture", 1), "file set")
})

test_that("known interrupted seed outputs can be cleared and rerun safely", {
  root <- tempfile("v07-resume-"); dir.create(root)
  root <- normalizePath(root, winslash = "/")
  withr::defer(unlink(root, recursive = TRUE))
  cell <- "fixture"; seed <- 1
  attempt <- v07_attempt_path(root, "pilot", cell, seed)
  dir.create(dirname(attempt), recursive = TRUE)
  writeLines("partial", attempt)
  expect_error(v07_seed_output_state(root, "pilot", cell, seed), "tampered or orphaned")
  expect_error(v07_clear_interrupted_seed(root, "pilot", cell, seed), "tampered or orphaned")
  unlink(attempt)
  expect_identical(v07_seed_output_state(root, "pilot", cell, seed), "absent")

  packet <- list(
    markers = data.frame(id = c("a", "b"), m000001 = c(0, 2)),
    ids = data.frame(index = 1:2, id = c("a", "b")),
    phenotype = data.frame(index = 1:2, id = c("a", "b"), y = c(1, 2)),
    truth = data.frame(cell_id = cell, seed = seed, n = 2, requested_m = 1,
      retained_m = 1, truth_sigma_g2 = 0.5, truth_sigma_e2 = 0.5,
      truth_ratio = 0.5, ridge = 0.01, scale_denominator = 0.5)
  )
  v07_write_packet(root, "pilot", cell, seed, packet)
  expect_identical(v07_seed_output_state(root, "pilot", cell, seed), "interrupted")
  expect_invisible(v07_clear_interrupted_seed(root, "pilot", cell, seed))
  expect_identical(v07_seed_output_state(root, "pilot", cell, seed), "absent")

  unexpected <- v07_packet_dir(root, "pilot", cell, seed + 1)
  dir.create(unexpected, recursive = TRUE)
  writeLines("do not delete", file.path(unexpected, "unexpected.txt"))
  expect_error(v07_seed_output_state(root, "pilot", cell, seed + 1), "unexpected file")

  v07_write_packet(root, "pilot", cell, seed, packet)
  row <- v07_test_attempts()$attempts[1L, , drop = FALSE]
  v07_write_once(attempt, v07_tsv_text(row))
  expect_identical(v07_seed_output_state(root, "pilot", cell, seed), "complete")
  unlink(paste0(attempt, ".sha256"))
  expect_error(v07_seed_output_state(root, "pilot", cell, seed), "tampered or orphaned")
  expect_error(v07_clear_interrupted_seed(root, "pilot", cell, seed), "tampered or orphaned")
  expect_true(file.exists(attempt))
  expect_true(dir.exists(v07_packet_dir(root, "pilot", cell, seed)))
})

test_that("tier corpus locks bind manifest attempts and packet primaries", {
  root <- tempfile("v07-corpus-"); dir.create(root)
  root <- normalizePath(root, winslash = "/")
  withr::defer(unlink(root, recursive = TRUE))
  manifest <- data.frame(
    tier = "pilot", cell_id = "fixture", cell_index = 1, seed_offset = 7001,
    seed = 1, n = 2, m = 1, truth_sigma_g2 = 0.5, truth_sigma_e2 = 0.5,
    truth_ratio = 0.5, ridge = 0.01, regime = "fixture"
  )
  v07_write_once(file.path(root, "pilot_manifest.tsv"), v07_tsv_text(manifest))
  packet <- list(
    markers = data.frame(id = c("a", "b"), m000001 = c(0, 2)),
    ids = data.frame(index = 1:2, id = c("a", "b")),
    phenotype = data.frame(index = 1:2, id = c("a", "b"), y = c(1, 2)),
    truth = data.frame(cell_id = "fixture", seed = 1, n = 2, requested_m = 1,
      retained_m = 1, truth_sigma_g2 = 0.5, truth_sigma_e2 = 0.5,
      truth_ratio = 0.5, ridge = 0.01, scale_denominator = 0.5)
  )
  v07_write_packet(root, "pilot", "fixture", 1, packet)
  attempt_path <- v07_attempt_path(root, "pilot", "fixture", 1)
  v07_write_once(attempt_path, "x\n1\n")
  expect_invisible(v07_write_corpus_lock(root, manifest, "pilot"))
  expect_invisible(v07_verify_corpus_lock(root, manifest, "pilot"))

  unlink(c(attempt_path, paste0(attempt_path, ".sha256")))
  v07_write_once(attempt_path, "x\n2\n")
  expect_error(v07_verify_corpus_lock(root, manifest, "pilot"), "differs")
})

test_that("root isolation and recomputer digests are frozen", {
  base <- tempfile("v07-roots-"); dir.create(base)
  withr::defer(unlink(base, recursive = TRUE))
  roots <- file.path(base, c("driver", "r", "julia")); vapply(roots, dir.create, logical(1L))
  expect_equal(length(v07_assert_separate_roots(roots[[1]], roots[[2]], roots[[3]])), 3L)
  expect_error(v07_assert_separate_roots(roots[[1]], roots[[1]], roots[[3]]), "distinct")
  expect_true(v07_hex64(v07_r_recomputer_sha256))
  expect_true(v07_hex64(v07_julia_recomputer_sha256))
  r_recomputer <- testthat::test_path("..", "..", "tools", "v07_genomic_recovery_v2_recompute.R")
  julia_recomputer <- testthat::test_path("..", "..", "..", "HSquared.jl", "sim",
    "phase2_v07_genomic_recovery_v2_recompute.jl")
  expect_invisible(v07_assert_recomputer(r_recomputer, v07_r_recomputer_sha256, "base-R"))
  expect_invisible(v07_assert_recomputer(julia_recomputer, v07_julia_recomputer_sha256, "Julia"))
  expect_invisible(v07_selftest())
})

test_that("output roots and verification stages are fail-closed", {
  base <- tempfile("v07-output-"); dir.create(base)
  base <- normalizePath(base, winslash = "/")
  withr::defer(unlink(base, recursive = TRUE))
  roots <- file.path(base, c("driver", "r", "julia")); vapply(roots, dir.create, logical(1L))
  output <- file.path(base, "campaign")
  expect_identical(v07_assert_new_output_root(output, roots), output)
  expect_error(v07_assert_new_output_root("relative-campaign", roots), "absolute")
  expect_error(v07_assert_new_output_root(file.path(roots[[1L]], "nested"), roots), "nested")
  link <- file.path(dirname(base), paste0(basename(base), "-link"))
  file.symlink(base, link); withr::defer(unlink(link))
  expect_error(v07_assert_new_output_root(file.path(link, "campaign"), roots), "real directory|canonical")

  expect_true(all(c("pilot_corpus_lock.tsv", "pilot_adjudication_receipt.tsv") %in%
    v07_stage_top("pilot_complete")))
  expect_true(all(c("confirm_corpus_lock.tsv", "confirm_adjudication_receipt.tsv") %in%
    v07_stage_top("confirm_complete")))
  expect_error(v07_stage_top("unknown"), "unknown verification stage")
})

test_that("execution commits preserve the selected implementation trees", {
  r_root <- normalizePath(testthat::test_path("..", ".."), winslash = "/")
  julia_root <- normalizePath(file.path(r_root, "..", "HSquared.jl"), winslash = "/")
  expect_identical(
    v07_assert_selected_tree(r_root, v07_r_auto_route_commit, "R", "R auto-route"),
    v07_git_object(r_root, v07_r_auto_route_commit, "R")
  )
  expect_identical(
    v07_assert_selected_tree(julia_root, v07_julia_candidate_commit, "src", "Julia candidate"),
    v07_git_object(julia_root, v07_julia_candidate_commit, "src")
  )
  expect_true(all(c(
    "julia_execution_commit", "r_selected_tree", "julia_selected_tree",
    "holdout_checkpoint_doc_sha256", "holdout_checklog_sha256",
    "juliacall_source_commit", "juliacall_installed_tree_sha256",
    "julia_dependency_manifest_sha256", "julia_libunwind_sha256"
  ) %in% v07_seal_keys))
})

test_that("resolved endpoints use scientific components and stay eligible", {
  x <- v07_test_attempts()
  lower <- 1L
  x$attempts$boundary_status[[lower]] <- "boundary_lower"
  x$attempts$boundary_reason[[lower]] <- "boundary_lower"
  x$attempts$fitted_total_variance[[lower]] <- 0.9
  x$attempts$scientific_ratio[[lower]] <- 0
  x$attempts$scientific_sigma_g2[[lower]] <- 0
  x$attempts$scientific_sigma_e2[[lower]] <- 0.9
  x$attempts$numerical_ratio[[lower]] <- 1e-7
  x$attempts$numerical_sigma_g2[[lower]] <- 9e-8
  x$attempts$numerical_sigma_e2[[lower]] <- 0.89999991
  x$attempts$lower_derivative_per_observation[[lower]] <- -0.1

  upper <- 49L
  x$attempts$boundary_status[[upper]] <- "boundary_upper"
  x$attempts$boundary_reason[[upper]] <- "boundary_upper"
  x$attempts$fitted_total_variance[[upper]] <- 1.1
  x$attempts$scientific_ratio[[upper]] <- 1
  x$attempts$scientific_sigma_g2[[upper]] <- 1.1
  x$attempts$scientific_sigma_e2[[upper]] <- 0
  x$attempts$numerical_ratio[[upper]] <- 1 - 1e-7
  x$attempts$numerical_sigma_g2[[upper]] <- 1.09999989
  x$attempts$numerical_sigma_e2[[upper]] <- 1.1e-7
  x$attempts$upper_derivative_per_observation[[upper]] <- 0.1

  validated <- v07_validate_attempts(x$attempts, x$manifest, "pilot")
  expect_true(validated$converged[[lower]])
  expect_true(validated$converged[[upper]])
  summary <- v07_summarize(x$attempts, x$manifest, "pilot")
  expect_equal(unique(summary$n_converged), 48L)

  bad <- x$attempts
  bad$scientific_sigma_g2[[lower]] <- 1e-7
  expect_error(v07_validate_attempts(bad, x$manifest, "pilot"), "scientific boundary")

  bad_lower_kkt <- x$attempts
  bad_lower_kkt$lower_derivative_per_observation[[lower]] <- 1
  expect_error(v07_validate_attempts(bad_lower_kkt, x$manifest, "pilot"), "KKT")
  bad_upper_kkt <- x$attempts
  bad_upper_kkt$upper_derivative_per_observation[[upper]] <- -1
  expect_error(v07_validate_attempts(bad_upper_kkt, x$manifest, "pilot"), "KKT")
})

test_that("pilot summary uses upper-SD sizing and whole-campaign stop rules", {
  x <- v07_test_attempts()
  summary <- v07_summarize(x$attempts, x$manifest, "pilot")
  expect_identical(unique(summary$cell_status), "CONFIRMATION_ELIGIBLE")
  expect_true(all(summary$pilot_sd_upper > 0))
  expect_true(all(summary$required_n >= 200))

  stopped <- x$attempts
  idx <- which(stopped$cell_id == v07_cells$cell_id[[1L]])[1:3]
  stopped$status[idx] <- "fit_error"
  stopped$error_class[idx] <- "synthetic_failure"
  stopped$converged[idx] <- FALSE
  stopped[idx, c(
    "boundary_status", "boundary_reason", "relationship_source",
    "relationship_method", "allele_frequency_source", "relationship_scale",
    "marker_hash", "id_hash", "kernel_hash", "precision_hash"
  )] <- NA
  stopped[idx, c(
    "boundary_epsilon", "scientific_sigma_g2", "scientific_sigma_e2",
    "scientific_ratio", "fitted_total_variance", "numerical_sigma_g2",
    "numerical_sigma_e2", "numerical_ratio", "scale_denominator"
  )] <- NA_real_
  out <- v07_summarize(stopped, x$manifest, "pilot")
  expect_identical(
    unique(out$cell_status[out$cell_id == v07_cells$cell_id[[1L]]]),
    "STOP_LOW_PILOT_CONVERGENCE"
  )
})

test_that("every frozen mutation makes a structural or summary gate red", {
  x <- v07_test_attempts()
  baseline <- v07_summarize(x$attempts, x$manifest, "pilot")

  estimate <- x$attempts
  estimate$scientific_sigma_g2[[1L]] <- estimate$scientific_sigma_g2[[1L]] + 0.01
  estimate$fitted_total_variance[[1L]] <- estimate$scientific_sigma_g2[[1L]] + estimate$scientific_sigma_e2[[1L]]
  estimate$scientific_ratio[[1L]] <- estimate$scientific_sigma_g2[[1L]] / estimate$fitted_total_variance[[1L]]
  changed <- v07_summarize(estimate, x$manifest, "pilot")
  expect_error(v07_compare_summary(baseline, changed), "summary mismatch")

  mutate_and_fail <- function(field, value, pattern) {
    y <- x$attempts; y[[field]][[1L]] <- value
    expect_error(v07_validate_attempts(y, x$manifest, "pilot"), pattern)
  }
  mutate_and_fail("truth_ratio", 0.3, "manifest mismatch")
  mutate_and_fail("seed", x$attempts$seed[[1L]] + 999, "manifest denominator")
  mutate_and_fail("cell_id", "wrong", "manifest denominator")
  mutate_and_fail("ridge", 0.02, "manifest mismatch")
  mutate_and_fail("marker_hash", "mutated", "invalid marker_hash")
  mutate_and_fail("id_hash", v07_test_hash("a"), "ID-order")
  mutate_and_fail("attempted", FALSE, "attempted=true")
  mutate_and_fail("status", "fit_error", "status/convergence")
  mutate_and_fail("numerical_ratio", 0.4, "ratio mismatch")
  mutate_and_fail("lower_derivative_per_observation", -1, "KKT")

  removed <- x$attempts[-1L, ]
  expect_error(v07_validate_attempts(removed, x$manifest, "pilot"), "manifest denominator")
  duplicated <- rbind(x$attempts, x$attempts[1L, ])
  expect_error(v07_validate_attempts(duplicated, x$manifest, "pilot"), "duplicate")
})

test_that("summary comparison handles signed infinity and lexical failures", {
  x <- v07_test_attempts()
  baseline <- v07_summarize(x$attempts, x$manifest, "pilot")
  infinite <- baseline
  infinite$required_n_raw[[1L]] <- Inf
  infinite$required_n[[1L]] <- Inf
  expect_invisible(v07_compare_summary(infinite, infinite))
  opposite <- infinite; opposite$required_n[[1L]] <- -Inf
  expect_error(v07_compare_summary(infinite, opposite), "summary mismatch")

  root <- tempfile("v07-summary-roundtrip-"); dir.create(root)
  withr::defer(unlink(root, recursive = TRUE))
  path <- file.path(root, "summary.tsv")
  v07_write_once(path, v07_tsv_text(baseline))
  roundtrip <- v07_read_tsv(path, v07_summary_columns)
  expect_type(baseline$target_pass, "logical")
  expect_type(roundtrip$target_pass, "character")
  expect_invisible(v07_compare_summary(baseline, roundtrip))
  expect_invisible(v07r_compare(baseline, roundtrip))
  inverted <- roundtrip
  inverted$target_pass[[1L]] <- if (inverted$target_pass[[1L]] == "true") "false" else "true"
  expect_error(v07_compare_summary(baseline, inverted), "summary mismatch in target_pass")
  expect_error(v07r_compare(baseline, inverted), "summary mismatch in target_pass")
  invalid <- roundtrip; invalid$target_pass[[1L]] <- "not-a-boolean"
  expect_error(v07_compare_summary(baseline, invalid), "invalid logical summary field")
  expect_error(v07r_compare(baseline, invalid), "invalid logical summary field")
  missing <- roundtrip; missing$target_pass[[1L]] <- NA_character_
  expect_error(v07_compare_summary(baseline, missing), "invalid logical summary field")
  expect_error(v07r_compare(baseline, missing), "invalid logical summary field")

  expect_identical(v07_failure_classes(c("z", "z", "a")), "a=1;z=2")
  expect_identical(v07r_failure_classes(c("z", "z", "a")), "a=1;z=2")
})

test_that("launcher passes only xargs cell and seed as positional arguments", {
  launcher <- paste(readLines(testthat::test_path("..", "..", "tools", "run-v07-genomic-recovery-v2.sh")), collapse = "\n")
  expect_match(launcher, "cell=\u00241; seed=\u00242", fixed = TRUE)
  expect_match(launcher, "export V07_TOOL=", fixed = TRUE)
  expect_match(
    launcher,
    'export R_LIBS="/home/snakagaw/R/v07-lib:/home/snakagaw/R/lib"',
    fixed = TRUE
  )
  expect_false(grepl("sh _ _", launcher, fixed = TRUE))
})

test_that("sealing performs the real JuliaCall lifecycle before output creation", {
  code <- paste(readLines(
    testthat::test_path("..", "..", "tools", "v07_genomic_recovery_v2.R")
  ), collapse = "\n")
  create_start <- regexpr("v07_create_seal <- function", code, fixed = TRUE)[[1L]]
  create_end <- regexpr("v07_assert_bound_state <- function", code, fixed = TRUE)[[1L]]
  create <- substring(code, create_start, create_end - 1L)
  expect_lt(
    regexpr("v07_assert_live_bridge", create, fixed = TRUE)[[1L]],
    regexpr("dir.create(out_dir", create, fixed = TRUE)[[1L]]
  )
  expect_match(code, 'JuliaCall::julia_eval("isdefined(Main, :HSquared)")', fixed = TRUE)
})

test_that("independent base-R summary matches the campaign arithmetic", {
  x <- v07_test_attempts()
  expected <- v07_summarize(x$attempts, x$manifest, "pilot")
  observed <- v07r_summary(x$manifest, x$attempts, "pilot")
  expect_invisible(v07r_compare(expected, observed, tolerance = 1e-10))
  expect_identical(unique(observed$campaign_status), "CONFIRMATION_ELIGIBLE")
  expect_true(all(observed$n_resolved_valid == observed$n_converged))
  expect_true(all(observed$n_interior == 48L))

  mutated <- observed
  mutated$required_n_raw[[1L]] <- mutated$required_n_raw[[1L]] + 1
  expect_error(v07r_compare(expected, mutated), "summary mismatch")
})

test_that("base-R packet reconstruction independently checks k, K, Q, and alignment", {
  root <- tempfile("v07r-packet-"); dir.create(root)
  withr::defer(unlink(root, recursive = TRUE))
  packet <- list(
    markers = data.frame(id = c("a", "b"), m000001 = c(0, 2)),
    ids = data.frame(index = 1:2, id = c("a", "b")),
    phenotype = data.frame(index = 1:2, id = c("a", "b"), y = c(1, 2)),
    truth = data.frame(cell_id = "fixture", seed = 1, n = 2, requested_m = 1,
      retained_m = 1, truth_sigma_g2 = 0.5, truth_sigma_e2 = 0.5,
      truth_ratio = 0.5, ridge = 0.01, scale_denominator = 0.5)
  )
  v07_write_packet(root, "pilot", "fixture", 1, packet)
  manifest <- data.frame(tier = "pilot", cell_id = "fixture", cell_index = 1,
    seed_offset = 7001, seed = 1, n = 2, m = 1, truth_sigma_g2 = 0.5,
    truth_sigma_e2 = 0.5, truth_ratio = 0.5, ridge = 0.01, regime = "fixture")
  attempt <- data.frame(scale_denominator = 0.5)
  rebuilt <- v07r_validate_packet(root, "pilot", manifest, attempt)
  expect_equal(rebuilt$k, 0.5)
  expect_lte(rebuilt$qk_error, 1e-10)

  truth_path <- file.path(v07_packet_dir(root, "pilot", "fixture", 1), "truth.tsv")
  unlink(c(truth_path, paste0(truth_path, ".sha256")))
  packet$truth$scale_denominator <- 0.6
  v07_write_once(truth_path, v07_tsv_text(packet$truth))
  lock_path <- file.path(dirname(truth_path), "packet_files_lock.tsv")
  unlink(c(lock_path, paste0(lock_path, ".sha256")))
  primaries <- file.path(dirname(truth_path), c("markers.tsv", "ids.tsv", "phenotype.tsv", "truth.tsv"))
  lock <- data.frame(file = basename(primaries), sha256 = vapply(primaries, v07_sha256, character(1L)))
  v07_write_once(lock_path, v07_tsv_text(lock))
  expect_error(v07r_validate_packet(root, "pilot", manifest, attempt), "construction/truth")
})

test_that("the independent recomputer is standalone and selftests", {
  code <- paste(readLines(recompute_tool), collapse = "\n")
  expect_false(grepl("source(", code, fixed = TRUE))
  expect_false(grepl("hsquared::", code, fixed = TRUE))
  expect_invisible(v07r_selftest())
})

test_that("independent manifest validation pins the full seed and science algebra", {
  pilot <- v07_manifest("pilot")
  expect_equal(nrow(v07r_validate_manifest(pilot, "pilot")), 432L)
  mutate <- function(field, value, pattern = "contract") {
    x <- pilot; x[[field]][[1L]] <- value
    expect_error(v07r_validate_manifest(x, "pilot"), pattern)
  }
  mutate("tier", "confirm", "tier")
  mutate("seed_offset", 7002, "contract")
  mutate("seed", pilot$seed[[1L]] + 1, "contract")
  mutate("ridge", 0.02, "contract")
  mutate("n", 121, "contract")
  mutate("m", 601, "contract")
  mutate("truth_ratio", 0.3, "contract")
})
