#' ggplot2 visualizations for hsquared results
#'
#' `autoplot()` methods render the quantitative-genetic results an
#' `hsquared_fit` (or a `gwas()` scan) carries as `ggplot2` objects, in the
#' style of the `brms`/`bayesplot` ecosystem and consistent with the sister
#' packages `drmTMB`/`gllvmTMB`. They are **uncertainty-first**: where the fit
#' carries the experimental standard errors / reliabilities, the figures show
#' them (clearly labelled experimental and asymptotic).
#'
#' Available `type`s for `autoplot.hsquared_fit()`:
#'
#' * `"variance"` (default) -- a horizontal forest of the variance components
#'   and per-trait `h^2`, each with approximate 95% intervals (`+/- 1.96 * SE`)
#'   when the fit carries the experimental standard errors.
#' * `"breeding_values"` -- a sorted caterpillar of the estimated breeding
#'   values, with `+/- 1.96 * sqrt(PEV)` bands when prediction error variances
#'   are available, faceted by trait for multivariate fits.
#' * `"g_matrix"` -- a **rotation-invariant** genetic-correlation heatmap of the
#'   estimated `G` for multivariate fits (correlations are invariant to the
#'   factor rotation; raw loadings are never plotted -- the ratified cross-lane
#'   convention).
#' * `"reaction_norm"` -- for random-regression fits, the genetic-variance and
#'   heritability trajectories across the covariate (faceted). The heritability
#'   trajectory carries the same caveat as [rr_heritability()]: with a
#'   homogeneous residual and no permanent-environment term it can overstate
#'   `h^2(t)` for repeated-records designs.
#'
#' The figure helpers are deliberately modular (each takes a tidy data frame and
#' returns a `ggplot`) so they can be factored into a shared visualization
#' package later.
#'
#' @param object An `hsquared_fit` or `hs_gwas` object.
#' @param type Which figure to draw (see Details).
#' @param ... Currently unused.
#'
#' @return A `ggplot` object.
#' @name hsquared-autoplot
NULL

#' @importFrom ggplot2 autoplot
#' @importFrom ggplot2 .data
#' @export
ggplot2::autoplot

#' hsquared ggplot2 theme
#'
#' A light, publication-oriented `ggplot2` theme shared by the hsquared
#' `autoplot()` figures. Exported so users can restyle or extend the figures.
#'
#' @param base_size Base font size.
#' @return A `ggplot2` theme object.
#' @export
theme_hsquared <- function(base_size = 12) {
  ggplot2::theme_minimal(base_size = base_size) +
    ggplot2::theme(
      panel.grid.minor = ggplot2::element_blank(),
      plot.title = ggplot2::element_text(face = "bold"),
      plot.subtitle = ggplot2::element_text(colour = "grey35"),
      strip.text = ggplot2::element_text(face = "bold")
    )
}

# --- modular figure builders (tidy data frame -> ggplot) -------------------

# Horizontal forest: data frame with `term`, `estimate`, optional `lo`/`hi`,
# and an optional `panel` grouping for faceting.
hs_gg_forest <- function(
  df,
  xlab = "estimate",
  title = NULL,
  subtitle = NULL,
  zero_line = TRUE
) {
  df$term <- factor(df$term, levels = rev(unique(df$term)))
  has_ci <- all(c("lo", "hi") %in% names(df)) && any(is.finite(df$lo))
  p <- ggplot2::ggplot(df, ggplot2::aes(x = .data$estimate, y = .data$term))
  if (zero_line) {
    p <- p +
      ggplot2::geom_vline(
        xintercept = 0,
        linetype = 3,
        colour = "grey70"
      )
  }
  if (has_ci) {
    p <- p +
      ggplot2::geom_errorbarh(
        ggplot2::aes(xmin = .data$lo, xmax = .data$hi),
        height = 0.18,
        na.rm = TRUE,
        colour = "grey45"
      )
  }
  p <- p + ggplot2::geom_point(size = 2.6, colour = "#2c6fbb")
  if ("panel" %in% names(df)) {
    p <- p +
      ggplot2::facet_grid(
        rows = ggplot2::vars(.data$panel),
        scales = "free",
        space = "free_y"
      )
  }
  p +
    ggplot2::labs(x = xlab, y = NULL, title = title, subtitle = subtitle) +
    theme_hsquared()
}

# --- autoplot.hsquared_fit -------------------------------------------------

