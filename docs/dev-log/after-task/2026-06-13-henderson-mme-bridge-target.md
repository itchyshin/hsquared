# Supplied-Variance Henderson MME Bridge Target

Date: 2026-06-13

Active lenses: Hopper, Lovelace, Henderson, Fisher, Rose, Grace.

Spawned subagents: none.

## Scope

Expose an explicit opt-in R-to-Julia bridge target for supplied-variance
Henderson MME validation:

```r
hs_control(
  engine = "julia",
  engine_control = list(
    target = "henderson_mme",
    variance_components = c(sigma_a2 = 1.2, sigma_e2 = 0.8)
  )
)
```

This is a tiny validation bridge target. It does not estimate variance
components, return a log-likelihood, run AI-REML, validate Mrode fitted outputs,
or claim production sparse fitting.

## Skills

Used:

- `bridge-contract-review`;
- `engine-contract-review`;
- `after-task-audit`.

## Implementation

Added:

- `hs_validate_julia_target()`;
- `hs_validate_supplied_variances()`;
- `hs_fit_julia_henderson_mme_payload()`;
- `hs_normalize_julia_henderson_mme_result()`;
- `hsquared()` dispatch for `engine_control$target = "henderson_mme"`;
- live tests through direct payload and through `hsquared()`.

The bridge path uses the existing R payload, builds `Ainv` in Julia, calls
`HSquared.henderson_mme()`, and normalizes fixed effects, EBVs/BLUPs, fitted
values, supplied variance components, h2, `nobs`, and diagnostics into an
`hsquared_fit` object. It deliberately omits `loglik`, `df`, PEV, and
reliability.

Updated:

- README;
- model-status article;
- v0.1 contract;
- engine contract;
- capability status;
- validation debt register;
- public claims register;
- NEWS;
- roxygen docs;
- coordination board;
- check log.

## Validation

Local checks:

- `Rscript -e "devtools::document()" && air format . && Rscript -e "devtools::test(filter = 'julia-bridge|phase0-api')"`:
  docs updated, formatting completed, `111 pass`, `0 fail`, `0 warnings`,
  `0 skips`; live Julia bridge activated sibling `HSquared.jl`.
- `Rscript -e "devtools::test()"`: `327 pass`, `0 fail`, `0 warnings`,
  `0 skips`; live bridge activated sibling `HSquared.jl`.
- `Rscript -e "pkgdown::build_articles(lazy = FALSE); pkgdown::check_pkgdown()"`:
  articles rebuilt and `No problems found.`
- `Rscript -e "devtools::check()"`: first run had a transient timestamp note
  (`unable to verify current time`); rerun was `0 errors`, `0 warnings`,
  `0 notes`.
- `git diff --check`: clean.

Remote checks:

- Pending until this slice is pushed.

## Rose Audit

Verdict: clean with limitations.

Allowed wording:

- opt-in supplied-variance Henderson MME bridge target;
- tiny validation examples;
- fixed effects, EBVs/BLUPs, fitted values, supplied variance components, and
  h2.

Blocked wording:

- variance components are estimated;
- log-likelihood or AIC is available for this target;
- AI-REML is implemented;
- general animal-model support is implemented;
- Mrode fitted-output validation is covered;
- production sparse fitting is validated.

## Next Work

1. Ask the Julia twin to keep `henderson_mme()` result/documentation wording
   aligned with the R bridge target.
2. Add fitted Mrode output validation before broadening any public fitting
   language.
