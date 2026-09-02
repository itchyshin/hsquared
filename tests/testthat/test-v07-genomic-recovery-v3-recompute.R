recompute_tool <- testthat::test_path(
  "..", "..", "tools", "v07_genomic_recovery_v3_recompute.R"
)
testthat::skip_if_not(
  file.exists(recompute_tool),
  "repository-only recovery-v3 recomputer is unavailable"
)
source(normalizePath(recompute_tool, mustWork = TRUE), local = TRUE)

v3r_test_hash <- function(letter, n = 64L) {
  paste(rep(letter, n), collapse = "")
}

v3r_test_write <- function(path, x) {
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  v07d_write_once(path, v07d_tsv_text(x))
  invisible(path)
}

v3r_test_rewrite <- function(path, x) {
  unlink(c(path, paste0(path, ".sha256")))
  v3r_test_write(path, x)
}

v3r_test_preseal <- function() {
  c(
    r_auto_route_commit = v3r_test_hash("a", 40L),
    julia_candidate_commit = v3r_test_hash("b", 40L),
    r_driver_commit = v3r_test_hash("c", 40L),
    r_recomputer_commit = v3r_test_hash("d", 40L),
    julia_replay_commit = v3r_test_hash("e", 40L),
    r_driver_sha256 = v3r_test_hash("a"),
    r_recomputer_sha256 = v3r_test_hash("b"),
    julia_replay_sha256 = v3r_test_hash("c"),
    manifest_sha256 = v3r_test_hash("d")
  )
}

v3r_test_packet_fixture <- function(stage = "d1") {
  root <- tempfile("v3r-packet-")
  dir.create(root)
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  stopifnot(stage %in% c("d0f", "d1"))
  ids <- sprintf("g%06d", seq_len(4L))
  M <- matrix(c(
    0, 1, 2, 1,
    0, 0, 1, 2,
    2, 1, 0, 1
  ), nrow = 4L, ncol = 3L)
  colnames(M) <- sprintf("m%06d", seq_len(ncol(M)))
  p <- colSums(M) / 8
  W <- sweep(M, 2L, 2 * p, "-")
  k <- 2 * sum(p * (1 - p))
  K <- tcrossprod(W) / k
  diag(K) <- diag(K) + 0.01
  Q <- solve(K)
  hashes <- c(
    marker_hash = v07d_marker_fingerprint(M, ids, colnames(M)),
    id_hash = v07d_id_fingerprint(ids),
    kernel_hash = v07d_matrix_fingerprint("K_lambda", K, ids),
    precision_hash = v07d_matrix_fingerprint("Q_lambda", Q, ids)
  )
  row <- if (stage == "d1") {
    data.frame(
      stage = stage, cell_id = "tiny_d1", cell_index = 1L,
      seed_offset = 101L, seed = 2028010101, n = 4L, m = 3L,
      marker_ratio = 0.75, marker_ratio_code = "q0750",
      truth_sigma_g2 = 0.5, truth_sigma_e2 = 0.5, truth_ratio = 0.5,
      ridge = 0.01, stringsAsFactors = FALSE
    )[v3p_d1_columns]
  } else {
    data.frame(
      stage = stage, design_id = "tiny_d0f", design_index = 1L,
      panel_id = "tiny_d0f_p01", panel_rank = 1L,
      source_cell_id = "n120_m600_r050", panel_source_seed = 2027147101,
      phenotype_rank = 1L, seed = 2029101001, n = 4L, m = 3L,
      marker_ratio = 0.75, retained_m = 3L,
      truth_sigma_g2 = 0.5, truth_sigma_e2 = 0.5, truth_ratio = 0.5,
      ridge = 0.01, marker_hash = hashes[["marker_hash"]],
      id_hash = hashes[["id_hash"]], kernel_hash = hashes[["kernel_hash"]],
      precision_hash = hashes[["precision_hash"]], stringsAsFactors = FALSE
    )[v3p_d0f_phenotype_columns]
  }
  preseal <- v3r_test_preseal()
  preseal_sha <- v3r_test_hash("f")
  packet <- v3r_packet_dir(root, stage, row)
  markers <- data.frame(id = ids, M, check.names = FALSE)
  names(markers) <- c("id", colnames(M))
  id_table <- data.frame(index = seq_len(4L), id = ids, stringsAsFactors = FALSE)
  phenotype <- data.frame(
    index = seq_len(4L), id = ids, y = c(-1, 0, 0.5, 1.5),
    stringsAsFactors = FALSE
  )
  construction <- data.frame(
    retained_m = 3L, marker_hash = hashes[["marker_hash"]],
    id_hash = hashes[["id_hash"]], kernel_hash = hashes[["kernel_hash"]],
    precision_hash = hashes[["precision_hash"]], stringsAsFactors = FALSE
  )
  truth_parts <- list(
    row,
    data.frame(
      packet_schema_version = "v07-genomic-recovery-v3-packet-1",
      truth_schema_version = "v07-genomic-recovery-v3-truth-1",
      scale_denominator = k, relationship_source = "markers",
      relationship_method = "vanraden1", allele_frequency_source = "sample",
      relationship_scale = "K_lambda", preseal_sha256 = preseal_sha,
      r_implementation_commit = preseal[["r_auto_route_commit"]],
      julia_implementation_commit = preseal[["julia_candidate_commit"]],
      driver_commit = preseal[["r_driver_commit"]], stringsAsFactors = FALSE
    )
  )
  if (stage == "d1") truth_parts <- append(truth_parts, list(construction), 1L)
  truth <- do.call(cbind, truth_parts)[v3r_truth_columns(stage)]
  objects <- list(
    markers.tsv = markers, ids.tsv = id_table,
    phenotype.tsv = phenotype, truth.tsv = truth
  )
  for (name in names(objects)) {
    v3r_test_write(file.path(packet, name), objects[[name]])
  }
  lock <- data.frame(
    file = names(objects),
    sha256 = vapply(
      file.path(packet, names(objects)), v07d_sha256, character(1L)
    ),
    stringsAsFactors = FALSE
  )
  v3r_test_write(file.path(packet, "packet_files_lock.tsv"), lock)
  spectrum <- v3r_spectrum(K, 4L)
  result <- data.frame(
    attempted = TRUE, status = "success", error_class = "none",
    converged = TRUE, boundary_status = "interior",
    boundary_reason = "ai_interior", boundary_epsilon = 1e-7,
    scientific_sigma_g2 = 0.5, scientific_sigma_e2 = 0.5,
    scientific_ratio = 0.5, fitted_total_variance = 1,
    numerical_sigma_g2 = 0.5, numerical_sigma_e2 = 0.5,
    numerical_ratio = 0.5, profile_loglik = -1,
    lower_derivative_per_observation = 1,
    upper_derivative_per_observation = -1, iterations = 2,
    objective = 1, gradient_norm = 0, runtime_seconds = 0.2,
    peak_rss_mb = 100, scale_denominator = k,
    eigen_cv_population = spectrum$cv,
    effective_rank = spectrum$effective_rank,
    information_r020 = spectrum$information[[1L]],
    se_info_r020 = spectrum$se[[1L]],
    information_r050 = spectrum$information[[2L]],
    se_info_r050 = spectrum$se[[2L]],
    information_r080 = spectrum$information[[3L]],
    se_info_r080 = spectrum$se[[3L]],
    relationship_source = "markers", relationship_method = "vanraden1",
    allele_frequency_source = "sample", relationship_scale = "K_lambda",
    route = "ordinary_auto_genomic",
    r_implementation_commit = preseal[["r_auto_route_commit"]],
    julia_implementation_commit = preseal[["julia_candidate_commit"]],
    driver_commit = preseal[["r_driver_commit"]],
    preseal_sha256 = preseal_sha, stringsAsFactors = FALSE
  )[v3p_result_columns]
  attempt_parts <- list(row, result)
  if (stage == "d1") attempt_parts <- append(attempt_parts, list(construction), 1L)
  attempt <- do.call(cbind, attempt_parts)[v3r_attempt_columns(stage)]
  attempt_path <- v3r_attempt_path(root, stage, row)
  v3r_test_write(attempt_path, attempt)
  list(
    root = root, stage = stage, row = row, packet = packet,
    attempt_path = attempt_path, preseal = preseal,
    preseal_sha = preseal_sha, ids = ids, M = M, p = p, W = W, k = k,
    K = K, Q = Q, hashes = hashes, spectrum = spectrum,
    attempt = attempt, truth = truth
  )
}

v3r_test_refresh_packet_lock <- function(fixture) {
  files <- v3r_packet_primaries[1:4]
  lock <- data.frame(
    file = files,
    sha256 = vapply(
      file.path(fixture$packet, files), v07d_sha256, character(1L)
    ),
    stringsAsFactors = FALSE
  )
  v3r_test_rewrite(file.path(fixture$packet, "packet_files_lock.tsv"), lock)
}

