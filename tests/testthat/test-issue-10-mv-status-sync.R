# Refs #10: keep validation_status() evidence and the comparator
# manifest in line with the already signed-off t = 2 coverage and the
# discharged blupf90+ comparison. Does not change status or
# public_covered_count.

test_that("multivariate validation evidence matches the signed-off t=2 coverage", {
  status <- validation_status()
  mv <- status[
    status$capability == "experimental multivariate REML estimator (opt-in)",
  ]
  expect_equal(nrow(mv), 1L)
  expect_equal(mv$status, "covered")
  expect_no_match(mv$evidence, "without promoting the row", fixed = TRUE)
  expect_no_match(mv$evidence, "validation row (partial)", fixed = TRUE)
  expect_match(
    mv$evidence,
    "covered at validation scale; HSquared.jl#161",
    fixed = TRUE
  )
  expect_match(mv$evidence, "blupf90+ 2.60", fixed = TRUE)
  expect_match(
    mv$evidence,
    "covered (validation-scale) t = 2 unstructured claim",
    fixed = TRUE
  )
})
