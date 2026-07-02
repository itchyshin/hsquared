## Reproducible parity record: multi-effect (K >= 3) live bridge G10 verification
## Branch: feat/2026-07-01-phase2-r-multieffect (R) /
##         feat/2026-07-01-phase2-multi-effect-interval (HSquared.jl)
## Run: 2026-07-01
##
## Purpose: Establish and record the live JuliaCall bridge parity for the
##   arbitrary-(1|g) multi-effect public surface (animal-A + >= 2 pedigree-
##   independent iid groups). This is the Phase 2-R Wave 2 G10 gate: a public
##   surface claim must actually RUN end-to-end over the live bridge and MATCH a
##   direct engine fit. Two independent checks:
##
##   (1) MARSHALLING IDENTITY: the R hsquared() fit vs a direct
##       fit_multi_effect_reml + multi_effect_ratio_interval on the SAME
##       marshalled Julia inputs (hsq_parsed.{y,X,blocks}). Diff must be ~0 —
##       this proves the R->Julia round-trip through the N-block payload lost
##       nothing (the JuliaCall sparse-CSC assign + Dict construction is exact).
##
##   (2) INDEPENDENT NATIVE-JULIA: the same fit rebuilt from scratch in Julia
##       (pedigree_inverse from the same rows; identity Ainv + hand-built Z for
##       each iid group) vs the R fit. This confirms the R-marshalled Z / Ainv
##       equal an independent Julia-native construction (verifies marshalling,
##       not just self-consistency).
##
## Usage:
##   PATH="$HOME/.juliaup/bin:$PATH" \
##   HSQUARED_JULIA_PROJECT="/path/to/HSquared.jl" \
##   Rscript sim/phase2_multi_effect_live_parity.R
##
## Prerequisites:
##   - JuliaCall installed in R; julia on PATH (juliaup bin, or julia >= 1.10)
##   - HSquared.jl checkout on the phase2 branch with parse_payload_v2 /
##     fit_payload_v2 / result_payload_v2 / multi_effect_ratio_interval available
##   - hsquared R package loadable from source (devtools::load_all)
##
## Result 2026-07-01 (julia 1.10.0; HSquared.jl @ feat/2026-07-01-phase2-multi-
##   effect-interval / beca24e1):
##   K=3 fixture (animal + nest + year, n=40), converged=TRUE.
##   R VC: animal 0.67416636, nest 0.50624866, year 0.43565854, resid 0.20053939.
##   R h2 (animal) = 0.3711117; h2 CI [0.0410334, 0.890569], se 0.312462, delta.
##   CHECK 1 (marshalling identity):  max diff = 0 (exact).
##   CHECK 2 (independent native-Julia rebuild): max diff = 0 (exact) — the
##     R-marshalled sparse-CSC Z / pedigree Ainv are bit-identical to a from-
##     scratch Julia construction.
##   Live test test-formula-animal.R (with NOT_CRAN=true + bridge): 96 pass /
##     0 fail / 0 skip; the K>=3 block test runs live (7 assertions pass).

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
## FIXTURE: animal-A pedigree + TWO pedigree-independent iid groups
##   n = 40 records over a 40-animal pedigree (10 founders + 30 offspring);
##   nest (8 levels) and year (5 levels) assigned INDEPENDENTLY of pedigree
##   -> three independent blocks -> fit_multi_effect_reml.  Moderate n, all
##   three components identified (non-tiny, so the delta-method CI is meaningful).
## =========================================================
cat("\n=== FIXTURE: K=3 (animal + nest + year), n=40 ===\n")

set.seed(2027)
n_found <- 10L
n_off <- 30L
ids <- c(paste0("f", 1:n_found), paste0("o", 1:n_off))
sire <- c(rep(NA, n_found), sample(paste0("f", 1:n_found), n_off, replace = TRUE))
dam <- c(rep(NA, n_found), sample(paste0("f", 1:n_found), n_off, replace = TRUE))
# avoid sire == dam self-mating
same <- which(!is.na(sire) & sire == dam)
for (i in same) dam[i] <- sample(setdiff(paste0("f", 1:n_found), sire[i]), 1)
ped <- data.frame(id = ids, sire = sire, dam = dam, stringsAsFactors = FALSE)

