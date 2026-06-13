# Mrode-Style Supplied-Variance Fixture

Date: 2026-06-13

Active lenses: Ada, Shannon, Jason, Hopper, Lovelace, Curie, Fisher, Mrode,
Rose, Grace.

Spawned subagents: none.

Current lane: R validation.

## Goal

Mirror the Julia twin's Mrode-style supplied-variance validation fixture in the
R repo without claiming general fitting, variance-component estimation, or
ASReml parity.

## Files Changed

- `R/validation-fixtures.R`
- `R/validation-status.R`
- `tests/testthat/test-validation-fixtures.R`
- `tests/testthat/test-phase0-api.R`
- `README.md`
- `NEWS.md`
- `vignettes/articles/model-status.Rmd`
- `vignettes/articles/mission-control.Rmd`
- `docs/design/04-validation-canon.md`
- `docs/design/06-public-claims-register.md`
- `docs/design/capability-status.md`
- `docs/design/validation-debt-register.md`
- `docs/dev-log/scout/2026-06-13-mrode-supplied-variance-fixture.md`
- `docs/dev-log/check-log.md`
- `docs/dev-log/coordination-board.md`
- `docs/dev-log/after-task/2026-06-13-mrode-style-supplied-variance-fixture.md`

## Implementation

Added internal `hs_mrode_supplied_variance_validation_fixture()` with a
twelve-animal Mrode-style pedigree, supplied variance components, expected
`Ainv`, fixed effects, EBVs, fitted values, PEV, reliability, h2, ML
log-likelihood, and REML log-likelihood.

Added independent R reference helpers for:

- Henderson MME PEV;
- reliability;
- dense Gaussian ML/REML log-likelihood at supplied variance components.

Added tests that:

- pin R payload ordering, `X`, sparse `Z`, and expected `Ainv`;
- compare the fixture against independent R reference calculations;
- optionally compare live `HSquared.jl` `gaussian_loglik()`,
  `sparse_reml_loglik()`, and `henderson_mme()` outputs when JuliaCall and the
  sibling checkout are available.

## Public Claim Audit

Allowed wording:

- Mrode-style supplied-variance validation fixture;
- pinned Ainv, fixed effects, EBVs, fitted values, PEV, reliability, h2, ML
  log-likelihood, and dense/sparse REML log-likelihood;
- partial validation evidence.

Blocked wording:

- general animal-model fitting is implemented;
- variance-component estimation is implemented;
- AI-REML is implemented;
- full Mrode fitted-output validation is complete;
- ASReml or production-software parity is established;
- production sparse PEV/reliability is available.

## Checks

- `air format . && Rscript -e "devtools::test(filter = 'validation-fixtures|mrode-validation|phase0-api|julia-bridge')"`
  - Initial result: two failures caused by incidental row names inherited from
    named PEV/reliability vectors.
  - Fix: strip incidental names in the R reference result helper.
  - Result after fix: `192 pass`, `0 fail`, `0 warnings`, `0 skips`; live
    Julia bridge activated sibling `HSquared.jl`.
- `Rscript -e "devtools::test()"`: `460 pass`, `0 fail`, `0 warnings`,
  `0 skips`; live Julia bridge activated sibling `HSquared.jl`.
- `Rscript -e "pkgdown::build_articles(lazy = FALSE); pkgdown::check_pkgdown()"`:
  articles rebuilt, including `mission-control.html` and `model-status.html`;
  pkgdown reported `No problems found.`
- `Rscript -e "devtools::check()"`: passed with `0 errors`, `0 warnings`, and
  `0 notes`.
- `git diff --check`: clean.
- Rendered article spot-check:
  `rg -n "Mrode-style supplied-variance|estimated-variance Mrode|full Mrode" pkgdown-site/articles/model-status.html pkgdown-site/articles/mission-control.html`
  found the model-status and mission-control wording plus the blocked
  estimated-variance Mrode claim.
- Targeted Rose search:
  `rg -n "Mrode validation complete|animal-model fitting works|REML estimation works|ASReml parity is established|variance-component estimation is implemented|GPU execution is available|QTL/eQTL.*available" README.md NEWS.md docs/design vignettes || true`
  returned no matches.

## Tests Of The Tests

- The expected fixture values are pinned constants copied from the Julia twin,
  not produced by the R helper under test.
- The pure R test independently recomputes MME, PEV/reliability, and dense
  ML/REML likelihood values.
- The optional live Julia test checks the sibling engine path separately.

## What Did Not Go Smoothly

The first focused run failed because `diag()` preserved animal IDs as vector
names, which became data-frame row names. The numeric evidence was already
correct; the helper now removes those incidental names before constructing
data frames.

## Known Limitations

- Supplied variance components only.
- No optimizer, AI-REML, or estimated variance components.
- No external ASReml/BLUPF90/DMU/WOMBAT comparator yet.
- No production sparse reliability claim.

## Next Actions

1. Push and record remote CI/pkgdown/Pages evidence.
2. Notify issue #7 and the Julia twin with the exact claim boundary.

## Closeout Verification (Claude, R lane)

This slice was authored by the sister thread and synced into the R working tree
via Dropbox; the R-lane Claude took over the closeout (no re-implementation).

- Independent numeric re-derivation: rebuilt the pedigree -> A -> Ainv ->
  Henderson MME and marginal-V ML/REML from scratch in pure R (not via the
  fixture helpers under test) and confirmed every pinned value (Ainv, fixed
  effects, EBVs, fitted, PEV, reliability, h2, ML logLik, dense/sparse REML
  logLik) matches the Julia targets to machine precision (max abs diff approx
  1.8e-14; h2/ML/REML exact).
- Local: `rcmdcheck::rcmdcheck()` `0 errors | 0 warnings | 0 notes`; full
  `devtools::test()` all pass with the live Julia bridge active;
  `air format --check .` and `git diff --check` clean.
- Remote (commit `a437feb`): R-CMD-check `27467574922`, pkgdown `27467574904`,
  Pages `27467612204` all passed.
- Rose audit: clean; all public wording stays within the supplied-variance
  boundary (no estimation / fitted-Mrode / production / ASReml-parity claim).
- Commit pair: `a437feb` (Add) + the following `Record ... CI evidence` commit.
