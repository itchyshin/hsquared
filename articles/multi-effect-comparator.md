# Multi-effect model (K \>= 3): sommer comparator and validation evidence

This article documents the **arbitrary-`(1 | group)` multi-effect animal
model** — the opt-in `target = "multi_effect"` path in `hsquared` — for
the case of an additive-genetic animal effect plus **two or more**
pedigree-independent i.i.d. random effects (K \>= 3 variance
components). It places the `hsquared` estimates next to a
[`sommer::mmer`](https://rdrr.io/pkg/sommer/man/mmer.html) same-estimand
cross-check and cites the primary engine validation gate. It is
companion reading to [Two-effect model: sommer
comparator](https://itchyshin.github.io/hsquared/articles/two-effect-comparator.md)
(the K = 2 case) and to [Validation
evidence](https://itchyshin.github.io/hsquared/articles/validation-evidence.md).

## Honesty notes

1.  **The fit requires a live Julia engine.** Code is shown but not
    executed at build time (the `eval = FALSE` chunk option is set
    globally). Numbers quoted in prose are from a live local run with
    `julia` on `PATH` and `HSQUARED_JULIA_PROJECT` pointing at
    `HSquared.jl` on the `feat/2026-07-01-phase2-multi-effect-interval`
    branch. The reproducible parity record is
    `sim/phase2_multi_effect_live_parity.R`.

2.  **The per-component intervals are asymptotic and NOT
    coverage-calibrated.** They come from a logit-scale delta-method
    finite-difference information Hessian
    (`multi_effect_ratio_interval`). A parametric bootstrap is the only
    finite-sample path; small-sample coverage of these intervals is
    untested (a calibrated interval is an open owed item on
    `V3-NEFFECT-REML`).

3.  **Only the animal ratio is a heritability.** In a K \>= 3 fit,
    [`heritability()`](https://itchyshin.github.io/hsquared/reference/heritability.md)
    returns the ANIMAL block’s additive variance over the **total**
    phenotypic variance (`σ²a / (σ²a + Σ σ²_group + σ²e)`), and
    [`heritability_interval()`](https://itchyshin.github.io/hsquared/reference/heritability_interval.md)
    returns its interval. Every other block’s ratio
    (`fit$result$variance_ratio_intervals`) is a variance-explained
    proportion, NOT a heritability.

4.  **Validation status.** `V3-NEFFECT-REML` is `covered` (experimental,
    validation-scale, opt-in; NOT the default `engine="fit"` path) via
    the doc-16 substitutable gate — a pre-declared 48-seed bias/MCSE
    recovery gate PASSED and a `sommer` same-estimand REML comparator
    agrees to ~1e-4 relative. The R `(1|g)` multi-effect surface is
    itself a public-covered model (the 3rd `public_covered_count`),
    still opt-in, with asymptotic / uncalibrated intervals. The gate is
    summarised (not re-run) at the end of this article. This article’s
    own `sommer` cross-check is additional evidence, not the primary
    gate.

## Setup

``` r

library(hsquared)
library(sommer)
library(Matrix)
```

## The fixture

A 40-animal pedigree (10 founders + 30 offspring); two environmental
factors — `nest` (8 levels) and `year` (5 levels) — assigned
**independently** of the pedigree and of each other, so all three
variance components (additive-genetic, nest, year) are separable. This
gives three independent blocks and routes to `fit_multi_effect_reml` (K
= 3). This is the same fixture as the live parity record
(`sim/phase2_multi_effect_live_parity.R`, seed 2027).

``` r

set.seed(2027)
n_found <- 10L
n_off   <- 30L
ids  <- c(paste0("f", 1:n_found), paste0("o", 1:n_off))
sire <- c(rep(NA, n_found), sample(paste0("f", 1:n_found), n_off, replace = TRUE))
dam  <- c(rep(NA, n_found), sample(paste0("f", 1:n_found), n_off, replace = TRUE))
same <- which(!is.na(sire) & sire == dam)          # avoid sire == dam
for (i in same) dam[i] <- sample(setdiff(paste0("f", 1:n_found), sire[i]), 1)
ped <- data.frame(id = ids, sire = sire, dam = dam, stringsAsFactors = FALSE)

n <- length(ids)
nest_lvls <- paste0("nst", 1:8)
year_lvls <- paste0("yr", 1:5)
nest <- sample(nest_lvls, n, replace = TRUE)
year <- sample(year_lvls, n, replace = TRUE)
nest_e <- setNames(rnorm(8, 0, 0.7), nest_lvls)
year_e <- setNames(rnorm(5, 0, 0.5), year_lvls)

# additive values by simple founder-drop (recovery is not the point here —
# parity + agreement is; the 48-seed gate below establishes recovery)
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
```

## Fitting the multi-effect model with `hsquared`

The formula lists the animal term plus each bare `(1 | group)` i.i.d.
effect. The `target = "multi_effect"` engine path fits
`y ~ μ + a + nest + year + ε` with `a ~ N(0, A σ²a)` and each
environmental effect `~ N(0, I σ²)`, all independent.

``` r

fit <- hsquared(
  y ~ animal(1 | id, pedigree = ped) + (1 | nest) + (1 | year),
  data    = dat,
  family  = gaussian(),
  control = hs_control(
    engine         = "julia",
    engine_control = list(target = "multi_effect")
  )
)
```

Read the results with the standard extractor surface:

``` r

# Variance components (all blocks + residual, in block order)
variance_components(fit)
#     component   estimate
# 1      animal  0.6741664
# 2        nest  0.5062487
# 3        year  0.4356585
# 4    residual  0.2005394

# Heritability = ANIMAL additive variance / TOTAL phenotypic variance
heritability(fit)
#     term  estimate
# 1 animal 0.3711117

# Asymptotic 95% h2 CI (delta-method, NOT coverage-calibrated)
heritability_interval(fit)
#    estimate     lower    upper level        se method boundary
#   0.3711117 0.0410334 0.890569  0.95 0.3124620  delta    FALSE

# Per-component variance-ratio intervals (animal is a heritability; the others
# are variance-explained proportions, NOT heritabilities)
fit$result$variance_ratio_intervals
# $animal  est 0.371112  CI [0.041033, 0.890569]
# $nest    est 0.278677  CI [0.074719, 0.648922]
# $year    est 0.239819  CI [0.053678, 0.636971]
```

## Building the pedigree relationship matrix A

The `sommer` comparator needs an explicit relationship matrix;
Henderson’s tabular method gives the exact pedigree-based A:

``` r

build_A_from_ped <- function(ped) {
  n <- nrow(ped); id <- ped$id
  A <- matrix(0, n, n); rownames(A) <- colnames(A) <- id
  for (i in seq_len(n)) {
    si <- if (!is.na(ped$sire[i])) match(ped$sire[i], id) else NA
    di <- if (!is.na(ped$dam[i]))  match(ped$dam[i],  id) else NA
    for (j in seq_len(i)) {
      if (i == j) {
        f_i <- if (!is.na(si) && !is.na(di)) A[si, di] / 2 else 0
        A[i, i] <- 1 + f_i
      } else {
        v <- 0
        if (!is.na(si)) v <- v + A[si, j] / 2
        if (!is.na(di)) v <- v + A[di, j] / 2
        A[i, j] <- v; A[j, i] <- v
      }
    }
  }
  A
}
A <- build_A_from_ped(ped)
dat$id   <- factor(dat$id, levels = rownames(A))
dat$nest <- factor(dat$nest)
dat$year <- factor(dat$year)
```

## `sommer` same-estimand comparator

The same-estimand
[`sommer::mmer`](https://rdrr.io/pkg/sommer/man/mmer.html) model is:

    y ~ 1 + vsr(id, Gu = A) + vsr(nest) + vsr(year) + units

- `vsr(id, Gu = A)` is the pedigree-A animal effect (estimand: `σ²a A`).
- `vsr(nest)` / `vsr(year)` are the iid environmental effects (estimand:
  `σ² I`).
- `units` is the iid residual.

This is the **exact same estimand** as the `hsquared` multi-effect
model.

``` r

sm <- mmer(
  y      ~ 1,
  random = ~ vsr(id, Gu = A) + vsr(nest) + vsr(year),
  rcov   = ~ units,
  data   = dat,
  verbose = FALSE
)
```

## Agreement table

Live-run numbers (seed 2027, 40 records, 40 pedigree animals):

| Component   | `hsquared` | `sommer`  | `|diff|` |
|-------------|------------|-----------|----------|
| σ²a         | 0.6741664  | 0.6588977 | 1.53e-02 |
| σ²nest      | 0.5062487  | 0.5069217 | 6.73e-04 |
| σ²year      | 0.4356585  | 0.4332728 | 2.39e-03 |
| σ²e         | 0.2005394  | 0.2091817 | 8.64e-03 |
| h² (animal) | 0.3711117  | 0.3643794 | 6.73e-03 |

`hsquared` (AI-REML) and `sommer` (EM-AI-REML) agree to within **1.5 ×
10⁻²** in the worst case (σ²a). The two REML optimisers differ
algorithmically (average-information vs EM-AI) and this fixture is small
(n = 40 with three variance components to separate), so
machine-precision agreement is not expected; this band is consistent
with both having converged to the same optimum. It is a cross-check that
the estimators agree on the same estimand, not a claim about
small-sample accuracy of any single component.

``` r

sm_sa2 <- as.numeric(sm$sigma[["u:id"]])
sm_sn2 <- as.numeric(sm$sigma[["u:nest"]])
sm_sy2 <- as.numeric(sm$sigma[["u:year"]])
sm_se2 <- as.numeric(sm$sigma[["units"]])
sm_vp  <- sm_sa2 + sm_sn2 + sm_sy2 + sm_se2

vc_hsq <- variance_components(fit)
hsq_h2 <- heritability(fit)$estimate

agreement <- data.frame(
  component = c("sigma_a2", "sigma_nest2", "sigma_year2", "sigma_e2", "h2_animal"),
  hsquared  = c(vc_hsq$estimate, hsq_h2),
  sommer    = c(sm_sa2, sm_sn2, sm_sy2, sm_se2, sm_sa2 / sm_vp),
  stringsAsFactors = FALSE
)
agreement$abs_diff <- abs(agreement$hsquared - agreement$sommer)
agreement
```

## Live bridge parity (the marshalling check)

Beyond the `sommer` cross-check, the reproducible record
`sim/phase2_multi_effect_live_parity.R` verifies that the R
[`hsquared()`](https://itchyshin.github.io/hsquared/reference/hsquared.md)
call and a **direct** `HSquared.fit_multi_effect_reml` +
`multi_effect_ratio_interval` on the same inputs return identical
results:

- **Marshalling identity**: R fit vs a direct fit on the marshalled
  payload (`parse_payload_v2` blocks) — max diff **0** (exact). The
  R→Julia N-block payload round-trip (JuliaCall sparse-CSC assign +
  `Dict` construction) loses nothing.
- **Independent native-Julia rebuild**: the model rebuilt from scratch
  in Julia (`pedigree_inverse` + hand-built incidence matrices +
  identity relationships) vs the R fit — max diff **0** (exact),
  confirming the R-marshalled `Z` / `Ainv` equal an independent Julia
  construction.

## Validation evidence (do not re-run)

This `sommer` cross-check is additional corroborating evidence. The
**primary validation gate** is on the Julia side (row `V3-NEFFECT-REML`
in `HSquared.validation_status()`):

- **Pre-declared 48-seed bias/MCSE recovery gate**
  (`sim/phase3_neffect_recovery_gate.jl`, predeclared commit `68cc7acc`
  BEFORE running): DGP is an 860-animal half-sib pedigree with K = 3
  independent effects — animal-A, env1-I(80 levels), env2-I(60 levels),
  both environmental factors independent of the pedigree and of each
  other; truth (σ²a, σ²g1, σ²g2, σ²e) = (1.0, 0.5, 0.5, 1.0). Seeds
  20260800..20260847, cold start. Result: **48/48 converged; all four
  `|bias| ≤ 2·MCSE`** (largest 0.34·MCSE — no detectable across-seed
  bias; this does NOT mean “unbiased”).
- **`sommer` 4.4.5 same-estimand REML comparator** on the reconstructed
  seed-20260800 dataset (`comparator/prepare_sommer_neffect.jl` +
  `comparator/run_sommer_neffect.R`, same model
  `y ~ 1 + vsr(animal, Gu = A) + vsr(g1) + vsr(g2) + units`): **AGREE —
  all four components to ~1e-4 relative** (max 8.09e-5).

References (HSquared.jl repo, branch
`feat/2026-07-01-phase2-multi-effect-interval`):
`docs/dev-log/recovery-checkpoints/2026-07-01-neffect-covered-evidence.md`,
`docs/dev-log/recovery-checkpoints/2026-07-01-neffect-recovery-gate-predeclaration.md`.

Scope of the covered claim: arbitrary-N **independent**-effect REML on
the tested identified design (Gaussian, dense/validation-scale). It does
NOT cover correlated effects (that is the direct–maternal row),
production sparse scale, small-sample accuracy of any single component,
or a public-default status — the R multi-effect surface stays
**experimental** (opt-in `target = "multi_effect"`; engine-covered is
not the same as R-public-covered).
