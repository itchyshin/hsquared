hs_build_bridge_payload <- function(spec) {
  relinv_primary <- spec$random$genomic
  if (is.null(relinv_primary)) {
    relinv_primary <- spec$random$single_step
  }
  if (!is.null(relinv_primary)) {
    return(hs_build_relinv_bridge_payload(spec, relinv_primary))
  }

  animal <- spec$random$animal
  is_metafounder <- FALSE
  if (is.null(animal)) {
    animal <- spec$random$metafounder
    is_metafounder <- TRUE
  }
  pedigree <- animal$pedigree
  observed_ids <- animal$values
  ids <- pedigree$ids
  id_index <- match(observed_ids, ids)

  if (anyNA(id_index)) {
    stop(
      "Internal bridge error: observed animal IDs are not aligned with the ",
      "validated pedigree.",
      call. = FALSE
    )
  }

  Z <- Matrix::sparseMatrix(
    i = seq_along(id_index),
    j = id_index,
    x = 1,
    dims = c(length(id_index), length(ids)),
    dimnames = list(NULL, ids)
  )

  # Second design matrix `Z2` for the opt-in two-effect model: a record incidence
  # on the second effect's levels. `common_env` levels are the environmental
  # groups with an identity relationship; `maternal_genetic` levels are the
  # pedigree animals (dams expressed through `Z2`) with the pedigree relationship.
  Z2 <- NULL
  effect2 <- NULL
  second <- spec$random$common_env
  if (is.null(second)) {
    second <- spec$random$maternal_genetic
  }
  if (!is.null(second)) {
    levels2 <- second$levels
    index2 <- match(second$values, levels2)
    Z2 <- Matrix::sparseMatrix(
      i = seq_along(index2),
      j = index2,
      x = 1,
      dims = c(length(index2), length(levels2)),
      dimnames = list(NULL, levels2)
    )
    effect2 <- list(
      type = second$type,
      group = second$group,
      levels = levels2,
      relationship = second$relationship
    )
  }

  # Opt-in random-regression (reaction-norm) design carried on `animal()`'s LHS:
  # the per-record covariate and the number of Legendre coefficients travel in
  # the payload; the engine builds the n x k Phi basis from the standardized
  # covariate. The recorded (lower, upper) bounds let extractors re-standardize a
  # user-supplied `at =` covariate value on the original scale.
  rr <- animal$random_regression

  structure(
    list(
      y = if (isTRUE(spec$response$multivariate)) {
        NULL
      } else {
        as.numeric(spec$response$values)
      },
      Y = if (isTRUE(spec$response$multivariate)) {
        unname(as.matrix(spec$response$values))
      } else {
        NULL
      },
      X = unname(as.matrix(spec$fixed$design)),
      Z = Z,
      Z2 = Z2,
      effect2 = effect2,
      random_regression = rr,
      Ainv = NULL,
      group_of = if (is_metafounder) animal$group_of else NULL,
      Gamma = if (is_metafounder) animal$Gamma else NULL,
      gamma_labels = if (is_metafounder) animal$gamma_labels else NULL,
      relationship_source = if (is_metafounder) "metafounder" else "pedigree",
      method = spec$method,
      family = spec$family$family,
      # Per-record trial counts (length-n integer vector) for a
      # cbind(successes, failures) binomial response; NULL for every other
      # response (Bernoulli/Poisson/Gaussian).
      n_trials = spec$response$n_trials,
      ids = ids,
      pedigree = list(
        id = pedigree$data$id,
        sire = pedigree$data$sire,
        dam = pedigree$data$dam,
        sire_index = pedigree$parent_index$sire,
        dam_index = pedigree$parent_index$dam,
        original_order = pedigree$original_order
      ),
      metadata = list(
        response = spec$response$name,
        response_type = if (isTRUE(spec$response$multivariate)) {
          "multivariate"
        } else if (!is.null(rr)) {
          "random_regression"
        } else {
          "univariate"
        },
        trait_names = spec$response$trait_names,
        random_regression = if (is.null(rr)) {
          NULL
        } else {
          list(
            covariate = rr$covariate,
            order = rr$order,
            lower = rr$lower,
            upper = rr$upper
          )
        },
        fixed_colnames = colnames(spec$fixed$design),
        animal_id_column = animal$group,
        observed_ids = observed_ids,
        observed_id_index = id_index,
        relationship = animal$relationship,
        gamma_source = if (is_metafounder) "supplied" else NULL,
        fixed_terms = spec$fixed$terms,
        contrasts = spec$fixed$contrasts,
        ainv_status = "build_in_julia",
        ainv_target = paste0(
          "HSquared.pedigree_inverse(",
          "HSquared.normalize_pedigree(id, sire, dam))"
        ),
        julia_spec_target = paste0(
          if (is_metafounder) {
            "HSquared.metafounder_animal_model"
          } else {
            paste0(
              "HSquared.animal_model_spec(y, X, Z, Ainv; ",
              "ids = ids, method = :",
              spec$method,
              ")"
            )
          }
        ),
        julia_fit_target = paste0("HSquared.", spec$bridge$target)
      )
    ),
    class = c("hs_bridge_payload", "list")
  )
}

