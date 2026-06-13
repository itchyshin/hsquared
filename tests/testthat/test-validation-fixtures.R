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

test_that("Mrode-style supplied-variance fixture pins R reference outputs", {
  fixture <- hsquared:::hs_mrode_supplied_variance_validation_fixture()
  spec <- hsquared:::hs_build_model_spec(
    fixture$formula,
    data = fixture$data,
    family = stats::gaussian(),
    REML = FALSE
  )
  payload <- hsquared:::hs_build_bridge_payload(spec)

  expect_equal(fixture$name, "mrode_style_supplied_variance_outputs")
  expect_equal(payload$ids, fixture$expected$ids)
  expect_equal(payload$pedigree$id, fixture$expected$ids)
  expect_equal(as.numeric(payload$X[, 1]), rep(1, 12))
  expect_equal(as.numeric(payload$X[, 2]), fixture$data$x)
  expect_equal(unname(as.matrix(payload$Z)), diag(12))
  expect_equal(fixture$expected$Ainv, t(fixture$expected$Ainv))

  reference <- hsquared:::hs_solve_henderson_mme_reference(
    y = payload$y,
    X = payload$X,
    Z = payload$Z,
    Ainv = fixture$expected$Ainv,
    sigma_a2 = fixture$sigma_a2,
    sigma_e2 = fixture$sigma_e2,
    ids = payload$ids
  )
  ml <- hsquared:::hs_gaussian_loglik_reference(
    y = payload$y,
    X = payload$X,
    Z = payload$Z,
    Ainv = fixture$expected$Ainv,
    sigma_a2 = fixture$sigma_a2,
    sigma_e2 = fixture$sigma_e2,
    method = "ML"
  )
  reml <- hsquared:::hs_gaussian_loglik_reference(
    y = payload$y,
    X = payload$X,
    Z = payload$Z,
    Ainv = fixture$expected$Ainv,
    sigma_a2 = fixture$sigma_a2,
    sigma_e2 = fixture$sigma_e2,
    method = "REML"
  )

  expect_equal(
    reference$fixed_effects,
    fixture$expected$fixed_effects,
    tolerance = 1e-10,
    ignore_attr = TRUE
  )
  expect_equal(
    reference$breeding_values,
    fixture$expected$breeding_values,
    tolerance = 1e-10
  )
  expect_equal(reference$fitted, fixture$expected$fitted, tolerance = 1e-10)
  expect_equal(
    reference$prediction_error_variance,
    fixture$expected$prediction_error_variance,
    tolerance = 1e-10
  )
  expect_equal(
    reference$reliability,
    fixture$expected$reliability,
    tolerance = 1e-10
  )
  expect_equal(reference$heritability, fixture$expected$heritability)
  expect_equal(ml$loglik, fixture$expected$ml_loglik, tolerance = 1e-10)
  expect_equal(reml$loglik, fixture$expected$reml_loglik, tolerance = 1e-10)
  expect_equal(
    reml$beta,
    unname(fixture$expected$fixed_effects),
    tolerance = 1e-10
  )
})