test_that("Retry-6 route rebind is red before summary reconstruction", {
  root <- tempfile("v3r-route-aware-summary-")
  dir.create(root)
  on.exit(unlink(root, recursive = TRUE), add = TRUE)
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  binding <- list(
    preseal_sha256 = v3r_test_hash("e"),
    manifest_sha256 = v3r_test_hash("f"),
    corpus_lock_sha256 = v3r_test_hash("a"),
    r_auto_route_commit = v3r_test_hash("a", 40L),
    julia_candidate_commit = v3r_test_hash("b", 40L),
    r_driver_commit = v3r_test_hash("c", 40L),
    julia_replay_commit = v3r_test_hash("d", 40L),
    julia_replay_sha256 = v3r_test_hash("b")
  )
  parity <- v3p_d0f_summary_parity_fixture(binding)
  v3r_test_write(
    file.path(root, "d0f_bootstrap_indices.tsv"), parity$bootstrap
  )
  state <- list(
    root = root, stage = "d0f", manifest = parity$manifest,
    binding = binding
  )
  julia <- parity$attempts
  julia$route <- "julia_profile_replay"
  julia$driver_commit <- binding$julia_replay_commit
  legacy_rebound <- julia
  legacy_rebound$route <- "ordinary_auto_genomic"
  legacy_rebound$driver_commit <- binding$r_driver_commit
  expect_identical(
    v3p_d0f_summary(
      parity$manifest, legacy_rebound, parity$bootstrap,
      v07d_sha256(file.path(root, "d0f_bootstrap_indices.tsv")), binding
    ),
    parity$summary
  )
  expect_error(
    v3r_new_admitted_evidence(legacy_rebound, "julia", "d0f"),
    "route does not match"
  )
  expect_error(
    v3r_expected_summary(state, julia),
    "requires admitted evidence"
  )
  admitted <- v3r_new_admitted_evidence(julia, "julia", "d0f")
  observed <- v3r_expected_summary(state, admitted)
  expect_identical(observed, parity$summary)
  wrong_driver <- julia
  wrong_driver$driver_commit <- binding$r_driver_commit
  expect_error(
    v3r_expected_summary(state, v3r_new_admitted_evidence(
      wrong_driver, "julia", "d0f"
    )),
    "attempt provenance binding is invalid"
  )

  d1 <- v3p_d1_summary_parity_fixture(binding)
  d1_state <- list(
    root = root, stage = "d1", manifest = d1$manifest,
    binding = binding
  )
  d1_julia <- d1$attempts
  d1_julia$route <- "julia_profile_replay"
  d1_julia$driver_commit <- binding$julia_replay_commit
  expect_error(
    v3r_expected_summary(d1_state, d1_julia),
    "requires admitted evidence"
  )
  d1_admitted <- v3r_new_admitted_evidence(d1_julia, "julia", "d1")
  d1_observed <- v3r_expected_summary(d1_state, d1_admitted)
  expect_identical(d1_observed, d1$summary)
  d1_wrong_driver <- d1_julia
  d1_wrong_driver$driver_commit <- binding$r_driver_commit
  expect_error(
    v3r_expected_summary(d1_state, v3r_new_admitted_evidence(
      d1_wrong_driver, "julia", "d1"
    )),
    "attempt provenance binding is invalid"
  )
})

test_that("weighted route lineage conserves full D0F and D1 evidence", {
  h64 <- function(x) v3r_test_hash(x)
  h40 <- function(x) v3r_test_hash(x, 40L)
  binding <- list(
    preseal_sha256 = h64("e"), manifest_sha256 = h64("f"),
    corpus_lock_sha256 = h64("a"), r_auto_route_commit = h40("a"),
    julia_candidate_commit = h40("b"), r_driver_commit = h40("c"),
    julia_replay_commit = h40("d"), julia_replay_sha256 = h64("b")
  )
  for (stage in c("d0f", "d1")) {
    parity <- if (stage == "d0f") {
      v3p_d0f_summary_parity_fixture(binding)
    } else {
      v3p_d1_summary_parity_fixture(binding)
    }
    ordinary <- parity$attempts
    julia <- ordinary
    julia$route <- "julia_profile_replay"
    julia$driver_commit <- binding$julia_replay_commit
    admitted <- list(
      official = v3r_new_admitted_evidence(ordinary, "official", stage),
      base_r = v3r_new_admitted_evidence(ordinary, "base_r", stage),
      julia = v3r_new_admitted_evidence(julia, "julia", stage)
    )
    state <- list(
      stage = stage, manifest = parity$manifest,
      corpus = list(sha256 = h64("c"))
    )
    evidence <- list(
      base_r_inventory_sha256 = h64("d"),
      julia_replay_inventory_sha256 = h64("e")
    )
    adjudication <- list(admitted = admitted)
    lineage <- v3r_expected_route_lineage(state, evidence, adjudication)
    expected_rows <- if (stage == "d0f") 9L else 36L
    expect_equal(nrow(lineage), expected_rows)
    expect_equal(
      as.integer(tapply(
        lineage$source_attempt_count, lineage$evidence_kind, sum
      )),
      rep(576L, 3L)
    )
    evidence$route_lineage <- lineage
    expect_no_error(v3r_validate_route_lineage(
      state, evidence, adjudication
    ))
    evidence$route_lineage$source_attempt_count[[1L]] <-
      evidence$route_lineage$source_attempt_count[[1L]] - 1L
    expect_error(
      v3r_validate_route_lineage(state, evidence, adjudication),
      "differs from admitted evidence"
    )
  }
})

test_that("admitted evidence rejects forged route identity", {
  binding <- list(
    preseal_sha256 = v3r_test_hash("e"),
    manifest_sha256 = v3r_test_hash("f"),
    corpus_lock_sha256 = v3r_test_hash("a"),
    r_auto_route_commit = v3r_test_hash("a", 40L),
    julia_candidate_commit = v3r_test_hash("b", 40L),
    r_driver_commit = v3r_test_hash("c", 40L),
    julia_replay_commit = v3r_test_hash("d", 40L),
    julia_replay_sha256 = v3r_test_hash("b")
  )
  parity <- v3p_d1_summary_parity_fixture(binding)
  expect_error(
    v3r_new_admitted_evidence(parity$attempts, "julia", "d1"),
    "route does not match"
  )
  admitted <- v3r_new_admitted_evidence(parity$attempts, "official", "d1")
  class(admitted) <- v3r_evidence_class("julia")
  expect_error(v3r_evidence_rows(admitted), "class/kind binding")
})

test_that("base R reconstructs p, W, k, G, K, Q, hashes, and attempt fields", {
  fixture <- v3r_test_packet_fixture()
  on.exit(unlink(fixture$root, recursive = TRUE), add = TRUE)
  packet <- v3r_reconstruct_packet(
    fixture$root, fixture$stage, fixture$row,
    fixture$preseal, fixture$preseal_sha
  )
  expect_equal(packet$p, fixture$p, tolerance = 0)
  expect_equal(unname(packet$W), unname(fixture$W), tolerance = 0)
  expect_equal(packet$k, fixture$k, tolerance = 1e-15)
  expect_equal(unname(packet$K), unname(fixture$K), tolerance = 1e-15)
  expect_equal(unname(packet$Q), unname(fixture$Q), tolerance = 1e-12)
  expect_lte(max(abs(packet$Q %*% packet$K - diag(4L))), 1e-10)
  expect_identical(packet$hashes, fixture$hashes)
  expect_identical(packet$native_hashes, fixture$hashes)
  row <- v3r_recompute_row(
    fixture$root, fixture$stage, fixture$row,
    fixture$preseal, fixture$preseal_sha
  )
  expect_identical(
    names(row), c(v3p_d1_attempt_columns, v3r_native_hash_columns)
  )
  expect_equal(row$scale_denominator, fixture$k, tolerance = 1e-15)
})

test_that("direct recomputation admits only Totoro or live DRAC allocations", {
  env <- c(
    GITHUB_ACTIONS = "false", CI = "false", SLURM_JOB_ID = "",
    OPENBLAS_NUM_THREADS = "1", JULIA_NUM_THREADS = "1",
    OMP_NUM_THREADS = "1", MKL_NUM_THREADS = "1",
    VECLIB_MAXIMUM_THREADS = "1", NUMEXPR_NUM_THREADS = "1"
  )
  expect_silent(v3r_assert_execution_context(
    host = "totoro.biology.ualberta.ca", environment = env
  ))
  expect_error(v3r_assert_execution_context(
    host = "login1", cluster = "fir", environment = env
  ), "SLURM allocation")
  allocated <- env
  allocated[["SLURM_JOB_ID"]] <- "123456"
  expect_silent(v3r_assert_execution_context(
    host = "cn001", cluster = "fir", environment = allocated
  ))
  malformed <- allocated
  malformed[["SLURM_JOB_ID"]] <- "interactive"
  expect_error(v3r_assert_execution_context(
    host = "cn001", cluster = "fir", environment = malformed
  ), "SLURM allocation")
  bad <- env
  bad[["GITHUB_ACTIONS"]] <- "true"
  expect_error(v3r_assert_execution_context(
    host = "totoro", environment = bad
  ), "forbidden")
  bad <- env
  bad[["CI"]] <- "TRUE"
  expect_error(v3r_assert_execution_context(
    host = "totoro", environment = bad
  ), "forbidden")
  bad <- env
  bad[["OPENBLAS_NUM_THREADS"]] <- "2"
  expect_error(v3r_assert_execution_context(
    host = "totoro", environment = bad
  ), "pinned")
})

test_that("D0F reconstructs panel packets and binds every source identity", {
  fixture <- v3r_test_packet_fixture("d0f")
  on.exit(unlink(fixture$root, recursive = TRUE), add = TRUE)

  packet <- v3r_reconstruct_packet(
    fixture$root, fixture$stage, fixture$row,
    fixture$preseal, fixture$preseal_sha
  )
  expect_equal(packet$p, fixture$p, tolerance = 0)
  expect_equal(unname(packet$W), unname(fixture$W), tolerance = 0)
  expect_equal(packet$k, fixture$k, tolerance = 1e-15)
  expect_equal(unname(packet$K), unname(fixture$K), tolerance = 1e-15)
  expect_equal(unname(packet$Q), unname(fixture$Q), tolerance = 1e-12)
  expect_identical(packet$hashes, fixture$hashes)
  expect_identical(packet$native_hashes, fixture$hashes)

  recomputed <- v3r_recompute_row(
    fixture$root, fixture$stage, fixture$row,
    fixture$preseal, fixture$preseal_sha
  )
  expect_identical(
    names(recomputed), c(v3p_d0f_attempt_columns, v3r_native_hash_columns)
  )
  expect_identical(recomputed$panel_id, fixture$row$panel_id)
  expect_equal(
    recomputed$panel_source_seed, fixture$row$panel_source_seed, tolerance = 0
  )
  expect_identical(recomputed$source_cell_id, fixture$row$source_cell_id)
  expect_equal(recomputed$seed, fixture$row$seed, tolerance = 0)

  mutations <- list(
    panel_id = function(x) {
      x$panel_id <- "tiny_d0f_p02"
      x
    },
    panel_source_seed = function(x) {
      x$panel_source_seed <- x$panel_source_seed + 1
      x
    },
    source_cell_id = function(x) {
      x$source_cell_id <- "n300_m150_r050"
      x
    },
    marker_hash = function(x) {
      x$marker_hash <- v3r_test_hash("0")
      x
    },
    seed = function(x) {
      x$seed <- x$seed + 1
      x
    }
  )
  for (field in names(mutations)) {
    changed <- mutations[[field]](fixture$row)
    expect_error(
      v3r_reconstruct_packet(
        fixture$root, fixture$stage, changed,
        fixture$preseal, fixture$preseal_sha
      ),
      if (field == "seed") {
        "packet directory must be an absolute existing"
      } else {
        paste0("truth/manifest mismatch in ", field)
      },
      info = paste("D0F identity mutation", field)
    )
  }
})