# Supplied-relationship-inverse primary effect (genomic `Ginv` or single-step
# `Hinv`): build Z from the record incidence and carry the user-supplied
# relationship inverse (no pedigree). The engine fits a relationship-inverse-
# based animal_model_spec by REML.
hs_build_relinv_bridge_payload <- function(spec, primary) {
  observed_ids <- primary$values
  ids <- primary$ids
  id_index <- match(observed_ids, ids)

  if (anyNA(id_index)) {
    stop(
      "Internal bridge error: observed IDs are not aligned with the ",
      "relationship-inverse dimnames.",
      call. = FALSE
    )
  }

  Z <- Matrix::sparseMatrix(
    i = seq_along(id_index),
    j = id_index,
    x = 1,
    dims = c(length(id_index), length(ids)),
    dimnames = list(NULL, ids)
  )

  source <- if (is.null(primary$source)) "supplied" else primary$source

  # single_step CONSTRUCTION payload: carry the pedigree (id/sire/dam -> Ainv, A),
  # the genotyped-subset markers (-> G), the genotyped_rows alignment, and the
  # construction knobs. The metafounder variant additionally carries group_of +
  # Gamma for the opt-in supplied-Gamma H^Gamma bridge.
  if (source %in% c("construct", "metafounder_construct")) {
    ped <- primary$pedigree$data
    is_metafounder <- identical(source, "metafounder_construct")
    return(structure(
      list(
        y = as.numeric(spec$response$values),
        Y = NULL,
        X = unname(as.matrix(spec$fixed$design)),
        Z = Z,
        Z2 = NULL,
        effect2 = NULL,
        Ainv = NULL,
        Ginv = NULL,
        markers = unname(as.matrix(primary$markers)),
        marker_names = colnames(primary$markers),
        genotyped_rows = primary$genotyped_rows,
        group_of = primary$group_of,
        Gamma = primary$Gamma,
        gamma_labels = primary$gamma_labels,
        single_step = list(
          tau = primary$tau,
          omega = primary$omega,
          blend_weight = primary$blend_weight,
          ridge = primary$ridge
        ),
        relationship_source = if (is_metafounder) {
          "metafounder_single_step"
        } else {
          "construct"
        },
        relationship = primary$relationship,
        method = spec$method,
        family = spec$family$family,
        ids = ids,
        pedigree = list(id = ped$id, sire = ped$sire, dam = ped$dam),
        metadata = list(
          response = spec$response$name,
          response_type = "univariate",
          trait_names = NULL,
          fixed_colnames = colnames(spec$fixed$design),
          animal_id_column = primary$group,
          observed_ids = observed_ids,
          observed_id_index = id_index,
          fixed_terms = spec$fixed$terms,
          contrasts = spec$fixed$contrasts,
          relationship = primary$relationship,
          n_genotyped = length(primary$genotyped_rows),
          gamma_source = if (is_metafounder) "supplied" else NULL,
          julia_fit_target = paste0("HSquared.", spec$bridge$target)
        )
      ),
      class = c("hs_bridge_payload", "list")
    ))
  }

  marker_names <- NULL
  if (identical(source, "markers")) {
    ginv <- NULL
    marker_names <- colnames(primary$markers)
    markers <- unname(as.matrix(primary$markers))
  } else {
    ginv <- unname(as.matrix(primary$ginv))
    markers <- NULL
  }

  structure(
    list(
      y = as.numeric(spec$response$values),
      Y = NULL,
      X = unname(as.matrix(spec$fixed$design)),
      Z = Z,
      Z2 = NULL,
      effect2 = NULL,
      Ainv = NULL,
      Ginv = ginv,
      markers = markers,
      marker_names = marker_names,
      relationship_source = source,
      ridge = 0.01,
      relationship = primary$relationship,
      method = spec$method,
      family = spec$family$family,
      ids = ids,
      pedigree = NULL,
      metadata = list(
        response = spec$response$name,
        response_type = "univariate",
        trait_names = NULL,
        fixed_colnames = colnames(spec$fixed$design),
        animal_id_column = primary$group,
        observed_ids = observed_ids,
        observed_id_index = id_index,
        fixed_terms = spec$fixed$terms,
        contrasts = spec$fixed$contrasts,
        relationship = primary$relationship,
        julia_fit_target = paste0("HSquared.", spec$bridge$target)
      )
    ),
    class = c("hs_bridge_payload", "list")
  )
}
