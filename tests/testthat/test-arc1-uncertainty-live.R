hs_arc1_uncertainty_require_live <- function() {
  identical(tolower(Sys.getenv("HSQUARED_ARC1_REQUIRE_LIVE", "false")), "true")
}

hs_arc1_normalize_nan <- function(x) {
  if (is.character(x)) {
    x[x %in% c("__HSQ_MISSING__", "__HSQ_NONE__")] <- NA_character_
  }
  x <- as.numeric(x)
  x[is.nan(x)] <- NA_real_
  x
}

hs_arc1_direct_numeric <- function(x) {
  if (
    is.null(x) ||
      anyNA(x) ||
      any(x %in% c("__HSQ_MISSING__", "__HSQ_NONE__", "missing", "nothing"))
  ) {
    return(NA_real_)
  }
  as.numeric(x)
}

hs_arc1_sort_named_lists <- function(x) {
  if (is.environment(x)) {
    x <- as.list.environment(x, all.names = TRUE)
  }
  if (!is.list(x) || is.data.frame(x)) {
    return(x)
  }
  if (!is.null(names(x))) {
    x <- x[order(names(x))]
  }
  lapply(x, hs_arc1_sort_named_lists)
}

hs_arc1_uncertainty_live_julia_commands <- function() {
  list(
    profile_ci = paste(
      "let rows=HSquared.arc1_confint(hsq_arc1); Dict(",
      "\"estimand\"=>string.([r.estimand for r in rows]),",
      "\"segment\"=>Int[r.segment for r in rows],",
      "\"estimate\"=>Float64[ismissing(r.estimate) ? NaN : r.estimate for r in rows],",
      "\"lower\"=>Float64[ismissing(r.lower) ? NaN : r.lower for r in rows],",
      "\"upper\"=>Float64[ismissing(r.upper) ? NaN : r.upper for r in rows],",
      "\"formed\"=>Bool[r.formed for r in rows],",
      "\"status\"=>string.([r.status for r in rows])) end",
      sep = "\n"
    ),
    fa_dgp = paste0(
      "begin\n",
      paste(
        "using Random, LinearAlgebra",
        "hsq_arc1_test_rng = MersenneTwister(20261002);",
        "hsq_arc1_test_ids = collect(1:110);",
        "hsq_arc1_test_sire = zeros(Int, 110); hsq_arc1_test_dam = zeros(Int, 110);",
        "for sire_id in 1:10, dam_slot in 1:2, offspring_slot in 1:4",
        "child = 30 + (sire_id - 1) * 8 + (dam_slot - 1) * 4 + offspring_slot;",
        "hsq_arc1_test_sire[child] = sire_id;",
        "hsq_arc1_test_dam[child] = 10 + 2 * (sire_id - 1) + dam_slot; end;",
        "hsq_arc1_test_ped = HSquared.normalize_pedigree(hsq_arc1_test_ids, hsq_arc1_test_sire, hsq_arc1_test_dam);",
        "hsq_arc1_test_observed_ids = collect(31:110);",
        "hsq_arc1_test_signs = [1.0, 1.0, -1.0, -1.0];",
        "hsq_arc1_test_G = 0.35 .* (hsq_arc1_test_signs * hsq_arc1_test_signs') + 0.15 .* Matrix{Float64}(I, 4, 4);",
        "hsq_arc1_test_R = 0.4 .* Matrix{Float64}(I, 4, 4) + 0.1 .* ones(4, 4);",
        "hsq_arc1_test_LG = cholesky(Symmetric(hsq_arc1_test_G)).L;",
        "hsq_arc1_test_LR = cholesky(Symmetric(hsq_arc1_test_R)).L;",
        "hsq_arc1_test_animal = zeros(Float64, 110, 4);",
        "for animal in 1:30; hsq_arc1_test_animal[animal, :] .= hsq_arc1_test_LG * randn(hsq_arc1_test_rng, 4); end;",
        "for animal in hsq_arc1_test_observed_ids;",
        "hsq_arc1_test_animal[animal, :] .= 0.5 .* hsq_arc1_test_animal[hsq_arc1_test_sire[animal], :] .+",
        "0.5 .* hsq_arc1_test_animal[hsq_arc1_test_dam[animal], :] .+ sqrt(0.5) .* (hsq_arc1_test_LG * randn(hsq_arc1_test_rng, 4)); end;",
        "hsq_arc1_test_means = [0.0, 1.0, -1.0, 2.0];",
        "hsq_arc1_test_Y = Matrix{Float64}(undef, 80, 4);",
        "for row in eachindex(hsq_arc1_test_observed_ids); animal = hsq_arc1_test_observed_ids[row];",
        "hsq_arc1_test_Y[row, :] .= hsq_arc1_test_means .+ hsq_arc1_test_animal[animal, :] .+ hsq_arc1_test_LR * randn(hsq_arc1_test_rng, 4); end;",
        sep = "\n"
      ),
      "\nend"
    ),
    outer_selected = paste(
      "hsq_selection.selection_status == :selected &&",
      "hsq_selection.selected_fit !== nothing && hsq_selection.selected_rank in (0, 1) &&",
      "all(c.eligible for c in hsq_selection.candidate_summary)",
      sep = "\n"
    ),
    interrupted = paste0(
      "begin\n",
      paste(
        hsquared:::hs_julia_arc1_plain_command(),
        "hsq_arc1_interrupted = HSquared._arc1_bootstrap(hsq_selection, hsq_Y, hsq_X, hsq_Z, hsq_ped;",
        "seeds=UInt64[31], ids=hsq_ped.ids, traits=hsq_traits,",
        "selector=(args...; ids, traits, ledger_sink)->begin",
        "ledger_sink[]=(candidate_summary=(scores=[1.0, 2.0],), attempts=[(status=:running, score=NaN)]);",
        "throw(InterruptException()); end);",
        "hsq_arc1_interrupted_plain = hsq_arc1_plain(hsq_arc1_interrupted);",
        sep = "\n"
      ),
      "\nend"
    )
  )
}

