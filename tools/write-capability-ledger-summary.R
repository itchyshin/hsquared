#!/usr/bin/env Rscript
# Generate vignettes/articles/includes/capability-ledger-summary.md from
# validation_status(). A17 phase 3 (docs IA), plan section 4b.
#
# Run from the package root:
#
#   Rscript tools/write-capability-ledger-summary.R
#
# The route table below is keyed to exact `validation_status()$capability`
# strings. If a key disappears or its `status` changes, generation ABORTS
# instead of emitting a stale reader permission. That drift guard is the point
# of the script: the reader-facing wording cannot outlive the evidence row it
# was written against.

hs_route_table <- function() {
  list(
    list(
      key = "univariate Gaussian animal-model fit (default path, AI-REML)",
      expect = "covered",
      title = "Univariate Gaussian animal model (the default path)",
      call = 'hsquared(y ~ sex + animal(1 | id, pedigree = ped), data = dat)',
      scope = paste(
        "One additive genetic effect, Gaussian response, REML only, fitted by",
        "average-information REML on the sparse mixed-model equations. Known-truth",
        "recovery is near-unbiased across an h2 grid of 0.2/0.4/0.6; the",
        "near-boundary cell h2 = 0.1 shows mild upward bias and 5% boundary",
        "pinning. ML is rejected on this path."
      ),
      point = "yes",
      interval = "no",
      fallback = paste(
        "None needed - this is the recommended route. For a model with a second",
        "random effect, see the two-effect card below."
      )
    ),
    list(
      key = paste0(
        "two-effect / arbitrary-N independent-effect estimator (opt-in; ",
        "covered: common-env + (1|g) iid / A2=I; experimental: maternal / A2=pedigree)"
      ),
      expect = "covered",
      title = "Animal model plus independent extra effects (common environment, arbitrary N)",
      call = paste0(
        'hsquared(y ~ animal(1 | id, pedigree = ped) + common_env(1 | group),\n',
        '         data = dat, control = hs_control(engine = "julia"))'
      ),
      scope = paste(
        "The common-environment leg (additive animal A plus i.i.d. environment,",
        "A2 = I) and the arbitrary-N generalization to independent i.i.d. effects",
        "are covered at validation scale on a pre-declared 48-seed recovery gate",
        "with an external same-estimand REML comparator. The animal-block ratio is",
        "narrow-sense h2; other blocks are variance-explained proportions, NOT",
        "heritabilities. Independent effects only - correlated, random-regression,",
        "and non-Gaussian structures are not this route."
      ),
      point = "yes",
      interval = "no",
      fallback = paste(
        "The maternal-genetic leg (`maternal_genetic()`, A2 = pedigree A) runs on",
        "the same estimator but is still experimental: its own recovery gate and",
        "comparator are owed. Use the covered common-environment route, or treat a",
        "maternal fit as exploratory."
      )
    ),
    list(
      key = "experimental sparse REML estimator (opt-in)",
      expect = "partial",
      title = "Sparse REML variance components (opt-in engine target)",
      call = paste0(
        'hsquared(y ~ animal(1 | id, pedigree = ped), data = dat,\n',
        '         control = hs_control(engine = "julia",\n',
        '           engine_control = list(target = "sparse_reml")))'
      ),
      scope = paste(
        "Reaches the same REML optimum as the default path and is cross-checked",
        "against an independent pure-R REML optimizer and the external",
        "`pedigreemm` package. It exists as an engine-target check, not as a",
        "separate user-facing model."
      ),
      point = "partial",
      interval = "no",
      fallback = "Use the default `hsquared()` call, which is the covered route to the same estimates."
    ),
    list(
      key = "experimental repeatability estimator (opt-in)",
      expect = "partial",
      title = "Repeatability / permanent environment (repeated records)",
      call = paste0(
        'hsquared(y ~ animal(1 | id, pedigree = ped) + permanent(1 | id), data = dat,\n',
        '         control = hs_control(engine = "julia"))'
      ),
      scope = paste(
        "REML-only repeatability optimizer returning additive, permanent-environment,",
        "and residual variances. Va and Vpe are only identifiable with repeated",
        "records per individual. No comparator and no known-truth recovery gate yet."
      ),
      point = "partial",
      interval = "no",
      fallback = paste(
        "Fit the covered univariate animal model on individual means, or run your",
        "own comparator (for example `sommer`) alongside before reporting."
      )
    ),
    list(
      key = "experimental supplied-relationship estimator (opt-in: genomic, single-step)",
      expect = "partial",
      title = "Genomic (GREML) and single-step relationship models",
      call = paste0(
        'hsquared(y ~ genomic(1 | id, markers = M), data = dat,\n',
        '         control = hs_control(engine = "julia"))'
      ),
      scope = paste(
        "Accepts a supplied Ginv/Hinv or builds G from markers and H^-1 from",
        "pedigree plus a genotyped subset. Construction knobs (tau, omega, blend,",
        "ridge) are not comparator-validated; low-rank m >> n solves, APY, and",
        "AGHmatrix/sommer/BLUPF90 parity are planned. Metafounder paths are",
        "supplied-variance only."
      ),
      point = "partial",
      interval = "no",
      fallback = paste(
        "Use the covered pedigree animal model, or report genomic estimates only",
        "beside an external comparator you ran yourself."
      )
    ),
    list(
      key = "experimental SNP-BLUP marker-effect model (opt-in; supplied-variance or REML-estimated)",
      expect = "partial",
      title = "SNP-BLUP marker effects",
      call = paste0(
        'hsquared(y ~ genomic(1 | id, markers = M), data = dat,\n',
        '         control = hs_control(engine = "julia",\n',
        '           engine_control = list(target = "snp_blup")))'
      ),
      scope = paste(
        "VanRaden method-1 marker model returning per-marker effects, genomic",
        "breeding values, and fixed effects, with variances either supplied or",
        "REML-estimated. Weighted/Bayesian marker priors and JWAS/sommer/BLUPF90",
        "parity are planned."
      ),
      point = "partial",
      interval = "no",
      fallback = "Use the genomic GREML route above for a breeding-value question, and treat marker effects as exploratory."
    ),
    list(
      key = "experimental multivariate REML estimator (opt-in)",
      expect = "partial",
      default_route = TRUE,
      title = "Multivariate Gaussian animal model (cbind response)",
      call = paste0(
        'hsquared(cbind(y1, y2) ~ animal(1 | id, pedigree = ped), data = dat)\n',
        '# routes on the default path; engine = "julia", target = ',
        '"multivariate" still works'
      ),
      scope = paste(
        "REML-only, animal-model-only, dense/validation-scale. Returns G0/R0",
        "covariance and correlation matrices, per-trait h2, and cross-trait EBVs.",
        "The R-lane evidence includes a 100-replicate t = 2 cold-start recovery",
        "study, one reproduced full-unstructured `sommer` comparator leg, a",
        "published Mrode-style supplied-variance anchor, and a Bayesian MCMCglmm",
        "agreement probe - which is NOT same-estimand REML parity. The engine row",
        "is covered; this R-public surface is not. Since MV-4 the cbind route is",
        "selected on the default call: that is reachability, not promotion, and",
        "public_covered_count did not move."
      ),
      point = "partial",
      interval = "no",
      fallback = paste(
        "Fit each trait with the covered univariate model, and report cross-trait",
        "covariance only beside an external multi-trait comparator."
      )
    )
  )
}

