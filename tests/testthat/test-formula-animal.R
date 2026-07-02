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

test_that("formula parser accepts bare (1 | group) intercepts, rejects slopes", {
  ped <- data.frame(
    id = c("a", "b", "c"),
    sire = c(NA, NA, "a"),
    dam = c(NA, NA, "b")
  )
  dat <- data.frame(
    y = c(1, 2, 3),
    x = c(0.1, 0.2, 0.3),
    nest = c("N1", "N1", "N2"),
    id = c("a", "b", "c"),
    stringsAsFactors = FALSE
  )

  # A bare random INTERCEPT `(1 | group)` is now accepted as an opt-in i.i.d.
  # random effect (the arbitrary-N independent-effect model). It must parse into
  # the `iid_effects` list, not error.
  spec <- hsquared:::hs_build_model_spec(
    y ~ animal(1 | id, pedigree = ped) + (1 | nest),
    data = dat,
    family = stats::gaussian(),
    REML = TRUE
  )
  expect_length(spec$random$iid_effects, 1L)
  expect_equal(spec$random$iid_effects[[1L]]$type, "iid")
  expect_equal(spec$random$iid_effects[[1L]]$group, "nest")
  expect_equal(spec$random$iid_effects[[1L]]$relationship, "identity")

  # A random SLOPE `(x | id)` is still REJECTED: hsquared has no random-slope
  # estimator, so accepting it would over-claim a capability that is not
  # implemented.
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

  # A correlated / uncorrelated slope term `(x || id)` is also REJECTED (the `||`
  # operator, lme4's uncorrelated-slope syntax).
  expect_error(
    hsquared:::hs_build_model_spec(
      y ~ animal(1 | id, pedigree = ped) + (x || id),
      data = dat,
      family = stats::gaussian(),
      REML = TRUE
    ),
    "Unsupported random-effect term",
    fixed = TRUE
  )
})

test_that("formula parser accepts animal() + two bare (1 | group) i.i.d. effects", {
  ped <- data.frame(
    id = c("a", "b", "c", "d"),
    sire = c(NA, NA, "a", "a"),
    dam = c(NA, NA, "b", "c"),
    stringsAsFactors = FALSE
  )
  dat <- data.frame(
    y = c(1, 2, 3, 4),
    id = c("a", "c", "d", "b"),
    nest = c("N1", "N1", "N2", "N2"),
    year = c("2019", "2020", "2019", "2020"),
    stringsAsFactors = FALSE
  )
  spec <- hsquared:::hs_build_model_spec(
    y ~ animal(1 | id, pedigree = ped) + (1 | nest) + (1 | year),
    data = dat,
    family = stats::gaussian(),
    REML = TRUE
  )
  # Two i.i.d. blocks on DISTINCT grouping columns must both be retained (the
  # list slot avoids the old string-keyed collision).
  expect_length(spec$random$iid_effects, 2L)
  expect_equal(
    vapply(spec$random$iid_effects, function(e) e$group, character(1L)),
    c("nest", "year")
  )
  expect_true(all(
    vapply(spec$random$iid_effects, function(e) e$type, character(1L)) == "iid"
  ))
  expect_match(spec$bridge$target, "fit_multi_effect_reml", fixed = TRUE)
})

