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

test_that("Henderson MME validation fixture pins supplied-variance solutions", {
  fixture <- hsquared:::hs_henderson_mme_validation_fixture()
  spec <- hsquared:::hs_build_model_spec(
    fixture$formula,
    data = fixture$data,
    family = stats::gaussian(),
    REML = FALSE
  )
  payload <- hsquared:::hs_build_bridge_payload(spec)

  expect_equal(payload$ids, fixture$expected$ids)
  expect_equal(payload$pedigree$id, fixture$expected$ids)
  expect_equal(
    as.matrix(fixture$expected$Ainv),
    matrix(
      c(
        2,
        1,
        -1,
        -1,
        0,
        1,
        2,
        -1,
        -1,
        0,
        -1,
        -1,
        2.5,
        0.5,
        -1,
        -1,
        -1,
        0.5,
        2.5,
        -1,
        0,
        0,
        -1,
        -1,
        2
      ),
      nrow = 5,
      byrow = TRUE,
      dimnames = list(fixture$expected$ids, fixture$expected$ids)
    )
  )

  reference <- hsquared:::hs_solve_henderson_mme_reference(
    y = payload$y,
    X = payload$X,
    Z = payload$Z,
    Ainv = fixture$expected$Ainv,
    sigma_a2 = fixture$sigma_a2,
    sigma_e2 = fixture$sigma_e2,
    ids = payload$ids
  )

  expect_equal(
    unname(reference$fixed_effects),
    unname(fixture$expected$fixed_effects),
    tolerance = 1e-12
  )
  expect_equal(
    reference$breeding_values,
    fixture$expected$breeding_values,
    tolerance = 1e-12
  )
  expect_equal(reference$fitted, fixture$expected$fitted, tolerance = 1e-12)
  expect_equal(reference$heritability, fixture$expected$heritability)
})

test_that("Henderson MME fixture matches Julia henderson_mme when available", {
  fixture <- hsquared:::hs_henderson_mme_validation_fixture()
  spec <- hsquared:::hs_build_model_spec(
    fixture$formula,
    data = fixture$data,
    family = stats::gaussian(),
    REML = FALSE
  )
  payload <- hsquared:::hs_build_bridge_payload(spec)

  testthat::skip_if_not(
    hsquared:::hs_julia_bridge_available(),
    "JuliaCall, Julia, and local HSquared.jl are required for live Henderson MME validation."
  )

  hsquared:::hs_julia_setup(hsquared:::hs_default_julia_project())
  hsquared:::hs_julia_assign_payload(
    payload,
    initial = c(
      sigma_a2 = fixture$sigma_a2,
      sigma_e2 = fixture$sigma_e2
    )
  )
  JuliaCall::julia_assign("hsq_mme_sigma_a2", fixture$sigma_a2)
  JuliaCall::julia_assign("hsq_mme_sigma_e2", fixture$sigma_e2)
  JuliaCall::julia_command(paste(
    "hsq_mme_ped = HSquared.normalize_pedigree(hsq_id, hsq_sire, hsq_dam);",
    "hsq_mme_Ainv = HSquared.pedigree_inverse(hsq_mme_ped);",
    "hsq_mme_spec = HSquared.animal_model_spec(",
    "hsq_y, hsq_X, hsq_Z, hsq_mme_Ainv;",
    "ids = hsq_mme_ped.ids, method = :ML);",
    "hsq_mme = HSquared.henderson_mme(",
    "hsq_mme_spec, hsq_mme_sigma_a2, hsq_mme_sigma_e2);",
    "hsq_mme_bv = HSquared.breeding_values(hsq_mme);",
    "hsq_mme_payload = Dict(",
    "\"fixed_effects\" => HSquared.fixed_effects(hsq_mme),",
    "\"animal_ids\" => hsq_mme_bv.ids,",
    "\"animal_effects\" => hsq_mme_bv.values,",
    "\"fitted\" => HSquared.fitted_values(hsq_mme)",
    ");"
  ))

  observed <- JuliaCall::julia_eval("hsq_mme_payload")

  expect_equal(
    as.numeric(observed$fixed_effects),
    unname(fixture$expected$fixed_effects),
    tolerance = 1e-10
  )
  expect_equal(
    as.character(observed$animal_ids),
    fixture$expected$breeding_values$id
  )
  expect_equal(
    as.numeric(observed$animal_effects),
    fixture$expected$breeding_values$value,
    tolerance = 1e-10
  )
  expect_equal(
    as.numeric(observed$fitted),
    fixture$expected$fitted$.fitted,
    tolerance = 1e-10
  )
})

