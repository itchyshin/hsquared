#' Post-fit relatedness-corrected marker scan (GWAS)
#'
#' `gwas()` runs a dense, supplied-variance, relatedness-corrected mixed-model
#' (GLS) Wald marker scan on a fitted Gaussian animal model, reusing the fit's
#' estimated variance components `(σ²a, σ²e)` and pedigree relationship. It is an
#' experimental, validation-scale screen that surfaces the Julia-owned
#' `HSquared.mixed_model_marker_scan()`.
#'
#' **The p-values are NOT genome-wide calibrated.** They are marker-by-marker
#' Wald (nominal) p-values plus deterministic Bonferroni and Benjamini-Hochberg
#' adjustments over the *supplied* marker set only. There is no realistic-LD /
#' study-design calibration, no permutation, and no external comparator (the
#' calibration gate is `HSquared.jl#48`). A leave-one-group-out (LOCO) scan is
#' available engine-side (`HSquared.loco_mixed_model_marker_scan()`); this R
#' `gwas()` wrapper does **not** yet surface it (R LOCO surfacing is in
#' progress), so the scan it runs applies one whole-pedigree relationship
#' correction across all markers. Do not report genome-wide significance from
#' these values.
#'
#' @param object A fitted Gaussian animal model (`hsquared_fit` from the default
#'   pedigree path); its variance components and pedigree relationship are reused
#'   so the scan is conditioned on the same covariance the model was fit under.
#' @param markers A numeric matrix of marker dosages with one row per animal in
#'   the fit's pedigree (in pedigree order) and one column per marker.
#' @param marker_ids Optional marker names; defaults to the `markers` column
#'   names, then to sequential ids.
#' @param method `"mixed"` (default) for the relatedness-corrected mixed-model
#'   (GLS) scan, or `"single"` for the relatedness-**un**corrected single-marker
#'   (OLS) scan. The single-marker scan ignores the pedigree relationship — it is
#'   a naive screen useful mainly as a contrast (it is more inflated by relatedness
#'   than the mixed scan).
#' @param ... Unused.
#'
#' @return An `hs_gwas` data frame with one row per marker: `marker`, `effect`,
#'   `se`, `z`, `chisq`, `p_value`, `bonferroni_p`, `bh_qvalue`, `lod`, carrying a
#'   `scan_method` attribute. Its `print()` method restates the
#'   uncalibrated-significance caveat (and, for `method = "single"`, the absence of
#'   any relatedness correction).
#' @export
gwas <- function(
  object,
  markers,
  marker_ids = NULL,
  method = c("mixed", "single"),
  ...
) {
  UseMethod("gwas")
}

#' @export
gwas.default <- function(
  object,
  markers,
  marker_ids = NULL,
  method = c("mixed", "single"),
  ...
) {
  stop(
    "`gwas()` requires a fitted Gaussian animal model (`hsquared_fit`).",
    call. = FALSE
  )
}

