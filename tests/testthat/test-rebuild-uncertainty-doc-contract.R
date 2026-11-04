test_that("uncertainty help does not advertise an unimplemented bootstrap method", {
  doc <- paste(readLines(file.path("..", "..", "man", "arc1_uncertainty.Rd"), warn = FALSE), collapse = "\n")
  expect_false(grepl("arc1_bootstrap_v2", doc, fixed = TRUE))
  expect_true(grepl("arc1_bootstrap_v1", doc, fixed = TRUE))
})
