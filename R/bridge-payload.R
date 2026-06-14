hs_build_bridge_payload <- function(spec) {
  animal <- spec$random$animal
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

  # Second design matrix `Z2` for the opt-in common-environment effect: an IID
  # incidence of records on the environmental grouping levels (relationship I).
  Z2 <- NULL
  effect2 <- NULL
  common_env <- spec$random$common_env
  if (!is.null(common_env)) {
    env_levels <- common_env$levels
    env_index <- match(common_env$values, env_levels)
    Z2 <- Matrix::sparseMatrix(
      i = seq_along(env_index),
      j = env_index,
      x = 1,
      dims = c(length(env_index), length(env_levels)),
      dimnames = list(NULL, env_levels)
    )
    effect2 <- list(
      type = "common_env",
      group = common_env$group,
      levels = env_levels,
      relationship = "identity"
    )
  }

  structure(
    list(
      y = as.numeric(spec$response$values),
      X = unname(as.matrix(spec$fixed$design)),
      Z = Z,
      Z2 = Z2,
      effect2 = effect2,
      Ainv = NULL,
      method = spec$method,
      family = spec$family$family,
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
        fixed_colnames = colnames(spec$fixed$design),
        animal_id_column = animal$group,
        observed_ids = observed_ids,
        observed_id_index = id_index,
        fixed_terms = spec$fixed$terms,
        contrasts = spec$fixed$contrasts,
        ainv_status = "build_in_julia",
        ainv_target = paste0(
          "HSquared.pedigree_inverse(",
          "HSquared.normalize_pedigree(id, sire, dam))"
        ),
        julia_spec_target = paste0(
          "HSquared.animal_model_spec(y, X, Z, Ainv; ",
          "ids = ids, method = :",
          spec$method,
          ")"
        ),
        julia_fit_target = "HSquared.fit_animal_model(spec)"
      )
    ),
    class = c("hs_bridge_payload", "list")
  )
}
