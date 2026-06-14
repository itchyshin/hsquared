test_that("animal is an inert formula marker", {
  expect_null(animal(1 | id, pedigree = ped))
  expect_null(animal(1 | id))
})

test_that("planned genomic and QTL markers are inert formula markers", {
  expect_null(genomic(1 | id, Ginv = Ginv))
  expect_null(single_step(1 | id, Hinv = Hinv))
  expect_null(markers(M, model = "random"))
  expect_null(marker_scan(M, map = marker_map))
  expect_null(qtl_scan(position, genotype_probs = probs))
})

test_that("planned quantitative-genetic effect markers are inert", {
  expect_null(permanent(1 | id))
  expect_null(common_env(1 | litter))
  expect_null(maternal_genetic(1 | dam, pedigree = ped))
  expect_null(maternal_env(1 | dam))
  expect_null(paternal_genetic(1 | sire, pedigree = ped))
  expect_null(paternal_env(1 | sire))
  expect_null(cytoplasmic(1 | maternal_line))
  expect_null(imprinting(1 | id, pedigree = ped, parent = "maternal"))
  expect_null(dominance(1 | id, pedigree = ped, Dinv = Dinv))
  expect_null(epistasis(1 | id, pedigree = ped, Einv = Einv))
  expect_null(relmat(1 | id, K = K))
  expect_null(precision(1 | id, Q = Q))
})

test_that("hs_build_model_spec parses the v0.1 animal contract", {
  ped <- data.frame(
    animal = c("a", "b", "c", "d"),
    father = c(NA, NA, "a", "a"),
    mother = c(NA, NA, "b", "c")
  )
  dat <- data.frame(
    y = c(1, 2, 3),
    sex = c("f", "m", "f"),
    age = c(1, 2, 3),
    id = c("a", "c", "d")
  )

  spec <- hsquared:::hs_build_model_spec(
    y ~ sex + age + animal(1 | id, pedigree = ped),
    data = dat,
    family = stats::gaussian(),
    REML = TRUE
  )

  expect_equal(spec$method, "REML")
  expect_equal(spec$response$name, "y")
  expect_equal(nrow(spec$fixed$design), nrow(dat))
  expect_equal(spec$random$animal$group, "id")
  expect_equal(spec$random$animal$pedigree$ids, c("a", "b", "c", "d"))
  expect_equal(
    spec$random$animal$pedigree$data$sire,
    c(NA_character_, NA_character_, "a", "a")
  )
})

test_that("formula parser rejects unsupported animal syntax", {
  ped <- data.frame(
    id = c("a", "b"),
    sire = c(NA, NA),
    dam = c(NA, NA)
  )
  dat <- data.frame(y = c(1, 2), id = c("a", "b"), trait = c("x", "y"))

  expect_error(
    hsquared:::hs_build_model_spec(
      y ~ animal(trait | id, pedigree = ped),
      data = dat,
      family = stats::gaussian(),
      REML = TRUE
    ),
    "Only random-intercept syntax",
    fixed = TRUE
  )

  expect_error(
    hsquared:::hs_build_model_spec(
      y ~ animal(1 | id, pedigree = ped, cov = us()),
      data = dat,
      family = stats::gaussian(),
      REML = TRUE
    ),
    "`animal()` argument `cov` is planned, not implemented in v0.1.",
    fixed = TRUE
  )
})

test_that("formula parser rejects planned genomic and QTL syntax honestly", {
  ped <- data.frame(id = c("a", "b"), sire = c(NA, NA), dam = c(NA, NA))
  dat <- data.frame(y = c(1, 2), id = c("a", "b"), sex = c("f", "m"))

  # `genomic(1 | id, Ginv = Ginv)` and `single_step(1 | id, Hinv = Hinv)` are now
  # parsed as opt-in primary effects (see test-genomic.R / test-single-step.R);
  # the marker/QTL scans remain planned.
  expect_error(
    hsquared:::hs_build_model_spec(
      y ~ sex + markers(M, model = "random"),
      data = dat,
      family = stats::gaussian(),
      REML = TRUE
    ),
    "`markers()` is planned, not implemented.",
    fixed = TRUE
  )

  expect_error(
    hsquared:::hs_build_model_spec(
      y ~ sex + animal(1 | id, pedigree = ped) + marker_scan(M, map = map),
      data = dat,
      family = stats::gaussian(),
      REML = TRUE
    ),
    "`marker_scan()` is planned, not implemented.",
    fixed = TRUE
  )
})