test_that("base R records native K/Q hashes without demanding Julia byte identity", {
  fixture <- v3r_test_packet_fixture()
  on.exit(unlink(fixture$root, recursive = TRUE), add = TRUE)
  alternate_K <- fixture$K
  alternate_K[1L, 2L] <- alternate_K[1L, 2L] + 2e-15
  alternate_K[2L, 1L] <- alternate_K[1L, 2L]
  alternate_Q <- solve(alternate_K)
  expect_lte(max(abs(alternate_K - fixture$K)), 1e-10)
  expect_lte(max(abs(alternate_Q - fixture$Q)), 1e-10)
  truth <- fixture$truth
  truth$kernel_hash <- v07d_matrix_fingerprint(
    "K_lambda", alternate_K, fixture$ids
  )
  truth$precision_hash <- v07d_matrix_fingerprint(
    "Q_lambda", alternate_Q, fixture$ids
  )
  expect_false(identical(truth$kernel_hash, fixture$hashes[["kernel_hash"]]))
  expect_false(identical(
    truth$precision_hash, fixture$hashes[["precision_hash"]]
  ))
  v3r_test_rewrite(file.path(fixture$packet, "truth.tsv"), truth)
  v3r_test_refresh_packet_lock(fixture)
  attempt <- fixture$attempt
  attempt$kernel_hash <- truth$kernel_hash
  attempt$precision_hash <- truth$precision_hash
  v3r_test_rewrite(fixture$attempt_path, attempt)

  packet <- v3r_reconstruct_packet(
    fixture$root, fixture$stage, fixture$row,
    fixture$preseal, fixture$preseal_sha
  )
  expect_identical(packet$hashes[["kernel_hash"]], truth$kernel_hash)
  expect_identical(packet$hashes[["precision_hash"]], truth$precision_hash)
  expect_false(identical(
    packet$native_hashes[["kernel_hash"]], truth$kernel_hash
  ))
  expect_false(identical(
    packet$native_hashes[["precision_hash"]], truth$precision_hash
  ))
  recomputed <- v3r_recompute_row(
    fixture$root, fixture$stage, fixture$row,
    fixture$preseal, fixture$preseal_sha
  )
  expect_identical(recomputed$kernel_hash, truth$kernel_hash)
  expect_identical(recomputed$precision_hash, truth$precision_hash)
  expect_identical(
    recomputed$base_r_kernel_hash,
    packet$native_hashes[["kernel_hash"]]
  )
  expect_identical(
    recomputed$base_r_precision_hash,
    packet$native_hashes[["precision_hash"]]
  )
})

test_that("packet, truth, attempt, and fingerprint mutations are rejected", {
  marker <- v3r_test_packet_fixture()
  on.exit(unlink(marker$root, recursive = TRUE), add = TRUE)
  path <- file.path(marker$packet, "markers.tsv")
  changed <- v07d_read_tsv(path, verify = FALSE)
  changed[[2L]][[1L]] <- 1
  changed[[2L]][[2L]] <- 0
  v3r_test_rewrite(path, changed)
  v3r_test_refresh_packet_lock(marker)
  expect_error(
    v3r_reconstruct_packet(
      marker$root, marker$stage, marker$row,
      marker$preseal, marker$preseal_sha
    ),
    "marker_hash drift"
  )

  truth <- v3r_test_packet_fixture()
  on.exit(unlink(truth$root, recursive = TRUE), add = TRUE)
  truth_changed <- truth$truth
  truth_changed$scale_denominator <- truth_changed$scale_denominator + 0.1
  v3r_test_rewrite(file.path(truth$packet, "truth.tsv"), truth_changed)
  v3r_test_refresh_packet_lock(truth)
  expect_error(
    v3r_reconstruct_packet(
      truth$root, truth$stage, truth$row,
      truth$preseal, truth$preseal_sha
    ),
    "denominator drift"
  )

  ridge <- v3r_test_packet_fixture()
  on.exit(unlink(ridge$root, recursive = TRUE), add = TRUE)
  ridge_changed <- ridge$truth
  ridge_changed$ridge <- ridge_changed$ridge + 5e-13
  v3r_test_rewrite(file.path(ridge$packet, "truth.tsv"), ridge_changed)
  v3r_test_refresh_packet_lock(ridge)
  expect_error(
    v3r_reconstruct_packet(
      ridge$root, ridge$stage, ridge$row,
      ridge$preseal, ridge$preseal_sha
    ),
    "truth/manifest mismatch in ridge"
  )

  truth_ratio <- v3r_test_packet_fixture()
  on.exit(unlink(truth_ratio$root, recursive = TRUE), add = TRUE)
  ratio_changed <- truth_ratio$truth
  ratio_changed$truth_ratio <- ratio_changed$truth_ratio + 5e-13
  v3r_test_rewrite(
    file.path(truth_ratio$packet, "truth.tsv"), ratio_changed
  )
  v3r_test_refresh_packet_lock(truth_ratio)
  expect_error(
    v3r_reconstruct_packet(
      truth_ratio$root, truth_ratio$stage, truth_ratio$row,
      truth_ratio$preseal, truth_ratio$preseal_sha
    ),
    "truth/manifest mismatch in truth_ratio"
  )

  descriptive <- v3r_test_packet_fixture()
  on.exit(unlink(descriptive$root, recursive = TRUE), add = TRUE)
  descriptive_changed <- descriptive$truth
  descriptive_changed$marker_ratio <- descriptive_changed$marker_ratio + 5e-13
  v3r_test_rewrite(
    file.path(descriptive$packet, "truth.tsv"), descriptive_changed
  )
  v3r_test_refresh_packet_lock(descriptive)
  expect_silent(v3r_reconstruct_packet(
    descriptive$root, descriptive$stage, descriptive$row,
    descriptive$preseal, descriptive$preseal_sha
  ))

  attempt <- v3r_test_packet_fixture()
  on.exit(unlink(attempt$root, recursive = TRUE), add = TRUE)
  changed_attempt <- attempt$attempt
  changed_attempt$effective_rank <- changed_attempt$effective_rank + 0.01
  v3r_test_rewrite(attempt$attempt_path, changed_attempt)
  expect_error(
    v3r_recompute_row(
      attempt$root, attempt$stage, attempt$row,
      attempt$preseal, attempt$preseal_sha
    ),
    "spectral diagnostics drift"
  )
})

test_that("corpus lock binds exact attempts and packet primaries", {
  fixture <- v3r_test_packet_fixture()
  on.exit(unlink(fixture$root, recursive = TRUE), add = TRUE)
  v3r_test_write(
    file.path(fixture$root, "stage_preseal.tsv"),
    data.frame(key = "synthetic", value = "only", stringsAsFactors = FALSE)
  )
  v3r_test_write(file.path(fixture$root, "d1_manifest.tsv"), fixture$row)
  expected <- v3r_inventory(
    fixture$root,
    v3r_expected_official_paths(fixture$root, fixture$stage, fixture$row)
  )
  lock_path <- file.path(fixture$root, "stage_corpus_lock.tsv")
  v3r_test_write(lock_path, expected)
  expect_silent(v3r_verify_corpus(fixture$root, fixture$stage, fixture$row))

  duplicate <- rbind(expected, expected[1L, , drop = FALSE])
  v3r_test_rewrite(lock_path, duplicate)
  expect_error(
    v3r_verify_corpus(fixture$root, fixture$stage, fixture$row),
    "corpus lock differs"
  )
  v3r_test_rewrite(lock_path, expected[-1L, , drop = FALSE])
  expect_error(
    v3r_verify_corpus(fixture$root, fixture$stage, fixture$row),
    "corpus lock differs"
  )
  v3r_test_rewrite(lock_path, expected)
  v3r_test_write(
    file.path(fixture$root, "attempts", "d1", "extra", "1.tsv"),
    data.frame(x = 1L)
  )
  expect_error(
    v3r_verify_corpus(fixture$root, fixture$stage, fixture$row),
    "missing or additional"
  )
})

test_that("fan-out claims nested targets without scanning the mutable subtree", {
  skip_on_os("windows")
  root <- tempfile("v3r-fanout-")
  dir.create(root)
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  on.exit(unlink(root, recursive = TRUE), add = TRUE)
  paths <- c(
    file.path(root, "base_r_recompute", "d1", "group_a", "1.tsv"),
    file.path(root, "base_r_recompute", "d1", "group_b", "2.tsv")
  )
  jobs <- lapply(seq_along(paths), function(i) {
    parallel::mcparallel(v3r_write_once(
      paths[[i]], data.frame(value = i), temporary_parent = root
    ))
  })
  results <- parallel::mccollect(jobs)
  expect_true(all(vapply(results, is.character, logical(1L))))
  expect_true(all(file.exists(c(paths, paste0(paths, ".sha256")))))

  raced <- file.path(root, "base_r_recompute", "d1", "group_c", "3.tsv")
  race_jobs <- lapply(1:2, function(i) {
    parallel::mcparallel(try(v3r_write_once(
      raced, data.frame(value = i), temporary_parent = root
    ), silent = TRUE))
  })
  race <- parallel::mccollect(race_jobs)
  expect_equal(sum(vapply(race, inherits, logical(1L), "try-error")), 1L)
  expect_silent(v3r_verify_pair(raced))
})

