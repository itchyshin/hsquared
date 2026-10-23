# Input guards of the Henderson MME reference solvers and the Mrode9 fixture
# loader. Messages are asserted by fragment so wording tweaks stay cheap.

hs_solver_inputs <- function() {
  list(
    y = c(1, 2, 3),
    X = matrix(1, 3, 1),
    Z = diag(3),
    Ainv = diag(3),
    ids = c("a", "b", "c")
  )
}

hs_call_univariate_solver <- function(..., overrides = list()) {
  args <- utils::modifyList(
    c(
      hs_solver_inputs(),
      list(sigma_a2 = 1, sigma_e2 = 1)
    ),
    overrides
  )
  do.call(hsquared:::hs_solve_henderson_mme_reference, args)
}

test_that("univariate Henderson reference solver rejects bad inputs", {
  expect_error(
    hs_call_univariate_solver(overrides = list(y = c("a", "b", "c"))),
    "must be numeric"
  )
  for (bad in list(0, -1, c(1, 2), "1")) {
    expect_error(
      hs_call_univariate_solver(overrides = list(sigma_a2 = bad)),
      "`sigma_a2` must be a positive number"
    )
    expect_error(
      hs_call_univariate_solver(overrides = list(sigma_e2 = bad)),
      "`sigma_e2` must be a positive number"
    )
  }
})

hs_mv_solver_inputs <- function() {
  list(
    Y = cbind(c(1, 2, 3), c(2, 1, 4)),
    sex = c("f", "m", "f"),
    animal = c("a", "b", "c"),
    ids = c("a", "b", "c"),
    Ainv = diag(3),
    G0 = diag(2),
    R0 = diag(2)
  )
}

hs_call_mv_solver <- function(overrides = list()) {
  args <- utils::modifyList(hs_mv_solver_inputs(), overrides)
  do.call(hsquared:::hs_solve_multivariate_henderson_mme_reference, args)
}

test_that("multivariate Henderson reference solver rejects bad inputs", {
  expect_error(
    hs_call_mv_solver(list(Y = cbind(c("a", "b", "c"), c("d", "e", "f")))),
    "`Y` must be numeric"
  )
  expect_error(
    hs_call_mv_solver(list(sex = c("f", "m"))),
    "same record count"
  )
  expect_error(
    hs_call_mv_solver(list(animal = c("a", "b"))),
    "same record count"
  )
  expect_error(
    hs_call_mv_solver(list(G0 = diag(3))),
    "square trait covariance"
  )
  expect_error(
    hs_call_mv_solver(list(R0 = diag(3))),
    "square residual covariance"
  )
  expect_error(
    hs_call_mv_solver(list(animal = c("a", "b", "zzz"))),
    "values must appear in"
  )
})

test_that("Mrode9 fixture loader names the missing optional package", {
  testthat::local_mocked_bindings(
    requireNamespace = function(package, ...) FALSE,
    .package = "base"
  )
  expect_error(
    hsquared:::hs_mrode9_pedigree_validation_fixture(),
    "optional `nadiv` package is required"
  )
})
