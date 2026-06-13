#' Create an hsquared data container
#'
#' `hs_data()` collects phenotype, pedigree, genotype, marker, expression,
#' annotation, and environment inputs into one checked container. It is a
#' lightweight data-contract object for future genomic, QTL/eQTL, and
#' multi-omics workflows. It does not fit models. The v0.1 parser can use an
#' `hs_data` object directly as `data`, reading model variables from
#' `phenotypes` and making named components such as `pedigree` available to
#' formula terms.
#'
#' @param phenotypes A data frame of phenotypic records.
#' @param pedigree Optional pedigree data frame.
#' @param genotypes Optional genotype matrix or data frame.
#' @param markers Optional marker map data frame.
#' @param expression Optional expression matrix or data frame.
#' @param annotation Optional annotation data frame.
#' @param environment Optional environment/covariate data frame.
#' @param id Name of the individual ID column in `phenotypes`.
#'
#' @return An `hs_data` object.
#' @export
hs_data <- function(
  phenotypes,
  pedigree = NULL,
  genotypes = NULL,
  markers = NULL,
  expression = NULL,
  annotation = NULL,
  environment = NULL,
  id = "id"
) {
  if (!is.data.frame(phenotypes)) {
    stop("`phenotypes` must be a data frame.", call. = FALSE)
  }
  if (!is.character(id) || length(id) != 1L || is.na(id) || id == "") {
    stop("`id` must be one non-empty column name.", call. = FALSE)
  }
  if (!id %in% names(phenotypes)) {
    stop("`id` column `", id, "` was not found in `phenotypes`.", call. = FALSE)
  }

  phenotype_ids <- hs_checked_ids(phenotypes[[id]], "`phenotypes`")
  pedigree_ids <- hs_data_pedigree_ids(pedigree, phenotype_ids)
  genotype_ids <- hs_optional_component_ids(genotypes, id, "`genotypes`")
  expression_ids <- hs_optional_component_ids(expression, id, "`expression`")

  hs_validate_optional_data_frame(markers, "`markers`")
  hs_validate_optional_data_frame(annotation, "`annotation`")
  hs_validate_optional_data_frame(environment, "`environment`")

  structure(
    list(
      phenotypes = phenotypes,
      pedigree = pedigree,
      genotypes = genotypes,
      markers = markers,
      expression = expression,
      annotation = annotation,
      environment = environment,
      id = id,
      id_map = list(
        phenotype_ids = unique(phenotype_ids),
        pedigree_ids = pedigree_ids,
        genotype_ids = genotype_ids,
        expression_ids = expression_ids,
        phenotypes_without_pedigree = setdiff(
          unique(phenotype_ids),
          pedigree_ids
        ),
        phenotypes_without_genotypes = setdiff(
          unique(phenotype_ids),
          genotype_ids
        ),
        genotypes_without_phenotypes = setdiff(
          genotype_ids,
          unique(phenotype_ids)
        ),
        phenotypes_without_expression = setdiff(
          unique(phenotype_ids),
          expression_ids
        ),
        expression_without_phenotypes = setdiff(
          expression_ids,
          unique(phenotype_ids)
        )
      )
    ),
    class = "hs_data"
  )
}

#' @export
print.hs_data <- function(x, ...) {
  cat("<hs_data>\n")
  cat("  phenotypes: ", nrow(x$phenotypes), " rows\n", sep = "")
  cat("  phenotype IDs: ", length(x$id_map$phenotype_ids), "\n", sep = "")
  hs_print_component_count("pedigree IDs", x$id_map$pedigree_ids)
  hs_print_component_count("genotype IDs", x$id_map$genotype_ids)
  hs_print_component_count("expression IDs", x$id_map$expression_ids)
  invisible(x)
}

#' @export
summary.hs_data <- function(object, ...) {
  structure(
    list(
      components = names(Filter(Negate(is.null), unclass(object)))[
        names(Filter(Negate(is.null), unclass(object))) %in%
          c(
            "phenotypes",
            "pedigree",
            "genotypes",
            "markers",
            "expression",
            "annotation",
            "environment"
          )
      ],
      id_map = object$id_map,
      id_overlap = hs_data_id_overlap(object$id_map)
    ),
    class = "summary_hs_data"
  )
}

