test_that("print.hs_backend_info shows all backend rows (#372)", {
  info <- backend_info()
  expect_equal(nrow(info), 6L)

  printed <- paste(capture.output(print(info)), collapse = "\n")
  expect_false(grepl("<0 rows>", printed, fixed = TRUE))
  expect_match(printed, "cpu")
  expect_match(printed, "threads")
  expect_match(printed, "cuda")
  expect_match(printed, "amdgpu")
  expect_match(printed, "metal")
  expect_match(printed, "oneapi")

  expect_invisible(print(info))
})