#' @rdname hsquared-autoplot
#' @exportS3Method ggplot2::autoplot
autoplot.hsquared_fit <- function(
  object,
  type = c("variance", "breeding_values", "g_matrix", "reaction_norm"),
  ...
) {
  hs_require_ggplot2()
  type <- match.arg(type)
  switch(
    type,
    variance = hs_autoplot_variance(object, ...),
    breeding_values = hs_autoplot_breeding_values(object, ...),
    g_matrix = hs_autoplot_g_matrix(object, ...),
    reaction_norm = hs_autoplot_reaction_norm(object, ...)
  )
}

hs_autoplot_variance <- function(object, ...) {
  vc <- object$result$variance_components
  if (is.null(vc) || !all(c("component", "estimate") %in% names(vc))) {
    stop(
      "This `hsquared_fit` has no variance-component estimates to plot.",
      call. = FALSE
    )
  }
  se <- object$result$variance_component_se
  vc_df <- data.frame(
    term = as.character(vc$component),
    estimate = as.numeric(vc$estimate),
    panel = "variance components",
    stringsAsFactors = FALSE
  )
  vc_df$lo <- NA_real_
  vc_df$hi <- NA_real_
  experimental <- FALSE
  if (!is.null(se) && all(c("component", "se") %in% names(se))) {
    idx <- match(vc_df$term, as.character(se$component))
    sev <- as.numeric(se$se)[idx]
    vc_df$lo <- vc_df$estimate - 1.96 * sev
    vc_df$hi <- vc_df$estimate + 1.96 * sev
    experimental <- any(is.finite(sev))
  }

  # heritability panel (with SE if available)
  her <- object$result$heritability
  if (!is.null(her) && all(c("term", "estimate") %in% names(her))) {
    h_df <- data.frame(
      term = paste0("h\u00b2[", as.character(her$term), "]"),
      estimate = as.numeric(her$estimate),
      panel = "heritability",
      lo = NA_real_,
      hi = NA_real_,
      stringsAsFactors = FALSE
    )
    # `heritability_se` is a scalar SE for univariate fits and may be a
    # per-trait vector for multivariate; recycle a scalar across the h^2 rows.
    hse <- object$result$heritability_se
    if (!is.null(hse)) {
      hsev <- as.numeric(if (is.data.frame(hse)) hse$se else hse)
      if (length(hsev) == 1L) {
        hsev <- rep(hsev, nrow(h_df))
      }
      if (length(hsev) == nrow(h_df)) {
        h_df$lo <- pmax(0, h_df$estimate - 1.96 * hsev)
        h_df$hi <- pmin(1, h_df$estimate + 1.96 * hsev)
        experimental <- experimental || any(is.finite(hsev))
      }
    }
    df <- rbind(vc_df, h_df)
  } else {
    df <- vc_df
  }

  sub <- if (experimental) {
    "experimental +/- 1.96 SE (asymptotic, REML, not coverage-calibrated)"
  } else {
    NULL
  }
  hs_attach_meta(
    hs_gg_forest(
      df,
      xlab = "estimate",
      title = "Variance components and heritability",
      subtitle = sub,
      zero_line = TRUE
    ),
    type = "variance",
    interval_status = if (experimental) "experimental_asymptotic" else "none",
    notes = "variance components + per-trait h^2; SEs asymptotic/REML, not coverage-calibrated"
  )
}

hs_autoplot_breeding_values <- function(object, ...) {
  bv <- tryCatch(breeding_values(object), error = function(e) NULL)
  if (is.null(bv) || !all(c("id", "value") %in% names(bv))) {
    stop(
      "This `hsquared_fit` has no breeding values to plot.",
      call. = FALSE
    )
  }
  bv <- bv[is.finite(bv$value), , drop = FALSE]
  has_trait <- "trait" %in% names(bv)
  # PEV band if available
  pev <- object$result$prediction_error_variance
  if (!is.null(pev) && all(c("id", "value") %in% names(pev))) {
    key <- if (has_trait && "trait" %in% names(pev)) {
      paste(bv$id, bv$trait)
    } else {
      bv$id
    }
    pkey <- if (has_trait && "trait" %in% names(pev)) {
      paste(pev$id, pev$trait)
    } else {
      pev$id
    }
    bv$pev <- as.numeric(pev$value)[match(key, pkey)]
  } else {
    bv$pev <- NA_real_
  }
  # rank within trait (or overall)
  split_key <- if (has_trait) bv$trait else rep("1", nrow(bv))
  bv$rank <- stats::ave(
    bv$value,
    split_key,
    FUN = function(v) rank(v, ties.method = "first")
  )
  bv$lo <- bv$value - 1.96 * sqrt(bv$pev)
  bv$hi <- bv$value + 1.96 * sqrt(bv$pev)
  has_band <- any(is.finite(bv$lo))

  p <- ggplot2::ggplot(bv, ggplot2::aes(x = .data$rank, y = .data$value)) +
    ggplot2::geom_hline(yintercept = 0, linetype = 3, colour = "grey70")
  if (has_band) {
    p <- p +
      ggplot2::geom_ribbon(
        ggplot2::aes(ymin = .data$lo, ymax = .data$hi),
        fill = "#2c6fbb",
        alpha = 0.18,
        na.rm = TRUE
      )
  }
  p <- p + ggplot2::geom_point(size = 1.2, colour = "#2c6fbb", na.rm = TRUE)
  if (has_trait) {
    p <- p + ggplot2::facet_wrap(ggplot2::vars(.data$trait), scales = "free")
  }
  sub <- if (has_band) {
    "sorted EBVs with +/- 1.96 sqrt(PEV) bands"
  } else {
    "sorted EBVs (no prediction error variances available)"
  }
  hs_attach_meta(
    p +
      ggplot2::labs(
        x = "rank",
        y = "breeding value",
        title = "Estimated breeding values",
        subtitle = sub
      ) +
      theme_hsquared(),
    type = "breeding_values",
    interval_status = if (has_band) "pev_band" else "none",
    notes = "sorted EBVs; bands are +/- 1.96 sqrt(PEV) when available"
  )
}

