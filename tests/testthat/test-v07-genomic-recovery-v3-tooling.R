seed_tool <- testthat::test_path(
  "..",
  "..",
  "tools",
  "v07_genomic_recovery_v3_seed_lock.R"
)
d0_tool <- testthat::test_path(
  "..",
  "..",
  "tools",
  "v07_genomic_recovery_v3_d0_recompute.R"
)
state_tool <- testthat::test_path(
  "..",
  "..",
  "tools",
  "v07_genomic_recovery_v3_state_machine.R"
)
testthat::skip_if_not(
  file.exists(seed_tool) && file.exists(d0_tool) && file.exists(state_tool),
  "repository-only recovery-v3 tools are unavailable in the built package"
)
source(normalizePath(seed_tool, mustWork = TRUE), local = TRUE)
source(normalizePath(d0_tool, mustWork = TRUE), local = TRUE)
source(normalizePath(state_tool, mustWork = TRUE), local = TRUE)

test_that("recovery-v3 exact seed spaces are exhaustive and disjoint", {
  lock <- v07s_read_lock(v07s_default_lock())
  spaces <- v07s_validate_spaces(lock)

  expect_equal(nrow(spaces$historical), 41488L)
  expect_equal(nrow(spaces$proposed), 92304L)
  expect_equal(nrow(spaces$retired_d0f), 2880L)
  expect_identical(
    unique(spaces$retired_d0f$stage),
    c(
      "D0F_RETIRED", "D0F_RETRY1_RETIRED", "D0F_RETRY2_RETIRED",
      "D0F_RETRY3_RETIRED", "D0F_RETRY4_RETIRED"
    )
  )
  expect_setequal(
    unique(spaces$proposed$stage),
    c("D0F_RETRY", "D1", "D2", "D3", "D4")
  )
  expect_contains(spaces$historical$seed, 2027142001)
  expect_contains(
    spaces$historical$seed,
    v07s_d0f_bootstrap_seeds(v07s_d0f_retired_bootstrap_base)
  )
  expect_contains(
    spaces$historical$seed,
    v07s_d0f_bootstrap_seeds(v07s_d0f_retired_retry_bootstrap_base)
  )
  expect_contains(
    spaces$historical$seed,
    v07s_d0f_bootstrap_seeds(v07s_d0f_retired_retry2_bootstrap_base)
  )
  expect_contains(
    spaces$historical$seed,
    v07s_d0f_bootstrap_seeds(v07s_d0f_retired_retry3_bootstrap_base)
  )
  expect_contains(
    spaces$historical$seed,
    v07s_d0f_bootstrap_seeds(v07s_d0f_retired_retry4_bootstrap_base)
  )
  expect_length(intersect(spaces$historical$seed, spaces$proposed$seed), 0L)
  expect_length(intersect(spaces$retired_d0f$seed, spaces$proposed$seed), 0L)

  expect_identical(
    spaces$retired_d0f$seed,
    c(
      v07s_d0f_seed_grid(
        v07s_d0f_retired_phenotype_base,
        "D0F_RETIRED"
      )$seed,
      v07s_d0f_seed_grid(
        v07s_d0f_retired_retry_phenotype_base,
        "D0F_RETRY1_RETIRED"
      )$seed,
      v07s_d0f_seed_grid(
        v07s_d0f_retired_retry2_phenotype_base,
        "D0F_RETRY2_RETIRED"
      )$seed,
      v07s_d0f_seed_grid(
        v07s_d0f_retired_retry3_phenotype_base,
        "D0F_RETRY3_RETIRED"
      )$seed,
      v07s_d0f_seed_grid(
        v07s_d0f_retired_retry4_phenotype_base,
        "D0F_RETRY4_RETIRED"
      )$seed
    )
  )
  retry <- spaces$proposed[spaces$proposed$stage == "D0F_RETRY", ]
  expect_identical(
    retry$seed,
    v07s_d0f_seed_grid(v07s_d0f_retry_phenotype_base, "D0F_RETRY")$seed
  )

  collision <- spaces$proposed
  collision$seed[[1L]] <- 2027142001
  expect_error(
    v07s_validate_spaces(lock, collision),
    "v3 seed intersects historical lock: 2027142001"
  )

  duplicate <- spaces$proposed
  duplicate$seed[[2L]] <- duplicate$seed[[1L]]
  expect_error(v07s_validate_spaces(lock, duplicate), "exact seed collision")

  retired_collision <- spaces$proposed
  retired_collision$seed[[1L]] <- spaces$retired_d0f$seed[[1L]]
  expect_error(
    v07s_validate_spaces(lock, retired_collision),
    "v3 seed intersects historical lock"
  )
  retired_bootstrap_collision <- spaces$proposed
  retired_bootstrap_collision$seed[[1L]] <-
    v07s_d0f_bootstrap_seeds(v07s_d0f_retired_bootstrap_base)[[1L]]
  expect_error(
    v07s_validate_spaces(lock, retired_bootstrap_collision),
    "v3 seed intersects historical lock"
  )
  retired_retry_bootstrap_collision <- spaces$proposed
  retired_retry_bootstrap_collision$seed[[1L]] <-
    v07s_d0f_bootstrap_seeds(
      v07s_d0f_retired_retry_bootstrap_base
    )[[1L]]
  expect_error(
    v07s_validate_spaces(lock, retired_retry_bootstrap_collision),
    "v3 seed intersects historical lock"
  )
  retired_retry2_bootstrap_collision <- spaces$proposed
  retired_retry2_bootstrap_collision$seed[[1L]] <-
    v07s_d0f_bootstrap_seeds(
      v07s_d0f_retired_retry2_bootstrap_base
    )[[1L]]
  expect_error(
    v07s_validate_spaces(lock, retired_retry2_bootstrap_collision),
    "v3 seed intersects historical lock"
  )
  retired_retry3_bootstrap_collision <- spaces$proposed
  retired_retry3_bootstrap_collision$seed[[1L]] <-
    v07s_d0f_bootstrap_seeds(
      v07s_d0f_retired_retry3_bootstrap_base
    )[[1L]]
  expect_error(
    v07s_validate_spaces(lock, retired_retry3_bootstrap_collision),
    "v3 seed intersects historical lock"
  )
  retired_retry4_bootstrap_collision <- spaces$proposed
  retired_retry4_bootstrap_collision$seed[[1L]] <-
    v07s_d0f_bootstrap_seeds(
      v07s_d0f_retired_retry4_bootstrap_base
    )[[1L]]
  expect_error(
    v07s_validate_spaces(lock, retired_retry4_bootstrap_collision),
    "v3 seed intersects historical lock"
  )
  wrong_stage <- spaces$proposed
  wrong_stage$stage[[1L]] <- "D0F"
  expect_error(
    v07s_validate_spaces(lock, wrong_stage),
    "stage names or exact denominators drift"
  )
  expect_error(
    v07s_d0f_seed_grid(.Machine$integer.max, "D0F_RETRY"),
    "unique in-range integers"
  )
  expect_error(
    v07s_d0f_bootstrap_seeds(.Machine$integer.max),
    "unique in-range integers"
  )
})

