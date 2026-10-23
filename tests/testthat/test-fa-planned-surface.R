test_that("FA formula remains reserved while the bounded R opt-in is partial", {
  status <- validation_status()
  mv <- status[status$capability ==
                 "experimental multivariate REML estimator (opt-in)", ]
  expect_match(mv$claim_boundary,
               "four-trait rank-one factor_analytic G is partial",
               fixed = TRUE)

  # The public count is a claim-surface fence, not a reason to promote the
  # engine's V4-FA evidence into the R package.
  capability_path <- testthat::test_path(
    "..",
    "..",
    "docs",
    "design",
    "capability-status.md"
  )
  testthat::skip_if_not(
    file.exists(capability_path),
    "repository-only capability-status.md is unavailable in the build tarball"
  )
  capability_doc <- paste(
    readLines(capability_path, warn = FALSE),
    collapse = "\n"
  )
  expect_match(
    capability_doc,
    "factor-analytic G matrices | partial",
    fixed = TRUE
  )
  expect_true(grepl("public_covered_count[^\\n]*7", capability_doc))

  formulas <- formula_status()
  fa_term <- "animal(trait | id, pedigree = ped, cov = fa(K = 2))"
  fa_note <- formulas$current_behavior[formulas$term == fa_term]
  expect_length(fa_note, 1L)
  expect_match(fa_note, "Julia V4-FA is engine-covered", fixed = TRUE)
  expect_match(fa_note, "A separate partial opt-in", fixed = TRUE)
  expect_match(fa_note, "public_covered_count stays 7", fixed = TRUE)

  # The bounded opt-in does not change the version, covered count, or grammar.
  expect_match(capability_doc, "FA status (2026-09-27)", fixed = TRUE)
  expect_match(capability_doc, "cov = fa(K)", fixed = TRUE)
  expect_match(capability_doc, "public_covered_count` stays **7**", fixed = TRUE)
  expect_match(capability_doc, "0.9.0", fixed = TRUE)
  expect_match(
    capability_doc,
    "Experimental stays **0.9.0**. Not an R-public SS flip.",
    fixed = TRUE
  )
  expect_false(grepl(
    "Experimental stays \\*\\*0\\.8\\.0\\*\\*\\. Not an R-public SS flip",
    capability_doc
  ))
})

test_that("factor-analytic controls require rank one and lowrank remains closed", {
  expect_error(
    hsquared:::hs_validate_genetic_structure_control(
      hs_control(
        engine = "julia",
        engine_control = list(
          target = "multivariate",
          genetic_structure = "factor_analytic"
        )
      ),
      "multivariate"
    ),
    "rank = 1",
    fixed = TRUE
  )
  expect_error(
    hsquared:::hs_validate_genetic_structure_control(
      hs_control(
        engine = "julia",
        engine_control = list(
          target = "multivariate",
          genetic_structure = "lowrank"
        )
      ),
      "multivariate"
    ),
    "planned",
    fixed = TRUE
  )
})

test_that("FA formula grammar rejects before model construction", {
  ped <- data.frame(
    id = c("a", "b"),
    sire = c(NA, NA),
    dam = c(NA, NA)
  )
  dat <- data.frame(y = c(1, 2), id = ped$id)

  expect_error(
    hsquared:::hs_build_model_spec(
      y ~ animal(1 | id, pedigree = ped, cov = fa(K = 2)),
      data = dat,
      family = stats::gaussian(),
      REML = TRUE
    ),
    "`cov = fa(K = 1)` is also reserved and does not parse",
    fixed = TRUE
  )
})
