## C1-ext / design-36 H1 + H3 — R public-lane PATH_ONLY pointer
##
## Twin of HSquared.jl `sim/phase1_interval_coverage_ext.jl` (PR #294).
## This is NOT a second 2000-rep coverage driver. R has no C1-ext numeric
## harness, no `genetic_correlation_interval()` generic, and `confint()`
## remains a hard block. Coverage remains a Julia simulation gate.
##
## What this is
##   Smoke / PATH_ONLY prep: freeze campaign names, extractor mapping, and
##   `claim_eligible = FALSE` so the R claim surface cannot outrun Julia #294.
##   Aligned with design-39 H0 as the later claim-level template, not as a
##   Layer B ratification.
##
## What this is not
##   Not a C1 re-run. Not H0 Layer B. Not a confirm bank. Not a covered flip.
##   `public_covered_count` stays 7. Experimental 0.7.0. `point` stays
##   maintainer-owned. Repeatability `t` recovery FAIL is not rescued.
##
## Include-safe: `source()`-ing this file defines helpers and does not run
## `hs_c1ext_main()` unless invoked as Rscript (`sys.nframe() == 0`).
##
## Usage:
##   Rscript sim/phase1_interval_coverage_ext.R
##   Rscript sim/phase1_interval_coverage_ext.R --mode=smoke --out=tmp/c1ext-r-smoke.tsv

EXT_INTERPRETABLE_FRACTION <- 0.9
EXT_CONFIRM_REPS_TARGET <- 2000L
EXT_SEED_STRIDE <- 40009L
EXT_PROMOTABLE_LEVEL <- 0.95
EXT_CAMPAIGNS <- c("h1_two", "h1_multi", "h1_t", "h3_rg", "h3_ram")
EXT_MODES <- c("smoke", "screen", "confirm")
EXT_JULIA_TWIN <- "https://github.com/itchyshin/HSquared.jl/pull/294"
EXT_JULIA_TIP <- "b0f645ee"

# campaign, estimand, julia_interval, r_surface, scale, covered_today, role
SYMBOLIC_ALIGNMENT <- data.frame(
  campaign = c(
    "h1_two",
    "h1_two",
    "h1_multi",
    "h1_multi",
    "h1_t",
    "h3_rg",
    "h3_ram"
  ),
  estimand = c("ratio1", "ratio2", "ratio1", "ratio2", "t", "r_g", "r_am"),
  julia_interval = c(
    "two_effect_ratio_interval",
    "two_effect_ratio_interval",
    "multi_effect_ratio_interval",
    "multi_effect_ratio_interval",
    "repeatability_interval",
    "genetic_correlation_interval",
    "direct_maternal_interval"
  ),
  r_surface = c(
    "heritability_interval",
    "common_env_proportion_interval / maternal_proportion_interval",
    "heritability_interval (multi-effect fit)",
    "heritability_interval (ratio2 when attached)",
    "repeatability_interval",
    "NONE (genetic_correlation is point-only)",
    "NONE (genetic_correlation is point-only)"
  ),
  scale = c(
    "logit-delta",
    "logit-delta",
    "logit-delta",
    "logit-delta",
    "logit-delta",
    "Fisher-z",
    "Fisher-z"
  ),
  covered_today = c(
    "yes (two-effect opt-in); interval experimental",
    "yes (two-effect opt-in); interval experimental",
    "yes (multi-effect opt-in); interval experimental",
    "yes (multi-effect opt-in); interval experimental",
    "NO (recovery confirm FAIL)",
    "yes (t=2 MV covered); R interval generic missing",
    "yes (direct-maternal opt-in); R interval generic missing"
  ),
  role = c(
    "covered_pillar_bank",
    "covered_pillar_bank",
    "covered_pillar_bank",
    "covered_pillar_bank",
    "characterization_only",
    "covered_pillar_bank",
    "covered_pillar_bank"
  ),
  stringsAsFactors = FALSE
)

