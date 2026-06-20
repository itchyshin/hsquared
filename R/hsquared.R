#' Fit a quantitative-genetic model
#'
#' `hsquared()` is the R entry point for heritability, breeding-value,
#' G-matrix, and inheritance-structured mixed models. v0.1 fits the univariate
#' Gaussian animal model `y ~ fixed + animal(1 | id, pedigree = ped)` by REML
#' through the `HSquared.jl` engine. The default `control` fits when a local
#' Julia and `HSquared.jl` are available and otherwise errors with install
#' guidance; `hs_control(engine = "validate")` validates the contract without
#' fitting, then returns the validated model spec invisibly. Genomic,
#' repeatability, two-effect, marker-effect, multivariate, and non-Gaussian
#' (`poisson`/`binomial`, Laplace-REML, no heritability) models are opt-in
#' experimental paths; factor-analytic models remain planned.
#'
#' @param formula A model formula. The first planned v0.1 syntax is
#'   `y ~ fixed + animal(1 | id, pedigree = ped)`, with
#'   `animal(1 | id)` also accepted when `data` is an [hs_data()] object with a
#'   pedigree component.
#' @param data A data frame containing model variables, or an [hs_data()]
#'   object whose `phenotypes` component contains the model variables. When
#'   `data` is an `hs_data` object, formula arguments such as
#'   `pedigree = pedigree` can refer to named components in the bundle, and
#'   `animal(1 | id)` uses the bundle pedigree by default.
#' @param family A response family. The v0.1 parser accepts only
#'   `gaussian()`.
#' @param REML Logical; whether to use REML estimation. The v0.1 fit path
#'   supports REML only (the default, `TRUE`); `REML = FALSE` (ML) is not yet
#'   implemented and is rejected with an error.
#' @param control An object created by [hs_control()].
#' @param ... Reserved for future arguments.
#'
#' @return A `"hsquared_fit"` object from the fitted v0.1 Gaussian animal model.
#'   When the Julia engine is unavailable, an informative error. When
#'   `engine = "validate"`, the validated model specification is returned
#'   invisibly as a named list (after a confirming message), for programmatic
#'   inspection — for example `spec$bridge$target` and `spec$response`. This is
#'   the internal spec list, not the classed object that [model_spec()] builds.
#' @export
hsquared <- function(
  formula,
  data,
  family = stats::gaussian(),
  REML = TRUE,
  control = hs_control(),
  ...
) {
  if (missing(formula)) {
    stop("`formula` is required.", call. = FALSE)
  }
  if (missing(data)) {
    stop("`data` is required.", call. = FALSE)
  }
  if (!inherits(control, "hs_control")) {
    stop("`control` must be created by `hs_control()`.", call. = FALSE)
  }
  dots <- list(...)
  force(dots)

  # The opt-in non-Gaussian target widens the accepted families before the
  # model spec is validated; poisson(log)/binomial(logit) fit on the latent
  # scale, every other path stays Gaussian-only.
  julia_target <- if (identical(control$engine, "julia")) {
    hs_engine_control_value(control, "target", "fit_animal_model")
  } else {
    NA_character_
  }
  allow_families <- if (identical(julia_target, "nongaussian")) {
    c("gaussian", "poisson", "binomial")
  } else {
    "gaussian"
  }

  spec <- hs_build_model_spec(
    formula = formula,
    data = data,
    family = family,
    REML = REML,
    allow_families = allow_families
  )
  payload <- hs_build_bridge_payload(spec)

  if (identical(control$engine, "fit")) {
    if (isTRUE(spec$response$multivariate)) {
      stop(
        "The multivariate animal model is experimental and opt-in; the ",
        "default `engine = \"fit\"` path fits the univariate Gaussian animal ",
        "model only. Use `control = hs_control(engine = \"julia\", ",
        "engine_control = list(target = \"multivariate\"))`.",
        call. = FALSE
      )
    }
    if (identical(spec$random$animal$design, "random_regression")) {
      stop(
        "The random-regression (reaction-norm) animal model is experimental ",
        "and opt-in; the default `engine = \"fit\"` path fits the ",
        "random-intercept Gaussian animal model only. Use `control = ",
        "hs_control(engine = \"julia\", engine_control = list(target = ",
        "\"random_regression\"))`.",
        call. = FALSE
      )
    }
    if (!isTRUE(REML)) {
      stop(
        "The v0.1 default fit path estimates variance components by REML ",
        "(average-information REML). ML estimation (`REML = FALSE`) is not yet ",
        "implemented on the fit path; use `REML = TRUE` (the default).",
        call. = FALSE
      )
    }
    opt_in_effect <- setdiff(names(spec$random), "animal")
    if (length(opt_in_effect) > 0L) {
      stop(
        "The `",
        opt_in_effect[[1L]],
        "` model is experimental and opt-in; the default `engine = \"fit\"` ",
        "path fits the single-effect Gaussian animal model only. Use ",
        "`control = hs_control(engine = \"julia\", engine_control = list(",
        "target = \"",
        hs_second_effect_target(opt_in_effect[[1L]]),
        "\"))`.",
        call. = FALSE
      )
    }
    project <- hs_engine_control_value(
      control,
      "julia_project",
      hs_default_julia_project()
    )
    if (!hs_julia_bridge_available(project)) {
      stop(
        "Fitting the v0.1 Gaussian animal model requires the HSquared.jl Julia ",
        "engine (Julia, the `JuliaCall` R package, and a from-source checkout ",
        "of `HSquared.jl`, which is not yet a registered Julia package). To ",
        "fit: (1) `git clone https://github.com/itchyshin/HSquared.jl`; ",
        "(2) point the bridge at that checkout, either by setting the ",
        "`HSQUARED_JULIA_PROJECT` environment variable to the clone path or by ",
        "passing `control = hs_control(engine = \"julia\", engine_control = ",
        "list(julia_project = \"/path/to/HSquared.jl\"))`. To validate the ",
        "model contract without fitting (no Julia needed), use ",
        "`control = hs_control(engine = \"validate\")`.",
        call. = FALSE
      )
    }
    return(hs_fit_julia_ai_reml_payload(
      payload,
      project = project,
      initial = hs_engine_control_value(
        control,
        "initial",
        c(sigma_a2 = 1, sigma_e2 = 1)
      ),
      iterations = hs_engine_control_value(control, "iterations", 100L)
    ))
  }

  if (identical(control$engine, "julia")) {
    target <- hs_validate_julia_target(hs_engine_control_value(
      control,
      "target",
      "fit_animal_model"
    ))
    genetic_structure <- hs_validate_genetic_structure_control(control, target)
    if (
      isTRUE(spec$response$multivariate) && !identical(target, "multivariate")
    ) {
      stop(
        "A `cbind(...)` multivariate response requires the opt-in ",
        "`target = \"multivariate\"` Julia engine path. The `",
        target,
        "` target fits a univariate response.",
        call. = FALSE
      )
    }
    if (
      identical(target, "multivariate") && !isTRUE(spec$response$multivariate)
    ) {
      stop(
        "`target = \"multivariate\"` requires a `cbind(trait1, trait2, ...)` ",
        "response with `animal(1 | id, pedigree = ped)`.",
        call. = FALSE
      )
    }
    rr_design <- identical(spec$random$animal$design, "random_regression")
    if (rr_design && !identical(target, "random_regression")) {
      stop(
        "An `animal(rr(...) | id)` random-regression term requires the opt-in ",
        "`target = \"random_regression\"` Julia engine path. The `",
        target,
        "` target fits a random-intercept response.",
        call. = FALSE
      )
    }
    if (identical(target, "random_regression") && !rr_design) {
      stop(
        "`target = \"random_regression\"` requires an ",
        "`animal(rr(covariate, order = k) | id, pedigree = ped)` term in the ",
        "formula.",
        call. = FALSE
      )
    }
    # ML estimation is not implemented in v0.1. The estimation targets either
    # run the ML optimizer (`fit_animal_model`) or are REML-only
    # (`sparse_reml`/`ai_reml`, which would otherwise silently ignore the ML
    # request). Reject `REML = FALSE` for all of them. `henderson_mme` and
    # `snp_blup` solve at supplied variances, so their method label is cosmetic
    # and they are exempt.
    supplied_variance_targets <- c("henderson_mme", "snp_blup")
    if (!isTRUE(REML) && !target %in% supplied_variance_targets) {
      stop(
        "ML estimation (`REML = FALSE`) is not implemented; the v0.1 fit path ",
        "estimates variance components by REML. Use `REML = TRUE`.",
        call. = FALSE
      )
    }
    # A non-default random effect only fits through one of its opt-in targets;
    # the single-effect estimators would silently ignore it.
    second_effect <- setdiff(names(spec$random), "animal")
    if (length(second_effect) > 0L) {
      allowed <- hs_effect_targets(second_effect[[1L]])
      if (!target %in% allowed) {
        stop(
          "The formula has a `",
          second_effect[[1L]],
          "(...)` term, so it needs `target = \"",
          allowed[[1L]],
          "\"`",
          if (length(allowed) > 1L) {
            paste0(" (or \"", allowed[[2L]], "\")")
          } else {
            ""
          },
          ". The `",
          target,
          "` target fits the single additive-genetic effect only.",
          call. = FALSE
        )
      }
    }
    if (identical(target, "multivariate")) {
      return(hs_fit_julia_multivariate_payload(
        payload,
        project = hs_engine_control_value(
          control,
          "julia_project",
          hs_default_julia_project()
        ),
        initial = hs_engine_control_value(control, "initial", NULL),
        iterations = hs_engine_control_value(
          control,
          "iterations",
          2000L
        ),
        genetic_structure = genetic_structure
      ))
    }
    if (identical(target, "random_regression")) {
      return(hs_fit_julia_random_regression_payload(
        payload,
        project = hs_engine_control_value(
          control,
          "julia_project",
          hs_default_julia_project()
        ),
        iterations = hs_engine_control_value(
          control,
          "iterations",
          2000L
        )
      ))
    }
    if (identical(target, "nongaussian")) {
      if (identical(family$family, "gaussian")) {
        stop(
          "`target = \"nongaussian\"` fits non-Gaussian families ",
          "(`poisson(log)`, `binomial(logit)`); `family = gaussian()` fits ",
          "through the default path or `target = \"ai_reml\"`.",
          call. = FALSE
        )
      }
      return(hs_fit_julia_nongaussian_payload(
        payload,
        project = hs_engine_control_value(
          control,
          "julia_project",
          hs_default_julia_project()
        ),
        family = family,
        marginal = hs_engine_control_value(control, "marginal", "laplace"),
        iterations = hs_engine_control_value(control, "iterations", 200L)
      ))
    }
    if (identical(target, "henderson_mme")) {
      return(hs_fit_julia_henderson_mme_payload(
        payload,
        project = hs_engine_control_value(
          control,
          "julia_project",
          hs_default_julia_project()
        ),
        variance_components = hs_engine_control_value(
          control,
          "variance_components",
          NULL
        )
      ))
    }

    if (identical(target, "sparse_reml")) {
      return(hs_fit_julia_sparse_reml_payload(
        payload,
        project = hs_engine_control_value(
          control,
          "julia_project",
          hs_default_julia_project()
        ),
        initial = hs_engine_control_value(
          control,
          "initial",
          c(sigma_a2 = 1, sigma_e2 = 1)
        ),
        iterations = hs_engine_control_value(
          control,
          "iterations",
          1000L
        )
      ))
    }

    if (identical(target, "ai_reml")) {
      return(hs_fit_julia_ai_reml_payload(
        payload,
        project = hs_engine_control_value(
          control,
          "julia_project",
          hs_default_julia_project()
        ),
        initial = hs_engine_control_value(
          control,
          "initial",
          c(sigma_a2 = 1, sigma_e2 = 1)
        ),
        iterations = hs_engine_control_value(
          control,
          "iterations",
          100L
        )
      ))
    }

    if (identical(target, "repeatability")) {
      if (is.null(spec$random$permanent)) {
        stop(
          "`target = \"repeatability\"` requires a `permanent(1 | id)` term ",
          "alongside `animal(1 | id, ...)` in the formula.",
          call. = FALSE
        )
      }
      return(hs_fit_julia_repeatability_payload(
        payload,
        project = hs_engine_control_value(
          control,
          "julia_project",
          hs_default_julia_project()
        ),
        initial = hs_engine_control_value(
          control,
          "initial",
          c(sigma_a2 = 1, sigma_pe2 = 1, sigma_e2 = 1)
        ),
        iterations = hs_engine_control_value(
          control,
          "iterations",
          200L
        )
      ))
    }

    if (identical(target, "two_effect")) {
      if (
        is.null(spec$random$common_env) &&
          is.null(spec$random$maternal_genetic)
      ) {
        stop(
          "`target = \"two_effect\"` requires a `common_env(1 | group)` term, ",
          "or a `maternal_genetic(1 | dam)` term, alongside ",
          "`animal(1 | id, ...)` in the formula.",
          call. = FALSE
        )
      }
      return(hs_fit_julia_two_effect_payload(
        payload,
        project = hs_engine_control_value(
          control,
          "julia_project",
          hs_default_julia_project()
        ),
        initial = hs_engine_control_value(
          control,
          "initial",
          c(sigma_a2 = 1, sigma_c2 = 1, sigma_e2 = 1)
        ),
        iterations = hs_engine_control_value(
          control,
          "iterations",
          200L
        )
      ))
    }

    if (identical(target, "snp_blup")) {
      genomic_effect <- spec$random$genomic
      if (
        is.null(genomic_effect) ||
          !identical(genomic_effect$source, "markers")
      ) {
        stop(
          "`target = \"snp_blup\"` requires a `genomic(1 | id, markers = M)` ",
          "term (a raw marker matrix). SNP-BLUP estimates marker effects, so ",
          "a precomputed `Ginv` cannot be used.",
          call. = FALSE
        )
      }
      vc <- hs_validate_snp_blup_variances(
        hs_engine_control_value(control, "variance_components", NULL)
      )
      return(hs_fit_julia_snp_blup_payload(
        payload,
        project = hs_engine_control_value(
          control,
          "julia_project",
          hs_default_julia_project()
        ),
        variance_components = vc
      ))
    }

    if (target %in% c("genomic", "single_step")) {
      if (is.null(spec$random[[target]])) {
        arg <- if (identical(target, "genomic")) "Ginv" else "Hinv"
        stop(
          "`target = \"",
          target,
          "\"` requires a `",
          target,
          "(1 | id, ",
          arg,
          " = ",
          arg,
          ")` term in the formula.",
          call. = FALSE
        )
      }
      return(hs_fit_julia_genomic_payload(
        payload,
        project = hs_engine_control_value(
          control,
          "julia_project",
          hs_default_julia_project()
        ),
        initial = hs_engine_control_value(
          control,
          "initial",
          c(sigma_a2 = 1, sigma_e2 = 1)
        ),
        iterations = hs_engine_control_value(
          control,
          "iterations",
          100L
        )
      ))
    }

    return(hs_fit_julia_payload(
      payload,
      project = hs_engine_control_value(
        control,
        "julia_project",
        hs_default_julia_project()
      ),
      initial = hs_engine_control_value(
        control,
        "initial",
        c(sigma_a2 = 1, sigma_e2 = 1)
      )
    ))
  }

  # `engine == "validate"`: reaching here means `hs_build_model_spec()` and
  # `hs_build_bridge_payload()` both succeeded, so the v0.1 animal-model
  # contract is validated. Confirm with a message and return the validated spec
  # invisibly so it can be assigned and inspected, rather than stopping. Use the
  # default `control` to fit (requires the HSquared.jl Julia engine), or
  # `hs_control(engine = "julia")` for advanced engine control.
  message(
    "Validated the v0.1 animal-model contract; no model was fitted ",
    "(`engine = \"validate\"`). Julia fit target: `HSquared.",
    spec$bridge$target,
    "`. The validated spec is returned invisibly as a named list; assign it ",
    "to inspect the parsed contract (e.g. `spec$bridge$target`)."
  )
  invisible(spec)
}