test_that("D0 Helmert, information, and bootstrap conventions are frozen", {
  C <- v07d_helmert(6L)
  expect_equal(crossprod(C), diag(5L), tolerance = 1e-14)
  expect_equal(
    as.numeric(crossprod(C, rep(1, 6L))),
    rep(0, 5L),
    tolerance = 1e-14
  )
  expect_equal(v07d_information(rep(1, 5L), 0.5)[["information"]], 0)
  expect_equal(v07d_information(rep(1, 5L), 0.5)[["se_info"]], Inf)

  set.seed(617L)
  rng_before <- .Random.seed
  kind_before <- RNGkind()
  bootstrap <- v07d_bootstrap_table(2L)
  expect_identical(.Random.seed, rng_before)
  expect_identical(RNGkind(), kind_before)
  expect_identical(names(bootstrap), v07d_bootstrap_columns)
  expect_equal(nrow(bootstrap), 18L)
  expect_identical(
    unname(as.integer(bootstrap[
      1L,
      c("index_01", "index_02", "index_47", "index_48")
    ])),
    c(16L, 17L, 3L, 23L)
  )
  expect_identical(
    unname(as.integer(bootstrap[
      2L,
      c("index_01", "index_02", "index_47", "index_48")
    ])),
    c(43L, 38L, 32L, 21L)
  )
  expect_identical(
    v07d_id_fingerprint(c("alpha", "id2")),
    "e91221fde844edffa91e7d4701b28ecbfe2176eacb2eb341d062597726e2c4dc"
  )
  numeric_matrix <- matrix(c(1, -2.5, -0, 0), nrow = 2)
  expect_identical(
    v07d_matrix_fingerprint("K_lambda", numeric_matrix, c("a", "b")),
    "2c21985923be46408dd7d1c9387a9faac9c167b75e677bd952dfef6e7fc7221e"
  )
  marker_hash <- v07d_marker_fingerprint(
    matrix(c(0, 2, 1, 1), nrow = 2),
    c("a", "b"),
    c("m000001", "m000002")
  )
  expect_match(marker_hash, "^[0-9a-f]{64}$")
  expect_false(identical(
    marker_hash,
    v07d_marker_fingerprint(
      matrix(c(2, 0, 1, 1), nrow = 2),
      c("a", "b"),
      c("m000001", "m000002")
    )
  ))

  bootstrap_root <- tempfile("v07d-bootstrap-mutation-")
  dir.create(bootstrap_root)
  bootstrap_root <- normalizePath(
    bootstrap_root,
    winslash = "/",
    mustWork = TRUE
  )
  on.exit(unlink(bootstrap_root, recursive = TRUE), add = TRUE)
  sealed_path <- file.path(bootstrap_root, "sealed.tsv")
  sealed_hash <- v07d_write_once(sealed_path, v07d_tsv_text(bootstrap))
  changed_bootstrap <- bootstrap
  changed_bootstrap$index_01[[1L]] <- if (
    changed_bootstrap$index_01[[1L]] == 48L
  ) {
    47L
  } else {
    changed_bootstrap$index_01[[1L]] + 1L
  }
  changed_path <- file.path(bootstrap_root, "changed.tsv")
  v07d_write_once(changed_path, v07d_tsv_text(changed_bootstrap))
  expect_error(
    v07d_read_bootstrap(changed_path, sealed_hash, reps = 2L),
    "frozen SHA-256 mismatch"
  )
})