test_that("sparse REML likelihood fixture pins closed-form targets", {
  fixture <- hsquared:::hs_reml_likelihood_validation_fixture()
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
  expect_equal(as.numeric(payload$X), rep(1, 3))
  expect_equal(unname(as.matrix(payload$Z)), fixture$expected$Z)
  expect_equal(fixture$expected$Ainv, diag(3))
  expect_equal(unname(fixture$expected$fixed_effects), 2)
  expect_equal(
    fixture$expected$ml_loglik,
    -0.5 * (3 * log(2 * pi) + 3 * log(2) + 1)
  )
  expect_equal(
    fixture$expected$reml_loglik,
    -0.5 * (2 * log(2 * pi) + 3 * log(2) + log(1.5) + 1)
  )
})

test_that("sparse REML likelihood fixture matches Julia dense REML when available", {
  fixture <- hsquared:::hs_reml_likelihood_validation_fixture()
  spec <- hsquared:::hs_build_model_spec(
    fixture$formula,
    data = fixture$data,
    family = stats::gaussian(),
    REML = TRUE
  )
  payload <- hsquared:::hs_build_bridge_payload(spec)

  testthat::skip_if_not(
    hsquared:::hs_julia_bridge_available(),
    paste(
      "JuliaCall, Julia, and local HSquared.jl are required for live sparse",
      "REML likelihood validation."
    )
  )

  hsquared:::hs_julia_setup(hsquared:::hs_default_julia_project())
  hsquared:::hs_julia_assign_payload(
    payload,
    initial = c(
      sigma_a2 = fixture$sigma_a2,
      sigma_e2 = fixture$sigma_e2
    )
  )
  JuliaCall::julia_assign("hsq_reml_sigma_a2", fixture$sigma_a2)
  JuliaCall::julia_assign("hsq_reml_sigma_e2", fixture$sigma_e2)
  JuliaCall::julia_command(paste(
    "hsq_reml_ped = HSquared.normalize_pedigree(hsq_id, hsq_sire, hsq_dam);",
    "hsq_reml_Ainv = HSquared.pedigree_inverse(hsq_reml_ped);",
    "hsq_reml_spec = HSquared.animal_model_spec(",
    "hsq_y, hsq_X, hsq_Z, hsq_reml_Ainv;",
    "ids = hsq_reml_ped.ids, method = :REML);",
    "hsq_dense_reml = HSquared.gaussian_loglik(",
    "hsq_reml_spec, hsq_reml_sigma_a2, hsq_reml_sigma_e2;",
    "method = :REML);",
    "hsq_sparse_reml = HSquared.sparse_reml_loglik(",
    "hsq_reml_spec, hsq_reml_sigma_a2, hsq_reml_sigma_e2);",
    "hsq_dense_ml = HSquared.gaussian_loglik(",
    "hsq_reml_spec, hsq_reml_sigma_a2, hsq_reml_sigma_e2;",
    "method = :ML);",
    "hsq_reml_payload = Dict(",
    "\"dense_reml_loglik\" => hsq_dense_reml.loglik,",
    "\"sparse_reml_loglik\" => hsq_sparse_reml.loglik,",
    "\"dense_ml_loglik\" => hsq_dense_ml.loglik,",
    "\"dense_beta\" => hsq_dense_reml.beta,",
    "\"sparse_beta\" => hsq_sparse_reml.beta",
    ");"
  ))

  observed <- JuliaCall::julia_eval("hsq_reml_payload")

  expect_equal(
    as.numeric(observed$dense_reml_loglik),
    fixture$expected$reml_loglik,
    tolerance = 1e-10
  )
  expect_equal(
    as.numeric(observed$sparse_reml_loglik),
    as.numeric(observed$dense_reml_loglik),
    tolerance = 1e-10
  )
  expect_equal(
    as.numeric(observed$dense_ml_loglik),
    fixture$expected$ml_loglik,
    tolerance = 1e-10
  )
  expect_equal(
    as.numeric(observed$dense_beta),
    unname(fixture$expected$fixed_effects),
    tolerance = 1e-10
  )
  expect_equal(
    as.numeric(observed$sparse_beta),
    unname(fixture$expected$fixed_effects),
    tolerance = 1e-10
  )
})