test_that("multi-effect emitter builds a pedigree block plus one iid block per group", {
  ped <- data.frame(
    id = c("a", "b", "c", "d"),
    sire = c(NA, NA, "a", "a"),
    dam = c(NA, NA, "b", "c"),
    stringsAsFactors = FALSE
  )
  dat <- data.frame(
    y = c(1, 2, 3, 4),
    id = c("a", "c", "d", "b"),
    nest = c("N1", "N1", "N2", "N2"),
    year = c("2019", "2020", "2019", "2020"),
    stringsAsFactors = FALSE
  )
  spec <- hsquared:::hs_build_model_spec(
    y ~ animal(1 | id, pedigree = ped) + (1 | nest) + (1 | year),
    data = dat,
    family = stats::gaussian(),
    REML = TRUE
  )
  payload <- hsquared:::hs_build_bridge_payload(spec)
  re <- payload$random_effects

  expect_equal(payload$payload_version, 2L)
  expect_length(re, 3L)

  # block 1 — animal pedigree
  expect_equal(re[[1L]]$name, "animal")
  expect_equal(re[[1L]]$type, "pedigree")
  expect_equal(re[[1L]]$relmat_status, "build_in_julia")

  # blocks 2, 3 — i.i.d. identity blocks, one per grouping column
  expect_equal(re[[2L]]$name, "nest")
  expect_equal(re[[2L]]$type, "iid")
  expect_equal(re[[2L]]$relmat_status, "identity")
  expect_null(re[[2L]]$pedigree)
  expect_s4_class(re[[2L]]$Z, "dgCMatrix")
  expect_equal(dim(re[[2L]]$Z), c(4L, 2L))
  expect_equal(sort(re[[2L]]$ids), sort(c("N1", "N2")))

  expect_equal(re[[3L]]$name, "year")
  expect_equal(re[[3L]]$type, "iid")
  expect_equal(re[[3L]]$relmat_status, "identity")
  expect_equal(dim(re[[3L]]$Z), c(4L, 2L))
  expect_equal(sort(re[[3L]]$ids), sort(c("2019", "2020")))
})

test_that("hsquared fits the opt-in multi-effect model (K >= 3 blocks)", {
  testthat::skip_on_cran()
  testthat::skip_if_not(
    hsquared:::hs_julia_bridge_available(),
    "JuliaCall, Julia, and local HSquared.jl are required for a live fit."
  )

  # Founders a-d plus offspring e-h; two independent environmental factors (nest
  # and year) assigned INDEPENDENTLY of the pedigree, plus the additive-genetic
  # animal effect -> three independent blocks -> fit_multi_effect_reml.
  ped <- data.frame(
    id = c("a", "b", "c", "d", "e", "f", "g", "h"),
    sire = c(NA, NA, NA, NA, "a", "a", "c", "c"),
    dam = c(NA, NA, NA, NA, "b", "b", "d", "d"),
    stringsAsFactors = FALSE
  )
  set.seed(11)
  ids <- ped$id
  nest <- c("nst1", "nst1", "nst2", "nst2", "nst3", "nst3", "nst4", "nst4")
  year <- c("y1", "y2", "y1", "y2", "y1", "y2", "y1", "y2")
  nest_e <- stats::setNames(stats::rnorm(4, 0, 0.6), c("nst1", "nst2", "nst3", "nst4"))
  year_e <- stats::setNames(stats::rnorm(2, 0, 0.5), c("y1", "y2"))
  dat <- data.frame(
    y = 3 + nest_e[nest] + year_e[year] + stats::rnorm(8, 0, 0.7),
    id = ids,
    nest = nest,
    year = year,
    stringsAsFactors = FALSE
  )

  fit <- hsquared(
    y ~ animal(1 | id, pedigree = ped) + (1 | nest) + (1 | year),
    data = dat,
    family = stats::gaussian(),
    control = hs_control(
      engine = "julia",
      engine_control = list(target = "multi_effect")
    )
  )

  expect_s3_class(fit, "hsquared_fit")
  expect_equal(fit$spec$target, "multi_effect")

  vc <- variance_components(fit)
  # component/estimate over ALL blocks + residual, in block order.
  expect_equal(vc$component, c("animal", "nest", "year", "residual"))
  expect_true(all(is.finite(vc$estimate)) && all(vc$estimate >= 0))

  # heritability is the ANIMAL block ratio with the FULL phenotypic denominator.
  h2 <- heritability(fit)
  expect_equal(h2$term, "animal")
  total <- sum(vc$estimate)
  expect_equal(
    h2$estimate,
    vc$estimate[vc$component == "animal"] / total,
    tolerance = 1e-8
  )
  expect_true(is.finite(h2$estimate) && h2$estimate >= 0 && h2$estimate < 1)

  # named per-block random effects (BLUPs)
  re <- random_effects(fit)
  expect_true(all(c("animal", "nest", "year") %in% names(re)))
  expect_equal(nrow(re$nest), 4L)
  expect_equal(nrow(re$year), 2L)

  # POINT ESTIMATES only: no interval field is attached on this path (deferred).
  expect_null(fit$result$heritability_interval)
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
