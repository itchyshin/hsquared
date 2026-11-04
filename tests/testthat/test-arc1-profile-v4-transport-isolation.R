test_that("profile target diagnostics are detached from later Julia calls", {
  project <- Sys.getenv("HSQUARED_JULIA_PROJECT", unset = "")
  if (!nzchar(project) || !dir.exists(project) ||
      !hs_julia_bridge_available(project)) {
    skip("A local JuliaCall engine is required for this transport regression.")
  }

  hs_julia_setup(project)
  JuliaCall::julia_command(paste(
    hs_julia_arc1_plain_command(),
    paste(
      "hsq_arc1_transport_wire = hsq_arc1_plain((diagnostic=(",
      "source_id=(\"raw_observation\", \"residual_variance\",",
      "0.578, 1734), status=:ok),));"
    )
  ))
  raw <- JuliaCall::julia_eval("hsq_arc1_transport_wire")
  target_details <- hs_arc1_materialize_target_details(raw)
  JuliaCall::julia_eval("hsq_arc1_plain(hsq_arc1_transport_wire)")

  expect_identical(
    target_details$diagnostic$source_id[[1]], "raw_observation"
  )
  expect_identical(
    target_details$diagnostic$source_id[[2]], "residual_variance"
  )
  expect_identical(target_details$diagnostic$status, "ok")
})
