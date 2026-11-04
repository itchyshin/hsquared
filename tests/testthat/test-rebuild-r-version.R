test_that("package metadata declares the R version needed by its source", {
  metadata <- read.dcf(file.path("..", "..", "DESCRIPTION"))
  expect_true("Depends" %in% colnames(metadata))
  if ("Depends" %in% colnames(metadata)) {
    expect_match(metadata[1, "Depends"], "R *\\(>= *4[.]1[.]0 *\\)")
  }
})