hs_autoplot_g_matrix <- function(object, ...) {
  rg <- tryCatch(genetic_correlation(object), error = function(e) NULL)
  if (is.null(rg) || !is.matrix(rg) || nrow(rg) < 2L) {
    stop(
      "`type = \"g_matrix\"` needs a multivariate fit with a genetic ",
      "correlation matrix (rotation-invariant). Fit with ",
      "`engine_control = list(target = \"multivariate\")`.",
      call. = FALSE
    )
  }
  traits <- rownames(rg)
  if (is.null(traits)) {
    traits <- paste0("trait", seq_len(nrow(rg)))
  }
  df <- expand.grid(
    row = factor(traits, levels = traits),
    col = factor(traits, levels = rev(traits)),
    stringsAsFactors = FALSE
  )
  df$value <- as.numeric(rg[cbind(
    match(df$row, traits),
    match(df$col, traits)
  )])
  df$label <- formatC(df$value, format = "f", digits = 2)
  hs_attach_meta(
    ggplot2::ggplot(
      df,
      ggplot2::aes(x = .data$row, y = .data$col, fill = .data$value)
    ) +
      ggplot2::geom_tile(colour = "white", linewidth = 0.6) +
      ggplot2::geom_text(ggplot2::aes(label = .data$label), size = 3.4) +
      ggplot2::scale_fill_gradient2(
        low = "#b2182b",
        mid = "white",
        high = "#2166ac",
        midpoint = 0,
        limits = c(-1, 1),
        name = "genetic\ncorrelation"
      ) +
      ggplot2::coord_equal() +
      ggplot2::labs(
        x = NULL,
        y = NULL,
        title = "Genetic correlation (G)",
        subtitle = "rotation-invariant; raw loadings are never plotted"
      ) +
      theme_hsquared(),
    type = "g_matrix",
    rotation_status = "rotation_invariant",
    notes = "genetic correlations only; raw factor loadings are never plotted"
  )
}

hs_autoplot_reaction_norm <- function(object, at = NULL, n = 25L, ...) {
  # rr_genetic_variance()/rr_heritability() reject non-RR fits with a clear
  # message, so no extra guard is needed here.
  vg <- rr_genetic_variance(object, at = at, n = n)
  h2 <- rr_heritability(object, at = at, n = n)
  df <- rbind(
    data.frame(
      covariate = vg$covariate,
      value = vg$value,
      panel = "genetic variance",
      stringsAsFactors = FALSE
    ),
    data.frame(
      covariate = h2$covariate,
      value = h2$value,
      panel = "heritability",
      stringsAsFactors = FALSE
    )
  )
  df$panel <- factor(df$panel, levels = c("genetic variance", "heritability"))
  hs_attach_meta(
    ggplot2::ggplot(df, ggplot2::aes(x = .data$covariate, y = .data$value)) +
      ggplot2::geom_line(colour = "#2c6fbb", linewidth = 0.8) +
      ggplot2::geom_point(size = 1.4, colour = "#2c6fbb") +
      ggplot2::facet_wrap(
        ggplot2::vars(.data$panel),
        scales = "free_y",
        ncol = 1L
      ) +
      ggplot2::labs(
        x = "covariate",
        y = NULL,
        title = "Reaction norm (random regression)",
        subtitle = paste(
          "genetic-variance and heritability trajectories;",
          "h2(t) experimental (homogeneous residual, no PE term)"
        )
      ) +
      theme_hsquared(),
    type = "reaction_norm",
    notes = "supplied-K_g descriptive trajectories; h2(t) can overstate without a PE term"
  )
}

