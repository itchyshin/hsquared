# Extract an experimental common-environment / maternal variance-ratio interval

`common_env_proportion_interval()` and `maternal_proportion_interval()`
return an **experimental** large-sample (logit delta-method) confidence
interval for the second variance ratio (`c2` / `m2`, `ratio2`) of the
opt-in two-effect model, available only when the fit contains it. On the
same two-effect fit,
[`heritability_interval()`](https://itchyshin.github.io/hsquared/reference/heritability_interval.md)
returns the matching interval for the direct heritability (`h2`,
`ratio1`).

## Usage

``` r
common_env_proportion_interval(object, ...)

maternal_proportion_interval(object, ...)
```

## Arguments

- object:

  A fitted model object.

- ...:

  Reserved for future arguments.

## Value

A one-row data frame with `estimate` (the ratio), `lower`, `upper`,
`level`, `se`, `lower_clamped`, `upper_clamped`, and `boundary`, plus an
`"interpretation"` attribute, for two-effect `hsquared_fit` objects that
contain it.

## Details

This mirrors the engine row `V3-TWOEFFECT-REML`: the interval is the
asymptotic delta-method CI built from the two-effect REML observed
information (the finite-difference Hessian of the two-effect REML
log-likelihood at the optimum). It is **asymptotic, delta-method, REML
only, and NOT coverage-calibrated** — on small samples the REML surface
is flat and the interval is unreliable (the parametric bootstrap is the
only finite-sample- aware path). No calibrated coverage is claimed.

Boundary honesty: when the ratio's variance component sits on the
boundary (`sigma -> 0`) it is flagged (`boundary = TRUE`) and
`lower`/`upper` are `NA`, never a spuriously tight CI.
`lower_clamped`/`upper_clamped` flag when a bound reaches the numerical
`(0, 1)` rails.

Falconer fence: `c2` / `m2` is a **variance ratio**, not a heritability
(see
[`common_env_proportion()`](https://itchyshin.github.io/hsquared/reference/common_env_proportion.md)
/
[`maternal_proportion()`](https://itchyshin.github.io/hsquared/reference/maternal_proportion.md)).
