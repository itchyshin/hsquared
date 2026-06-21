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
  expect_null(group(1 | genetic_group))
  expect_null(unknown_parent_group(1 | upg))
  expect_null(metafounder(
    1 | id,
    pedigree = ped,
    group = mf_group,
    Gamma = Gamma
  ))
  expect_null(inbreeding(1 | id))
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
    "cbind(trait1, trait2)",
    fixed = TRUE
  )

  expect_error(
    hsquared:::hs_build_model_spec(
      y ~ animal(1 | id, pedigree = ped, cov = us()),
      data = dat,
      family = stats::gaussian(),
      REML = TRUE
    ),
    "`animal()` argument `cov` is planned, not implemented.",
    fixed = TRUE
  )
  expect_error(
    hsquared:::hs_build_model_spec(
      y ~ animal(1 | id, pedigree = ped, cov = lowrank(K = 2)),
      data = dat,
      family = stats::gaussian(),
      REML = TRUE
    ),
    "cov = lowrank(K = 2)",
    fixed = TRUE
  )
  expect_error(
    hsquared:::hs_build_model_spec(
      y ~ animal(trait | id, pedigree = ped, cov = fa(K = 2)),
      data = dat,
      family = stats::gaussian(),
      REML = TRUE
    ),
    "Long-format `animal(trait | id, cov = ...)`",
    fixed = TRUE
  )
})

test_that("family errors point to the opt-in non-Gaussian path", {
  ped <- data.frame(
    id = c("a", "b"),
    sire = c(NA, NA),
    dam = c(NA, NA)
  )
  dat <- data.frame(y = c(1, 2), id = c("a", "b"), sex = c("f", "m"))

  # On the default/spec path, poisson/binomial are rejected and pointed to the
  # opt-in `target = "nongaussian"` path (the families now fit there).
  expect_error(
    hsquared:::hs_build_model_spec(
      y ~ sex + animal(1 | id, pedigree = ped),
      data = dat,
      family = stats::poisson(),
      REML = TRUE
    ),
    "poisson\\(log\\).*nongaussian",
    perl = TRUE
  )

  expect_error(
    model_spec(
      y ~ sex + animal(1 | id, pedigree = ped),
      data = dat,
      family = stats::binomial()
    ),
    "binomial\\(logit\\).*nongaussian",
    perl = TRUE
  )

  # The error names the engine's V6-LAPLACE (partial) gate honestly.
  expect_error(
    hsquared:::hs_build_model_spec(
      y ~ sex + animal(1 | id, pedigree = ped),
      data = dat,
      family = stats::poisson(),
      REML = TRUE
    ),
    "V6-LAPLACE",
    fixed = TRUE
  )

  # gaussian() with a non-identity link is still rejected.
  expect_error(
    hsquared:::hs_build_model_spec(
      y ~ sex + animal(1 | id, pedigree = ped),
      data = dat,
      family = stats::gaussian("log"),
      REML = TRUE
    ),
    "not fitted on this path",
    fixed = TRUE
  )

  # With the opt-in target the family gate accepts poisson/binomial (the spec
  # builds; fitting itself needs a live engine).
  expect_no_error(
    hsquared:::hs_build_model_spec(
      y ~ sex + animal(1 | id, pedigree = ped),
      data = dat,
      family = stats::poisson(),
      REML = TRUE,
      allow_families = c("gaussian", "poisson", "binomial")
    )
  )
})