#' @export
gwas.hsquared_fit <- function(
  object,
  markers,
  marker_ids = NULL,
  method = c("mixed", "single"),
  ...
) {
  method <- match.arg(method)
  hs_validate_gwas_fit(object)
  payload <- object$payload
  vc <- object$result$variance_components
  sigma_a2 <- vc$estimate[vc$component == "animal"][[1L]]
  sigma_e2 <- vc$estimate[vc$component == "residual"][[1L]]

  markers <- hs_validate_gwas_markers(markers, payload)
  marker_ids <- hs_gwas_marker_ids(marker_ids, markers)

  project <- hs_default_julia_project()
  if (!hs_julia_bridge_available(project)) {
    stop(
      "The experimental Julia bridge requires Julia, the `JuliaCall` R ",
      "package, and a local `HSquared.jl` project.",
      call. = FALSE
    )
  }
  markers_rec <- as.matrix(payload$Z %*% markers)

  hs_julia_setup(project)
  JuliaCall::julia_assign("hsq_y", payload$y)
  JuliaCall::julia_assign("hsq_X", payload$X)
  JuliaCall::julia_assign("hsq_markers", markers_rec)
  JuliaCall::julia_assign("hsq_sigma_e2", as.numeric(sigma_e2))
  JuliaCall::julia_assign("hsq_marker_ids", as.character(marker_ids))
  if (identical(method, "mixed")) {
    hs_julia_assign_sparse_csc("hsq_Z", payload$Z)
    JuliaCall::julia_assign("hsq_id", payload$pedigree$id)
    JuliaCall::julia_assign(
      "hsq_sire",
      hs_parent_for_julia(payload$pedigree$sire)
    )
    JuliaCall::julia_assign(
      "hsq_dam",
      hs_parent_for_julia(payload$pedigree$dam)
    )
    JuliaCall::julia_assign("hsq_sigma_a2", as.numeric(sigma_a2))
    scan_cmd <- paste(
      "hsq_ped = HSquared.normalize_pedigree(hsq_id, hsq_sire, hsq_dam);",
      "hsq_Ainv = HSquared.pedigree_inverse(hsq_ped);",
      "hsq_scan = HSquared.mixed_model_marker_scan(",
      "hsq_y, hsq_X, hsq_Z, hsq_Ainv, hsq_markers, hsq_sigma_a2, hsq_sigma_e2;",
      "marker_ids = hsq_marker_ids);"
    )
  } else {
    # relatedness-UNcorrected single-marker (OLS) scan: no Z / Ainv / sigma_a2
    scan_cmd <- paste(
      "hsq_scan = HSquared.single_marker_scan(",
      "hsq_y, hsq_X, hsq_markers;",
      "sigma_e2 = hsq_sigma_e2, marker_ids = hsq_marker_ids);"
    )
  }
  JuliaCall::julia_command(paste(
    scan_cmd,
    "hsq_gwas_raw = Dict(",
    "\"marker_ids\" => string.(collect(hsq_scan.marker_ids)),",
    "\"effects\" => collect(Float64, hsq_scan.effects),",
    "\"standard_errors\" => collect(Float64, hsq_scan.standard_errors),",
    "\"z_scores\" => collect(Float64, hsq_scan.z_scores),",
    "\"chisq\" => collect(Float64, hsq_scan.chisq),",
    "\"p_values\" => collect(Float64, hsq_scan.p_values),",
    "\"bonferroni\" => collect(Float64, hsq_scan.bonferroni_p_values),",
    "\"bh\" => collect(Float64, hsq_scan.bh_q_values),",
    "\"lod\" => collect(Float64, hsq_scan.lod_scores)",
    ");"
  ))
  raw <- JuliaCall::julia_eval("hsq_gwas_raw")
  hs_normalize_gwas_result(raw, method = method)
}

# A gwas() fit must be the default univariate Gaussian pedigree animal model:
# it reuses the fit's pedigree relationship and additive/residual variance
# components for a relatedness-corrected scan.
hs_validate_gwas_fit <- function(object) {
  family <- object$spec$family$family %||% "gaussian"
  if (!identical(family, "gaussian")) {
    stop(
      "`gwas()` reuses an additive/residual variance decomposition, so it needs ",
      "a Gaussian animal-model fit; `",
      family,
      "` fits are not supported.",
      call. = FALSE
    )
  }
  payload <- object$payload
  if (
    is.null(payload$pedigree) ||
      is.null(payload$Z) ||
      is.null(payload$y) ||
      is.null(payload$X)
  ) {
    stop(
      "`gwas()` requires a fitted pedigree animal model (the default ",
      "`hsquared(y ~ ... + animal(1 | id, pedigree = ped))` path).",
      call. = FALSE
    )
  }
  vc <- object$result$variance_components
  if (
    is.null(vc) ||
      !is.data.frame(vc) ||
      !all(c("animal", "residual") %in% vc$component)
  ) {
    stop(
      "`gwas()` needs a fit reporting `animal` and `residual` variance ",
      "components; multivariate, genomic, single-step, SNP-BLUP, and ",
      "second-effect fits are not supported.",
      call. = FALSE
    )
  }
  invisible(TRUE)
}

