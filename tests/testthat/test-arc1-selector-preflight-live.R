test_that("Julia selector refusals cross the bridge before any fit", {
  project <- Sys.getenv("HSQUARED_JULIA_PROJECT", unset = "")
  if (
    !nzchar(project) ||
      !dir.exists(project) ||
      !hs_julia_bridge_available(project)
  ) {
    skip("A local JuliaCall engine is required for this transport regression.")
  }

  payload <- structure(
    list(
      Y = matrix(c(1, 2, 3, 4), 2, 2, dimnames = list(NULL, c("t1", "t2"))),
      X = matrix(1, 2, 1),
      Z = as(as(Matrix::Diagonal(2), "generalMatrix"), "CsparseMatrix"),
      ids = c("a", "b"),
      pedigree = list(id = c("a", "b"), sire = c(NA, NA), dam = c(NA, NA)),
      metadata = list(trait_names = c("t1", "t2"))
    ),
    class = "hs_bridge_payload"
  )
  for (policy in c("arc1_v1", "arc1_v2")) {
    result <- hs_fit_julia_fa_rank_selection_payload(
      payload,
      project = project,
      optimizer_policy = policy
    )
    expect_identical(result$selection_status, "unsupported_input")
    expect_match(result$reason, "requires four traits")
    expect_equal(nrow(result$attempts), 0L)
  }
  traits <- paste0("t", 1:4)
  payload$Y <- matrix(1:8, 2, 4, dimnames = list(NULL, traits))
  payload$metadata$trait_names <- traits
  bootstrap <- hs_fit_julia_fa_rank_selection_payload(
    payload,
    project = project,
    optimizer_policy = "arc1_v1",
    uncertainty = list(method = "arc1_bootstrap_v1", B = 1L, seeds = "1")
  )
  expect_identical(bootstrap$selection_status, "unsupported_input")
  expect_identical(
    bootstrap$arc1_uncertainty$status,
    "insufficient_usable_bootstrap"
  )
  expect_identical(bootstrap$arc1_uncertainty$formed, FALSE)
  expect_equal(bootstrap$arc1_uncertainty$usable_bootstrap_count, 0L)
  expect_length(bootstrap$arc1_uncertainty$attempts, 1L)
  expect_identical(
    bootstrap$arc1_uncertainty$attempts[[1]]$status,
    "not_run_after_outer_selection_failure"
  )
  cat("ARC1_SELECTOR_PREFLIGHT_TRANSPORT_COMPLETE\n")
})
