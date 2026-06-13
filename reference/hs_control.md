# Create hsquared control options

`hs_control()` records execution and storage controls for hsquared model
calls. The default `engine = "validate"` parses and validates the v0.1
contract before stopping. The experimental `engine = "julia"` path
attempts the current local Julia bridge for tiny v0.1 animal-model
payloads.

## Usage

``` r
hs_control(
  engine = c("validate", "julia"),
  backend = c("auto", "cpu", "cuda"),
  accelerator = c("auto", "none", "cuda"),
  precision = c("float64", "float32"),
  save = c("minimal", "full", "tiny"),
  engine_control = list()
)
```

## Arguments

- engine:

  Execution engine. `"validate"` stops after parser and bridge payload
  validation. `"julia"` uses the experimental local JuliaCall bridge.

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

  A named list for engine-specific controls. The current experimental
  Julia bridge recognizes `julia_project`, `initial`, and
  `max_dense_cells`.

## Value

An object of class `"hs_control"`.
