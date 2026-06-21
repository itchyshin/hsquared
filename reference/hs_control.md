# Create hsquared control options

`hs_control()` records execution and storage controls for hsquared model
calls. The default `engine = "fit"` fits the validated v0.1 Gaussian
animal model through the `HSquared.jl` engine (average-information
REML); `engine = "validate"` parses and validates the contract without
fitting, returning the validated spec invisibly; and `engine = "julia"`
exposes advanced engine controls.

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
  `JuliaCall` package, and an `HSquared.jl` checkout. `"validate"`
  validates the parser and bridge payload without fitting, then returns
  the validated spec invisibly (after a confirming message). `"julia"`
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
  `target`, `variance_components`, and `marginal`. `target` selects
  which Julia estimator the `engine = "julia"` bridge runs; it has no
  effect under the default `engine = "fit"` path. The supported targets
  are `"fit_animal_model"`, `"ai_reml"`, `"sparse_reml"`,
  `"henderson_mme"`, `"repeatability"`, `"two_effect"`, `"genomic"`,
  `"single_step"`, `"single_step_construct"`, `"metafounder"`,
  `"metafounder_single_step"`, `"snp_blup"`, `"multivariate"`, and
  `"nongaussian"`, described below. `marginal` applies only to
  `target = "nongaussian"`. With `engine = "julia"` and no `target`, the
  bridge defaults to `target = "fit_animal_model"`: it surfaces the
  Julia-owned `HSquared.fit_animal_model()` dense NelderMead optimizer,
  honouring the `REML` flag. This is **not** the same estimator as the
  default `engine = "fit"` path, which runs the validated
  average-information REML estimator (`HSquared.fit_ai_reml()`, the same
  one reached by `target = "ai_reml"`). The two paths target the same
  Gaussian animal model but differ at the optimizer level, so their
  estimates can differ slightly. Reach the validated estimator with
  `engine = "fit"` (the ordinary path) or with `engine = "julia"` and
  `target = "ai_reml"`. `target = "henderson_mme"` is a
  supplied-variance validation path and requires `variance_components`
  with named `sigma_a2` and `sigma_e2` values. `target = "metafounder"`
  is an experimental supplied-variance validation path for
  `metafounder(1 | id, pedigree = ped, group = mf_group, Gamma = Gamma)`.
  It builds the Julia-owned animal-only `A^Gamma` relationship; `Gamma`
  and the variance components are supplied, not estimated.
  `target = "sparse_reml"` is an experimental, opt-in validation path
  that surfaces the Julia-owned `HSquared.fit_sparse_reml()` REML-only
  sparse optimizer; it accepts `initial` (named `sigma_a2`/`sigma_e2`)
  and `iterations`. It is not the default, not production fitting, and
  not a variance-component estimation claim for the public R interface.
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
  only with repeated records per individual. `target = "two_effect"` is
  an experimental, opt-in path for two-effect models. It requires
  `animal(1 | id, pedigree = ped)` plus a second random effect —
  `common_env(1 | group)` (an IID common-environment effect) or
  `maternal_genetic(1 | dam)` (a maternal genetic effect carrying the
  pedigree relationship) — and surfaces the Julia-owned
  `HSquared.fit_two_effect_reml()` REML-only optimizer (three-component
  `initial` with `sigma_a2`/`sigma_c2`/`sigma_e2`). It is REML only and
  not the default. `target = "genomic"` and `target = "single_step"` are
  experimental, opt-in paths that fit a single effect whose relationship
  is a user-supplied inverse: `genomic(1 | id, Ginv = Ginv)` (a genomic
  relationship inverse) or `genomic(1 | id, markers = M)` (a marker
  matrix the engine turns into a genomic relationship), and
  `single_step(1 | id, Hinv = Hinv)` (a single-step relationship
  inverse). All surface `HSquared.fit_ai_reml()`. They are REML only and
  not the default. `target = "single_step_construct"` fits
  `single_step(1 | id, pedigree = ped, markers = M)` after the engine
  builds `H^-1` from the pedigree and genotyped-subset markers.
  `target = "metafounder_single_step"` fits
  `single_step(1 | id, pedigree = ped, markers = M, group = mf_group, Gamma = Gamma)`
  through the Julia-owned supplied-`Gamma` `H^Gamma` path. Both are
  experimental, opt-in, dense/validation-scale, REML-only, and not
  comparator-validated; `Gamma` is supplied, not estimated.
  `target = "snp_blup"` is an experimental, opt-in path for the SNP-BLUP
  / RR-BLUP marker-effect model. It requires
  `genomic(1 | id, markers = M)` (a raw marker matrix) and estimates
  per-marker effects
  ([`marker_effects()`](https://itchyshin.github.io/hsquared/reference/marker_extractors.md))
  and per-individual genomic breeding values. `variance_components` is
  **optional**: supply named `sigma_g2` (genomic) and `sigma_e2`
  (residual) for a supplied-variance solve (`HSquared.fit_snp_blup()`),
  or omit them to have
  [`hsquared()`](https://itchyshin.github.io/hsquared/reference/hsquared.md)
  **estimate** `sigma_g2`/`sigma_e2` by REML from the markers
  (`HSquared.fit_snp_blup_reml()`). Not the default.
  `target = "multivariate"` is an experimental, opt-in path for the
  multivariate Gaussian animal model. It requires a
  `cbind(trait1, trait2, ...)` response with
  `animal(1 | id, pedigree = ped)`, surfaces the Julia-owned
  `HSquared.fit_multivariate_reml()` REML-only optimizer, and returns
  G/R covariance matrices, genetic and residual correlations, per-trait
  heritability, and cross-trait breeding values. It is not the default
  and remains a `partial` validation claim until t\>=2 known-truth
  recovery and external-comparator evidence are committed. The reserved
  `genetic_structure` control currently accepts `"unstructured"` and
  `"diagonal"` on the R bridge. `"diagonal"` is the rotation-free
  structured subset: off-diagonal genetic covariances are fixed at zero.
  `"lowrank"` and `"factor_analytic"` remain planned until the loading
  rotation and interpretation contract is validated. The future `rank`
  control is also reserved and currently errors instead of being
  ignored.

  `target = "nongaussian"` is an experimental, opt-in latent-scale GLMM
  for
  `family = poisson()`/[`binomial()`](https://rdrr.io/r/stats/family.html)
  (binary 0/1) on `animal(1 | id, pedigree = ped)`, surfacing the
  Julia-owned `HSquared.fit_laplace_reml()` REML optimizer. The
  `marginal` control selects the approximation: `"laplace"` (the Laplace
  approximation, default) or `"variational"` (the variational/ELBO
  marginal; aliases `"la"`/`"va"`). Because a non-Gaussian family has no
  residual-variance scale, **no heritability** is reported. The
  variational objective is the ELBO (a lower bound on the marginal
  log-likelihood), so a variational fit's `logLik`/`AIC` are **not**
  comparable with a Laplace fit's. Experimental, REML-only, not
  coverage-calibrated (twin gate `V6-LAPLACE`/`VA`, partial).

## Value

An object of class `"hs_control"`.
