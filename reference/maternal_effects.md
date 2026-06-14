# Extract maternal genetic effects

`maternal_effects()` returns the predicted maternal genetic effects of
the opt-in, experimental maternal two-effect model
(`target = "two_effect"` with a
[`maternal_genetic()`](https://itchyshin.github.io/hsquared/reference/qg_effect_markers.md)
term).

## Usage

``` r
maternal_effects(object, ...)
```

## Arguments

- object:

  A fitted model object.

- ...:

  Reserved for future arguments.

## Value

Maternal genetic effect results for maternal `hsquared_fit` objects.