test_that("D0 outputs are create-once and numerical mutations compare red", {
  root <- tempfile("v07d-test-")
  dir.create(root)
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  on.exit(unlink(root, recursive = TRUE), add = TRUE)

  path <- file.path(root, "once.tsv")
  digest <- v07d_write_once(path, "x\n")
  expect_match(digest, "^[0-9a-f]{64}$")
  expect_invisible(v07d_verify_pair(path))
  expect_error(v07d_write_once(path, "y\n"), "create-once output exists")

  left <- data.frame(
    cell_id = "fixture",
    seed = 1,
    eigen_index = 1,
    eigenvalue = 2
  )
  expect_invisible(v07d_compare_table(
    left,
    left,
    v07d_eigen_columns,
    c("seed", "eigen_index", "eigenvalue")
  ))
  changed <- left
  changed$eigenvalue <- 2.1
  expect_error(
    v07d_compare_table(
      left,
      changed,
      v07d_eigen_columns,
      c("seed", "eigen_index", "eigenvalue")
    ),
    "comparison mismatch in eigenvalue"
  )
  malformed <- left
  malformed$eigenvalue <- "garbage"
  missing <- left
  missing$eigenvalue <- NA_real_
  expect_error(
    v07d_compare_table(
      malformed,
      missing,
      v07d_eigen_columns,
      c("seed", "eigen_index", "eigenvalue")
    ),
    "nonnumeric field: eigenvalue"
  )
  native <- data.frame(
    cell_id = "fixture",
    seed = 1,
    marker_hash_base_r = v07d_sha256_raw(charToRaw("marker")),
    id_hash_base_r = v07d_sha256_raw(charToRaw("id")),
    kernel_hash_base_r = v07d_sha256_raw(charToRaw("kernel")),
    precision_hash_base_r = v07d_sha256_raw(charToRaw("precision")),
    stringsAsFactors = FALSE
  )
  native <- native[v07d_native_hash_columns]
  diagnostic <- data.frame(
    cell_id = native$cell_id,
    seed = native$seed,
    marker_hash = native$marker_hash_base_r,
    id_hash = native$id_hash_base_r,
    stringsAsFactors = FALSE
  )
  expect_invisible(v07d_validate_native_hashes(
    native,
    diagnostic,
    expected_rows = 1L
  ))
  invalid_native <- native
  invalid_native$kernel_hash_base_r <- "not-a-hash"
  expect_error(
    v07d_validate_native_hashes(
      invalid_native,
      diagnostic,
      expected_rows = 1L
    ),
    "membership or exact-hash drift"
  )

  separate <- tempfile("v07d-separate-")
  dir.create(separate)
  separate <- normalizePath(separate, winslash = "/", mustWork = TRUE)
  on.exit(unlink(separate, recursive = TRUE), add = TRUE)
  nested <- file.path(root, "nested")
  dir.create(nested)
  expect_invisible(v07d_require_separate_roots(root, separate))
  expect_error(
    v07d_require_separate_roots(root, root),
    "must be separate and non-nested"
  )
  expect_error(
    v07d_require_separate_roots(root, nested),
    "must be separate and non-nested"
  )
})

