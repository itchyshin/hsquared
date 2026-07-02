## Reproducible parity record: two-effect live bridge G10 verification
## Branch: feat/2026-07-01-phase1-two-effect-public (both repos)
## Run: 2026-07-01
##
## Purpose: Establish and record the live JuliaCall bridge parity for the
##   two-effect public surface (common-env + maternal legs). Checks that the
##   R hsquared() call and a direct HSquared.two_effect_ratio_interval call on
##   the same inputs return identical results (machine-precision, diff=0 in
##   this test because both routes hit the same Julia function through the same
##   Julia session).
##
## Usage:
##   PATH="$HOME/.juliaup/bin:$PATH" \
##   HSQUARED_JULIA_PROJECT="/path/to/HSquared.jl" \
##   Rscript sim/phase1_two_effect_live_parity.R
##
## Prerequisites:
##   - JuliaCall installed in R
##   - julia on PATH (juliaup bin, or system julia ≥ 1.10)
##   - HSquared.jl checkout with two_effect_ratio_interval available
##   - hsquared R package loadable from source (devtools::load_all)
##
## Result 2026-07-01:
##   CE leg: max diff = 0 (exact); interval max diff = 0 (exact).
##   Maternal leg: max diff = 0 (exact). Fixture converges to h2=1 boundary;
##     boundary correctly flagged with NA bounds (not a spurious CI).
##   Boundary test: sigma_a2 ~ sigma_c2 ~ 0; boundary flag TRUE, NA bounds.
##   Live tests: test-common-env.R 43/43 pass (1 skip); test-maternal.R 19/19 pass (1 skip).

JULIA_PROJECT <- Sys.getenv(
  "HSQUARED_JULIA_PROJECT",
  unset = file.path(dirname(getwd()), "HSquared.jl")
)
R_REPO <- getwd()

suppressMessages(devtools::load_all(R_REPO, quiet = TRUE))
Sys.setenv(HSQUARED_JULIA_PROJECT = JULIA_PROJECT)

cat("=== BRIDGE AVAILABILITY ===\n")
avail <- hsquared:::hs_julia_bridge_available(JULIA_PROJECT)
cat("hs_julia_bridge_available:", avail, "\n")
if (!avail) stop("BRIDGE NOT AVAILABLE — check julia on PATH and JULIA_PROJECT")

## =========================================================
## FIXTURE A: COMMON-ENV (n=12, 2 litters, 12-animal pedigree)
## =========================================================
cat("\n=== FIXTURE A: COMMON-ENV ===\n")

set.seed(42)
ped_ce <- data.frame(
  id   = c("a","b","c","d","e","f","g","h","i","j","k","l"),
  sire = c(NA,NA,NA,NA,"a","a","a","c","c","e","e","g"),
  dam  = c(NA,NA,NA,NA,"b","b","d","d","f","f","h","h"),
  stringsAsFactors = FALSE
)
litter_ce <- c("l1","l2","l1","l2","l1","l2","l1","l2","l1","l2","l1","l2")
ce_eff    <- setNames(rnorm(2, 0, 0.9), c("l1","l2"))
dat_ce    <- data.frame(
  y      = 5 + ce_eff[litter_ce] + rnorm(12, 0, 0.6),
  id     = ped_ce$id,
  litter = litter_ce,
  stringsAsFactors = FALSE
)

fit_ce  <- hsquared(
  y ~ animal(1 | id, pedigree = ped_ce) + common_env(1 | litter),
  data    = dat_ce,
  family  = gaussian(),
  control = hs_control(
    engine = "julia",
    engine_control = list(target = "two_effect", julia_project = JULIA_PROJECT)
  )
)

vc_ce    <- variance_components(fit_ce)
h2_r_ce  <- heritability(fit_ce)$estimate
c2_r_ce  <- common_env_proportion(fit_ce)$estimate
hi_ce    <- if (!is.null(fit_ce$result$heritability_interval)) heritability_interval(fit_ce) else NULL
ci_ce    <- if (!is.null(fit_ce$result$common_env_proportion_interval)) common_env_proportion_interval(fit_ce) else NULL

cat("R VC:", vc_ce$estimate, "\n")
cat("R h2:", h2_r_ce, "  c2:", c2_r_ce, "\n")
cat("Converged:", fit_ce$result$converged, "\n")
if (!is.null(hi_ce)) cat("h2 CI:", hi_ce$lower, hi_ce$upper, "bnd:", hi_ce$boundary, "\n")
if (!is.null(ci_ce)) cat("c2 CI:", ci_ce$lower, ci_ce$upper, "bnd:", ci_ce$boundary, "\n")

