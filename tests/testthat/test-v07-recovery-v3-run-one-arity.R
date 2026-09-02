# Regression guard for the driver <-> preseal arity contract on the run-one path.
#
# tools/v07_genomic_recovery_v3.R::v3d_validate_attempt() forwards a single
# generated attempt to v3p_validate_results() (defined in the preseal library).
# The route-repair commit (b8096e5) made v3p_validate_results()'s `expected_route`
# a REQUIRED argument, but this run-one call site kept passing only 5 arguments,
# so every official `run-one` fit aborted with
#   "argument 'expected_route' is missing, with no default".
# No synthetic-lifecycle, preflight, or D0F-tail test drives v3d_validate_attempt(),
# which is why the defect survived. This test exercises exactly that call so the
# driver <-> preseal arity contract for run-one stays green.

driver_tool <- testthat::test_path(
  "..", "..", "tools", "v07_genomic_recovery_v3.R"
)
testthat::skip_if_not(
  file.exists(driver_tool),
  "repository-only recovery-v3 driver is unavailable"
)

# Source the driver into a private environment. The driver self-guards main()
# behind `if (sys.nframe() == 0L)` and sources the preseal library itself, so
# this loads v3d_validate_attempt(), the v3d_route constant, and the v3p_*
# validators without running any official work or consuming an official seed.
v3o_env <- new.env(parent = globalenv())
source(normalizePath(driver_tool, mustWork = TRUE), local = v3o_env)

v3o_test_hash <- function(letter, n = 64L) paste(rep(letter, n), collapse = "")

# Minimal attempt binding, mirroring the recompute test's v3r_test_route_binding()
# (kept local so this file is self-contained and does not source another test).
v3o_test_binding <- function() {
  list(
    preseal_sha256 = v3o_test_hash("e"),
    manifest_sha256 = v3o_test_hash("f"),
    corpus_lock_sha256 = v3o_test_hash("a"),
    r_auto_route_commit = v3o_test_hash("a", 40L),
    julia_candidate_commit = v3o_test_hash("b", 40L),
    r_driver_commit = v3o_test_hash("c", 40L),
    julia_replay_commit = v3o_test_hash("d", 40L),
    julia_replay_sha256 = v3o_test_hash("b")
  )
}

test_that("v3d_validate_attempt forwards expected_route on the run-one path", {
  binding <- v3o_test_binding()

  # The parity fixture yields admitted, row-aligned D0F attempts on the official
  # ordinary_auto_genomic route -- the same single-attempt shape v3d_fit_one
  # emits (route = v3d_route). Take one admitted attempt row and its manifest row.
  base <- v3o_env$v3p_d0f_summary_parity_fixture(binding)
  attempt_row <- base$attempts[1L, , drop = FALSE]
  manifest_row <- base$manifest[1L, , drop = FALSE]

  # The official attempt route equals the driver's route constant, so
  # expected_route = v3d_route is the correct value to forward.
  expect_identical(v3o_env$v3d_route, "ordinary_auto_genomic")
  expect_identical(as.character(attempt_row$route), v3o_env$v3d_route)

  # Before the fix this aborted with
  # "argument 'expected_route' is missing, with no default".
  expect_no_error(
    v3o_env$v3d_validate_attempt(attempt_row, manifest_row, "d0f", binding)
  )
})
