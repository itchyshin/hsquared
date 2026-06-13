hs_tiny_animal_validation_fixture <- function() {
  pedigree <- data.frame(
    id = c("calf", "sire", "dam"),
    sire = c("sire", NA, NA),
    dam = c("dam", NA, NA),
    stringsAsFactors = FALSE
  )
  data <- data.frame(
    y = c(1.2, 1.8, 2.6),
    age = c(0, 1, 2),
    id = c("sire", "dam", "calf"),
    stringsAsFactors = FALSE
  )

  formula <- y ~ age + animal(1 | id, pedigree = pedigree)
  ids <- c("sire", "dam", "calf")
  Ainv <- matrix(
    c(
      1.5,
      0.5,
      -1,
      0.5,
      1.5,
      -1,
      -1,
      -1,
      2
    ),
    nrow = 3,
    byrow = TRUE,
    dimnames = list(ids, ids)
  )

  list(
    name = "tiny_henderson_calf",
    description = paste(
      "Three-animal Henderson-style pedigree fixture for parser, bridge,",
      "and sparse Ainv validation."
    ),
    formula = formula,
    data = data,
    pedigree = pedigree,
    expected = list(
      ids = ids,
      sire_index = c(0L, 0L, 1L),
      dam_index = c(0L, 0L, 2L),
      Z = diag(3),
      Ainv = Ainv
    )
  )
}

hs_mrode9_pedigree_validation_fixture <- function() {
  if (!requireNamespace("nadiv", quietly = TRUE)) {
    stop(
      "The optional `nadiv` package is required for the Mrode9 validation ",
      "fixture.",
      call. = FALSE
    )
  }

  env <- new.env(parent = emptyenv())
  utils::data("Mrode9", package = "nadiv", envir = env)
  pedigree <- env$Mrode9[, c("pig", "sire", "dam")]
  names(pedigree) <- c("id", "sire", "dam")
  pedigree$id <- as.character(pedigree$id)
  pedigree$sire <- as.character(pedigree$sire)
  pedigree$dam <- as.character(pedigree$dam)
  pedigree$sire[is.na(pedigree$sire)] <- NA_character_
  pedigree$dam[is.na(pedigree$dam)] <- NA_character_

  ainv <- nadiv::makeAinv(pedigree)$Ainv
  colnames(ainv) <- rownames(ainv)

  list(
    name = "mrode9_nadiv_pedigree",
    description = paste(
      "Pedigree adapted from Mrode example 9.1 as shipped by nadiv; used",
      "for optional sparse Ainv comparator validation."
    ),
    source = paste(
      "nadiv::Mrode9, documented as adapted from example 9.1 of Mrode",
      "(2005), Linear Models for the Prediction of Animal Breeding Values."
    ),
    pedigree = pedigree,
    expected = list(Ainv = ainv)
  )
}