test_that("failed attempts stay in the denominator and cannot be removed", {
  h64 <- function(x) v3r_test_hash(x)
  h40 <- function(x) v3r_test_hash(x, 40L)
  binding <- list(
    preseal_sha256 = h64("e"), manifest_sha256 = h64("f"),
    corpus_lock_sha256 = h64("a"), r_auto_route_commit = h40("a"),
    julia_candidate_commit = h40("b"), r_driver_commit = h40("c"),
    julia_replay_commit = h40("d"), julia_replay_sha256 = h64("b")
  )
  fixture <- v3p_d1_summary_parity_fixture(binding)
  failed <- fixture$attempts
  failed$status[[1L]] <- "fit_error"
  failed$error_class[[1L]] <- "optimizer_error"
  failed$converged[[1L]] <- FALSE
  for (field in c(
    "boundary_status", "boundary_reason", "boundary_epsilon",
    "scientific_sigma_g2", "scientific_sigma_e2", "scientific_ratio",
    "fitted_total_variance", "numerical_sigma_g2", "numerical_sigma_e2",
    "numerical_ratio", "profile_loglik", "lower_derivative_per_observation",
    "upper_derivative_per_observation", "iterations", "objective",
    "gradient_norm"
  )) failed[[field]][[1L]] <- NA
  admitted <- v3p_admit_d1_attempts(failed, fixture$manifest, binding)
  expect_equal(nrow(admitted), 576L)
  expect_equal(sum(!admitted$converged), 1L)
  expect_error(
    v3p_admit_d1_attempts(failed[-1L, ], fixture$manifest, binding),
    "manifest denominator"
  )
  duplicated <- rbind(failed[-1L, ], failed[2L, , drop = FALSE])
  expect_error(
    v3p_admit_d1_attempts(duplicated, fixture$manifest, binding),
    "manifest denominator"
  )

  fail_rows <- function(x, rows) {
    for (i in rows) {
      x$status[[i]] <- "fit_error"
      x$error_class[[i]] <- "optimizer_error"
      x$converged[[i]] <- FALSE
      for (field in c(
        "boundary_status", "boundary_reason", "boundary_epsilon",
        "scientific_sigma_g2", "scientific_sigma_e2", "scientific_ratio",
        "fitted_total_variance", "numerical_sigma_g2", "numerical_sigma_e2",
        "numerical_ratio", "profile_loglik", "lower_derivative_per_observation",
        "upper_derivative_per_observation", "iterations", "objective",
        "gradient_norm"
      )) x[[field]][[i]] <- NA
    }
    x
  }
  low <- fail_rows(fixture$attempts, 1:3)
  low_summary <- v3p_d1_summary(fixture$manifest, low, binding)
  expect_true(any(low_summary$cell_status == "STOP_LOW_PILOT_CONVERGENCE"))
  expect_identical(
    v3r_compare_summary_triplet(low_summary, low_summary, low_summary, "d1"),
    0
  )
  severe <- fail_rows(fixture$attempts, 1:47)
  severe_summary <- v3p_d1_summary(fixture$manifest, severe, binding)
  expect_true(any(is.infinite(severe_summary$required_n)))
  expect_identical(
    v3r_compare_summary_triplet(
      severe_summary, severe_summary, severe_summary, "d1"
    ),
    0
  )
  one_sided <- severe_summary
  at <- which(is.infinite(one_sided$required_n))[[1L]]
  one_sided$required_n[[at]] <- 100
  expect_error(
    v3r_compare_summary_triplet(
      severe_summary, one_sided, severe_summary, "d1"
    ),
    "infinity"
  )
  opposite <- severe_summary
  opposite$required_n[[at]] <- -Inf
  expect_error(
    v3r_compare_summary_triplet(
      severe_summary, opposite, severe_summary, "d1"
    ),
    "infinity"
  )
})

test_that("full typed parity rejects changed R or Julia summaries", {
  h64 <- function(x) v3r_test_hash(x)
  h40 <- function(x) v3r_test_hash(x, 40L)
  binding <- list(
    preseal_sha256 = h64("e"), manifest_sha256 = h64("f"),
    corpus_lock_sha256 = h64("a"), r_auto_route_commit = h40("a"),
    julia_candidate_commit = h40("b"), r_driver_commit = h40("c"),
    julia_replay_commit = h40("d"), julia_replay_sha256 = h64("b")
  )
  d1 <- v3p_d1_summary_parity_fixture(binding)$summary
  expect_silent(v3p_adjudicate_summaries(d1, d1, d1, "d1"))
  changed <- d1
  changed$mean_spectral_cv[[1L]] <- changed$mean_spectral_cv[[1L]] + 1e-5
  expect_error(
    v3p_adjudicate_summaries(d1, changed, d1, "d1"),
    "summary mismatch"
  )
  logical <- d1
  logical$cell_eligible[[1L]] <- !logical$cell_eligible[[1L]]
  expect_error(
    v3p_adjudicate_summaries(d1, d1, logical, "d1"),
    "summary mismatch"
  )
})

v3r_test_review_fixture <- function() {
  root <- tempfile("v3r-review-")
  dir.create(root)
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  preseal <- v3r_test_preseal()
  state <- list(
    root = root, stage = "d1", preseal = list(
      sha256 = v3r_test_hash("a"), value = preseal
    ),
    corpus = list(sha256 = v3r_test_hash("b"))
  )
  evidence <- list(
    base_r_inventory_sha256 = v3r_test_hash("c"),
    julia_replay_inventory_sha256 = v3r_test_hash("d"),
    r_summary_sha256 = v3r_test_hash("e"),
    julia_summary_sha256 = v3r_test_hash("f"),
    route_lineage_sha256 = v3r_test_hash("a")
  )
  list(root = root, state = state, evidence = evidence)
}

test_that("post-run reviews bind exact evidence and CLEAN is mandatory", {
  fixture <- v3r_test_review_fixture()
  on.exit(unlink(fixture$root, recursive = TRUE), add = TRUE)
  path <- v3r_review_path(fixture$root, "fisher")
  row <- v3r_review_row(
    fixture$state, fixture$evidence, "fisher", "CLEAN",
    "ELIGIBLE=12",
    "2026-07-14T02:00:00Z"
  )
  v3r_test_write(path, row)
  expect_silent(v3r_validate_review(
    path, "fisher", fixture$state, fixture$evidence, "ELIGIBLE=12"
  ))
  decision_mutation <- row
  decision_mutation$stage_decision <- "PRECISION_BLOCKER=12"
  v3r_test_rewrite(path, decision_mutation)
  expect_error(
    v3r_validate_review(
      path, "fisher", fixture$state, fixture$evidence, "ELIGIBLE=12"
    ),
    "binding drift"
  )
  blocked <- row
  blocked$verdict <- "BLOCKED"
  v3r_test_rewrite(path, blocked)
  expect_error(
    v3r_validate_review(
      path, "fisher", fixture$state, fixture$evidence, "ELIGIBLE=12"
    ),
    "not CLEAN"
  )
  hash_mutation <- row
  hash_mutation$r_summary_sha256 <- v3r_test_hash("a")
  v3r_test_rewrite(path, hash_mutation)
  expect_error(
    v3r_validate_review(
      path, "fisher", fixture$state, fixture$evidence, "ELIGIBLE=12"
    ),
    "binding drift"
  )
})

