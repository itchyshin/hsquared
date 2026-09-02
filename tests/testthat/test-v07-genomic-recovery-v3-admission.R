admission_tool <- testthat::test_path(
  "..", "..", "tools", "v07_genomic_recovery_v3_admission.R"
)
testthat::skip_if_not(
  file.exists(admission_tool),
  "repository-only recovery-v3 adaptive admission tool is unavailable"
)
source(normalizePath(admission_tool, mustWork = TRUE), local = TRUE)
v3a_load_contract()

v3a_test_path <- function(prefix) {
  raw <- tempfile(prefix)
  file.path(normalizePath(dirname(raw), winslash = "/"), basename(raw))
}

v3a_test_fixture <- function(root) {
  dir.create(root, recursive = TRUE)
  cells <- v3a_contract$v3_cell_table[
    v3a_contract$v3_cell_table$truth_ratio == 0.5, , drop = FALSE
  ]
  rows <- do.call(rbind, lapply(seq_len(nrow(cells)), function(i) {
    x <- as.data.frame(setNames(
      replicate(
        length(v3a_contract$v3p_d1_summary_columns),
        rep(NA_character_, 3L), simplify = FALSE
      ),
      v3a_contract$v3p_d1_summary_columns
    ), stringsAsFactors = FALSE)
    x$stage <- "d1"
    x$cell_id <- cells$cell_id[[i]]
    x$cell_index <- cells$cell_index[[i]]
    x$n <- cells$n[[i]]
    x$m <- cells$m[[i]]
    x$marker_ratio <- cells$marker_ratio[[i]]
    x$truth_ratio <- 0.5
    x$target <- c("sigma_g2", "sigma_e2", "ratio")
    x$required_n <- 200L
    x$cell_eligible <- TRUE
    x$cell_status <- "ELIGIBLE"
    x
  }))
  summary_path <- file.path(root, "d1_summary_r.tsv")
  summary_hash <- v3a_write_once(root, basename(summary_path), rows)
  receipt <- data.frame(
    schema_version = "v07-genomic-recovery-v3-adjudication-2",
    stage = "d1", verdict = "PASS", stage_decision = "ELIGIBLE=12",
    r_summary_sha256 = summary_hash,
    route_lineage_sha256 = paste(rep("a", 64L), collapse = ""),
    adjudication_key_sha256 = paste(rep("b", 64L), collapse = ""),
    stringsAsFactors = FALSE
  )
  receipt_path <- file.path(root, "stage_adjudication_receipt.tsv")
  v3a_write_once(root, basename(receipt_path), receipt)
  list(
    root = root, summary = rows, summary_path = summary_path,
    receipt = receipt, receipt_path = receipt_path
  )
}

v3a_test_replace_pair <- function(path, value) {
  unlink(c(path, paste0(path, ".sha256")))
  v3a_write_once(dirname(path), basename(path), value)
}

test_that("canonical D1 summary alone determines the first D2 manifest", {
  fixture <- v3a_test_fixture(v3a_test_path("v3a-d1-"))
  d1 <- v3a_read_d1_final(fixture$root)
  empty_d2 <- data.frame(
    stage = character(), cell_id = character(), eligible = logical(),
    required_n = integer()
  )
  cells <- v3a_contract$v3_d2_next_cells(d1$decisions, empty_d2)
  manifest <- v3a_contract$v3_manifest("d2", cells)

  expect_equal(nrow(d1$decisions), 12L)
  expect_true(all(d1$decisions$eligible))
  expect_equal(length(unique(manifest$cell_id)), 10L)
  expect_equal(nrow(manifest), 480L)
  expect_length(
    intersect(manifest$seed, v3a_contract$v3_d1_manifest()$seed), 0L
  )
})

