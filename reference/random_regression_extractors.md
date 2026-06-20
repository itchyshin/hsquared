# Random-regression (reaction-norm) extractors

These extractors summarize an opt-in, **experimental** random-regression
(reaction-norm) fit (`target = "random_regression"`), fitted with an
`animal(rr(covariate, order = k) | id, pedigree = ped)` term. The model
estimates a `k x k` genetic covariance matrix `K_g` among an animal's
normalized-Legendre random-regression coefficients plus a single
homogeneous residual variance.

## Usage

``` r
rr_covariance(object, ...)

random_coefficients(object, ...)

rr_genetic_variance(object, at = NULL, n = 25L, ...)

rr_heritability(object, at = NULL, n = 25L, ...)

rr_correlation(object, at = NULL, n = 25L, ...)
```

## Arguments

- object:

  A random-regression `hsquared_fit` object.

- ...:

  Reserved for future arguments.

- at:

  Covariate values on the original scale at which to evaluate the
  trajectory. `NULL` (the default) uses an evenly spaced grid over the
  fitted covariate range.

- n:

  Number of grid points used when `at = NULL`.

## Value

`rr_covariance()` returns a numeric matrix; `random_coefficients()`
returns a data frame; the trajectory extractors return a data frame with
a `covariate` column and the evaluated `value`s.

## Details

- `rr_covariance()` returns the estimated `k x k` coefficient genetic
  covariance matrix `K_g`.

- `random_coefficients()` returns the per-animal predicted Legendre
  coefficients (long format: `id`, `coefficient`, `value`).

- `rr_genetic_variance()` returns the additive genetic variance
  trajectory `v_g(t) = phi(t)' K_g phi(t)` across covariate points.

- `rr_heritability()` returns the heritability trajectory
  `h^2(t) = v_g(t) / (v_g(t) + sigma_e^2)`. Because the residual is
  homogeneous and there is no permanent-environment term yet, this can
  OVERSTATE `h^2(t)` for repeated-records designs (test-day, growth
  curves).

- `rr_correlation()` returns the genetic correlation surface among the
  covariate points.

The trajectories are computed in R from the estimated `K_g` and the
recorded covariate standardization range; `at` is supplied on the
ORIGINAL covariate scale (defaulting to a grid over the fitted range)
and re-standardized to `[-1, 1]` internally, matching the Julia engine's
basis convention.

## Examples

``` r
if (FALSE) {
fit_rr <- hsquared(
  weight ~ sex + animal(rr(age, order = 2) | id, pedigree = ped),
  data = long_records,
  family = gaussian(),
  REML = TRUE,
  control = hs_control(
    engine = "julia",
    engine_control = list(target = "random_regression")
  )
)

rr_covariance(fit_rr)
random_coefficients(fit_rr)
rr_genetic_variance(fit_rr)
rr_heritability(fit_rr)
rr_correlation(fit_rr, at = c(1, 3, 5))
}
```
