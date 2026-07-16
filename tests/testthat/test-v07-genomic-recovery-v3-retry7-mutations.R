recompute_tool <- testthat::test_path(
  "..", "..", "tools", "v07_genomic_recovery_v3_recompute.R"
)
testthat::skip_if_not(
  file.exists(recompute_tool),
  "repository-only recovery-v3 recomputer is unavailable"
)
source(normalizePath(recompute_tool, mustWork = TRUE), local = TRUE)

r7m_opt_in <- function() {
  testthat::skip_if_not(
    identical(Sys.getenv("HSQUARED_RUN_RETRY7_MUTATIONS"), "true"),
    "set HSQUARED_RUN_RETRY7_MUTATIONS=true for Retry-7 mutation controls"
  )
}

r7m_hash <- function(letter, n = 64L) {
  paste(rep(letter, n), collapse = "")
}

r7m_binding <- function() {
  list(
    preseal_sha256 = r7m_hash("e"),
    manifest_sha256 = r7m_hash("f"),
    corpus_lock_sha256 = r7m_hash("a"),
    r_auto_route_commit = r7m_hash("a", 40L),
    julia_candidate_commit = r7m_hash("b", 40L),
    r_driver_commit = r7m_hash("c", 40L),
    julia_replay_commit = r7m_hash("e", 40L),
    julia_replay_sha256 = r7m_hash("c")
  )
}

r7m_preseal_value <- function(binding = r7m_binding()) {
  c(
    binding,
    list(
      r_recomputer_commit = r7m_hash("d", 40L),
      r_driver_sha256 = r7m_hash("a"),
      r_recomputer_sha256 = r7m_hash("b")
    )
  )
}

r7m_write_pair <- function(path, value) {
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  v3r_write_once(path, value, temporary_parent = dirname(path))
  invisible(path)
}

r7m_tree_digest <- function(root) {
  paths <- list.files(
    root, recursive = TRUE, all.files = TRUE, full.names = TRUE,
    include.dirs = FALSE, no.. = TRUE
  )
  git_metadata <- paste0(normalizePath(root, winslash = "/", mustWork = TRUE), "/.git/")
  paths <- paths[!startsWith(paths, git_metadata)]
  paths <- sort(paths[file.exists(paths) & !isTRUE(file.info(paths)$isdir)])
  relative <- substring(paths, nchar(root) + 2L)
  inventory <- data.frame(
    relative_path = relative,
    sha256 = vapply(paths, v07d_sha256, character(1L)),
    stringsAsFactors = FALSE
  )
  v3r_hash_text(v07d_tsv_text(inventory))
}

r7m_route_fixture <- function(stage = "d0f") {
  binding <- r7m_binding()
  parity <- if (identical(stage, "d0f")) {
    v3p_d0f_summary_parity_fixture(binding)
  } else {
    v3p_d1_summary_parity_fixture(binding)
  }
  root <- tempfile(paste0("retry7-", stage, "-mutations-"))
  dir.create(root)
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  if (identical(stage, "d0f")) {
    r7m_write_pair(
      file.path(root, "d0f_bootstrap_indices.tsv"), parity$bootstrap
    )
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
    root = root, stage = stage, manifest = parity$manifest,
    binding = binding, corpus = list(sha256 = r7m_hash("d"))
  )
  evidence <- list(
    base_r_inventory_sha256 = r7m_hash("b"),
    julia_replay_inventory_sha256 = r7m_hash("c")
  )
  adjudication <- list(admitted = admitted)
  evidence$route_lineage <- v3r_expected_route_lineage(
    state, evidence, adjudication
  )
  list(
    root = root, state = state, evidence = evidence,
    adjudication = adjudication, parity = parity,
    ordinary = ordinary, julia = julia
  )
}