test_that("formula parser rejects bare (... | group) random effects", {
  ped <- data.frame(
    id = c("a", "b", "c"),
    sire = c(NA, NA, "a"),
    dam = c(NA, NA, "b")
  )
  dat <- data.frame(y = c(1, 2, 3), x = c(0.1, 0.2, 0.3), id = c("a", "b", "c"))

  # A bare lme4-style random effect must be named, not silently absorbed into
  # the fixed-effect design.
  expect_error(
    hsquared:::hs_build_model_spec(
      y ~ animal(1 | id, pedigree = ped) + (1 | x),
      data = dat,
      family = stats::gaussian(),
      REML = TRUE
    ),
    "Unsupported random-effect term",
    fixed = TRUE
  )

  # The same applies when the bar term is the only random-effect-like term.
  expect_error(
    hsquared:::hs_build_model_spec(
      y ~ animal(1 | id, pedigree = ped) + (x | id),
      data = dat,
      family = stats::gaussian(),
      REML = TRUE
    ),
    "Unsupported random-effect term",
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

  # Phase 2 standard-QG reservations (genetic groups / unknown-parent-groups,
  # metafounders, inbreeding-as-effect) now error cleanly instead of leaking a
  # cryptic `could not find function` from the formula environment.
  for (term in c(
    "group(1 | id)",
    "unknown_parent_group(1 | id)",
    "inbreeding(1 | id)"
  )) {
    marker <- sub("\\(.*$", "", term)
    expect_error(
      hsquared:::hs_build_model_spec(
        stats::as.formula(
          paste("y ~ animal(1 | id, pedigree = ped) +", term)
        ),
        data = dat,
        family = stats::gaussian(),
        REML = TRUE
      ),
      paste0("`", marker, "()` is planned, not implemented."),
      fixed = TRUE
    )
  }
})

test_that("metafounder parses as an opt-in supplied-Gamma primary effect", {
  ped <- data.frame(
    id = c("sire", "dam", "calf"),
    sire = c(NA, NA, "sire"),
    dam = c(NA, NA, "dam")
  )
  dat <- data.frame(y = c(1, 2.5, 4), id = c("sire", "dam", "calf"))
  mf_group <- c(sire = "base", dam = "base", calf = "")
  Gamma <- matrix(0.25, nrow = 1, dimnames = list("base", "base"))

  spec <- hsquared:::hs_build_model_spec(
    y ~ metafounder(1 | id, pedigree = ped, group = mf_group, Gamma = Gamma),
    data = dat,
    family = stats::gaussian(),
    REML = TRUE
  )

  expect_null(spec$random$animal)
  expect_equal(spec$random$metafounder$type, "metafounder")
  expect_equal(spec$random$metafounder$relationship, "metafounder")
  expect_equal(
    unname(spec$random$metafounder$group_of),
    c("base", "base", "")
  )
  expect_equal(spec$random$metafounder$Gamma, matrix(0.25, nrow = 1))
  expect_match(spec$bridge$target, "metafounder_animal_model", fixed = TRUE)

  expect_error(
    hsquared:::hs_build_model_spec(
      y ~ metafounder(1 | id, pedigree = ped, group = mf_group),
      data = dat,
      family = stats::gaussian(),
      REML = TRUE
    ),
    "requires both `group` and `Gamma`",
    fixed = TRUE
  )
})

test_that("a bare fixed-effect column named `group` still parses", {
  # The reserved `group()` marker is detected by call head only, so a plain
  # fixed-effect column that happens to be named `group` must keep parsing.
  ped <- data.frame(
    id = c("a", "b", "c"),
    sire = c(NA, NA, "a"),
    dam = c(NA, NA, "b")
  )
  dat <- data.frame(
    y = c(1, 2, 3),
    id = c("a", "b", "c"),
    group = c("g1", "g2", "g1")
  )

  spec <- hsquared:::hs_build_model_spec(
    y ~ group + animal(1 | id, pedigree = ped),
    data = dat,
    family = stats::gaussian(),
    REML = TRUE
  )
  payload <- hsquared:::hs_build_bridge_payload(spec)
  expect_true("groupg2" %in% payload$metadata$fixed_colnames)

  # `group` as a grouping VARIABLE inside a random effect is the package's own
  # documented usage (`common_env(1 | group)`, formula_status row 4); the
  # reserved `group()` marker must not break it.
  expect_no_error(
    hsquared:::hs_build_model_spec(
      y ~ animal(1 | id, pedigree = ped) + common_env(1 | group),
      data = dat,
      family = stats::gaussian(),
      REML = TRUE
    )
  )
})

test_that("animal() random-regression syntax errors as planned", {
  ped <- data.frame(id = c("a", "b"), sire = c(NA, NA), dam = c(NA, NA))
  dat <- data.frame(y = c(1, 2), id = c("a", "b"), x = c(0.1, 0.2))

  expect_error(
    hsquared:::hs_build_model_spec(
      y ~ animal(x | id, pedigree = ped),
      data = dat,
      family = stats::gaussian(),
      REML = TRUE
    ),
    "random-regression",
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
