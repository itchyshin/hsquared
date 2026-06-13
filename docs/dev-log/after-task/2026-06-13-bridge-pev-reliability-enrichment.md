# Bridge PEV/Reliability Enrichment

Date: 2026-06-13

Active lenses: Hopper, Lovelace, Fisher, Emmy, Rose, Grace.

Spawned subagents: none.

## Scope

Enrich the experimental local R-to-Julia bridge so tiny `hsquared_fit` objects
can contain dense validation-path prediction-error-variance and reliability
fields when the sibling `HSquared.jl` checkout exposes matching exported
functions.

This does not change the default `hsquared()` behavior. The default engine
still validates and stops. This does not claim production sparse PEV,
production reliability, general animal-model support, or Mrode fitted-output
validation.

## Implementation

Updated:

- `R/julia-bridge.R`;
- `tests/testthat/test-julia-bridge.R`;
- `README.md`;
- `vignettes/articles/model-status.Rmd`;
- `NEWS.md`;
- `docs/design/01-v0.1-contract.md`;
- `docs/design/03-engine-contract.md`;
- `docs/design/capability-status.md`;
- `docs/design/validation-debt-register.md`;
- `docs/design/06-public-claims-register.md`;
- `docs/dev-log/check-log.md`;
- `docs/dev-log/coordination-board.md`.

Bridge behavior:

1. Fit the tiny payload with `HSquared.fit_animal_model()`.
2. Read the stable base `HSquared.result_payload()`.
3. If `HSquared.prediction_error_variance()` and `HSquared.reliability()` are
   defined, merge those dense validation-path fields into the R-side raw
   result.
4. Normalize those fields into the existing `hsquared_fit` extractor contract.

## Validation

Local checks:

- `air format .`: completed.
- `Rscript -e "devtools::test(filter = 'julia-bridge')"`: `34 pass`,
  `0 fail`, `0 warnings`, `0 skips`; the sibling `HSquared.jl` checkout was
  activated.
- `Rscript -e "devtools::test()"`: `195 pass`, `0 fail`, `0 warnings`,
  `0 skips`; the sibling `HSquared.jl` checkout was activated.
- `git diff --check`: clean.
- Stale wording scan for old PEV/reliability bridge text: no matches.
- `Rscript -e "pkgdown::check_pkgdown()"`: no problems found.
- `Rscript -e "devtools::check()"`: `0 errors | 0 warnings | 0 notes`.

## Rose Audit

Verdict: clean with limitations.

Allowed wording:

- dense validation-path PEV/reliability enrichment exists for tiny opt-in local
  bridge examples when the sibling Julia checkout exposes those extractors;
- default `hsquared()` still validates and stops;
- production bridge and validation-canon work remain required.

Blocked wording:

- production sparse PEV/reliability works;
- Mrode fitted-output validation exists;
- public/general animal-model fitting is implemented;
- Julia GPU, genomic, QTL/eQTL, or GLLVM work is affected by this slice.

## Follow-up

- Coordinate with the Julia twin so Documenter can describe the R-side bridge
  enrichment without changing Julia's stable base `result_payload()` until a
  lockstep payload-widening decision is made.
- Add fitted Mrode output validation before broadening any public fitting claim.