r7m_receipt_fixture <- function() {
  root <- tempfile("retry7-receipt-mutations-")
  dir.create(root)
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  binding <- r7m_binding()
  state <- list(
    root = root, stage = "d1",
    preseal = list(
      sha256 = binding$preseal_sha256,
      value = r7m_preseal_value(binding)
    ),
    corpus = list(sha256 = binding$corpus_lock_sha256)
  )
  evidence <- list(
    base_r_inventory_sha256 = r7m_hash("b"),
    julia_replay_inventory_sha256 = r7m_hash("c"),
    r_summary_sha256 = r7m_hash("d"),
    julia_summary_sha256 = r7m_hash("e"),
    route_lineage_sha256 = r7m_hash("f")
  )
  reviews <- setNames(lapply(seq_along(v3p_reviewers), function(i) {
    list(sha256 = r7m_hash(as.character(i + 1L)))
  }), v3p_reviewers)
  summary <- v3p_d1_summary_parity_fixture(binding)$summary
  receipt <- v3r_receipt_row(state, evidence, reviews, summary, 0, 0)
  list(
    root = root, state = state, evidence = evidence,
    reviews = reviews, summary = summary, receipt = receipt
  )
}

test_that("Retry-7 route admission fails at the envelope boundary without tree drift", {
  r7m_opt_in()
  fixture <- r7m_route_fixture("d0f")
  on.exit(unlink(fixture$root, recursive = TRUE), add = TRUE)
  before <- r7m_tree_digest(fixture$root)

  omitted <- fixture$julia
  omitted$route <- NULL
  expect_error(
    v3r_new_admitted_evidence(omitted, "julia", "d0f"),
    "requires a nonempty routed data frame",
    info = "earliest gate: route-specific smart constructor"
  )
  expect_identical(r7m_tree_digest(fixture$root), before)

  rebound <- fixture$julia
  rebound$route <- "ordinary_auto_genomic"
  expect_error(
    v3r_new_admitted_evidence(rebound, "julia", "d0f"),
    "route does not match",
    info = "earliest gate: route-specific smart constructor"
  )
  expect_identical(r7m_tree_digest(fixture$root), before)

  expect_error(
    v3r_expected_summary(fixture$state, fixture$julia),
    "requires admitted evidence",
    info = "earliest gate: summary accepts no raw data frame"
  )
  expect_identical(r7m_tree_digest(fixture$root), before)

  forged <- fixture$adjudication$admitted$julia
  class(forged) <- v3r_evidence_class("official")
  expect_error(
    v3r_evidence_rows(forged),
    "class/kind binding",
    info = "earliest gate: admitted-envelope integrity"
  )
  expect_identical(r7m_tree_digest(fixture$root), before)

  wrong_driver <- fixture$julia
  wrong_driver$driver_commit <- fixture$state$binding$r_driver_commit
  expect_error(
    v3r_expected_summary(
      fixture$state,
      v3r_new_admitted_evidence(wrong_driver, "julia", "d0f")
    ),
    "attempt provenance binding is invalid",
    info = "earliest gate: replay driver binding"
  )
  expect_identical(r7m_tree_digest(fixture$root), before)

  wrong_implementation <- fixture$julia
  wrong_implementation$r_implementation_commit <- r7m_hash("9", 40L)
  expect_error(
    v3r_expected_summary(
      fixture$state,
      v3r_new_admitted_evidence(wrong_implementation, "julia", "d0f")
    ),
    "attempt provenance binding is invalid",
    info = "earliest gate: replay implementation binding"
  )
  expect_identical(r7m_tree_digest(fixture$root), before)
})

