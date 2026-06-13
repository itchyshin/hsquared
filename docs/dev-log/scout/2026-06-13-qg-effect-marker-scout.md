# Quantitative-Genetic Effect Marker Scout

Date: 2026-06-13

Active lenses: Jason, Boole, Darwin, Rose.

## Local Packages Checked

- `gllvmTMB`
- `drmTMB`
- `DRM.jl`
- `GLLVM.jl`

## Useful Patterns

- `gllvmTMB` uses explicit animal keyword families and keeps `A`/`Ainv`
  naming separate from sampling-variance `V`.
- `drmTMB` exposes structured-effect status through marker names such as
  `animal()` and `relmat()`, and keeps fitted, planned, and unsupported states
  separate in diagnostics and documentation.
- `DRM.jl` treats `relmat()` and `animal()` as parse-time markers that are
  intercepted before ordinary formula evaluation.
- `GLLVM.jl` design notes favor structured precision and low-rank/factor
  computation, which supports keeping later inheritance kernels in one
  coherent grammar rather than as disconnected helper functions.

## Decision For hsquared

Reserve explicit marker names for the standard quantitative-genetic expansion:
permanent environment, common environment, maternal/paternal genetic and
environmental effects, cytoplasmic inheritance, imprinting, dominance,
epistasis, and user-supplied relationship or precision matrices.

The current R package should export those markers only as inert syntax. The
parser must reject them before model-frame construction with planned-not-
implemented wording.

## Claim Boundary

This scout supports API vocabulary only. It does not support any public claim
that permanent environment, common environment, maternal/paternal effects,
dominance, epistasis, cytoplasmic inheritance, imprinting, or custom-kernel
models are implemented.