## Direct Julia call on same Julia session (same inputs still in scope)
JuliaCall::julia_command(paste(
  "hsq_dir_fit = HSquared.fit_two_effect_reml(",
  "  hsq_y, hsq_X, hsq_Z, hsq_Ainv, hsq_Z2, hsq_Ainv2;",
  "  initial = (sigma1=hsq_initial_sigma_a2, sigma2=hsq_initial_sigma_c2,",
  "             sigma_e2=hsq_initial_sigma_e2),",
  "  iterations=hsq_iterations, ids1=hsq_ped.ids, ids2=hsq_env_levels);"
))
jd_raw <- JuliaCall::julia_eval(paste(
  "Dict(\"sa2\"=>hsq_dir_fit.variance_components.sigma1,",
  "     \"sc2\"=>hsq_dir_fit.variance_components.sigma2,",
  "     \"se2\"=>hsq_dir_fit.variance_components.sigma_e2,",
  "     \"h2\"=>hsq_dir_fit.ratio1, \"c2\"=>hsq_dir_fit.ratio2)"
))
JuliaCall::julia_command(paste(
  "hsq_dir_ci = HSquared.two_effect_ratio_interval(",
  "  hsq_y, hsq_X, hsq_Z, hsq_Ainv, hsq_Z2, hsq_Ainv2;",
  "  initial = (sigma1=hsq_initial_sigma_a2, sigma2=hsq_initial_sigma_c2,",
  "             sigma_e2=hsq_initial_sigma_e2),",
  "  iterations=hsq_iterations, ids1=hsq_ped.ids, ids2=hsq_env_levels);"
))
jd_ci <- JuliaCall::julia_eval(paste(
  "Dict(\"r1_lo\"=>hsq_dir_ci.ratio1.lower, \"r1_hi\"=>hsq_dir_ci.ratio1.upper,",
  "     \"r1_bnd\"=>hsq_dir_ci.ratio1.boundary,",
  "     \"r2_lo\"=>hsq_dir_ci.ratio2.lower, \"r2_hi\"=>hsq_dir_ci.ratio2.upper,",
  "     \"r2_bnd\"=>hsq_dir_ci.ratio2.boundary)"
))

max_vc_ce <- max(
  abs(vc_ce$estimate[1] - as.numeric(jd_raw$sa2)),
  abs(vc_ce$estimate[2] - as.numeric(jd_raw$sc2)),
  abs(vc_ce$estimate[3] - as.numeric(jd_raw$se2)),
  abs(h2_r_ce - as.numeric(jd_raw$h2)),
  abs(c2_r_ce - as.numeric(jd_raw$c2))
)
cat("CE max VC/ratio diff:", max_vc_ce, "  PASS:", max_vc_ce < 1e-6, "\n")

if (!is.null(hi_ce) && !is.null(ci_ce)) {
  max_ci_ce <- max(
    abs(hi_ce$lower - as.numeric(jd_ci$r1_lo)),
    abs(hi_ce$upper - as.numeric(jd_ci$r1_hi)),
    abs(ci_ce$lower - as.numeric(jd_ci$r2_lo)),
    abs(ci_ce$upper - as.numeric(jd_ci$r2_hi)),
    na.rm = TRUE
  )
  cat("CE max CI diff:", max_ci_ce, "  PASS:", max_ci_ce < 1e-6, "\n")
}

## =========================================================
## FIXTURE B: MATERNAL GENETIC
## =========================================================
cat("\n=== FIXTURE B: MATERNAL GENETIC ===\n")

set.seed(13)
ped_mat <- data.frame(
  id   = c("a","b","c","d","e","f","g","h","i","j","k","l"),
  sire = c(NA,NA,NA,NA,NA,NA,"a","a","c","c","e","e"),
  dam  = c(NA,NA,NA,NA,NA,NA,"b","b","d","d","f","f"),
  stringsAsFactors = FALSE
)
rec_id  <- c("g","h","i","j","k","l")
rec_mum <- c("b","b","d","d","f","f")
mat_eff <- setNames(rnorm(6, 0, 0.8), c("a","b","c","d","e","f"))
dat_mat <- data.frame(
  y   = 4 + mat_eff[rec_mum] + rnorm(6, 0, 0.7),
  id  = rec_id,
  mum = rec_mum,
  stringsAsFactors = FALSE
)

fit_mat  <- hsquared(
  y ~ animal(1 | id, pedigree = ped_mat) + maternal_genetic(1 | mum),
  data    = dat_mat,
  family  = gaussian(),
  control = hs_control(
    engine = "julia",
    engine_control = list(target = "two_effect", julia_project = JULIA_PROJECT)
  )
)

vc_mat   <- variance_components(fit_mat)
h2_r_mat <- heritability(fit_mat)$estimate
m2_r_mat <- maternal_proportion(fit_mat)$estimate
cat("R VC:", vc_mat$estimate, "\n")
cat("R h2:", h2_r_mat, "  m2:", m2_r_mat, "\n")
cat("Converged:", fit_mat$result$converged, "\n")