test_that("final receipt binds all tool, commit, inventory, summary, and review hashes", {
  fixture <- v3r_test_review_fixture()
  on.exit(unlink(fixture$root, recursive = TRUE), add = TRUE)
  reviews <- setNames(lapply(seq_along(v3p_reviewers), function(i) {
    reviewer <- v3p_reviewers[[i]]
    list(
      path = file.path(fixture$root, paste0(reviewer, ".tsv")),
      sha256 = v3r_test_hash(as.character(i + 1L))
    )
  }), v3p_reviewers)
  h64 <- function(x) v3r_test_hash(x)
  h40 <- function(x) v3r_test_hash(x, 40L)
  binding <- list(
    preseal_sha256 = h64("e"), manifest_sha256 = h64("f"),
    corpus_lock_sha256 = h64("a"), r_auto_route_commit = h40("a"),
    julia_candidate_commit = h40("b"), r_driver_commit = h40("c"),
    julia_replay_commit = h40("d"), julia_replay_sha256 = h64("b")
  )
  summary <- v3p_d1_summary_parity_fixture(binding)$summary
  receipt <- v3r_receipt_row(
    fixture$state, fixture$evidence, reviews, summary, 0, 0
  )
  expect_identical(names(receipt), v3r_receipt_columns)
  expect_identical(receipt$verdict, "PASS")
  expect_identical(receipt$stage_decision, "ELIGIBLE=12")
  expect_identical(
    receipt$r_recomputer_sha256,
    fixture$state$preseal$value[["r_recomputer_sha256"]]
  )
  expect_identical(
    receipt$julia_replay_inventory_sha256,
    fixture$evidence$julia_replay_inventory_sha256
  )
  expect_identical(receipt$attempt_max_diff, "0")
  expect_identical(receipt$summary_max_diff, "0")
  expect_silent(v3r_validate_receipt_row(receipt, receipt))
  key_mutation <- receipt
  key_mutation$adjudication_key_sha256 <- v3r_test_hash("f")
  expect_error(
    v3r_validate_receipt_row(key_mutation, key_mutation),
    "key is invalid"
  )
  binding_mutation <- receipt
  binding_mutation$route_lineage_sha256 <- v3r_test_hash("b")
  expect_error(
    v3r_validate_receipt_row(binding_mutation, binding_mutation),
    "key is invalid"
  )
  attempt_mutation <- receipt
  attempt_mutation$attempt_max_diff <- "1.1e-10"
  expect_error(
    v3r_validate_receipt_row(attempt_mutation, receipt),
    "maximum exceeds"
  )
  summary_mutation <- receipt
  summary_mutation$summary_max_diff <- "1.1e-10"
  expect_error(
    v3r_validate_receipt_row(summary_mutation, receipt),
    "maximum exceeds"
  )

  exact_root <- tempfile("v3r-exact-receipt-")
  dir.create(exact_root)
  exact_root <- normalizePath(exact_root, winslash = "/", mustWork = TRUE)
  on.exit(unlink(exact_root, recursive = TRUE), add = TRUE)
  exact_path <- file.path(exact_root, "stage_adjudication_receipt.tsv")
  expect_identical(
    v3r_ensure_exact_adjudication_receipt(exact_path, receipt, exact_root),
    "created"
  )
  exact_bytes <- readBin(exact_path, "raw", file.info(exact_path)$size)
  exact_sidecar <- readBin(
    paste0(exact_path, ".sha256"), "raw",
    file.info(paste0(exact_path, ".sha256"))$size
  )
  expect_identical(
    v3r_ensure_exact_adjudication_receipt(exact_path, receipt, exact_root),
    "existing"
  )
  expect_identical(
    readBin(exact_path, "raw", file.info(exact_path)$size), exact_bytes
  )
  expect_identical(
    readBin(
      paste0(exact_path, ".sha256"), "raw",
      file.info(paste0(exact_path, ".sha256"))$size
    ),
    exact_sidecar
  )
  conflicting <- receipt
  conflicting$route_lineage_sha256 <- v3r_test_hash("b")
  conflicting$adjudication_key_sha256 <- v3r_adjudication_key(conflicting)
  expect_error(
    v3r_ensure_exact_adjudication_receipt(
      exact_path, conflicting, exact_root
    ),
    "differs from the current exact evidence"
  )
  orphan_path <- file.path(exact_root, "orphan.tsv")
  v3r_test_write(orphan_path, receipt)
  unlink(paste0(orphan_path, ".sha256"))
  expect_error(
    v3r_ensure_exact_adjudication_receipt(
      orphan_path, receipt, exact_root
    ),
    "orphaned"
  )
})

test_that("post-run receipt subtree rejects missing, extra, and relocated members", {
  root <- tempfile("v3r-postrun-tree-")
  dir.create(root)
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  on.exit(unlink(root, recursive = TRUE), add = TRUE)
  paths <- vapply(v3p_reviewers, function(reviewer) {
    path <- v3r_review_path(root, reviewer)
    v3r_test_write(path, data.frame(x = reviewer))
    path
  }, character(1L))
  expect_silent(v3r_verify_exact_tree(
    root, paths, "post-run receipt tree"
  ))
  unlink(c(paths[[1L]], paste0(paths[[1L]], ".sha256")))
  expect_error(
    v3r_verify_exact_tree(
      root, paths, "post-run receipt tree"
    ),
    "missing or additional"
  )
  v3r_test_write(paths[[1L]], data.frame(x = v3p_reviewers[[1L]]))
  extra <- file.path(root, "postrun_receipts", "extra.tsv")
  v3r_test_write(extra, data.frame(x = "extra"))
  expect_error(
    v3r_verify_exact_tree(
      root, paths, "post-run receipt tree"
    ),
    "missing or additional"
  )
  unlink(c(extra, paste0(extra, ".sha256")))
  relocated <- file.path(root, "fisher.tsv")
  file.rename(paths[[1L]], relocated)
  file.rename(paste0(paths[[1L]], ".sha256"), paste0(relocated, ".sha256"))
  expect_error(
    v3r_verify_exact_tree(
      root, paths, "post-run receipt tree"
    ),
    "missing or additional"
  )
})

test_that("synthetic finalization creates once and validates the exact tree", {
  fixture <- v3r_test_packet_fixture("d1")
  root <- fixture$root
  on.exit(unlink(root, recursive = TRUE), add = TRUE)
  state <- list(root = root, stage = "d1", manifest = fixture$row)

  primaries <- file.path(root, v3p_preseal_names("d1", TRUE))
  primaries <- c(
    primaries,
    file.path(root, "stage_corpus_lock.tsv"),
    fixture$attempt_path,
    file.path(fixture$packet, v3r_packet_primaries),
    v3r_recompute_path(root, "d1", fixture$row),
    v3r_julia_path(root, "d1", fixture$row),
    file.path(root, "d1_summary_r.tsv"),
    file.path(root, "d1_summary_julia.tsv"),
    file.path(root, "stage_route_lineage.tsv"),
    vapply(v3p_reviewers, function(reviewer) {
      v3r_review_path(root, reviewer)
    }, character(1L))
  )
  primaries <- unique(primaries)
  existing <- primaries[file.exists(primaries)]
  if (length(existing)) {
    unlink(c(existing, paste0(existing, ".sha256")))
  }
  for (i in seq_along(primaries)) {
    v3r_test_write(
      primaries[[i]],
      data.frame(member = i, stringsAsFactors = FALSE)
    )
  }

  receipt_values <- setNames(
    rep(v3r_test_hash("a"), length(v3r_receipt_columns)),
    v3r_receipt_columns
  )
  receipt_values[c(
    "schema_version", "stage", "verdict", "stage_decision",
    "attempt_max_diff", "summary_max_diff"
  )] <- c(v3r_schema, "d1", "PASS", "ELIGIBLE=1", "0", "0")
  for (reviewer in v3p_reviewers) {
    path <- v3r_review_path(root, reviewer)
    receipt_values[[paste0(reviewer, "_review_path")]] <- file.path(
      "postrun_receipts", paste0(reviewer, ".tsv")
    )
    receipt_values[[paste0(reviewer, "_review_sha256")]] <- v07d_sha256(path)
  }
  receipt <- as.data.frame(
    as.list(receipt_values), stringsAsFactors = FALSE
  )[v3r_receipt_columns]
  receipt$adjudication_key_sha256 <- v3r_adjudication_key(receipt)

  target <- environment(v3r_adjudicate)
  original_expected_final <- get(
    "v3r_expected_final", envir = target, inherits = FALSE
  )
  assign(
    "v3r_expected_final",
    function(observed_root, observed_stage) {
      if (!identical(observed_root, root) || !identical(observed_stage, "d1")) {
        v3r_abort("synthetic finalization received the wrong root or stage")
      }
      list(state = state, receipt = receipt)
    },
    envir = target
  )
  on.exit(assign(
    "v3r_expected_final", original_expected_final, envir = target
  ), add = TRUE)

  expect_message(
    created <- v3r_adjudicate(root, "d1"),
    "wrote d1 adjudication receipt"
  )
  expect_identical(created, receipt)
  receipt_path <- file.path(root, "stage_adjudication_receipt.tsv")
  expect_true(file.exists(receipt_path))
  expect_true(file.exists(paste0(receipt_path, ".sha256")))
  first_hash <- v07d_sha256(receipt_path)
  expect_message(
    validated <- v3r_validate_final(root, "d1"),
    "validated d1 final receipt"
  )
  expect_true(v3r_same_text_table(validated, receipt))
  expect_message(
    retried <- v3r_adjudicate(root, "d1"),
    "verified existing d1 adjudication receipt"
  )
  expect_true(v3r_same_text_table(retried, receipt))
  expect_identical(v07d_sha256(receipt_path), first_hash)
  expect_silent(v3r_verify_final_tree(state, include_receipt = TRUE))
})

test_that("phase transitions fail closed before summaries, reviews, and receipt", {
  no_compute <- function(...) invisible(TRUE)
  fixture <- v3r_test_packet_fixture()
  on.exit(unlink(fixture$root, recursive = TRUE), add = TRUE)
  state <- list(root = fixture$root, stage = "d1", manifest = fixture$row)
  expect_error(v3r_read_rows(state, "base_r"), "absolute existing")
  expect_error(
    v3r_validate_final(fixture$root, "d1"),
    "missing"
  )
  expect_error(
    v3r_main(c(
      "--mode=adjudicate", paste0("--output-root=", fixture$root),
      "--stage=d1"
    ), execution_guard = no_compute),
    "missing, orphaned"
  )
  expect_error(
    v3r_main(c(
      "--mode=validate-final", paste0("--output-root=", fixture$root),
      "--stage=d1"
    ), execution_guard = no_compute),
    "missing"
  )
})

test_that("CLI modes and launcher-facing options are stable", {
  no_compute <- function(...) invisible(TRUE)
  expect_message(v3r_main(c("--mode=selftest")), "selftest: PASS")
  expect_error(
    v3r_main(c("selftest", "--mode=selftest"), execution_guard = no_compute),
    "either positionally"
  )
  expect_error(
    v3r_main(
      c("--mode=recompute-one", "--output-root=/tmp", "--stage=d1"),
      execution_guard = no_compute
    ),
    "--group is required"
  )
})

