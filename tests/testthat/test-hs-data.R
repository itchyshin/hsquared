test_that("hs_data stores phenotype, pedigree, and genotype ID maps", {
  phenotypes <- data.frame(id = c("a", "b", "b"), y = c(1, 2, 3))
  pedigree <- data.frame(
    id = c("a", "b", "c"),
    sire = c(NA, NA, "a"),
    dam = c(NA, NA, "b")
  )
  genotypes <- matrix(
    1,
    nrow = 2,
    ncol = 3,
    dimnames = list(c("b", "d"), c("m1", "m2", "m3"))
  )

  data <- hs_data(
    phenotypes = phenotypes,
    pedigree = pedigree,
    genotypes = genotypes,
    markers = data.frame(marker = c("m1", "m2", "m3"))
  )

  expect_s3_class(data, "hs_data")
  expect_equal(data$id_map$phenotype_ids, c("a", "b"))
  expect_equal(data$id_map$pedigree_ids, c("a", "b", "c"))
  expect_equal(data$id_map$genotype_ids, c("b", "d"))
  expect_equal(data$id_map$phenotypes_without_pedigree, character())
  expect_equal(data$id_map$phenotypes_without_genotypes, "a")
  expect_equal(data$id_map$genotypes_without_phenotypes, "d")
  expect_s3_class(summary(data), "summary_hs_data")
})

test_that("hs_data accepts expression IDs from an ID column", {
  phenotypes <- data.frame(sample = c("s1", "s2"), y = c(1, 2))
  expression <- data.frame(sample = c("s2", "s3"), gene1 = c(10, 20))

  data <- hs_data(
    phenotypes = phenotypes,
    expression = expression,
    id = "sample"
  )

  expect_equal(data$id_map$expression_ids, c("s2", "s3"))
  expect_equal(data$id_map$phenotypes_without_expression, "s1")
  expect_equal(data$id_map$expression_without_phenotypes, "s3")
})

test_that("hs_data rejects missing phenotype IDs and incomplete pedigree IDs", {
  expect_error(
    hs_data(data.frame(id = c("a", NA), y = c(1, 2))),
    "`phenotypes` IDs cannot be missing",
    fixed = TRUE
  )

  expect_error(
    hs_data(
      phenotypes = data.frame(id = c("a", "b"), y = c(1, 2)),
      pedigree = data.frame(id = "a", sire = NA, dam = NA)
    ),
    "not present in `pedigree`: b",
    fixed = TRUE
  )
})

test_that("hs_data rejects unsupported component shapes", {
  expect_error(
    hs_data(
      phenotypes = data.frame(id = "a", y = 1),
      genotypes = matrix(1, nrow = 1)
    ),
    "matrix must have individual IDs as row names",
    fixed = TRUE
  )

  expect_error(
    hs_data(
      phenotypes = data.frame(id = "a", y = 1),
      genotypes = data.frame(m1 = 1)
    ),
    "must contain ID column `id` or non-missing row names",
    fixed = TRUE
  )

  expect_error(
    hs_data(
      phenotypes = data.frame(id = "a", y = 1),
      markers = matrix(1)
    ),
    "`markers` must be a data frame",
    fixed = TRUE
  )
})