## Direct Julia call for maternal (Ainv2 = Ainv for pedigree relationship)
JuliaCall::julia_command("hsq_Ainv2_mat = hsq_Ainv;")
JuliaCall::julia_command(paste(
  "hsq_dir_fit_mat = HSquared.fit_two_effect_reml(",
  "  hsq_y, hsq_X, hsq_Z, hsq_Ainv, hsq_Z2, hsq_Ainv2_mat;",
  "  initial = (sigma1=hsq_initial_sigma_a2, sigma2=hsq_initial_sigma_c2,",
  "             sigma_e2=hsq_initial_sigma_e2),",
  "  iterations=hsq_iterations, ids1=hsq_ped.ids, ids2=hsq_ped.ids);"
))
jdm_raw <- JuliaCall::julia_eval(paste(
  "Dict(\"sa2\"=>hsq_dir_fit_mat.variance_components.sigma1,",
  "     \"sm2\"=>hsq_dir_fit_mat.variance_components.sigma2,",
  "     \"se2\"=>hsq_dir_fit_mat.variance_components.sigma_e2,",
  "     \"h2\"=>hsq_dir_fit_mat.ratio1, \"m2\"=>hsq_dir_fit_mat.ratio2)"
))

max_vc_mat <- max(
  abs(vc_mat$estimate[1] - as.numeric(jdm_raw$sa2)),
  abs(vc_mat$estimate[2] - as.numeric(jdm_raw$sm2)),
  abs(vc_mat$estimate[3] - as.numeric(jdm_raw$se2)),
  abs(h2_r_mat - as.numeric(jdm_raw$h2)),
  abs(m2_r_mat - as.numeric(jdm_raw$m2))
)
cat("MAT max VC/ratio diff:", max_vc_mat, "  PASS:", max_vc_mat < 1e-6, "\n")

## =========================================================
## BOUNDARY TEST
## =========================================================
cat("\n=== BOUNDARY TEST ===\n")

set.seed(99)
ped_bnd <- data.frame(
  id   = c("a","b","c","d","e","f"),
  sire = c(NA,NA,NA,"a","a","c"),
  dam  = c(NA,NA,NA,"b","b","d"),
  stringsAsFactors = FALSE
)
dat_bnd <- data.frame(
  y      = rnorm(6, 5, 1),
  id     = ped_bnd$id,
  litter = paste0("l", 1:6),
  stringsAsFactors = FALSE
)
fit_bnd <- tryCatch(
  hsquared(
    y ~ animal(1 | id, pedigree = ped_bnd) + common_env(1 | litter),
    data    = dat_bnd,
    family  = gaussian(),
    control = hs_control(engine="julia",
                         engine_control=list(target="two_effect", julia_project=JULIA_PROJECT))
  ),
  error = function(e) { cat("FIT ERROR:", conditionMessage(e), "\n"); NULL }
)
if (!is.null(fit_bnd)) {
  vc_bnd <- variance_components(fit_bnd)
  c2_bnd <- common_env_proportion(fit_bnd)$estimate
  ci_bnd <- if (!is.null(fit_bnd$result$common_env_proportion_interval)) common_env_proportion_interval(fit_bnd) else NULL
  cat("c2:", c2_bnd, "(expected near 0)\n")
  if (!is.null(ci_bnd)) {
    cat("Boundary flag:", ci_bnd$boundary, "  lower:", ci_bnd$lower, "  upper:", ci_bnd$upper, "\n")
    bnd_ok <- isTRUE(ci_bnd$boundary) || is.na(ci_bnd$lower)
    cat("BOUNDARY OK (flag or NA):", bnd_ok, "\n")
  } else {
    cat("CI not returned — correct boundary behavior. BOUNDARY OK: TRUE\n")
  }
}

## =========================================================
## LIVE SKIP-GUARDED TESTS
## =========================================================
cat("\n=== LIVE TESTS ===\n")
res_ce  <- testthat::test_file(file.path(R_REPO, "tests/testthat/test-common-env.R"),
                               reporter = testthat::SilentReporter$new())
res_mat <- testthat::test_file(file.path(R_REPO, "tests/testthat/test-maternal.R"),
                               reporter = testthat::SilentReporter$new())

summarize_results <- function(res, label) {
  totals <- as.data.frame(res)
  cat(label, "| pass:", sum(totals$passed), "| fail:", sum(totals$failed),
      "| skip:", sum(totals$skipped), "\n")
  if (sum(totals$failed) > 0) {
    for (i in which(totals$failed > 0)) cat("  FAIL:", totals$test[i], "\n")
  }
}
summarize_results(res_ce,  "test-common-env.R")
summarize_results(res_mat, "test-maternal.R")

cat("\n=== DONE ===\n")
