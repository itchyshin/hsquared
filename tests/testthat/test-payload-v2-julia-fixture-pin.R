# Parity pin: the R payload-v2 emitter must reproduce the Julia engine's
# checked-in payload_v2 fixtures byte for byte (parity cell 36).
# Pure R; reads the sibling HSquared.jl checkout read-only.

test_that("emit_payload_v2_fixtures.R output matches HSquared.jl payload_v2 JSON", {
  skip_on_cran()
  emitter <- testthat::test_path("..", "fixtures", "emit_payload_v2_fixtures.R")
  root <- normalizePath(
    file.path(dirname(emitter), "..", ".."),
    mustWork = FALSE
  )
  skip_if_not(
    file.exists(emitter) && file.exists(file.path(root, "DESCRIPTION")),
    "Source checkout (emitter script + DESCRIPTION) required."
  )
  fx <- c("test", "fixtures", "payload_v2")
  candidates <- c(
    Sys.getenv("HSQUARED_JL_PAYLOAD_V2_DIR", NA_character_),
    do.call(file.path, as.list(c(root, "..", "HSquared.jl", fx))),
    do.call(
      file.path,
      as.list(c(path.expand("~/Dropbox/Github Local/HSquared.jl"), fx))
    )
  )
  candidates <- candidates[!is.na(candidates) & dir.exists(candidates)]
  skip_if_not(
    length(candidates) > 0L,
    "Sibling HSquared.jl checkout with payload_v2 fixtures required."
  )
  jl_dir <- candidates[[1L]]

  out_dir <- withr::local_tempdir()
  status <- system2(
    file.path(R.home("bin"), "Rscript"),
    c(shQuote(normalizePath(emitter)), shQuote(out_dir)),
    stdout = FALSE,
    stderr = FALSE
  )
  expect_equal(status, 0L)

  jl_files <- sort(list.files(jl_dir, pattern = "\\.json$"))
  expect_gte(length(jl_files), 3L)
  expect_identical(sort(list.files(out_dir, pattern = "\\.json$")), jl_files)

  for (f in jl_files) {
    r_json <- file.path(out_dir, f)
    jl_json <- file.path(jl_dir, f)
    # Structural diff first (clearer failure), then byte-level pin.
    expect_identical(
      jsonlite::read_json(r_json, simplifyVector = FALSE),
      jsonlite::read_json(jl_json, simplifyVector = FALSE),
      label = paste("parsed", f)
    )
    expect_identical(
      unname(tools::md5sum(r_json)),
      unname(tools::md5sum(jl_json)),
      label = paste("bytes", f)
    )
  }
})
