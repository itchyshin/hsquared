hs_arc1_require_live <- function() {
  identical(tolower(Sys.getenv("HSQUARED_ARC1_REQUIRE_LIVE", "false")), "true")
}

test_that("required live arc1_v1 selection retains engine identity and attempt status", {
  if (!hs_arc1_require_live()) {
    skip(
      "Set HSQUARED_ARC1_REQUIRE_LIVE=true for required Arc1 live acceptance."
    )
  }
  if (
    !requireNamespace("JuliaCall", quietly = TRUE) ||
      !isTRUE(hsquared:::hs_julia_bridge_available())
  ) {
    stop(
      "HSQUARED_ARC1_REQUIRE_LIVE=true but JuliaCall, Julia, or the configured HSquared.jl project is unavailable."
    )
  }
  project <- Sys.getenv(
    "HSQUARED_JULIA_PROJECT",
    unset = hsquared:::hs_default_julia_project()
  )
  fixture <- utils::read.delim(
    testthat::test_path("fixtures", "auto_fa_rank", "ordinary_start.tsv"),
    stringsAsFactors = FALSE
  )
  ped <- fixture[c("id", "sire", "dam")]
  ped$sire[ped$sire == 0] <- NA
  ped$dam[ped$dam == 0] <- NA
  dat <- data.frame(
    id = fixture$id,
    t1 = fixture$y1,
    t2 = fixture$y2,
    t3 = fixture$y3,
    t4 = fixture$y4
  )
  fit <- hsquared(
    cbind(t1, t2, t3, t4) ~ animal(1 | id, pedigree = ped),
    data = dat,
    control = hs_control(
      engine = "julia",
      engine_control = list(
        target = "multivariate",
        rank_selection = "auto",
        optimizer_policy = "arc1_v1"
      )
    )
  )
  expect_s3_class(fit, "hsquared_fa_rank_selection")
  expect_identical(fit$optimizer_policy, "arc1_v1")
  expect_identical(fit$optimizer_policy_version, 1L)
  expect_true(is.character(fit$source_identity) && nzchar(fit$source_identity))
  expect_equal(fit$q, c(14L, 18L))
  expect_equal(fit$penalties, c(28, 36))
  expect_true(
    fit$selection_status %in% c("selected", "unavailable", "interrupted")
  )
  expect_true(all(c("attempted", "status", "reason") %in% names(fit$attempts)))
  expect_true(
    any(fit$attempts$attempted) || fit$selection_status == "interrupted"
  )
  expect_true(all(
    fit$attempts$status %in%
      c(
        "completed",
        "eligible",
        "failed",
        "interrupted",
        "unattempted",
        "running",
        "selected",
        "ineligible"
      )
  ))
  expect_equal(fit$starts_attempted, sum(fit$attempts$attempted, na.rm = TRUE))

  fixed <- tryCatch(
    hsquared(
      cbind(t1, t2, t3, t4) ~ animal(1 | id, pedigree = ped),
      data = dat,
      control = hs_control(
        engine = "julia",
        engine_control = list(
          target = "multivariate",
          genetic_structure = "factor_analytic",
          rank = 1L,
          optimizer_policy = "arc1_v1",
          julia_project = project
        )
      )
    ),
    error = identity
  )
  if (inherits(fixed, "error")) {
    expect_match(conditionMessage(fixed), "arc1_v1|optimizer|gradient|eligible")
  } else {
    expect_s3_class(fixed, "hsquared_fit")
    fixed_diagnostics <- fit_diagnostics(fixed)
    expect_true(any(fixed_diagnostics$metric == "optimizer_policy"))
    expect_true(any(fixed_diagnostics$metric == "source_identity"))
    expect_true(any(fixed_diagnostics$metric == "optimizer_attempts"))
  }

  JuliaCall::julia_command(paste(
    "hsq_arc1_matrix_refusal = HSquared.select_fa_rank(hsq_Y, hsq_X, hsq_Z,",
    "HSquared.pedigree_inverse(hsq_ped); optimizer_policy = \"arc1_v1\");"
  ))
  expect_identical(
    as.character(JuliaCall::julia_eval(
      "hsq_arc1_matrix_refusal.selection_status"
    )),
    "unsupported_input"
  )
  expect_match(
    as.character(JuliaCall::julia_eval(
      "hsq_arc1_matrix_refusal.reason"
    )),
    "validated Pedigree"
  )

  spec <- hsquared:::hs_build_model_spec(
    cbind(t1, t2, t3, t4) ~ animal(1 | id, pedigree = ped),
    dat,
    family = stats::gaussian(),
    REML = TRUE
  )
  payload <- hsquared:::hs_build_bridge_payload(spec)
  ledger_name <- "hsq_arc1_required_live_ledger"
  JuliaCall::julia_command(paste0(ledger_name, " = Ref{Any}(hsq_selection);"))
  on.exit(
    try(
      JuliaCall::julia_command(paste0(ledger_name, "[] = nothing;")),
      silent = TRUE
    ),
    add = TRUE
  )
  interrupted <- tryCatch(
    hsquared:::hs_julia_run_fa_rank_command(
      "throw(InterruptException())",
      ledger_name,
      runner = function(command) JuliaCall::julia_command(command),
      ledger_reader = function() {
        hsquared:::hs_julia_read_fa_rank_partial_ledger(ledger_name, payload)
      }
    ),
    interrupt = identity,
    error = identity
  )
  expect_s3_class(interrupted, "hsquared_fa_rank_interrupt")
  expect_identical(
    interrupted$partial_ledger$source_identity,
    fit$source_identity
  )
})
