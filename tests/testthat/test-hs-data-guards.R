hs_guard_phenotypes <- function() {
  data.frame(id = c("a", "b"), y = c(1, 2))
}

hs_guard_markers <- function() {
  data.frame(marker = c("m1", "m2"), chr = c("1", "1"), pos = c(10, 20))
}

hs_guard_genotypes <- function(marker_ids) {
  matrix(
    1,
    nrow = 2,
    ncol = length(marker_ids),
    dimnames = list(c("a", "b"), marker_ids)
  )
}

test_that("hs_data() rejects non-data-frame phenotypes", {
  expect_error(
    hs_data(phenotypes = matrix(1:4, 2)),
    "`phenotypes` must be a data frame.",
    fixed = TRUE
  )
})

test_that("data_status() default method names the supported class", {
  expect_error(
    data_status(list(a = 1)),
    "`data_status()` currently supports `hs_data()` objects.",
    fixed = TRUE
  )
})

test_that("hs_data() rejects a pedigree that is not a data frame", {
  expect_error(
    hs_data(phenotypes = hs_guard_phenotypes(), pedigree = matrix(1:6, 2)),
    "`pedigree` must be a data frame when supplied.",
    fixed = TRUE
  )
})

test_that("hs_data() rejects a pedigree with fewer than three columns", {
  expect_error(
    hs_data(
      phenotypes = hs_guard_phenotypes(),
      pedigree = data.frame(id = c("a", "b"), sire = c(NA, NA))
    ),
    "`pedigree` must have at least three columns: `id`, `sire`, and `dam`.",
    fixed = TRUE
  )
})

test_that("hs_data() names the marker-map columns it cannot find", {
  expect_error(
    hs_data(
      phenotypes = hs_guard_phenotypes(),
      markers = data.frame(marker = c("m1", "m2"), chr = c("1", "1"))
    ),
    "`markers` must contain marker, chromosome, and position columns.",
    fixed = TRUE
  )
})

test_that("hs_data() rejects duplicate genotype marker columns", {
  expect_error(
    hs_data(
      phenotypes = hs_guard_phenotypes(),
      genotypes = hs_guard_genotypes(c("m1", "m1")),
      markers = hs_guard_markers()
    ),
    "`genotypes` contains duplicate marker column: m1.",
    fixed = TRUE
  )
  # Plural form when more than one marker is duplicated.
  expect_error(
    hs_data(
      phenotypes = hs_guard_phenotypes(),
      genotypes = hs_guard_genotypes(c("m1", "m1", "m2", "m2")),
      markers = hs_guard_markers()
    ),
    "`genotypes` contains duplicate marker columns: m1, m2.",
    fixed = TRUE
  )
})

test_that("hs_data() requires genotype and marker-map IDs to match", {
  expect_error(
    hs_data(
      phenotypes = hs_guard_phenotypes(),
      genotypes = hs_guard_genotypes(c("m1", "m3")),
      markers = hs_guard_markers()
    ),
    "`genotypes` marker columns must match `markers` marker IDs exactly; ",
    fixed = TRUE
  )
  expect_error(
    hs_data(
      phenotypes = hs_guard_phenotypes(),
      genotypes = hs_guard_genotypes(c("m1", "m3")),
      markers = hs_guard_markers()
    ),
    "missing from `markers`: m3; missing from `genotypes`: m2.",
    fixed = TRUE
  )
})
