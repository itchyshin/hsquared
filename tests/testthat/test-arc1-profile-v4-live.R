hs_arc1_canonical_named_lists <- function(x) {
  if (!is.list(x) || is.data.frame(x)) {
    nms <- names(x)
    if (!is.null(nms) && length(nms) == length(x) && all(nzchar(nms))) {
      x <- x[order(nms)]
    }
    return(x)
  }
  x <- lapply(x, hs_arc1_canonical_named_lists)
  nms <- names(x)
  if (!is.null(nms) && length(nms) == length(x) && all(nzchar(nms))) {
    x <- x[order(nms)]
  }
  x
}

test_that("Arc 1 bridge comparisons preserve names while ignoring Dict order", {
  left <- list(alpha = list(counts = c(a = 2L, b = 4L)),
               beta = list(status = "ok"))
  right <- list(beta = list(status = "ok"),
                alpha = list(counts = c(b = 4L, a = 2L)))
  expect_identical(hs_arc1_canonical_named_lists(left),
                   hs_arc1_canonical_named_lists(right))
  right$alpha$counts[["a"]] <- 3L
  expect_false(identical(hs_arc1_canonical_named_lists(left),
                         hs_arc1_canonical_named_lists(right)))
})

test_that("Arc 1 bridge progress markers are opt-in", {
  old <- Sys.getenv("HSQUARED_ARC1_DEBUG_PROGRESS", unset = NA_character_)
  on.exit(if (is.na(old)) {
    Sys.unsetenv("HSQUARED_ARC1_DEBUG_PROGRESS")
  } else {
    Sys.setenv(HSQUARED_ARC1_DEBUG_PROGRESS = old)
  })
  Sys.setenv(HSQUARED_ARC1_DEBUG_PROGRESS = "true")
  expect_message(
    hs_arc1_debug_progress("profile-evidence-materialize-start"),
    "profile-evidence-materialize-start"
  )
  expect_message(
    hs_arc1_debug_progress("profile-evidence-validate-start"),
    "profile-evidence-validate-start"
  )
})

test_that("Arc 1 plain transport recursively converts nested Julia Dicts", {
  project <- Sys.getenv("HSQUARED_JULIA_PROJECT", unset = "")
  if (!nzchar(project) || !dir.exists(project) ||
      !hs_julia_bridge_available(project)) {
    skip("A local JuliaCall engine is required for this transport regression.")
  }
  hs_julia_setup(project)
  JuliaCall::julia_command(paste(
    hs_julia_arc1_plain_command(),
    paste(
      "hsq_arc1_nested_wire = hsq_arc1_plain((nuisance_statuses=[",
      "(counts=Dict(\"unresolved\"=>2),",
      "examples=Dict(\"near\"=>((status=:ok, count=1),)), omitted=0)],",
      "diagnostic=(upper_bound=BigFloat(\"1.25\"),",
      "profile_diagnostics=Any[(value=0.5, loglik=-2.0, status=:ok,",
      "nuisance=[(optimizer_status=:ok, gradient_norm=1e-8,)])])));"
    )
  ))
  nested <- JuliaCall::julia_eval("hsq_arc1_nested_wire")
  restored <- hs_arc1_plain_to_list(nested)
  expect_identical(restored$nuisance_statuses[[1]]$counts$unresolved, 2L)
  expect_identical(restored$nuisance_statuses[[1]]$examples$near[[1]]$status, "ok")
  diagnostic <- restored$diagnostic
  expect_identical(diagnostic$upper_bound, 1.25)
  profile_rows <- diagnostic$profile_diagnostics
  expect_identical(profile_rows[[1]]$nuisance[[1]]$optimizer_status, "ok")

  JuliaCall::julia_command(paste(
    hs_julia_arc1_plain_command(),
    "hsq_arc1_rational_wire = hsq_arc1_plain(Dict(\"exact_ratio\" =>",
    "Rational{BigInt}(big(900719925474099312345), big(7))));"
  ))
  exact_ratio <- hs_arc1_plain_to_list(
    JuliaCall::julia_eval("hsq_arc1_rational_wire")
  )$exact_ratio$`__arc1_rational__`
  expect_identical(exact_ratio$numerator, "900719925474099312345")
  expect_identical(exact_ratio$denominator, "7")
  expect_identical(exact_ratio$type, "Rational{BigInt}")

  JuliaCall::julia_command(paste(
    "hsq_arc1_unsupported_wire = Dict(\"diagnostic\" =>",
    "Dict(\"unsupported_regex\" => r\"not-transportable\"));"
  ))
  unsupported <- JuliaCall::julia_eval("hsq_arc1_unsupported_wire")
  expect_error(
    hs_arc1_plain_to_list(unsupported),
    "path.*diagnostic.*unsupported_regex.*JuliaObject.*Regex"
  )
})