v3r_test_batch_state <- function(n = 4L) {
  root <- tempfile("v3r-batch-root-")
  dir.create(root)
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  manifest <- data.frame(
    cell_id = sprintf("tiny_d1_%02d", seq_len(n)),
    seed = 2029900000 + seq_len(n), stringsAsFactors = FALSE
  )
  paths <- character()
  for (i in seq_len(n)) {
    row <- manifest[i, , drop = FALSE]
    attempt <- v3r_attempt_path(root, "d1", row)
    packet <- v3r_packet_dir(root, "d1", row)
    v3r_test_write(attempt, data.frame(value = i))
    paths <- c(paths, attempt)
    for (name in v3r_packet_primaries) {
      path <- file.path(packet, name)
      v3r_test_write(path, data.frame(value = paste(i, name)))
      paths <- c(paths, path)
    }
  }
  corpus <- data.frame(
    relative_path = substring(paths, nchar(root) + 2L),
    sha256 = vapply(paths, v07d_sha256, character(1L)),
    stringsAsFactors = FALSE
  )
  state <- list(
    root = root, stage = "d1", manifest = manifest,
    preseal = list(value = v3r_test_preseal(), sha256 = v3r_test_hash("f")),
    corpus = list(table = corpus, sha256 = v3r_test_hash("a"))
  )
  plan_path <- file.path(
    dirname(root), paste0(basename(root), "-external-batch-plan.tsv")
  )
  list(root = root, state = state, plan_path = plan_path)
}

v3r_test_write_batch_plan <- function(fixture, plan) {
  v3r_test_write(fixture$plan_path, plan)
  invisible(fixture$plan_path)
}

v3r_test_batch_recomputer <- function(root, stage, row, preseal, preseal_sha256) {
  data.frame(
    group = v3r_group(row, stage), seed = v3r_seed(row),
    scientific_value = as.numeric(row$seed) / 10, stringsAsFactors = FALSE
  )
}

v3r_test_batch_cleanup <- function(fixture) {
  unlink(c(
    fixture$root, fixture$plan_path, paste0(fixture$plan_path, ".sha256")
  ), recursive = TRUE)
}

test_that("batch planning canonicalizes order and covers the missing denominator once", {
  fixture <- v3r_test_batch_state()
  on.exit(v3r_test_batch_cleanup(fixture), add = TRUE)
  forward <- v3r_build_batch_plan(fixture$state, 2L)
  reverse <- v3r_build_batch_plan(fixture$state, 2L, rev(seq_len(4L)))
  expect_identical(forward, reverse)
  expect_identical(forward$batch_id, c("b0001", "b0001", "b0002", "b0002"))
  expect_identical(forward$batch_rank, c(1L, 2L, 1L, 2L))
  v3r_test_write_batch_plan(fixture, forward)
  authenticated <- v3r_read_batch_plan(fixture$state, fixture$plan_path)
  expect_silent(v3r_validate_batch_plan_missing(fixture$state, authenticated))
  expect_identical(
    sort(attr(authenticated, "manifest_indices")),
    seq_len(nrow(fixture$state$manifest))
  )
})

test_that("one batch validates the full corpus once and complete prefixes resume", {
  fixture <- v3r_test_batch_state()
  on.exit(v3r_test_batch_cleanup(fixture), add = TRUE)
  v3r_test_write_batch_plan(fixture, v3r_build_batch_plan(fixture$state, 2L))
  reads <- 0L
  state_reader <- function(root, stage, ...) {
    reads <<- reads + 1L
    expect_identical(root, fixture$root)
    expect_identical(stage, "d1")
    fixture$state
  }
  first <- v3r_recompute_batch(
    fixture$root, "d1", fixture$plan_path, "b0001",
    stage_reader = state_reader, row_recomputer = v3r_test_batch_recomputer
  )
  expect_identical(reads, 1L)
  expect_identical(first$written, 2L)
  expect_identical(first$already_complete, 0L)
  values <- lapply(seq_len(2L), function(i) {
    row <- fixture$state$manifest[i, , drop = FALSE]
    v3r_read_tsv(
      v3r_recompute_path(fixture$root, "d1", row),
      c("group", "seed", "scientific_value")
    )
  })
  second <- v3r_recompute_batch(
    fixture$root, "d1", fixture$plan_path, "b0001",
    stage_reader = state_reader, row_recomputer = v3r_test_batch_recomputer
  )
  expect_identical(reads, 2L)
  expect_identical(second$written, 0L)
  expect_identical(second$already_complete, 2L)
  repeated <- lapply(seq_len(2L), function(i) {
    row <- fixture$state$manifest[i, , drop = FALSE]
    v3r_read_tsv(
      v3r_recompute_path(fixture$root, "d1", row),
      c("group", "seed", "scientific_value")
    )
  })
  expect_identical(values, repeated)
})

test_that("row inputs are reauthenticated after plan preparation", {
  fixture <- v3r_test_batch_state(2L)
  on.exit(v3r_test_batch_cleanup(fixture), add = TRUE)
  v3r_test_write_batch_plan(fixture, v3r_build_batch_plan(fixture$state, 2L))
  affected <- fixture$state$manifest[1L, , drop = FALSE]
  v3r_test_rewrite(
    v3r_attempt_path(fixture$root, "d1", affected),
    data.frame(value = "mutated-after-plan")
  )
  expect_error(
    v3r_recompute_batch(
      fixture$root, "d1", fixture$plan_path, "b0001",
      stage_reader = function(...) fixture$state,
      row_recomputer = v3r_test_batch_recomputer
    ),
    "frozen SHA-256 mismatch|digest mismatch|expected"
  )
  expect_false(file.exists(v3r_recompute_path(fixture$root, "d1", affected)))
})

test_that("batch plans reject duplicates unknown rows wrong roots and stale targets", {
  fixture <- v3r_test_batch_state(3L)
  on.exit(v3r_test_batch_cleanup(fixture), add = TRUE)
  original <- v3r_build_batch_plan(fixture$state, 2L)

  duplicate <- original
  duplicate[2L, c("group", "seed")] <- duplicate[1L, c("group", "seed")]
  v3r_test_write_batch_plan(fixture, duplicate)
  expect_error(v3r_read_batch_plan(fixture$state, fixture$plan_path), "duplicate")

  unlink(c(fixture$plan_path, paste0(fixture$plan_path, ".sha256")))
  unknown <- original
  unknown$group[[1L]] <- "not_a_manifest_member"
  v3r_test_write_batch_plan(fixture, unknown)
  expect_error(v3r_read_batch_plan(fixture$state, fixture$plan_path), "unknown")

  unlink(c(fixture$plan_path, paste0(fixture$plan_path, ".sha256")))
  wrong_root <- original
  wrong_root$output_root <- paste0(fixture$root, "-other")
  v3r_test_write_batch_plan(fixture, wrong_root)
  expect_error(v3r_read_batch_plan(fixture$state, fixture$plan_path), "output_root")

  unlink(c(fixture$plan_path, paste0(fixture$plan_path, ".sha256")))
  v3r_test_write_batch_plan(fixture, original)
  first <- fixture$state$manifest[1L, , drop = FALSE]
  v3r_test_write(
    v3r_recompute_path(fixture$root, "d1", first),
    v3r_test_batch_recomputer(
      fixture$root, "d1", first,
      fixture$state$preseal$value, fixture$state$preseal$sha256
    )
  )
  authenticated <- v3r_read_batch_plan(fixture$state, fixture$plan_path)
  expect_error(
    v3r_validate_batch_plan_missing(fixture$state, authenticated),
    "missing manifest denominator"
  )
  expect_message(
    v3r_authenticate_batch_plan(
      fixture$root, "d1", fixture$plan_path,
      stage_reader = function(...) fixture$state
    ),
    "authenticated resumable base-R batch plan"
  )

  incomplete <- original[1:2, , drop = FALSE]
  unlink(c(fixture$plan_path, paste0(fixture$plan_path, ".sha256")))
  v3r_test_write_batch_plan(fixture, incomplete)
  expect_error(
    v3r_authenticate_batch_plan(
      fixture$root, "d1", fixture$plan_path,
      stage_reader = function(...) fixture$state
    ),
    "does not cover every currently missing row"
  )
  expect_error(
    v3r_external_batch_path(
      file.path(fixture$root, "batch-plan.tsv"), fixture$root,
      must_exist = FALSE
    ),
    "outside the evidence root"
  )
})

test_that("partial batch targets fail before any new row is written", {
  fixture <- v3r_test_batch_state(2L)
  on.exit(v3r_test_batch_cleanup(fixture), add = TRUE)
  v3r_test_write_batch_plan(fixture, v3r_build_batch_plan(fixture$state, 2L))
  first <- fixture$state$manifest[1L, , drop = FALSE]
  second <- fixture$state$manifest[2L, , drop = FALSE]
  first_target <- v3r_recompute_path(fixture$root, "d1", first)
  dir.create(dirname(first_target), recursive = TRUE)
  writeLines("orphan-primary", first_target)
  expect_error(
    v3r_recompute_batch(
      fixture$root, "d1", fixture$plan_path, "b0001",
      stage_reader = function(...) fixture$state,
      row_recomputer = v3r_test_batch_recomputer
    ),
    "partial primary/sidecar"
  )
  expect_false(file.exists(v3r_recompute_path(fixture$root, "d1", second)))
})

test_that("non-prefix complete batch targets fail before writes", {
  fixture <- v3r_test_batch_state(2L)
  on.exit(v3r_test_batch_cleanup(fixture), add = TRUE)
  v3r_test_write_batch_plan(fixture, v3r_build_batch_plan(fixture$state, 2L))
  first <- fixture$state$manifest[1L, , drop = FALSE]
  second <- fixture$state$manifest[2L, , drop = FALSE]
  v3r_test_write(
    v3r_recompute_path(fixture$root, "d1", second),
    v3r_test_batch_recomputer(
      fixture$root, "d1", second,
      fixture$state$preseal$value, fixture$state$preseal$sha256
    )
  )
  expect_error(
    v3r_recompute_batch(
      fixture$root, "d1", fixture$plan_path, "b0001",
      stage_reader = function(...) fixture$state,
      row_recomputer = v3r_test_batch_recomputer
    ),
    "not a complete resumable prefix"
  )
  expect_false(file.exists(v3r_recompute_path(fixture$root, "d1", first)))
})