hs_c1ext_usage <- function() {
  paste(
    "C1-ext H1/H3 R PATH_ONLY pointer (Julia #294 twin). No coverage numbers.",
    "",
    "Modes:",
    "  --mode=smoke    DEFAULT. Writes claim_eligible=false rows. Path proof only.",
    "  --mode=screen   Rejected here (no R numeric harness).",
    "  --mode=confirm  Rejected here (no R numeric harness).",
    "  --mode=promote  Rejected (Julia also rejects).",
    "",
    "Options:",
    "  --campaigns=LIST   Subset of h1_two,h1_multi,h1_t,h3_rg,h3_ram (default: all).",
    "  --out=PATH         Summary TSV (NEW file; never a C1 TSV).",
    sep = "\n"
  )
}

hs_c1ext_parse_args <- function(args = character()) {
  mode <- "smoke"
  campaigns <- EXT_CAMPAIGNS
  output <- file.path(tempdir(), "c1ext-r-smoke.tsv")

  for (arg in args) {
    if (!nzchar(arg)) {
      next
    }
    if (arg %in% c("-h", "--help")) {
      stop(hs_c1ext_usage(), call. = FALSE)
    }
    if (startsWith(arg, "--mode=")) {
      mode <- sub("^--mode=", "", arg)
    } else if (startsWith(arg, "--campaigns=")) {
      campaigns <- strsplit(sub("^--campaigns=", "", arg), ",", fixed = TRUE)[[
        1L
      ]]
      campaigns <- campaigns[nzchar(campaigns)]
    } else if (startsWith(arg, "--out=")) {
      output <- sub("^--out=", "", arg)
    } else if (startsWith(arg, "--reps=") || startsWith(arg, "--seed=")) {
      next
    } else {
      stop("Unknown argument: ", arg, "\n", hs_c1ext_usage(), call. = FALSE)
    }
  }

  if (!mode %in% EXT_MODES) {
    stop(
      "Unsupported --mode=",
      mode,
      ". R twin is PATH_ONLY smoke. ",
      "screen/confirm/promote are Julia-owned and not armed here.",
      call. = FALSE
    )
  }
  if (mode != "smoke") {
    stop(
      "--mode=",
      mode,
      " is not available on the R twin. Coverage remains Julia #294. ",
      "Use --mode=smoke for PATH_ONLY.",
      call. = FALSE
    )
  }
  unknown <- setdiff(campaigns, EXT_CAMPAIGNS)
  if (length(unknown)) {
    stop("Unknown campaigns: ", paste(unknown, collapse = ", "), call. = FALSE)
  }
  if (!length(campaigns)) {
    stop("No campaigns selected.", call. = FALSE)
  }

  list(mode = mode, campaigns = campaigns, output = output)
}

hs_c1ext_alignment <- function(campaigns = EXT_CAMPAIGNS) {
  SYMBOLIC_ALIGNMENT[SYMBOLIC_ALIGNMENT$campaign %in% campaigns, , drop = FALSE]
}

hs_c1ext_write_smoke_tsv <- function(path, campaigns = EXT_CAMPAIGNS) {
  rows <- hs_c1ext_alignment(campaigns)
  out <- data.frame(
    campaign = rows$campaign,
    estimand = rows$estimand,
    julia_interval = rows$julia_interval,
    r_surface = rows$r_surface,
    role = rows$role,
    mode = "smoke",
    gate = "PATH_ONLY",
    claim_eligible = FALSE,
    public_covered_count = 7L,
    experimental_version = "0.7.0",
    julia_twin = EXT_JULIA_TWIN,
    julia_tip = EXT_JULIA_TIP,
    stringsAsFactors = FALSE
  )
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  utils::write.table(out, path, sep = "\t", row.names = FALSE, quote = FALSE)
  path
}

hs_c1ext_main <- function(args = commandArgs(trailingOnly = TRUE)) {
  cfg <- hs_c1ext_parse_args(args)
  path <- hs_c1ext_write_smoke_tsv(cfg$output, cfg$campaigns)
  n_rows <- nrow(hs_c1ext_alignment(cfg$campaigns))
  message(
    "GATE PATH_ONLY  claim_eligible=false  campaigns=",
    length(cfg$campaigns),
    " rows=",
    n_rows
  )
  message("wrote ", path)
  invisible(path)
}

if (sys.nframe() == 0L) {
  hs_c1ext_main()
}
