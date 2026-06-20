# G-matrix geometry and evolvability

These extractors summarise the genetic variance-covariance matrix `G` of
an opt-in multivariate `hsquared_fit` (`target = "multivariate"`)
through its **rotation-invariant** geometry, following Hansen & Houle
(2008). They are defined on `G` itself (not on factor loadings), so they
are well defined for any multivariate fit — unstructured, diagonal, or
(when bridged) low-rank / factor-analytic — and do not depend on a
loading rotation convention.

## Usage

``` r
evolvability(object, direction, ...)

respondability(object, direction, ...)

conditional_evolvability(object, direction, ...)

autonomy(object, direction, ...)

mean_evolvability(object, ...)

g_max(object, ...)

variance_along_gradient(object, direction, normalize = TRUE, ...)

eigen_G(object, ...)
```

## Arguments

- object:

  An `hsquared_fit` from the opt-in multivariate target.

- direction:

  A numeric vector of selection gradients, one per trait. It is
  normalised to unit length internally; only its direction matters.

- ...:

  Unused.

- normalize:

  For `variance_along_gradient()`, whether to scale `direction` to unit
  length first (`TRUE`, the default, which then equals
  `evolvability()`); `FALSE` uses `direction` as given, returning the
  genetic variance in the raw (un-normalised) selection gradient `β'Gβ`.

## Value

A scalar for the directional metrics; a list for `eigen_G()` (`values`,
`vectors`) and `g_max()` (`eigenvalue`, `eigenvector`).

## Details

- `eigen_G()` returns the genetic eigenstructure: `values` (the variance
  along each genetic principal axis, descending) and `vectors` (the
  genetic principal components, sign-canonicalised so the
  largest-magnitude element of each is positive).

- `g_max()` returns the leading genetic axis: its `eigenvalue` and
  `eigenvector` (the direction of maximum evolvability).

- `mean_evolvability()` is the average evolvability over random
  selection directions, `tr(G) / t`.

- `evolvability(fit, direction)` is `e(β) = β'Gβ` (unit `β`): the
  additive genetic variance available to directional selection along
  `direction`.

- `variance_along_gradient(fit, direction, normalize)` is `β'Gβ` for a
  unit `direction` (`normalize = TRUE`, equal to `evolvability()`) or
  for the raw `direction` (`normalize = FALSE`).

- `respondability(fit, direction)` is `‖Gβ‖`: the length of the
  response.

- `conditional_evolvability(fit, direction)` is `1 / (β'G⁻¹β)`:
  evolvability when all other directions are held under stabilising
  selection (requires a positive-definite `G`).

- `autonomy(fit, direction)` is
  `conditional_evolvability / evolvability` in `[0, 1]` (requires a
  positive-definite `G`).

These are computed in R from the fitted `genetic_covariance(fit)` and
match the engine's `evolvability.jl` definitions (verified by a
skip-guarded live parity test). They are descriptive geometry of the
estimated `G`; they carry the same experimental, REML-only,
not-coverage-calibrated status as the multivariate fit itself and report
no standard errors.

## References

Hansen, T. F., & Houle, D. (2008). Measuring and comparing evolvability
and constraint in multivariate characters. *Journal of Evolutionary
Biology*, 21(5), 1201-1219.