n <- length(ids)
nest_lvls <- paste0("nst", 1:8)
year_lvls <- paste0("yr", 1:5)
nest <- sample(nest_lvls, n, replace = TRUE)
year <- sample(year_lvls, n, replace = TRUE)
nest_e <- setNames(rnorm(8, 0, 0.7), nest_lvls)
year_e <- setNames(rnorm(5, 0, 0.5), year_lvls)
# a modest additive signal via a simple founder-drop (recovery is not the point
# here — identifiability + parity is; the engine's V3-NEFFECT-REML 48-seed gate
# already establishes recovery)
a_founder <- setNames(rnorm(n_found, 0, 0.8), paste0("f", 1:n_found))
a_val <- numeric(n); names(a_val) <- ids
a_val[paste0("f", 1:n_found)] <- a_founder
for (i in seq_len(n_off)) {
  oid <- paste0("o", i)
  a_val[oid] <- 0.5 * (a_val[ped$sire[ped$id == oid]] + a_val[ped$dam[ped$id == oid]]) +
    rnorm(1, 0, 0.5)
}
dat <- data.frame(
  y = 3 + a_val[ids] + nest_e[nest] + year_e[year] + rnorm(n, 0, 0.6),
  id = ids, nest = nest, year = year,
  stringsAsFactors = FALSE
)

## ---------- R path: hsquared() multi_effect ----------
fit <- hsquared(
  y ~ animal(1 | id, pedigree = ped) + (1 | nest) + (1 | year),
  data = dat,
  family = gaussian(),
  control = hs_control(
    engine = "julia",
    engine_control = list(target = "multi_effect", julia_project = JULIA_PROJECT)
  )
)

vc_r <- variance_components(fit)
h2_r <- heritability(fit)$estimate
hi_r <- if (!is.null(fit$result$heritability_interval)) heritability_interval(fit) else NULL
vri_r <- fit$result$variance_ratio_intervals
cat("R converged:", fit$result$converged, "\n")
cat("R VC (", paste(vc_r$component, collapse = ", "), "):\n  ",
    paste(signif(vc_r$estimate, 8), collapse = "  "), "\n", sep = "")
cat("R h2 (animal):", signif(h2_r, 8), "\n")
if (!is.null(hi_r)) {
  cat("R h2 CI: [", signif(hi_r$lower, 6), ",", signif(hi_r$upper, 6),
      "] se=", signif(hi_r$se, 6), " method=", hi_r$method,
      " bnd=", hi_r$boundary, "\n")
}
if (!is.null(vri_r)) {
  for (nm in names(vri_r)) {
    ci <- vri_r[[nm]]
    cat("R ratio[", nm, "]: est=", signif(ci$estimate, 6),
        " CI=[", signif(ci$lower, 6), ",", signif(ci$upper, 6), "]",
        " bnd=", ci$boundary, "\n", sep = "")
  }
}