test_that("Arc 1 v4 evidence transport materializes a verified alias once", {
  project <- Sys.getenv("HSQUARED_JULIA_PROJECT", unset = "")
  if (!nzchar(project) || !dir.exists(project) ||
      !hs_julia_bridge_available(project)) {
    skip("A local JuliaCall engine is required for this transport regression.")
  }
  hs_julia_setup(project)
  JuliaCall::julia_command(hs_julia_arc1_plain_command())
  JuliaCall::julia_command(paste(
    "history=Any[]; for i in 1:256;",
    "counts=Dict(:valid=>i, :rejected=>2*i);",
    "diagnostic=Dict(:counts=>counts, :profile=>collect(1:64));",
    "event=Dict(:status=>:ok, :iteration=>i, :diagnostic=>diagnostic);",
    "push!(history, Dict(:target=>:heritability, :events=>Any[event]));",
    "end;",
    "hsq_arc1_v4_sink = Dict{Symbol,Any}(",
    ":requested_method_version => \"arc1_profile_v4\",",
    ":actual_method_version => \"arc1_profile_v4\",",
    ":arc1_profile_v3_evaluations => history,",
    ":arc1_profile_v4_evaluations => history);"
  ))
  baseline <- hs_arc1_plain_to_list(
    JuliaCall::julia_eval("hsq_arc1_plain(hsq_arc1_v4_sink)")
  )
  expression <- hs_julia_arc1_v4_evidence_projection_expression(
    "hsq_arc1_v4_sink"
  )
  projection <- hs_arc1_plain_to_list(
    JuliaCall::julia_eval(paste0("hsq_arc1_plain(", expression, ")"))
  )
  expect_true(projection$v4_alias_verified)
  expect_false("arc1_profile_v4_evaluations" %in% names(projection$evidence))

  evidence <- hs_arc1_materialize_profile_evidence_projection(projection)
  expect_identical(
    evidence$arc1_profile_v4_evaluations,
    evidence$arc1_profile_v3_evaluations
  )
  expect_length(evidence$arc1_profile_v4_evaluations, 256L)
  expect_identical(
    evidence$arc1_profile_v4_evaluations[[256L]]$events[[1L]]$diagnostic$counts$rejected,
    512L
  )
  comparable <- evidence
  attr(comparable, "hs_arc1_verified_bridge_alias") <- NULL
  expect_identical(
    hs_arc1_canonical_named_lists(comparable),
    hs_arc1_canonical_named_lists(baseline)
  )
  expect_identical(
    hs_arc1_validate_profile_evidence(
      evidence,
      "arc1_profile_v4",
      verified_bridge_alias = TRUE
    ),
    evidence
  )

  JuliaCall::julia_command(paste(
    "hsq_arc1_v4_distinct_aliases = Dict{Symbol,Any}(",
    ":requested_method_version=>\"arc1_profile_v4\",",
    ":actual_method_version=>\"arc1_profile_v4\",",
    ":arc1_profile_v3_evaluations=>Any[Dict(:status=>:ok)],",
    ":arc1_profile_v4_evaluations=>Any[Dict(:status=>:ok)]);"
  ))
  distinct_projection <- hs_arc1_plain_to_list(JuliaCall::julia_eval(
    paste0(
      "hsq_arc1_plain(",
      hs_julia_arc1_v4_evidence_projection_expression(
        "hsq_arc1_v4_distinct_aliases"
      ),
      ")"
    )
  ))
  expect_false(distinct_projection$v4_alias_verified)
  distinct_evidence <- hs_arc1_materialize_profile_evidence_projection(
    distinct_projection
  )
  expect_setequal(names(distinct_evidence), c(
    "actual_method_version", "arc1_profile_v3_evaluations",
    "arc1_profile_v4_evaluations", "requested_method_version"
  ))
  expect_identical(
    hs_arc1_validate_profile_evidence(
      distinct_evidence, "arc1_profile_v4"
    ),
    distinct_evidence
  )
})