test_that("formula parser rejects planned quantitative-genetic effects honestly", {
  ped <- data.frame(id = c("a", "b"), sire = c(NA, NA), dam = c(NA, NA))
  dat <- data.frame(
    y = c(1, 2),
    id = c("a", "b"),
    litter = c("l1", "l1"),
    dam = c("d1", "d2")
  )

  # `permanent()` (repeatability), `common_env()` (common-environment), and
  # `maternal_genetic()` (maternal two-effect) are now parsed opt-in second
  # random effects; the other planned QG markers still error.
  expect_error(
    hsquared:::hs_build_model_spec(
      y ~ animal(1 | id, pedigree = ped) + dominance(1 | id),
      data = dat,
      family = stats::gaussian(),
      REML = TRUE
    ),
    "`dominance()` is planned, not implemented.",
    fixed = TRUE
  )

  expect_error(
    hsquared:::hs_build_model_spec(
      y ~ animal(1 | id, pedigree = ped) + relmat(1 | id, Q = Q),
      data = dat,
      family = stats::gaussian(),
      REML = TRUE
    ),
    "`relmat()` is planned, not implemented.",
    fixed = TRUE
  )
})

test_that("formula parser validates pedigree and observed IDs", {
  ped <- data.frame(
    id = c("a", "b"),
    sire = c(NA, NA),
    dam = c(NA, NA)
  )
  dat <- data.frame(y = c(1, 2), id = c("a", "z"))

  expect_error(
    hsquared:::hs_build_model_spec(
      y ~ animal(1 | id, pedigree = ped),
      data = dat,
      family = stats::gaussian(),
      REML = TRUE
    ),
    "`data` column `id` contains ID not present in `pedigree`: z.",
    fixed = TRUE
  )
})

test_that("animal parser uses hs_data pedigree by default", {
  ped <- data.frame(
    id = c("a", "b", "c"),
    sire = c(NA, NA, "a"),
    dam = c(NA, NA, "b")
  )
  dat <- data.frame(
    y = c(1, 2),
    age = c(4, 5),
    id = c("a", "c")
  )
  bundle <- hs_data(phenotypes = dat, pedigree = ped)

  spec <- hsquared:::hs_build_model_spec(
    y ~ age + animal(1 | id),
    data = bundle,
    family = stats::gaussian(),
    REML = TRUE
  )

  expect_equal(spec$random$animal$pedigree_source, "hs_data")
  expect_equal(spec$random$animal$pedigree$ids, c("a", "b", "c"))
  expect_equal(spec$random$animal$pedigree$parent_index$sire, c(0L, 0L, 1L))
  expect_equal(spec$random$animal$pedigree$parent_index$dam, c(0L, 0L, 2L))
})

test_that("animal parser requires a pedigree source", {
  dat <- data.frame(y = c(1, 2), id = c("a", "b"))

  expect_error(
    hsquared:::hs_build_model_spec(
      y ~ animal(1 | id),
      data = dat,
      family = stats::gaussian(),
      REML = TRUE
    ),
    "unless `data` is an `hs_data()` object with a pedigree component",
    fixed = TRUE
  )

  expect_error(
    hsquared:::hs_build_model_spec(
      y ~ animal(1 | id),
      data = hs_data(dat),
      family = stats::gaussian(),
      REML = TRUE
    ),
    "unless `data` is an `hs_data()` object with a pedigree component",
    fixed = TRUE
  )
})