test_that("generated live Arc1 Julia commands parse without executing a fit", {
  if (
    !requireNamespace("JuliaCall", quietly = TRUE) ||
      !nzchar(Sys.which("julia"))
  ) {
    skip(
      "JuliaCall and a local Julia executable are required to parse bridge commands."
    )
  }
  JuliaCall::julia_setup(installJulia = FALSE, verbose = FALSE)
  JuliaCall::julia_command(paste0(
    "begin\n",
    paste(
      "hsq_arc1_parser_has_error(x) = x isa Expr ?",
      "(x.head in (:error, :incomplete) || any(hsq_arc1_parser_has_error, x.args)) : false;",
      "hsq_arc1_single_parse_ok(source) = try",
      "parsed = Meta.parse(source; raise=true); !hsq_arc1_parser_has_error(parsed)",
      "catch; false; end",
      sep = "\n"
    ),
    "\nend"
  ))
  commands <- hs_arc1_uncertainty_live_julia_commands()
  for (i in seq_along(commands)) {
    JuliaCall::julia_assign("hsq_arc1_source_to_parse", commands[[i]])
    expect_true(isTRUE(JuliaCall::julia_eval(
      "hsq_arc1_single_parse_ok(hsq_arc1_source_to_parse)"
    )))
  }
  JuliaCall::julia_assign(
    "hsq_arc1_source_to_parse",
    "using Random, LinearAlgebra x = 1;"
  )
  expect_false(isTRUE(JuliaCall::julia_eval(
    "hsq_arc1_single_parse_ok(hsq_arc1_source_to_parse)"
  )))
  JuliaCall::julia_assign("hsq_arc1_source_to_parse", "for i in 1:2\n  x = i\n")
  expect_false(isTRUE(JuliaCall::julia_eval(
    "hsq_arc1_single_parse_ok(hsq_arc1_source_to_parse)"
  )))
  project <- Sys.getenv("HSQUARED_JULIA_PROJECT", "")
  if (nzchar(project) && dir.exists(project)) {
    hsquared:::hs_julia_setup(project)
    JuliaCall::julia_command(commands$fa_dgp)
    expect_true(isTRUE(JuliaCall::julia_eval(
      "size(hsq_arc1_test_Y) == (80, 4)"
    )))
    expect_true(isTRUE(JuliaCall::julia_eval(
      "length(hsq_arc1_test_ped.ids) == 110"
    )))
    expect_true(isTRUE(JuliaCall::julia_eval(
      "length(hsq_arc1_test_observed_ids) == 80"
    )))
  }
})

