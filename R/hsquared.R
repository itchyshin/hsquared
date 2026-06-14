#' Fit a quantitative-genetic model
#'
#' `hsquared()` is the R entry point for heritability, breeding-value,
#' G-matrix, and inheritance-structured mixed models. v0.1 fits the univariate
#' Gaussian animal model `y ~ fixed + animal(1 | id, pedigree = ped)` by REML
#' through the `HSquared.jl` engine. The default `control` fits when a local
#' Julia and `HSquared.jl` are available and otherwise errors with install
#' guidance; `hs_control(engine = "validate")` validates the contract without
#' fitting. Multivariate, genomic, and non-Gaussian models remain planned.
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
#' @return A `"hsquared_fit"` object from the fitted v0.1 Gaussian animal model,
#'   or an informative error when the Julia engine is unavailable or
#'   `engine = "validate"` is used.
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

  spec <- hs_build_model_spec(
    formula = formula,
    data = data,
    family = family,
    REML = REML
  )
  payload <- hs_build_bridge_payload(spec)

  if (identical(control$engine, "fit")) {
    if (!isTRUE(REML)) {
      stop(
        "The v0.1 default fit path estimates variance components by REML ",
        "(average-information REML). ML estimation (`REML = FALSE`) is not yet ",
        "implemented on the fit path; use `REML = TRUE` (the default).",
        call. = FALSE
      )
    }
    second_effect <- setdiff(names(spec$random), "animal")
    if (length(second_effect) > 0L) {
      stop(
        "The two-effect (`",
        second_effect[[1L]],
        "`) model is experimental and opt-in; the default `engine = \"fit\"` ",
        "path fits the single-effect Gaussian animal model only. Use ",
        "`control = hs_control(engine = \"julia\", engine_control = list(",
        "target = \"",
        hs_second_effect_target(second_effect[[1L]]),
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
        "engine (Julia, the `JuliaCall` R package, and a local `HSquared.jl`). ",
        "Install them to fit, or use ",
        "`control = hs_control(engine = \"validate\")` to validate the model ",
        "without fitting.",
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
    # ML estimation is not implemented in v0.1. The estimation targets either
    # run the ML optimizer (`fit_animal_model`) or are REML-only
    # (`sparse_reml`/`ai_reml`, which would otherwise silently ignore the ML
    # request). Reject `REML = FALSE` for all of them. `henderson_mme` solves at
    # supplied variances, so its method label is cosmetic and is exempt.
    if (!isTRUE(REML) && !identical(target, "henderson_mme")) {
      stop(
        "ML estimation (`REML = FALSE`) is not implemented; the v0.1 fit path ",
        "estimates variance components by REML. Use `REML = TRUE`.",
        call. = FALSE
      )
    }
    # A second random effect only fits through its two-effect target; the
    # single-effect estimators would silently ignore it.
    second_effect <- setdiff(names(spec$random), "animal")
    if (length(second_effect) > 0L) {
      required <- hs_second_effect_target(second_effect[[1L]])
      if (!identical(target, required)) {
        stop(
          "The formula has a `",
          second_effect[[1L]],
          "(...)` term, so it needs `target = \"",
          required,
          "\"`. The `",
          target,
          "` target fits the single additive-genetic effect only.",
          call. = FALSE
        )
      }
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

  stop(
    "`hsquared(control = hs_control(engine = \"validate\"))` validated the ",
    "v0.1 animal-model contract and stopped without fitting. Use the default ",
    "`control` to fit the model (requires the HSquared.jl Julia engine), or ",
    "`hs_control(engine = \"julia\")` for advanced engine control. The Julia ",
    "fit target is `HSquared.fit_ai_reml(",
    "HSquared.animal_model_spec(y, X, Z, Ainv; ids = ids, method = :",
    payload$method,
    "))`.",
    call. = FALSE
  )
}