test_that("artifact writing cannot bypass exact D1 final-tree validation", {
  fixture <- v3a_test_fixture(v3a_test_path("v3a-invalid-final-"))
  out <- v3a_test_path("v3a-out-")
  dir.create(out)
  expect_error(
    v3a_prepare(out, "d2", fixture$root, function(...) NULL),
    "unused argument"
  )
  expect_error(
    assign("v3a_validate_final", function(...) NULL, envir = environment(v3a_prepare)),
    "locked binding"
  )
  expect_error(
    assign("v3a_contract", new.env(), envir = environment(v3a_prepare)),
    "locked binding"
  )
  expect_true(environmentIsLocked(v3a_contract))
  expect_error(
    assign("v3_d2_next_cells", function(...) NULL, envir = v3a_contract),
    "locked binding"
  )
  for (name in c(
    "v3a_load_contract", "v3a_d1_decisions", "v3a_write_once",
    "v3a_real_dir", "v3a_nested", "v3a_sha256", "v3a_prepare"
  )) {
    expect_true(bindingIsLocked(name, environment(v3a_prepare)), info = name)
  }
  expect_error(
    v3a_prepare(out, "d2", fixture$root),
    "D1 final-tree validation failed"
  )
  expect_length(list.files(out, all.files = TRUE, no.. = TRUE), 0L)
})

test_that("ambient base-name shadows cannot poison the locked module", {
  target <- v3a_test_path("v3a-shadow-hash-")
  writeLines("canonical bytes", target, useBytes = TRUE)
  forged <- paste(rep("a", 64L), collapse = "")
  had_system2 <- exists("system2", envir = .GlobalEnv, inherits = FALSE)
  if (had_system2) old_system2 <- get("system2", envir = .GlobalEnv)
  on.exit({
    if (had_system2) {
      assign("system2", old_system2, envir = .GlobalEnv)
    } else if (exists("system2", envir = .GlobalEnv, inherits = FALSE)) {
      rm("system2", envir = .GlobalEnv)
    }
  }, add = TRUE)
  assign("system2", function(...) forged, envir = .GlobalEnv)

  expect_false(identical(v3a_sha256(target), forged))
  expect_identical(parent.env(environment(v3a_sha256)), baseenv())
})

test_that("a caller-authored source function cannot poison contract loading", {
  helper <- v3a_test_path("v3a-shadow-source-")
  tool <- normalizePath(admission_tool, winslash = "/", mustWork = TRUE)
  writeLines(c(
    paste0(
      "source <- function(file, local, ...) { ",
      "assign('v3p_d1_summary_columns', 'CALLER_AUTHORED', envir = local); ",
      "invisible(NULL) }"
    ),
    "c <- function(...) stop('caller-authored c() was invoked')",
    "module <- new.env(parent = globalenv())",
    sprintf("base::source(%s, local = module)", dQuote(tool)),
    paste0(
      "stopifnot(!identical(module$v3a_contract$v3p_d1_summary_columns, ",
      "'CALLER_AUTHORED'))"
    )
  ), helper, useBytes = TRUE)
  out <- system2(
    file.path(R.home("bin"), "Rscript"),
    c("--vanilla", shQuote(helper)), stdout = TRUE, stderr = TRUE
  )
  expect_null(attr(out, "status"), info = paste(out, collapse = "\n"))
})

test_that("adaptive planning fails closed without canonical D2 numerics", {
  fixture <- v3a_test_fixture(v3a_test_path("v3a-blocked-"))
  expect_error(
    v3a_prepare(tempdir(), "d3", fixture$root),
    "D3/D4 remain blocked"
  )
  expect_error(
    v3a_prepare(tempdir(), "d4", fixture$root),
    "D3/D4 remain blocked"
  )
})

