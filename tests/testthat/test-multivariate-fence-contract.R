# A28 remainder — enforce doc-38 §H fences on claim + parser surfaces.
# No covered flip. Option (a): k >= 3 stays parseable-and-fittable-but-experimental.
# diagonal stays experimental; lowrank / factor_analytic stay aborted.

test_that("k >= 3 cbind remains parseable (doc-38 §H.1 option a)", {
  ped <- data.frame(
    id = c("sire", "dam", "calf1", "calf2"),
    sire = c(NA, NA, "sire", "sire"),
    dam = c(NA, NA, "dam", "dam")
  )
  dat <- data.frame(
    y1 = c(1, 2, 3, 4),
    y2 = c(1.5, 2.5, 3.5, 4.5),
    y3 = c(0.5, 1.5, 2.5, 3.5),
    id = ped$id
  )

  spec <- hsquared:::hs_build_model_spec(
    cbind(y1, y2, y3) ~ animal(1 | id, pedigree = ped),
    data = dat,
    family = stats::gaussian(),
    REML = TRUE
  )
  payload <- hsquared:::hs_build_bridge_payload(spec)

  expect_true(spec$response$multivariate)
  expect_equal(spec$response$trait_names, c("y1", "y2", "y3"))
  expect_equal(dim(payload$Y), c(4L, 3L))
  expect_match(spec$bridge$target, "fit_multivariate_reml", fixed = TRUE)
})

test_that("diagonal is accepted; lowrank/FA stay aborted (doc-38 §H.4)", {
  expect_identical(
    hsquared:::hs_validate_genetic_structure_control(
      hs_control(
        engine = "julia",
        engine_control = list(
          target = "multivariate",
          genetic_structure = "diagonal"
        )
      ),
      "multivariate"
    ),
    "diagonal"
  )
  for (gs in c("lowrank", "factor_analytic")) {
    expect_error(
      hsquared:::hs_validate_genetic_structure_control(
        hs_control(
          engine = "julia",
          engine_control = list(
            target = "multivariate",
            genetic_structure = gs
          )
        ),
        "multivariate"
      ),
      "planned, not implemented",
      fixed = TRUE
    )
  }
})

test_that("claim surfaces pin k=2 scope and diagonal experimental fences", {
  status <- validation_status()
  mv <- status[
    status$capability == "experimental multivariate REML estimator (opt-in)",
  ]
  expect_equal(mv$status, "partial")
  expect_match(
    mv$claim_boundary,
    "scoped to k = 2 unstructured",
    fixed = TRUE
  )
  expect_match(
    mv$claim_boundary,
    "k >= 3 stays parseable-and-fittable-but-experimental",
    fixed = TRUE
  )
  expect_match(
    mv$claim_boundary,
    "\"diagonal\" stays experimental",
    fixed = TRUE
  )

  formulas <- formula_status()
  mv_term <- "cbind(trait1, trait2) ~ animal(1 | id, pedigree = ped)"
  note <- formulas$current_behavior[formulas$term == mv_term]
  expect_match(note, "scoped to k = 2 unstructured", fixed = TRUE)
  expect_match(
    note,
    "k >= 3 traits stay parseable-and-fittable-but-experimental",
    fixed = TRUE
  )
  expect_match(
    note,
    "genetic_structure = \"diagonal\" stays experimental",
    fixed = TRUE
  )
})

test_that("structured / factor-analytic ledger row stays partial for diagonal", {
  status <- validation_status()
  # The public structured-G claim is not a validation_status() capability id;
  # pin the multivariate claim_boundary + formula note instead, and assert the
  # capability-status prose contract via the diagonal control remaining
  # non-covered in the live status table (multivariate stays partial).
  expect_false(any(
    grepl("diagonal", status$capability, fixed = TRUE) &
      status$status == "covered"
  ))
  expect_equal(
    status$status[
      status$capability == "experimental multivariate REML estimator (opt-in)"
    ],
    "partial"
  )
})