test_that("Arc1 profile v4 requests an evidence sink and retains target proof fields", {
  expect_identical(
    hs_julia_arc1_profile_method_argument(
      "arc1_profile_v4",
      v3_evidence_sink = "hsq_arc1_v4_evidence_sink"
    ),
    'method="arc1_profile_v4", v3_evidence_sink=hsq_arc1_v4_evidence_sink'
  )
  command <- hs_julia_arc1_profile_targets_command("arc1_profile_v4")
  for (field in c(
    "certificate", "determinant", "precision", "rounding",
    "design_identity", "convention", "profile_diagnostics", "examples"
  )) {
    expect_match(command, field, fixed = TRUE)
  }
})

test_that("Arc1 profile v4 interruption retains versioned refusal evidence", {
  evidence <- list(
    requested_method_version = "arc1_profile_v4",
    actual_method_version = "arc1_profile_v4",
    source_identity = "source-v4",
    arc1_profile_v4_evaluations = list(list(
      status = "unresolved_shared_competitor",
      tail_certificate = list(
        certified = TRUE, determinant = list(numerator = "5", denominator = "2"),
        precision = 256L, rounding = "directed_mpfr", design_identity = "design-v4"
      )
    ))
  )
  caught <- tryCatch(
    hs_arc1_capture_v3_profile_error(
      stop("retained refusal"),
      "arc1_profile_v4",
      function() evidence
    ),
    error = identity
  )
  expect_s3_class(caught, "error")
  expect_identical(conditionMessage(caught), "retained refusal")
  expect_identical(attr(caught, "arc1_profile_method_requested"), "arc1_profile_v4")
  expect_identical(attr(caught, "arc1_profile_method_actual"), "arc1_profile_v4")
  expect_identical(attr(caught, "arc1_profile_source_identity"), "source-v4")
  expect_identical(attr(caught, "arc1_profile_evidence"), evidence)
  expect_true(attr(caught, "arc1_profile_evidence_partial"))
})

test_that("Arc1 profile evidence rejects cross-method metadata", {
  v3 <- list(
    requested_method_version = "arc1_profile_v3",
    actual_method_version = "arc1_profile_v3",
    arc1_profile_v3_evaluations = list(list(status = "refused"))
  )
  expect_identical(
    hs_arc1_validate_profile_evidence(v3, "arc1_profile_v3"),
    v3
  )
  v4 <- list(
    requested_method_version = "arc1_profile_v4",
    actual_method_version = "arc1_profile_v4",
    arc1_profile_v3_evaluations = list(list(status = "refused")),
    arc1_profile_v4_evaluations = list(list(status = "refused"))
  )
  expect_identical(
    hs_arc1_validate_profile_evidence(v4, "arc1_profile_v4"),
    v4
  )
  conflicting_alias <- v4
  conflicting_alias$arc1_profile_v4_evaluations <- list(list(status = "different"))
  expect_error(
    hs_arc1_validate_profile_evidence(
      conflicting_alias, "arc1_profile_v4"
    ),
    "conflicting evaluation history"
  )
  bad_version <- v4
  bad_version$actual_method_version <- "arc1_profile_v3"
  expect_error(
    hs_arc1_validate_profile_evidence(bad_version, "arc1_profile_v4"),
    "method identity"
  )
  bad_key <- v3
  bad_key$arc1_profile_v4_evaluations <- bad_key$arc1_profile_v3_evaluations
  expect_error(
    hs_arc1_validate_profile_evidence(bad_key, "arc1_profile_v3"),
    "cross-method"
  )
})

