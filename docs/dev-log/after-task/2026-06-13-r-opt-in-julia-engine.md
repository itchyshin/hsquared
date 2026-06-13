# R Opt-In Julia Engine

Date: 2026-06-13

Active lenses: Ada, Shannon, Hopper, Lovelace, Emmy, Grace, Rose, Pat.

Spawned subagents: none.

## Scope

Move the local live bridge from an internal-only smoke helper to an explicit
experimental user-facing path:

```r
hsquared(..., control = hs_control(engine = "julia"))
```

The default remains validation-only. This slice does not claim general animal
model fitting, sparse production marshalling, Mrode validation, or large-data
readiness.

## Implementation

Added:

- `engine = c("validate", "julia")` to `hs_control()`;
- named-list validation for `engine_control`;
- `hs_engine_control_value()` for bridge settings;
- `hsquared()` dispatch to `hs_fit_julia_payload()` only when
  `engine = "julia"`;
- `hs_validate_max_dense_cells()`;
- tests for control validation, opt-in fitting, and dense-guard validation.

The Julia-specific controls remain under `engine_control`. Current recognized
fields are:

- `julia_project`
- `initial`
- `max_dense_cells`

## Validation

Local checks:

- `air format .`: completed.
- `Rscript -e "devtools::document()"`: regenerated Rd topics.
- `Rscript -e "devtools::test()"`: `105 pass`, `0 fail`, `0 warnings`,
  `0 skips`; live tests activated sibling `HSquared.jl`.
- `git diff --check`: clean.
- `Rscript -e "pkgdown::check_pkgdown()"`: `No problems found.`
- `Rscript -e "devtools::check()"`: `0 errors | 0 warnings | 0 notes`.

## Rose Audit

Verdict: clean with limitations.

Allowed wording:

- experimental opt-in Julia engine;
- tiny local v0.1 animal-model examples;
- dense guarded bridge validation;
- returns `hsquared_fit` when Julia, JuliaCall, and sibling `HSquared.jl` are
  available.

Blocked wording:

- general animal-model fitting is implemented;
- default `hsquared()` fits models;
- sparse production R-to-Julia marshalling exists;
- large data or ASReml-level support exists;
- Mrode validation is covered.

## Next Work

1. Add a Mrode/tiny validation fixture through the opt-in engine.
2. Replace dense `Z` transfer with sparse marshalling.
3. Decide the eventual default-engine policy only after validation evidence is
   stronger.
