# R Live Julia Bridge Smoke

Date: 2026-06-13

Active lenses: Ada, Shannon, Hopper, Lovelace, Grace, Rose, Pat.

Spawned subagents: none. The Julia twin lane was verified from local repo state
and GitHub Actions.

## Scope

Advance issue #6 from payload shape only to a local internal R-to-Julia smoke
test. This slice does not make `hsquared()` fit models for users.

## Implementation

Added:

- `R/julia-bridge.R`
- `tests/testthat/test-julia-bridge.R`

The internal bridge:

- checks that `JuliaCall`, a `julia` executable, and a sibling `HSquared.jl`
  project are available;
- activates the sibling Julia project;
- sends the existing internal `hs_bridge_payload` into Julia;
- asks Julia to normalize the pedigree, build `Ainv`, call
  `fit_animal_model()`, and return `result_payload()`;
- normalizes the Julia result into the existing internal `hsquared_fit`
  result contract;
- refuses non-tiny payloads before densifying `Z`.

## Validation

Local checks:

- `Rscript -e "devtools::document()"`: completed after loading `hsquared`.
- `git diff --check`: clean.
- `Rscript -e "devtools::test()"`: passed with `93 pass`, `0 fail`,
  `0 warnings`, and `0 skips`; the live bridge activated
  `~/Dropbox/Github Local/HSquared.jl`.
- `Rscript -e "pkgdown::check_pkgdown()"`: `No problems found.`
- `Rscript -e "devtools::check()"`: `0 errors | 0 warnings | 0 notes`.

The live test asserts:

- internal `hsquared_fit` class;
- convergence;
- finite log-likelihood;
- two variance components;
- non-negative variance estimates;
- breeding-value IDs;
- fixed-effect names;
- finite heritability;
- `stats::logLik()` compatibility.

## Cross-Repo Note

The first live smoke exposed a useful sibling issue: `HSData` referenced
`HSDataIDMap` before the type was defined. The Julia twin resolved that in
`HSquared.jl` commit `798cfb7 Add HSData input container`. From this lane,
`julia --project=. -e 'using Pkg; Pkg.test()'` and
`julia --project=docs docs/make.jl` were also verified clean against the
sibling checkout before closing the R slice.

## Rose Audit

Verdict: clean with limitations.

Allowed wording:

- local internal JuliaCall smoke path for the tiny v0.1 payload;
- bridge-shape validation against sibling `HSquared.jl`;
- internal `hsquared_fit` normalization from Julia result payload.

Blocked wording:

- `hsquared()` fits models;
- production R-to-Julia bridge execution is implemented;
- sparse production fitting is implemented;
- ASReml-level animal-model support exists;
- this tiny dense smoke path is suitable for large data.

## Next Work

1. Wire `hsquared(..., engine = "julia")` only after an explicit engine-control
   surface and user-facing error policy are designed.
2. Replace the dense tiny `Z` transfer with sparse marshalling.
3. Add Mrode-style validation through the live bridge before claiming fitted
   animal-model support.
