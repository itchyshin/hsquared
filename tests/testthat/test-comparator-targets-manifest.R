test_that("comparator target manifest indexes mirrored R fixtures (#49 coordination)", {
  manifest <- hs_read_comparator_manifest()
  expect_identical(manifest$schema_version, 1L)
  expect_identical(manifest$lane, "hsquared")
  expect_match(manifest$claim_boundary, "not add external comparator evidence", fixed = FALSE)

  targets <- manifest$target
  ids <- vapply(targets, `[[`, character(1), "id")
  expect_length(unique(ids), length(ids))
  expect_setequal(
    ids,
    c(
      "animal_model_fitted_target",
      "sire_model_fitted_target",
      "phase4_multitrait_parity",
      "genomic_gblup_snpblup_target",
      "marker_scan_parity",
      "structured_covariance_parity",
      "non_gaussian_parity"
    )
  )

  allowed_evidence <- c(
    "julia_target",
    "julia_target_r_consumed",
    "julia_target_external_one_leg",
    "bridge_payload_fixture"
  )

  pkg_root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)

  for (target in targets) {
    expect_true(length(target$capability_rows) > 0L)
    expect_true(target$evidence_type %in% allowed_evidence)
    expect_match(target$boundary, "no|not", ignore.case = TRUE)
    expect_true(nzchar(trimws(target$required_comparator)))

    if (isTRUE(target$r_mirror)) {
      fixture_dir <- file.path(pkg_root, target$r_fixture_path)
      expect_true(dir.exists(fixture_dir))
      for (file in target$required_files) {
        expect_true(file.exists(file.path(fixture_dir, file)))
      }
    } else {
      expect_false(target$r_mirror)
      expect_identical(target$r_fixture_path, "")
    }
  }

  sire <- targets[[match("sire_model_fitted_target", ids)]]
  expect_identical(sire$r_mirror, FALSE)
  expect_identical(sire$issue, 16L)

  multivariate <- targets[[match("phase4_multitrait_parity", ids)]]
  expect_match(multivariate$external_status, "sommer")
  expect_match(multivariate$boundary, "second independent")

  genomic <- targets[[match("genomic_gblup_snpblup_target", ids)]]
  expect_identical(genomic$evidence_type, "julia_target_r_consumed")
  expect_match(genomic$external_status, "PR #84")

  nongaussian <- targets[[match("non_gaussian_parity", ids)]]
  expect_match(nongaussian$boundary, "no per-record varying-trial R activation")
})

test_that("frozen comparator fixture SHA256 pins match mirrored CSV bytes", {
  pins <- utils::read.csv(
    hs_comparator_fixture_shas_path(),
    stringsAsFactors = FALSE
  )
  pkg_root <- normalizePath(testthat::test_path("..", ".."), mustWork = TRUE)
  manifest <- hs_read_comparator_manifest()
  mirrored_ids <- vapply(
    manifest$target,
    function(t) if (isTRUE(t$r_mirror)) t$id else NA_character_,
    character(1)
  )
  mirrored_ids <- mirrored_ids[!is.na(mirrored_ids)]

  for (id in mirrored_ids) {
    target <- manifest$target[[match(id, vapply(manifest$target, `[[`, "", "id"))]]
    fixture_dir <- file.path(pkg_root, target$r_fixture_path)
    rows <- pins[pins$target == id, , drop = FALSE]
    expect_true(nrow(rows) > 0L)
    for (i in seq_len(nrow(rows))) {
      path <- file.path(fixture_dir, rows$file[i])
      expect_true(file.exists(path))
      expect_identical(hs_sha256_file(path), rows$sha256[i])
    }
  }
})