test_that("Retry-7 weighted lineage rejects count, group, and inventory mutations", {
  r7m_opt_in()
  for (stage in c("d0f", "d1")) {
    fixture <- r7m_route_fixture(stage)
    on.exit(unlink(fixture$root, recursive = TRUE), add = TRUE)
    before <- r7m_tree_digest(fixture$root)
    expect_silent(v3r_validate_route_lineage(
      fixture$state, fixture$evidence, fixture$adjudication
    ))

    mutations <- list(
      count = function(x) {
        x$source_attempt_count[[1L]] <- x$source_attempt_count[[1L]] - 1L
        x
      },
      group = function(x) {
        x$group_id[[1L]] <- paste0(x$group_id[[1L]], "_forged")
        x
      },
      inventory = function(x) {
        x$source_inventory_sha256[[1L]] <- r7m_hash("9")
        x
      }
    )
    for (name in names(mutations)) {
      changed <- fixture$evidence
      changed$route_lineage <- mutations[[name]](
        fixture$evidence$route_lineage
      )
      expect_error(
        v3r_validate_route_lineage(
          fixture$state, changed, fixture$adjudication
        ),
        "differs from admitted evidence",
        info = paste("earliest gate: route-lineage", name)
      )
      expect_identical(
        r7m_tree_digest(fixture$root), before,
        info = paste("failed lineage", name, "left the tree unchanged")
      )
    }
  }
})

test_that("Retry-7 reviews cannot precede summaries or lineage", {
  r7m_opt_in()
  fixture <- r7m_route_fixture("d1")
  on.exit(unlink(fixture$root, recursive = TRUE), add = TRUE)
  receipt_path <- file.path(
    fixture$root, "postrun_receipts", "fisher.tsv"
  )
  before <- r7m_tree_digest(fixture$root)

  missing_summary <- fixture$parity$summary[0L, , drop = FALSE]
  expect_error(
    v3r_compare_summary_triplet(
      fixture$parity$summary, missing_summary,
      fixture$parity$summary, "d1"
    ),
    "shape/NA drift",
    info = "earliest gate: summaries precede review"
  )
  expect_false(file.exists(receipt_path))
  expect_identical(r7m_tree_digest(fixture$root), before)

  missing_lineage <- fixture$evidence
  missing_lineage$route_lineage <-
    fixture$evidence$route_lineage[0L, , drop = FALSE]
  expect_error(
    v3r_validate_route_lineage(
      fixture$state, missing_lineage, fixture$adjudication
    ),
    "differs from admitted evidence",
    info = "earliest gate: lineage precedes review"
  )
  expect_false(file.exists(receipt_path))
  expect_identical(r7m_tree_digest(fixture$root), before)
})

test_that("Retry-7 detects post-preseal byte mutation without further drift", {
  r7m_opt_in()
  root <- tempfile("retry7-post-preseal-mutation-")
  dir.create(root)
  root <- normalizePath(root, winslash = "/", mustWork = TRUE)
  on.exit(unlink(root, recursive = TRUE), add = TRUE)
  path <- file.path(root, "stage_preseal.tsv")
  r7m_write_pair(
    path,
    data.frame(key = "synthetic", value = "sealed", stringsAsFactors = FALSE)
  )
  writeLines("post-preseal mutation", path, useBytes = TRUE)
  mutated <- r7m_tree_digest(root)
  expect_error(
    v3r_verify_pair(path), "sidecar mismatch",
    info = "earliest gate: post-preseal primary SHA-256"
  )
  expect_false(file.exists(file.path(
    root, "stage_adjudication_receipt.tsv"
  )))
  expect_identical(r7m_tree_digest(root), mutated)
})

