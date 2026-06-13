# Create hsquared control options

`hs_control()` records the planned execution and storage controls for
future hsquared model calls. In Phase 0 these options are validated and
stored, but no model fitting is performed.

## Usage

``` r
hs_control(
  backend = c("auto", "cpu", "cuda"),
  accelerator = c("auto", "none", "cuda"),
  precision = c("float64", "float32"),
  save = c("minimal", "full", "tiny"),
  engine_control = list()
)
```

## Arguments

- backend:

  Planned compute backend. One of `"auto"`, `"cpu"`, or `"cuda"`.

- accelerator:

  Planned accelerator preference. One of `"auto"`, `"none"`, or
  `"cuda"`.

- precision:

  Planned numeric precision. One of `"float64"` or `"float32"`.

- save:

  Planned fitted-object storage mode. One of `"minimal"`, `"full"`, or
  `"tiny"`.

- engine_control:

  A named list reserved for future HSquared.jl engine controls.

## Value

An object of class `"hs_control"`.
