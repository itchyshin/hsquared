# Likelihood-ratio test for genetic covariance structure

`covariance_structure_lrt(constrained, full)` is an **experimental**
nested likelihood-ratio test comparing two opt-in multivariate fits **on
the same data**: a `constrained` genetic structure (currently
`genetic_structure = "diagonal"`) against the `full` `"unstructured"`
fit. The statistic is `2 * (logLik(full) - logLik(constrained))` on
`df = n_genetic_params(full) - n_genetic_params(constrained)`.

## Usage

``` r
covariance_structure_lrt(constrained, full, ...)
```

## Arguments

- constrained, full:

  Two `hsquared_fit` objects from the opt-in multivariate target; `full`
  must nest `constrained` (more genetic covariance parameters).

- ...:

  Unused.

## Value

A one-row data frame with `statistic`, `df`, `pvalue`, `boundary`, and
the `constrained` / `full` genetic-structure labels.

## Details

For diagonal-vs-unstructured the null (off-diagonal genetic covariances
= 0) is interior, so the χ² reference is exact (`boundary = FALSE`).
Structures whose null lies on a rank/PSD boundary (low-rank /
factor-analytic) would need a χ²-mixture correction and are gated out of
the R bridge for now.

It mirrors the engine row `V4-MV-REML` (`partial`): asymptotic,
REML-only, dense validation-scale, with the multivariate recovery
calibration not yet passed — a reported test, not a validated one. Both
fits must be on the same response, fixed effects, and pedigree.