test_that("Retry-7 review admission rejects missing and BLOCKED receipts read-only", {
  r7m_opt_in()
  fixture <- r7m_receipt_fixture()
  on.exit(unlink(fixture$root, recursive = TRUE), add = TRUE)
  path <- v3r_review_path(fixture$root, "fisher")
  dir.create(dirname(path), recursive = TRUE)
  before <- r7m_tree_digest(fixture$root)
  expect_error(
    v3r_validate_review(
      path, "fisher", fixture$state, fixture$evidence,
      v3r_stage_decision(fixture$summary, "d1")
    ),
    "does not exist",
    info = "earliest gate: canonical review pair must exist"
  )
  expect_identical(r7m_tree_digest(fixture$root), before)

  blocked <- v3r_review_row(
    fixture$state, fixture$evidence, "fisher", "BLOCKED",
    v3r_stage_decision(fixture$summary, "d1"), "2026-07-16T12:00:00Z"
  )
  r7m_write_pair(path, blocked)
  before_blocked <- r7m_tree_digest(fixture$root)
  expect_error(
    v3r_validate_review(
      path, "fisher", fixture$state, fixture$evidence,
      v3r_stage_decision(fixture$summary, "d1")
    ),
    "not CLEAN",
    info = "earliest gate: CLEAN review verdict"
  )
  expect_identical(r7m_tree_digest(fixture$root), before_blocked)
})

