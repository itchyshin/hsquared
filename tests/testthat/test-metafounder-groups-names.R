test_that("metafounder_groups() falls back to names(group_of) when ids are absent", {
  fit <- hsquared:::hs_new_fit(
    call = quote(hsquared()),
    spec = list(),
    payload = list(group_of = c(a = "M1", b = "", c = "M2")),
    result = list()
  )

  expect_equal(
    metafounder_groups(fit),
    data.frame(
      id = c("a", "b", "c"),
      metafounder_group = c("M1", NA, "M2"),
      is_metafounder = c(TRUE, FALSE, TRUE),
      stringsAsFactors = FALSE
    )
  )
})
