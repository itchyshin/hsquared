# Reading G matrices

This article is for the applied moment after a multivariate animal model
has fit: you want to know what the genetic covariance matrix says, what
the residual matrix says, and where the current evidence boundary is.

The current `hsquared` multivariate path is experimental and opt-in. It
estimates an unstructured additive-genetic covariance matrix `G` and
residual covariance matrix `R` for Gaussian animal models. It is not yet
production multi-trait software, and it does not yet provide standard
errors, confidence intervals, selection-response predictions,
factor-analytic loadings, or a general phenotypic covariance extractor.

## Model scale

For the current two-or-more-trait Gaussian animal model,

``` math
\mathrm{vec}(\mathbf a) \sim
\mathrm{MVN}\left(\mathbf 0, \mathbf G \otimes \mathbf A\right),
\qquad
\mathrm{vec}(\mathbf e) \sim
\mathrm{MVN}\left(\mathbf 0, \mathbf R \otimes \mathbf I\right).
```

`A` is the additive relationship matrix from the pedigree. `G` is the
trait-by-trait additive-genetic covariance matrix. `R` is the
trait-by-trait residual covariance matrix. The two matrices are on the
scale of the response traits after the fixed effects in the formula.

``` r

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
```

## The G matrix

Use
[`G_matrix()`](https://itchyshin.github.io/hsquared/reference/multivariate_extractors.md)
when you want the additive-genetic covariance matrix in the language of
quantitative genetics. It is an alias for the more explicit
[`genetic_covariance()`](https://itchyshin.github.io/hsquared/reference/multivariate_extractors.md)
extractor.

``` r

G_matrix(fit_mv)
genetic_covariance(fit_mv)
```

Read the diagonal as additive-genetic variance for each trait. Larger
diagonal entries mean more additive-genetic variation on that trait’s
measurement scale.

Read the off-diagonal as additive-genetic covariance between traits. A
positive entry means animals with higher additive-genetic values for one
trait tend to have higher additive-genetic values for the other. A
negative entry means the additive-genetic values tend to move in
opposite directions.

For interpretation across traits with different units, use the genetic
correlation:

``` r

genetic_correlation(fit_mv)
```

The genetic correlation is standardized, so it is often easier to read
than the raw covariance. It is not a causal statement by itself. A
correlation tells you how additive-genetic deviations line up in the
fitted model; selection response still needs the relevant selection
gradient and a clearly defined prediction target.

## The R matrix

Use
[`R_matrix()`](https://itchyshin.github.io/hsquared/reference/multivariate_extractors.md)
for the residual covariance matrix. It is an alias for
[`residual_covariance()`](https://itchyshin.github.io/hsquared/reference/multivariate_extractors.md).

``` r

R_matrix(fit_mv)
residual_covariance(fit_mv)
residual_correlation(fit_mv)
```

`R` collects variation not assigned to the additive animal effect or
fixed effects in the current model. It can include measurement noise,
microenvironment, unmodelled common environment, unmodelled maternal
effects, and other residual sources. Do not read a residual correlation
as genetic integration.

## Heritability and EBVs

For the current animal-plus-residual multivariate model, per-trait
heritability is read from the diagonal pieces of `G` and `R`:

``` math
h^2_j = \frac{G_{jj}}{G_{jj} + R_{jj}}.
```

Use the extractor rather than calculating by hand:

``` r

heritability(fit_mv)
```

Future models with permanent environment, common environment, maternal
effects, or genomic effects will need a model-specific phenotypic
denominator. That is why this slice does not add a general `P_matrix()`
extractor yet.

Breeding values are returned by animal and trait:

``` r

breeding_values(fit_mv)
EBV(fit_mv)
```

In an unbalanced response matrix, an animal can be missing one trait and
still receive breeding values for all traits. The missing trait borrows
information through the fitted genetic covariance and the pedigree
relationship.

## What to trust first

Trust invariant summaries first:

- `G_matrix(fit)` / `genetic_covariance(fit)`;
- `R_matrix(fit)` / `residual_covariance(fit)`;
- `genetic_correlation(fit)` and `residual_correlation(fit)`;
- `heritability(fit)`;
- `breeding_values(fit)`;
- `fit_diagnostics(fit)`.

The **rotation-invariant** geometry of `G` is now surfaced
(experimental): the genetic eigenstructure via `eigen_G(fit)` and
`g_max(fit)`, and the Hansen & Houle (2008) evolvability measures
[`evolvability()`](https://itchyshin.github.io/hsquared/reference/g_matrix_geometry.md),
[`variance_along_gradient()`](https://itchyshin.github.io/hsquared/reference/g_matrix_geometry.md),
[`respondability()`](https://itchyshin.github.io/hsquared/reference/g_matrix_geometry.md),
[`conditional_evolvability()`](https://itchyshin.github.io/hsquared/reference/g_matrix_geometry.md),
[`autonomy()`](https://itchyshin.github.io/hsquared/reference/g_matrix_geometry.md),
and
[`mean_evolvability()`](https://itchyshin.github.io/hsquared/reference/g_matrix_geometry.md).
These are functionals of `G` itself, not of factor loadings, so they are
well defined without a rotation convention.

Factor *loadings*, specific variance, and latent breeding values stay
reserved: loading axes are sign- and rotation-nonunique unless the model
has a validated constraint or rotation policy. The agreed cross-lane
convention is to bridge only rotation-invariant functionals of `G` (the
eigenbasis + the invariants above), never the raw loadings. Until a
loading-rotation policy is validated, `hsquared` keeps the invariant
covariance, correlation, eigenstructure, and evolvability geometry as
the stable interpretation layer.

## Current evidence boundary

The current multivariate surface is `partial`.

Covered in the R lane:

- [`cbind()`](https://rdrr.io/r/base/cbind.html) response grammar;
- missing response cells preserved as `NA` and marshalled to Julia
  `NaN`;
- G/R covariance and correlation extraction;
- [`G_matrix()`](https://itchyshin.github.io/hsquared/reference/multivariate_extractors.md)
  and
  [`R_matrix()`](https://itchyshin.github.io/hsquared/reference/multivariate_extractors.md)
  aliases over those same fields;
- per-trait heritability and cross-trait EBVs;
- the rotation-invariant G geometry:
  [`eigen_G()`](https://itchyshin.github.io/hsquared/reference/g_matrix_geometry.md),
  [`g_max()`](https://itchyshin.github.io/hsquared/reference/g_matrix_geometry.md),
  and the Hansen & Houle evolvability measures (live-verified against
  the engine; experimental, no standard errors);
- a shared deterministic R/Julia fixture;
- an optional `sommer` comparator for the diagonal-residual version of
  the shared fixture.

Still planned:

- acceptance or broadening of the current `t >= 2` recovery gate;
- a second independent same-estimand comparator beyond `sommer` for
  unstructured `G` and full `R`;
- *validated*, coverage-calibrated standard errors and confidence
  intervals for G/R entries, correlations, and heritabilities
  (experimental, asymptotic SEs are already available via
  [`covariance_standard_errors()`](https://itchyshin.github.io/hsquared/reference/covariance_standard_errors.md)
  for an unstructured fit — `V4-MV-REML`, partial: the strict per-seed
  recovery gate is still a non-pass (7/12 seeds), though the 12-seed
  bias/MCSE study (twin `HSquared.jl#78`/`#79`) shows no detectable
  bias; unstructured-only, not coverage-calibrated);
- production sparse multivariate fitting;
- `cov = diag()`, `cov = lowrank(K)`, and `cov = fa(K)` R grammar;
- a general `P_matrix()` extractor with a model-specific estimand.

## Background anchors

The reason G matrices matter is classical quantitative genetics: the
additive genetic covariance matrix connects multivariate inheritance,
constraint, and response to selection. Useful anchors are [Lande and
Arnold’s correlated-trait selection
framework](https://pubmed.ncbi.nlm.nih.gov/28556011/), [Kirkpatrick,
Lofsvold and Bulmer’s work on genetic covariance functions for growth
trajectories](https://pubmed.ncbi.nlm.nih.gov/2323560/), and [Hansen and
Houle’s evolvability measures for multivariate
characters](https://pubmed.ncbi.nlm.nih.gov/18662244/).

For `hsquared`, the current package reports the fitted G and R matrices
and now the rotation-invariant eigenstructure and Hansen & Houle
evolvability geometry (experimental, no standard errors).
Selection-response and factor-analytic *loading* interpretation stay
behind explicit validation gates (loadings need a validated rotation
policy; nothing here is coverage-calibrated).

See also:

- [Multivariate Gaussian animal
  models](https://itchyshin.github.io/hsquared/articles/multivariate.md)
- [Model
  status](https://itchyshin.github.io/hsquared/articles/model-status.md)
- [Formula grammar
  roadmap](https://itchyshin.github.io/hsquared/articles/formula-grammar.md)
