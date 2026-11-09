# Coverage lane for R/hs_data.R: argument guards, optional-component ID
# resolution and the print/summary methods of the data container. Counts are
# checked against the input sizes (set arithmetic on IDs).

hs_cov_pheno <- function() {
  data.frame(id = c("a", "b", "b", "c"), y = c(1, 2, 3, 4))
}

hs_cov_pedigree <- function() {
  data.frame(
    id = c("a", "b", "c", "d"),
    sire = c(NA, NA, "a", "a"),
    dam = c(NA, NA, "b", "b")
  )
}

hs_cov_out <- function(x) paste(utils::capture.output(print(x)), collapse = "\n")

test_that("hs_data() guards its phenotypes and id arguments", {
  expect_error(hs_data(phenotypes = 1), "`phenotypes` must be a data frame.", fixed = TRUE)
  for (bad in list(1, NA_character_, "", c("id", "y"))) {
    expect_error(
      hs_data(hs_cov_pheno(), id = bad),
      "`id` must be one non-empty column name.",
      fixed = TRUE
    )
  }
  expect_error(
    hs_data(hs_cov_pheno(), id = "animal"),
    "`id` column `animal` was not found in `phenotypes`.",
    fixed = TRUE
  )
})

test_that("optional components resolve IDs from a column, then row names, else refuse", {
  by_column <- hs_data(
    hs_cov_pheno(),
    genotypes = data.frame(id = c("a", "x", "x"), m1 = c(0, 1, 2))
  )
  expect_identical(by_column$id_map$genotype_ids, c("a", "x"))

  by_rownames <- hs_data(
    hs_cov_pheno(),
    genotypes = data.frame(m1 = c(0, 1), row.names = c("b", "y"))
  )
  expect_identical(by_rownames$id_map$genotype_ids, c("b", "y"))

  expect_error(
    hs_data(hs_cov_pheno(), genotypes = data.frame(m1 = c(0, 1))),
    "`genotypes` must contain ID column `id` or non-missing row names.",
    fixed = TRUE
  )
  expect_error(
    hs_data(hs_cov_pheno(), genotypes = matrix(0, 2, 2)),
    "`genotypes` matrix must have individual IDs as row names.",
    fixed = TRUE
  )
  expect_error(
    hs_data(hs_cov_pheno(), expression = list(a = 1)),
    "`expression` must be a data frame or matrix when supplied.",
    fixed = TRUE
  )
})

test_that("expression features need names only when an annotation_id is supplied", {
  annotation <- data.frame(feature = c("g1", "g2"), chr = c("1", "2"))
  unnamed_matrix <- matrix(0, 2, 2, dimnames = list(c("a", "b"), NULL))
  expect_error(
    hs_data(
      hs_cov_pheno(),
      expression = unnamed_matrix,
      annotation = annotation,
      annotation_id = "feature"
    ),
    "`expression` matrix must have feature IDs as column names when `annotation_id` is supplied.",
    fixed = TRUE
  )

  id_only <- data.frame(id = c("a", "b"))
  expect_error(
    hs_data(
      hs_cov_pheno(),
      expression = id_only,
      annotation = annotation,
      annotation_id = "feature"
    ),
    "`expression` must contain at least one feature column when `annotation_id` is supplied.",
    fixed = TRUE
  )

  named_matrix <- matrix(0, 2, 2, dimnames = list(c("a", "b"), c("g1", "g2")))
  with_matrix <- hs_data(
    hs_cov_pheno(),
    expression = named_matrix,
    annotation = annotation,
    annotation_id = "feature"
  )
  expect_s3_class(with_matrix, "hs_data")
  expect_identical(with_matrix$id_map$expression_ids, c("a", "b"))

  with_frame <- hs_data(
    hs_cov_pheno(),
    expression = data.frame(id = c("a", "b"), g1 = 1:2, g2 = 3:4),
    annotation = annotation,
    annotation_id = "feature"
  )
  expect_s3_class(with_frame, "hs_data")
})

test_that("a genotype table with only an id column cannot be aligned to a marker map", {
  markers <- data.frame(marker = c("m1", "m2"), chr = c("1", "1"), pos = c(1, 2))
  expect_error(
    hs_data(
      hs_cov_pheno(),
      genotypes = data.frame(id = c("a", "b")),
      markers = markers
    ),
    "`genotypes` must contain at least one marker column when `markers` is supplied.",
    fixed = TRUE
  )
})

