# Extract an experimental repeatability confidence interval

`repeatability_interval()` returns an **experimental** large-sample
(logit delta-method) confidence interval for the repeatability
coefficient `t = (Va + Vpe) / Vp` of the opt-in repeatability
(permanent-environment) model, available only when the fit contains it.

## Usage

``` r
repeatability_interval(object, ...)
```

## Arguments

- object:

  A fitted model object.

- ...:

  Reserved for future arguments.

## Value

A one-row data frame with `estimate` (the repeatability `t`), `lower`,
`upper`, `level`, and `se`, for `hsquared_fit` objects that contain it.

## Details

It mirrors the engine row `V3-REPEAT-REML` (`partial`): the engine's
repeatability REML estimator and this interval are engine-internal
self-consistency tested (recovery of `t` and interval bracketing / range
/ level-nesting / point-estimate match on seeded fixtures), but there is
no external comparator, no `h²` interval, and no deep-pedigree
validation. It is asymptotic, REML-only, unreliable at small `n` or near
the (0, 1) boundary (where the engine throws and the field is omitted),
and not a validated capability.
