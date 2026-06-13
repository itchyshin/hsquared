# Extract breeding values

`breeding_values()` is part of the planned v0.1 fitted-object contract.
It works for `hsquared_fit` objects that contain a Julia result.

## Usage

``` r
breeding_values(object, ...)
```

## Arguments

- object:

  A fitted model object.

- ...:

  Reserved for future arguments.

## Value

Breeding value results for `hsquared_fit` objects.