# ---------------------------------------------------------------------------
# Retry-7 regression tail: the D0F operational adjudicator at full 576
# cardinality across every boundary-classification arm and both summary
# routes. Prior to this block no test exercised v3p_d0f_summary_route's
# non-interior arms (interior_rescued / boundary_lower / boundary_upper /
# unresolved / error), nor v3r_expected_summary_route at D0F. These tests only
# exercise fixes that already exist in the sealed tools; they add no behaviour.
#
# Source-verified invariants that shape the fixtures below:
#   * The D0F manifest and its fixed panels are FULLY order-pinned
#     (v3p_validate_d0f_fixed_panels requires canonical design/panel order;
#     v3p_validate_d0f_phenotype_manifest requires panel-major, phenotype-minor
#     1..8 order). A permuted manifest is therefore inadmissible, so tally
#     "permutation invariance" is tested as position-invariance across two
#     admissible canonical layouts (arms at head vs tail), not a row shuffle.
#   * Unsuccessful rows must satisfy v3p_validate_unsuccessful_results exactly:
#     required-NA scientific/optimizer fields, and either a boundary_unresolved
#     arm (non-empty reason, boundary_epsilon == v3p_boundary_epsilon, all-NA or
#     all-finite evidence) or an error arm (boundary_status NA, all boundary
#     evidence NA).

v3r_test_route_binding <- function() {
  list(
    preseal_sha256 = v3r_test_hash("e"),
    manifest_sha256 = v3r_test_hash("f"),
    corpus_lock_sha256 = v3r_test_hash("a"),
    r_auto_route_commit = v3r_test_hash("a", 40L),
    julia_candidate_commit = v3r_test_hash("b", 40L),
    r_driver_commit = v3r_test_hash("c", 40L),
    julia_replay_commit = v3r_test_hash("d", 40L),
    julia_replay_sha256 = v3r_test_hash("b")
  )
}

v3r_test_as_julia <- function(attempts, binding) {
  attempts$route <- "julia_profile_replay"
  attempts$driver_commit <- binding$julia_replay_commit
  attempts
}

# Clone the parity fixture's admitted attempts, then overwrite the boundary /
# convergence / scientific fields per design (192 rows each) to populate every
# classification arm, and re-admit so v3p_validate_results re-checks the result.
# all_converged = TRUE  -> 150 interior / 12 rescued / 15 lower / 15 upper.
# all_converged = FALSE -> 130 interior / 12 rescued / 15 lower / 15 upper
#                          + 10 boundary_unresolved + 10 error (172 converged).
v3r_test_d0f_mixed_fixture <- function(
  binding, all_converged = TRUE, layout = c("tail", "head")
) {
  layout <- match.arg(layout)
  base <- v3p_d0f_summary_parity_fixture(binding)
  manifest <- base$manifest
  a <- base$attempts
  eps <- v3p_boundary_epsilon
  fail_fields <- c(
    "scientific_sigma_g2", "scientific_sigma_e2", "scientific_ratio",
    "fitted_total_variance", "numerical_sigma_g2", "numerical_sigma_e2",
    "numerical_ratio", "iterations", "objective", "gradient_norm",
    "profile_loglik", "lower_derivative_per_observation",
    "upper_derivative_per_observation", "boundary_epsilon"
  )
  set_rescued <- function(a, r) {
    a$boundary_status[r] <- "interior_rescued"
    a$boundary_reason[r] <- "profile_interior"
    a
  }
  set_lower <- function(a, r) {
    a$boundary_status[r] <- "boundary_lower"
    a$boundary_reason[r] <- "boundary_lower"
    a$scientific_ratio[r] <- 0
    a$scientific_sigma_g2[r] <- 0
    a$scientific_sigma_e2[r] <- a$fitted_total_variance[r]
    a$numerical_ratio[r] <- eps
    a$numerical_sigma_g2[r] <- eps * a$fitted_total_variance[r]
    a$numerical_sigma_e2[r] <-
      a$fitted_total_variance[r] - eps * a$fitted_total_variance[r]
    a$lower_derivative_per_observation[r] <- -1
    a
  }
  set_upper <- function(a, r) {
    a$boundary_status[r] <- "boundary_upper"
    a$boundary_reason[r] <- "boundary_upper"
    a$scientific_ratio[r] <- 1
    a$scientific_sigma_g2[r] <- a$fitted_total_variance[r]
    a$scientific_sigma_e2[r] <- 0
    a$numerical_ratio[r] <- 1 - eps
    a$numerical_sigma_g2[r] <- a$fitted_total_variance[r] * (1 - eps)
    a$numerical_sigma_e2[r] <- a$fitted_total_variance[r] * eps
    a$upper_derivative_per_observation[r] <- 1
    a
  }
  set_error <- function(a, r) {
    a$status[r] <- "fit_error"
    a$error_class[r] <- "optimizer_error"
    a$converged[r] <- FALSE
    for (f in fail_fields) a[[f]][r] <- NA
    a$boundary_status[r] <- NA
    a$boundary_reason[r] <- NA
    a
  }
  set_unresolved <- function(a, r) {
    a$status[r] <- "fit_error"
    a$error_class[r] <- "boundary_unresolved_error"
    a$converged[r] <- FALSE
    for (f in fail_fields) a[[f]][r] <- NA
    a$boundary_status[r] <- "boundary_unresolved"
    a$boundary_reason[r] <- "profile_flat"
    a$boundary_epsilon[r] <- eps
    a
  }
  for (design_id in v3p_d0f_designs$design_id) {
    idx <- which(a$design_id == design_id)
    if (identical(layout, "head")) idx <- rev(idx)
    if (all_converged) {
      a <- set_rescued(a, idx[151:162])
      a <- set_lower(a, idx[163:177])
      a <- set_upper(a, idx[178:192])
    } else {
      a <- set_rescued(a, idx[131:142])
      a <- set_lower(a, idx[143:157])
      a <- set_upper(a, idx[158:172])
      a <- set_unresolved(a, idx[173:182])
      a <- set_error(a, idx[183:192])
    }
  }
  attempts <- v3p_admit_d0f_attempts(a, manifest, binding)
  list(manifest = manifest, attempts = attempts, bootstrap = base$bootstrap)
}

v3r_test_d0f_bootstrap_sha <- function(root, bootstrap) {
  path <- file.path(root, "d0f_bootstrap_indices.tsv")
  v3r_test_write(path, bootstrap)
  list(path = path, sha256 = v07d_sha256(path))
}

test_that("D0F summary conserves 576 across boundary classes and both routes", {
  binding <- v3r_test_route_binding()
  mixed <- v3r_test_d0f_mixed_fixture(binding)
  root <- tempfile("v3r-d0f-multiroute-")
  dir.create(root)
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  on.exit(unlink(root, recursive = TRUE), add = TRUE)
  boot <- v3r_test_d0f_bootstrap_sha(root, mixed$bootstrap)

  summary <- v3p_d0f_summary(
    mixed$manifest, mixed$attempts, mixed$bootstrap, boot$sha256, binding
  )
  expect_equal(nrow(summary), 3L)
  class_cols <- c(
    "n_interior", "n_interior_rescued", "n_boundary_lower",
    "n_boundary_upper", "n_unresolved", "n_error"
  )
  expect_true(all(rowSums(summary[class_cols]) == summary$n_attempted))
  expect_true(all(summary$n_attempted == 192L))
  expect_equal(sum(summary$n_attempted), 576L)
  expect_true(all(summary$n_interior == 150L))
  expect_true(all(summary$n_interior_rescued == 12L))
  expect_true(all(summary$n_boundary_lower == 15L))
  expect_true(all(summary$n_boundary_upper == 15L))
  expect_true(all(summary$n_unresolved == 0L))
  expect_true(all(summary$n_error == 0L))
  expect_true(all(summary$d0f_status == "COMPLETE"))

  julia_attempts <- v3r_test_as_julia(mixed$attempts, binding)
  julia_summary <- v3p_d0f_julia_summary(
    mixed$manifest, julia_attempts, mixed$bootstrap, boot$sha256, binding
  )
  expect_silent(v3p_adjudicate_summaries(summary, summary, julia_summary, "d0f"))
  mutated <- julia_summary
  mutated$n_boundary_lower[[1L]] <- mutated$n_boundary_lower[[1L]] + 1L
  expect_error(
    v3p_adjudicate_summaries(summary, summary, mutated, "d0f"),
    "summary mismatch"
  )
})

test_that("D0F partial failure keeps the denominator and blocks the stage", {
  binding <- v3r_test_route_binding()
  mixed <- v3r_test_d0f_mixed_fixture(binding, all_converged = FALSE)
  root <- tempfile("v3r-d0f-blocker-")
  dir.create(root)
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  on.exit(unlink(root, recursive = TRUE), add = TRUE)
  boot <- v3r_test_d0f_bootstrap_sha(root, mixed$bootstrap)

  summary <- v3p_d0f_summary(
    mixed$manifest, mixed$attempts, mixed$bootstrap, boot$sha256, binding
  )
  class_cols <- c(
    "n_interior", "n_interior_rescued", "n_boundary_lower",
    "n_boundary_upper", "n_unresolved", "n_error"
  )
  expect_true(all(rowSums(summary[class_cols]) == summary$n_attempted))
  expect_equal(sum(summary$n_attempted), 576L)
  expect_identical(v3r_stage_decision(summary, "d0f"), "D0F_FIT_BLOCKER")
  expect_true(all(v3p_bool(summary$fit_blocker, "fit_blocker")))
  expect_gt(sum(summary$n_unresolved + summary$n_error), 0)
  expect_true(all(summary$n_converged == 172L))
  expect_true(all(is.na(summary$variance_within)))
  expect_true(all(is.na(summary$variance_within_bootstrap_lower)))
  expect_true(all(is.na(summary$mean_ratio)))
  expect_error(
    v3p_admit_d0f_attempts(mixed$attempts[-1L, ], mixed$manifest, binding),
    "manifest denominator"
  )
})

