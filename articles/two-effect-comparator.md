# Two-effect model: sommer comparator and validation evidence

This article documents the **common-environment (c²) and
maternal-genetic (m²) two-effect animal model** — the opt-in
`target = "two_effect"` path in `hsquared` — and places its estimates
next to a [`sommer::mmer`](https://rdrr.io/pkg/sommer/man/mmer.html)
same-estimand cross-check. It is companion reading to [Validation
evidence](https://itchyshin.github.io/hsquared/articles/validation-evidence.md),
which explains what “covered” means in the `hsquared` validation ladder.

## Honesty notes

Four points frame everything below.

1.  **The fit requires a live Julia engine.** Code is shown but not
    executed at build time (the `eval = FALSE` chunk option is set
    globally). Numbers quoted in prose are from a live local run with
    `julia` on `PATH` and `HSQUARED_JULIA_PROJECT` pointing at
    `HSquared.jl` on the `feat/2026-07-01-phase1-two-effect-public`
    branch.

2.  **`h²`/`c²`/`m²` intervals are asymptotic and NOT
    coverage-calibrated.** They come from a logit-scale delta-method
    finite-difference information Hessian (`two_effect_ratio_interval`,
    J1). A parametric bootstrap is the only finite-sample path;
    small-sample coverage of these intervals is untested (the calibrated
    interval is an open owed item on `V3-TWOEFFECT-REML`).

3.  **c² is a variance ratio, not a heritability.**
    [`common_env_proportion()`](https://itchyshin.github.io/hsquared/reference/common_env_proportion.md)
    is `σ²c / (σ²a + σ²c + σ²e)`, which quantifies the fraction of
    phenotypic variance due to the shared common environment (litter,
    cohort, etc.). It is not a measure of heritability.

4.  **Validation status.** `V3-TWOEFFECT-REML` is `covered`
    (experimental, validation-scale, opt-in; NOT the public default) via
    the doc-33 substitutable gate:

    - a pre-declared 48-seed bias/MCSE recovery gate PASSED (48/48
      converged, all three `|bias| ≤ 2·MCSE` — no detectable bias, never
      “unbiased”);
    - a `blupf90+` 2.60 same-estimand REML comparator agrees to ~1e-5.
      Details:
      `docs/dev-log/recovery-checkpoints/2026-06-30-v3-two-effect-recovery-gate-predeclaration.md`
      and
      `docs/dev-log/recovery-checkpoints/2026-06-30-v3-two-effect-blupf90-comparator.md`
      (Julia repo, branch `feat/2026-07-01-phase1-two-effect-public`).
      This article’s `sommer` cross-check is additional evidence, not
      the primary gate.

## Setup

``` r

library(hsquared)
library(sommer)
library(Matrix)
```

## The fixture

A half-sib design: 5 sires each mated to 4 dams (20 litters), 3
offspring per litter (60 records). All animals are in the pedigree (85
rows); only offspring have phenotype records. Litter membership is
assigned independently of the additive-genetic structure, so the common
environment and additive-genetic effects are separable. True generating
parameters are σ²a = 0.6, σ²c = 0.4, σ²e = 1.0 (h² = 0.30, c² = 0.20).

``` r

set.seed(314)

n_sires <- 5
n_dams  <- 20   # 4 dams per sire
n_per   <- 3    # offspring per litter

sire_ids <- paste0("s", seq_len(n_sires))
dam_ids  <- paste0("d", seq_len(n_dams))
off_ids  <- paste0("o", seq_len(n_dams * n_per))
all_ids  <- c(sire_ids, dam_ids, off_ids)

ped <- data.frame(
  id   = all_ids,
  sire = c(rep(NA, n_sires),
           rep(NA_character_, n_dams),
           rep(sire_ids, each = (n_dams / n_sires) * n_per)),
  dam  = c(rep(NA, n_sires),
           rep(NA_character_, n_dams),
           rep(dam_ids, each = n_per)),
  stringsAsFactors = FALSE
)

litter_off <- rep(dam_ids, each = n_per)

# Simulate: σ²a = 0.6, σ²c = 0.4, σ²e = 1.0
ebv_sire <- rnorm(n_sires, 0, sqrt(0.6))
ebv_dam  <- rnorm(n_dams,  0, sqrt(0.6))
ebv_off  <- numeric(n_dams * n_per)
for (i in seq_along(ebv_off)) {
  si <- match(ped$sire[n_sires + n_dams + i], sire_ids)
  di <- match(ped$dam[n_sires  + n_dams + i], dam_ids)
  ebv_off[i] <- (ebv_sire[si] + ebv_dam[di]) / 2 + rnorm(1, 0, sqrt(0.6 / 2))
}
c_eff <- setNames(rnorm(n_dams, 0, sqrt(0.4)), dam_ids)

dat <- data.frame(
  y      = 10 + ebv_off + c_eff[litter_off] + rnorm(n_dams * n_per, 0, 1),
  id     = off_ids,
  litter = litter_off,
  stringsAsFactors = FALSE
)
```

## Fitting the two-effect model with `hsquared`

The model is
`y ~ animal(1 | id, pedigree = ped) + common_env(1 | litter)`. The
`target = "two_effect"` engine path fits `y ~ μ + a + c + ε` where
`a ~ N(0, A σ²a)` and `c ~ N(0, I σ²c)` are independent. The
[`heritability()`](https://itchyshin.github.io/hsquared/reference/heritability.md)
extractor returns `h² = σ²a / Vp`; the new
[`common_env_proportion()`](https://itchyshin.github.io/hsquared/reference/common_env_proportion.md)
extractor returns `c² = σ²c / Vp`.

``` r

fit <- hsquared(
  y ~ animal(1 | id, pedigree = ped) + common_env(1 | litter),
  data    = dat,
  family  = gaussian(),
  control = hs_control(
    engine         = "julia",
    engine_control = list(target = "two_effect")
  )
)
```

Read the results with the standard extractor surface:

``` r

# Variance components
variance_components(fit)
#   component  estimate
# 1    animal  1.0424
# 2 common_env  0.0271
# 3  residual  0.7234

# Heritability (narrow-sense, within this model)
heritability(fit)
#   term  estimate
# 1 animal  0.5814

# Common-environment proportion
common_env_proportion(fit)
#   term       estimate                  (attr: interpretation = "variance ratio...")
# 1 common_env  0.0151

# Asymptotic 95 % CIs (delta-method, NOT coverage-calibrated)
heritability_interval(fit)
#   estimate  lower  upper  method  boundary
#   0.5814    0.0089 0.9954 delta   FALSE

common_env_proportion_interval(fit)
#   estimate  lower  upper  boundary
#   0.0151    0.000  1.000  FALSE
```

## Building the pedigree relationship matrix A

The `sommer` comparator requires an explicit relationship matrix.
Henderson’s tabular method gives the exact pedigree-based A:

``` r

build_A_from_ped <- function(ped) {
  n <- nrow(ped); ids <- ped$id
  A <- matrix(0, n, n); rownames(A) <- colnames(A) <- ids
  for (i in seq_len(n)) {
    si <- if (!is.na(ped$sire[i])) match(ped$sire[i], ids) else NA
    di <- if (!is.na(ped$dam[i]))  match(ped$dam[i],  ids) else NA
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
```

## `sommer` same-estimand comparator

The same-estimand
[`sommer::mmer`](https://rdrr.io/pkg/sommer/man/mmer.html) model is:

    y ~ 1 + vsr(id, Gu = A) + vsr(litter) + units

- `vsr(id, Gu = A)` is the pedigree-A animal effect (estimand: `σ²a A`).
- `vsr(litter)` is the iid common-environment effect (estimand:
  `σ²c I`).
- `units` is the iid residual.

This is the **exact same estimand** as the `hsquared` two-effect model.

``` r

sm <- mmer(
  y      ~ 1,
  random = ~ vsr(id, Gu = A) + vsr(litter),
  rcov   = ~ units,
  data   = dat,
  verbose = FALSE
)
```

## Agreement table

Live-run numbers (seed 314, 60 records, 85 pedigree animals):

| Component | True | `hsquared` | `sommer` | `|diff|` |
|-----------|------|------------|----------|----------|
| σ²a       | 0.60 | 1.0424     | 1.0424   | 2.2e-05  |
| σ²c       | 0.40 | 0.0271     | 0.0271   | 3.5e-06  |
| σ²e       | 1.00 | 0.7234     | 0.7234   | 1.6e-05  |
| h²        | 0.30 | 0.5814     | 0.5814   | 1.1e-05  |
| c²        | 0.20 | 0.0151     | 0.0151   | 1.9e-06  |

`hsquared` (AI-REML) and `sommer` (EM-AI-REML) agree to within **2.2 ×
10⁻⁵** in the worst case (σ²a). The two REML optimisers differ
algorithmically (average-information vs EM-AI), so machine-precision
agreement is not expected; this band is consistent with both having
converged to the same optimum.

Note: the estimated h² (0.58) is far from the true h² (0.30). This is
expected on 60 records — the data are too few for a tight estimate. This
is a cross-check that the estimators agree, not a claim about their
accuracy on small samples.

``` r

sm_sa2 <- sm$sigma[["u:id"]]
sm_sc2 <- sm$sigma[["u:litter"]]
sm_se2 <- sm$sigma[["units"]]
sm_vp  <- sm_sa2 + sm_sc2 + sm_se2

vc_hsq <- variance_components(fit)
hsq_h2 <- heritability(fit)$estimate
hsq_c2 <- common_env_proportion(fit)$estimate

agreement <- data.frame(
  component = c("sigma_a2", "sigma_c2", "sigma_e2", "h2", "c2"),
  hsquared  = c(vc_hsq$estimate, hsq_h2, hsq_c2),
  sommer    = c(sm_sa2, sm_sc2, sm_se2, sm_sa2 / sm_vp, sm_sc2 / sm_vp),
  stringsAsFactors = FALSE
)
agreement$diff <- abs(agreement$hsquared - agreement$sommer)
agreement
```

## Boundary behaviour

When `σ²c → 0` (e.g. each animal in its own litter, so the
common-environment is unidentified), the engine flags the interval as
`boundary = TRUE` and returns `NA` bounds — not a spurious narrow CI.
This is tested in the live test suite (`test-common-env.R`).

## Validation evidence (do not re-run)

This sommer cross-check is additional corroborating evidence. The
**primary validation gate** is on the Julia side (row
`V3-TWOEFFECT-REML` in `HSquared.validation_status()`):

- **Pre-declared 48-seed bias/MCSE recovery gate**
  (`sim/phase3_two_effect_bias_mcse.jl`, predeclared commit `41bd18f6`
  BEFORE running): 48/48 converged, all three `|bias| ≤ 2·MCSE`. No
  detectable bias; this does NOT mean “unbiased”.
- **`blupf90+` 2.60 same-estimand REML comparator** from a neutral start
  (6 rounds) on the seed-20260618 dataset: (σ²a, σ²c, σ²e) = (1.1457,
  0.4793, 0.8867), agreement to ~1e-5.

References:
`docs/dev-log/recovery-checkpoints/2026-06-30-v3-two-effect-recovery-gate-predeclaration.md`,
`docs/dev-log/recovery-checkpoints/2026-06-30-v3-two-effect-blupf90-comparator.md`
(HSquared.jl repo).

Do not re-run these gates. They are committed evidence, not live code.
