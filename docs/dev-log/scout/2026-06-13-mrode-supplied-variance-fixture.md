# Mrode-Style Supplied-Variance Fixture Scout

Date: 2026-06-13

Active lenses: Jason, Curie, Fisher, Mrode, Hopper, Lovelace, Rose.
Spawned subagents: none.

## Question

How should the R lane mirror the Julia twin's Mrode-style validation work
without overstating `hsquared` fitting support?

## Sources Checked

- `HSquared.jl/test/runtests.jl`: Phase 1 Mrode-style supplied-variance
  validation fixture with pinned Ainv, fixed effects, EBVs, fitted values, PEV,
  reliability, h2, ML log-likelihood, and dense/sparse REML log-likelihood.
- `HSquared.jl/src/likelihood.jl`: `gaussian_loglik()`,
  `sparse_reml_loglik()`, and `henderson_mme()` boundaries.
- `gllvmTMB/R/julia-bridge.R`: R-to-Julia bridge discipline where Julia output
  is normalized into ordinary R result methods.
- `DRM.jl/src/comparison.jl`: REML guardrail that likelihood comparisons must
  name the estimator and avoid comparing different fixed-effect structures.
- `.agents/skills/quantgen-scout/references/packages.md`: local comparison map
  for ASReml, MCMCglmm, sommer, JWAS, BLUPF90, DMU, WOMBAT, AGHmatrix, nadiv,
  XSim, drmTMB/DRM.jl, and gllvmTMB/GLLVM.jl.

## Lesson

The right R-side move is a validation fixture, not a public fitting claim. The
fixture should pin the same supplied-variance estimand as the Julia twin and
separate it from:

- variance-component estimation;
- AI-REML;
- production sparse fitting;
- ASReml or production-software parity;
- general Mrode fitted-output validation.

## hsquared Action

Add an internal R fixture that:

- uses the same twelve-animal Mrode-style pedigree and supplied variances;
- checks independent R reference MME and dense-likelihood calculations;
- optionally checks live `HSquared.jl` Ainv, MME, dense ML/REML likelihood, and
  sparse REML likelihood through JuliaCall;
- keeps public wording at `partial` validation evidence.

## Claim Risk

Avoid wording such as "Mrode validation complete", "animal-model fitting works",
"REML estimation works", or "ASReml parity". Allowed wording is
"Mrode-style supplied-variance validation fixture".