test_that("Mrode-style supplied-variance fixture matches Julia when available", {
  fixture <- hsquared:::hs_mrode_supplied_variance_validation_fixture()
  spec <- hsquared:::hs_build_model_spec(
    fixture$formula,
    data = fixture$data,
    family = stats::gaussian(),
    REML = FALSE
  )
  payload <- hsquared:::hs_build_bridge_payload(spec)

  testthat::skip_if_not(
    hsquared:::hs_julia_bridge_available(),
    paste(
      "JuliaCall, Julia, and local HSquared.jl are required for live",
      "Mrode-style supplied-variance validation."
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
  JuliaCall::julia_assign("hsq_ms_sigma_a2", fixture$sigma_a2)
  JuliaCall::julia_assign("hsq_ms_sigma_e2", fixture$sigma_e2)
  JuliaCall::julia_command(paste(
    "hsq_ms_ped = HSquared.normalize_pedigree(hsq_id, hsq_sire, hsq_dam);",
    "hsq_ms_Ainv = HSquared.pedigree_inverse(hsq_ms_ped);",
    "hsq_ms_spec_ml = HSquared.animal_model_spec(",
    "hsq_y, hsq_X, hsq_Z, hsq_ms_Ainv;",
    "ids = hsq_ms_ped.ids, method = :ML);",
    "hsq_ms_spec_reml = HSquared.animal_model_spec(",
    "hsq_y, hsq_X, hsq_Z, hsq_ms_Ainv;",
    "ids = hsq_ms_ped.ids, method = :REML);",
    "hsq_ms_ml = HSquared.gaussian_loglik(",
    "hsq_ms_spec_ml, hsq_ms_sigma_a2, hsq_ms_sigma_e2;",
    "method = :ML);",
    "hsq_ms_reml = HSquared.gaussian_loglik(",
    "hsq_ms_spec_reml, hsq_ms_sigma_a2, hsq_ms_sigma_e2;",
    "method = :REML);",
    "hsq_ms_sparse_reml = HSquared.sparse_reml_loglik(",
    "hsq_ms_spec_reml, hsq_ms_sigma_a2, hsq_ms_sigma_e2);",
    "hsq_ms_mme = HSquared.henderson_mme(",
    "hsq_ms_spec_ml, hsq_ms_sigma_a2, hsq_ms_sigma_e2);",
    "hsq_ms_bv = HSquared.breeding_values(hsq_ms_mme);",
    "hsq_ms_payload = Dict(",
    "\"ids\" => hsq_ms_ped.ids,",
    "\"Ainv\" => Matrix(hsq_ms_Ainv),",
    "\"ml_loglik\" => hsq_ms_ml.loglik,",
    "\"dense_reml_loglik\" => hsq_ms_reml.loglik,",
    "\"sparse_reml_loglik\" => hsq_ms_sparse_reml.loglik,",
    "\"sparse_beta\" => hsq_ms_sparse_reml.beta,",
    "\"fixed_effects\" => HSquared.fixed_effects(hsq_ms_mme),",
    "\"animal_ids\" => hsq_ms_bv.ids,",
    "\"animal_effects\" => hsq_ms_bv.values,",
    "\"fitted\" => HSquared.fitted_values(hsq_ms_mme),",
    "\"heritability\" => HSquared.heritability(hsq_ms_mme)",
    ");",
    "if isdefined(HSquared, :prediction_error_variance) &&",
    "isdefined(HSquared, :reliability) &&",
    "applicable(HSquared.prediction_error_variance, hsq_ms_mme) &&",
    "applicable(HSquared.reliability, hsq_ms_mme);",
    "hsq_ms_pev = HSquared.prediction_error_variance(hsq_ms_mme);",
    "hsq_ms_rel = HSquared.reliability(hsq_ms_mme);",
    "hsq_ms_payload[\"pev_ids\"] = hsq_ms_pev.ids;",
    "hsq_ms_payload[\"pev\"] = hsq_ms_pev.values;",
    "hsq_ms_payload[\"reliability_ids\"] = hsq_ms_rel.ids;",
    "hsq_ms_payload[\"reliability\"] = hsq_ms_rel.values;",
    "end;"
  ))

  observed <- JuliaCall::julia_eval("hsq_ms_payload")

  expect_equal(as.character(observed$ids), fixture$expected$ids)
  dimnames(observed$Ainv) <- list(fixture$expected$ids, fixture$expected$ids)
  expect_equal(observed$Ainv, fixture$expected$Ainv, tolerance = 1e-10)
  expect_equal(
    as.numeric(observed$fixed_effects),
    unname(fixture$expected$fixed_effects),
    tolerance = 1e-10
  )
  expect_equal(as.character(observed$animal_ids), fixture$expected$ids)
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
  expect_equal(
    as.numeric(observed$ml_loglik),
    fixture$expected$ml_loglik,
    tolerance = 1e-10
  )
  expect_equal(
    as.numeric(observed$dense_reml_loglik),
    fixture$expected$reml_loglik,
    tolerance = 1e-10
  )
  expect_equal(
    as.numeric(observed$sparse_reml_loglik),
    fixture$expected$reml_loglik,
    tolerance = 1e-10
  )
  expect_equal(
    as.numeric(observed$sparse_beta),
    unname(fixture$expected$fixed_effects),
    tolerance = 1e-10
  )
  expect_equal(
    as.numeric(observed$heritability),
    fixture$expected$heritability,
    tolerance = 1e-12
  )

  if (!is.null(observed$pev) && !is.null(observed$reliability)) {
    expect_equal(as.character(observed$pev_ids), fixture$expected$ids)
    expect_equal(as.character(observed$reliability_ids), fixture$expected$ids)
    expect_equal(
      as.numeric(observed$pev),
      fixture$expected$prediction_error_variance$value,
      tolerance = 1e-10
    )
    expect_equal(
      as.numeric(observed$reliability),
      fixture$expected$reliability$value,
      tolerance = 1e-10
    )
  }
})

test_that("sparse REML optimizer reaches the same REML optimum from different starts", {
  testthat::skip_on_cran()
  testthat::skip_if_not(
    hsquared:::hs_julia_bridge_available(),
    "JuliaCall, Julia, and local HSquared.jl are required for live sparse REML estimate-recovery validation."
  )

  fixture <- hsquared:::hs_mrode_supplied_variance_validation_fixture()
  fit_from <- function(init) {
    hsquared(
      fixture$formula,
      data = fixture$data,
      family = stats::gaussian(),
      REML = TRUE,
      control = hs_control(
        engine = "julia",
        engine_control = list(
          target = "sparse_reml",
          initial = init,
          iterations = 1000L
        )
      )
    )
  }

  # Estimate-recovery discipline (see 04-validation-canon comparator rule): the
  # REML objective optimum is start-independent. This validates the experimental
  # optimizer, NOT data-generating recovery, supplied-truth recovery, or ASReml
  # parity. Both fits optimize the SAME estimand (the REML objective).
  fit_a <- fit_from(c(sigma_a2 = 0.5, sigma_e2 = 0.5))
  fit_b <- fit_from(c(sigma_a2 = 3.0, sigma_e2 = 1.5))

  la <- fit_a$result$loglik
  lb <- fit_b$result$loglik
  expect_true(is.finite(la) && is.finite(lb))
  # Same REML optimum from different starts (loglik is flat near the optimum, so
  # compare it tightly and the variance estimates a little more loosely).
  expect_equal(la, lb, tolerance = 1e-3)
  expect_equal(
    variance_components(fit_a)$estimate,
    variance_components(fit_b)$estimate,
    tolerance = 1e-2
  )
  expect_true(all(variance_components(fit_a)$estimate > 0))
  expect_equal(
    fit_diagnostics(fit_a)$value[
      fit_diagnostics(fit_a)$metric == "variance_components_source"
    ],
    "estimated_sparse_reml"
  )
})