test_that("print.hs_data counts only the components that were supplied", {
  bare <- hs_data(hs_cov_pheno())
  text <- hs_cov_out(bare)
  expect_match(text, "<hs_data>", fixed = TRUE)
  expect_match(text, "phenotypes: 4 rows", fixed = TRUE)
  expect_match(text, "phenotype IDs: 3", fixed = TRUE)
  expect_false(grepl("pedigree IDs", text, fixed = TRUE))
  expect_false(grepl("genotype IDs", text, fixed = TRUE))
  expect_false(grepl("expression IDs", text, fixed = TRUE))

  full <- hs_data(
    hs_cov_pheno(),
    pedigree = hs_cov_pedigree(),
    genotypes = matrix(0, 2, 1, dimnames = list(c("a", "z"), "m1")),
    expression = matrix(0, 3, 1, dimnames = list(c("a", "b", "c"), "g1"))
  )
  text <- hs_cov_out(full)
  expect_match(text, "pedigree IDs: 4", fixed = TRUE)
  expect_match(text, "genotype IDs: 2", fixed = TRUE)
  expect_match(text, "expression IDs: 3", fixed = TRUE)
  utils::capture.output(returned <- print(full))
  expect_identical(returned, full)
})

test_that("data_status() reports 'not available' for every absent component", {
  expect_error(
    data_status(list()),
    "`data_status()` currently supports `hs_data()` objects.",
    fixed = TRUE
  )
  status <- data_status(hs_data(hs_cov_pheno()))
  text <- hs_cov_out(status)
  expect_match(text, "<hs_data_status>", fixed = TRUE)
  expect_match(text, "components: phenotypes", fixed = TRUE)
  for (part in c("pedigree", "expression", "genotype", "marker", "annotation", "environment")) {
    expect_match(text, paste0(part, " status: not available"), fixed = TRUE)
  }
})

test_that("data_status() prints a table for every component that was supplied", {
  pheno <- cbind(hs_cov_pheno(), site = c("s1", "s2", "s2", "s1"))
  bundle <- hs_data(
    pheno,
    pedigree = hs_cov_pedigree(),
    genotypes = matrix(0, 2, 2, dimnames = list(c("a", "z"), c("m1", "m2"))),
    markers = data.frame(marker = c("m1", "m2"), chr = c("1", "2"), pos = c(5, 9)),
    expression = matrix(0, 3, 2, dimnames = list(c("a", "b", "c"), c("g1", "g2"))),
    annotation = data.frame(feature = c("g1", "g2"), chr = c("1", "2")),
    annotation_id = "feature",
    environment = data.frame(site = c("s1", "s2"), altitude = c(10, 200)),
    environment_id = "site"
  )
  status <- data_status(bundle)
  text <- hs_cov_out(status)
  for (part in c("pedigree", "expression", "genotype", "marker", "annotation", "environment")) {
    expect_match(text, paste0(part, " status:\n"), fixed = TRUE)
    expect_false(grepl(paste0(part, " status: not available"), text, fixed = TRUE))
  }
  expect_identical(
    status$components,
    c("phenotypes", "pedigree", "genotypes", "markers", "expression", "annotation", "environment")
  )

  summ <- summary(bundle)
  summ_text <- hs_cov_out(summ)
  expect_match(summ_text, "<summary_hs_data>", fixed = TRUE)
  expect_match(summ_text, "phenotype IDs: 3", fixed = TRUE)
  for (part in c("pedigree", "expression", "genotype", "marker", "annotation", "environment")) {
    expect_match(summ_text, paste0(part, " status:\n"), fixed = TRUE)
  }
  utils::capture.output(returned <- print(summ))
  expect_identical(returned, summ)
})

test_that("summary of a phenotypes-only bundle lists no component tables", {
  summ_text <- hs_cov_out(summary(hs_data(hs_cov_pheno())))
  expect_match(summ_text, "components: phenotypes", fixed = TRUE)
  expect_false(grepl("status:", summ_text, fixed = TRUE))
})

test_that("the ID overlap table is exact set arithmetic on the supplied IDs", {
  bundle <- hs_data(
    hs_cov_pheno(),
    pedigree = hs_cov_pedigree(),
    genotypes = matrix(0, 2, 1, dimnames = list(c("a", "z"), "m1"))
  )
  expect_identical(bundle$id_map$phenotypes_without_pedigree, character())
  expect_identical(bundle$id_map$phenotypes_without_genotypes, c("b", "c"))
  expect_identical(bundle$id_map$genotypes_without_phenotypes, "z")
})
