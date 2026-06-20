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
autoplot(
  object,
  type = c("variance", "breeding_values", "g_matrix", "g_geometry", "reaction_norm",
    "rr_eigenfunctions", "rr_surface"),
  ...
)

# S3 method for class 'hs_gwas'
autoplot(object, type = c("manhattan", "qq"), ...)
```

## Arguments

- object:

  An `hsquared_fit` or `hs_gwas` object.

- type:

  Which figure to draw (see Details).

- ...:

  Figure-specific options passed through: `low_h2` (the
  genetic-correlation heatmap flags off-diagonal cells involving a trait
  with `h^2 < low_h2` as imprecise; default `0.1`), `at`/`n` (the
  reaction-norm covariate evaluation points), and `correlation`
  (`rr_surface`: draw the genetic-correlation surface instead of the
  covariance surface).

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
  cross-lane convention). Off-diagonal cells involving a low-`h^2` trait
  are flagged as imprecise (threshold `low_h2`, default `0.1`).

- `"g_geometry"` – a scree of the **rotation-invariant** genetic
  eigenstructure (eigenvalues = variance per genetic axis, with percent
  variance explained) for multivariate fits. Axis directions / loadings
  are never drawn (rotation-arbitrary; span-ambiguous under repeated
  eigenvalues).

- `"reaction_norm"` – for random-regression fits, the genetic-variance
  and heritability trajectories across the covariate (faceted). The
  heritability trajectory carries the same caveat as
  [`rr_heritability()`](https://itchyshin.github.io/hsquared/reference/random_regression_extractors.md):
  with a homogeneous residual and no permanent-environment term it can
  overstate `h^2(t)` for repeated-records designs.

- `"rr_eigenfunctions"` – for random-regression fits, the
  rotation-invariant eigenfunctions `psi_j(t)` of `K_g` as covariate
  functions (faceted by axis, labelled by percent genetic variance).
  Signs are arbitrary and the curves are span-ambiguous under repeated
  eigenvalues (do not over-read).

- `"rr_surface"` – for random-regression fits, the genetic covariance
  surface `S(s, t) = phi(s)' K_g phi(t)` over the covariate grid as a
  heatmap (pass `correlation = TRUE` for the genetic-correlation
  surface). Supplied-`K_g` descriptive.

[`autoplot()`](https://ggplot2.tidyverse.org/reference/autoplot.html) on
a [`gwas()`](https://itchyshin.github.io/hsquared/reference/gwas.md)
scan (`hs_gwas`) draws `type = "manhattan"` (default) or `type = "qq"`
(observed vs expected `-log10(p)` with a `y = x` null and the
genomic-inflation `lambda_GC` as a diagnostic). Both carry the
EXPERIMENTAL, NOT-genome-wide-calibrated caveat (gate `HSquared.jl#48`).

The figure helpers are deliberately modular (each takes a tidy data
frame and returns a `ggplot`) so they can be factored into a shared
visualization package later.
