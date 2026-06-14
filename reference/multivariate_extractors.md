# Extract multivariate covariance and correlation matrices

These extractors return the genetic (`G`) and residual (`R`) covariance
or correlation matrices from opt-in multivariate `hsquared_fit` objects
(`target = "multivariate"`). `G_matrix()` is an applied-workflow alias
for `genetic_covariance()`, and `R_matrix()` is an alias for
`residual_covariance()`. Use them after checking
[`fit_diagnostics()`](https://itchyshin.github.io/hsquared/reference/fit_diagnostics.md)
because likelihood-based summaries are intentionally blocked when a
multivariate fit has not converged.

## Usage

``` r
genetic_covariance(object, ...)

G_matrix(object, ...)

residual_covariance(object, ...)

R_matrix(object, ...)

genetic_correlation(object, ...)

residual_correlation(object, ...)
```

## Arguments

- object:

  A fitted model object.

- ...:

  Reserved for future arguments.

## Value

A numeric matrix for `hsquared_fit` objects that contain the requested
multivariate result field.

## Examples

``` r
if (FALSE) {
fit_mv <- hsquared(
  cbind(weight, length) ~ sex + age + animal(1 | id, pedigree = ped),
  data = dat,
  family = gaussian(),
  REML = TRUE,
  control = hs_control(
    engine = "julia",
    engine_control = list(target = "multivariate")
  )
)

fit_diagnostics(fit_mv)

genetic_covariance(fit_mv)
G_matrix(fit_mv)
residual_covariance(fit_mv)
R_matrix(fit_mv)
genetic_correlation(fit_mv)
residual_correlation(fit_mv)
heritability(fit_mv)
}
```