test_that("Retry-7 adjudication key and exact-receipt retry fail closed", {
  r7m_opt_in()
  fixture <- r7m_receipt_fixture()
  on.exit(unlink(fixture$root, recursive = TRUE), add = TRUE)

  stale_key <- fixture$receipt
  stale_key$r_recomputer_sha256 <- r7m_hash("9")
  before <- r7m_tree_digest(fixture$root)
  expect_error(
    v3r_validate_receipt_row(stale_key, stale_key),
    "key is invalid",
    info = "earliest gate: adjudication key binds exact tool hash"
  )
  expect_identical(r7m_tree_digest(fixture$root), before)

  wrong_tool <- stale_key
  wrong_tool$adjudication_key_sha256 <- v3r_adjudication_key(wrong_tool)
  expect_error(
    v3r_validate_receipt_row(wrong_tool, fixture$receipt),
    "differs from the current exact evidence",
    info = "earliest gate: exact evidence binds tool hash after key validation"
  )
  expect_identical(r7m_tree_digest(fixture$root), before)

  path <- file.path(fixture$root, "stage_adjudication_receipt.tsv")
  expect_identical(
    v3r_ensure_exact_adjudication_receipt(
      path, fixture$receipt, fixture$root
    ),
    "created"
  )
  exact_digest <- r7m_tree_digest(fixture$root)
  expect_identical(
    v3r_ensure_exact_adjudication_receipt(
      path, fixture$receipt, fixture$root
    ),
    "existing"
  )
  expect_identical(
    r7m_tree_digest(fixture$root), exact_digest,
    info = "byte-identical receipt retry is read-only"
  )

  noncanonical_root <- tempfile("retry7-noncanonical-receipt-")
  dir.create(noncanonical_root)
  noncanonical_root <- normalizePath(
    noncanonical_root, winslash = "/", mustWork = TRUE
  )
  on.exit(unlink(noncanonical_root, recursive = TRUE), add = TRUE)
  noncanonical_path <- file.path(
    noncanonical_root, "stage_adjudication_receipt.tsv"
  )
  noncanonical_bytes <- charToRaw(enc2utf8(paste0(
    v07d_tsv_text(fixture$receipt), "\n"
  )))
  writeBin(noncanonical_bytes, noncanonical_path)
  noncanonical_hash <- v07d_sha256(noncanonical_path)
  writeBin(
    charToRaw(sprintf(
      "%s  %s\n", noncanonical_hash, basename(noncanonical_path)
    )),
    paste0(noncanonical_path, ".sha256")
  )
  noncanonical_digest <- r7m_tree_digest(noncanonical_root)
  expect_error(
    v3r_ensure_exact_adjudication_receipt(
      noncanonical_path, fixture$receipt, noncanonical_root
    ),
    "primary is not byte-identical",
    info = "earliest gate: parse-equivalent receipt bytes"
  )
  expect_identical(
    r7m_tree_digest(noncanonical_root), noncanonical_digest
  )

  sidecar_root <- tempfile("retry7-noncanonical-sidecar-")
  dir.create(sidecar_root)
  sidecar_root <- normalizePath(
    sidecar_root, winslash = "/", mustWork = TRUE
  )
  on.exit(unlink(sidecar_root, recursive = TRUE), add = TRUE)
  sidecar_path <- file.path(
    sidecar_root, "stage_adjudication_receipt.tsv"
  )
  r7m_write_pair(sidecar_path, fixture$receipt)
  sidecar_text <- readLines(paste0(sidecar_path, ".sha256"), warn = FALSE)
  writeBin(
    charToRaw(sidecar_text), paste0(sidecar_path, ".sha256")
  )
  sidecar_digest <- r7m_tree_digest(sidecar_root)
  expect_error(
    v3r_ensure_exact_adjudication_receipt(
      sidecar_path, fixture$receipt, sidecar_root
    ),
    "sidecar is not byte-identical",
    info = "earliest gate: parse-equivalent sidecar bytes"
  )
  expect_identical(r7m_tree_digest(sidecar_root), sidecar_digest)

  conflicting <- fixture$receipt
  conflicting$route_lineage_sha256 <- r7m_hash("9")
  conflicting$adjudication_key_sha256 <- v3r_adjudication_key(conflicting)
  expect_error(
    v3r_ensure_exact_adjudication_receipt(
      path, conflicting, fixture$root
    ),
    "differs from the current exact evidence",
    info = "earliest gate: conflicting complete receipt pair"
  )
  expect_identical(r7m_tree_digest(fixture$root), exact_digest)

  stale_root <- tempfile("retry7-stale-receipt-")
  dir.create(stale_root)
  stale_root <- normalizePath(stale_root, winslash = "/", mustWork = TRUE)
  on.exit(unlink(stale_root, recursive = TRUE), add = TRUE)
  stale_path <- file.path(stale_root, "stage_adjudication_receipt.tsv")
  r7m_write_pair(stale_path, fixture$receipt)
  writeLines("stale", stale_path, useBytes = TRUE)
  stale_digest <- r7m_tree_digest(stale_root)
  expect_error(
    v3r_ensure_exact_adjudication_receipt(
      stale_path, fixture$receipt, stale_root
    ),
    "sidecar mismatch",
    info = "earliest gate: stale primary/sidecar pair"
  )
  expect_identical(r7m_tree_digest(stale_root), stale_digest)

  orphan_root <- tempfile("retry7-orphan-receipt-")
  dir.create(orphan_root)
  orphan_root <- normalizePath(orphan_root, winslash = "/", mustWork = TRUE)
  on.exit(unlink(orphan_root, recursive = TRUE), add = TRUE)
  orphan_path <- file.path(orphan_root, "stage_adjudication_receipt.tsv")
  r7m_write_pair(orphan_path, fixture$receipt)
  unlink(paste0(orphan_path, ".sha256"))
  orphan_digest <- r7m_tree_digest(orphan_root)
  expect_error(
    v3r_ensure_exact_adjudication_receipt(
      orphan_path, fixture$receipt, orphan_root
    ),
    "orphaned",
    info = "earliest gate: orphaned receipt pair"
  )
  expect_identical(r7m_tree_digest(orphan_root), orphan_digest)
})

test_that("Retry-7 duplicate exact-receipt writers converge to one exact pair", {
  r7m_opt_in()
  skip_if(.Platform$OS.type != "unix", "forked writer race requires Unix")
  fixture <- r7m_receipt_fixture()
  on.exit(unlink(fixture$root, recursive = TRUE), add = TRUE)
  path <- file.path(fixture$root, "stage_adjudication_receipt.tsv")
  jobs <- lapply(seq_len(2L), function(i) {
    parallel::mcparallel(try(
      v3r_ensure_exact_adjudication_receipt(
        path, fixture$receipt, fixture$root
      ),
      silent = TRUE
    ))
  })
  results <- parallel::mccollect(jobs)
  values <- unname(unlist(lapply(results, function(x) {
    if (inherits(x, "try-error")) "failed-exclusive-claim" else x
  })))
  expect_true("created" %in% values)
  expect_true(all(values %in% c(
    "created", "existing", "failed-exclusive-claim"
  )))
  observed <- v3r_read_tsv(path, v3r_receipt_columns, all_character = TRUE)
  expect_silent(v3r_validate_receipt_row(observed, fixture$receipt))
  stable <- r7m_tree_digest(fixture$root)
  expect_identical(
    v3r_ensure_exact_adjudication_receipt(
      path, fixture$receipt, fixture$root
    ),
    "existing"
  )
  expect_identical(r7m_tree_digest(fixture$root), stable)
})

