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
