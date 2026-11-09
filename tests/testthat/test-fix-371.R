# Issue #371: REML = FALSE guard must apply for any hsquared() call form on
# engine = "validate" (bare, namespace-qualified, do.call).

hs_371_ped <- function() {
  data.frame(
    id = c("a", "b", "c"),
    sire = c(NA, NA, "a"),
    dam = c(NA, NA, "b")
  )
}

hs_371_dat <- function() {
  data.frame(
    y = c(1, 2, 3),
    sex = c("m", "f", "m"),
    id = c("a", "b", "c")
  )
}

hs_371_call_list <- function() {
  ped <- hs_371_ped()
  list(
    formula = y ~ sex + animal(1 | id, pedigree = ped),
    data = hs_371_dat(),
    family = stats::gaussian(),
    REML = FALSE,
    control = hs_control(engine = "validate")
  )
}

expect_validate_reml_false_rejected <- function(expr) {
  err <- expect_error(
    force(expr),
    class = "hsquared_unsupported_syntax"
  )
  msg <- conditionMessage(err)
  expect_match(msg, "Closest working call: `REML = TRUE`", fixed = TRUE)
}

test_that("engine = validate rejects REML = FALSE on a bare hsquared() call (#371)", {
  cl <- hs_371_call_list()
  expect_validate_reml_false_rejected(
    hsquared(
      formula = cl$formula,
      data = cl$data,
      family = cl$family,
      REML = cl$REML,
      control = cl$control
    )
  )
})

test_that("engine = validate rejects REML = FALSE via hsquared::hsquared() (#371)", {
  cl <- hs_371_call_list()
  expect_validate_reml_false_rejected(
    hsquared::hsquared(
      formula = cl$formula,
      data = cl$data,
      family = cl$family,
      REML = cl$REML,
      control = cl$control
    )
  )
})

test_that("engine = validate rejects REML = FALSE via do.call(hsquared, ...) (#371)", {
  cl <- hs_371_call_list()
  expect_validate_reml_false_rejected(
    do.call(hsquared, cl)
  )
})