test_that("isolated-root expected D0F summary dispatches by route", {
  binding <- v3r_test_route_binding()
  mixed <- v3r_test_d0f_mixed_fixture(binding)
  root <- tempfile("v3r-d0f-expected-")
  dir.create(root)
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  on.exit(unlink(root, recursive = TRUE), add = TRUE)
  boot <- v3r_test_d0f_bootstrap_sha(root, mixed$bootstrap)
  state <- list(
    root = root, stage = "d0f", manifest = mixed$manifest, binding = binding
  )

  official <- v3r_new_admitted_evidence(mixed$attempts, "official", "d0f")
  expect_identical(
    v3r_expected_summary(state, official),
    v3p_d0f_summary(
      mixed$manifest, mixed$attempts, mixed$bootstrap, boot$sha256, binding
    )
  )

  julia_attempts <- v3r_test_as_julia(mixed$attempts, binding)
  julia <- v3r_new_admitted_evidence(julia_attempts, "julia", "d0f")
  expect_identical(
    v3r_expected_summary(state, julia),
    v3p_d0f_julia_summary(
      mixed$manifest, julia_attempts, mixed$bootstrap, boot$sha256, binding
    )
  )
})

test_that("D0F boundary tallies are position- and route-invariant with 576 lineage", {
  binding <- v3r_test_route_binding()
  tail_fixture <- v3r_test_d0f_mixed_fixture(binding, layout = "tail")
  head_fixture <- v3r_test_d0f_mixed_fixture(binding, layout = "head")
  root <- tempfile("v3r-d0f-tally-")
  dir.create(root)
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  on.exit(unlink(root, recursive = TRUE), add = TRUE)
  boot <- v3r_test_d0f_bootstrap_sha(root, tail_fixture$bootstrap)

  tail_summary <- v3p_d0f_summary(
    tail_fixture$manifest, tail_fixture$attempts, tail_fixture$bootstrap,
    boot$sha256, binding
  )
  head_summary <- v3p_d0f_summary(
    head_fixture$manifest, head_fixture$attempts, head_fixture$bootstrap,
    boot$sha256, binding
  )
  tally_cols <- c(
    "n_converged", "n_interior", "n_interior_rescued", "n_boundary_lower",
    "n_boundary_upper", "n_unresolved", "n_error", "n_attempted"
  )
  # Tallies are pure per-design count aggregates: invariant to whether the
  # boundary arms sit at the head or tail of each canonically-ordered design.
  expect_identical(head_summary[tally_cols], tail_summary[tally_cols])
  # The two layouts are genuinely distinct fixtures (per-panel variance moves).
  expect_false(isTRUE(all.equal(
    head_summary$variance_within, tail_summary$variance_within
  )))

  julia_attempts <- v3r_test_as_julia(tail_fixture$attempts, binding)
  julia_summary <- v3p_d0f_julia_summary(
    tail_fixture$manifest, julia_attempts, tail_fixture$bootstrap,
    boot$sha256, binding
  )
  expect_identical(julia_summary[tally_cols], tail_summary[tally_cols])

  ordinary <- tail_fixture$attempts
  admitted <- list(
    official = v3r_new_admitted_evidence(ordinary, "official", "d0f"),
    base_r = v3r_new_admitted_evidence(ordinary, "base_r", "d0f"),
    julia = v3r_new_admitted_evidence(julia_attempts, "julia", "d0f")
  )
  lineage_state <- list(
    stage = "d0f", manifest = tail_fixture$manifest,
    corpus = list(sha256 = v3r_test_hash("c"))
  )
  evidence <- list(
    base_r_inventory_sha256 = v3r_test_hash("d"),
    julia_replay_inventory_sha256 = v3r_test_hash("e")
  )
  lineage <- v3r_expected_route_lineage(
    lineage_state, evidence, list(admitted = admitted)
  )
  expect_equal(nrow(lineage), 9L)
  expect_equal(
    as.integer(tapply(
      lineage$source_attempt_count, lineage$evidence_kind, sum
    )),
    rep(576L, 3L)
  )
})

test_that("D0F summary booleans serialize lowercase and survive write/read/adjudicate", {
  binding <- v3r_test_route_binding()
  mixed <- v3r_test_d0f_mixed_fixture(binding)
  root <- tempfile("v3r-d0f-boolean-")
  dir.create(root)
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  on.exit(unlink(root, recursive = TRUE), add = TRUE)
  boot <- v3r_test_d0f_bootstrap_sha(root, mixed$bootstrap)

  summary <- v3p_d0f_summary(
    mixed$manifest, mixed$attempts, mixed$bootstrap, boot$sha256, binding
  )
  expect_false(any(v3p_bool(summary$fit_blocker, "fit_blocker")))

  summary_path <- file.path(root, "d0f_summary_r.tsv")
  v3r_write_once(summary_path, summary)
  txt <- readChar(summary_path, file.info(summary_path)$size, useBytes = TRUE)
  expect_true(grepl("\\tfalse", txt))
  expect_false(grepl("\\tFALSE|\\tTRUE", txt))

  reread <- v3r_read_tsv(summary_path, v3p_d0f_summary_columns)
  expect_identical(class(reread$fit_blocker), "character")
  # In-memory driver (logical) as the LEFT/driver arg is exactly the ordering
  # the operational adjudicator uses (v3r_adjudicate_tables passes the in-memory
  # driver first and the disk-read summaries second). Logical FALSE and on-disk
  # "false" compare EQUAL here, which is the campaign-relevant path.
  expect_silent(v3p_adjudicate_summaries(summary, reread, reread, "d0f"))

  # ARG-ORDER characterization (latent asymmetry, deliberately NOT fixed --
  # editing the sealed tool would invalidate the campaign root). v3p_compare_
  # tables detects logical fields from the LEFT arg only (preseal.R ~2479), so a
  # disk-read (all-character) table as the LEFT/driver arg treats fit_blocker as
  # character and "false" != as.character(FALSE) ("FALSE"). This ordering never
  # occurs in v3r_adjudicate_tables, so the campaign path is unaffected; the
  # test locks the current behaviour.
  expect_error(
    v3p_compare_tables(
      reread, summary, v3p_d0f_summary_columns, c("stage", "design_id")
    ),
    "summary mismatch in fit_blocker"
  )
})

test_that("exact adjudication receipt from a D0F fit-blocker summary is created once", {
  binding <- v3r_test_route_binding()
  mixed <- v3r_test_d0f_mixed_fixture(binding, all_converged = FALSE)
  root <- tempfile("v3r-d0f-receipt-")
  dir.create(root)
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  on.exit(unlink(root, recursive = TRUE), add = TRUE)
  boot <- v3r_test_d0f_bootstrap_sha(root, mixed$bootstrap)
  summary <- v3p_d0f_summary(
    mixed$manifest, mixed$attempts, mixed$bootstrap, boot$sha256, binding
  )

  state <- list(
    root = root, stage = "d0f",
    preseal = list(sha256 = v3r_test_hash("a"), value = v3r_test_preseal()),
    corpus = list(sha256 = v3r_test_hash("b"))
  )
  evidence <- list(
    base_r_inventory_sha256 = v3r_test_hash("c"),
    julia_replay_inventory_sha256 = v3r_test_hash("d"),
    r_summary_sha256 = v3r_test_hash("e"),
    julia_summary_sha256 = v3r_test_hash("f"),
    route_lineage_sha256 = v3r_test_hash("a")
  )
  reviews <- setNames(lapply(seq_along(v3p_reviewers), function(i) {
    reviewer <- v3p_reviewers[[i]]
    list(
      path = file.path(root, paste0(reviewer, ".tsv")),
      sha256 = v3r_test_hash(as.character(i + 1L))
    )
  }), v3p_reviewers)
  receipt <- v3r_receipt_row(state, evidence, reviews, summary, 0, 0)
  expect_identical(names(receipt), v3r_receipt_columns)
  expect_identical(receipt$stage, "d0f")
  expect_identical(receipt$stage_decision, "D0F_FIT_BLOCKER")

  exact_root <- tempfile("v3r-d0f-exact-")
  dir.create(exact_root)
  exact_root <- normalizePath(exact_root, winslash = "/", mustWork = TRUE)
  on.exit(unlink(exact_root, recursive = TRUE), add = TRUE)
  exact_path <- file.path(exact_root, "stage_adjudication_receipt.tsv")
  expect_identical(
    v3r_ensure_exact_adjudication_receipt(exact_path, receipt, exact_root),
    "created"
  )
  exact_bytes <- readBin(exact_path, "raw", file.info(exact_path)$size)
  exact_sidecar <- readBin(
    paste0(exact_path, ".sha256"), "raw",
    file.info(paste0(exact_path, ".sha256"))$size
  )
  expect_identical(
    v3r_ensure_exact_adjudication_receipt(exact_path, receipt, exact_root),
    "existing"
  )
  expect_identical(
    readBin(exact_path, "raw", file.info(exact_path)$size), exact_bytes
  )
  expect_identical(
    readBin(
      paste0(exact_path, ".sha256"), "raw",
      file.info(paste0(exact_path, ".sha256"))$size
    ),
    exact_sidecar
  )
})

test_that("admitted evidence rejects a forged route identity at D0F", {
  binding <- v3r_test_route_binding()
  mixed <- v3r_test_d0f_mixed_fixture(binding)
  expect_error(
    v3r_new_admitted_evidence(mixed$attempts, "julia", "d0f"),
    "route does not match"
  )
  julia_attempts <- v3r_test_as_julia(mixed$attempts, binding)
  expect_error(
    v3r_new_admitted_evidence(julia_attempts, "official", "d0f"),
    "route does not match"
  )
  admitted <- v3r_new_admitted_evidence(mixed$attempts, "official", "d0f")
  class(admitted) <- v3r_evidence_class("julia")
  expect_error(v3r_evidence_rows(admitted), "class/kind binding")
})
