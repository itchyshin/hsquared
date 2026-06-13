# Extract breeding values

`breeding_values()` is part of the planned v0.1 fitted-object contract.
It works for `hsquared_fit` objects that contain a Julia result. `EBV()`
and `BLUP()` are aliases for applied quantitative-genetic workflows.

## Usage

``` r
breeding_values(object, ...)

EBV(object, ...)

BLUP(object, ...)
```

## Arguments

- object:

  A fitted model object.

- ...:

  Reserved for future arguments.

## Value

Breeding value results for `hsquared_fit` objects.