# --- autoplot.hs_gwas (Manhattan) ------------------------------------------

#' @rdname hsquared-autoplot
#' @exportS3Method ggplot2::autoplot
autoplot.hs_gwas <- function(object, ...) {
  hs_require_ggplot2()
  df <- as.data.frame(object)
  if (!all(c("p_value") %in% names(df))) {
    stop(
      "This `hs_gwas` object has no `p_value` column to plot.",
      call. = FALSE
    )
  }
  df$index <- seq_len(nrow(df))
  df$neglog10p <- -log10(pmax(df$p_value, .Machine$double.xmin))
  m <- nrow(df)
  bonf <- -log10(0.05 / m)
  hs_attach_meta(
    ggplot2::ggplot(df, ggplot2::aes(x = .data$index, y = .data$neglog10p)) +
      ggplot2::geom_hline(
        yintercept = bonf,
        linetype = 2,
        colour = "#b2182b"
      ) +
      ggplot2::geom_point(size = 1.3, colour = "#2c6fbb") +
      ggplot2::annotate(
        "text",
        x = 1,
        y = bonf,
        vjust = -0.5,
        hjust = 0,
        size = 3,
        colour = "#b2182b",
        label = "Bonferroni 0.05"
      ) +
      ggplot2::labs(
        x = "marker",
        y = expression(-log[10](p)),
        title = "Marker scan (Manhattan)",
        subtitle = paste(
          "EXPERIMENTAL: nominal Wald p-values, NOT genome-wide",
          "calibrated (gate HSquared.jl#48)"
        )
      ) +
      theme_hsquared(),
    type = "manhattan",
    source = "gwas",
    interval_status = "uncalibrated",
    notes = "nominal Wald p-values; Bonferroni line is visual only; not genome-wide calibrated (gate #48)"
  )
}

# --- recovery forest (validation-study data frame) -------------------------

#' Forest plot of a known-truth recovery study
#'
#' Visualizes a bias +/- 2*MCSE recovery study (e.g.
#' `data-raw/multivariate-recovery-study.R`): each target's bias with its
#' +/- 2*MCSE interval and a zero-bias reference line. Targets whose interval
#' covers zero show "no detectable bias".
#'
#' @param data A data frame with `target`, `bias`, and `mcse` columns.
#' @return A `ggplot` object.
#' @export
hs_recovery_forest <- function(data) {
  hs_require_ggplot2()
  if (!all(c("target", "bias", "mcse") %in% names(data))) {
    stop(
      "`data` must have `target`, `bias`, and `mcse` columns.",
      call. = FALSE
    )
  }
  df <- data.frame(
    term = as.character(data$target),
    estimate = as.numeric(data$bias),
    lo = as.numeric(data$bias) - 2 * as.numeric(data$mcse),
    hi = as.numeric(data$bias) + 2 * as.numeric(data$mcse),
    stringsAsFactors = FALSE
  )
  df$covers0 <- df$lo <= 0 & df$hi >= 0
  hs_attach_meta(
    hs_gg_forest(
      df,
      xlab = "bias (mean(hat) - truth)",
      title = "Known-truth recovery (bias +/- 2 MCSE)",
      subtitle = "intervals covering 0 indicate no detectable bias",
      zero_line = TRUE
    ),
    type = "recovery_forest",
    source = "study",
    interval_status = "mcse_band",
    notes = "bias +/- 2 MCSE; interval covering 0 = no detectable bias"
  )
}

# --- helper ----------------------------------------------------------------

hs_require_ggplot2 <- function() {
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop(
      "The hsquared plotting layer requires the `ggplot2` package.",
      call. = FALSE
    )
  }
  invisible(TRUE)
}

# Attach the cross-lane honest-status meta (the `13-plotting-layer.md` §3
# contract, mirroring gllvmTMB/drmTMB): machine-readable type / source /
# interval / rotation status + caveat notes, alongside the human-readable
# subtitle, so the honest-status guardrails are inspectable, not just printed.
hs_attach_meta <- function(
  p,
  type,
  source = "fit",
  interval_status = "none",
  rotation_status = "not_applicable",
  notes = NULL
) {
  attr(p, "hsquared_meta") <- list(
    type = type,
    source = source,
    interval_status = interval_status,
    rotation_status = rotation_status,
    notes = notes
  )
  p
}
