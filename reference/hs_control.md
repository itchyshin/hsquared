# Create hsquared control options

`hs_control()` records execution and storage controls for hsquared model
calls. The default `engine = "fit"` fits the validated v0.1 Gaussian
animal model through the `HSquared.jl` engine (average-information
REML); `engine = "validate"` parses and validates the contract without
fitting; and `engine = "julia"` exposes advanced engine controls.

## Usage

``` r
hs_control(
  engine = c("fit", "validate", "julia"),
  backend = c("auto", "cpu", "threads", "cuda", "amdgpu", "metal", "oneapi"),
  accelerator = c("auto", "none", "gpu", "cuda", "amdgpu", "metal", "oneapi"),
  precision = c("float64", "float32"),
  save = c("minimal", "full", "tiny"),
  engine_control = list()
)
```

## Arguments

- engine:

  Execution engine. `"fit"` (default) fits the v0.1 Gaussian animal
  model via the `HSquared.jl` engine; this requires a local Julia, the
  `JuliaCall` package, and an `HSquared.jl` checkout. `"validate"` stops
  after parser and bridge payload validation without fitting. `"julia"`
  exposes the advanced opt-in bridge with explicit `target` control.

- backend:

  Planned compute backend. One of `"auto"`, `"cpu"`, `"threads"`,
  `"cuda"`, `"amdgpu"`, `"metal"`, or `"oneapi"`.

- accelerator:

  Planned accelerator preference. One of `"auto"`, `"none"`, `"gpu"`,
  `"cuda"`, `"amdgpu"`, `"metal"`, or `"oneapi"`.

- precision:

  Planned numeric precision. One of `"float64"` or `"float32"`.

- save:

  Planned fitted-object storage mode. One of `"minimal"`, `"full"`, or
  `"tiny"`.

- engine_control:

  A named list for engine-specific controls. The current experimental
  Julia bridge recognizes `julia_project`, `initial`, `iterations`,
  `target`, and `variance_components`. `target = "henderson_mme"` is a
  supplied-variance validation path and requires `variance_components`
  with named `sigma_a2` and `sigma_e2` values. `target = "sparse_reml"`
  is an experimental, opt-in validation path that surfaces the
  Julia-owned `HSquared.fit_sparse_reml()` REML-only sparse optimizer;
  it accepts `initial` (named `sigma_a2`/`sigma_e2`) and `iterations`.
  It is not the default, not production fitting, and not a
  variance-component estimation claim for the public R interface.
  `target = "ai_reml"` exposes the same average-information REML
  estimator (`HSquared.fit_ai_reml()`) that the default `engine = "fit"`
  path uses, with explicit `initial` and `iterations` control. This is
  the validated v0.1 estimator for the univariate Gaussian animal model;
  the `engine = "fit"` default is the ordinary way to reach it.
  `target = "repeatability"` is an experimental, opt-in path for the
  repeatability (permanent-environment) model. It requires
  `animal(1 | id, pedigree = ped) + permanent(1 | id)` in the formula
  and surfaces the Julia-owned `HSquared.fit_repeatability_reml()`
  REML-only optimizer (three-component `initial` with
  `sigma_a2`/`sigma_pe2`/`sigma_e2`). It is REML only, not the default,
  and the additive and permanent-environment variances are identifiable
  only with repeated records per individual.

## Value

An object of class `"hs_control"`.
