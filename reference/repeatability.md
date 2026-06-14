# Extract repeatability estimates

`repeatability()` reports the repeatability `R = (Va + Vpe) / Vp` of the
opt-in, experimental repeatability (permanent-environment) model. It
works for `hsquared_fit` objects fitted with
`engine_control = list(target = "repeatability")`.

## Usage

``` r
repeatability(object, ...)
```

## Arguments

- object:

  A fitted model object.

- ...:

  Reserved for future arguments.

## Value

Repeatability results for repeatability `hsquared_fit` objects.
