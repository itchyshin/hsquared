# Direct-maternal correlated model extractors

These extractors summarize an opt-in, **experimental** direct-maternal
correlated model (`target = "direct_maternal"`), fitted with
`animal(1 | id, pedigree = ped) + maternal_genetic(1 | dam)`. The model
estimates a 2x2 genetic covariance matrix G_dm between the direct
additive and maternal additive effects, plus a residual variance.

## Usage

``` r
direct_heritability(object, ...)

direct_variance(object, ...)

partner_variance(object, ...)

direct_maternal_covariance(object, ...)

total_heritability(object, ...)
```

## Arguments

- object:

  An `hsquared_fit` from `target = "direct_maternal"`.

- ...:

  Not used.

## Value

- `direct_heritability()`: a one-row data frame with `term` and
  `estimate`, plus an `"interpretation"` attribute.

- `total_heritability()`: a one-row data frame with
  `term = "total_willham"` and `estimate`, plus an `"interpretation"`
  attribute.

- `direct_variance()`, `partner_variance()`,
  `direct_maternal_covariance()`: single numerics (the raw variance
  component).

## Details

Willham fence: the direct-maternal model (Willham 1963, 1972)
distinguishes the **direct** narrow-sense heritability
`h2_d = sigma_ad / sigma_P` from the maternal variance ratio
`m2 = sigma_am / sigma_P`, the Willham total (selection-response)
heritability
`h2_T = (sigma_ad + 1.5*sigma_dm + 0.5*sigma_am) / sigma_P`, and the
genetic covariance `sigma_dm`.
`sigma_P = sigma_ad + sigma_am + sigma_dm + sigma_e2 = Var(y_i)` for a
non-inbred base (coefficient 1 on `sigma_dm` because
`2 * A[i,dam] = 2 * (1/2) = 1`). **h2 is denominator-dependent under
maternal effects; compare (co)variance components, not h2 values, across
software (ASReml/BLUPF90/WOMBAT/sommer/MCMCglmm all leave sigma_P to the
user).** A **negative** genetic correlation `r_am` is real and
biologically expected in many livestock traits; it reflects an
antagonistic direct-maternal relationship and does NOT indicate a model
failure.

Note: the 2x2 G_dm formulation is due to Willham (1963, 1972), not
Falconer (1965). Falconer's single-m model fixes `r_am = +/-1` and is a
special case (Bijma 2011).

`direct_heritability()` returns the direct narrow-sense heritability
with an interpretation attribute. `total_heritability()` returns
Willham's selection-response heritability `h2_T`. `direct_variance()`,
`partner_variance()`, and `direct_maternal_covariance()` return the raw
variance-component scalars.
[`genetic_correlation()`](https://itchyshin.github.io/hsquared/reference/multivariate_extractors.md)
on a direct-maternal fit returns the between-effect correlation r_am.

## See also

[`variance_components()`](https://itchyshin.github.io/hsquared/reference/variance_components.md),
[`genetic_correlation()`](https://itchyshin.github.io/hsquared/reference/multivariate_extractors.md),
[`maternal_effects()`](https://itchyshin.github.io/hsquared/reference/maternal_effects.md),
`total_heritability()`

## Examples

``` r
if (FALSE) {
fit_dm <- hsquared(
  y ~ 1 + animal(1 | id, pedigree = ped) + maternal_genetic(1 | dam),
  data = dat,
  family = gaussian(),
  REML = TRUE,
  control = hs_control(
    engine = "julia",
    engine_control = list(target = "direct_maternal")
  )
)

direct_heritability(fit_dm)    # h2_d (direct narrow-sense)
total_heritability(fit_dm)     # h2_T (Willham selection-response)
genetic_correlation(fit_dm)    # r_am (may be negative)
direct_variance(fit_dm)        # sigma_ad
partner_variance(fit_dm)       # sigma_am
direct_maternal_covariance(fit_dm)  # sigma_dm
variance_components(fit_dm)    # all four components
maternal_effects(fit_dm)       # maternal EBVs
}
```
