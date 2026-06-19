# A worked animal-model analysis (gryphon)

This article walks one univariate animal model end to end on a real
teaching dataset — fit, heritability with its experimental uncertainty,
breeding values and accuracy, and a diagnostic plot — so you can see the
whole `hsquared` extractor surface in one place. It complements the
broad [Fitting
models](https://itchyshin.github.io/hsquared/articles/fitting-models.md)
tour and the [sommer / pedigreemm
benchmark](https://itchyshin.github.io/hsquared/articles/benchmark-comparators.md)
(which checks the same fit against external packages).

Two honesty notes first:

- **Fitting needs a local engine.** The default
  [`hsquared()`](https://itchyshin.github.io/hsquared/reference/hsquared.md)
  fit marshals to a local Julia + `HSquared.jl` + `JuliaCall`. The code
  below is shown but not executed at build time; the heritability value
  quoted is the published/recovered estimate (see the benchmark article
  for the executed agreement).
- **gryphon uses a supplied relationship matrix.** The raw gryphon
  pedigree contains ancestral loops that pedigree tools refuse, so the
  relationship information is supplied directly as `A_gryphon` rather
  than parsed from a raw pedigree. Most of your own datasets will use
  the ordinary `animal(1 | id, pedigree = ped)` path shown in [Fitting
  models](https://itchyshin.github.io/hsquared/articles/fitting-models.md).

## The data and question

The gryphon birth-weight dataset
([`enhancer::DT_gryphon`](https://rdrr.io/pkg/enhancer/man/DT_gryphon.html)
/ `A_gryphon`, from Wilson et al. 2010, *An ecologist’s guide to the
animal model*) is the canonical teaching example. The question is the
classic one: **how heritable is birth weight?** — i.e. what fraction of
phenotypic variance is additive genetic, `h² = σ²a / (σ²a + σ²e)`.

``` r

library(hsquared)
utils::data("DT_gryphon", package = "enhancer")
str(DT_gryphon[, c("ANIMAL", "BWT")])
```

## Fit the animal model

The univariate Gaussian animal model is `BWT ~ 1 + animal`, by REML.
With a raw pedigree you would write
`hsquared(BWT ~ animal(1 | id, pedigree = ped), data = dat)`; for
gryphon the relationship information is supplied via the engine path.

``` r

# Requires a local Julia + HSquared.jl + JuliaCall.
fit <- hsquared(BWT ~ animal(1 | id, pedigree = ped), data = dat)
fit
```

## Read the result

The published REML estimates are `σ²a = 3.3954`, `σ²e = 3.8286`, giving
**`h² = 0.470`** — birth weight is moderately heritable.
[`summary()`](https://rdrr.io/r/base/summary.html) reports the point
estimates and, when a local engine provides them, the **experimental**
uncertainty surfaces (asymptotic, REML-only — see [Validation
evidence](https://itchyshin.github.io/hsquared/articles/validation-evidence.md)):

``` r

summary(fit)
heritability(fit)          # point estimate (≈ 0.470)
heritability_interval(fit) # experimental logit delta-method CI, if available
heritability_standard_error(fit)
variance_component_standard_errors(fit)
```

The interval and standard errors are reported as
point-estimate-plus-bounds only; they are not coverage-calibrated and
should not be read as validated inference.

## Breeding values and accuracy

``` r

ebv <- breeding_values(fit)   # one predicted additive genetic value per animal
head(ebv)
accuracy(fit)                 # sqrt(reliability), when reliability is present
```

## A diagnostic look

``` r

plot(fit, type = "variance")   # components, with experimental +/- 1.96 SE whiskers if present
plot(fit, type = "residuals")  # residuals vs fitted
```

## Interpreting `h² = 0.47`

A heritability near one-half means roughly half the variation in birth
weight among these animals is additive genetic — there is appreciable
raw material for a response to selection, and the predicted breeding
values rank animals by genetic merit for the trait. As always, `h²` is a
property of *this population in this environment*, not a fixed constant
of the trait.

## Honest boundaries

- The fit requires a local engine; gryphon uses a supplied relationship
  matrix (the raw pedigree is pathological). Your own analyses will
  typically use `animal(1 | id, pedigree = ped)`.
- The CI/SE surfaces are **experimental** (engine row `V1-HERIT-CI`,
  `partial`): asymptotic, REML-only, unreliable at small `n`. They are
  reported, not validated.
- gryphon is teaching/simulated data; the published numbers are an
  external anchor, not a known-truth simulation. For bias/coverage and
  external-package agreement see [Validation
  evidence](https://itchyshin.github.io/hsquared/articles/validation-evidence.md)
  and the
  [benchmark](https://itchyshin.github.io/hsquared/articles/benchmark-comparators.md).

## See also

- [Fitting
  models](https://itchyshin.github.io/hsquared/articles/fitting-models.md)
  — the broad tour, including the ordinary raw-pedigree path and the
  opt-in models.
- [Benchmark: hsquared vs sommer and
  pedigreemm](https://itchyshin.github.io/hsquared/articles/benchmark-comparators.md)
  — the same gryphon fit checked against external REML fitters.
