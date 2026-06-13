# Inspect planned compute backends

`backend_info()` reports which backend names are accepted by
[`hs_control()`](https://itchyshin.github.io/hsquared/reference/hs_control.md)
and whether any of them are execution-ready from the R package. In the
current package state, backend names are control metadata only: they are
selectable but not dispatched.

## Usage

``` r
backend_info(control = hs_control())
```

## Arguments

- control:

  An object created by
  [`hs_control()`](https://itchyshin.github.io/hsquared/reference/hs_control.md).

## Value

A data frame of backend status records with class `"hs_backend_info"`.