test_that("recovery-v3 adaptive admission state machine fails closed", {
  expect_invisible(v3_selftest())
})

test_that("D0 rejects files reached through a symlinked directory", {
  skip_if(.Platform$OS.type != "unix", "symlink mutation requires Unix")
  root <- tempfile("v07d-symlink-")
  dir.create(root)
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  on.exit(unlink(root, recursive = TRUE), add = TRUE)
  real <- file.path(root, "real")
  alias <- file.path(root, "alias")
  dir.create(real)
  v07d_write_once(file.path(real, "fixture.tsv"), "x\n")
  expect_true(file.symlink(real, alias))
  expect_error(
    v07d_verify_pair(file.path(alias, "fixture.tsv")),
    "missing, orphaned, or symlinked file pair"
  )
})

test_that("D0 exact-tree admission rejects special files and empty dirs", {
  skip_if(.Platform$OS.type != "unix", "special-file mutation requires Unix")
  skip_if(Sys.which("mkfifo") == "", "mkfifo is unavailable")
  root <- tempfile("v07d-tree-")
  dir.create(file.path(root, "a"), recursive = TRUE)
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  on.exit(unlink(root, recursive = TRUE), add = TRUE)
  expected <- c("a/x.tsv", "a/y.tsv")
  file.create(file.path(root, expected))
  expect_invisible(v07d_verify_tree_membership(root, expected, "fixture tree"))

  dir.create(file.path(root, "unexpected-empty"))
  expect_error(
    v07d_verify_tree_membership(root, expected, "fixture tree"),
    "missing or additional file/directory member"
  )
  unlink(file.path(root, "unexpected-empty"), recursive = TRUE)

  unlink(file.path(root, "a/x.tsv"))
  system2("mkfifo", file.path(root, "a/x.tsv"))
  expect_error(
    v07d_verify_tree_membership(root, expected, "fixture tree"),
    "non-regular file|missing or additional"
  )
})
