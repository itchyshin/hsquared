# Random regression (k = 2): sommer comparator and validation evidence

This article documents the **random-regression (reaction-norm) animal
model** — the opt-in `target = "random_regression"` path in `hsquared` —
at its covered aim **k = 2** (a linear reaction norm: intercept + one
slope, a 2 × 2 coefficient genetic covariance `K_g`). It places the
`hsquared` estimates next to a
[`sommer::mmes`](https://rdrr.io/pkg/sommer/man/mmes.html) same-estimand
cross-check and cites the engine validation evidence for the
random-regression REML estimator. It is companion reading to [Validation
evidence](https://itchyshin.github.io/hsquared/articles/validation-evidence.md)
and to the [Two-effect model
comparator](https://itchyshin.github.io/hsquared/articles/two-effect-comparator.md),
which use the same honesty ladder.

## Honesty notes

Five points frame everything below.

1.  **The fit requires a live Julia engine.** Code is shown but not
    executed at build time (the `eval = FALSE` chunk option is set
    globally). Numbers quoted in prose are from a live local run with
    `julia` on `PATH` and `HSQUARED_JULIA_PROJECT` pointing at
    `HSquared.jl` on the `feat/2026-07-01-phase3-rr-k2` branch.

2.  **Random-regression heritability is a CURVE, never a scalar.**
    [`rr_heritability()`](https://itchyshin.github.io/hsquared/reference/random_regression_extractors.md)
    returns a covariate-indexed trajectory
    `h²(t) = v_g(t) / (v_g(t) + σ²_e)` with `v_g(t) = φ(t)ᵀ K_g φ(t)`.
    The scalar
    [`heritability()`](https://itchyshin.github.io/hsquared/reference/heritability.md)
    extractor deliberately **errors** on a random-regression fit — there
    is no single “the heritability” for a reaction norm. Any scalar RR
    heritability would be a bug.

3.  **The reported `h²(t)` can OVERSTATE heritability for
    repeated-records designs.** The current engine uses a single
    **homogeneous** residual variance and has **no permanent-environment
    (PE) term**. For test-day, growth-curve, and other repeated-measures
    data, part of the between-record variance that a PE term would
    absorb is instead left in the genetic trajectory, inflating `h²(t)`.
    Heterogeneous residuals and a PE term are planned, not implemented.

4.  **Eigenfunctions are rotation-invariant functionals, not raw
    loadings.**
    [`rr_eigenfunctions()`](https://itchyshin.github.io/hsquared/reference/random_regression_extractors.md)
    returns the eigen-decomposition of `K_g` as functions of the
    covariate — eigenvalues (additive genetic variance per axis),
    proportion of genetic variance explained, sign-canonicalized
    eigen-coefficients, and the eigenfunctions `ψ_j(t) = φ(t)ᵀ v_j`.
    These are rotation-invariant; no raw, rotation-arbitrary Legendre
    loadings are interpreted.

5.  **Validation status.** The random-regression REML row `V3-RR-REML`
    is **covered at validation scale** — the maintainer G10 flip has
    been applied and the R public `rr()` surface now matches the twin
    engine’s covered status. This is experimental and opt-in (not the
    default; not production or ML; intervals on `K_g` are not
    implemented). The fences in notes 2–4 above (h²(t) is a curve, not a
    scalar; overstatement risk without PE; eigenfunctions are
    rotation-invariant) hold regardless of covered status. This
    article’s `sommer` cross-check is corroborating evidence; the
    primary gate evidence is summarized in [Validation evidence (do not
    re-run)](#validation-evidence-do-not-re-run) below.

## Setup

``` r

library(hsquared)
library(sommer)
library(Matrix)
```

## The fixture

A half-sib design with repeated records across a within-individual
covariate (call it `age`). Two sires and three dams produce 12
offspring; each offspring is recorded at 5 spread covariate points
(`age` ∈ {1, 2, 4, 6, 8}), giving 60 records. All animals are in the
pedigree; only offspring have phenotype records. The covariate varies
within individual, which is what makes a reaction-norm
(random-regression) model identifiable.

The response is generated from per-animal normalized-Legendre
coefficients (intercept + slope) with a fixed `sex` effect and a single
homogeneous residual variance.

``` r

set.seed(20260701)

ped <- data.frame(
  id   = c("s1", "s2", "d1", "d2", "d3", paste0("o", 1:12)),
  sire = c(NA, NA, NA, NA, NA,
           "s1", "s1", "s1", "s1", "s2", "s2", "s2", "s2", "s1", "s2", "s1", "s2"),
  dam  = c(NA, NA, NA, NA, NA,
           "d1", "d1", "d2", "d2", "d2", "d2", "d3", "d3", "d3", "d1", "d3", "d1"),
  stringsAsFactors = FALSE
)

animals <- paste0("o", 1:12)
ages    <- c(1, 2, 4, 6, 8)     # 5 spread covariate points

long <- expand.grid(id = animals, age = ages,
                    KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
long$sex <- ifelse(long$id %in% animals[c(TRUE, FALSE)], "m", "f")

# Per-animal Legendre intercept + slope from a true 2x2 K_g.
K_true <- matrix(c(0.40, 0.10, 0.10, 0.20), 2, 2)
Zc     <- matrix(rnorm(length(animals) * 2), length(animals), 2) %*% chol(K_true)
rownames(Zc) <- animals

# Normalized Legendre design (order 2) on the standardized covariate.
tstd <- 2 * (long$age - min(ages)) / (max(ages) - min(ages)) - 1
phi  <- cbind(sqrt(1 / 2), sqrt(3 / 2) * tstd)

long$weight <- c(m = 2.0, f = 2.3)[long$sex] +
  rowSums(phi * Zc[long$id, ]) +
  rnorm(nrow(long), sd = sqrt(0.15))    # homogeneous residual
```

## Fitting the random-regression model with `hsquared`

The model puts `rr(age, order = 2)` on the left-hand side of the
[`animal()`](https://itchyshin.github.io/hsquared/reference/animal.md)
term and selects the random-regression engine target.
`rr(covariate, order = k)` requests a `k`-coefficient
normalized-Legendre reaction norm (`order = 2` = intercept + slope); the
covariate is standardized to `[-1, 1]` over its observed range inside
the engine.

``` r

fit <- hsquared(
  weight ~ sex + animal(rr(age, order = 2) | id, pedigree = ped),
  data    = long,
  family  = gaussian(),
  REML    = TRUE,
  control = hs_control(
    engine         = "julia",
    engine_control = list(target = "random_regression", iterations = 2000L)
  )
)
```

Read the reaction-norm results with the random-regression extractor
surface:

``` r

# 2 x 2 coefficient genetic covariance K_g (Legendre intercept, slope)
rr_covariance(fit)
#           legendre0 legendre1
# legendre0 1.528553  0.203163
# legendre1 0.203163  0.248646

# Residual variance (single, homogeneous)
fit$result$residual_variance
# [1] 0.1117737

# Heritability TRAJECTORY (a curve, never a scalar) at chosen covariate points
rr_heritability(fit, at = c(1, 2, 4, 6, 8))
#   covariate     value
# 1         1 0.8754097
# 2         2 0.8628529
# 3         4 0.8658810
# 4         6 0.8979575
# 5         8 0.9301810

# The scalar heritability() extractor ERRORS on a random-regression fit:
# heritability(fit)
# Error: This `hsquared_fit` object does not contain heritability estimates ...

# Genetic variance trajectory v_g(t) = phi(t)' K_g phi(t)
rr_genetic_variance(fit, at = c(1, 4, 8))

# Genetic correlation surface across covariate points (unit diagonal)
rr_correlation(fit, at = c(1, 4, 8))

# Rotation-invariant eigenfunctions of K_g (no raw loadings)
rr_eigenfunctions(fit, at = c(1, 4, 8))
```

The estimated `h²(t)` above sits near 0.86–0.93. That is high, and it
illustrates honesty note 3 directly: with a homogeneous residual and no
permanent-environment term, a repeated-records design pushes
between-record variation into the genetic trajectory. Read these as a
demonstration that the estimator and the extractor surface agree, not as
an accuracy claim for this small fixture.

## Building the pedigree relationship matrix A

The `sommer` comparator needs an explicit relationship matrix `A`.
Henderson’s tabular method gives the exact pedigree-based `A` (identical
to the helper in the [two-effect
comparator](https://itchyshin.github.io/hsquared/articles/two-effect-comparator.md)):

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
[`sommer::mmes`](https://rdrr.io/pkg/sommer/man/mmes.html) model uses
[`leg()`](https://rdrr.io/pkg/enhancer/man/leg.html) for the
normalized-Legendre basis and an **unstructured** 2 × 2 genetic
covariance over the intercept and slope, tied to the pedigree `A`:

``` r

# Standardize the covariate the same way the engine does, then build the leg() term.
long$t <- 2 * (long$age - min(long$age)) / (max(long$age) - min(long$age)) - 1

sm <- mmes(
  weight ~ 1 + sex,
  random = ~ vsm(usm(leg(t, 1)), ism(id), Gu = A),   # unstructured 2x2 K_g on pedigree A
  rcov   = ~ units,
  data   = long,
  verbose = FALSE
)
```

Two contract points make this a genuine same-estimand check:

- **Use the current `mmes` / `vsm` interface, not the legacy `mmer` /
  `vsr`.** In the modern `sommer`,
  `vsm(usm(leg(t, 1)), ism(id), Gu = A)` estimates the full unstructured
  2 × 2 coefficient covariance `K_g`. The legacy
  `mmer(random = ~ vsr(...))` path silently collapses the random
  regression and must not be used for this comparison.
- **The Legendre normalization matches by construction.**
  `sommer::leg()` uses the identical normalized Legendre basis
  `φ_n(t) = √((2n+1)/2) · P_n(t)` as the engine’s `legendre_design` (the
  standardization matrix `D = I₂`; maximum basis difference ≈ 7 ×
  10⁻¹³). So the comparison is on the absolute variance entries of `K_g`
  in a common basis — not a correlation-only check, which could pass
  spuriously.

## Agreement (engine validation evidence, do not re-run)

The engine’s committed same-estimand comparator
(`comparator/prepare_sommer_rr.jl` + `comparator/run_sommer_rr.R` in the
`HSquared.jl` repo) reconstructs the pre-declared seed-20261000
recovery-gate dataset exactly and fits the model above. On the absolute
`K_g` entries and residual variance in the shared Legendre basis,
`hsquared` (dense REML) and `sommer` (EM-AI-REML) **agree to ≤ 1.9 ×
10⁻⁵ relative**:

| Component                  | engine `hsquared` | `sommer` `mmes` | rel. diff |
|----------------------------|-------------------|-----------------|-----------|
| `K_g[1,1]` (intercept var) | 0.914884          | 0.914867        | 1.9e-5    |
| `K_g[2,2]` (slope var)     | 0.469791          | 0.469795        | 7.7e-6    |
| `K_g[1,2]` (covariance)    | 0.369880          | 0.369881        | 1.4e-6    |
| `σ²e`                      | 1.020958          | 1.020959        | 8.4e-7    |

Both optimizers maximize the same REML likelihood on the same data. The
two REML algorithms differ (dense average-information/Nelder–Mead vs
EM-AI), so machine-precision agreement is not expected; this band is
consistent with both having converged to the same optimum. This is a
single-seed point-estimate leg, complementary to the multi-seed recovery
gate below.

``` r

# Sketch of the comparison at the estimate (see the HSquared.jl comparator scripts for the
# exact reconstruction of the pre-declared gate dataset and the tabulated relative differences).
Kg_hsq <- rr_covariance(fit)
sm_vc  <- summary(sm)$varcomp
Kg_hsq
sm_vc
```

## Validation evidence (do not re-run)

This `sommer` cross-check is corroborating evidence. The **primary
validation evidence** for the random-regression REML estimator lives on
the Julia side (row `V3-RR-REML` in `HSquared.validation_status()`), at
the covered aim **k = 2**:

- **Pre-declared 48-seed bias/MCSE recovery gate**
  (`sim/phase3_rr_recovery_gate.jl`; predeclaration committed **before**
  the run, harness byte-identical pre/post). DGP: half-sib q = 360 (300
  recorded offspring × 6 spread normalized-Legendre covariate points, n
  = 1800); truth `K_g = [1.0 0.3; 0.3 0.5]`, `σ²e = 1.0`; seeds
  20261000..20261047; cold start `K_g = I₂`. **Result: 48/48 converged;
  all four `|bias| ≤ 2·MCSE`:**

  | component  | mean   | truth | bias    | \|bias\|/MCSE |
  |------------|--------|-------|---------|---------------|
  | `K_g[1,1]` | 0.9781 | 1.00  | −0.0219 | 1.16          |
  | `K_g[2,2]` | 0.5183 | 0.50  | +0.0183 | 1.67          |
  | `K_g[1,2]` | 0.2984 | 0.30  | −0.0016 | 0.17          |
  | `σ²e`      | 0.9992 | 1.00  | −0.0008 | 0.15          |

  Read as **no detectable across-seed bias** (the noisiest term, the
  slope variance, sits at 1.67·MCSE), never “unbiased”.

- **`sommer` 4.4.5 same-estimand REML comparator**
  ([`leg()`](https://rdrr.io/pkg/enhancer/man/leg.html) /
  `vsm(usm(...), ism(id), Gu = A)`) on the reconstructed seed-20261000
  dataset: all `K_g` entries and `σ²e` agree to **≤ 1.9 × 10⁻⁵
  relative** (table above).

References (HSquared.jl repo, branch `feat/2026-07-01-phase3-rr-k2`):
`docs/dev-log/recovery-checkpoints/2026-07-01-rr-k2-recovery-gate-predeclaration.md`,
`docs/dev-log/recovery-checkpoints/2026-07-01-rr-k2-covered-evidence.md`,
and the convention lock `docs/design/22-rr-convention-lock.md`.

Do not re-run these gates. They are committed evidence, not live code.

## Scope

The covered aim is **k = 2** (a linear reaction norm) for the Gaussian
animal model: a 2 × 2 `K_g` plus a homogeneous residual variance, on an
identified normalized-Legendre design at dense/validation scale. Not in
scope: `k ≥ 3` (reduced-rank / factor-analytic `K_g`, post-v1.0);
heterogeneous residuals; a permanent-environment term; production sparse
scale; and raw random slopes `(x | g)` (a frozen grammar slot with no
estimator). `h²(t)` is always a curve; the animal-block ratio is a
narrow-sense heritability trajectory, subject to the PE-overstatement
caveat above.
