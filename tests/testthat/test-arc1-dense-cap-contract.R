test_that("Arc 1 FA selection refuses an ignored dense-size override", {
  for (policy in c("arc1_v1", "arc1_v2")) {
    control <- list(
      engine = "julia",
      engine_control = list(
        target = "multivariate",
        optimizer_policy = policy,
        rank_selection = "auto",
        max_dense_cells = 100L
      )
    )
    expect_error(
      hs_validate_auto_fa_rank_control(control, "multivariate", list(), list()),
      "does not honour.*max_dense_cells"
    )
  }
})