# --- permission wording (one source, so cards cannot disagree) --------------

hs_permission_fit <- function(status, is_default) {
  if (identical(status, "covered") && is_default) {
    "**Yes** - implemented and covered on the default call."
  } else if (identical(status, "covered")) {
    "**Yes** - implemented and covered at validation scale, behind an opt-in engine target."
  } else if (identical(status, "partial") && is_default) {
    "**Yes, but experimental** - it runs on the default call, yet the evidence is incomplete. Default routing is not a covered claim."
  } else if (identical(status, "partial")) {
    "**Yes, but opt-in and experimental** - the code runs; the evidence is incomplete."
  } else {
    "**No** - not implemented; the call aborts as planned, not implemented."
  }
}

hs_permission_point <- function(point) {
  switch(
    point,
    yes = paste(
      "**Yes, within the stated scope** - a pre-declared recovery gate passed and",
      "an external same-estimand comparator agrees."
    ),
    partial = paste(
      "**Not on this package's evidence alone.** Report only beside a comparator",
      "you ran yourself, and say the route is experimental."
    ),
    no = "**No** - no point-estimate reporting permission.",
    stop("unknown point permission: ", point)
  )
}

hs_permission_interval <- function(interval) {
  switch(
    interval,
    yes = "**Yes** - named, coverage-calibrated interval method.",
    no = paste(
      "**No.** Standard errors and intervals are asymptotic/delta-method,",
      "labelled experimental, and NOT coverage-calibrated. No route in this",
      "package currently carries an interval-reporting permission."
    ),
    stop("unknown interval permission: ", interval)
  )
}

# --- generation -------------------------------------------------------------

hs_check_routes <- function(routes, status_tbl) {
  for (route in routes) {
    hit <- status_tbl$status[status_tbl$capability == route$key]
    if (length(hit) != 1L) {
      stop(
        "capability-ledger drift: validation_status() has ",
        length(hit),
        " row(s) for key\n  ",
        route$key,
        "\nUpdate tools/write-capability-ledger-summary.R before regenerating.",
        call. = FALSE
      )
    }
    if (!identical(hit, route$expect)) {
      stop(
        "capability-ledger drift: '",
        route$title,
        "' expects status '",
        route$expect,
        "' but validation_status() says '",
        hit,
        "'.\nReconcile the reader permission before regenerating.",
        call. = FALSE
      )
    }
  }
  invisible(TRUE)
}

