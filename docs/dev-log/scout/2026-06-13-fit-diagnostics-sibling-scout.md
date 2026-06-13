# Fit Diagnostics Sibling Scout

Date: 2026-06-13

Active lenses: Jason, Emmy, Hopper, Pat, Rose

Spawned subagents: none

Current lane: R

## Local Sources Checked

- `/Users/z3437171/Dropbox/Github Local/drmTMB/R/methods.R`
- `/Users/z3437171/Dropbox/Github Local/gllvmTMB/R/extractors.R`
- `/Users/z3437171/Dropbox/Github Local/GLLVM.jl/src/postfit.jl`
- `/Users/z3437171/Dropbox/Github Local/DRM.jl/src/DRM.jl`

## Lessons

- `drmTMB` print methods surface log-likelihood and convergence status early,
  which helps users distinguish a result object from an uninspected fit.
- `GLLVM.jl` post-fit displays consistently report log-likelihood, AIC,
  convergence, and iteration counts for fitted objects.
- `DRM.jl` exports explicit fit-inspection vocabulary such as convergence and
  likelihood helpers.
- For `hsquared`, this pattern should stay conservative: expose the diagnostics
  already present in an `hsquared_fit` payload, but do not imply that the
  experimental bridge is production animal-model fitting.

## Decision

Add a small `fit_diagnostics()` extractor for `hsquared_fit` objects. It should
report engine, method, family, bridge target, convergence, optimizer status,
iterations, log-likelihood metadata, and any extra scalar diagnostics supplied
by the Julia result payload.
