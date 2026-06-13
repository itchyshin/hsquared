test_that("tiny animal validation fixture pins R payload ordering", {
  fixture <- hsquared:::hs_tiny_animal_validation_fixture()
  spec <- hsquared:::hs_build_model_spec(
    fixture$formula,
    data = fixture$data,
    family = stats::gaussian(),
    REML = TRUE
  )
  payload <- hsquared:::hs_build_bridge_payload(spec)

  expect_equal(payload$ids, fixture$expected$ids)
  expect_equal(payload$pedigree$id, fixture$expected$ids)
  expect_equal(payload$pedigree$sire_index, fixture$expected$sire_index)
  expect_equal(payload$pedigree$dam_index, fixture$expected$dam_index)
  expect_equal(payload$metadata$observed_ids, fixture$data$id)
  expect_equal(payload$metadata$observed_id_index, c(1L, 2L, 3L))
  expect_equal(unname(as.matrix(payload$Z)), fixture$expected$Z)
})

test_that("tiny animal validation fixture matches Julia Ainv when available", {
  fixture <- hsquared:::hs_tiny_animal_validation_fixture()
  spec <- hsquared:::hs_build_model_spec(
    fixture$formula,
    data = fixture$data,
    family = stats::gaussian(),
    REML = TRUE
  )
  payload <- hsquared:::hs_build_bridge_payload(spec)

  testthat::skip_if_not(
    hsquared:::hs_julia_bridge_available(),
    "JuliaCall, Julia, and local HSquared.jl are required for live Ainv validation."
  )

  hsquared:::hs_julia_setup(hsquared:::hs_default_julia_project())
  JuliaCall::julia_assign("hsq_val_id", payload$pedigree$id)
  JuliaCall::julia_assign(
    "hsq_val_sire",
    hsquared:::hs_parent_for_julia(payload$pedigree$sire)
  )
  JuliaCall::julia_assign(
    "hsq_val_dam",
    hsquared:::hs_parent_for_julia(payload$pedigree$dam)
  )
  JuliaCall::julia_command(paste(
    "hsq_val_ped = HSquared.normalize_pedigree(",
    "hsq_val_id, hsq_val_sire, hsq_val_dam);",
    "hsq_val_Ainv = Matrix(HSquared.pedigree_inverse(hsq_val_ped));"
  ))

  observed <- JuliaCall::julia_eval("hsq_val_Ainv")
  dimnames(observed) <- dimnames(fixture$expected$Ainv)

  expect_equal(observed, fixture$expected$Ainv, tolerance = 1e-12)
})
