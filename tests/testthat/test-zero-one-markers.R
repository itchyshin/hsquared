# hsquared#292: BGLR-style 0/1 inbred coding is inside [0, 2] and was
# accepted silently. Warn, do not recode.

test_that("BGLR-style 0/1 inbred markers warn without recoding (#292)", {
  ids <- paste0("g", 1:3)
  M01 <- matrix(c(0, 1, 0, 1, 1, 0), 3, 2)
  rownames(M01) <- ids
  M02 <- 2 * M01
  M012 <- matrix(c(0, 1, 2, 0, 2, 1), 3, 2)
  rownames(M012) <- ids
  dosage <- matrix(c(0, 0.5, 1, 1.5, 2, 0.25), 3, 2)
  rownames(dosage) <- ids

  expect_warning(
    out <- hsquared:::hs_validate_genomic_markers(M01),
    class = "hsquared_zero_one_markers"
  )
  expect_identical(out, M01)

  w <- tryCatch(
    hsquared:::hs_validate_genomic_markers(M01),
    warning = function(e) e
  )
  expect_s3_class(w, "hsquared_zero_one_markers")
  expect_s3_class(w, "hsquared_warning")
  expect_match(
    conditionMessage(w),
    "markers look 0/1 coded; `genomic()` expects allele counts 0/1/2 (double a homozygous 0/1 panel)",
    fixed = TRUE
  )

  expect_silent(hsquared:::hs_validate_genomic_markers(M02))
  expect_silent(hsquared:::hs_validate_genomic_markers(M012))
  expect_silent(hsquared:::hs_validate_genomic_markers(dosage))

  dat <- data.frame(y = c(1, 2, 3), id = ids)
  expect_warning(
    spec <- hsquared:::hs_build_model_spec(
      y ~ genomic(1 | id, markers = M01),
      data = dat,
      family = stats::gaussian(),
      REML = TRUE
    ),
    class = "hsquared_zero_one_markers"
  )
  expect_identical(spec$random$genomic$markers, M01)
})
