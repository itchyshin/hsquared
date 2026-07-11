# Extract a supplied metafounder Gamma matrix

**\[experimental\]**

## Usage

``` r
gamma_matrix(object, ...)
```

## Arguments

- object:

  A fitted model object.

- ...:

  Reserved for future arguments.

## Value

A numeric matrix with metafounder labels when the fitted object contains
a supplied `Gamma` payload.

## Details

`gamma_matrix()` returns the supplied metafounder `Gamma` matrix carried
by an experimental metafounder or `H^Gamma` single-step `hsquared_fit`
object. It is provenance for the fitted relationship, not an estimated
parameter.