test_that("summary and receipt mutations stop canonical decision derivation", {
  fixture <- v3a_test_fixture(v3a_test_path("v3a-mutation-"))

  writeLines("mutation", fixture$summary_path)
  expect_error(v3a_read_d1_final(fixture$root), "sidecar mismatch")

  v3a_test_replace_pair(fixture$summary_path, fixture$summary)
  changed_receipt <- fixture$receipt
  changed_receipt$stage_decision <- "ELIGIBLE=999"
  v3a_test_replace_pair(fixture$receipt_path, changed_receipt)
  expect_error(v3a_read_d1_final(fixture$root), "stage decision differs")

  changed <- fixture$summary
  changed$cell_eligible[changed$cell_id == changed$cell_id[[1L]]] <- FALSE
  changed_hash <- v3a_test_replace_pair(fixture$summary_path, changed)
  changed_receipt <- fixture$receipt
  changed_receipt$r_summary_sha256 <- changed_hash
  v3a_test_replace_pair(fixture$receipt_path, changed_receipt)
  expect_error(v3a_read_d1_final(fixture$root), "eligibility and cell status")

  changed$cell_status[changed$cell_id == changed$cell_id[[1L]]] <- "ALIEN"
  changed_hash <- v3a_test_replace_pair(fixture$summary_path, changed)
  changed_receipt$r_summary_sha256 <- changed_hash
  changed_receipt$stage_decision <- "ALIEN=1;ELIGIBLE=11"
  v3a_test_replace_pair(fixture$receipt_path, changed_receipt)
  expect_error(v3a_read_d1_final(fixture$root), "unknown cell status")
})

test_that("sidecars bind both the digest and canonical basename", {
  fixture <- v3a_test_fixture(v3a_test_path("v3a-sidecar-"))
  sidecar <- paste0(fixture$summary_path, ".sha256")
  digest <- v3a_sha256(fixture$summary_path)
  writeLines(paste(digest, "wrong-name.tsv"), sidecar)
  expect_error(v3a_read_d1_final(fixture$root), "sidecar mismatch")
  writeLines(paste0(digest, "   ", basename(fixture$summary_path)), sidecar)
  expect_error(v3a_read_d1_final(fixture$root), "sidecar mismatch")
})

test_that("adaptive roots are real, empty, distinct, and nonnested", {
  fixture <- v3a_test_fixture(v3a_test_path("v3a-paths-"))
  nested <- file.path(fixture$root, "attempts")
  dir.create(nested)
  expect_error(
    v3a_prepare(nested, "d2", fixture$root),
    "distinct and nonnested"
  )

  nonempty <- v3a_test_path("v3a-nonempty-")
  dir.create(nonempty)
  writeLines("unexpected", file.path(nonempty, "member"))
  expect_error(
    v3a_prepare(nonempty, "d2", fixture$root),
    "must be empty"
  )

  target <- v3a_test_path("v3a-real-")
  alias <- v3a_test_path("v3a-alias-")
  dir.create(target)
  testthat::skip_if_not(file.symlink(target, alias), "symlinks unavailable")
  expect_error(
    v3a_prepare(alias, "d2", fixture$root),
    "existing real directory"
  )
})

test_that("exclusive create-once output is canonical and never overwritten", {
  root <- v3a_test_path("v3a-once-")
  dir.create(root)
  object <- data.frame(key = "schema", value = "test")
  digest <- v3a_write_once(root, "member.tsv", object)
  path <- file.path(root, "member.tsv")
  original <- readBin(path, "raw", n = file.info(path)$size)

  expect_identical(length(readLines(path, warn = FALSE)), 2L)
  expect_error(v3a_write_once(root, "member.tsv", object), "already exists")
  expect_identical(readBin(path, "raw", n = file.info(path)$size), original)
  expect_identical(v3a_verify_pair(path), digest)
  expect_silent(v3a_selftest())

  claim_root <- v3a_test_path("v3a-claim-")
  dir.create(claim_root)
  claim <- v3a_claim_empty_root(claim_root)
  expect_true(file.exists(claim))
  expect_error(v3a_claim_empty_root(claim_root), "must be empty")
  unlink(claim)
})

test_that("concurrent create-once writers produce exactly one valid pair", {
  testthat::skip_on_os("windows")
  root <- v3a_test_path("v3a-race-")
  dir.create(root)
  object <- data.frame(key = "schema", value = "race")
  results <- parallel::mclapply(
    1:2,
    function(i) try(v3a_write_once(root, "member.tsv", object), silent = TRUE),
    mc.cores = 2L
  )
  winners <- vapply(results, v3a_hex64, logical(1L))
  expect_identical(sum(winners), 1L)
  expect_identical(
    v3a_verify_pair(file.path(root, "member.tsv")), results[[which(winners)]]
  )
})
