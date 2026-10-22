# Julia-free input guards for genomic() / single_step() marker inputs. These
# fire in the R parser before any engine call. Branches already asserted
# elsewhere (finite dosages, nonempty row names, column names, monomorphic
# panel, "not both" Hinv, needs a pedigree, ids not in the pedigree, H^Gamma
# group/Gamma pairing, bundle genotypes without ids) are not repeated here.

gss_data <- function() {
  data.frame(
    y = c(1.1, 2.2, 3.0, 2.5),
    id = c("g1", "g2", "g3", "g4"),
    stringsAsFactors = FALSE
  )
}

gss_markers <- function() {
  matrix(
    c(0, 1, 2, 1, 2, 0, 1, 1, 0, 2, 1, 0),
    nrow = 4,
    dimnames = list(c("g1", "g2", "g3", "g4"), paste0("m", 1:3))
  )
}

gss_pedigree <- function() {
  data.frame(
    id = c("g1", "g2", "g3", "g4"),
    sire = c(NA, NA, "g1", "g1"),
    dam = c(NA, NA, "g2", "g2"),
    stringsAsFactors = FALSE
  )
}

test_that("genomic markers must be a numeric matrix", {
  d <- gss_data()
  M <- gss_markers()
  M_chr <- matrix(as.character(M), nrow = 4, dimnames = dimnames(M))
  M_df <- as.data.frame(M)
  expect_error(
    hsquared(y ~ genomic(1 | id, markers = M_chr), data = d),
    "`markers` must be a numeric marker matrix.",
    fixed = TRUE
  )
  expect_error(
    hsquared(y ~ genomic(1 | id, markers = M_df), data = d),
    "`markers` must be a numeric marker matrix.",
    fixed = TRUE
  )
})

test_that("genomic markers need at least one row and one marker column", {
  d <- gss_data()
  no_rows <- matrix(numeric(0), nrow = 0, ncol = 3)
  no_cols <- matrix(numeric(0), nrow = 4, ncol = 0)
  rownames(no_cols) <- d$id
  expect_error(
    hsquared(y ~ genomic(1 | id, markers = no_rows), data = d),
    "`markers` must have at least one row and one marker column.",
    fixed = TRUE
  )
  expect_error(
    hsquared(y ~ genomic(1 | id, markers = no_cols), data = d),
    "`markers` must have at least one row and one marker column.",
    fixed = TRUE
  )
})

test_that("single_step bundle shorthand rejects genotypes that are not a matrix or data frame", {
  expect_error(
    hsquared:::hs_single_step_bundle_markers(c(a = 0, b = 1), "id"),
    "`hs_data()` `genotypes` must be a numeric matrix or data frame",
    fixed = TRUE
  )
})

test_that("single_step construction names unknown construction arguments", {
  d <- gss_data()
  ped <- gss_pedigree()
  M <- gss_markers()
  spec <- function(formula) {
    hsquared:::hs_build_model_spec(
      formula,
      data = d,
      family = stats::gaussian(),
      REML = TRUE
    )
  }
  expect_error(
    spec(y ~ single_step(1 | id, pedigree = ped, markers = M, scale = 2)),
    "`single_step()` construction argument `scale` is planned, not implemented.",
    fixed = TRUE
  )
  expect_error(
    spec(y ~
      single_step(1 | id, pedigree = ped, markers = M, scale = 2, shrink = 1)),
    "`single_step()` construction arguments `scale`, `shrink` are planned, not implemented.",
    fixed = TRUE
  )
})