test_that("required live Arc1 profile v4 preserves Julia identity and interval parity", {
  if (!identical(tolower(Sys.getenv("HSQUARED_ARC1_REQUIRE_LIVE", "false")), "true")) {
    skip("Set HSQUARED_ARC1_REQUIRE_LIVE=true for required Arc1 live acceptance.")
  }
  project <- Sys.getenv("HSQUARED_JULIA_PROJECT", "")
  if (!nzchar(project) || !dir.exists(project) ||
      !requireNamespace("JuliaCall", quietly = TRUE) ||
      !isTRUE(hsquared:::hs_julia_bridge_available(project))) {
    stop("Required live v4 test needs JuliaCall, Julia, and a configured HSquared.jl project.")
  }
  hsquared:::hs_julia_setup(project)
  ids <- paste0("a", 1:6)
  ped <- data.frame(
    id = ids,
    sire = c(NA, NA, "a1", "a1", "a2", "a2"),
    dam = c(NA, NA, NA, NA, NA, NA),
    stringsAsFactors = FALSE
  )
  dat <- data.frame(
    id = rep(ids, each = 2),
    y = c(1.1, 1.4, 0.7, 1.0, 1.8, 1.5, 0.3, 0.8, 2.0, 1.6, 1.2, 1.7)
  )
  fit <- hsquared(
    y ~ animal(1 | id, pedigree = ped) + permanent(1 | id),
    data = dat,
    control = hs_control(engine = "julia", engine_control = list(
      target = "repeatability", scale_method = "dense",
      uncertainty_method = "arc1_profile_v4"
    ))
  )
  uncertainty <- fit$result$arc1_uncertainty
  expect_s3_class(fit, "hsquared_fit")
  expect_identical(uncertainty$method, "arc1_profile_v4")
  expect_identical(uncertainty$method_version, "arc1_profile_v4")

  direct_identity <- JuliaCall::julia_eval(paste(
    "Dict(\"method\"=>string(hsq_arc1.method),",
    "\"method_version\"=>string(hsq_arc1.method_version),",
    "\"point_identity\"=>something(get(hsq_arc1,:point_identity,nothing),\"\"),",
    "\"source_identity\"=>hsq_arc1.source_identity,",
    "\"reference_source_identity\"=>hsq_arc1.reference_source_identity)"
  ))
  expect_identical(uncertainty$method, as.character(direct_identity$method))
  expect_identical(uncertainty$method_version, as.character(direct_identity$method_version))
  expect_identical(uncertainty$point_identity, as.character(direct_identity$point_identity))
  expect_identical(uncertainty$source_identity, as.character(direct_identity$source_identity))
  expect_identical(uncertainty$reference_source_identity,
                   as.character(direct_identity$reference_source_identity))
  expect_identical(uncertainty$profile_evidence$actual_method_version,
                   "arc1_profile_v4")
  expect_true("arc1_profile_v4_evaluations" %in% names(uncertainty$profile_evidence))
  expect_null(uncertainty$v3_profile_evidence)

  direct_targets <- hs_arc1_materialize_target_details(
    JuliaCall::julia_eval("hsq_arc1_plain(hsq_arc1_targets_r)"),
    converter = hs_arc1_plain_to_list
  )
  # Julia Dict iteration order is not a value-level contract. Canonicalize only
  # named lists, preserving unnamed tuple order, classes, and every value.
  expect_identical(
    hs_arc1_canonical_named_lists(uncertainty$target_details),
    hs_arc1_canonical_named_lists(direct_targets)
  )
  expect_identical(uncertainty$profile_evidence$requested_method_version,
                   "arc1_profile_v4")
  expect_identical(uncertainty$profile_evidence$actual_method_version,
                   as.character(direct_identity$method_version))
  expect_identical(uncertainty$profile_evidence$source_identity,
                   as.character(direct_identity$source_identity))
  expect_identical(uncertainty$profile_evidence$arc1_profile_v3_evaluations,
                   uncertainty$profile_evidence$arc1_profile_v4_evaluations)
  expect_true(length(uncertainty$profile_evidence$arc1_profile_v4_evaluations) > 0L)

  expect_true(length(uncertainty$target_details) > 0L)
  for (target in uncertainty$target_details) {
    expect_true(all(c("profile_diagnostics", "nuisance_statuses", "tail_screen") %in%
                      names(target)))
    expect_true(all(vapply(
      target$nuisance_statuses,
      function(status) "examples" %in% names(status),
      logical(1)
    )))
    tail <- target$tail_screen
    if (is.list(tail) && identical(tail$method, "uniform_residual_tail_bound")) {
      expect_true(is.list(tail$certificate))
      expect_true(all(c(
        "determinant", "precision", "rounding", "design_identity", "convention"
      ) %in% names(tail$certificate)))
      if (tail$certificate$status %in% c("excluded_tail", "bound_not_separating")) {
        expect_true(is.list(tail$certificate$determinant))
        expect_true(all(c("numerator", "denominator") %in%
                          names(tail$certificate$determinant)))
        expect_true(is.character(tail$certificate$determinant$numerator))
        expect_true(is.character(tail$certificate$determinant$denominator))
        expect_true(is.character(tail$certificate$upper_bound))
        expect_true(is.character(tail$certificate$threshold_lower))
        expect_true(is.character(tail$certificate$gap_lower))
      } else {
        expect_identical(tail$certificate$status, "certificate_unavailable")
        expect_true(is.character(tail$certificate$reason))
      }
    }
  }

  normalize_nan <- function(x) {
    if (is.character(x)) {
      x[x %in% c("__HSQ_MISSING__", "__HSQ_NONE__")] <- NA_character_
    }
    x <- as.numeric(x)
    x[is.nan(x)] <- NA_real_
    x
  }

  direct_ci <- JuliaCall::julia_eval(paste(
    "let rows=HSquared.arc1_confint(hsq_arc1); Dict(",
    "\"estimand\"=>string.([r.estimand for r in rows]),",
    "\"segment\"=>Int[r.segment for r in rows],",
    "\"estimate\"=>Float64[ismissing(r.estimate) ? NaN : r.estimate for r in rows],",
    "\"lower\"=>Float64[ismissing(r.lower) ? NaN : r.lower for r in rows],",
    "\"upper\"=>Float64[ismissing(r.upper) ? NaN : r.upper for r in rows],",
    "\"formed\"=>Bool[r.formed for r in rows],",
    "\"status\"=>string.([r.status for r in rows])) end"
  ))
  direct_ci <- as.data.frame(direct_ci, stringsAsFactors = FALSE)
  r_ci <- confint(fit, method = "arc1_profile_v4")
  expect_identical(r_ci, arc1_uncertainty(fit))
  expect_identical(r_ci$estimand, as.character(direct_ci$estimand))
  expect_identical(r_ci$segment, as.integer(direct_ci$segment))
  expect_equal(normalize_nan(r_ci$estimate), normalize_nan(direct_ci$estimate))
  expect_equal(normalize_nan(r_ci$lower), normalize_nan(direct_ci$lower))
  expect_equal(normalize_nan(r_ci$upper), normalize_nan(direct_ci$upper))
  expect_identical(r_ci$formed, as.logical(direct_ci$formed))
  expect_identical(r_ci$status, as.character(direct_ci$status))
})