test_that("required live Arc1 profile and bootstrap retain engine uncertainty diagnostics", {
  if (!hs_arc1_uncertainty_require_live()) {
    skip(
      "Set HSQUARED_ARC1_REQUIRE_LIVE=true for required Arc1 uncertainty acceptance."
    )
  }
  project <- Sys.getenv("HSQUARED_JULIA_PROJECT", "")
  if (!nzchar(project) || !dir.exists(project)) {
    stop(
      "HSQUARED_ARC1_REQUIRE_LIVE=true but HSQUARED_JULIA_PROJECT is missing or invalid."
    )
  }
  if (
    !requireNamespace("JuliaCall", quietly = TRUE) ||
      !isTRUE(hsquared:::hs_julia_bridge_available())
  ) {
    stop(
      "HSQUARED_ARC1_REQUIRE_LIVE=true but JuliaCall or the configured Julia engine is unavailable."
    )
  }

  hsquared:::hs_julia_setup(project)
  generated_commands <- hs_arc1_uncertainty_live_julia_commands()

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
  profile <- hsquared(
    y ~ animal(1 | id, pedigree = ped) + permanent(1 | id),
    data = dat,
    control = hs_control(
      engine = "julia",
      engine_control = list(
        target = "repeatability",
        scale_method = "dense",
        uncertainty_method = "arc1_profile_v1"
      )
    )
  )
  expect_s3_class(profile, "hsquared_fit")
  expect_identical(profile$result$arc1_uncertainty$method, "arc1_profile_v1")
  expect_identical(
    profile$result$arc1_uncertainty$method_version,
    "arc1_profile_v1"
  )
  expect_true(is.finite(profile$result$heritability))
  expect_true(is.finite(profile$result$repeatability))
  r_profile_ci <- confint(profile, method = "arc1_profile_v1")
  julia_profile_ci <- JuliaCall::julia_eval(generated_commands$profile_ci)
  julia_profile_ci <- as.data.frame(julia_profile_ci, stringsAsFactors = FALSE)
  expect_identical(
    r_profile_ci$estimand,
    as.character(julia_profile_ci$estimand)
  )
  expect_identical(r_profile_ci$segment, as.integer(julia_profile_ci$segment))
  expect_equal(
    hs_arc1_normalize_nan(r_profile_ci$estimate),
    hs_arc1_normalize_nan(julia_profile_ci$estimate)
  )
  expect_equal(
    hs_arc1_normalize_nan(r_profile_ci$lower),
    hs_arc1_normalize_nan(julia_profile_ci$lower)
  )
  expect_equal(
    hs_arc1_normalize_nan(r_profile_ci$upper),
    hs_arc1_normalize_nan(julia_profile_ci$upper)
  )
  expect_identical(r_profile_ci$formed, as.logical(julia_profile_ci$formed))
  expect_identical(r_profile_ci$status, as.character(julia_profile_ci$status))
  expect_setequal(
    unique(r_profile_ci$estimand),
    c(
      "additive_variance",
      "permanent_environment_variance",
      "residual_variance",
      "heritability",
      "repeatability"
    )
  )

  profile_v2 <- hsquared(
    y ~ animal(1 | id, pedigree = ped) + permanent(1 | id),
    data = dat,
    control = hs_control(
      engine = "julia",
      engine_control = list(
        target = "repeatability",
        scale_method = "dense",
        uncertainty_method = "arc1_profile_v2"
      )
    )
  )
  expect_s3_class(profile_v2, "hsquared_fit")
  expect_identical(profile_v2$result$arc1_uncertainty$method, "arc1_profile_v2")
  expect_identical(
    profile_v2$result$arc1_uncertainty$method_version,
    "arc1_profile_v2"
  )
  direct_v2_identity <- list(
    method = as.character(JuliaCall::julia_eval("string(hsq_arc1.method)")),
    method_version = as.character(
      JuliaCall::julia_eval("string(hsq_arc1.method_version)")
    ),
    point_identity = as.character(
      JuliaCall::julia_eval(
        "something(get(hsq_arc1, :point_identity, nothing), \"\")"
      )
    ),
    reference_source_identity = as.character(
      JuliaCall::julia_eval("hsq_arc1.reference_source_identity")
    )
  )
  expect_identical(
    direct_v2_identity$method,
    profile_v2$result$arc1_uncertainty$method
  )
  expect_identical(
    direct_v2_identity$method_version,
    profile_v2$result$arc1_uncertainty$method_version
  )
  expect_identical(
    direct_v2_identity$point_identity,
    profile_v2$result$arc1_uncertainty$point_identity
  )
  expect_identical(
    direct_v2_identity$reference_source_identity,
    profile_v2$result$arc1_uncertainty$reference_source_identity
  )
  profile_v2_ci <- confint(profile_v2, method = "arc1_profile_v2")
  direct_v2_ci <- JuliaCall::julia_eval(generated_commands$profile_ci)
  direct_v2_ci <- as.data.frame(direct_v2_ci, stringsAsFactors = FALSE)
  expect_identical(profile_v2_ci, arc1_uncertainty(profile_v2))
  expect_identical(profile_v2_ci$estimand, as.character(direct_v2_ci$estimand))
  expect_identical(profile_v2_ci$segment, as.integer(direct_v2_ci$segment))
  expect_equal(
    hs_arc1_normalize_nan(profile_v2_ci$estimate),
    hs_arc1_normalize_nan(direct_v2_ci$estimate)
  )
  expect_equal(
    hs_arc1_normalize_nan(profile_v2_ci$lower),
    hs_arc1_normalize_nan(direct_v2_ci$lower)
  )
  expect_equal(
    hs_arc1_normalize_nan(profile_v2_ci$upper),
    hs_arc1_normalize_nan(direct_v2_ci$upper)
  )
  expect_identical(profile_v2_ci$formed, as.logical(direct_v2_ci$formed))
  expect_identical(profile_v2_ci$status, as.character(direct_v2_ci$status))
  expect_error(
    confint(profile_v2, method = "arc1_profile_v1"),
    "must match the method selected when fitting"
  )

  profile_v3 <- hsquared(
    y ~ animal(1 | id, pedigree = ped) + permanent(1 | id),
    data = dat,
    control = hs_control(
      engine = "julia",
      engine_control = list(
        target = "repeatability",
        scale_method = "dense",
        uncertainty_method = "arc1_profile_v3"
      )
    )
  )
  expect_s3_class(profile_v3, "hsquared_fit")
  expect_identical(profile_v3$result$arc1_uncertainty$method, "arc1_profile_v3")
  expect_identical(profile_v3$result$arc1_uncertainty$method_version, "arc1_profile_v3")
  profile_v3_identity <- list(
    method = as.character(JuliaCall::julia_eval("string(hsq_arc1.method)")),
    method_version = as.character(JuliaCall::julia_eval("string(hsq_arc1.method_version)")),
    point_identity = as.character(JuliaCall::julia_eval(
      "something(get(hsq_arc1, :point_identity, nothing), \"\")"
    )),
    source_identity = as.character(JuliaCall::julia_eval("hsq_arc1.source_identity")),
    reference_source_identity = as.character(
      JuliaCall::julia_eval("hsq_arc1.reference_source_identity")
    )
  )
  expect_identical(profile_v3_identity$method, profile_v3$result$arc1_uncertainty$method)
  expect_identical(profile_v3_identity$method_version,
                   profile_v3$result$arc1_uncertainty$method_version)
  expect_identical(profile_v3_identity$point_identity,
                   profile_v3$result$arc1_uncertainty$point_identity)
  expect_identical(profile_v3_identity$source_identity,
                   profile_v3$result$arc1_uncertainty$source_identity)
  expect_identical(profile_v3_identity$reference_source_identity,
                   profile_v3$result$arc1_uncertainty$reference_source_identity)
  profile_v3_ci <- confint(profile_v3, method = "arc1_profile_v3")
  direct_v3_ci <- JuliaCall::julia_eval(generated_commands$profile_ci)
  direct_v3_ci <- as.data.frame(direct_v3_ci, stringsAsFactors = FALSE)
  expect_identical(profile_v3_ci$estimand, as.character(direct_v3_ci$estimand))
  expect_identical(profile_v3_ci$segment, as.integer(direct_v3_ci$segment))
  expect_equal(hs_arc1_normalize_nan(profile_v3_ci$estimate),
               hs_arc1_normalize_nan(direct_v3_ci$estimate))
  expect_equal(hs_arc1_normalize_nan(profile_v3_ci$lower),
               hs_arc1_normalize_nan(direct_v3_ci$lower))
  expect_equal(hs_arc1_normalize_nan(profile_v3_ci$upper),
               hs_arc1_normalize_nan(direct_v3_ci$upper))
  expect_identical(profile_v3_ci$formed, as.logical(direct_v3_ci$formed))
  expect_identical(profile_v3_ci$status, as.character(direct_v3_ci$status))
  expect_identical(profile_v3_ci, arc1_uncertainty(profile_v3))
  expect_error(
    confint(profile_v3, method = "arc1_profile_v2"),
    "must match the method selected when fitting"
  )

  profile_v4 <- hsquared(
    y ~ animal(1 | id, pedigree = ped) + permanent(1 | id),
    data = dat,
    control = hs_control(
      engine = "julia",
      engine_control = list(
        target = "repeatability",
        scale_method = "dense",
        uncertainty_method = "arc1_profile_v4"
      )
    )
  )
  expect_s3_class(profile_v4, "hsquared_fit")
  expect_identical(profile_v4$result$arc1_uncertainty$method, "arc1_profile_v4")
  expect_identical(profile_v4$result$arc1_uncertainty$method_version, "arc1_profile_v4")
  profile_v4_identity <- list(
    method = as.character(JuliaCall::julia_eval("string(hsq_arc1.method)")),
    method_version = as.character(JuliaCall::julia_eval("string(hsq_arc1.method_version)")),
    point_identity = as.character(JuliaCall::julia_eval(
      "something(get(hsq_arc1, :point_identity, nothing), \"\")"
    )),
    source_identity = as.character(JuliaCall::julia_eval("hsq_arc1.source_identity")),
    reference_source_identity = as.character(
      JuliaCall::julia_eval("hsq_arc1.reference_source_identity")
    )
  )
  expect_identical(profile_v4_identity$method, profile_v4$result$arc1_uncertainty$method)
  expect_identical(profile_v4_identity$method_version,
                   profile_v4$result$arc1_uncertainty$method_version)
  expect_identical(profile_v4_identity$point_identity,
                   profile_v4$result$arc1_uncertainty$point_identity)
  expect_identical(profile_v4_identity$source_identity,
                   profile_v4$result$arc1_uncertainty$source_identity)
  expect_identical(profile_v4_identity$reference_source_identity,
                   profile_v4$result$arc1_uncertainty$reference_source_identity)
  profile_v4_ci <- confint(profile_v4, method = "arc1_profile_v4")
  direct_v4_ci <- JuliaCall::julia_eval(generated_commands$profile_ci)
  direct_v4_ci <- as.data.frame(direct_v4_ci, stringsAsFactors = FALSE)
  expect_identical(profile_v4_ci, arc1_uncertainty(profile_v4))
  expect_identical(profile_v4_ci$estimand, as.character(direct_v4_ci$estimand))
  expect_identical(profile_v4_ci$segment, as.integer(direct_v4_ci$segment))
  expect_equal(hs_arc1_normalize_nan(profile_v4_ci$estimate),
               hs_arc1_normalize_nan(direct_v4_ci$estimate))
  expect_equal(hs_arc1_normalize_nan(profile_v4_ci$lower),
               hs_arc1_normalize_nan(direct_v4_ci$lower))
  expect_equal(hs_arc1_normalize_nan(profile_v4_ci$upper),
               hs_arc1_normalize_nan(direct_v4_ci$upper))
  expect_identical(profile_v4_ci$formed, as.logical(direct_v4_ci$formed))
  expect_identical(profile_v4_ci$status, as.character(direct_v4_ci$status))
  expect_error(
    confint(profile_v4, method = "arc1_profile_v3"),
    "must match the method selected when fitting"
  )

  # Reproduce only the independent DGP portion of the retained Julia witness.
  # The 110-row pedigree has 30 unobserved parents; only offspring 31:110 have records.
  JuliaCall::julia_command(generated_commands$fa_dgp)
  observed_ids <- as.integer(JuliaCall::julia_eval(
    "hsq_arc1_test_observed_ids"
  ))
  fa_ids <- as.integer(JuliaCall::julia_eval("hsq_arc1_test_ids"))
  fa_sire <- as.integer(JuliaCall::julia_eval("hsq_arc1_test_sire"))
  fa_dam <- as.integer(JuliaCall::julia_eval("hsq_arc1_test_dam"))
  fa_sire[fa_sire == 0L] <- NA_integer_
  fa_dam[fa_dam == 0L] <- NA_integer_
  fa_ped <- data.frame(id = fa_ids, sire = fa_sire, dam = fa_dam)
  expect_equal(nrow(fa_ped), 110L)
  expect_identical(observed_ids, 31:110)
  fa_Y <- as.matrix(JuliaCall::julia_eval("hsq_arc1_test_Y"))
  fa_dat <- data.frame(
    id = observed_ids,
    t1 = fa_Y[, 1],
    t2 = fa_Y[, 2],
    t3 = fa_Y[, 3],
    t4 = fa_Y[, 4]
  )
  expect_equal(nrow(fa_dat), 80L)
  seeds <- c("18446744073709551614", "9223372036854775809", "31")
  boot <- hsquared(
    cbind(t1, t2, t3, t4) ~ animal(1 | id, pedigree = fa_ped),
    data = fa_dat,
    control = hs_control(
      engine = "julia",
      engine_control = list(
        target = "multivariate",
        rank_selection = "auto",
        optimizer_policy = "arc1_v1",
        uncertainty_method = "arc1_bootstrap_v1",
        bootstrap_B = 3L,
        bootstrap_seeds = seeds
      )
    )
  )
  # arc1_uncertainty() is the public interval-table extractor. Detailed
  # bootstrap metadata remains on the fitted rank-selection result.
  uncertainty <- boot$arc1_uncertainty
  intervals <- arc1_uncertainty(boot)
  outer_selected <- JuliaCall::julia_eval(generated_commands$outer_selected)
  expect_true(isTRUE(outer_selected))
  expect_identical(uncertainty$requested_seeds, seeds)
  expect_identical(uncertainty$requested_bootstrap_count, 3L)
  expect_identical(uncertainty$prefix_size, 3L)
  expect_identical(uncertainty$retained_full_stream_count, 3L)
  expect_length(uncertainty$attempts, 3L)
  expect_true(is.list(uncertainty$attempts[[1]]))
  direct_boot <- hs_arc1_plain_to_list(
    JuliaCall::julia_eval("hsq_arc1_plain(hsq_arc1_boot)")
  )
  direct_guards <- JuliaCall::julia_eval(
    "hsq_arc1_plain(hsq_selection.guard_results)"
  )
  expect_identical(
    hs_arc1_plain_to_list(boot$guard_results),
    hs_arc1_plain_to_list(direct_guards)
  )
  expect_identical(
    as.character(uncertainty$traits),
    as.character(direct_boot$traits)
  )
  expect_equal(
    unname(uncertainty$point_estimates),
    as.numeric(direct_boot$point_estimates)
  )
  expect_identical(
    uncertainty$requested_seeds,
    as.character(direct_boot$requested_seeds)
  )
  expect_equal(nrow(intervals), 4L)
  expect_identical(intervals, uncertainty$intervals)
  direct_intervals <- direct_boot$intervals
  expect_identical(
    intervals$estimand,
    vapply(direct_intervals, `[[`, character(1), "estimand")
  )
  expect_identical(
    intervals$trait,
    vapply(direct_intervals, `[[`, character(1), "trait")
  )
  expect_identical(
    intervals$segment,
    as.integer(vapply(direct_intervals, `[[`, integer(1), "segment"))
  )
  expect_equal(
    hs_arc1_normalize_nan(intervals$estimate),
    hs_arc1_normalize_nan(vapply(
      direct_intervals,
      `[[`,
      numeric(1),
      "estimate"
    ))
  )
  expect_equal(
    hs_arc1_normalize_nan(intervals$lower),
    vapply(
      direct_intervals,
      function(row) hs_arc1_direct_numeric(row$lower),
      numeric(1)
    )
  )
  expect_equal(
    hs_arc1_normalize_nan(intervals$upper),
    vapply(
      direct_intervals,
      function(row) hs_arc1_direct_numeric(row$upper),
      numeric(1)
    )
  )
  expect_identical(
    intervals$formed,
    as.logical(vapply(direct_intervals, `[[`, logical(1), "formed"))
  )
  expect_identical(
    intervals$status,
    vapply(direct_intervals, `[[`, character(1), "status")
  )
  expect_length(direct_boot$attempts, length(uncertainty$attempts))
  for (i in seq_along(uncertainty$attempts)) {
    observed <- uncertainty$attempts[[i]]
    direct <- direct_boot$attempts[[i]]
    expect_identical(as.character(observed$seed), as.character(direct$seed))
    expect_identical(as.character(observed$status), as.character(direct$status))
    expect_identical(
      as.character(observed$selected_rank),
      as.character(direct$selected_rank)
    )
    expect_equal(as.numeric(observed$h2), as.numeric(direct$h2))
    expect_identical(
      as.integer(observed$starts_planned),
      as.integer(direct$starts_planned)
    )
    expect_identical(
      as.integer(observed$starts_attempted),
      as.integer(direct$starts_attempted)
    )
    expect_identical(
      hs_arc1_sort_named_lists(observed$candidate_summary),
      hs_arc1_sort_named_lists(direct$candidate_summary)
    )
    expect_identical(
      hs_arc1_sort_named_lists(observed$selector_attempts),
      hs_arc1_sort_named_lists(direct$selector_attempts)
    )
    expect_identical(
      hs_arc1_sort_named_lists(observed$selected_fit_summary),
      hs_arc1_sort_named_lists(direct$selected_fit_summary)
    )
    expect_identical(
      hs_arc1_plain_to_list(observed$guard_results),
      hs_arc1_plain_to_list(direct$guard_results)
    )
    for (j in seq_along(observed$candidate_summary)) {
      expect_equal(
        hs_arc1_direct_numeric(observed$candidate_summary[[j]]$loglik),
        hs_arc1_direct_numeric(direct$candidate_summary[[j]]$loglik)
      )
      expect_equal(
        hs_arc1_direct_numeric(observed$candidate_summary[[j]]$criterion),
        hs_arc1_direct_numeric(direct$candidate_summary[[j]]$criterion)
      )
    }
    if (length(observed$selector_attempts)) {
      observed_starts <- observed$selector_attempts
      direct_starts <- direct$selector_attempts
      expect_identical(
        lapply(observed_starts, `[[`, "start_id"),
        lapply(direct_starts, `[[`, "start_id")
      )
      expect_identical(
        lapply(observed_starts, `[[`, "status"),
        lapply(direct_starts, `[[`, "status")
      )
      expect_identical(
        lapply(observed_starts, `[[`, "failure_status"),
        lapply(direct_starts, `[[`, "failure_status")
      )
      expect_identical(
        sum(vapply(observed_starts, function(x) x$status != "ok", logical(1))),
        sum(vapply(direct_starts, function(x) x$status != "ok", logical(1)))
      )
    }
  }
  expect_identical(uncertainty$failure_causes, direct_boot$failure_causes)
  expect_identical(uncertainty$counts, direct_boot$counts)
  expect_true(
    uncertainty$status %in% c("formed", "insufficient_usable_bootstrap")
  )
  expect_identical(uncertainty$rng_identity, "MersenneTwister")
  expect_true(nzchar(uncertainty$julia_version))

  JuliaCall::julia_command(generated_commands$interrupted)
  interrupted <- JuliaCall::julia_eval(
    "hsq_arc1_interrupted_plain[\"attempts\"][1][\"selector_ledger\"][\"attempts\"][1]"
  )
  expect_true(is.list(interrupted) || is.environment(interrupted))
  expect_equal(
    JuliaCall::julia_eval("string(hsq_arc1_interrupted.attempts[1].status)"),
    "interrupted"
  )
  expect_equal(as.character(interrupted$status), "running")
  expect_true(is.nan(as.numeric(interrupted$score)))
  expect_equal(
    JuliaCall::julia_eval(
      "string(hsq_arc1_interrupted_plain[\"interruption_ledger\"][\"attempt\"])"
    ),
    "1"
  )

  # The recovered R route rejects bootstrap v2 before any Julia fit.
  unsupported_v2 <- hs_control(
    engine = "julia",
    engine_control = list(
      target = "multivariate", optimizer_policy = "arc1_v2",
      uncertainty_method = "arc1_bootstrap_v2", bootstrap_B = 1L,
      bootstrap_seeds = "42"
    )
  )
  expect_error(
    hs_validate_arc1_uncertainty_control(
      unsupported_v2, "multivariate", list(), list(), automatic_fa = TRUE
    ),
    "arc1_bootstrap_v1"
  )

})