#' @export
print.summary_hs_data <- function(x, ...) {
  cat("<summary_hs_data>\n")
  cat("  components: ", paste(x$components, collapse = ", "), "\n", sep = "")
  cat("  phenotype IDs: ", length(x$id_map$phenotype_ids), "\n", sep = "")
  cat("  ID overlap:\n", sep = "")
  print.data.frame(x$id_overlap, row.names = FALSE)
  invisible(x)
}

hs_data_id_overlap <- function(id_map) {
  data.frame(
    metric = c(
      "phenotype_ids",
      "pedigree_ids",
      "genotype_ids",
      "expression_ids",
      "phenotypes_without_pedigree",
      "phenotypes_without_genotypes",
      "genotypes_without_phenotypes",
      "phenotypes_without_expression",
      "expression_without_phenotypes"
    ),
    count = c(
      length(id_map$phenotype_ids),
      length(id_map$pedigree_ids),
      length(id_map$genotype_ids),
      length(id_map$expression_ids),
      length(id_map$phenotypes_without_pedigree),
      length(id_map$phenotypes_without_genotypes),
      length(id_map$genotypes_without_phenotypes),
      length(id_map$phenotypes_without_expression),
      length(id_map$expression_without_phenotypes)
    ),
    stringsAsFactors = FALSE
  )
}

hs_checked_ids <- function(x, label) {
  ids <- as.character(x)
  if (any(is.na(ids) | ids == "" | ids == "0")) {
    stop(label, " IDs cannot be missing, empty, or `0`.", call. = FALSE)
  }
  ids
}

hs_data_pedigree_ids <- function(pedigree, phenotype_ids) {
  if (is.null(pedigree)) {
    return(character())
  }
  if (!is.data.frame(pedigree)) {
    stop("`pedigree` must be a data frame when supplied.", call. = FALSE)
  }
  if (ncol(pedigree) < 3L) {
    stop(
      "`pedigree` must have at least three columns: `id`, `sire`, and `dam`.",
      call. = FALSE
    )
  }

  cols <- hs_pedigree_columns(pedigree)
  pedigree_ids <- hs_checked_ids(pedigree[[cols$id]], "`pedigree`")
  missing <- setdiff(unique(phenotype_ids), pedigree_ids)
  if (length(missing) > 0L) {
    stop(
      "`phenotypes` contain ID",
      if (length(missing) > 1L) "s" else "",
      " not present in `pedigree`: ",
      paste(missing, collapse = ", "),
      ".",
      call. = FALSE
    )
  }

  unique(pedigree_ids)
}

hs_optional_component_ids <- function(x, id, label) {
  if (is.null(x)) {
    return(character())
  }
  if (is.data.frame(x)) {
    if (id %in% names(x)) {
      return(unique(hs_checked_ids(x[[id]], label)))
    }
    if (hs_has_explicit_rownames(x)) {
      return(unique(hs_checked_ids(rownames(x), label)))
    }
    stop(
      label,
      " must contain ID column `",
      id,
      "` or non-missing row names.",
      call. = FALSE
    )
  }
  if (is.matrix(x)) {
    if (is.null(rownames(x))) {
      stop(
        label,
        " matrix must have individual IDs as row names.",
        call. = FALSE
      )
    }
    return(unique(hs_checked_ids(rownames(x), label)))
  }

  stop(label, " must be a data frame or matrix when supplied.", call. = FALSE)
}

hs_has_explicit_rownames <- function(x) {
  row_names <- attr(x, "row.names")
  !is.null(row_names) && !is.integer(row_names)
}

hs_validate_optional_data_frame <- function(x, label) {
  if (!is.null(x) && !is.data.frame(x)) {
    stop(label, " must be a data frame when supplied.", call. = FALSE)
  }
  invisible(TRUE)
}

hs_print_component_count <- function(label, ids) {
  if (length(ids) > 0L) {
    cat("  ", label, ": ", length(ids), "\n", sep = "")
  }
}
