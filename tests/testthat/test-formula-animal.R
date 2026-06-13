test_that("animal is an inert formula marker", {
  expect_null(animal(1 | id, pedigree = ped))
})

test_that("planned genomic and QTL markers are inert formula markers", {
  expect_null(genomic(1 | id, Ginv = Ginv))
  expect_null(single_step(1 | id, Hinv = Hinv))
  expect_null(markers(M, model = "random"))
  expect_null(marker_scan(M, map = marker_map))
  expect_null(qtl_scan(position, genotype_probs = probs))
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

  expect_error(
    hsquared:::hs_build_model_spec(
      y ~ sex + genomic(1 | id, Ginv = Ginv),
      data = dat,
      family = stats::gaussian(),
      REML = TRUE
    ),
    "`genomic()` is planned, not implemented.",
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
