# Forest plot of a known-truth recovery study

Visualizes a bias +/- 2*MCSE recovery study (e.g.
`data-raw/multivariate-recovery-study.R`): each target's bias with its
+/- 2*MCSE interval and a zero-bias reference line. Targets whose
interval covers zero show "no detectable bias".

## Usage

``` r
hs_recovery_forest(data)
```

## Arguments

- data:

  A data frame with `target`, `bias`, and `mcse` columns.

## Value

A `ggplot` object.