test_that("Retry-7 regenerated summary and review-tree mutations fail read-only", {
  r7m_opt_in()
  fixture <- r7m_route_fixture("d1")
  on.exit(unlink(fixture$root, recursive = TRUE), add = TRUE)
  driver <- fixture$parity$summary
  changed <- driver
  changed$mean_estimate[[1L]] <- changed$mean_estimate[[1L]] + 1e-4
  r_path <- file.path(fixture$root, "d1_summary_r.tsv")
  j_path <- file.path(fixture$root, "d1_summary_julia.tsv")
  r7m_write_pair(r_path, driver)
  r7m_write_pair(j_path, changed)
  mutated <- r7m_tree_digest(fixture$root)
  expect_error(
    v3p_adjudicate_summaries(driver, changed, driver, "d1"),
    "summary mismatch",
    info = "earliest gate: regenerated-sidecar summary parity"
  )
  expect_identical(r7m_tree_digest(fixture$root), mutated)
  expect_false(file.exists(file.path(
    fixture$root, "stage_adjudication_receipt.tsv"
  )))

  review_fixture <- r7m_receipt_fixture()
  on.exit(unlink(review_fixture$root, recursive = TRUE), add = TRUE)
  row <- v3r_review_row(
    review_fixture$state, review_fixture$evidence, "fisher", "CLEAN",
    v3r_stage_decision(review_fixture$summary, "d1"),
    "2026-07-16T12:00:00Z"
  )
  relocated <- file.path(review_fixture$root, "relocated", "fisher.tsv")
  r7m_write_pair(relocated, row)
  relocated_digest <- r7m_tree_digest(review_fixture$root)
  expect_error(
    v3r_validate_review(
      relocated, "fisher", review_fixture$state,
      review_fixture$evidence, "ELIGIBLE=12"
    ),
    "relocated",
    info = "earliest gate: canonical review location"
  )
  expect_identical(r7m_tree_digest(review_fixture$root), relocated_digest)

  canonical <- v3r_review_path(review_fixture$root, "fisher")
  r7m_write_pair(canonical, row)
  unlink(paste0(canonical, ".sha256"))
  orphan_digest <- r7m_tree_digest(review_fixture$root)
  expect_error(
    v3r_validate_review(
      canonical, "fisher", review_fixture$state,
      review_fixture$evidence, "ELIGIBLE=12"
    ),
    "missing, orphaned",
    info = "earliest gate: orphaned review pair"
  )
  expect_identical(r7m_tree_digest(review_fixture$root), orphan_digest)
})

test_that("Retry-7 duplicate review writers leave one canonical pair", {
  r7m_opt_in()
  skip_if(.Platform$OS.type != "unix", "forked writer race requires Unix")
  fixture <- r7m_receipt_fixture()
  on.exit(unlink(fixture$root, recursive = TRUE), add = TRUE)
  path <- v3r_review_path(fixture$root, "fisher")
  row <- v3r_review_row(
    fixture$state, fixture$evidence, "fisher", "CLEAN",
    v3r_stage_decision(fixture$summary, "d1"),
    "2026-07-16T12:00:00Z"
  )
  jobs <- lapply(seq_len(2L), function(i) {
    parallel::mcparallel(try(
      v3r_write_once(path, row, temporary_parent = fixture$root),
      silent = TRUE
    ))
  })
  results <- parallel::mccollect(jobs)
  expect_equal(sum(!vapply(results, inherits, logical(1L), "try-error")), 1L)
  expect_silent(v3r_validate_review(
    path, "fisher", fixture$state, fixture$evidence, "ELIGIBLE=12"
  ))
  stable <- r7m_tree_digest(fixture$root)
  expect_silent(v3r_validate_review(
    path, "fisher", fixture$state, fixture$evidence, "ELIGIBLE=12"
  ))
  expect_identical(r7m_tree_digest(fixture$root), stable)
})