hs_validate_gwas_markers <- function(markers, payload) {
  if (is.null(markers)) {
    stop("`markers` is required.", call. = FALSE)
  }
  markers <- as.matrix(markers)
  if (!is.numeric(markers)) {
    stop("`markers` must be a numeric matrix.", call. = FALSE)
  }
  n_animals <- length(payload$pedigree$id)
  if (nrow(markers) != n_animals) {
    stop(
      "`markers` must have one row per animal in the fit's pedigree (",
      n_animals,
      " rows, in pedigree order); got ",
      nrow(markers),
      ".",
      call. = FALSE
    )
  }
  if (ncol(markers) < 1L) {
    stop("`markers` must have at least one marker column.", call. = FALSE)
  }
  if (any(!is.finite(markers))) {
    stop("`markers` must contain only finite dosages.", call. = FALSE)
  }
  storage.mode(markers) <- "double"
  markers
}

hs_gwas_marker_ids <- function(marker_ids, markers) {
  if (!is.null(marker_ids)) {
    if (length(marker_ids) != ncol(markers)) {
      stop(
        "`marker_ids` must have one entry per marker column (",
        ncol(markers),
        ").",
        call. = FALSE
      )
    }
    return(as.character(marker_ids))
  }
  labels <- colnames(markers)
  if (is.null(labels) || length(labels) != ncol(markers)) {
    labels <- as.character(seq_len(ncol(markers)))
  }
  labels
}

hs_normalize_gwas_result <- function(raw, method = "mixed") {
  out <- data.frame(
    marker = as.character(raw$marker_ids),
    effect = as.numeric(raw$effects),
    se = as.numeric(raw$standard_errors),
    z = as.numeric(raw$z_scores),
    chisq = as.numeric(raw$chisq),
    p_value = as.numeric(raw$p_values),
    bonferroni_p = as.numeric(raw$bonferroni),
    bh_qvalue = as.numeric(raw$bh),
    lod = as.numeric(raw$lod),
    stringsAsFactors = FALSE
  )
  class(out) <- c("hs_gwas", "data.frame")
  attr(out, "scan_method") <- method
  out
}

#' @export
print.hs_gwas <- function(x, ...) {
  method <- attr(x, "scan_method") %||% "mixed"
  if (identical(method, "single")) {
    cat(
      "<hs_gwas> dense single-marker (OLS) scan -- relatedness-UNcorrected\n"
    )
    cat(
      "  EXPERIMENTAL: no pedigree/relatedness correction (a naive contrast to\n"
    )
    cat(
      "  the relatedness-corrected `method = \"mixed\"` scan); p-values are NOT\n"
    )
    cat(
      "  genome-wide calibrated (nominal Wald + Bonferroni/BH only). Do not\n"
    )
    cat("  report genome-wide significance from these.\n")
    out <- x
    class(out) <- "data.frame"
    attr(out, "scan_method") <- NULL
    print(utils::head(out, ...), row.names = FALSE)
    return(invisible(x))
  }
  cat("<hs_gwas> dense supplied-variance relatedness-corrected marker scan\n")
  cat(
    "  EXPERIMENTAL: p-values are NOT genome-wide calibrated. They are nominal\n"
  )
  cat(
    "  Wald p-values + Bonferroni/BH over the supplied markers only (one whole-\n"
  )
  cat(
    "  pedigree correction; no permutation, no external comparator; engine gate\n"
  )
  cat(
    "  HSquared.jl#48). LOCO exists engine-side but is not yet surfaced here.\n"
  )
  cat("  Do not report genome-wide significance from these.\n")
  out <- x
  class(out) <- "data.frame"
  print(utils::head(out, ...), row.names = FALSE)
  invisible(x)
}
