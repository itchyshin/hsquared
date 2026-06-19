# Benchmark: hsquared vs sommer and pedigreemm

This article is a **documented, reproducible benchmark**: it places the
v0.1 Gaussian animal-model fit next to two established external REML
fitters — [`sommer`](https://CRAN.R-project.org/package=sommer) and
[`pedigreemm`](https://CRAN.R-project.org/package=pedigreemm) — on a
standard dataset, and shows the agreement against the
maintainer-signed-off band. Its companion, [Validation
evidence](https://itchyshin.github.io/hsquared/articles/validation-evidence.md),
explains *what “validated” means*; this page *shows the numbers*.

Two honesty points frame everything below:

- The agreement table is computed by hsquared’s **pure-R REML reference
  optimiser**, which runs in public CI (given the Suggests packages) and
  needs **no Julia**. The production engine (`fit_ai_reml` /
  `fit_sparse_reml`) recovers the same values within the same band when
  given the supplied relationship matrix, but that leg is skip-guarded
  and runs only on a machine with a local Julia + `HSquared.jl` +
  `JuliaCall`. Engine and pure-R reference agree to machine precision.
- `sommer` is a **two-sided agreement** check; `pedigreemm` is only a
  **one-sided log-likelihood floor** (explained in its own section).
  They are evidence *behind* the `covered` v0.1 fit, not separately
  “covered” capabilities.

## The dataset and model

The benchmark uses the **gryphon** birth-weight dataset (`DT_gryphon` /
`A_gryphon`) shipped in the CRAN package `enhancer`, from Wilson et
al. (2010), *An ecologist’s guide to the animal model*, *J. Anim. Ecol.*
79:13–26. It is **teaching / simulated** data with a known published
REML fit, which is exactly what makes it a good external anchor.

The model is the univariate Gaussian animal model `BWT ~ 1 + animal`,
fitted by REML. The raw gryphon pedigree contains ancestral loops that
general pedigree tools refuse, so the relationship information is
supplied directly as `A_gryphon` (the same path the engine uses).

## The published anchor and the benchmark

Published REML estimates (Wilson et al. 2010): `σ²a = 3.3954`,
`σ²e = 3.8286`, `h² = 0.470`.

The values below were computed by the reproducing code in the next
section. The CI test asserts that the pure-R reference and `sommer`
agree with the published anchor within the signed-off band
(`expect_equal(..., tolerance = 0.02)`, a relative `0.02` on each
variance component; the `h²`-vs-`sommer` check is an absolute `0.02`
bound).

| Source | σ²a (animal) | σ²e (residual) | h² |
|----|----|----|----|
| Published (Wilson et al. 2010) | 3.3954 | 3.8286 | 0.470 |
| hsquared — pure-R REML reference | 3.3953 | 3.8287 | 0.470 |
| [`sommer::mmes()`](https://rdrr.io/pkg/sommer/man/mmes.html) | 3.3954 | 3.8286 | 0.470 |

All three agree to roughly four decimal places.

**The signed-off band** (maintainer, 2026-06-13;
`docs/design/01-v0.1-contract.md`): variance components within ~1–2%
relative, `h²` within ~0.01–0.02 absolute, EBV correlation \> 0.999. The
CI test implements the variance-component and `h²` portion (relative
`0.02` on the variance components via `expect_equal`); the
EBV-correlation criterion is a signed-off **target** verified on the
engine side, not a number this R atom produces.

### Reproduce it

This is the exact code the benchmark runs (gryphon anchor + the optional
`sommer` agreement leg):

``` r

library(hsquared)

# Gryphon birth-weight data (teaching data; Wilson et al. 2010)
utils::data("DT_gryphon", package = "enhancer")
DT <- DT_gryphon
A <- A_gryphon
dat <- DT[!is.na(DT$BWT), ]
ids <- rownames(A)

# Published anchor
pub <- c(sigma_a2 = 3.3954, sigma_e2 = 3.8286, h2 = 0.470)

# hsquared's independent pure-R REML reference on y, X, Z, Ainv
y <- dat$BWT
X <- matrix(1, length(y), 1L)
j <- match(as.character(dat$ANIMAL), ids)
Z <- matrix(0, length(y), length(ids))
Z[cbind(seq_along(j), j)] <- 1
ref <- hsquared:::hs_reml_estimate_reference(
  y, X, Z, solve(A),
  method = "REML", initial = c(sigma_a2 = 3, sigma_e2 = 4)
)
# ref$estimate -> sigma_a2 = 3.3953, sigma_e2 = 3.8287; h2 = 0.470

# Two-sided agreement against sommer
d2 <- dat
d2$ANIMAL <- factor(as.character(d2$ANIMAL))
m <- sommer::mmes(
  BWT ~ 1,
  random = ~ sommer::vsm(sommer::ism(ANIMAL), Gu = A),
  data = d2, verbose = FALSE
)
# sort(unlist(m$theta)) -> 3.3954, 3.8286; animal h2 = 0.470
```

## `pedigreemm`: a one-sided floor, not an agreement

`pedigreemm` is **not** in the table above, on purpose. Its optimiser
lands slightly off the REML optimum on pedigree models, and it cannot
fit the saturated one-record-per-animal design at all. So it is run on a
deliberately **replicated** dataset (three records per animal on the
12-animal Mrode pedigree, so the design is non-degenerate), and it is
used only to assert a **one-sided lower bound**: under the same verified
REML objective, hsquared’s solution is *at least as good as*
pedigreemm’s.

Executed result (replicated fixture):

| Quantity            | hsquared (pure-R reference) | pedigreemm |
|---------------------|-----------------------------|------------|
| REML log-likelihood | **−52.2836**                | −52.3097   |

hsquared reaches the higher (better) REML log-likelihood —
`logLik(hsquared) ≥ logLik(pedigreemm)` — by ~0.026. This is an
optimiser-quality floor, **not** a two-sided agreement, **not** DGP
recovery, and **not** ASReml parity.

``` r

fx <- hsquared:::hs_replicated_animal_comparator_fixture()
lab <- as.character(fx$pedigree$id)

# pedigreemm REML fit on the replicated design
ped <- pedigreemm::pedigree(
  sire = match(as.character(fx$pedigree$sire), lab),
  dam = match(as.character(fx$pedigree$dam), lab), label = lab
)
dd <- fx$data
dd$id <- factor(as.character(dd$id), levels = lab)
m <- pedigreemm::pedigreemm(y ~ x + (1 | id), data = dd, pedigree = list(id = ped))

# hsquared reference + the shared REML objective; assert hsquared >= pedigreemm
# (see tests/testthat/test-validation-fixtures.R for the full comparison).
```

## What runs where (reproducibility)

| Leg | Needs | Runs in CI? |
|----|----|----|
| Published ↔︎ pure-R reference ↔︎ `sommer` | `enhancer`, `sommer` (Suggests) | yes (skipped on CRAN) |
| `pedigreemm` one-sided floor | `pedigreemm`, `withr` (Suggests) | yes (skipped on CRAN) |
| **Engine** recovery (`fit_ai_reml`/`fit_sparse_reml`) via supplied `A_gryphon` | local Julia + `HSquared.jl` + `JuliaCall` | no — local only |

The CI-runnable legs use the pure-R reference optimiser; CI staying
green confirms the R lane and the discriminating power of the
comparison. The engine recovers the same values within the same band
locally, and the engine matches the pure-R reference to machine
precision.

## Honest boundaries

- Not bit-exact; the gryphon population is teaching/simulated data, and
  the headline published numbers should be re-confirmed before any new
  promotion.
- This benchmark verifies variance-component and `h²` agreement; it does
  not by itself produce the EBV-correlation criterion of the signed-off
  band (that is verified engine-side).
- `pedigreemm` is a one-sided floor only — never read it as “hsquared
  agrees with pedigreemm”.
- This is recovery against a *published external estimate*, not a
  known-truth simulation. For bias/coverage over simulated truth, see
  the DGP recovery study in [Validation
  evidence](https://itchyshin.github.io/hsquared/articles/validation-evidence.md).
- In the package’s
  [`validation_status()`](https://itchyshin.github.io/hsquared/reference/validation_status.md),
  the relevant `covered` rows are the external published-REML recovery
  (gryphon, R reference) and the default univariate Gaussian fit;
  `sommer` and `pedigreemm` are evidence behind those, not separately
  “covered”.

## See also

- [Validation
  evidence](https://itchyshin.github.io/hsquared/articles/validation-evidence.md)
  — what “validated” means, the full evidence ladder, and the
  public-CI-vs-local split.
- [`vignette()`](https://rdrr.io/r/utils/vignette.html) /
  [`?validation_status`](https://itchyshin.github.io/hsquared/reference/validation_status.md)
  — the live source of truth for capability status.