## ---------- CHECK 1: MARSHALLING IDENTITY ----------
## After the R fit, hsq_parsed (the marshalled payload) is live in the Julia
## session. Rebuild the identical effects vector the multi_effect dispatch uses
## and fit directly. Diff must be ~0 (same Julia inputs, same function).
cat("\n=== CHECK 1: marshalling identity (R fit vs direct on hsq_parsed) ===\n")
JuliaCall::julia_command(paste(
  "hsq_p1_eff = [(Matrix{Float64}(b.Z), Matrix{Float64}(b.relmat_inverse))",
  "for b in hsq_parsed.blocks];",
  "hsq_p1_ids = [b.ids for b in hsq_parsed.blocks];",
  "hsq_p1_fit = HSquared.fit_multi_effect_reml(",
  "hsq_parsed.y, hsq_parsed.X, hsq_p1_eff; ids = hsq_p1_ids);",
  "hsq_p1_ci = HSquared.multi_effect_ratio_interval(",
  "hsq_parsed.y, hsq_parsed.X, hsq_p1_eff; ids = hsq_p1_ids);"
))
d1 <- JuliaCall::julia_eval(paste(
  "Dict(",
  "\"sigmas\" => collect(Float64, hsq_p1_fit.variance_components.sigmas),",
  "\"se2\" => Float64(hsq_p1_fit.variance_components.sigma_e2),",
  "\"ratios\" => collect(Float64, hsq_p1_fit.ratios),",
  "\"ci_est\" => [Float64(r.estimate) for r in hsq_p1_ci.ratios],",
  "\"ci_lo\" => [Float64(r.lower) for r in hsq_p1_ci.ratios],",
  "\"ci_hi\" => [Float64(r.upper) for r in hsq_p1_ci.ratios])"
))
# R vc order = block order then residual; engine sigmas = block order.
r_sigmas <- vc_r$estimate[vc_r$component != "residual"]
r_se2 <- vc_r$estimate[vc_r$component == "residual"]
max_vc_1 <- max(abs(r_sigmas - d1$sigmas), abs(r_se2 - d1$se2))
# animal ratio (h2) from R vs engine ratio for the animal block (block 1 = animal)
animal_idx <- match("animal", vc_r$component)
max_h2_1 <- abs(h2_r - d1$ratios[animal_idx])
# per-component ratio-interval bounds (R vri order matches block order)
r_ci_lo <- vapply(names(vri_r), function(nm) vri_r[[nm]]$lower, numeric(1))
r_ci_hi <- vapply(names(vri_r), function(nm) vri_r[[nm]]$upper, numeric(1))
max_ci_1 <- max(abs(r_ci_lo - d1$ci_lo), abs(r_ci_hi - d1$ci_hi), na.rm = TRUE)
cat("CHECK 1 max VC diff:", max_vc_1, "\n")
cat("CHECK 1 max h2 diff:", max_h2_1, "\n")
cat("CHECK 1 max CI-bound diff:", max_ci_1, "\n")
pass1 <- max(max_vc_1, max_h2_1, max_ci_1, na.rm = TRUE) < 1e-9
cat("CHECK 1 PASS (< 1e-9):", pass1, "\n")

## ---------- CHECK 2: INDEPENDENT NATIVE-JULIA ----------
## Rebuild the model from scratch in Julia: pedigree_inverse from the same rows,
## identity Ainv + hand-built incidence Z for each iid group, same y / X.
## Confirms the R-marshalled Z / Ainv equal an independent Julia construction.
cat("\n=== CHECK 2: independent native-Julia fit vs R fit ===\n")
JuliaCall::julia_assign("hsq_v2_y", dat$y)
JuliaCall::julia_assign("hsq_v2_X", matrix(1.0, nrow = n, ncol = 1))
JuliaCall::julia_assign("hsq_v2_pid", as.character(ped$id))
JuliaCall::julia_assign("hsq_v2_sire", ifelse(is.na(ped$sire), "0", ped$sire))
JuliaCall::julia_assign("hsq_v2_dam", ifelse(is.na(ped$dam), "0", ped$dam))
JuliaCall::julia_assign("hsq_v2_rec_id", as.character(dat$id))     # record -> animal
JuliaCall::julia_assign("hsq_v2_nest", as.character(dat$nest))
JuliaCall::julia_assign("hsq_v2_year", as.character(dat$year))
JuliaCall::julia_command(paste(
  # animal block: pedigree Ainv + record->animal incidence
  "hsq_v2_ped = HSquared.normalize_pedigree(hsq_v2_pid, hsq_v2_sire, hsq_v2_dam);",
  "hsq_v2_Ainv_a = HSquared.pedigree_inverse(hsq_v2_ped);",
  "hsq_v2_aids = hsq_v2_ped.ids;",
  "hsq_v2_apos = Dict(id => i for (i, id) in enumerate(hsq_v2_aids));",
  "hsq_v2_Za = zeros(Float64, length(hsq_v2_rec_id), length(hsq_v2_aids));",
  "for (r, id) in enumerate(hsq_v2_rec_id); hsq_v2_Za[r, hsq_v2_apos[id]] = 1.0; end;",
  # nest block: identity Ainv + record->nest incidence
  "hsq_v2_nlv = sort(unique(hsq_v2_nest));",
  "hsq_v2_npos = Dict(l => i for (i, l) in enumerate(hsq_v2_nlv));",
  "hsq_v2_Zn = zeros(Float64, length(hsq_v2_nest), length(hsq_v2_nlv));",
  "for (r, l) in enumerate(hsq_v2_nest); hsq_v2_Zn[r, hsq_v2_npos[l]] = 1.0; end;",
  "hsq_v2_Ainv_n = Matrix{Float64}(I, length(hsq_v2_nlv), length(hsq_v2_nlv));",
  # year block: identity Ainv + record->year incidence
  "hsq_v2_ylv = sort(unique(hsq_v2_year));",
  "hsq_v2_ypos = Dict(l => i for (i, l) in enumerate(hsq_v2_ylv));",
  "hsq_v2_Zy = zeros(Float64, length(hsq_v2_year), length(hsq_v2_ylv));",
  "for (r, l) in enumerate(hsq_v2_year); hsq_v2_Zy[r, hsq_v2_ypos[l]] = 1.0; end;",
  "hsq_v2_Ainv_y = Matrix{Float64}(I, length(hsq_v2_ylv), length(hsq_v2_ylv));",
  # effects vector in the SAME block order the R emitter uses: animal, nest, year
  "hsq_v2_eff = [(hsq_v2_Za, Matrix(hsq_v2_Ainv_a)),",
  "(hsq_v2_Zn, hsq_v2_Ainv_n), (hsq_v2_Zy, hsq_v2_Ainv_y)];",
  "hsq_v2_ids = [collect(hsq_v2_aids), hsq_v2_nlv, hsq_v2_ylv];",
  "hsq_v2_fit = HSquared.fit_multi_effect_reml(",
  "hsq_v2_y, hsq_v2_X, hsq_v2_eff; ids = hsq_v2_ids);",
  "hsq_v2_ci = HSquared.multi_effect_ratio_interval(",
  "hsq_v2_y, hsq_v2_X, hsq_v2_eff; ids = hsq_v2_ids);"
))
d2 <- JuliaCall::julia_eval(paste(
  "Dict(",
  "\"sigmas\" => collect(Float64, hsq_v2_fit.variance_components.sigmas),",
  "\"se2\" => Float64(hsq_v2_fit.variance_components.sigma_e2),",
  "\"ratios\" => collect(Float64, hsq_v2_fit.ratios),",
  "\"ci_lo\" => [Float64(r.lower) for r in hsq_v2_ci.ratios],",
  "\"ci_hi\" => [Float64(r.upper) for r in hsq_v2_ci.ratios])"
))
max_vc_2 <- max(abs(r_sigmas - d2$sigmas), abs(r_se2 - d2$se2))
max_h2_2 <- abs(h2_r - d2$ratios[animal_idx])
max_ci_2 <- max(abs(r_ci_lo - d2$ci_lo), abs(r_ci_hi - d2$ci_hi), na.rm = TRUE)
cat("CHECK 2 native VC:  ", paste(signif(d2$sigmas, 8), collapse = "  "),
    " | se2=", signif(d2$se2, 8), "\n")
