# Reserved factor-analytic and G-matrix extractors

These extractor names are reserved for future factor-analytic G-matrix
results. The current package can report invariant covariance and
correlation matrices from opt-in multivariate fits, but it does not yet
expose interpreted loadings, uniqueness/specific variance, latent
breeding values, or eigen-G summaries. Loading columns are
rotation-nonunique until a rotation or constraint policy is validated.
Future `hsquared_fit` methods reserve `effect` and rotation controls,
but these controls currently error rather than implying that loading
axes are interpretable.

## Usage

``` r
genetic_loadings(object, ...)

specific_variance(object, ...)

latent_breeding_values(object, ...)

eigen_G(object, ...)
```

## Arguments

- object:

  A fitted model object.

- ...:

  Reserved for future arguments.

## Value

These reserved extractors currently error for `hsquared_fit` objects.