hs_render_card <- function(route, is_default) {
  c(
    paste0("### ", route$title),
    "",
    "```r",
    strsplit(route$call, "\n", fixed = TRUE)[[1L]],
    "```",
    "",
    paste0("**Can I fit it?** ", hs_permission_fit(route$expect, is_default)),
    "",
    paste0(
      "**Can I report the point estimate?** ",
      hs_permission_point(route$point)
    ),
    "",
    paste0(
      "**Can I report an interval?** ",
      hs_permission_interval(route$interval)
    ),
    "",
    paste0("**Exact scope and caveat.** ", route$scope),
    "",
    paste0("**Concrete fallback.** ", route$fallback),
    ""
  )
}

hs_render_planned <- function(status_tbl) {
  planned <- status_tbl[status_tbl$status == "planned", , drop = FALSE]
  if (nrow(planned) == 0L) {
    return(character())
  }
  c(
    "## Not available (syntax reservations and planned lanes)",
    "",
    paste(
      "These rows are `planned` in `validation_status()`. The formula vocabulary",
      "may parse, but the fit aborts as planned, not implemented - and there is no",
      "reporting permission of any kind."
    ),
    "",
    paste0("- ", planned$capability, " *(", planned$phase, ")*"),
    ""
  )
}

hs_render_counts <- function(status_tbl) {
  tally <- table(factor(
    status_tbl$status,
    levels = c("covered", "partial", "planned")
  ))
  c(
    "| Status | Rows | What it means for you |",
    "|---|---|---|",
    paste0(
      "| `covered` | ",
      tally[["covered"]],
      " | Pre-declared recovery gate passed and an external same-estimand ",
      "comparator agrees. Point estimates are reportable within the stated scope. |"
    ),
    paste0(
      "| `partial` | ",
      tally[["partial"]],
      " | The code runs and is bridge-verified, but the evidence chain is ",
      "incomplete. Exploratory use only. |"
    ),
    paste0(
      "| `planned` | ",
      tally[["planned"]],
      " | Not implemented. No reporting permission. |"
    ),
    "",
    paste(
      "Those counts are rows in the evidence ledger, not user-facing models. Some",
      "rows are validation atoms (a pedigree-inverse check, a textbook fixture) or",
      "evidence for another row rather than a model you would fit. The cards below",
      "are the model routes."
    ),
    ""
  )
}

hs_build_summary <- function(status_tbl, routes = hs_route_table()) {
  hs_check_routes(routes, status_tbl)

  default_key <- "univariate Gaussian animal-model fit (default path, AI-REML)"

  lines <- c(
    paste0(
      "<!-- Generated by tools/write-capability-ledger-summary.R from ",
      "validation_status(); do not edit by hand. -->"
    ),
    "",
    paste(
      "`validation_status()` in the installed package is the live source of truth.",
      "This summary is generated from it, so a status change here is a status",
      "change there - the two cannot drift apart silently."
    ),
    "",
    hs_render_counts(status_tbl),
    "## Reader routes",
    "",
    paste(
      "Every route below runs. The question these cards answer is narrower and more",
      "useful: *what may I put in a paper?*"
    ),
    ""
  )

  for (route in routes) {
    # `default_route` is reachability, `expect` is the claim. A route can be
    # default-reachable and still `partial` (the MV-4 cbind auto-route).
    on_default <- isTRUE(route$default_route) ||
      identical(route$key, default_key)
    lines <- c(lines, hs_render_card(route, on_default))
  }

  lines <- c(
    lines,
    hs_render_planned(status_tbl),
    "## Before you report",
    "",
    paste0(
      "1. Run `validation_status()` and confirm your route's row still says what ",
      "this page says."
    ),
    "2. Report point estimates for `covered` rows only.",
    paste0(
      "3. Do not report a standard error or interval as calibrated. None of them ",
      "are, in any release of this package so far."
    ),
    paste0(
      "4. For a `partial` route, run an external comparator yourself and report ",
      "both numbers."
    ),
    paste0(
      "5. Say in the methods that the fit came from an experimental package, and ",
      "name the version."
    ),
    ""
  )

  lines
}

# --- entry point ------------------------------------------------------------

if (identical(environment(), globalenv()) && !interactive()) {
  if (!requireNamespace("pkgload", quietly = TRUE)) {
    stop(
      "pkgload is required to generate the capability ledger summary.",
      call. = FALSE
    )
  }
  pkgload::load_all(".", quiet = TRUE)

  status_tbl <- as.data.frame(validation_status())
  out_path <- file.path(
    "vignettes",
    "articles",
    "includes",
    "capability-ledger-summary.md"
  )
  dir.create(dirname(out_path), recursive = TRUE, showWarnings = FALSE)

  summary_lines <- hs_build_summary(status_tbl)
  writeLines(summary_lines, out_path)
  message("wrote ", out_path, " (", length(summary_lines), " lines)")
}
