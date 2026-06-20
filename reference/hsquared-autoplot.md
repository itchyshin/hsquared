# ggplot2 visualizations for hsquared results

[`autoplot()`](https://ggplot2.tidyverse.org/reference/autoplot.html)
methods render the quantitative-genetic results an `hsquared_fit` (or a
[`gwas()`](https://itchyshin.github.io/hsquared/reference/gwas.md) scan)
carries as `ggplot2` objects, in the style of the `brms`/`bayesplot`
ecosystem and consistent with the sister packages `drmTMB`/`gllvmTMB`.
They are **uncertainty-first**: where the fit carries the experimental
standard errors / reliabilities, the figures show them (clearly labelled
experimental and asymptotic).

## Usage

``` r
# S3 method for class 'hsquared_fit'
autoplot(object, type = c("variance", "breeding_values", "g_matrix"), ...)

# S3 method for class 'hs_gwas'
autoplot(object, ...)
```

## Arguments

- object:

  An `hsquared_fit` or `hs_gwas` object.

- type:

  Which figure to draw (see Details).

- ...:

  Currently unused.

## Value

A `ggplot` object.

## Details

Available `type`s for `autoplot.hsquared_fit()`:

- `"variance"` (default) – a horizontal forest of the variance
  components and per-trait `h^2`, each with approximate 95% intervals
  (`+/- 1.96 * SE`) when the fit carries the experimental standard
  errors.

- `"breeding_values"` – a sorted caterpillar of the estimated breeding
  values, with `+/- 1.96 * sqrt(PEV)` bands when prediction error
  variances are available, faceted by trait for multivariate fits.

- `"g_matrix"` – a **rotation-invariant** genetic-correlation heatmap of
  the estimated `G` for multivariate fits (correlations are invariant to
  the factor rotation; raw loadings are never plotted – the ratified
  cross-lane convention).

The figure helpers are deliberately modular (each takes a tidy data
frame and returns a `ggplot`) so they can be factored into a shared
visualization package later.