test_that("Retry-7 predecessor, dirty deploy, and RNG controls fail closed", {
  r7m_opt_in()
  predecessor <- tempfile("retry7-unadjudicated-d0f-")
  dir.create(predecessor)
  predecessor <- normalizePath(predecessor, winslash = "/", mustWork = TRUE)
  on.exit(unlink(predecessor, recursive = TRUE), add = TRUE)
  d1 <- file.path(predecessor, "nested-d1")
  dir.create(d1)
  expect_error(
    v3p_validate_successful_d0f_adjudication(predecessor, d1_root = d1),
    "distinct and nonnested",
    info = "earliest gate: nested D0F predecessor"
  )
  sibling <- tempfile("retry7-d1-")
  dir.create(sibling)
  sibling <- normalizePath(sibling, winslash = "/", mustWork = TRUE)
  on.exit(unlink(sibling, recursive = TRUE), add = TRUE)
  predecessor_digest <- r7m_tree_digest(predecessor)
  expect_error(
    v3p_validate_successful_d0f_adjudication(
      predecessor, d1_root = sibling
    ),
    "receipt primary is missing",
    info = "earliest gate: unadjudicated D0F predecessor"
  )
  expect_identical(r7m_tree_digest(predecessor), predecessor_digest)

  git_root <- tempfile("retry7-dirty-deploy-")
  dir.create(git_root)
  git_root <- normalizePath(git_root, winslash = "/", mustWork = TRUE)
  on.exit(unlink(git_root, recursive = TRUE), add = TRUE)
  system2("git", c("-C", shQuote(git_root), "init", "--quiet"))
  system2("git", c(
    "-C", shQuote(git_root), "config", "user.email", "retry7@example.invalid"
  ))
  system2("git", c(
    "-C", shQuote(git_root), "config", "user.name", "Retry 7"
  ))
  writeLines("clean", file.path(git_root, "tracked.txt"))
  system2("git", c("-C", shQuote(git_root), "add", "tracked.txt"))
  system2("git", c(
    "-C", shQuote(git_root), "commit", "--quiet", "-m", "baseline"
  ))
  writeLines("dirty", file.path(git_root, "tracked.txt"))
  dirty_digest <- r7m_tree_digest(git_root)
  expect_error(
    v3p_git_clean(git_root), "worktree is dirty",
    info = "earliest gate: clean deployment"
  )
  expect_identical(r7m_tree_digest(git_root), dirty_digest)

  had_seed <- exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  old_seed <- if (had_seed) get(".Random.seed", envir = .GlobalEnv) else NULL
  old_kind <- RNGkind()
  on.exit({
    do.call(RNGkind, as.list(old_kind))
    if (had_seed) {
      assign(".Random.seed", old_seed, envir = .GlobalEnv)
    } else if (exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)) {
      rm(".Random.seed", envir = .GlobalEnv)
    }
  }, add = TRUE)
  set.seed(707L)
  before_seed <- get(".Random.seed", envir = .GlobalEnv)
  invisible(v3p_d0f_bootstrap_manifest(1L))
  expect_identical(
    get(".Random.seed", envir = .GlobalEnv), before_seed,
    info = "bootstrap construction preserves the preseal RNG state"
  )
})