cat("CHECK 2 max VC diff:", max_vc_2, "\n")
cat("CHECK 2 max h2 diff:", max_h2_2, "\n")
cat("CHECK 2 max CI-bound diff:", max_ci_2, "\n")
# native rebuild uses a different optimizer start path; allow a small numeric tol
pass2 <- max(max_vc_2, max_h2_2, max_ci_2, na.rm = TRUE) < 1e-5
cat("CHECK 2 PASS (< 1e-5):", pass2, "\n")

## =========================================================
## LIVE SKIP-GUARDED TEST
## =========================================================
cat("\n=== LIVE TEST: test-formula-animal.R (K>=3 block) ===\n")
res <- testthat::test_file(
  file.path(R_REPO, "tests/testthat/test-formula-animal.R"),
  reporter = testthat::SilentReporter$new()
)
totals <- as.data.frame(res)
cat("test-formula-animal.R | pass:", sum(totals$passed),
    "| fail:", sum(totals$failed), "| skip:", sum(totals$skipped), "\n")
if (sum(totals$failed) > 0) {
  for (i in which(totals$failed > 0)) cat("  FAIL:", totals$test[i], "\n")
}

## =========================================================
cat("\n=== RESULT SUMMARY ===\n")
cat("CHECK 1 (marshalling identity)  PASS:", pass1,
    " | max diff:", signif(max(max_vc_1, max_h2_1, max_ci_1, na.rm = TRUE), 3), "\n")
cat("CHECK 2 (independent native)    PASS:", pass2,
    " | max diff:", signif(max(max_vc_2, max_h2_2, max_ci_2, na.rm = TRUE), 3), "\n")
cat("Live test failures:", sum(totals$failed), "\n")
cat("\n=== DONE ===\n")
