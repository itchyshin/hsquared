# Extract breeding values

`breeding_values()` is part of the planned v0.1 fitted-object contract.
It works for internal `hsquared_fit` objects that already contain a
Julia result, but ordinary calls to
[`hsquared()`](https://itchyshin.github.io/hsquared/reference/hsquared.md)
do not return fitted models yet.

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
